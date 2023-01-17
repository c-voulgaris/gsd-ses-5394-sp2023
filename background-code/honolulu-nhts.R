library(tidyverse)
library(archive)
library(tidycensus)

# Download NHTS data


url <- "https://nhts.ornl.gov/assets/2016/download/csv.zip"

hhs <- read_csv(archive_read(url, file = "hhpub.csv"), 
                col_types = cols()) 

honolulu_nhts <- hhs |>
  filter(HHSTATE == "HI" & MSASIZE == "03")

buffalo_nhts <- hhs |>
  filter(HH_CBSA == "15380")


houston_nhts <- hhs |>
  filter(HH_CBSA == "26420")

honolulu_tracts <- get_decennial(geography = "tract", 
                                 state = "HI",
                                 county = "003",
                                 variables = "P1_001N",
                                 year = 2020)

sum(honolulu_tracts$value)


buffalo_tracts <- get_decennial(geography = "tract", 
                                 state = "NY",
                                 county = c("Erie", "Niagara"),
                                 variables = "P1_001N",
                                 year = 2020)

sum(buffalo_tracts$value)


houston_tracts <- get_decennial(geography = "tract", 
                                state = "TX",
                                county = c("Austin", 
                                           "Brazoria",
                                           "Chambers",
                                           "Fort Bend",
                                           "Galveston",
                                           "201",
                                           "Liberty",
                                           "Montgomery",
                                           "Waller"),
                                variables = "P1_001N",
                                year = 2020)

sum(houston_tracts$value)

jacksonville_tracts <- get_decennial(geography = "tract", 
                                state = "FL",
                                county = c("Duval", 
                                           "St. Johns",
                                           "Clay",
                                           "Baker",
                                           "Nassau"),
                                variables = "P1_001N",
                                year = 2020)

sum(jacksonville_tracts$value)

las_vegas_tracts <- get_decennial(geography = "tract", 
                                     state = "NV",
                                     county = c("Clark"),
                                     variables = "P1_001N",
                                     year = 2020)

sum(las_vegas_tracts$value)

okc_tracts <- get_decennial(geography = "tract", 
                                     state = "OK",
                                     county = c("Canadian", 
                                                "Cleveland",
                                                "Grady",
                                                "Lincoln",
                                                "Logan",
                                                "McClain",
                                                "Oklahoma"),
                                     variables = "P1_001N",
                                     year = 2020)

sum(okc_tracts$value)


rochester_tracts <- get_decennial(geography = "tract", 
                            state = "NY",
                            county = c("Livingston", 
                                       "Monroe",
                                       "Ontario",
                                       "Orleans",
                                       "Wayne",
                                       "Yates"),
                            variables = "P1_001N",
                            year = 2020)

sum(rochester_tracts$value)
