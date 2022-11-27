# Aim: test 2015 data
remotes::install_github("ropensci/stats19")
library(stats19)
# ?get_stats19
crashes_2017 = get_stats19(2017, type = "accident")
crashes_2015 = get_stats19(2015, type = "accident")
