context("test-get")

test_that("get_stats19 works", {
  skip_download()
  veh = get_stats19(year = 2009, type = "veh")
  expect_true(nrow(veh) > 100000)
  cas = get_stats19(year = 2009, type = "cas")
  expect_true(nrow(cas) > 100000)
  acc = get_stats19(year = 2009, type = "acc")
  expect_true(nrow(acc) > 100000)
  acc = get_stats19(year = 2009)
  expect_true(nrow(acc) > 100000)
  # get_stats19 defaults to accidents and downloads first
  # from menu (2017) so multilple will found for read_
  # which is expected.
  expect_error(get_stats19(type = "veh"))

})

