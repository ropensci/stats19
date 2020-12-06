test_that("check-year works", {
  expect_equal(check_year(2005:2010), 2005)
  expect_true(identical(check_year(c(2017, 2018)),
                        as.numeric(c(2017, 2018))))
  expect_true(identical(check_year(1979:2018),
                        as.numeric(c(1979, 2005, 2015:2018))))
})
