test_that("get_stats19_adjustments is exported", {
  expect_true("get_stats19_adjustments" %in% getNamespaceExports("stats19"))
  expect_true(is.function(get_stats19_adjustments))
})

test_that("get_stats19_adjustments has correct parameters", {
  params = names(formals(get_stats19_adjustments))
  expect_true("data_dir" %in% params)
  expect_true("u" %in% params)
})

test_that("get_stats19_adjustments returns informative message", {
  # This function now returns a message about adjusted data being in casualty table
  result = get_stats19_adjustments()
  expect_true(is.character(result))
  expect_true(grepl("Adjustment table is now merged", result))
})
