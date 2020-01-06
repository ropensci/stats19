# Aim: get national cycling data

library(stats19)
library(tidyverse)

a = get_stats19(2018, "ac")
c = get_stats19(2018, "ca")
v = get_stats19(2018, "ve")
table(c$casualty_type)

cc = c %>% filter(casualty_type == "Cyclist")
ca = inner_join(cc, a)
nrow(cc) == nrow(ca) # one 'accident' per casualty
cav = inner_join(ca, v)  # matches the pedal cycle
nrow(cav) == nrow(ca)
table(cav$vehicle_type) # they are all pedal cyclists!

cav2 = inner_join(ca, v, by = "accident_index")
nrow(cav2) == nrow(ca)
nrow(cav2) / nrow(ca) # on average 2 vehicles per casualty
summary(cav2$number_of_vehicles)
table(cav2$number_of_vehicles) / nrow(cav2) # 92% of cyclist casualties involved 2 vehicles, 2% 1 vehicle, 4% 3 vehicles

# focus only on crashes involving 2 vehicles:
casualties_cyclist_other_2_vehicles_no_cycle_vehicle = cav2 %>%
  filter(number_of_vehicles == 2) %>%
  filter(vehicle_type != "Pedal cycle")
nrow(casualties_cyclist_other_2_vehicles_no_cycle_vehicle) / nrow(cav) # 91% of of crashes (implying that 1% of cycle crashes were cycle-cycle)

casualties_cyclist_other_2_vehicles = cav2 %>%
  filter(number_of_vehicles == 2) %>%
  filter(vehicle_reference.x != vehicle_reference.y)
casualties_cyclist_other_2_vehicles %>% select(age_of_casualty, age_of_driver, casualty_imd_decile, driver_imd_decile, vehicle_type)
nrow(casualties_cyclist_other_2_vehicles) / nrow(cav) # 92% of cyclist crashes
table(casualties_cyclist_other_2_vehicles$vehicle_type) # majority are cars
prop.table(.Last.value) # 80% of other vehicles were car

casualties_cyclist_other_2_vehicles
names(casualties_cyclist_other_2_vehicles)

cav_min = casualties_cyclist_other_2_vehicles %>%
  select(accident_index, casualty_reference, time, date, longitude, latitude, local_authority_district, police_force, day_of_week, road_type, speed_limit, sex_of_casualty, age_of_casualty, casualty_severity, casualty_home_area_type, casualty_imd_decile, vehicle_type, sex_of_driver, age_of_driver, engine_capacity_cc, driver_imd_decile, driver_home_area_type)
table(cav_min$vehicle_type)
cav_min
cav_min %>% select(age_of_casualty, age_of_driver, casualty_imd_decile, driver_imd_decile, vehicle_type)

readr::write_csv(cav_min, "casualties_cyclist_other_2_vehicles.csv")
piggyback::pb_upload("casualties_cyclist_other_2_vehicles.csv")
piggyback::pb_download_url("casualties_cyclist_other_2_vehicles.csv")
