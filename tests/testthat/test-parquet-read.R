# Reading from the Parquet cache: coverage, fallback and download behaviour.
# Fixtures and helpers live in helper-stats19.R.

test_that("a cache that does not cover the requested year falls back to the CSV", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  # Cache covers 2023 only; 2024 exists as a CSV
  fixture = local_parquet_fixture(type = "collision", year = 2024,
                                  cache_n = 2, cache_year = 2023, csv_n = 1)

  res = NULL
  expect_warning(
    res <- read_stats19(year = 2024, type = "collision", engine = "parquet",
                        format = FALSE, silent = TRUE),
    "may not be fully covered"
  )
  # one row, from the CSV, not two from the cache. The CSV path reads every
  # column as text, so compare as character.
  expect_equal(nrow(res), 1)
  expect_true(all(as.character(res$collision_year) == "2024"))
})

test_that("engine = 'readr' reads the CSV even when a cache covers the year", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  fixture = local_parquet_fixture(type = "collision", year = 2024,
                                  cache_n = 2, csv_n = 5)

  res = read_stats19(year = 2024, type = "collision", engine = "readr",
                     format = FALSE, silent = TRUE)
  expect_equal(nrow(res), 5)
})

test_that("get_stats19 does not download files the cache already covers", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  fixture = local_parquet_fixture(type = "collision", year = 2024, cache_n = 2)

  res = get_stats19(year = 2024, type = "collision", engine = "duckdb",
                    format = FALSE, silent = TRUE)
  expect_equal(nrow(res), 2)
  # nothing was written to the download directory: the cache satisfied the call
  expect_length(list.files(fixture$data_dir), 0)
})
