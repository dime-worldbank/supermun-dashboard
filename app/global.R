# Packages ----------------------------------------------------------------

library(tidyverse)
library(plotly)
library(sf)
library(DT)

library(shiny)
library(shinyjs)
library(shinyBS)
library(shinythemes)
library(shinydashboard)
library(shinycssloaders)
library(shinybusy)
library(shinyWidgets)
library(bs4Dash)
library(fresh)
library(htmltools)

# Data ----------------------------------------------------------------------

source("auxiliary/params.R")
source("auxiliary/display_map.R")
source("auxiliary/line_plot.R")


communes <-
  read_rds(
    file.path(
      "data",
      "communes.rds"
    )
  ) %>%
  st_as_sf

map_data <-
  read_rds(
    file.path(
      "data",
      "map_data.rds"
    )
  )

data_table <-
  read_rds(
    file.path(
      "data",
      "data_table.rds"
    )
  )

indicators <-
  read_rds(
    file.path(
      "data",
      "indicators.rds"
    )
  )

st_crs(communes) <- "4326"
st_crs(regions) <- "4326"


indicator_list <-
  read_rds(
    file.path(
      "data",
      "indicator_list.rds"
    )
  )

ic <- indicator_list[1] %>% unname %>% unlist
sd <- indicator_list[2] %>% unname %>% unlist
