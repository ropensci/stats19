# Shared test fixtures. testthat sources helper*.R before the test files, so
# these are available to every test file and the parquet fixtures stay in one
# place.

# Minimal DfT-shaped CSV fixture. Small enough to keep the suite fast, complete
# enough for the converter's schema mapping (missing columns become NULL).
write_stats19_fixture = function(data_dir, type, year, n = 2) {
  ids = sprintf("%s%02dA", year, seq_len(n))
  df = switch(
    type,
    collision = data.frame(
      collision_index = ids,
      collision_year = year,
      collision_severity = rep(3, n),
      number_of_vehicles = rep(1, n),
      number_of_casualties = rep(1, n),
      date = rep(sprintf("01/01/%d", year), n),
      stringsAsFactors = FALSE
    ),
    casualty = data.frame(
      collision_index = ids,
      collision_year = year,
      vehicle_reference = rep(1, n),
      casualty_reference = seq_len(n),
      casualty_severity = rep(3, n),
      stringsAsFactors = FALSE
    ),
    vehicle = data.frame(
      collision_index = ids,
      collision_year = year,
      vehicle_reference = seq_len(n),
      vehicle_type = rep(9, n),
      stringsAsFactors = FALSE
    )
  )
  name = sprintf("dft-road-casualty-statistics-%s-%d.csv", type, year)
  utils::write.csv(df, file.path(data_dir, name), row.names = FALSE)
  file.path(data_dir, name)
}

# Rows in a Parquet file or Hive-partitioned directory, read back with DuckDB
parquet_row_count = function(path) {
  con = DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)
  glob = if (dir.exists(path)) file.path(path, "**", "*.parquet") else path
  DBI::dbGetQuery(con, sprintf("SELECT count(*) AS n FROM read_parquet('%s')", glob))$n
}

# Build a Parquet cache in a temporary directory and point the package at it.
# `csv_n` controls the row count of the CSV fixture in the download directory,
# so tests can tell a cache read from a CSV fallback by row count alone.
# Cleanup is registered on the caller's frame, otherwise the directories and
# environment variables are torn down as soon as this helper returns.
local_parquet_fixture = function(type = "collision", year = 2024, cache_n = 2,
                                csv_n = NULL, cache_year = year) {
  env = parent.frame()
  source_dir = withr::local_tempdir(.local_envir = env)
  parquet_dir = withr::local_tempdir(.local_envir = env)
  data_dir = withr::local_tempdir(.local_envir = env)
  withr::local_envvar(c(STATS19_PARQUET_DIRECTORY = parquet_dir,
                        STATS19_DOWNLOAD_DIRECTORY = data_dir), .local_envir = env)
  write_stats19_fixture(source_dir, type, cache_year, n = cache_n)
  stats19_to_parquet(type = type, data_dir = source_dir,
                     output_dir = parquet_dir, silent = TRUE)
  if (!is.null(csv_n)) {
    write_stats19_fixture(data_dir, type, year, n = csv_n)
  }
  list(parquet_dir = parquet_dir, data_dir = data_dir,
       parquet_file = file.path(parquet_dir, paste0(type, "s.parquet")))
}
