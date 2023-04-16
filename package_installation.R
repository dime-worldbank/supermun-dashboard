install.packages("pacman")
packages <-
  c(
    "tidyverse",
    "plotly",
    "sf",
    "writexl",
    "shiny",
    "shinyjs",
    "shinyBS",
    "shinythemes",
    "shinydashboard",
    "shinycssloaders",
    "shinybusy",
    "shinyWidgets",
    "htmltools",
    "DT",
    "data.table"
  )
pacman::p_load(packages, character.only = TRUE)