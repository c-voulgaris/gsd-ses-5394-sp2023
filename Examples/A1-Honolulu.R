###

library(tidycensus)
library(tidyverse)
library(here)
library(sf)
library(leaflet)
library(tigris)

honolulu_tract_pop <- get_decennial(geography = "tract", 
                                 state = "HI",
                                 county = "003",
                                 variables = "P1_001N",
                                 year = 2020) |>
  rename(population = value) |>
  select(GEOID, population)

sum(honolulu_tract_pop$population)

honolulu_areas <- tracts(state = "HI",
                         county = "Honolulu") %>%
  select(GEOID, ALAND) %>%
  st_drop_geometry()

hh_vars = c(no_veh = "B08201_002",
            total_hhs = "B08201_001",
            hh_1person = "B08201_007",
            hh_2person = "B08201_013",
            hh_3person = "B08201_019",
            hh_4person_plus = "B08201_025",
            inc_lt_10k = "B19001_002",
            inc_btw_10k_15k = "B19001_003",
            inc_btw_15k_20k = "B19001_004",
            inc_btw_20k_25k = "B19001_005",
            inc_btw_25k_30k = "B19001_006",
            inc_btw_30k_35k = "B19001_007",
            inc_btw_35k_40k = "B19001_008",
            inc_btw_40k_45k = "B19001_009",
            inc_btw_45k_50k = "B19001_010",
            inc_btw_50k_60k = "B19001_011",
            inc_btw_60k_75k = "B19001_012",
            inc_btw_75k_100k = "B19001_013",
            inc_btw_100k_125k = "B19001_014",
            inc_btw_125k_150k = "B19001_015",
            inc_btw_150k_200k = "B19001_016",
            inc_gt_200k = "B19001_017")

honolulu_tract_hhs <- get_acs(geography = "tract",
                              state = "HI",
                              county = "003",
                              variables = hh_vars,
                              output = "wide", 
                              geometry = TRUE) %>%
  filter(!st_is_empty(geometry)) %>%
  filter(GEOID != "15003981200") %>% # small islands with no jobs or hhs 
  select(GEOID, ends_with("E", ignore.case = FALSE))

lehd_blocks <- read_csv('https://lehd.ces.census.gov/data/lodes/LODES7/hi/wac/hi_wac_S000_JT00_2019.csv.gz', show_col_types = FALSE) %>%
  rename(total_emp = C000) %>%
  mutate(basic_emp = CNS01+CNS02+CNS03+CNS04+CNS05+CNS06+CNS08+CNS09) %>%
  rename(retail_emp = CNS07) %>%
  mutate(service_emp = total_emp - basic_emp - retail_emp) %>%
  select(w_geocode, total_emp, basic_emp, retail_emp, service_emp)

lehd_tracts <- lehd_blocks %>%
  mutate(w_geocode = as.character(w_geocode)) %>%
  mutate(GEOID = substr(w_geocode, 1, 11)) %>%
  select(-w_geocode) %>%
  group_by(GEOID) %>%
  summarize(across(everything(), ~sum(.)))

honolulu_data <- honolulu_tract_hhs %>%
  left_join(honolulu_areas) %>%
  left_join(honolulu_tract_pop) %>%
  left_join(lehd_tracts) 

write_csv(st_drop_geometry(honolulu_data),
          file = here("Examples",
                      "data",
                      "hi_zone_data.csv")) 

st_write(honolulu_data,
         here("Examples",
              "data",
              "hi_zone_data.geojson"),
         delete_dsn = TRUE)

