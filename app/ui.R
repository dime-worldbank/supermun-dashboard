# UI ###########################################################################

ui <- 

  navbarPage(
    
    "Suivi des perfomances municipales",
    fluid = FALSE,
    id = "main",
    collapsible = T, 
    position = "fixed-top",
    includeCSS("www/styles.css"),
    header = tagList(
      useShinydashboard()
    ),

    # Tab panel: home -----------------
    tabPanel(
      "Accueil",

      br(),
      br(),
      br(),
      
      sidebarLayout(
        sidebarPanel(
          pickerInput(
            inputId = "map_year",
            label = "Année",
            choices = communes %>% pull(year) %>% unique %>% na.omit
          ),
          
          pickerInput(
            inputId = "map_groupe",
            label = "Groupe d'indicateur",
            choices = c(
              "Capacité institutionelle" = "ic",
              "Services Publics" = "sd"
            )
          ),
        
          radioGroupButtons(
            inputId = "map_var",
            label = "Liste des indicateurs",
            choices = ic,
            direction = "vertical"
          )
          
        ),
        
        mainPanel(
          plotlyOutput(
            "map",
            height = "800px"
          )
        )
      )
    ),
    
    ## Commune profile ----------------------------------------------------
    
    tabPanel(
      
      "Données par commune",
      
      br(),
      br(),
      br(),

      pickerInput(
        inputId = "profile_commune",
        choices = communes %>% pull(commune) %>% unique,
        selected = "Banfora",
        width = "100%",
        options = list(style = "commune")
      ),

      fluidRow(
        column(
          width = 3,
          fluidRow(infoBoxOutput("ic", width = 12)),
          fluidRow(infoBoxOutput("sd", width = 12))
        ),
        column(
          width = 9,
          plotlyOutput(
            "line_plot",
            height = "250px"
          )#,
          #htmlOutput("plot_note")
        )
      ),

      bs4Card(
        width = 12,
        solidHeader = TRUE,
        collapsible = FALSE,
        status = "primary",
        dataTableOutput("table")
      )
      
    ),
    
    ## Data download -------------------------------------------------------
    
    tabPanel(
      "Données",
      
      br(),
      br(),
      br(),
      
      sidebarLayout(
        
        sidebarPanel(

          pickerInput(
            inputId = "data_var",
            label = "Indicateurs",
            choices = indicator_list,
            selected = indicator_list,
            options = list(
              `actions-box` = TRUE),
            multiple = TRUE
          ),

            
          pickerInput(
            inputId = "data_region",
            label = "Région",
            choices = communes %>% pull(region) %>% unique,
            selected = communes %>% pull(region) %>% unique,
            options = list(
              `actions-box` = TRUE),
            multiple = TRUE
          ),
           
          pickerInput(
            inputId = "data_province",
            label = "Province",
            choices = communes %>% pull(province) %>% unique,
            selected = communes %>% pull(province) %>% unique,
            options = list(
              `actions-box` = TRUE),
            multiple = TRUE
          ),
            
          pickerInput(
            inputId = "data_commune",
            label = "Commune",
            choices = communes %>% pull(commune) %>% unique,
            selected = communes %>% pull(commune) %>% unique,
            options = list(
              `actions-box` = TRUE),
            multiple = TRUE
          ),

            
          pickerInput(
            inputId = "data_year",
            label = "Anée",
            choices = communes %>% filter(!is.na(year)) %>% pull(year) %>% unique,
            selected = communes %>% filter(!is.na(year)) %>% pull(year) %>% unique,
            options = list(
              `actions-box` = TRUE),
            multiple = TRUE
          )
        ),

        mainPanel(
          dataTableOutput("data")
        )
      )
    )
    
  ) # navbarPage
