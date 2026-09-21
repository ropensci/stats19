# Extracted from test-parquet-read.R:32

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "stats19", path = "..")
attach(test_env, warn.conflicts = FALSE)

# test -------------------------------------------------------------------------
skip_if_not_installed("duckdb")
skip_if_not_installed("DBI")
fixture = local_parquet_fixture(type = "collision", year = 2024,
                                  cache_n = 2, csv_n = 5)
res = read_stats19(year = 2024, type = "collision", engine = "readr",
                     format = FALSE, silent = TRUE)
expect_equal(nrow(res), 5)
