#' Download, read and format STATS19 data in one function.
#'
#' @section Details:
#' This function gets STATS19 data. Behind the scenes it uses
#' `dl_stats19()` and `read_*` functions, returning a
#' `tibble` (default), `data.frame`, `sf` or `ppp` object, depending on the
#' `output_format` parameter.
#'
#' By default, stats19 downloads files to a temporary directory.
#' You can change this behavior to save the files in a permanent directory.
#' This is done by setting the `STATS19_DOWNLOAD_DIRECTORY` environment variable.
#' A convenient way to do this is by adding `STATS19_DOWNLOAD_DIRECTORY=/path/to/a/dir`
#' to your `.Renviron` file, which can be opened with `usethis::edit_r_environ()`.
#'
#' The function returns data for a specific year (e.g. `year = 2022`)
#'
#' Note: for years before 2016 the function may return data from more years than are
#' requested due to the nature of the files hosted at
#' [data.gov.uk](https://www.data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-accidents-safety-data).
#'
#' As this function uses `dl_stats19` function, it can download many MB of data,
#' so ensure you have a sufficient disk space.
#'
#' If `output_format = "data.frame"` or `output_format = "sf"` or `output_format
#' = "ppp"` then the output data is transformed into a data.frame, sf or ppp
#' object using the [as.data.frame()] or [format_sf()] or [format_ppp()]
#' functions, as shown in the examples.
#'
#' @seealso [dl_stats19()]
#' @seealso [read_collisions()]
#'
#' @inheritParams dl_stats19
#' @param file_name Character string of a specific STATS19 CSV filename to
#'   download/read. If `NULL`, filenames are inferred from `year` and `type`.
#' @param format Switch to return raw read from file, default is `TRUE`.
#' @param output_format A string that specifies the desired output format. The
#'   default value is `"tibble"`. Other possible values are `"data.frame"`, `"sf"`,
#'   `"ppp"`, and `"duckdb"` (which returns a lazy `tbl` connection to DuckDB via `dbplyr`).
#'   Any other string is ignored and a tibble output is returned. See details and examples.
#'   With `"duckdb"` stats19 leaves the connection open for further queries, so
#'   close it yourself when finished with
#'   `DBI::dbDisconnect(dbplyr::remote_con(x), shutdown = TRUE)`.
#' @param engine CSV/Parquet reader backend. Defaults to `"readr"`. Set to `"duckdb"` to
#'   query files via DuckDB before loading into R, or `"parquet"` to query from a
#'   local Parquet cache (`STATS19_PARQUET_DIRECTORY`, see [stats19_to_parquet()]).
#'   The cache is used only when it covers the requested years and is never rebuilt
#'   automatically; when it covers the request it also replaces the download, so no
#'   files are fetched. Otherwise the CSV files are downloaded and read.
#' @param where Optional SQL predicate appended to the `WHERE` clause when
#'   `engine = "duckdb"` or `engine = "parquet"`, e.g. `"longitude > -1.9 AND longitude < -1.2"`.
#'   For OSGR coordinate predicates on `location_easting_osgr` and
#'   `location_northing_osgr`, values are safely `TRY_CAST` to `DOUBLE` to avoid
#'   type issues when source CSV columns are loaded as text.
#'   Ignored when `engine = "readr"`.
#' @param ... Other arguments be passed to [format_sf()] or
#'   [format_ppp()] functions. Read and run the examples.
#'
#' @export
#' @examples
#' \donttest{
#' if(curl::has_internet()) {
#' col = get_stats19(year = 2022, type = "collision")
#' cas = get_stats19(year = 2022, type = "casualty")
#' veh = get_stats19(year = 2022, type = "vehicle")
#' class(col)
#' # data.frame output
#' x = get_stats19(2022, silent = TRUE, output_format = "data.frame")
#' class(x)
#' 
#' # # Get 5-years worth of data (commented-out due to large response size):
#' # col_5 = get_stats19(year = 5, type = "collision")
#' # cas_5 = get_stats19(year = 5, type = "casualty")
#' # veh_5 = get_stats19(year = 5, type = "vehicle")
#' 
#'
#' # Run tests only if endpoint is alive:
#' if(nrow(x) > 0) {
#'
#' # use duckdb engine
#' col_duck = get_stats19(year = 2022, type = "collision", engine = "duckdb")
#'
#' # use duckdb with where clause
#' col_where = get_stats19(year = 2022, type = "collision", engine = "duckdb",
#'                        where = "speed_limit = 30")
#'
#' # sf output
#' x_sf = get_stats19(2022, silent = TRUE, output_format = "sf")
#'
#' # sf output with lonlat coordinates
#' x_sf = get_stats19(2022, silent = TRUE, output_format = "sf", lonlat = TRUE)
#' sf::st_crs(x_sf)
#'
#' if (requireNamespace("spatstat.geom", quietly = TRUE)) {
#' # ppp output
#' x_ppp = get_stats19(2022, silent = TRUE, output_format = "ppp")
#'
#' # We can use the window parameter of format_ppp function to filter only the
#' # events occurred in a specific area. For example we can create a new bbox
#' # of 5km around the city center of Leeds
#'
#' leeds_window = spatstat.geom::owin(
#' xrange = c(425046.1, 435046.1),
#' yrange = c(428577.2, 438577.2)
#' )
#'
#' leeds_ppp = get_stats19(2022, silent = TRUE, output_format = "ppp", window = leeds_window)
#' spatstat.geom::plot.ppp(leeds_ppp, use.marks = FALSE, clipwin = leeds_window)
#' }
#' }
#' }
#' }
get_stats19 = function(year = NULL,
                      type = "collision",
                      data_dir = get_data_directory(),
                      file_name = NULL,
                      format = TRUE,
                      ask = FALSE,
                      silent = FALSE,
                      output_format = "tibble",
                      engine = "readr",
                      where = NULL,
                      ...) {
  # Set type to "collision" if it's "accident" or similar:
  if (grepl("acc", x = type, ignore.case = TRUE)) {
    type = "collision"
  }
  
  valid_formats = c("tibble", "data.frame", "sf", "ppp", "duckdb")
  if (!output_format %in% valid_formats) {
    warning("output_format should be one of ", paste(valid_formats, collapse = ", "), 
            ". Defaulting to tibble.", call. = FALSE, immediate. = TRUE)
    output_format = "tibble"
  }
  
  if (output_format == "duckdb") {
    engine = "duckdb"
  }

  if (grepl("cas", type, ignore.case = TRUE) && output_format %in% c("sf", "ppp")) {
    warning("Casualties do not have a spatial dimension. Defaulting to tibble.",
            call. = FALSE, immediate. = TRUE)
    output_format = "tibble"
  }
  # Check if we can satisfy from local Parquet
  plural_name = if (grepl("acc|col", type, ignore.case = TRUE)) {
    "collisions"
  } else if (grepl("cas", type, ignore.case = TRUE)) {
    "casualties"
  } else {
    "vehicles"
  }
  parquet_dir = get_parquet_directory()
  parquet_file = file.path(parquet_dir, paste0(plural_name, ".parquet"))
  has_specific_csv = !is.null(file_name) && nzchar(file_name) &&
    grepl("\\.csv$", file_name, ignore.case = TRUE)
  parquet_ok = file.exists(parquet_file) && parquet_has_years(parquet_file, year)
  # read_stats19() serves from the cache whenever it covers the requested years
  # and no CSV was named, so skip the download on exactly that condition. This
  # includes engine = "duckdb", which previously downloaded files it never read.
  # engine = "readr" still needs the CSV, so it is deliberately excluded.
  skip_dl = parquet_ok && !has_specific_csv &&
    (engine %in% c("parquet", "duckdb") || output_format == "duckdb")

  # download what the user wanted if not already satisfied by Parquet
  if (!skip_dl) {
    dl_stats19(year = year, type = type, data_dir = data_dir, 
               file_name = file_name, ask = ask, silent = silent)
  }
  
  # read in
  read_in = read_stats19(year = year, filename = file_name %||% "", 
                         data_dir = data_dir, format = format, 
                         silent = silent, type = type, engine = engine,
                         where = where, output_format = output_format)

  # A lazy DuckDB table is returned as-is: stats19 hands the connection to the
  # caller, who closes it with DBI::dbDisconnect(dbplyr::remote_con(x)). If
  # duckdb or dbplyr were unavailable, read_stats19() fell back to a tibble, in
  # which case fall through to the post-processing below instead of claiming a
  # lazy table was returned.
  if (output_format == "duckdb") {
    if (inherits(read_in, "tbl_lazy")) {
      return(read_in)
    }
    output_format = "tibble"
  }

  # Smart Unification for E-scooter Casualties
  # If type is casualty, we check vehicles to find e-scooter riders
  if (grepl("cas", type, ignore.case = TRUE) && !is.null(read_in) && format) {
    ve_escooter = tryCatch({
      ve_temp = read_stats19(year = year, filename = "", data_dir = data_dir, 
                             format = TRUE, silent = TRUE, type = "vehicle",
                             engine = engine, where = where)
      if (!is.null(ve_temp) && "escooter_flag" %in% names(ve_temp)) {
        ve_temp[ve_temp$escooter_flag == "Vehicle was an e-scooter", 
                c("collision_index", "vehicle_reference")]
      } else {
        NULL
      }
    }, error = function(e) NULL)
    
    if (!is.null(ve_escooter) && nrow(ve_escooter) > 0) {
      # Identify casualties associated with e-scooter vehicles
      is_escooter_rider = paste(read_in$collision_index, read_in$vehicle_reference) %in% 
                          paste(ve_escooter$collision_index, ve_escooter$vehicle_reference)
      # If they are linked to an e-scooter and their type is NA, they are the rider
      read_in$casualty_type[is_escooter_rider & is.na(read_in$casualty_type)] = "E-scooter rider"
    }
  }

  # transform read_in into the desired format
  if (output_format != "tibble" && !is.null(read_in)) {
    read_in = switch(
      output_format,
      "data.frame" = as.data.frame(read_in, ...),
      "sf" = format_sf(read_in, ...),
      "ppp" = format_ppp(read_in, ...)
    )
  }


  read_in
}
