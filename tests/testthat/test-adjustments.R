test_that("summarise_adjusted_severities works on sample data", {
  cas = casualties_sample
  res = summarise_adjusted_severities(cas)

  expect_s3_class(res, "tbl_df")
  expect_named(res, c("fatal", "serious_unadjusted", "serious_adjusted", "slight_unadjusted", "slight_adjusted", "total"))
  expect_equal(res$total, nrow(cas))
  expect_equal(res$serious_unadjusted, res$serious_adjusted)
})

test_that("summarise_adjusted_severities correctly applies adjustment probabilities", {
  df = data.frame(
    collision_year = c(2024, 2024, 2024, 2024),
    casualty_severity = c("Fatal", "Serious", "Slight", "Slight"),
    casualty_adjusted_severity_serious = c(NA, 0.85, 0.40, NA),
    casualty_adjusted_severity_slight = c(NA, 0.15, 0.60, NA),
    stringsAsFactors = FALSE
  )

  res = summarise_adjusted_severities(df)

  expect_equal(res$fatal, 1)
  expect_equal(res$serious_unadjusted, 1)
  # serious_adjusted: Fatal=0, row2=0.85, row3=0.40, row4=0 (slight unadjusted) -> 1.25 -> round = 1
  expect_equal(res$serious_adjusted, 1)

  # slight_adjusted: row2=0.15, row3=0.60, row4=1 (fallback for NA slight) -> 1.75 -> round = 2
  expect_equal(res$slight_adjusted, 2)
  expect_equal(res$total, 4)
})

test_that("summarise_adjusted_severities supports grouping", {
  df = data.frame(
    collision_year = c(2023, 2023, 2024, 2024),
    casualty_severity = c("Serious", "Slight", "Fatal", "Serious"),
    casualty_adjusted_severity_serious = c(0.9, 0.1, NA, 0.8),
    casualty_adjusted_severity_slight = c(0.1, 0.9, NA, 0.2),
    stringsAsFactors = FALSE
  )

  res = summarise_adjusted_severities(df, by = "collision_year")
  expect_equal(nrow(res), 2)
  expect_equal(res$collision_year, c(2023, 2024))
})

test_that("summarise_adjusted_severities throws on missing severity column", {
  bad_df = data.frame(a = 1:5)
  expect_error(summarise_adjusted_severities(bad_df), "Input data must contain a severity column")
})
