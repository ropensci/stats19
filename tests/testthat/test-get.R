context("test-get")

test_that("get_stats19 works", {
  skip_download()
  skip_on_cran()
  veh = get_stats19(year = 2019, type = "veh")
  expect_true(nrow(veh) > 100000)
  cas = get_stats19(year = 2019, type = "cas")
  expect_true(nrow(cas) > 100000)
  acc = get_stats19(year = 2019, type = "collision")
  expect_true(nrow(acc) > 100000)
  acc = get_stats19(year = 2019)
  expect_true(nrow(acc) > 100000)
  # get_stats19 defaults to accidents and downloads first
  # from menu (2022) so multilple will found for read_
  # which is expected.
  # expect_error(get_stats19(type = "veh"))

  # check class of output_format
  acc_tibble = get_stats19(year = 2019, type = "collision")
  acc_data_frame = get_stats19(year = 2019, type = "collision", output_format = "data.frame")
  acc_sf = get_stats19(year = 2019, type = "collision", output_format = "sf")

  expect_true(is(acc_tibble, "tbl_df"))
  expect_s3_class(acc_data_frame, "data.frame")
  expect_true(is(acc_sf, "sf"))

  # if the output format is not c("tibble", "sf", "ppp") then it returns NULL
  expect_warning({acc = get_stats19(2019, "collision", output_format = "abcdef")})
  expect_true(is(acc, "tbl_df"))

  # raise warning if output_format = "sf" and type = "cas". Defaulting to
  # tbl output format.
  # expect_warning({acc = get_stats19(2010, type = "cas", output_format = "sf")})
  expect_true(is(acc, "tbl_df"))
})

test_that("get_stats19 works with multiple years and formats", {
  skip_on_cran()
  skip_if_offline()
  cas_2021 = get_stats19(2021, type = "cas", silent = TRUE)
  cas_2022 = get_stats19(2022, type = "cas", silent = TRUE)
  expect_equal(
    names(cas_2021),
    names(cas_2022)
    )
})

find_cols_with_many_NAs = function(df, na_threshold = 0.5) {
  # Calculate the proportion of NAs in each column
  na_proportions = sapply(df, function(col) sum(is.na(col)) / length(col))

  # Find columns where the proportion of NAs is greater than the threshold
  cols_with_many_NAs = names(na_proportions[na_proportions > na_threshold])

  return(cols_with_many_NAs)
}

test_that("col types are set", {
  skip_download()
  skip_on_cran()
  cas = get_stats19(year = 2019, type = "cas")
  veh = get_stats19(year = 2019, type = "veh")
  # print(nrow(cas))
  # print("class(veh$age_of_vehicle)")
  # print(class(veh$age_of_vehicle))
  # print("class(cas$age_of_casualty)")
  # print(class(cas$age_of_casualty))
  expect_type(cas$age_of_casualty, "integer")
  expect_type(veh$age_of_vehicle, "integer")
  # no NAs introduced
  expect_length(find_cols_with_many_NAs(cas), 0)
  expect_length(find_cols_with_many_NAs(veh), 0)
})
