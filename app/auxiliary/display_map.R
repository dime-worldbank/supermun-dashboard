display_map <-
  function(input_year, input_var) {
    
    data <-
      map_data[[input_var]] %>%
      filter(year == input_year) %>%
      right_join(map, by = "commune") %>%
      st_as_sf() %>%
      filter(!is.na(year)) %>% 
      mutate(
        value = var
      )
    
    title <-
      indicators %>%
      filter(indicator == input_var) %>%
      pull(title_french)
    
    unit <-
      indicators %>%
      filter(indicator == input_var) %>%
      pull(unit_french)
    
    # Function to wrap text based on a character limit per line
    wrap_text <- function(text, width = 40) {  
      paste(strwrap(text, width = width), collapse = "\n")
    }
    
    # Determine the direction of the colors based on input_var
    direction <- if (input_var %in% c("value_school_supplies")) -1 else 1
    
    static_map <- ggplot(data) +
      geom_sf(aes(fill = value, text = text)) +
      scale_fill_distiller(
        name = "Value",
        palette = "RdYlGn",  # Red to Green palette
        direction = direction,
        breaks = pretty_breaks(n = 5)(range(data$value, na.rm = TRUE))
      ) +
      labs(
        title = wrap_text(paste0("<b>", title, "</b>\n(", input_year, ")"), width = 40),
        fill = indicators$unit_french[indicators$indicator == input_var]
      ) +
      theme_void() +
      theme(plot.title = element_text(hjust = 0.5))
    
    ggplotly(
      static_map,
      tooltip = "text"
    ) %>%
      #hide_legend %>%
      style(
        #hoveron = "fill",
        line.color = toRGB("gray25"),
        traces = seq.int(2, 349)
      ) %>%
      config(
        scrollZoom = TRUE,
        modeBarButtonsToRemove = c("toggleSpikelines", "hoverCompareCartesian"), # Removing specific buttons
        toImageButtonOptions = list(
          filename = paste(title, "-", input_year),
          width = 1050,
          height =  675
        ),
        displaylogo = FALSE,
        locale = 'fr'
      ) %>%
      layout(
        margin = list(t = 75),
        xaxis = list(visible = FALSE),
        yaxis = list(visible = FALSE)
      )
    
  }