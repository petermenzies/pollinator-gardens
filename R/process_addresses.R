library(tidygeocoder)
library(tidyverse)
library(sf)

addresses <- read_csv("data/addresses.csv")

addressesWithoutCoords <- addresses |> 
  filter(is.na(latitude)) |> 
  select(-c(latitude, longitude))

geocodedAdresses <- addressesWithoutCoords |> 
  geocode(
    address,
    method = 'osm',
    lat = latitude,
    long = longitude
  )

allGeocodedAddreses <- addresses |> 
  rows_update(geocodedAdresses)

points <- st_as_sf(
  allGeocodedAddreses,
  coords = c("longitude", "latitude"),
  crs = 4326
  )

write_rds(points, "data/temp/points.RDS")
