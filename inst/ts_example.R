# packages
library(stats19)
library(purrr)
library(dplyr)
library(sf)
library(lubridate)
library(ggplot2)
library(forecast)

# data
my_years = 2010:2018
accidents_10_18 = map_df(my_years, get_stats19, type = "accidents")
accidents_10_18 = format_sf(accidents_10_18, lonlat = TRUE)

# aggregating data
accidents_10_18_monthly = accidents_10_18 %>%
  st_drop_geometry() %>%
  mutate(date_month = round_date(date, unit = "month")) %>%
  group_by(date_month) %>%
  summarize(n = n()) %>%
  ungroup()

ggplot(accidents_10_18_monthly, aes(x = date_month, y = n)) +
  geom_line()

# a little bit of cleaning cause the first obs and the last one seems super weird
head(accidents_10_18_monthly)
tail(accidents_10_18_monthly)

accidents_10_18_monthly = accidents_10_18_monthly %>%
  slice(-c(1, nrow(.)))

ggplot(accidents_10_18_monthly, aes(x = date_month, y = n)) +
  geom_line()

# let's try the easiest and stupidest forecasting ever. I exclude 2018 data
accidents_10_17_monthly = accidents_10_18_monthly %>%
  filter(date_month < ymd("2018-01-01"))

accidents_10_17_ts = ts(accidents_10_17_monthly$n, frequency = 12, start = c(2010, 2))
accidents_10_17_ts

accidents_model_montly = auto.arima(accidents_10_17_ts)
accidents_model_montly

# forecasting
forecasting_18_monthly = forecast(accidents_10_17_ts, h = 12)
forecasting_18_monthly

forecasting_18_monthly_dataframe = as_tibble(forecasting_18_monthly) %>%
  mutate(date_month = seq(as.POSIXct("2018-01-01 00:00:00"), by = "month", length.out = 12))

# plot forecasting
ggplot(forecasting_18_monthly_dataframe, aes(x = date_month)) +
  geom_line(aes(y = n), accidents_10_18_monthly, size = 1.05) +
  geom_line(aes(y = `Point Forecast`), col = "blue", size = 1.05) +
  geom_ribbon(aes(ymin = `Lo 95`, ymax = `Hi 95`), alpha = 0.33, fill = "blue")
