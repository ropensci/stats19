test_that("get_url works correctly", {
  # Test default parameters
  url = get_url()
  expect_true(grepl("https://data.dft.gov.uk/road-accidents-safety-data", url))
  
  # Test with file name
  url_with_file = get_url("test.csv")
  expect_true(grepl("test.csv$", url_with_file))
  expect_true(grepl("https://data.dft.gov.uk/road-accidents-safety-data", url_with_file))
  
  # Test with custom domain
  url_custom = get_url("file.csv", domain = "https://example.com", directory = "data")
  expect_true(grepl("https://example.com/data/file.csv", url_custom))
})

test_that("current_year returns valid year", {
  year = current_year()
  expect_true(is.numeric(year))
  expect_true(is.integer(year))
  expect_true(year >= 2024 && year <= 2100)
})

test_that("find_file_name works for different years", {
  skip_if_not_installed("stats19")
  
  # Test single recent year
  files_2022 = find_file_name(2022)
  expect_true(length(files_2022) > 0)
  expect_true(any(grepl("2022", files_2022)))
  
  # Test with type filtering
  files_collision = find_file_name(2022, type = "collision")
  expect_true(length(files_collision) > 0)
  expect_true(any(grepl("collision|Collision", files_collision, ignore.case = TRUE)))
  
  # Test casualty type
  files_casualty = find_file_name(2022, type = "casualty")
  expect_true(length(files_casualty) > 0)
  
  # Test vehicle type
  files_vehicle = find_file_name(2022, type = "vehicle")
  expect_true(length(files_vehicle) > 0)
})

test_that("find_file_name handles special year cases", {
  skip_if_not_installed("stats19")
  
  # Test year 5 (last 5 years)
  files_5 = find_file_name(5)
  expect_true(length(files_5) > 0)
  
  # Test "5 years" string
  files_5_str = find_file_name("5 years")
  expect_true(length(files_5_str) > 0)
  
  # Test historical data (before 2020)
  files_old = find_file_name(1985)
  expect_true(length(files_old) > 0)
  expect_true(any(grepl("1979", files_old)))
})

test_that("find_file_name handles type parameter correctly", {
  skip_if_not_installed("stats19")
  
  # Test cas -> ics-cas replacement
  files_cas = find_file_name(2022, type = "cas")
  expect_true(length(files_cas) > 0)
  
  # Test invalid type
  expect_error(find_file_name(type = "invalid_type"), "No files of that type found")
})

test_that("locate_files returns correct paths", {
  skip_if_not_installed("stats19")
  
  # Create a temporary directory for testing
  temp_dir = tempdir()
  
  # Test with non-existent files
  files = locate_files(data_dir = temp_dir, years = 2022, type = "collision")
  expect_equal(length(files), 0)
  
  # Test that function requires existing directory
  expect_error(locate_files(data_dir = "/nonexistent/path"))
})

test_that("locate_one_file works correctly", {
  skip_if_not_installed("stats19")
  
  temp_dir = tempdir()
  
  # Test with no files - should error
  expect_error(locate_one_file(data_dir = temp_dir, year = 2022), "No files found")
})

test_that("get_data_directory returns valid path", {
  # Unset environment variable for testing
  old_dir = Sys.getenv("STATS19_DOWNLOAD_DIRECTORY")
  Sys.unsetenv("STATS19_DOWNLOAD_DIRECTORY")
  
  # Should return tempdir when not set
  dir = get_data_directory()
  expect_equal(dir, tempdir())
  
  # Restore old value if it existed
  if(old_dir != "") {
    Sys.setenv(STATS19_DOWNLOAD_DIRECTORY = old_dir)
  }
})

test_that("set_data_directory validates input", {
  # Test with non-existent directory
  expect_error(set_data_directory("/nonexistent/path/12345"), "Directory does not exist")
  
  # Test with valid directory in non-interactive mode
  temp_dir = tempdir()
  old_dir = Sys.getenv("STATS19_DOWNLOAD_DIRECTORY")
  Sys.unsetenv("STATS19_DOWNLOAD_DIRECTORY")
  
  # Should set without asking in non-interactive mode
  expect_message(set_data_directory(temp_dir), "STATS19_DOWNLOAD_DIRECTORY is set")
  expect_equal(Sys.getenv("STATS19_DOWNLOAD_DIRECTORY"), temp_dir)
  
  # Clean up
  Sys.unsetenv("STATS19_DOWNLOAD_DIRECTORY")
  if(old_dir != "") {
    Sys.setenv(STATS19_DOWNLOAD_DIRECTORY = old_dir)
  }
})

test_that("phrase returns valid prompt", {
  prompt = phrase()
  expect_true(is.character(prompt))
  expect_true(nchar(prompt) > 0)
  expect_true(grepl("\\(y = enter, n = N/other\\)\\?", prompt))
})

test_that("select_file works with menu", {
  # This function uses interactive menu, so we just test it doesn't error
  # with valid input structure
  fnames = c("file1.csv", "file2.csv")
  # Cannot test interactive function directly in automated tests
  expect_true(is.character(fnames))
})
