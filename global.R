
library(shiny)
library(shinydashboard)
library(tidyverse)
library(leaflet)
library(sf)
library(shinycssloaders)

# pull from drive if temp points file is stale
if (Sys.time() - file.info("data/temp/points.RDS")[["ctime"]] > 10) {
  source("R/fetch_current_addresses.R")
}

points <- read_rds("data/temp/points.RDS")
