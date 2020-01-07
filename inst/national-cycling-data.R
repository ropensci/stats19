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


# add imd scores ----------------------------------------------------------

u = "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833970/File_1_-_IMD2019_Index_of_Multiple_Deprivation.xlsx"
download.file(u, "File_1_-_IMD2019_Index_of_Multiple_Deprivation.xlsx")
imd_scores = readxl::read_excel("File_1_-_IMD2019_Index_of_Multiple_Deprivation.xlsx", sheet = 2)
imd_scores_min = imd_scores %>%
  select(geo_code = `LSOA code (2011)`, `Index of Multiple Deprivation (IMD) Decile`)
lsoas = sf::read_sf("https://github.com/npct/pct-outputs-national/raw/master/commute/lsoa/z_all.geojson")
summary(lsoas$geo_code %in% imd_scores$`LSOA code (2011)`)
lsoas_min = lsoas %>% select(geo_code, lad_name, all, bicycle, car_driver)
lsoas_imd = left_join(lsoas_min, imd_scores_min)
sf::write_sf(lsoas_imd, "lsoa_zones_imd_2019.geojson")
piggyback::pb_upload("lsoa_zones_imd_2019.geojson")
lsoas_imd_min = lsoas_imd %>% select(imd_decile_2019 = `Index of Multiple Deprivation (IMD) Decile`, lad_name)
plot(lsoas_imd_min[lsoas_imd_min$lad_name == "Leeds", ])

cav_sf = cav_min %>%
  filter(!is.na(latitude)) %>%
  sf::st_as_sf(., coords = c("longitude", "latitude"), crs = 4326)
plot(cav_sf[1:999, "speed_limit"])

cav_imd = sf::st_join(cav_sf, lsoas_imd_min)
names(cav_imd)
plot(cav_imd[1:999, "lad_name"])
plot(cav_imd[1:999, "imd_decile_2019"])

cav_imd_df = cav_imd %>% sf::st_drop_geometry()
readr::write_csv(cav_imd_df, "casualties_cyclist_other_2_vehicles_imd.csv")
piggyback::pb_upload("casualties_cyclist_other_2_vehicles_imd.csv")
piggyback::pb_download_url("casualties_cyclist_other_2_vehicles_imd.csv")
