display_map <-
  function(data, input_year, input_var, title) {
    
    static_map <-
      ggplot() +
      geom_sf(
        data = data,
        aes(
          text = text,
          fill = fill,
          color = commune
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
      style(
        hoveron = "fill",
        line.color = toRGB("gray25"),
        traces = seq.int(2, 349)
      ) %>%
      hide_legend %>%
      config(
        modeBarButtonsToRemove = plotly_remove_buttons,
        toImageButtonOptions = list(
          filename = paste(title, "-", input_year),
          width = 1050,
          height =  675
        )
      ) %>%
      layout(
        margin = list(t = 75, b = 180, r = 20, l = 20),
        xaxis = list(visible = FALSE),
        yaxis = list(visible = FALSE),
        annotations =
          list(
            x = -1.5,
            y = 9,
            text = HTML(
              paste(
                str_wrap(
                  paste(
                    "<b>Définition:</b>",
                    indicators %>%
                      filter(indicator == input_var) %>%
                      pull(definition_french)
                  ),
                  note_chars
                )
              )
            ),
            showarrow = F,
            font = list(size = note_size)
          )
      )

  }