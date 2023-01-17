#

library(sf)
library(tidyverse)
library(tigris)

all_msas <- tigris::core_based_statistical_areas() %>%
  filter(LSAD == "M1") %>%
  st_centroid()

# from 2022 - criteria were: 
#  At least 100 households in 2017 NHTS
#  Only within one state
#  Has a Tier 1 transit agency (with available GTFS feed)

possible_msa_names <- c("Baltimore-Columbia-Towson, MD",
                        "Buffalo-Cheektowaga, NY",
                        "Cleveland-Elyria, OH",
                        "Columbus, OH",
                        "Denver-Aurora-Lakewood, CO",
                        "Houston-The Woodlands-Sugar Land, TX",
                        "Indianapolis-Carmel-Anderson, IN",
                        "Jacksonville, FL",
                        "Las Vegas-Henderson-Paradise, NV",
                        "Oklahoma City, OK",
                        "Pittsburgh, PA",
                        "Rochester, NY",
                        "Sacramento-Roseville-Folsom, CA",
                        "Salt Lake City, UT",
                        "San Jose-Sunnyvale-Santa Clara, CA")

possible_msas <- all_msas %>%
  filter(NAME %in% possible_msa_names)


# Maybe filter by distance to nearest other MSA?
dists <- sf::st_distance(all_msas, possible_msas) %>%
  as_tibble() %>%
  setNames(possible_msa_names) %>%
  mutate_all(as.numeric) %>%
  mutate(from_msa = all_msas$NAME) %>%
  pivot_longer(-from_msa, names_to = "to_msa") %>%
  filter(value > 0) %>%
  arrange(desc(to_msa), desc(value)) %>%
  group_by(to_msa) %>%
  summarise(closest_msa = last(from_msa),
            dist = last(value) / 1609)
  


