# Load necessary packages ------------------------------------------------------

# Uncomment and run the next line to install pacman in your computer
# install.packages("pacman")

packages <-
  c(
    "tidyverse",
    "here",
    "sf"
  )

pacman::p_load(
  packages,
  character.only = TRUE
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
    ),
    subfamily = str_to_sentence(subfamily)
  )

indicators %>%
  write_rds(
    here(
      "app",
      "data",
      "indicators.rds"
    )
  )

## Combine all data ------------------------------------------------------------

communes <-
  communes  %>%
  left_join(panel) %>%
  arrange(commune) %>%
  select(province, region, commune, year, indicators$indicator) %>%
  mutate(
    across(
      c(province, region, commune),
      ~ str_to_title(.)
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
  filter(!is.na(value)) %>%
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

# List of indicators -----------------------------------------------------------
ic <- 
  indicators %>%
  filter(family == "Capacité institutionelle") %>%
  pull(indicator)

names(ic) <- 
  indicators %>%
  filter(family == "Capacité institutionelle") %>%
  pull(title_french)

sd <- 
  indicators %>%
  filter(family == "Services publics") %>%
  pull(indicator)

names(sd) <- 
  indicators %>%
  filter(family == "Services publics") %>%
  pull(title_french)

indicator_list <-
  list(
    "Capacité institutionelle" = ic,
    "Services publics" = sd
  )

indicator_list %>%
  write_rds(
    here(
      "app",
      "data",
      "indicator_list.rds"
    )
  )

# Map data ---------------------------------------------------------------------

communes %>%
  select(commune, geometry) %>%
  unique %>%
  write_rds(
    here(
      "app",
      "data",
      "map.rds"
    )
  )

communes <-
  communes %>%
  st_drop_geometry

quintiles <- 
  function(var) {
    
    title <-
      indicators %>%
      filter(indicator == var) %>%
      pull(title_french)
    
    unit <-
      indicators %>%
      filter(indicator == var) %>%
      pull(unit_french)
    
    data <-
      communes %>%
      select(year, region, commune, province, all_of(var)) %>%
      group_by(year, region) %>%
      mutate(
        var = get(var), 
        n_region = var %>% na.omit %>% length,
        rank_region = rank(var)
      ) %>%
      group_by(year) %>%
      mutate(
        quintile = ntile(var, 5),
        var = round(var, 1),
        n_country = var %>% na.omit %>% length,
        rank_country = rank(var)
      ) %>%
      group_by(year, quintile) %>%
      mutate(
        label = paste(min(var), "-", max(var)),
        label = ifelse(is.na(var), NA, label)
      ) %>%
      ungroup %>%
      mutate(
        text = paste0(
          "<b>Commune de ", commune, "</b><br><br>",
          "<b>Province:</b> ", province, "<br>",
          "<b>Région:</b> ", region, "<br><br>",
          "<b>", title, " (", year, "): </b>",
          var, " ",
          unit, "<br><br>",
          "<b>", rank_country, "ème </b>sur ", n_country, " communes de Burkina Faso <br>",
          "<b>", rank_region, "ème </b>sur ", n_region, " communes de ", region
        ),
        text = ifelse(is.na(var), NA, text)
      ) %>%
      select(year, label, text, commune)
      
  }

map_data <-
  map(indicators$indicator, quintiles)

names(map_data) <- indicators$indicator

map_data %>%
  write_rds(
    here(
      "app",
      "data",
      "map_data.rds"
    )
  )

communes %>%
  write_rds(
    here(
      "app",
      "data",
      "communes.rds"
    )
  )

