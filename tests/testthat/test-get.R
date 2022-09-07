context("test-get")

test_that("get_stats19 works", {
  skip_download()
  skip_on_cran()
  veh = get_stats19(year = 2019, type = "veh")
  expect_true(nrow(veh) > 100000)
  cas = get_stats19(year = 2019, type = "cas")
  expect_true(nrow(cas) > 100000)
  acc = get_stats19(year = 2019, type = "acc")
  expect_true(nrow(acc) > 100000)
  acc = get_stats19(year = 2019)
  expect_true(nrow(acc) > 100000)
  # get_stats19 defaults to accidents and downloads first
  # from menu (2017) so multilple will found for read_
  # which is expected.
  # expect_error(get_stats19(type = "veh"))

  # check class of output_format
  acc_tibble = get_stats19(year = 2019, type = "acc")
  acc_data_frame = get_stats19(year = 2019, type = "acc", output_format = "data.frame")
  acc_sf = get_stats19(year = 2019, type = "acc", output_format = "sf")
  acc_ppp = get_stats19(year = 2019, type = "acc", output_format = "ppp")

  expect_true(is(acc_tibble, "tbl_df"))
  expect_s3_class(acc_data_frame, "data.frame")
  expect_true(is(acc_sf, "sf"))
  expect_true(is(acc_ppp, "ppp"))

  # if the output format is not c("tibble", "sf", "ppp") then it returns NULL
  expect_warning({acc = get_stats19(2019, "acc", output_format = "abcdef")})
  expect_true(is(acc, "tbl_df"))

  # raise warning if output_format = "sf" and type = "cas". Defaulting to
  # tbl output format.
  # expect_warning({acc = get_stats19(2010, type = "cas", output_format = "sf")})
  expect_true(is(acc, "tbl_df"))
})

test_that("get_stats19 multiple years", {
  skip_on_cran()
  skip_if_offline()
  t18 = get_stats19(year = 2018)
  t19 = get_stats19(year = 2019)
  expect_equal(names(t18), names(t19))
})

test_that("get_stats19 works with multiple years and formats", {
  skip_on_cran()
  skip_if_offline()
  cas_2018 = get_stats19(2018, type = "cas", silent = TRUE)
  cas_2017 = get_stats19(2017, type = "cas", silent = TRUE)
  cas_2016 = get_stats19(2016, type = "cas", silent = TRUE)
  expect_equal(
    names(cas_2016),
    names(cas_2017)
    )
})


