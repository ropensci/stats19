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

  # check class of output_format
  acc_tibble = get_stats19(year = 2009, type = "acc")
  acc_sf = get_stats19(year = 2009, type = "acc", output_format = "sf")
  acc_ppp = get_stats19(year = 2009, type = "acc", output_format = "ppp")

  expect_true(is(acc_tibble, "tbl_df"))
  expect_true(is(acc_sf, "sf"))
  expect_true(is(acc_ppp, "ppp"))

  # if the output format is not c("tibble", "sf", "ppp") then it returns NULL
  acc = get_stats19(year = 2009, type = "acc", output_format = "abcdef")
  expect_null(acc)
})

test_that("get_stats19 multiple years", {
  t09 = get_stats19(year = 2009)
  t15 = get_stats19(year = 2015)
  t16 = get_stats19(year = 2016)
  t = get_stats19(year = c(2009, 2015, 2016))

  expect_equal(nrow(t), sum(nrow(t09), nrow(t15), nrow(t16)))
})
