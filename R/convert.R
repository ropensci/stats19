#' Convert raw STATS19 CSV files to Parquet
#'
#' @description
#' Reads raw STATS19 CSV files from the data directory and converts them into
#' highly compressed, typed, columnar Parquet files using DuckDB.
#' Normalises schema variations across historical releases (such as
#' `accident_index` vs `collision_index`, date string formats, and column renames).
#'
#' @param type Type of data to convert: `"collision"` (or `"accident"`),
#'   `"casualty"`, `"vehicle"`, or `"all"`.
#' @param years Optional vector of years to convert. If `NULL` (default), all
#'   available files for the requested type in `data_dir` are converted.
#' @param data_dir Directory containing raw downloaded CSV files.
#'   Defaults to `get_data_directory()`.
#' @param output_dir Directory where the Parquet file(s) will be written.
#'   Defaults to `get_parquet_directory()`.
#' @param filename Optional output filename. If `NULL` (default), the file is
#'   named `{type}s.parquet` (e.g. `collisions.parquet`).
#' @param partition_by Optional column name(s) to partition by, e.g. `"collision_year"`.
#'   If supplied, a Hive-partitioned directory will be written.
#' @param compression Parquet compression codec: `"zstd"` (default) or `"snappy"`.
#' @param max_mem_gb Maximum memory limit in GB for DuckDB during conversion (default: 4).
#' @param temp_dir Path to DuckDB temporary spilling directory (default: `tempdir()`).
#' @param overwrite Logical. If `TRUE` (default), overwrites existing Parquet output.
#' @param silent Logical. Suppress informational messages? (default: `FALSE`).
#'
#' @return The path to the created Parquet file or directory (invisibly).
#' @export
#'
#' @examples
#' \donttest{
#' if (requireNamespace("duckdb", quietly = TRUE) &&
#'     requireNamespace("DBI", quietly = TRUE)) {
#'   # Convert collision files to Parquet in a temporary folder
#'   tmp_parquet <- file.path(tempdir(), "parquet")
#'   # stats19_to_parquet(type = "collision", output_dir = tmp_parquet)
#' }
#' }
stats19_to_parquet = function(type = "collision",
                              years = NULL,
                              data_dir = get_data_directory(),
                              output_dir = get_parquet_directory(),
                              filename = NULL,
                              partition_by = NULL,
                              compression = "zstd",
                              max_mem_gb = 4,
                              temp_dir = tempdir(),
                              overwrite = TRUE,
                              silent = FALSE) {
  compression = match.arg(tolower(compression), c("zstd", "snappy"))
  stopifnot(is.numeric(max_mem_gb), length(max_mem_gb) == 1, max_mem_gb > 0)

  if (!requireNamespace("duckdb", quietly = TRUE) || !requireNamespace("DBI", quietly = TRUE)) {
    stop("Packages 'duckdb' and 'DBI' are required to convert STATS19 data to Parquet.", call. = FALSE)
  }

  if (identical(type, "all")) {
    out = character(0)
    for (t in c("collision", "casualty", "vehicle")) {
      out = c(out, stats19_to_parquet(
        type = t,
        years = years,
        data_dir = data_dir,
        output_dir = output_dir,
        partition_by = partition_by,
        compression = compression,
        max_mem_gb = max_mem_gb,
        temp_dir = temp_dir,
        overwrite = overwrite,
        silent = silent
      ))
    }
    return(invisible(out))
  }

  # Normalise type
  type_clean = tolower(type)
  if (grepl("acc|col", type_clean)) {
    type_clean = "collision"
    plural_name = "collisions"
    file_pattern = "(^|[-_])(accident|collision)([-_]|$)"
  } else if (grepl("cas", type_clean)) {
    type_clean = "casualty"
    plural_name = "casualties"
    file_pattern = "(^|[-_])(casualty|casualties)([-_]|$)"
  } else if (grepl("veh", type_clean)) {
    type_clean = "vehicle"
    plural_name = "vehicles"
    file_pattern = "(^|[-_])(vehicle|vehicles)([-_]|$)"
  } else {
    stop("Unrecognised type: ", type, ". Must be collision, casualty, vehicle, or all.", call. = FALSE)
  }

  if (!dir.exists(data_dir)) {
    stop("Source data directory does not exist: ", data_dir, call. = FALSE)
  }
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Find available CSV files in data_dir
  all_csvs = list.files(data_dir, pattern = "\\.csv$", full.names = TRUE)
  # Strip common DfT prefix so 'casualty' does not match collision and vehicle filenames
  stripped_bnames = sub("^dft[-_]road[-_]casualty[-_]statistics[-_]", "", basename(all_csvs), ignore.case = TRUE)
  type_csvs = all_csvs[grepl(file_pattern, stripped_bnames, ignore.case = TRUE)]

  # Exclude adjustment lookups
  type_csvs = type_csvs[!grepl("adjustment", basename(type_csvs), ignore.case = TRUE)]

  if (length(type_csvs) == 0) {
    message("No CSV files found in ", data_dir, " for type '", type_clean, "'.")
    return(invisible(NULL))
  }

  # Filter by years if requested
  if (!is.null(years)) {
    year_pats = paste0("-", years, "\\.csv")
    type_csvs = type_csvs[grepl(paste(year_pats, collapse = "|"), basename(type_csvs))]
    if (length(type_csvs) == 0) {
      message("No CSV files found matching requested years.")
      return(invisible(NULL))
    }
  } else {
    # If not filtering by specific years:
    # 1. Drop rolling 'last-5-years.csv' if individual annual files are present
    has_annual = any(grepl("-(19|20)\\d{2}\\.csv$", basename(type_csvs)))
    if (has_annual) {
      type_csvs = type_csvs[!grepl("last-5-years", basename(type_csvs))]
    }

    # 2. Avoid duplicate records between 1979-latest and individual years
    has_longrun = any(grepl("1979-", basename(type_csvs)))
    if (has_longrun) {
      longrun_file = type_csvs[grepl("1979-", basename(type_csvs))][1]
      # Detect the end year of the long-run file, e.g. 1979-2021 -> 2021
      m = regmatches(basename(longrun_file), regexec("1979-(\\d{4})", basename(longrun_file)))
      if (length(m[[1]]) >= 2) {
        end_year = as.integer(m[[1]][2])
        # Drop individual annual files that are already inside the long-run file
        annual_files = type_csvs[!grepl("1979-", basename(type_csvs))]
        years_in_annual = as.integer(gsub(".*?-(19|20)(\\d{2})\\.csv$", "\\1\\2", basename(annual_files)))
        keep_annual = annual_files[!is.na(years_in_annual) & years_in_annual > end_year]
        type_csvs = c(longrun_file, keep_annual)
      }
    }
  }

  if (length(type_csvs) == 0) {
    message("No matching files found for conversion.")
    return(invisible(NULL))
  }

  # Establish output file path
  target_file = filename %||% paste0(plural_name, ".parquet")
  out_path = file.path(output_dir, target_file)

  if (file.exists(out_path) && !overwrite) {
    message("Output file already exists and overwrite is FALSE: ", out_path)
    return(invisible(out_path))
  }

  if (!silent) {
    message("Converting ", length(type_csvs), " file(s) for '", type_clean, "' to Parquet...")
  }

  # Connect DuckDB
  con = DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))

  DBI::dbExecute(con, "SET preserve_insertion_order = false;")
  DBI::dbExecute(con, glue::glue("SET memory_limit = '{max_mem_gb}GB';"))
  if (dir.exists(temp_dir)) {
    DBI::dbExecute(con, glue::glue("SET temp_directory = '{temp_dir}';"))
  }

  # Format file list for SQL
  escaped_files = gsub("'", "''", type_csvs)
  files_sql = paste0("['", paste(escaped_files, collapse = "', '"), "']")

  # Create temporary view over input CSV files
  view_name = "raw_stats19_input"
  view_create_sql = glue::glue("
    CREATE OR REPLACE TEMPORARY VIEW {view_name} AS
    SELECT * FROM read_csv({files_sql}, union_by_name = true, all_varchar = true);
  ")
  DBI::dbExecute(con, view_create_sql)

  # Choose schema definition according to type
  schema_defs = switch(
    type_clean,
    "collision" = stats19_schema_collision,
    "casualty"  = stats19_schema_casualty,
    "vehicle"   = stats19_schema_vehicle
  )

  # Build SELECT query dynamically based on columns present in input
  sql_select = build_stats19_select_query(con, view_name, schema_defs)

  # Build COPY statement
  partition_sql = ""
  if (!is.null(partition_by)) {
    part_cols = paste(partition_by, collapse = ", ")
    partition_sql = glue::glue(", PARTITION_BY ({part_cols})")
  }

  escaped_out = gsub("'", "''", out_path)
  copy_sql = glue::glue("
    COPY ({sql_select})
    TO '{escaped_out}'
    (FORMAT PARQUET, COMPRESSION {toupper(compression)}, ROW_GROUP_SIZE 100000{partition_sql});
  ")

  DBI::dbExecute(con, copy_sql)

  if (!silent) {
    message("Saved Parquet file at: ", out_path)
  }

  invisible(out_path)
}

# Internal helper: build SELECT statement mapping input columns to standard Parquet schema
build_stats19_select_query = function(con, view_name, schema_defs) {
  actual_cols = DBI::dbListFields(con, view_name)
  actual_lower = tolower(actual_cols)
  names(actual_lower) = actual_cols

  select_clauses = character(0)
  used_cols = character(0)

  for (item in schema_defs) {
    target_name = item$name
    target_type = item$type
    candidates = item$candidates

    # Match candidates in prioritized order
    matched_candidates = candidates[tolower(candidates) %in% actual_lower]
    matched_actual = actual_cols[match(tolower(matched_candidates), actual_lower)]

    if (length(matched_actual) == 0) {
      select_clauses = c(select_clauses, glue::glue("  NULL::{target_type} AS {target_name}"))
    } else {
      used_cols = union(used_cols, matched_actual)

      if (!is.null(item$special) && item$special == "date") {
        d_col = paste0('"', matched_actual[1], '"')
        clause = glue::glue("  CASE
    WHEN {d_col} IS NULL THEN NULL
    WHEN {d_col} LIKE '%/%' THEN try_strptime({d_col}, '%d/%m/%Y')::DATE
    ELSE try_strptime({d_col}, '%Y-%m-%d')::DATE
  END AS {target_name}")
        select_clauses = c(select_clauses, clause)
      } else if (length(matched_actual) == 1) {
        col_ref = paste0('"', matched_actual[1], '"')
        if (toupper(target_type) %in% c("VARCHAR", "TEXT")) {
          select_clauses = c(select_clauses, glue::glue("  {col_ref}::VARCHAR AS {target_name}"))
        } else {
          select_clauses = c(select_clauses, glue::glue("  TRY_CAST({col_ref} AS {target_type}) AS {target_name}"))
        }
      } else {
        # Multiple matched (e.g. collision_index and accident_index both present across files)
        quoted_refs = paste0('"', matched_actual, '"')
        coalesce_expr = paste(glue::glue("NULLIF({quoted_refs}, '')"), collapse = ", ")
        if (toupper(target_type) %in% c("VARCHAR", "TEXT")) {
          select_clauses = c(select_clauses, glue::glue("  COALESCE({coalesce_expr})::VARCHAR AS {target_name}"))
        } else {
          select_clauses = c(select_clauses, glue::glue("  TRY_CAST(COALESCE({coalesce_expr}) AS {target_type}) AS {target_name}"))
        }
      }
    }
  }

  # Append any extra columns from input CSVs as VARCHAR
  extra_cols = setdiff(actual_cols, used_cols)
  for (col in extra_cols) {
    col_ref = paste0('"', col, '"')
    select_clauses = c(select_clauses, glue::glue("  TRY_CAST({col_ref} AS VARCHAR) AS \"{col}\""))
  }

  paste0("SELECT\n", paste(select_clauses, collapse = ",\n"), "\nFROM ", view_name)
}

# Internal helper to check if a Parquet file covers requested years
parquet_has_years = function(parquet_file, years = NULL) {
  if (!file.exists(parquet_file)) return(FALSE)
  if (!requireNamespace("duckdb", quietly = TRUE) || !requireNamespace("DBI", quietly = TRUE)) {
    return(FALSE)
  }

  con = tryCatch(suppressMessages(DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")), error = function(e) NULL)
  if (is.null(con)) return(FALSE)
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  escaped_pq = gsub("'", "''", parquet_file)
  range_df = tryCatch({
    DBI::dbGetQuery(con, glue::glue("SELECT min(collision_year) AS min_y, max(collision_year) AS max_y FROM read_parquet('{escaped_pq}')"))
  }, error = function(e) NULL)

  if (is.null(range_df) || is.null(range_df$min_y) || is.na(range_df$min_y) || is.na(range_df$max_y)) {
    return(FALSE)
  }

  fn = unlist(stats19::file_names)
  m = regmatches(fn, regexpr("20[0-9]{2}", fn))
  latest = if (length(m) > 0) max(as.integer(m), na.rm = TRUE) else 2024

  if (is.null(years) || identical(years, "all") || identical(years, 1979) || identical(years, 1979L)) {
    return(range_df$min_y <= 1979 && range_df$max_y >= latest)
  }

  if (identical(years, 5) || identical(years, "5 years")) {
    return(range_df$max_y >= latest && range_df$min_y <= (latest - 4))
  }

  if (is.numeric(years)) {
    int_years = as.integer(years)
    if (min(int_years) < range_df$min_y || max(int_years) > range_df$max_y) {
      return(FALSE)
    }
    yr_str = paste0(int_years, collapse = ", ")
    q = glue::glue("SELECT count(DISTINCT collision_year) AS cnt FROM read_parquet('{escaped_pq}') WHERE collision_year IN ({yr_str})")
    cnt_df = tryCatch(DBI::dbGetQuery(con, q), error = function(e) NULL)
    if (!is.null(cnt_df) && !is.null(cnt_df$cnt) && !is.na(cnt_df$cnt)) {
      return(cnt_df$cnt == length(unique(int_years)))
    }
    return(FALSE)
  }

  TRUE
}

stats19_schema_collision = list(
  list(name = "collision_index", type = "VARCHAR", candidates = c("collision_index", "accident_index")),
  list(name = "collision_year", type = "INT", candidates = c("collision_year", "accident_year")),
  list(name = "collision_reference", type = "VARCHAR", candidates = c("collision_ref_no", "collision_reference", "accident_reference")),
  list(name = "collision_severity", type = "TINYINT", candidates = c("collision_severity", "accident_severity")),
  list(name = "number_of_vehicles", type = "SMALLINT", candidates = c("number_of_vehicles")),
  list(name = "number_of_casualties", type = "SMALLINT", candidates = c("number_of_casualties")),
  list(name = "date", type = "DATE", candidates = c("date", "collision_date", "accident_date"), special = "date"),
  list(name = "day_of_week", type = "TINYINT", candidates = c("day_of_week")),
  list(name = "time", type = "VARCHAR", candidates = c("time", "collision_time", "accident_time")),
  list(name = "local_authority_district", type = "SMALLINT", candidates = c("local_authority_district")),
  list(name = "local_authority_ons_district", type = "VARCHAR", candidates = c("local_authority_ons_district")),
  list(name = "local_authority_highway", type = "VARCHAR", candidates = c("local_authority_highway")),
  list(name = "local_authority_highway_current", type = "VARCHAR", candidates = c("local_authority_highway_current")),
  list(name = "first_road_class", type = "TINYINT", candidates = c("first_road_class", "1st_road_class")),
  list(name = "first_road_number", type = "INT", candidates = c("first_road_number", "1st_road_number")),
  list(name = "road_type", type = "TINYINT", candidates = c("road_type")),
  list(name = "speed_limit", type = "SMALLINT", candidates = c("speed_limit")),
  list(name = "junction_detail", type = "TINYINT", candidates = c("junction_detail")),
  list(name = "junction_detail_historic", type = "TINYINT", candidates = c("junction_detail_historic")),
  list(name = "junction_control", type = "TINYINT", candidates = c("junction_control")),
  list(name = "second_road_class", type = "TINYINT", candidates = c("second_road_class", "2nd_road_class")),
  list(name = "second_road_number", type = "INT", candidates = c("second_road_number", "2nd_road_number")),
  list(name = "pedestrian_crossing", type = "TINYINT", candidates = c("pedestrian_crossing")),
  list(name = "pedestrian_crossing_human_control", type = "TINYINT", candidates = c("pedestrian_crossing_human_control", "pedestrian_crossing_human_control_historic")),
  list(name = "pedestrian_crossing_physical_facilities", type = "TINYINT", candidates = c("pedestrian_crossing_physical_facilities", "pedestrian_crossing_physical_facilities_historic")),
  list(name = "light_conditions", type = "TINYINT", candidates = c("light_conditions")),
  list(name = "weather_conditions", type = "TINYINT", candidates = c("weather_conditions")),
  list(name = "road_surface_conditions", type = "TINYINT", candidates = c("road_surface_conditions")),
  list(name = "special_conditions_at_site", type = "TINYINT", candidates = c("special_conditions_at_site")),
  list(name = "carriageway_hazards", type = "TINYINT", candidates = c("carriageway_hazards")),
  list(name = "carriageway_hazards_historic", type = "TINYINT", candidates = c("carriageway_hazards_historic")),
  list(name = "urban_or_rural_area", type = "TINYINT", candidates = c("urban_or_rural_area")),
  list(name = "did_police_officer_attend", type = "TINYINT", candidates = c("did_police_officer_attend_scene_of_accident", "did_police_officer_attend")),
  list(name = "trunk_road_flag", type = "TINYINT", candidates = c("trunk_road_flag")),
  list(name = "lsoa_of_accident_location", type = "VARCHAR", candidates = c("lsoa_of_accident_location")),
  list(name = "longitude", type = "DOUBLE", candidates = c("longitude")),
  list(name = "latitude", type = "DOUBLE", candidates = c("latitude")),
  list(name = "location_easting_osgr", type = "DOUBLE", candidates = c("location_easting_osgr")),
  list(name = "location_northing_osgr", type = "DOUBLE", candidates = c("location_northing_osgr")),
  list(name = "police_force", type = "SMALLINT", candidates = c("police_force")),
  list(name = "enhanced_severity_collision", type = "TINYINT", candidates = c("enhanced_severity_collision")),
  list(name = "collision_injury_based", type = "TINYINT", candidates = c("collision_injury_based")),
  list(name = "collision_adjusted_severity_serious", type = "DOUBLE", candidates = c("collision_adjusted_severity_serious")),
  list(name = "collision_adjusted_severity_slight", type = "DOUBLE", candidates = c("collision_adjusted_severity_slight"))
)

stats19_schema_casualty = list(
  list(name = "collision_index", type = "VARCHAR", candidates = c("collision_index", "accident_index")),
  list(name = "collision_year", type = "INT", candidates = c("collision_year", "accident_year")),
  list(name = "collision_reference", type = "VARCHAR", candidates = c("collision_ref_no", "collision_reference", "accident_reference")),
  list(name = "vehicle_reference", type = "INT", candidates = c("vehicle_reference")),
  list(name = "casualty_reference", type = "INT", candidates = c("casualty_reference")),
  list(name = "casualty_class", type = "TINYINT", candidates = c("casualty_class")),
  list(name = "sex_of_casualty", type = "TINYINT", candidates = c("sex_of_casualty")),
  list(name = "age_of_casualty", type = "SMALLINT", candidates = c("age_of_casualty")),
  list(name = "age_band_of_casualty", type = "TINYINT", candidates = c("age_band_of_casualty")),
  list(name = "casualty_severity", type = "TINYINT", candidates = c("casualty_severity")),
  list(name = "pedestrian_location", type = "TINYINT", candidates = c("pedestrian_location")),
  list(name = "pedestrian_movement", type = "TINYINT", candidates = c("pedestrian_movement")),
  list(name = "car_passenger", type = "TINYINT", candidates = c("car_passenger")),
  list(name = "bus_or_coach_passenger", type = "TINYINT", candidates = c("bus_or_coach_passenger")),
  list(name = "pedestrian_road_maintenance_worker", type = "TINYINT", candidates = c("pedestrian_road_maintenance_worker")),
  list(name = "casualty_type", type = "SMALLINT", candidates = c("casualty_type")),
  list(name = "casualty_home_area_type", type = "TINYINT", candidates = c("casualty_home_area_type")),
  list(name = "casualty_imd_decile", type = "TINYINT", candidates = c("casualty_imd_decile")),
  list(name = "lsoa_of_casualty", type = "VARCHAR", candidates = c("lsoa_of_casualty")),
  list(name = "enhanced_casualty_severity", type = "TINYINT", candidates = c("enhanced_casualty_severity")),
  list(name = "casualty_injury_based", type = "TINYINT", candidates = c("casualty_injury_based")),
  list(name = "casualty_adjusted_severity_serious", type = "DOUBLE", candidates = c("casualty_adjusted_severity_serious")),
  list(name = "casualty_adjusted_severity_slight", type = "DOUBLE", candidates = c("casualty_adjusted_severity_slight")),
  list(name = "casualty_distance_banding", type = "TINYINT", candidates = c("casualty_distance_banding"))
)

stats19_schema_vehicle = list(
  list(name = "collision_index", type = "VARCHAR", candidates = c("collision_index", "accident_index")),
  list(name = "collision_year", type = "INT", candidates = c("collision_year", "accident_year")),
  list(name = "collision_reference", type = "VARCHAR", candidates = c("collision_ref_no", "collision_reference", "accident_reference")),
  list(name = "vehicle_reference", type = "INT", candidates = c("vehicle_reference")),
  list(name = "vehicle_type", type = "SMALLINT", candidates = c("vehicle_type")),
  list(name = "towing_and_articulation", type = "TINYINT", candidates = c("towing_and_articulation")),
  list(name = "vehicle_manoeuvre", type = "TINYINT", candidates = c("vehicle_manoeuvre")),
  list(name = "vehicle_manoeuvre_historic", type = "TINYINT", candidates = c("vehicle_manoeuvre_historic")),
  list(name = "vehicle_direction_from", type = "TINYINT", candidates = c("vehicle_direction_from")),
  list(name = "vehicle_direction_to", type = "TINYINT", candidates = c("vehicle_direction_to")),
  list(name = "vehicle_location_restricted_lane", type = "TINYINT", candidates = c("vehicle_location_restricted_lane")),
  list(name = "vehicle_location_restricted_lane_historic", type = "TINYINT", candidates = c("vehicle_location_restricted_lane_historic")),
  list(name = "junction_location", type = "TINYINT", candidates = c("junction_location")),
  list(name = "skidding_and_overturning", type = "TINYINT", candidates = c("skidding_and_overturning")),
  list(name = "hit_object_in_carriageway", type = "TINYINT", candidates = c("hit_object_in_carriageway")),
  list(name = "vehicle_leaving_carriageway", type = "TINYINT", candidates = c("vehicle_leaving_carriageway")),
  list(name = "hit_object_off_carriageway", type = "TINYINT", candidates = c("hit_object_off_carriageway")),
  list(name = "first_point_of_impact", type = "TINYINT", candidates = c("first_point_of_impact")),
  list(name = "vehicle_left_hand_drive", type = "TINYINT", candidates = c("vehicle_left_hand_drive")),
  list(name = "journey_purpose_of_driver", type = "TINYINT", candidates = c("journey_purpose_of_driver")),
  list(name = "journey_purpose_of_driver_historic", type = "TINYINT", candidates = c("journey_purpose_of_driver_historic")),
  list(name = "sex_of_driver", type = "TINYINT", candidates = c("sex_of_driver")),
  list(name = "age_of_driver", type = "SMALLINT", candidates = c("age_of_driver")),
  list(name = "age_band_of_driver", type = "TINYINT", candidates = c("age_band_of_driver")),
  list(name = "engine_capacity_cc", type = "INT", candidates = c("engine_capacity_cc")),
  list(name = "propulsion_code", type = "TINYINT", candidates = c("propulsion_code")),
  list(name = "age_of_vehicle", type = "SMALLINT", candidates = c("age_of_vehicle")),
  list(name = "generic_make_model", type = "VARCHAR", candidates = c("generic_make_model")),
  list(name = "driver_imd_decile", type = "TINYINT", candidates = c("driver_imd_decile")),
  list(name = "driver_home_area_type", type = "TINYINT", candidates = c("driver_home_area_type")),
  list(name = "lsoa_of_driver", type = "VARCHAR", candidates = c("lsoa_of_driver")),
  list(name = "escooter_flag", type = "TINYINT", candidates = c("escooter_flag")),
  list(name = "driver_distance_banding", type = "TINYINT", candidates = c("driver_distance_banding"))
)

