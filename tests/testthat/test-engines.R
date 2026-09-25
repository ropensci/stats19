# The readr, DuckDB and Parquet engines must return identical data.

sort_stats19 = function(x) {
  key = intersect(c("collision_index", "vehicle_reference", "casualty_reference"), names(x))
  x = x[do.call(order, unname(as.list(x[key]))), ]
  rownames(x) = NULL
  x
}

test_that("engines agree on a CSV with padding, -1 and unlisted columns", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")

  data_dir = withr::local_tempdir()
  parquet_dir = withr::local_tempdir()
  f = file.path(data_dir, "dft-road-casualty-statistics-collision-2024.csv")
  writeLines(c(
    "collision_index,collision_year,collision_ref_no,speed_limit,junction_detail,enhanced_severity_collision,collision_adjusted_severity_serious,date,time",
    "2024A,2024,A1,30,3,-1,0.25,01/02/2024,08:15",
    "2024B,2024,B1 ,-1,-1,3,1,02/02/2024,17:40"
  ), f)
  stats19_to_parquet("collision", data_dir = data_dir, output_dir = parquet_dir, silent = TRUE)

  res = lapply(c("readr", "duckdb", "parquet"), function(e) {
    withr::local_envvar(STATS19_PARQUET_DIRECTORY = if (e == "parquet") parquet_dir else tempfile())
    sort_stats19(suppressMessages(read_stats19(year = 2024, type = "collision", data_dir = data_dir,
                                               engine = e, silent = TRUE)))
  })
  expect_identical(res[[2]], res[[1]])
  expect_identical(res[[3]], res[[1]])
  expect_type(res[[1]]$enhanced_severity_collision, "double")
  expect_identical(res[[1]]$collision_reference, c("A1", "B1"))
})

test_that("readr and duckdb engines agree on real data for each table", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")
  withr::local_envvar(STATS19_PARQUET_DIRECTORY = tempfile())

  for (type in c("collision", "casualty", "vehicle")) {
    get = function(engine) sort_stats19(suppressMessages(
      get_stats19(year = 2024, type = type, engine = engine, silent = TRUE)))
    r = get("readr")
    skip_if(is.null(r) || nrow(r) == 0, "No data downloaded")
    expect_identical(get("duckdb"), r, label = type)
  }
})
