#' Convert raw STATS19 CSV files to Parquet
#'
#' @description
#' Reads raw STATS19 CSV files from the data directory and converts them into
#' highly compressed, typed, columnar Parquet files using DuckDB.
#' Columns are parsed exactly as `read_stats19()` parses the CSV files, so
#' every engine returns the same data after `format_stats19()`. Caches written
#' by other stats19 versions are ignored until rebuilt.
#'
#' @param type Type of data to convert: `"collision"` (or `"accident"`),
#'   `"casualty"`, `"vehicle"`, or `"all"`.
#' @param years Optional vector of years to convert. If `NULL` (default), all
#'   available files for the requested type in `data_dir` are converted. Years
#'   are matched as a token in the DfT filename, so `years = 2024` matches both
#'   `...-collision-2024.csv` and `...-collision-2024-corrected.csv`.
#' @param data_dir Directory containing raw downloaded CSV files.
#'   Defaults to `get_data_directory()`.
#' @param output_dir Directory where the Parquet file(s) will be written.
#'   Defaults to `get_parquet_directory()`.
#' @param filename Optional output filename. If `NULL` (default), the file is
#'   named `{type}s.parquet` (e.g. `collisions.parquet`).
#' @param partition_by Optional column name(s) to partition by, e.g. `"collision_year"`.
#'   If supplied, a Hive-partitioned directory will be written. Names are checked
#'   against the columns of the converted output, so a typo fails early rather
#'   than producing an unpartitioned or broken file.
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
    # Match each year as a filename token so that suffixed DfT releases
    # (...-2024-corrected.csv) are converted too, without matching a year that
    # only appears as part of another number.
    year_pats = paste0("(^|[-_])", years, "([-_.]|$)")
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

    # 2. Avoid duplicate records between the long-run file and individual
    # years. Prefer 1979-latest, which is cumulative and is what
    # find_file_name() reads, over older releases such as 1979-2021.
    longrun = type_csvs[grepl("1979-", basename(type_csvs))]
    if (length(longrun) > 0) {
      longrun = longrun[order(!grepl("1979-latest", basename(longrun)))][1]
      end_year = suppressWarnings(as.integer(sub(".*1979-(\\d{4}).*", "\\1", basename(longrun))))
      annual_files = type_csvs[!grepl("1979-", basename(type_csvs))]
      years_in_annual = as.integer(gsub(".*?-(19|20)(\\d{2})\\.csv$", "\\1\\2", basename(annual_files)))
      keep_annual = annual_files[!is.na(end_year) & !is.na(years_in_annual) & years_in_annual > end_year]
      type_csvs = c(longrun, keep_annual)
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

  # Same SQL as read_stats19(engine = "duckdb") uses on the CSV files, so the
  # cache holds exactly what the CSV engines read and format_stats19() does
  # the rest for every engine.
  sql_select = stats19_csv_sql(con, type_csvs)

  # Build COPY statement
  if (!is.null(partition_by)) {
    if (!is.character(partition_by)) {
      stop("partition_by must be a character vector of column names.", call. = FALSE)
    }
    valid_partition_cols = DBI::dbGetQuery(con, paste("DESCRIBE", sql_select))$column_name
    unknown = setdiff(partition_by, valid_partition_cols)
    if (length(unknown) > 0) {
      stop("Unknown partition_by column(s): ", paste(unknown, collapse = ", "),
           ". Use a column of the converted output, for example 'collision_year'.",
           call. = FALSE)
    }
    part_cols = paste(partition_by, collapse = ", ")
    partition_sql = glue::glue(", PARTITION_BY ({part_cols})")
  } else {
    partition_sql = ""
  }

  escaped_out = gsub("'", "''", out_path)
  copy_sql = glue::glue("
    COPY ({sql_select})
    TO '{escaped_out}'
    (FORMAT PARQUET, COMPRESSION {toupper(compression)}, ROW_GROUP_SIZE 100000,
     KV_METADATA {{stats19_format: '{stats19_parquet_format}'}}{partition_sql});
  ")

  DBI::dbExecute(con, copy_sql)

  # Verify what was written rather than trusting COPY: a silently truncated
  # cache is worse than a failed conversion, because later reads trust it.
  written_glob = if (is.null(partition_by)) out_path else file.path(out_path, "**", "*.parquet")
  escaped_glob = gsub("'", "''", written_glob)
  rows_out = tryCatch(
    DBI::dbGetQuery(con, glue::glue("SELECT count(*) AS n FROM read_parquet('{escaped_glob}')"))$n,
    error = function(e) NA_real_
  )
  rows_in = tryCatch(
    DBI::dbGetQuery(con, glue::glue("SELECT count(*) AS n FROM ({sql_select})"))$n,
    error = function(e) NA_real_
  )
  if (!is.na(rows_in) && !is.na(rows_out) && rows_in != rows_out) {
    warning("Row count mismatch after conversion: ", rows_in,
            " rows read from CSV, ", rows_out, " rows written to ", out_path,
            ".", call. = FALSE)
  }

  if (!silent) {
    message("Saved Parquet file at: ", out_path,
            if (!is.na(rows_out)) paste0(" (", format(rows_out, big.mark = ","), " rows)") else "")
  }

  invisible(out_path)
}

# Written to the Parquet metadata. Bump it when stats19_csv_sql() changes, so
# caches written by other versions are not read and are rebuilt instead.
stats19_parquet_format = "csv-sql-1"

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
  fmt = tryCatch(DBI::dbGetQuery(con, glue::glue(
    "SELECT decode(value) AS v FROM parquet_kv_metadata('{escaped_pq}') WHERE decode(key) = 'stats19_format'"
  ))$v, error = function(e) character(0))
  if (!identical(fmt, stats19_parquet_format)) {
    warning("Ignoring Parquet cache written by another stats19 version: ", parquet_file,
            ". Rebuild it with stats19_to_parquet().", call. = FALSE)
    return(FALSE)
  }

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
