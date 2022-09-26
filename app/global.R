# Packages ----------------------------------------------------------------

library(tidyverse)
library(plotly)
library(sf)
library(DT)
library(writexl)

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
  )

map <-
  read_rds(
    file.path(
      "data",
      "map.rds"
    )
  )

st_crs(map) <- "4326"

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

indicator_list <-
  read_rds(
    file.path(
      "data",
      "indicator_list.rds"
    )
  )

ic <- indicators %>% filter(family == "Capacité institutionelle") %>% pull(indicator)
names(ic) <- indicators %>% filter(family == "Capacité institutionelle") %>% pull(button)

sd <- indicators %>% filter(family == "Services publics") %>% pull(indicator)
names(sd) <- indicators %>% filter(family == "Services publics") %>% pull(button)
