# Aim: get national cycling data

library(stats19)
library(tidyverse)

a = get_stats19(2018, "ac")
c = get_stats19(2018, "ca")
v = get_stats19(2018, "ve")
table(c$casualty_type)

cc = c %>% filter(casualty_type == "Cyclist")
ca = inner_join(cc, a)
cav = inner_join(ca, v)

cav
names(cav)

cav_min = cav %>% select(accident_index, vehicle_reference, casualty_reference, time, date, longitude, latitude, local_authority_district, police_force, day_of_week, road_type, speed_limit, sex_of_casualty, age_of_casualty, casualty_severity, casualty_home_area_type, casualty_imd_decile, vehicle_type, sex_of_driver, age_of_driver, engine_capacity_cc, driver_imd_decile, driver_home_area_type)

readr::write_csv(cav_min, "cav_min.csv")
piggyback::pb_upload("cav_min.csv")
piggyback::pb_download_url("cav_min.csv")
