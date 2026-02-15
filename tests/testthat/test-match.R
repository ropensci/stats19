test_that("match_tag is exported", {
  expect_true("match_tag" %in% getNamespaceExports("stats19"))
  expect_true(is.function(match_tag))
})

test_that("match_tag has correct parameters", {
  params = names(formals(match_tag))
  expect_true("crashes" %in% params)
  expect_true("shapes_url" %in% params)
  expect_true("costs_url" %in% params)
  expect_true("match_with" %in% params)
  expect_true("include_motorway_bua" %in% params)
  expect_true("summarise" %in% params)
})

test_that("match_tag has sensible defaults", {
  defaults = formals(match_tag)
  expect_equal(defaults$match_with, "severity")
  expect_equal(defaults$include_motorway_bua, FALSE)
  expect_equal(defaults$summarise, FALSE)
})

test_that("match_tag parameter validation", {
  skip_if_not_installed("stats19")
  skip_if_offline()
  
  # Test that function requires a crashes data frame
  expect_error(match_tag(), "argument \"crashes\" is missing")
})
