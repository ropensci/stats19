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

test_that("get_parquet_directory and set_parquet_directory work", {
  withr::local_envvar(STATS19_PARQUET_DIRECTORY = NA)

  tmp_d = tempfile()
  set_parquet_directory(tmp_d)
  expect_equal(get_parquet_directory(), tmp_d)
  expect_true(dir.exists(tmp_d))
})

test_that("stats19_to_parquet converts CSVs to Parquet using DuckDB", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  tmp_data = file.path(tempdir(), "test_stats19_csv")
  tmp_out = file.path(tempdir(), "test_stats19_parquet")
  dir.create(tmp_data, recursive = TRUE, showWarnings = FALSE)
  dir.create(tmp_out, recursive = TRUE, showWarnings = FALSE)

  # Create sample collision CSV
  sample_df = data.frame(
    collision_index = c("202401A", "202402B"),
    collision_year = c(2024, 2024),
    collision_severity = c(1, 3),
    number_of_vehicles = c(2, 1),
    number_of_casualties = c(1, 0),
    date = c("15/06/2024", "20/07/2024"),
    stringsAsFactors = FALSE
  )
  test_csv = file.path(tmp_data, "dft-road-casualty-statistics-collision-2024.csv")
  utils::write.csv(sample_df, test_csv, row.names = FALSE)

  p_path = stats19_to_parquet(
    type = "collision",
    data_dir = tmp_data,
    output_dir = tmp_out,
    silent = TRUE
  )

  expect_true(file.exists(p_path))
  expect_true(grepl("collisions\\.parquet$", p_path))

  # Verify row count via DuckDB
  con = DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)
  res = DBI::dbGetQuery(con, paste0("SELECT count(*) AS n FROM read_parquet('", p_path, "')"))
  expect_equal(res$n[1], 2)
})

test_that("stats19_to_parquet normalises legacy accident_index to collision_index", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  tmp_data = file.path(tempdir(), "test_stats19_legacy_csv")
  tmp_out = file.path(tempdir(), "test_stats19_legacy_parquet")
  dir.create(tmp_data, recursive = TRUE, showWarnings = FALSE)
  dir.create(tmp_out, recursive = TRUE, showWarnings = FALSE)

  # Legacy 2017 schema with accident_index
  sample_legacy = data.frame(
    accident_index = c("201701X", "201702Y"),
    accident_year = c(2017, 2017),
    accident_reference = c("REF1", "REF2"),
    accident_severity = c(2, 3),
    date = c("01/01/2017", "02/01/2017"),
    longitude = c(-0.12, -0.13),
    latitude = c(51.5, 51.51),
    stringsAsFactors = FALSE
  )
  test_csv = file.path(tmp_data, "dft-road-casualty-statistics-accident-2017.csv")
  utils::write.csv(sample_legacy, test_csv, row.names = FALSE)

  p_path = stats19_to_parquet(
    type = "collision",
    data_dir = tmp_data,
    output_dir = tmp_out,
    silent = TRUE
  )

  expect_true(file.exists(p_path))

  con = DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)
  res = DBI::dbGetQuery(con, paste0("SELECT collision_index, collision_year, collision_reference, date, longitude FROM read_parquet('", p_path, "')"))
  expect_equal(nrow(res), 2)
  expect_equal(res$collision_index, c("201701X", "201702Y"))
  expect_equal(res$collision_year, c(2017L, 2017L))
  expect_equal(res$collision_reference, c("REF1", "REF2"))
  expect_equal(as.character(res$date), c("2017-01-01", "2017-01-02"))
})

test_that("stats19_to_parquet converts casualty and vehicle data", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  tmp_data = file.path(tempdir(), "test_stats19_types_csv")
  tmp_out = file.path(tempdir(), "test_stats19_types_parquet")
  dir.create(tmp_data, recursive = TRUE, showWarnings = FALSE)
  dir.create(tmp_out, recursive = TRUE, showWarnings = FALSE)

  cas_df = data.frame(
    collision_index = "202401A",
    collision_year = 2024,
    vehicle_reference = 1,
    casualty_reference = 1,
    casualty_severity = 3,
    stringsAsFactors = FALSE
  )
  veh_df = data.frame(
    collision_index = "202401A",
    collision_year = 2024,
    vehicle_reference = 1,
    vehicle_type = 9,
    stringsAsFactors = FALSE
  )
  utils::write.csv(cas_df, file.path(tmp_data, "dft-road-casualty-statistics-casualty-2024.csv"), row.names = FALSE)
  utils::write.csv(veh_df, file.path(tmp_data, "dft-road-casualty-statistics-vehicle-2024.csv"), row.names = FALSE)

  p_cas = stats19_to_parquet(type = "casualty", data_dir = tmp_data, output_dir = tmp_out, silent = TRUE)
  p_veh = stats19_to_parquet(type = "vehicle", data_dir = tmp_data, output_dir = tmp_out, silent = TRUE)

  expect_true(file.exists(p_cas))
  expect_true(file.exists(p_veh))
})

