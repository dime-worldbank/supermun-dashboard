# UI ###########################################################################

ui <- 

  navbarPage(
    
    "Suivi de la Performance Municipale",
    fluid = FALSE,
    id = "main",
    collapsible = T, 
    position = "fixed-top",
    theme = shinytheme("united"),
    header = tagList(
      useShinydashboard()
    ),
    tags$style(
      ".commune {font-size: 36px;} .download {width: 49%; background-color: #17a2b8; color: white}"
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
            choices = communes %>% pull(year) %>% unique %>% na.omit,
            selected = 2018
          ),

          pickerInput(
            inputId = "map_groupe",
            label = "Groupe d'indicateur",
            choices = c(
              "Capacité institutionelle",
              "Services publics"
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
            height = "700px"
          ),
          htmlOutput("map_note")
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
        options = list(
          style = "commune",
          `live-search` = TRUE
        )
      ),

      fluidRow(
        column(
          width = 3,
          fluidRow(valueBoxOutput("ic", width = 12)),
          fluidRow(valueBoxOutput("sd", width = 12))
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

      wellPanel(
        width = 12,
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
        
        ### Sidebar ----------------------------------------------------------
        sidebarPanel(
          width = 3,

          pickerInput(
            inputId = "data_var",
            label = "Indicateurs",
            choices = indicator_list,
            selected = c(ic, sd),
            options = list(`actions-box` = TRUE),
            multiple = TRUE
          ),
          
          
          pickerInput(
            inputId = "data_region",
            label = "Région",
            choices = communes %>% arrange(region) %>% pull(region) %>% unique,
            selected = communes %>% arrange(region) %>% pull(region) %>% unique,
            options = list(`actions-box` = TRUE, 
                           `live-search` = TRUE),
            multiple = TRUE, 
            
          ),
          
          pickerInput(
            inputId = "data_province",
            label = "Province",
            choices = communes %>% arrange(province) %>% pull(province) %>% unique %>% na.omit,
            selected = communes %>% arrange(province) %>% pull(province) %>% unique,
            options = list(
              `actions-box` = TRUE,
              `live-search` = TRUE
            ),
            multiple = TRUE
          ),
          
          pickerInput(
            inputId = "data_commune",
            label = "Commune",
            choices = communes %>% pull(commune) %>% unique,
            selected = communes %>% pull(commune) %>% unique,
            options = list(
              `actions-box` = TRUE,
              `live-search` = TRUE
            ),
            multiple = TRUE
          ),
          
          
          pickerInput(
            inputId = "data_year",
            label = "Anée",
            choices = communes %>% filter(!is.na(year)) %>% pull(year) %>% unique,
            selected = communes %>% filter(!is.na(year)) %>% pull(year) %>% unique,
            options = list(`actions-box` = TRUE, 
                           `live-search` = TRUE),
            multiple = TRUE
          ),
          
          downloadButton(
            "data_csv",
            " CSV",
            class = "download"
          ),
          
          downloadButton(
            "data_xls",
            " Excel",
            class = "download"
          )
        ),
      
      ### Main panel -----------------------------------------------------------
        mainPanel(
          width = 9,
          dataTableOutput("data") 
        )
      )
    ),
    
    ## Data download -------------------------------------------------------
    
    tabPanel(
      "Indicateurs",
      
      br(),
      br(),
      br(),
      
      dataTableOutput("indicators")

    )
    
  ) # navbarPage
