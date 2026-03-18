#' Read in STATS19 road safety data from .csv files downloaded.
#'
#' @section Details:
#' This is a wrapper function to access and load stats 19 data in a user-friendly way.
#' The function returns a data frame, in which each record is a reported incident in the
#' STATS19 data.
#'
#' @param filename Character string of the filename of the .csv to read, if this is given, type and
#' years determine whether there is a target to read, otherwise disk scan would be needed.
#' @param data_dir Where sets of downloaded data would be found.
#' @param year Single year for which data are to be read
#' @param format Switch to return raw read from file, default is `TRUE`.
#' @param silent Boolean. If `FALSE` (default value), display useful progress
#'   messages on the screen.
#'
#' @export
#' @examples
#' \donttest{
#' if(curl::has_internet()) {
#' dl_stats19(year = 2024, type = "collision")
#' ac = read_collisions(year = 2024)
#' }
#' }
read_collisions = function(year = NULL,
                          filename = "",
                          data_dir = get_data_directory(),
                          format = TRUE,
                          silent = FALSE) {
  read_stats19(year = year, filename = filename, data_dir = data_dir, 
               format = format, silent = silent, type = "collision")
}

#' Read in stats19 road safety data from .csv files downloaded.
#'
#' @inheritParams read_collisions
#' @export
read_vehicles = function(year = NULL,
                         filename = "",
                         data_dir = get_data_directory(),
                         format = TRUE) {
  read_stats19(year = year, filename = filename, data_dir = data_dir, 
               format = format, type = "vehicle")
}

#' Read in STATS19 road safety data from .csv files downloaded.
#'
#' @inheritParams read_collisions
#' @export
read_casualties = function(year = NULL,
                           filename = "",
                           data_dir = get_data_directory(),
                           format = TRUE) {
  read_stats19(year = year, filename = filename, data_dir = data_dir, 
               format = format, type = "cas")
}

# Internal helper to make numeric DuckDB predicates work with all_varchar=TRUE
sanitize_duckdb_where = function(where) {
  if (is.null(where) || !nzchar(where)) {
    return(where)
  }
  
  wrap_try_cast = function(sql, column) {
    already_cast = grepl(
      paste0("TRY_CAST\\s*\\(\\s*", column, "\\s+AS\\s+DOUBLE\\s*\\)"),
      sql,
      ignore.case = TRUE,
      perl = TRUE
    )
    if (already_cast) {
      return(sql)
    }
    
    gsub(
      pattern = paste0("\\b", column, "\\b"),
      replacement = paste0("TRY_CAST(", column, " AS DOUBLE)"),
      x = sql,
      ignore.case = TRUE,
      perl = TRUE
    )
  }
  
  where = wrap_try_cast(where, "location_easting_osgr")
  where = wrap_try_cast(where, "location_northing_osgr")
  where
}

# Internal helper to normalize legacy collision reference fields early.
normalize_collision_reference = function(x) {
  reference_aliases = c("collision_ref_no", "accident_reference", "accident_ref_no")
  
  if (!"collision_reference" %in% names(x)) {
    src = reference_aliases[reference_aliases %in% names(x)]
    if (length(src) > 0) {
      names(x)[names(x) == src[[1]]] = "collision_reference"
    }
    return(x)
  }
  
  for (old_name in reference_aliases) {
    if (old_name %in% names(x)) {
      missing_idx = is.na(x$collision_reference) | x$collision_reference == ""
      x$collision_reference[missing_idx] = x[[old_name]][missing_idx]
      x[[old_name]] = NULL
    }
  }
  x
}

