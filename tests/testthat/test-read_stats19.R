context("test-read_stats19")

source("../skip-download.R")

test_that("read_accidents works", {
  skip_download()
  skip_on_cran()
  # download real data
  acc_2019 = stats19::file_names$`dft-road-casualty-statistics-vehicle-2019.csv`
  dl_stats19(file_name = acc_2019)
  # make sure we have a csv file to read
  path = stats19:::locate_one_file(
    stats19:::get_data_directory(),
    type = "accident",
    year = 2019,
    filename = sub(".zip", ".csv", acc_2019)
  )
  # read it
  read = read_accidents(year = 2019)
  raw_read = read.csv(path)
  expect_equal(nrow(read), nrow(raw_read))
  # read with just file name
})

test_that("read_* acc_index works", {
  skip_download()
  skip_on_cran()
  veh_2019 = stats19::file_names$`dft-road-casualty-statistics-vehicle-2019.csv`
  dl_stats19(file_name = veh_2019)
  cas_2019 = stats19::file_names$`dft-road-casualty-statistics-casualty-2019.csv`
  dl_stats19(file_name = cas_2019)
  read_veh = read_vehicles(year = 2019)
  read_cas = read_casualties(year = 2019)
  expect_true(identical(names(read_veh)[1], "accident_index"))
  expect_true(identical(names(read_cas)[1], "accident_index"))
})

test_that("read_casualties works", {
  skip_download()
  skip_on_cran()
  # download real data
  cas_2019 = stats19::file_names$`dft-road-casualty-statistics-casualty-2019.csv`
  dl_stats19(file_name = cas_2019)
  path = locate_one_file(
    type = "casualty",
    year = 2019
    )
  # read it
  read = read_casualties(
    year = 2019, # make it unique
    filename = "Cas.csv",
    format = FALSE
  )
  raw_read = read.csv(path)
  read_formatted = read_casualties(
    year = 2019,
    format = TRUE
  )
  expect_equal(nrow(read_formatted), nrow(raw_read))
})
