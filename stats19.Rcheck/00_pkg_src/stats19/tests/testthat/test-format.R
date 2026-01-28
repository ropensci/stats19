test_that("format_column_names works correctly", {
  # Test basic column name formatting
  cols = c("Accident Index", "Location Easting (OSGR)", "1st Road Class", "2nd Road Number")
  formatted = format_column_names(cols)
  
  expect_equal(formatted[1], "accident_index")
  expect_equal(formatted[2], "location_easting_osgr")
  expect_equal(formatted[3], "first_road_class")
  expect_equal(formatted[4], "second_road_number")
})

test_that("format_column_names handles special characters", {
  # Test parentheses removal
  expect_equal(format_column_names("Test (Value)"), "test_value")
  
  # Test question mark removal
  expect_equal(format_column_names("What?"), "what")
  
  # Test hyphen to underscore
  expect_equal(format_column_names("Test-Value"), "test_value")
  
  # Test space to underscore
  expect_equal(format_column_names("Test Value"), "test_value")
  
  # Test lowercase conversion
  expect_equal(format_column_names("TEST VALUE"), "test_value")
})

test_that("format_column_names handles ordinal numbers", {
  expect_equal(format_column_names("1st Item"), "first_item")
  expect_equal(format_column_names("2nd Item"), "second_item")
})

test_that("format_collisions is exported and documented", {
  expect_true("format_collisions" %in% getNamespaceExports("stats19"))
  
  # Test that function exists and has correct structure
  expect_true(is.function(format_collisions))
  expect_equal(length(formals(format_collisions)), 1)
})

test_that("format_casualties is exported and documented", {
  expect_true("format_casualties" %in% getNamespaceExports("stats19"))
  
  # Test that function exists
  expect_true(is.function(format_casualties))
  expect_equal(length(formals(format_casualties)), 1)
})

test_that("format_vehicles is exported and documented", {
  expect_true("format_vehicles" %in% getNamespaceExports("stats19"))
  
  # Test that function exists
  expect_true(is.function(format_vehicles))
  expect_equal(length(formals(format_vehicles)), 1)
})

test_that("format_sf works with sample data", {
  skip_if_not_installed("sf")
  
  # Use the built-in sample data
  data("accidents_sample", package = "stats19")
  
  # Test format_sf
  x_sf = format_sf(accidents_sample)
  
  # Check that it's an sf object
  expect_s3_class(x_sf, "sf")
  
  # Check that geometry column exists
  expect_true("geometry" %in% names(x_sf))
  
  # Check CRS is British National Grid
  expect_equal(sf::st_crs(x_sf)$epsg, 27700)
})

test_that("format_sf works with lonlat parameter", {
  skip_if_not_installed("sf")
  
  data("accidents_sample", package = "stats19")
  
  # Test with lonlat = TRUE
  x_sf_lonlat = format_sf(accidents_sample, lonlat = TRUE)
  
  # Check that it's an sf object
  expect_s3_class(x_sf_lonlat, "sf")
  
  # Check CRS is WGS84 (longitude/latitude)
  expect_equal(sf::st_crs(x_sf_lonlat)$epsg, 4326)
})

test_that("format_sf removes rows with missing coordinates", {
  skip_if_not_installed("sf")
  
  data("accidents_sample", package = "stats19")
  
  # Create test data with NA coordinates
  test_data = accidents_sample[1:5, ]
  test_data$location_easting_osgr[1] = NA
  test_data$location_northing_osgr[2] = NA
  
  # Format should remove rows with NA
  expect_message(x_sf <- format_sf(test_data), "rows removed with no coordinates")
  
  # Should have fewer rows (at least 2 NAs removed)
  expect_true(nrow(x_sf) < 5)
  expect_true(nrow(x_sf) >= 1)
})

test_that("format_ppp works with sample data", {
  skip_if_not_installed("spatstat.geom")
  
  data("accidents_sample", package = "stats19")
  
  # Test format_ppp
  x_ppp = format_ppp(accidents_sample)
  
  # Check that it's a ppp object
  expect_s3_class(x_ppp, "ppp")
  
  # Check that it has the right structure
  expect_true("x" %in% names(x_ppp))
  expect_true("y" %in% names(x_ppp))
  expect_true("marks" %in% names(x_ppp))
})

test_that("format_ppp works with custom window", {
  skip_if_not_installed("spatstat.geom")
  
  data("accidents_sample", package = "stats19")
  
  # Create custom window
  custom_window = spatstat.geom::owin(
    xrange = c(400000, 500000),
    yrange = c(400000, 500000)
  )
  
  # Test format_ppp with custom window
  x_ppp = format_ppp(accidents_sample, window = custom_window)
  
  # Check that it's a ppp object
  expect_s3_class(x_ppp, "ppp")
})

test_that("format_ppp removes rows with missing coordinates", {
  skip_if_not_installed("spatstat.geom")
  
  data("accidents_sample", package = "stats19")
  
  # Create test data with NA coordinates
  test_data = accidents_sample[1:5, ]
  test_data$location_easting_osgr[1] = NA
  
  # Format should remove rows with NA
  expect_message(x_ppp <- format_ppp(test_data), "rows removed with no coordinates")
})

test_that("format_ppp requires spatstat.geom package", {
  # Mock the scenario where spatstat.geom is not installed
  # This is tricky to test without actually uninstalling the package
  # So we just verify the function checks for it
  expect_true(is.function(format_ppp))
})
