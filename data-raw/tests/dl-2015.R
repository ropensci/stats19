# Aim: test 2015 data
remotes::install_github("ropensci/stats19")
library(stats19)
# ?get_stats19
crashes_2022 = get_stats19(2022, type = "collision")
crashes_2015 = get_stats19(2015, type = "collision")
