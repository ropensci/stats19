test_that("multiplication works", {
  devtools::load_all()
  # print(check_year(2005:2010))
  expect_equal(check_year(2005:2010), 2005)
})
