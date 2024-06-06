# Server ################################################################################

  server <- function(input, output, session) {
    
## Commune profile -------------------------------------------------------------
    
### Boxes ----------------------------------------------------------------------
    output$ic <-
      renderValueBox({
        
        year_max <- 
          communes %>%
          filter(
            commune == input$profile_commune,
            !is.na(total_points_ic)
          ) %>%
          pull(year) %>%
          max 
        
        value <- 
          communes %>%
          filter(
            commune == input$profile_commune,
            year == year_max
          ) %>%
          pull(total_points_ic) %>%
          round(1)
        
        valueBox(
          value = value,
          subtitle = paste("Capacité institutionnelle\n(", year_max, ")"),
          icon = icon("university", lib = "font-awesome"),
          color = "teal"
        )
      })
    
    output$sd <-
      renderValueBox({
        
        year_max <- 
          communes %>%
          filter(
            commune == input$profile_commune,
            !is.na(total_points_sd)) %>%
          pull(year) %>%
          max
        
        value <-
          communes %>%
          filter(
            commune == input$profile_commune,
            year == year_max
          ) %>%
          pull(total_points_sd) %>%
          round(1)
        
        valueBox(
          value,
          width = 12,
          subtitle = paste("Services publics\n(", year_max, ")"),
          icon = icon("hand-holding", lib = "font-awesome"),
          color = "teal"
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
            filter = "top",
            selection = "single",
            escape = FALSE,
            extensions = 'FixedHeader',
            options = list(
              buttons = c('copy', 'csv', 'excel'),
              dom = 'Bfrtip',
              pageLength = 18,
              scrollX = TRUE,
              scrollY = "550px",  # Set a specific value for scrollY instead of TRUE
              rowsGroup = list(0)
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
              pull(button)
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
        
        display_map(input$map_year, input$map_var) # Function defined in auxiliary/display_map.R

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
    
  data <-
   eventReactive(
     c(input$data_commune, input$data_province, input$data_region, input$data_year, input$data_var),
     {
       names <-
        indicators %>%
        filter(indicator %in% input$data_var) %>%
        pull(Indicateur)
     
       data <- 
         communes %>%
         filter(
           commune %in% input$data_commune,
           province %in% input$data_province,
           region %in% input$data_region,
           year %in% as.numeric(input$data_year)
         ) %>%
         select(region, province, commune, year, all_of(input$data_var)) %>%
         mutate(
           across(
             all_of(input$data_var),
             ~ round(., 3)
           )
         )
       
        names(data) <-
          c("Région","Province", "Commune", "Année", names)
       
       data
     }
   )
  
  output$data <- renderDT({
    datatable(
      data(),
      extensions = 'FixedHeader',
      options = list(
        fixedHeader = TRUE,
        scrollX = TRUE,
        scrollY = "550px",
        pageLength = 20,
        lengthMenu = list(c(10, 15, -1), c('10 rows', '15 rows', 'Show all')),
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel')
      )
    )
  })
  
  output$data_csv <-
    downloadHandler(
      filename = "supermun.csv",
      
      content = function(file) {
        write_csv(
          data(),
          file
        )
      }
    )
  
  output$data_xls <-
    downloadHandler(
      filename = "supermun.xlsx",
      
      content = function(file) {
        write_xlsx(
          data(),
          file
        )
      }
    )
  
# Indicators -------------------------------------------------------------------
  
  output$indicators <-
    renderDataTable(
      {
        table <-
          indicators %>%
            select(family, title_french, unit_french, definition_french) %>%
         #   arrange(family, title_french) %>%
            set_names("Groupe", "Indicateur", "Unité de mesure", "Définition") %>%
            datatable(
              rownames = FALSE,
              filter = "top",
              selection = "multiple",
              escape = FALSE,
              extensions = 'FixedHeader',
              options = list(
                buttons = c('copy', 'csv', 'excel'),
                dom = 'Bfrtip',
                pageLength = 18,
                lengthMenu = list(c(10, 15, -1), c('10 rows', '15 rows', 'Show all')),
                scrollX = TRUE,
                scrollY = "550px",
                rowsGroup = list(0)
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
      }
    )
  }

