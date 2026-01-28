test_that("get_stats19 is exported", {
  expect_true("get_stats19" %in% getNamespaceExports("stats19"))
  expect_true(is.function(get_stats19))
})

test_that("get_stats19 has correct parameters", {
  params = names(formals(get_stats19))
  expect_true("year" %in% params)
  expect_true("type" %in% params)
  expect_true("format" %in% params)
  expect_true("output_format" %in% params)
})

test_that("get_stats19 default parameters are sensible", {
  defaults = formals(get_stats19)
  expect_equal(defaults$format, TRUE)
  expect_equal(defaults$output_format, "tibble")
})
