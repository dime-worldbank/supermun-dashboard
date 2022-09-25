# Server ################################################################################

  server <- function(input, output, session) {
    
## Commune profile -------------------------------------------------------------
    
### Boxes ----------------------------------------------------------------------
    output$ic <-
      renderInfoBox({
        
        year_max <- 
          communes %>%
          filter(
            commune == input$profile_commune,
            !is.na(total_points_ic)
          ) %>%
          pull(year) %>%
          max 
        
        bs4ValueBox(
          value = 
            communes %>%
            filter(
              commune == input$profile_commune,
              year == year_max
            ) %>%
            pull(total_points_ic) %>%
            round(1),
          subtitle = paste("Capacité institutionelle\n(", year_max, ")"),
          icon = icon("university", lib = "font-awesome")
        )
      })
    
    output$sd <-
      renderInfoBox({
        
        year_max <- 
          communes %>%
          filter(
            commune == input$profile_commune,
            !is.na(total_points_sd)) %>%
          pull(year) %>%
          max
        
        bs4ValueBox(
          communes %>%
            filter(
              commune == input$profile_commune,
              year == year_max
            ) %>%
            pull(total_points_sd) %>%
            round(1),
          width = 12,
          subtitle = paste("Services publics\n(", year_max, ")"),
          icon = icon("hand-holding", lib = "font-awesome")
        )
      })
    
### Institutional capacity table -----------------------------------------------
    
  output$table <-
      renderDataTable({
        
        table <-
          datatable(
            data_table %>%
              filter(
                commune == input$profile_commune
              ) %>%
              select(-commune),
            rownames = FALSE,
            options = 
              list(
                dom = 't',
                rowsGroup = list(0),
                scrollX = TRUE,
                scrollY = TRUE,
                pageLength = 17
              ),
            selection = 
              list(
                mode = "single"
              )
          )

        table$dependencies <- 
          c(
            table$dependencies, 
            list(
              htmlDependency(
                "RowsGroup", 
                "2.0.0", 
                src = "www", 
                script = "dataTables.rowsGroup.js"
              )
            )
          )
        
        table
        
      })
    
  selected_var <-
    eventReactive(
      input$table_rows_selected,
      
      {
        if (is.null(input$table_rows_selected)) {
          "Capacité institutionnelle (Points)"
        } else {
          data_table[input$table_rows_selected, "Indicateur"] %>% unlist %>% unname
        }
      },
      
      ignoreNULL = FALSE
    )
 

### Selected graph -------------------------------------------------------------

    output$line_plot <-
      renderPlotly({

        line_plot(communes, input$profile_commune, selected_var())
        
      })
  
  output$plot_note <-
    renderUI({
      HTML(
        str_wrap(
          paste(
            "<b>Définition:</b>",
            indicators %>%
              filter(Indicateur == selected_var()) %>%
              pull(definition_french)
          ),
          note_chars
        )
      )
    })
    
## Map -------------------------------------------------------------------------
    
    observeEvent(
      input$map_groupe,
      
      # List of indicators is updated based on family
      updateRadioGroupButtons(
        session,
        "map_var",
        choices = indicators %>% 
          filter(family == input$map_groupe) %>%
          pull(indicator) %>%
          setNames(
            indicators %>% 
              filter(family == input$map_groupe) %>%
              pull(title_french)
          )
      ),
      
      ignoreInit = TRUE
    )
    
    output$map_def_h <-
      renderUI({
        if (!is.null(input$map_var)) {
          p(tags$b("Description de l'indicateur"))
        }
      })
    
    map_def <-
      eventReactive(
        input$map_var,
        {
          indicators %>%
            filter(indicator == input$map_var) %>%
            pull(definition_french)
        },
        
        ignoreNULL = FALSE
      )

    
### Map ------------------------------------------------------------------------
    output$map <-
      renderPlotly({
        
        var <-
          ifelse(
            is.null(input$map_var),
            "total_points_ic",
            input$map_var
          )
        
        unit <-
          indicators %>%
          filter(indicator == var) %>%
          pull(unit_french)
        
        title <-
          indicators %>%
          filter(indicator == var) %>%
          pull(title_french)
        
        quintiles <-
          communes %>%
          filter(year == input$map_year) %>%
          pull(get(var)) %>%
          quantile(
            probs = seq(0, 1, 0.2), 
            na.rm = TRUE
          ) %>% 
          round(0) %>% 
          unname
        
        data <-
          communes %>%
          filter(year == input$map_year) %>%
          mutate(
            fill = case_when(
              (get(var) < quintiles[2]) ~ 5,
              (get(var) > quintiles[2]) & (get(var) < quintiles[3]) ~ 4,
              (get(var) > quintiles[3]) & (get(var) < quintiles[4]) ~ 3,
              (get(var) > quintiles[4]) & (get(var) < quintiles[5]) ~ 2,
              (get(var) > quintiles[5]) ~ 1
            ) %>%
              factor(
                labels = c(
                  paste0(quintiles[5], "+"),
                  paste0(quintiles[4], "-", quintiles[5]),
                  paste0(quintiles[3], "-", quintiles[4]),
                  paste0(quintiles[2], "-", quintiles[3]),
                  paste0(quintiles[2], "-")
                )
              ),
            n_country = get(var) %>% na.omit %>% length,
            rank_country = rank(get(var))
          ) %>%
          group_by(region) %>%
          mutate(
            n_region = get(var) %>% na.omit %>% length,
            rank_region = rank(get(var))
          ) %>%
          ungroup %>%
          mutate(
            text = paste0(
              "<b>Commune de ", commune, "</b><br><br>",
              "<b>Province:</b> ", province, "<br>",
              "<b>Région:</b> ", region, "<br><br>",
              "<b>", title, " (", year, "): </b>",
              get(var) %>% round(1), " ",
              unit, "<br><br>",
              "<b>",rank_country, "ème </b>sur ", n_country, " communes de Burkina Faso <br>",
              "<b>",rank_region, "ème </b>sur ", n_region, " communes de ", region
            )
          )
        
        display_map(data, input$map_year, input$map_var, title) # Function defined in auxiliary/display_map.R

      })
    
# Data -------------------------------------------------------------------------
    
  output$ic_value <-
    renderText(
      panel %>%
        filter(
          commune == input$profile_commune,
          year == 2018
        ) %>%
        pull(total_points_ic)
    )
    
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

