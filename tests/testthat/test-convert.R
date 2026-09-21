test_that("get_parquet_directory and set_parquet_directory work", {
  old_dir = Sys.getenv("STATS19_PARQUET_DIRECTORY", unset = "")
  on.exit({
    if (old_dir == "") {
      Sys.unsetenv("STATS19_PARQUET_DIRECTORY")
    } else {
      Sys.setenv(STATS19_PARQUET_DIRECTORY = old_dir)
    }
  })

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

test_that("get_stats19 with output_format = 'duckdb' returns a lazy tbl", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")
  skip_if_not_installed("dbplyr")

  # Test on available data if present
  p_dir = get_parquet_directory()
  skip_if(!file.exists(file.path(p_dir, "collisions.parquet")))

  tbl_col = get_stats19(year = 2024, type = "collision", output_format = "duckdb", silent = TRUE)
  expect_s3_class(tbl_col, "tbl_duckdb_connection")
  expect_true(inherits(tbl_col, "tbl_lazy"))
})

