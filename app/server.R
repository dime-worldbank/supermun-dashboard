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
        
        display_map(map_data[[input$map_var]], input$map_year, input$map_var) # Function defined in auxiliary/display_map.R

      })
    
    output$map_note <-
      renderUI({
        HTML(
          str_wrap(
            paste(
              "<b>Définition:</b>",
              indicators %>%
                filter(indicator == input$map_var) %>%
                pull(definition_french)
            ),
            note_chars
          )
        )
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
          
          names <-
            indicators %>%
            filter(indicator %in% input$data_var) %>%
            pull(title_french)
          
          data <- 
            communes %>%
            st_drop_geometry() %>%
            filter(
              commune %in% input$data_commune,
              province %in% input$data_province,
              region %in% input$data_region,
              year %in% as.numeric(input$data_year)
            ) %>%
            select(province, region, commune, year, all_of(input$data_var)) %>%
            mutate(
              across(
                all_of(input$data_var),
                ~ round(., 3)
              )
            )
            
          names(data) <-
            c("Province", "Région", "Commune", "Année", indicators$title_french)
          
          data
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
# Indicators -------------------------------------------------------------------
  
  output$indicators <-
    renderDataTable(
      {
        table <-
          datatable(
            indicators %>%
              select(family, title_french, unit_french, definition_french) %>%
              arrange(family, title_french) %>%
              set_names("Groupe", "Indicateur", "Unité de mesure", "Définition"),
            extensions = 'Buttons',
            filter = "top",
            selection = "multiple",
            escape = FALSE,
            options = list(
              dom  = 'tB',
              rowsGroup = list(0),
              pageLength = 17,
              autoWidth = TRUE,
              buttons = c('copy', 'csv', 'excel'),
              lengthMenu = c(10, 20, 50, 100),
              scrollX = TRUE,
              scroller = TRUE
            ),
            rownames = FALSE
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
      }
    )
  }

