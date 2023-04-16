# Uncomment and run the next line to install pacman in your computer
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
    "data.table",
    "here",
    "sp",
    "renv"
  )

pacman::p_load(
  packages,
  character.only = TRUE
)