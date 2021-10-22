context("test-read_stats19")

source("../skip-download.R")

test_that("read_accidents works", {
  skip_download()
  skip_on_cran()
  # download real data
  acc_2016 = stats19::file_names$`dft-road-casualty-statistics-vehicle-2019.csv`
  dl_stats19(file_name = acc_2016)
  # make sure we have a csv file to read
  path = stats19:::locate_one_file(
    stats19:::get_data_directory(),
    type = "accident",
    year = 2016,
    filename = sub(".zip", ".csv", acc_2016)
  )
  # read it
  read = read_accidents(
    year = 2016, # make it unique
    # filename = sub(".zip", ".csv", acc_2016)
  )
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
test_that("read_vehicles works", {
  skip_download()
  skip_on_cran()
  # download real data
  veh_2016 = stats19::file_names$`dft-road-casualty-statistics-vehicle-2016.csv`
  dl_stats19(file_name = veh_2016)

  path = locate_one_file( # need it for raw_read
    type = "vehicle",
    year = 2016)
  # read it
  read = read_vehicles(
    year = 2016,
    filename = "Veh.csv"
  )
  raw_read = read.csv(path)
  expect_false(identical(
    class(read$Accident_Index),
    class(raw_read$Accident_Index)
    ))
  read_formatted = read_vehicles(
    year = 2016,
    filename = "Veh.csv",
    format = FALSE
  )
  # read it using file name only IF only one is Veh.csv is downloaded.
  # thefore start from clean
  unlink(tempdir(), recursive = TRUE)
  dir.create(tempdir())
  # expect error for clean data_dir
  # fname_2016 = stats19:::check_input_file(year = 2016, type = "ac",
  #                                         data_dir = stats19:::get_data_directory())
  # if(!file.exists(fname_2016)) {
  #   expect_error(read_accidents(year = 2016))
  # }
  dl_stats19(year = 2016, type = "veh")
  read = read_vehicles(year = 2016)
  expect_error(read_vehicles("junk"))
  # "Your parameters return identical filenames under different directories."
})

test_that("read_casualties works", {
  skip_download()
  skip_on_cran()
  # download real data
  cas_2016 = stats19::file_names$`dft-road-casualty-statistics-casualty-2016.csv`
  dl_stats19(file_name = cas_2016)
  path = locate_one_file(
    type = "casualty",
    year = 2016
    )
  # read it
  read = read_casualties(
    year = 2016, # make it unique
    filename = "Cas.csv",
    format = FALSE
  )
  raw_read = read.csv(path)
  read_formatted = read_casualties(
    year = 2016,
    format = TRUE
  )
  expect_equal(nrow(read_formatted), nrow(raw_read))
})
