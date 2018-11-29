context("test-read_stats19")

test_that("read_accidents works", {
  skip_download()
  # download real data
  acc_2016 = file_names$dftRoadSafety_Accidents_2016.zip
  dl_stats19(file_name = acc_2016)
  # make sure we have a csv file to read
  path = locate_one_file(
    tempdir(), years = 2016, filename = sub(".zip", ".csv", acc_2016))
  # read it
  read = read_accidents(
    years = 2016, # make it unique
    data_dir = tempdir(),
    filename = sub(".zip", ".csv", acc_2016)
  )
  raw_read = read.csv(path)
  expect_equal(nrow(read), nrow(raw_read))
  expect_error(read_accidents("junk"))
})

test_that("read_vehicles works", {
  skip_download()
  # download real data
  veh_2016 = file_names$dftRoadSafetyData_Vehicles_2016.zip
  dl_stats19(file_name = veh_2016)
  path = file.path(
    tempdir(), sub(".zip", "", veh_2016))
  # read it
  read = read_vehicles(
    data_dir = path,
    filename = "Veh.csv"
  )
  raw_read = read.csv(file.path(path, "Veh.csv"))
  expect_false(identical(
    class(read$Accident_Index),
    class(raw_read$Accident_Index)
    ))
  expect_error(read_vehicles("junk"))
})
