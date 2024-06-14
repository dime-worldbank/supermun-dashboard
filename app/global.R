# Packages ----------------------------------------------------------------

library(tidyverse)
library(plotly)
library(sf)
library(writexl)
library(scales)
library(shiny)
library(shinyjs)
library(shinyBS)
library(shinythemes)
library(shinydashboard)
library(shinycssloaders)
library(shinybusy)
library(shinyWidgets)
library(htmltools)


library(DT)
library(data.table)

# United theme ---------------------------------------------------------------

info <- "#17a2b8"
info_dark <- "#148a9c"
dark <- "#772953"
warning <- "#efb73e"
success <- "#38b44a"
secondary <- "#aea79f"
light <- "#e9ecef"
primary <- "#e95420"
      

# Auxiliary functions -------------------------------------------------------

source("auxiliary/params.R")
source("auxiliary/display_map.R")
source("auxiliary/line_plot.R")

# Data ----------------------------------------------------------------------

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

ic <- indicators %>% filter(family == "Capacité institutionnelle") %>% pull(indicator)
names(ic) <- indicators %>% filter(family == "Capacité institutionnelle") %>% pull(button)

sd <- indicators %>% filter(family == "Services publics") %>% pull(indicator)
names(sd) <- indicators %>% filter(family == "Services publics") %>% pull(button)
