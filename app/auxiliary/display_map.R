display_map <-
  function(input_year, input_var) {
    
    data <-
      map_data[[input_var]] %>%
      filter(year == input_year) %>%
      right_join(map, by = "commune") %>%
      st_as_sf
    
    title <-
      indicators %>%
      filter(indicator == input_var) %>%
      pull(title_french)
    
    unit <-
      indicators %>%
      filter(indicator == input_var) %>%
      pull(unit_french)
    
    
    static_map <-
      ggplot() +
      geom_sf(
        data = data,
        aes(
          fill = label,
          text = text
          #color = commune
        )
      ) +
      labs(
        fill = unit,
        title = paste0("<b>", title, " (", input_year, ")</b>")
      ) +
      theme_void() +
      scale_fill_manual(
        values = c(
          "#FF6961",
          "#FFB54C",
          "#F8D66D",
          "#8CD47E",
          "#7ABD7E"
        ),
        na.value = "white"
      ) +
      theme(
        plot.title = element_text(hjust = 0.5)
      )
    
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
        modeBarButtonsToRemove = plotly_remove_buttons,
        toImageButtonOptions = list(
          filename = paste(title, "-", input_year),
          width = 1050,
          height =  675
        )
      ) %>%
      layout(
        margin = list(t = 75),
        xaxis = list(visible = FALSE),
        yaxis = list(visible = FALSE)
      )
    
  }