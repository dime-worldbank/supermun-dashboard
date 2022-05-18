# Packages ----------------------------------------------------------------

library(tidyverse)
library(plotly)
library(sf)
library(DT)

library(shiny)
library(shinyjs)
library(shinyBS)
library(shinycssloaders)
library(shinybusy)
library(shinyWidgets)
library(bs4Dash)
library(fresh)

# Data ----------------------------------------------------------------------

communes <-
  read_rds(
    file.path(
      "data",
      "communes.rds"
    )
  )


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

indicator_list <-
  indicators$indicator

names(indicator_list) <- indicators$title_french


ic <- 
  indicators %>%
  filter(family == "ic") %>%
  select(indicator, Indicateur)