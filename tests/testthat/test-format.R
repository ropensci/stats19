context("test-format")

test_that("read_schema works", {
  t = stats19::read_schema()
  expect_equal(nrow(t), 969)
})
# test_that("format_stats19_2005_2014_ac works", {
  # ac = stats19::dl_stats19(years = c("2005", "2014"))
  # 103mb download!
  # t = stats19::format_stats19_2005_2014_ac(ac)

# })
