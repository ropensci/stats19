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

test_that("stats19_to_parquet keeps legacy columns for format_stats19 to normalise", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  tmp_data = withr::local_tempdir()
  tmp_out = withr::local_tempdir()

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
  raw = DBI::dbGetQuery(con, paste0("SELECT * FROM read_parquet('", p_path, "')"))
  res = format_collisions(raw)
  expect_equal(nrow(res), 2)
  expect_equal(res$collision_index, c("201701X", "201702Y"))
  expect_equal(res$collision_year, c(2017, 2017))
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

test_that("stats19_to_parquet handles type = 'all', compression and overwrite", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  data_dir = withr::local_tempdir()
  output_dir = withr::local_tempdir()
  for (t in c("collision", "casualty", "vehicle")) {
    write_stats19_fixture(data_dir, t, 2024)
  }

  paths = stats19_to_parquet(type = "all", data_dir = data_dir,
                             output_dir = output_dir, compression = "snappy",
                             silent = TRUE)
  expect_length(paths, 3)
  expect_true(all(file.exists(paths)))
  expect_setequal(basename(paths), c("collisions.parquet", "casualties.parquet", "vehicles.parquet"))
  for (p in paths) {
    expect_equal(parquet_row_count(p), 2)
  }

  # overwrite = FALSE keeps what is on disk and says so
  expect_message(
    again <- stats19_to_parquet(type = "collision", data_dir = data_dir,
                                output_dir = output_dir, overwrite = FALSE),
    "overwrite is FALSE"
  )
  expect_equal(again, file.path(output_dir, "collisions.parquet"))
})

test_that("stats19_to_parquet stops on an unknown type", {
  expect_error(
    stats19_to_parquet(type = "not_a_type", data_dir = tempdir(), silent = TRUE),
    "Unrecognised type"
  )
})

test_that("stats19_to_parquet reports an empty data directory", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  data_dir = withr::local_tempdir()
  expect_message(
    res <- stats19_to_parquet(type = "collision", data_dir = data_dir,
                              output_dir = withr::local_tempdir(), silent = TRUE),
    "No CSV files found in"
  )
  expect_null(res)
})

test_that("get_stats19 warns and falls back on an unknown output_format", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  # A covering cache means no download is attempted for the CSV path either
  fixture = local_parquet_fixture(type = "collision", year = 2024, cache_n = 2)

  expect_warning(
    res <- get_stats19(year = 2024, type = "collision", output_format = "nonsense",
                       engine = "duckdb", format = FALSE, silent = TRUE),
    "output_format should be one of"
  )
  expect_equal(nrow(res), 2)
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
  fixture = local_parquet_fixture(type = "collision", year = 2024, cache_n = 2, csv_n = 5)

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
  expect_warning(expect_false(parquet_has_years(pq_path, 2024)), "another stats19 version")
  DBI::dbExecute(con, glue::glue(
    "COPY t TO '{pq_path}' (FORMAT PARQUET, KV_METADATA {{stats19_format: '{stats19_parquet_format}'}})"
  ))
  DBI::dbDisconnect(con, shutdown = TRUE)

  expect_true(parquet_has_years(pq_path, 2024))
  expect_true(parquet_has_years(pq_path, 2023:2024))
  expect_false(parquet_has_years(pq_path, 2025))
  expect_false(parquet_has_years(pq_path, 2022))
  expect_false(parquet_has_years(pq_path, "all"))
  expect_false(parquet_has_years("non_existent.parquet", 2024))
})

