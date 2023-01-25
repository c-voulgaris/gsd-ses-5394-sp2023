# Load libraries
library(tigris)
library(sf)
library(osmdata)
library(tidyverse)
library(units)
library(here)
library(leaflet)
library(htmlwidgets)

# Load TAZs
okc_areas <- tracts(state = "OK",
                         county = c("Canadian",
                                    "cleveland",
                                    "Grady",
                                    "Lincoln",
                                    "Logan",
                                    "McClain",
                                    "Oklahoma")) %>%
  select(GEOID)

map <- okc_areas %>%
  st_transform("WGS84") %>%
  leaflet() %>%
  addTiles() %>%
  addPolygons(popup = ~GEOID,
              weight = 1,
              opacity = 1,
              highlightOptions =
                highlightOptions(fillColor = "red"))

saveWidget(map, file = here('Examples/okc_boundaries.html'))

# List included roads
included_roads <- c(primary = "S1100",
                    secondary = "S1200",
                    unpaved = "S1500",
                    ramp = "S1630",
                    service = "S1640",
                    local = "S1400")

# Load street network



okc_roads <- roads(state = "OK",
                   county = c("Canadian",
                              "cleveland",
                              "Grady",
                              "Lincoln",
                              "Logan",
                              "McClain",
                              "Oklahoma")) %>%
  filter(MTFCC %in% included_roads) %>%
  mutate(veh_speed = case_when(MTFCC == "S1100" ~ 60, # primary
                               MTFCC == "S1200" ~ 40, # secondary
                               MTFCC == "S1500" ~ 20, # unpaved
                               MTFCC == "S1630" ~ 40, # ramp
                               MTFCC == "S1640" ~ 40, # service road
                               MTFCC == "S1400" ~ 20)) %>% # local road
  mutate(veh_speed = set_units(veh_speed, "mi/h")) %>%
  mutate(seg_length = set_units(st_length(.), "mi")) %>%
  mutate(travel_time = set_units(seg_length / veh_speed, "min"))

st_write(okc_roads,
         here("Examples",
              "data",
              "okc_roads.geojson"),
         delete_dsn = TRUE)


st_write(okc_areas,
         here("Examples",
              "data",
              "okc_areas.geojson"),
         delete_dsn = TRUE)
