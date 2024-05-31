line_plot <-
  function(data, com, variable) {
    
    var <-
      indicators %>%
      filter(Indicateur == variable) %>%
      pull(indicator)
    
    unit <-
      indicators %>%
      filter(Indicateur == variable) %>%
      pull(unit_french)

    title <-
      indicators %>%
      filter(Indicateur == variable) %>%
      pull(title_french)
    
    data <-
      communes %>%
      filter(commune == com)
    
    interval <-
      data %>%
      pull(year) %>%
      unique
    
    static_plot <-
      data %>%
      ggplot(
        aes_string(
          x = "year",
          y = var
        )
      ) +
      geom_line(
        color = info,
        size = 1,
      ) +
      geom_point(
        aes(
          text = paste0(
            year,
            "<br>",
            round(get(var), 1),
            " ",
            unit
          )
        ),
        color = info_dark,
        size = 3
      ) +
      scale_x_discrete(limits = interval) +
      theme_minimal() +
      labs(y = unit, x = NULL) +
      ggtitle(title)
    
    ggplotly(
      static_plot, 
      tooltip = "text"
    ) %>% 
      config( scrollZoom = TRUE,
               modeBarButtonsToRemove = c("toggleSpikelines", "hoverCompareCartesian"), # Removing specific buttons
               displaylogo = FALSE,
                locale = 'fr')
    
  }
  