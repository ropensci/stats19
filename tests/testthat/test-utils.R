context("test-utils")

test_that("geturl works", {
  expect_equal(get_url(),
               file.path("http://data.dft.gov.uk.s3.amazonaws.com",
                         "road-accidents-safety-data/")
               )
})

test_that("find_file_name works", {
  expect_equal(find_file_name(type = "accid"),
               "dftRoadSafety_Accidents_2016.zip")
  expect_equal(find_file_name(years ="2015", type = "accid"),
               "RoadSafetyData_Accidents_2015.zip")
  expect_equal(find_file_name(years = c("2005", "2006")),
               "Stats19_Data_2005-2014.zip")
  expect_error(find_file_name(years = c("2009", "2014", "2015")))
  # cover https://github.com/ITSLeeds/stats19/issues/21
  files_found = find_file_name(years = 1980:2001)
  expect_equal(length(files_found), 2)
  # start OR end year is between 74 and 04
  files_found = find_file_name(years = 1974:2004)
  expect_equal(length(files_found), 2)
  files_found = find_file_name(years = 1974:2005)
  expect_equal(length(files_found), 2)
  # wrongs
  files_found = find_file_name(years = 1973:1972)
  expect_equal(length(files_found), 0)
  files_found = find_file_name(years = -1)
  expect_equal(length(files_found), 0)
  files_found = find_file_name(years = "testing")
  expect_equal(length(files_found), 0)
  files_found = find_file_name(years = 1973)
  expect_equal(length(files_found), 0)
})

test_that("locate_files & locate_one_file works", {
  fn = stats19::file_names$dftRoadSafetyData_Casualties_2017.zip
  skip_download()
  dl_stats19(file_name = fn)
  x = locate_files(return = TRUE)
  expect_true(length(x) > 0) # other files would have been downloaded already
  x1 = locate_one_file(filename = "Cas.csv", type = "casualties")
  expect_true(length(x1) == 1)
  # now multiple
  fn = stats19::file_names$dftRoadSafetyData_Casualties_2016.zip
  dl_stats19(file_name = fn)
  x2 = locate_one_file(filename = "Cas.csv")
  expect_true(length(x1) == 1)
  # more tests on locate_files
  expect_output(locate_files())
  expect_silent(locate_files(quiet = TRUE))
  # from clean start
  unlink(tempdir(), recursive = TRUE)
  dir.create(tempdir())
  expect_null(locate_files(return = TRUE))
  expect_message(locate_files())
  expect_error(locate_files(data_dir = "/junking"))
})
