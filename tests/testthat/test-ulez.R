test_that("get_ULEZ is exported", {
  expect_true("get_ULEZ" %in% getNamespaceExports("stats19"))
  expect_true(is.function(get_ULEZ))
})

test_that("get_ULEZ has correct parameters", {
  params = names(formals(get_ULEZ))
  expect_true("vrm" %in% params)
  expect_equal(length(params), 1)
})

test_that("get_ULEZ validates VRM input correctly", {
  # Test VRM with spaces
  expect_error(get_ULEZ(vrm = c("ABC 123")), "Please remove spaces from VRMs")
  
  # Test VRM with non-alphanumeric characters
  expect_error(get_ULEZ(vrm = c("ABC-123")), "VRMs must be alphanumeric")
  
  # Test non-character VRM elements
  expect_error(get_ULEZ(vrm = c(123)), "All VRMs must be character")
})

test_that("get_ULEZ shows rate limiting message", {
  skip_if_offline()
  skip_on_cran()
  
  # The function should display a message about rate limiting
  expect_message(get_ULEZ(vrm = c("INVALID")), "50 vrms per minute")
})
