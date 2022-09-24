library(tidyverse)
library(here)
library(sf)

# Regions map ------------------------------------------------------------------

regions <-
  read_rds(
    here(
      "data",
      "raw",
      "BFA_adm1.rds"
    )
  ) %>%
  st_as_sf() %>%
  transmute(
    region = NAME_1
  ) %>%
  st_simplify(
    preserveTopology = TRUE, 
    dTolerance = 1000
  )

regions %>%
  write_rds(
    here(
      "app",
      "data",
      "regions.rds"
    )
  )

# Communes data ----------------------------------------------------------------

## Communes map ----------------------------------------------------------------
communes <-
  read_rds(
    here(
      "data",
      "raw",
      "BFA_adm3.rds"
    )
  ) %>%
  st_as_sf() %>%
  select(
    NAME_1,
    province = NAME_2,
    NAME_3
  ) %>%
  st_simplify(
    preserveTopology = TRUE, 
    dTolerance = 1000
  ) %>%
  left_join(join) %>%
  select(-starts_with("NAME"))

# SUPERMUN data ---------------------------------------------------------------
panel <-
  read_csv(
    here(
      "data",
      "raw",
      "SUPERMUN Panel.csv"
    )
  ) %>%
  select(-`...1`) 

## Calculate information for map -----------------------------------------------

panel_long <-
  panel %>%
  pivot_longer(
    cols = 4:ncol(.),
    names_to = "indicator"
  ) %>%
  group_by(year, indicator) %>%
  mutate(
    n_country = n_distinct(commune),
    rank_country = rank(value),
    quintile = ntile(rank_country, 5)
  ) %>%
  group_by(year, indicator, region) %>%
  mutate(
    n_region = n_distinct(commune),
    rank_region = rank(value)
  )

## Correspondence between map and data on commune name -------------------------
join <-
  read_csv(
    here(
      "documentation",
      "Commune Concordance for Shape Files 2019-02-01.csv"
    ),
    locale = readr::locale(encoding = "latin1")
  )

## Combine all data ------------------------------------------------------------
communes <-
  communes  %>%
  left_join(panel)

communes %>%
  write_rds(
    here(
      "app",
      "data",
      "communes.rds"
    )
  )


# List of indicators -----------------------------------------------------------
indicators <-
  read_csv(
    here(
      "documentation",
      "SUPERMUN Indicator List.csv"
    ),
    locale = readr::locale(encoding = "latin1")
  ) %>%
  arrange(title_french) %>%
  mutate(
    Indicateur = paste0(
      title_french,
      " (",
      unit_french,
      ")"
    )
  )

indicators %>%
  write_rds(
    here(
      "app",
      "data",
      "indicators.rds"
    )
  )
