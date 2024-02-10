# fetch saved points file from google drive

path_to_json <- list.files("auth", pattern = ".json", full.names = TRUE)

googledrive::drive_deauth()

googledrive::drive_auth(
  path = path_to_json,
  scopes = "https://www.googleapis.com/auth/drive"
)

googledrive::drive_download(
  "https://drive.google.com/file/d/1Ava2svSNTJIQXhOXzZQcsym952ft7jUr/view?usp=drive_link",
  "data/temp/points.RDS",
  overwrite = TRUE
)
