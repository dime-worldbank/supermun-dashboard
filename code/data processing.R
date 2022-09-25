library(tidyverse)
library(here)
library(sf)

## Correspondence between map and data on commune name -------------------------

join <-
  read_csv(
    here(
      "documentation",
      "Commune Concordance for Shape Files 2019-02-01.csv"
    ),
    locale = readr::locale(encoding = "latin1")
  )

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

## Combine all data ------------------------------------------------------------
communes <-
  communes  %>%
  right_join(panel) %>%
  arrange(commune)

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

# Table to be displayed --------------------------------------------------------

table <-
  communes %>%
  st_drop_geometry %>%
  select(
    year,
    commune,
    starts_with("value"),
    starts_with("total_points")
  ) %>%
  pivot_longer(
    cols = c(starts_with("value"), starts_with("total")),
    names_to = "indicator"
  ) %>%
  mutate(value = round(value, 1)) %>%
  arrange(year) %>%
  pivot_wider(
    names_from = year
  ) %>%
  inner_join(
    indicators %>%
      select(
        indicator, 
        Indicateur,
        `Groupe d'indicateur` = family
      )
  ) %>%
  select(-indicator) %>%
  relocate(
    `Groupe d'indicateur`,
    Indicateur
  ) %>%
  arrange(`Groupe d'indicateur`)

table %>%
  write_rds(
    here(
      "app",
      "data",
      "data_table.rds"
    )
  )
