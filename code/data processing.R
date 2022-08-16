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
    NAME_2,
    NAME_3
  ) %>%
  st_simplify(
    preserveTopology = TRUE, 
    dTolerance = 1000
  )

## Calculate information for map -----------------------------------------------

panel %>%
  filter(year == year) %>%
  select(commune, region, all_of(indicator)) %>%
  mutate(
    n_country = get(indicator) %>% na.omit %>% length,
    rank_country = rank(get(indicator)),
    quintile = ntile(rank_country, 5)
  ) %>%
  group_by(region) %>%
  mutate(
    n_region = get(indicator) %>% na.omit %>% length,
    rank_region = rank(get(indicator))
  )

## SUPERMUN data ---------------------------------------------------------------
panel <-
  read_csv(
    here(
      "data",
      "raw",
      "SUPERMUN Panel.csv"
    )
  )

## Correspondence between map and data on commune name -------------------------
join <-
  read_csv(
    here(
      "data",
      "raw",
      "map_name_matching.csv"
    ),
    locale = readr::locale(encoding = "latin1")
  )

## Combine all data ------------------------------------------------------------
communes <-
  communes %>%
    left_join(join) %>%
    left_join(panel) %>%
    select(
      region = NAME_1,
      province = NAME_2,
      commune = NAME_3,
      year, 
      starts_with("value"),
      contains("points")
    ) 



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
      "data",
      "raw",
      "indicator_list.csv"
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
