context("test-format")

test_that("read_schema works", {
  t = stats19::read_schema()
  expect_equal(nrow(t), 969)
})
