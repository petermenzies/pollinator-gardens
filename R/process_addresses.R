library(tidygeocoder)

process_addresses <- function(addresses) {
  
  incProgress(1/10, message = "authorizing")
  
  path_to_json <- list.files("auth", pattern = ".json", full.names = TRUE)
  
  gs4_auth(
    path = path_to_json,
    scopes = "https://www.googleapis.com/auth/spreadsheets"
  )
  
  googledrive::drive_auth(
    path = path_to_json,
    scopes = "https://www.googleapis.com/auth/drive"
  )
  
  incProgress(1/10, message = "parsing addreses")
  
  addresses$address <- paste(addresses$`Garden Street Address`, addresses$`Garden City, State, Zip Code`, sep = " ")
  
  # # for testing
  # addresses <- head(addresses, n = 10)
  
  incProgress(1/10, message = "geocoding addreses (takes a few min)")
  
  geocoded_addresses <- addresses |> 
    geocode(
      address,
      method = 'arcgis',
      lat = latitude,
      long = longitude
    )
  
  incProgress(5/10, message = "writing file locally")
  
  geocoded_addresses <- geocoded_addresses |> 
    select(
      address,
      latitude,
      longitude,
      tier = `Which garden tier are you applying for?`
    )
  
  updated_points <- geocoded_addresses |> 
    st_as_sf(
      coords = c("longitude", "latitude"),
      crs = 4326
    )
  
  incProgress(1/10, message = "writing file to cloud")
  
  write_rds(updated_points, "data/temp/points.RDS")

  googledrive::drive_update(
    "https://drive.google.com/file/d/1Ava2svSNTJIQXhOXzZQcsym952ft7jUr/view?usp=drive_link",
    "data/temp/points.RDS"
  )
  
  gs4_deauth()
  drive_deauth()
  
}
