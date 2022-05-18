# Server ################################################################################

  server <- function(input, output, session) {
    
## Commune profile -------------------------------------------------------------
    
### Institutional capacity table -----------------------------------------------
    
    output$profile_title <-
      renderText(paste("Commune de", input$profile_commune))
    
    output$table <-
      renderTable(
        communes %>%
          st_drop_geometry %>%
          filter(commune == input$profile_commune) %>%
          select(
            year,
            starts_with("value")
          ) %>%
          pivot_longer(
            cols = starts_with("value"),
            names_to = "indicator"
          ) %>%
          pivot_wider(
            names_from = year
          ) %>%
          inner_join(ic) %>%
          select(
            Indicateur,
            starts_with("20")
          )
      )

### Selected graph -------------------------------------------------------------
    
    output$line_plot_title <-
      renderText(
        indicators %>%
          filter(indicator == input$profile_var) %>%
          pull(title_french)
      )
    
    unit <- 
      eventReactive(
        input$profile_var,
        
        indicators %>%
          filter(indicator == input$profile_var) %>%
          pull(unit_french)
      )
    
    output$line_plot_unit <-
      renderText({
        paste0("(", unit(), ")")
      })
      
    output$line_plot <-
      renderPlotly({
        
        static <-
          communes %>%
            st_drop_geometry %>%
            filter(commune == input$profile_commune) %>%
            ggplot(
              aes_string(
                x = "year",
                y = input$profile_var
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
                  round(get(input$profile_var), 1),
                  " ",
                  unit()
                )
              ),
              color = "navy",
              size = 3
            ) +
            theme_minimal() +
            labs(x = NULL, y = NULL)
        
        ggplotly(static, tooltip = "text")
      })
    
## Map -------------------------------------------------------------------------
    
    output$map_title <-
      renderText(
        indicators %>%
          filter(indicator == input$map_var) %>%
          pull(title_french)
      )
    
    output$map_year <-
      renderText(
        input$map_year
      )
    
### Map ------------------------------------------------------------------------
    output$map <-
      renderPlotly({
        
        unit <-
          indicators %>%
          filter(indicator == input$map_var) %>%
          pull(unit_french)
        
        title <-
          indicators %>%
          filter(indicator == input$map_var) %>%
          pull(title_french)
        
        data <-
          communes %>%
          filter(year == input$map_year) %>%
          mutate(
            n_country = get(input$map_var) %>% na.omit %>% length,
            rank_country = rank(get(input$map_var))
          ) %>%
          group_by(region) %>%
          mutate(
            n_region = get(input$map_var) %>% na.omit %>% length,
            rank_region = rank(get(input$map_var))
          ) %>%
          ungroup %>%
          mutate(
            text = paste0(
              "Commune de ", commune, "<br><br>",
              "Province: ", province, "<br>",
              "Région: ", region, "<br><br>",
              title, " (", year, "): ", 
              get(input$map_var) %>% round(1), " ",
              unit, "<br>",
              rank_country, "ème sur ", n_country, " communes de Burkina Faso <br>",
              rank_region, "ème sur ", n_region, " communes de ", region
            )
          )
        
        static <-
          ggplot() +
          geom_sf(
            data = communes,
            aes(
              text = commune
            ),
            color = "black"
          ) +
          geom_sf(
            data = data,
            aes_string(
              fill = input$map_var,
              text = "text"
            ),
            color = "black"
          ) + 
          geom_sf(
            data = regions,
            fill = alpha("white", 0),
            color = alpha("black", 1),
            size = 1
          ) +
          labs(
            fill = unit
          ) +
          theme_void() 
        
        ggplotly(
          static, 
          tooltip = "text"
        )
        
      })
    
# Data -------------------------------------------------------------------------
    
  output$data <-
      renderDataTable(
        {
          communes %>%
            st_drop_geometry() %>%
            filter(
              commune %in% input$data_commune,
              province %in% input$data_province,
              region %in% input$data_region,
              year %in% as.numeric(input$data_year)
            ) %>%
            select(
              commune,
              province,
              region,
              year,
              all_of(input$data_var)
            ) %>%
            mutate(
              across(
                all_of(input$data_var),
                ~ round(., 3)
              )
            )
        },
        extensions = 'Buttons',
        filter = "top",
        selection = "multiple",
        escape = FALSE,
        options = list(
          sDom  = '<"top">Bt<"bottom">ip',
          pageLength = 10,
          autoWidth = TRUE,
          buttons = c('copy', 'csv', 'excel'),
          lengthMenu = c(10, 20, 50, 100),
          scrollX = TRUE,
          scroller = TRUE
        ),
        rownames = FALSE,
        server = FALSE
      )
  }

