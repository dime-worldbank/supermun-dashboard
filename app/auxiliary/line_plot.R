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
    
    static_plot <-
      communes %>%
      st_drop_geometry %>%
      filter(commune == com) %>%
      ggplot(
        aes_string(
          x = "year",
          y = var
        )
      ) +
      geom_line(
        color = "navy",
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
        color = "navy",
        size = 3
      ) +
      theme_minimal() +
      labs(y = unit, x = NULL) +
      ggtitle(title)
    
    ggplotly(
      static_plot, 
      tooltip = "text"
    )
    
  }
  