test_that("get_MOT is exported", {
  expect_true("get_MOT" %in% getNamespaceExports("stats19"))
  expect_true(is.function(get_MOT))
})

test_that("get_MOT has correct parameters", {
  params = names(formals(get_MOT))
  expect_true("vrm" %in% params)
  expect_true("apikey" %in% params)
})

test_that("get_MOT validates VRM input correctly", {
  # Test VRM with spaces
  expect_error(get_MOT(vrm = c("ABC 123"), apikey = "test"), "Please remove spaces from VRMs")
  
  # Test VRM with non-alphanumeric characters
  expect_error(get_MOT(vrm = c("ABC-123"), apikey = "test"), "VRMs must be alphanumeric")
  
  # Test non-character apikey
  expect_error(get_MOT(vrm = c("ABC123"), apikey = 123), "api key must be a character string")
  
  # Test large number of VRMs
  expect_error(get_MOT(vrm = rep("ABC123", 150000), apikey = "test"), 
               "Don't do more than 150,000 VRMs per day")
  
  # Test non-character VRM elements
  expect_error(get_MOT(vrm = c(123), apikey = "test"), "All VRMs must be character")
})

test_that("get_MOT validates apikey input", {
  # Non-character API key
  expect_error(get_MOT(vrm = c("TEST123"), apikey = 12345), 
               "api key must be a character string")
})
