context("test-read_stats19")

source("../skip-download.R")

test_that("read_accidents works", {
  skip_download()
  # download real data
  acc_2016 = stats19::file_names$dftRoadSafety_Accidents_2016.zip
  dl_stats19(file_name = acc_2016)
  # make sure we have a csv file to read
  path = locate_one_file(
    tempdir(),
    type = "accidents",
    year = 2016,
    filename = sub(".zip", ".csv", acc_2016)
  )
  # read it
  read = read_accidents(
    year = 2016, # make it unique
    data_dir = tempdir()
    # filename = sub(".zip", ".csv", acc_2016)
  )
  raw_read = read.csv(path)
  expect_equal(nrow(read), nrow(raw_read))
  # read with just file name
  read = read_accidents(
    filename = sub(".zip", ".csv", acc_2016)
  )
  expect_equal(nrow(read), nrow(raw_read))
  expect_error(read_accidents("junk"))
})

test_that("read_vehicles works", {
  skip_download()
  # download real data
  veh_2016 = stats19::file_names$dftRoadSafetyData_Vehicles_2016.zip
  dl_stats19(file_name = veh_2016)

  path = locate_one_file( # need it for raw_read
    data_dir = tempdir(),
    type = "vehicles",
    year = 2016)
  # read it
  read = read_vehicles(
    year = 2016,
    data_dir = tempdir(),
    filename = "Veh.csv"
  )
  raw_read = read.csv(path)
  expect_false(identical(
    class(read$Accident_Index),
    class(raw_read$Accident_Index)
    ))
  # read it using file name only IF only one is Veh.csv is downloaded.
  # thefore start from clean
  unlink(tempdir(), recursive = TRUE)
  dir.create(tempdir())
  dl_stats19(file_name = veh_2016)
  read = read_vehicles(
    filename = "Veh.csv"
  )
  expect_false(identical(
    class(read$Accident_Index),
    class(raw_read$Accident_Index)
  ))
  expect_error(read_vehicles("junk"))
})

test_that("read_casualties works", {
  skip_download()
  # download real data
  cas_2016 = stats19::file_names$dftRoadSafetyData_Casualties_2016.zip
  dl_stats19(file_name = cas_2016)
  path = locate_one_file(
    type = "Casualties",
    data_dir = tempdir(),
    year = 2016,
    filename = "Cas.csv")
  # read it
  read = read_casualties(
    year = 2016, # make it unique
    data_dir = tempdir(),
    filename = "Cas.csv"
  )
  raw_read = read.csv(path)
  expect_false(identical(
    class(read$Accident_Index),
    class(raw_read$Accident_Index)
  ))
  expect_error(read_vehicles("junk"))
})
