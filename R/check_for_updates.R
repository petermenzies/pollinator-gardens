# check for new rows added to the sheet
library(googlesheets4)

check_for_updates <- function() {
  
  path_to_json <- list.files("auth", pattern = ".json", full.names = TRUE)
  
  gs4_auth(
    path = path_to_json,
    scopes = "https://www.googleapis.com/auth/spreadsheets"
  )
  
  addresses <- read_sheet("https://docs.google.com/spreadsheets/d/18kMrQr3CWWrZ_i7YJ13YPayODebB9XURLNUECp3sfA8/edit#gid=753809200")
  assign("addresses", addresses, envir = .GlobalEnv)
  
  current_rows <- nrow(points)
  sheet_rows <- nrow(addresses)
  
  new_rows <- sheet_rows > current_rows
  
  return(new_rows)
}