test_that("stats19_to_parquet rejects unknown partition_by columns", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  data_dir = withr::local_tempdir()
  output_dir = withr::local_tempdir()
  write_stats19_fixture(data_dir, "collision", 2024)

  expect_error(
    stats19_to_parquet(type = "collision", data_dir = data_dir,
                       output_dir = output_dir, partition_by = "not_a_column",
                       silent = TRUE),
    "Unknown partition_by column"
  )

  out = stats19_to_parquet(type = "collision", data_dir = data_dir,
                           output_dir = output_dir, partition_by = "collision_year",
                           silent = TRUE)
  expect_true(dir.exists(out))
  expect_length(list.files(out, pattern = "\\.parquet$", recursive = TRUE), 1)
})

test_that("stats19_to_parquet matches years as filename tokens", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  data_dir = withr::local_tempdir()
  output_dir = withr::local_tempdir()
  f = write_stats19_fixture(data_dir, "collision", 2024)
  # A suffixed release name still counts as 2024
  file.rename(f, file.path(data_dir, "dft-road-casualty-statistics-collision-2024-corrected.csv"))

  out = stats19_to_parquet(type = "collision", years = 2024, data_dir = data_dir,
                           output_dir = output_dir, silent = TRUE)
  expect_true(file.exists(out))
  expect_equal(parquet_row_count(out), 2)

  # 2024 inside a longer number is not a year token
  other_dir = withr::local_tempdir()
  write_stats19_fixture(other_dir, "collision", 20240)
  expect_message(
    stats19_to_parquet(type = "collision", years = 2024, data_dir = other_dir,
                       output_dir = withr::local_tempdir()),
    "No CSV files found matching requested years"
  )
})

test_that("stats19_to_parquet reports columns missing from the source files", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  data_dir = withr::local_tempdir()
  output_dir = withr::local_tempdir()
  write_stats19_fixture(data_dir, "collision", 2024)

  # The fixture has a handful of columns out of the full DfT schema, so the
  # converter should say so rather than leaving the user to find all-NULL
  # columns later.
  expect_message(
    stats19_to_parquet(type = "collision", data_dir = data_dir,
                       output_dir = output_dir),
    "written as all-NULL"
  )
})

test_that("get_stats19 with output_format = 'duckdb' returns a lazy tbl from the Parquet cache", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")
  skip_if_not_installed("dbplyr")

  # Self-contained: build the cache from a 2-row fixture and put a different
  # 5-row CSV in the download directory, so the row count below distinguishes
  # the cache from the CSV fallback. The previous version keyed off whatever
  # happened to be in STATS19_PARQUET_DIRECTORY and skipped silently when it
  # was absent, which it always is on CI.
  source_dir = withr::local_tempdir()
  parquet_dir = withr::local_tempdir()
  data_dir = withr::local_tempdir()
  withr::local_envvar(STATS19_PARQUET_DIRECTORY = parquet_dir,
                      STATS19_DOWNLOAD_DIRECTORY = data_dir)

  write_stats19_fixture(source_dir, "collision", 2024, n = 2)
  write_stats19_fixture(data_dir, "collision", 2024, n = 5)
  stats19_to_parquet(type = "collision", data_dir = source_dir,
                     output_dir = parquet_dir, silent = TRUE)

  tbl_col = get_stats19(year = 2024, type = "collision",
                        output_format = "duckdb", silent = TRUE)

  expect_s3_class(tbl_col, "tbl_duckdb_connection")
  expect_true(inherits(tbl_col, "tbl_lazy"))
  expect_equal(nrow(dplyr::collect(tbl_col)), 2)
  # stats19 deliberately leaves the connection open, so the caller closes it
  DBI::dbDisconnect(dbplyr::remote_con(tbl_col), shutdown = TRUE)
})

test_that("stats19_to_parquet validates compression and max_mem_gb arguments", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  expect_error(stats19_to_parquet(compression = "invalid_codec"), "should be one of")
  expect_error(stats19_to_parquet(max_mem_gb = -1))
  expect_error(stats19_to_parquet(max_mem_gb = "large"))
})

test_that("parquet_has_years correctly detects covered and missing years", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  tmp_dir = tempfile("pq_test_years")
  dir.create(tmp_dir, recursive = TRUE)
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  # Create small test parquet covering 2023 and 2024
  df = data.frame(
    collision_index = c("1", "2"),
    collision_year = c(2023L, 2024L),
    stringsAsFactors = FALSE
  )
  pq_path = file.path(tmp_dir, "collisions.parquet")
  con = DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
  DBI::dbWriteTable(con, "t", df)
  DBI::dbExecute(con, glue::glue("COPY t TO '{pq_path}' (FORMAT PARQUET)"))
  DBI::dbDisconnect(con, shutdown = TRUE)

  expect_true(parquet_has_years(pq_path, 2024))
  expect_true(parquet_has_years(pq_path, 2023:2024))
  expect_false(parquet_has_years(pq_path, 2025))
  expect_false(parquet_has_years(pq_path, 2022))
  expect_false(parquet_has_years(pq_path, "all"))
  expect_false(parquet_has_years("non_existent.parquet", 2024))
})