# Internal helper to handle all stats19 reading
read_stats19 = function(year = NULL,
                        filename = "",
                        data_dir = get_data_directory(),
                        format = TRUE,
                        silent = TRUE,
                        type = "collision",
                        engine = "readr",
                        where = NULL) {
  fnames = filename
  if (filename == "" || is.null(filename)) {
    fnames = find_file_name(years = year, type = type)
  }
  
  if (length(fnames) == 0) {
    message("No files found.")
    return(NULL)
  }

  paths = file.path(data_dir, fnames)
  existing_paths = paths[file.exists(paths)]
  
  if (length(existing_paths) == 0) {
    message("Files not found on disk.")
    return(NULL)
  }

  if (engine == "duckdb") {
    if (!requireNamespace("duckdb", quietly = TRUE) || !requireNamespace("DBI", quietly = TRUE)) {
      warning("duckdb and DBI packages are required for engine = 'duckdb'. Falling back to readr.")
      engine = "readr"
    }
  }

  if (engine == "duckdb") {
    con = DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
    on.exit(DBI::dbDisconnect(con, shutdown = TRUE))
    
    # Create views for each file and union them
    view_names = paste0("v", seq_along(existing_paths))
    for (i in seq_along(existing_paths)) {
      p = existing_paths[i]
      v = view_names[i]
      
      # Using read_csv_auto which is very fast and handles many edge cases
      # We read as VARCHAR initially to be safe with STATS19's weird types and -1 for NA
      # We use SELECT * to ensure we get all columns (indices, coordinates, etc.)
      query = glue::glue("CREATE VIEW {v} AS SELECT * FROM read_csv_auto('{p}', all_varchar=TRUE)")
      DBI::dbExecute(con, query)
    }
    
    union_query = paste0("SELECT * FROM ", paste(view_names, collapse = " UNION ALL BY NAME SELECT * FROM "))
    
    # Build WHERE clauses
    where_clauses = character(0)
    
    # 1. Filter by year in SQL if requested
    if (!is.null(year) && !identical(year, 5) && !identical(year, "5 years") && !identical(year, 1979) && !identical(year, 1979L)) {
      # Get all columns from all views to find all potential year columns
      all_cols = unique(unlist(lapply(view_names, function(v) DBI::dbListFields(con, v))))
      year_cols = intersect(all_cols, c("accident_year", "collision_year", "Accident_Year", "Collision_Year"))
      if (length(year_cols) > 0) {
        year_str = paste0("'", year, "'", collapse = ", ")
        # Build OR condition for all found year columns
        year_cond = paste0("(", paste0(year_cols, " IN (", year_str, ")", collapse = " OR "), ")")
        where_clauses = c(where_clauses, year_cond)
      }
    }
    
    # 2. Add arbitrary WHERE clause (e.g. spatial bounding box)
    if (!is.null(where)) {
      where = sanitize_duckdb_where(where)
      where_clauses = c(where_clauses, where)
    }
    
    if (length(where_clauses) > 0) {
      union_query = paste0("SELECT * FROM (", union_query, ") WHERE ", paste(where_clauses, collapse = " AND "))
    }
    
    x = DBI::dbGetQuery(con, union_query)
    x = tibble::as_tibble(x)
  } else {
    if (any(grepl("1979-latest", existing_paths))) {
      warning("Reading the large 1979-latest file with 'readr' can be slow. Consider using engine = 'duckdb' for better performance.", call. = FALSE)
    }
    read_one = function(p) {
      if (isFALSE(silent)) message("Reading in: ", p)
      readr::read_csv(p, col_types = col_spec(p), na = c("", "NA", "-1"), show_col_types = FALSE)
    }
    
    # Read and bind
    x_list = lapply(existing_paths, read_one)
    x = dplyr::bind_rows(x_list)
  }
  
  x = normalize_collision_reference(x)
  
  if(format) {
    format_fun = switch(tolower(substr(type, 1, 3)),
                        "col" = format_collisions,
                        "veh" = format_vehicles,
                        "cas" = format_casualties)
    x = format_fun(x)
  }
  
  # Ensure -1 is NA across all columns (safety net for Option 1)
  # Done AFTER formatting to allow schema to map -1 to labels first if needed
  x[] = lapply(x, function(col) {
    if(is.character(col)) {
      col[col == "-1"] = NA_character_
    } else if(is.numeric(col)) {
      col[col == -1] = NA
    }
    col
  })
  x = tibble::as_tibble(x)
  
  # Filter by year if requested
  # Note: we don't filter if year is 1979 to maintain compatibility with full history fetching
  if (!is.null(year) && !identical(year, 5) && !identical(year, "5 years") && !identical(year, 1979) && !identical(year, 1979L)) {
    year_col = intersect(names(x), c("accident_year", "collision_year"))
    if (length(year_col) > 0) {
      x = x[x[[year_col[1]]] %in% year, ]
    }
  }
  
  x
}

#' Local helper to be reused.
#' @param filename Character string of the filename of the .csv to read.
#' @param type One of 'collision', 'casualty', 'Vehicle'.
#' @param data_dir Where sets of downloaded data would be found.
#' @param year Single year for which data are to be read.
check_input_file = function(filename = NULL,
                            type = NULL,
                            data_dir = NULL,
                            year = NULL) {
  path = locate_one_file(
    type = type,
    filename = filename,
    data_dir = data_dir,
    year = year
  )
  if(identical(path, "More than one csv file found."))
    stop("Multiple files with the same name found.", call. = FALSE)
  
  if (is.null(path) || length(path) == 0 || !endsWith(path, ".csv") || !file.exists(path)) {
    message(path, " not found")
    message("Try running dl_stats19(), change arguments or try later.")
    return(NULL)
  }
  return(path)
}

# possibly in utils
# Convert the 'type' column to readr's col_type format
convert_to_col_type = function(type) {
  switch(type,
         character = readr::col_character(),
         numeric = readr::col_double(),
         integer = readr::col_integer(),
         logical = readr::col_logical(),
         date = readr::col_date(),
         datetime = readr::col_datetime(),
         readr::col_guess())
}

col_spec = function(path = NULL) {
  if (is.null(path)) {
    # Fallback to all known variables if no path
    unique_vars = unique(stats19::stats19_variables$variable)
    unique_types = sapply(unique_vars, function(v) {
      type = stats19::stats19_variables$type[stats19::stats19_variables$variable == v][1]
      convert_to_col_type(type)
    })
    return(do.call(readr::cols, stats::setNames(unique_types, unique_vars)))
  }

  # Read only the header to get column names and ORDER
  header = names(readr::read_csv(path, n_max = 0, show_col_types = FALSE))
  header_clean = format_column_names(header)
  
  # Map cleaned header names to their types from the schema
  col_types_list = lapply(header_clean, function(v) {
    type_info = stats19::stats19_variables$type[stats19::stats19_variables$variable == v]
    if (length(type_info) > 0) {
      convert_to_col_type(type_info[1])
    } else {
      readr::col_guess()
    }
  })
  
  # Create the cols object with the correct NAMES and ORDER matching the file
  do.call(readr::cols, stats::setNames(col_types_list, header))
}
