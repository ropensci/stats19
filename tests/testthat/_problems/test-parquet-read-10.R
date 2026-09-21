# Extracted from test-parquet-read.R:10

# test -------------------------------------------------------------------------
skip_if_not_installed("duckdb")
skip_if_not_installed("DBI")
fixture = local_parquet_fixture(type = "collision", year = 2024,
                                  cache_n = 2, cache_year = 2023, csv_n = 1)
