# packages
library(sf)
library(osmdata)
library(tmap)
library(dplyr)
library(stats19)
library(igraph)
library(purrr)

# download geofabric data for IOW
iow_geofabric = readRDS(url("https://github.com/ropensci/stats19/releases/download/1.1.0/roads_key.Rds")) %>%
  st_transform(crs = 27700)
iow_bb = getbb("Isle of Wight, South East, England", format_out = "sf_polygon", featuretype = "state") %>%
  st_transform(crs = 27700)

# filter only certain types of highways
key_roads_text = "primary|secondary|tertiary"
iow_geofabric = iow_geofabric %>%
  filter(grepl(pattern = key_roads_text, x = fclass))

# fix link labels
iow_geofabric = iow_geofabric %>%
  mutate(highway = sub("_link", "", fclass))

# plot
tm_shape(iow_bb, ext = 1.05) +
  tm_borders() +
  tm_shape(iow_geofabric) +
  tm_lines(
    col = "highway",
    lwd = 2,
    palette = "Paired",
    title.col = "Highway Type",
    labels = c("Primary Roads", "Secondary Roads", "Tertiary Roads"),
  ) +
  tm_compass(type = "8star", position = c("left", "top")) +
  tm_scale_bar()

# download car crashes data and transform in sf
car_collisions_2022 = get_stats19(year = 2018)
car_collisions_2022 = car_collisions_2022 %>%
  filter(!is.na(longitude), !is.na(latitude)) %>% # NA in coordinates
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%
  st_transform(crs = 27700)

# filter car crashes in IOW
car_collisions_2022_iow = car_collisions_2022[iow_bb, ]

# plot
tm_shape(iow_bb, ext = 1.05) +
  tm_borders() +
  tm_shape(iow_geofabric) +
  tm_lines(
    col = "highway",
    lwd = 2,
    palette = "Paired",
    title.col = "Highway Type",
    labels = c("Primary Roads", "Secondary Roads", "Tertiary Roads"),
  ) +
  tm_shape(car_collisions_2022_iow) +
  tm_dots(size = 0.075) +
  tm_compass(type = "8star", position = c("left", "top")) +
  tm_scale_bar()


# Exclude car crashes far from all streets
car_collisions_2022_iow = car_collisions_2022_iow[iow_geofabric,
  op = st_is_within_distance, dist = units::set_units(50, "m")
]

# plot
tm_shape(iow_bb, ext = 1.05) +
  tm_borders() +
  tm_shape(iow_geofabric) +
  tm_lines(
    col = "highway",
    lwd = 2,
    palette = "Paired",
    title.col = "Highway Type",
    labels = c("Primary Roads", "Secondary Roads", "Tertiary Roads"),
  ) +
  tm_shape(car_collisions_2022_iow) +
  tm_dots(size = 0.075) +
  tm_compass(type = "8star", position = c("left", "top")) +
  tm_scale_bar()

# match each car crashes with its nearest highway
ID_nearest_highway = st_nearest_feature(car_collisions_2022_iow, iow_geofabric)
number_of_car_collisions = factor(ID_nearest_highway, levels = seq_len(nrow(iow_geofabric))) %>%
  table() %>% as.numeric()

iow_geofabric = iow_geofabric %>%
  mutate(number_of_car_collisions = as.character(number_of_car_collisions))

# plot
tm_shape(iow_bb) +
  tm_borders() +
  tm_shape(iow_geofabric) +
  tm_lines(
    col = "number_of_car_collisions",
    lwd = 4,
    palette = "-RdYlGn",
    legend.col.show = FALSE
  ) +
  tm_shape(car_collisions_2022_iow) +
  tm_dots(size = 0.075)

# problems...

# spatial smoothing (like moving average filtering)
iow_graph = st_touches(iow_geofabric) %>% graph.adjlist()
iow_graph_ego = ego(iow_graph, order = 2)

spatial_smoothing = function(ID) {
  mean(number_of_car_collisions[iow_graph_ego[[ID]]])
}

iow_geofabric = iow_geofabric %>%
  mutate(number_of_car_collisions_smooth = map_dbl(seq_len(nrow(.)), spatial_smoothing))

# plot
tm_shape(iow_bb, ext = 1.05) +
  tm_borders() +
  tm_shape(iow_geofabric) +
  tm_lines(
    col = "number_of_car_collisions_smooth",
    lwd = 2.5,
    palette = "-RdYlGn",
    title.col = "Smoothed number of car crashes in 2022"
  ) +
  tm_shape(car_collisions_2022_iow) +
  tm_dots(size = 0.075) +
  tm_compass(type = "8star", position = c("left", "top")) +
  tm_scale_bar()

# works. let's tune it!
iow_graph_ego = ego(iow_graph, order = 4)

iow_geofabric = iow_geofabric %>%
  mutate(number_of_car_collisions_smooth = map_dbl(seq_len(nrow(.)), spatial_smoothing))

# plot
tm_shape(iow_bb, ext = 1.05) +
  tm_borders() +
  tm_shape(iow_geofabric) +
  tm_lines(
    col = "number_of_car_collisions_smooth",
    lwd = 2.5,
    palette = "-RdYlGn",
    title.col = "Smoothed number of car crashes in 2022"
  ) +
  tm_shape(car_collisions_2022_iow) +
  tm_dots(size = 0.075) +
  tm_compass(type = "8star", position = c("left", "top")) +
  tm_scale_bar()

# still some problems, spatial distance on a network?
# problems, again...

# higher order?
iow_graph_ego = ego(iow_graph, order = 50)

iow_geofabric = iow_geofabric %>%
  mutate(number_of_car_collisions_smooth = map_dbl(seq_len(nrow(.)), spatial_smoothing))

# plot
tm_shape(iow_bb, ext = 1.05) +
  tm_borders() +
  tm_shape(iow_geofabric) +
  tm_lines(
    col = "number_of_car_collisions_smooth",
    lwd = 2.5,
    palette = "-RdYlGn",
    title.col = "Smoothed number of car crashes in 2022"
  ) +
  tm_shape(car_collisions_2022_iow) +
  tm_dots(size = 0.075) +
  tm_compass(type = "8star", position = c("left", "top")) +
  tm_scale_bar()

# other problems.......


