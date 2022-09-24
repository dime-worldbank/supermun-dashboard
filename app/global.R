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


communes <-
  read_rds(
    file.path(
      "data",
      "communes.rds"
    )
  ) %>%
  st_as_sf


regions <-
  read_rds(
    file.path(
      "data",
      "regions.rds"
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
  indicators$indicator

names(indicator_list) <- indicators$title_french

ic <- 
  indicators %>% 
  filter(family == "ic") %>%
  pull(indicator) %>%
  setNames(
    indicators %>% 
      filter(family == "ic") %>%
      pull(title_french)
  )

families <- 
  indicators %>%
  filter(family == "ic") %>%
  select(indicator, Indicateur)
