library(tidygeocoder)
library(tidyverse)
library(sf)

addresses <- read_csv("data/addresses.csv")

addresses$address <- paste(addresses$`Garden Street Address`, addresses$`Garden City, State, Zip Code`, sep = " ")

geocoded_addresses <- addresses |> 
  geocode(
    address,
    method = 'arcgis',
    lat = latitude,
    long = longitude
  )

geocoded_addresses <- geocoded_addresses |> 
  select(
    address,
    latitude,
    longitude,
    tier = `Which garden tier are you applying for?`
  )

points <- geocoded_addresses |> 
  st_as_sf(
    coords = c("longitude", "latitude"),
    crs = 4326
  )

write_rds(points, "data/temp/points.RDS")
