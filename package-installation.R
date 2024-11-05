# Code to install required packages


# needed packages
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

# Install and load the pacman package if not already installed
if (!require(pacman)) install.packages("pacman")
library(pacman)

# Function to load packages with an option to install
load_packages <- function(packages, install_if_missing = TRUE) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE) && install_if_missing) {
      pacman::p_install(pkg, character.only = TRUE)
      library(pkg, character.only = TRUE)
    }
  }
}

# Call the function with install_if_missing set to FALSE by default
load_packages(packages)
