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
    
    tags$style(".commune {font-size: 36px; font-family: 'Source Sans Pro',sans-serif; margin-top: 20px;
    margin-bottom: 10px; font-weight: 500; line-height: 1.1; background-color: '#FF6961';"),

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
            options = list(`actions-box` = TRUE),
            multiple = TRUE
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
            options = list(`actions-box` = TRUE),
            multiple = TRUE
          ),
          
          downloadButton(
            "data_csv",
            " CSV",
            style = "width:100%; background-color: #204d74; color: white"
          ),
          
          downloadButton(
            "data_xls",
            " Excel",
            style = "width:100%; background-color: #204d74; color: white"
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
