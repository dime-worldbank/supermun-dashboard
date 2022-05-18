# UI ###########################################################################

ui <-
  dashboardPage(

    freshTheme = create_theme(bs4dash_layout(sidebar_width = "300px")),

    ## Header ------------------------------------------------------------------

    dashboardHeader(

      title = dashboardBrand(
        title = "SUPERMUN",
      ),
      status = "white",
      border = TRUE,
      sidebarIcon = icon("bars"),
      controlbarIcon = icon("th"),
      fixed = FALSE

    ),

    ## Navigation menu ---------------------------------------------------------
    dashboardSidebar(

      status = "info",
      skin = "light",
      elevation = 5,

      sidebarMenu(
        menuItem("Home", tabName = "home", icon = icon("home")),
        menuItem("Map", tabName = "map", icon = icon("map")),
        menuItem("Commune profile", tabName = "profile", icon = icon("map-pin")),
        menuItem("Donées", tabName = "data", icon = icon("database"))
      )
    ),

    dashboardBody(
      tabItems(

        ## Landing page --------------------------------------------------------

        tabItem(
          tabName = "home",

          bs4Card(
            width = 12,
            status = "navy",
            solidHeader = TRUE,
            
            br(),
            p("The World Bank recognizes institutional strengthening as key ingredient for progress of its members countries along income categories. While there are numerous diagnostic and assessment tools for specific functional areas such as public financial management and tax administration, there is no analytical tool for country-level institutional assessment."),
            p("The Global Benchmarking Institutions Dashboard (G-BID) contributes to fill this gap by providing a standard methodology to summarize information from a large set of country-level institutional indicators."),
            p("The dashboard provides a user-friendly interface with multiple visualizations of a country’s institutional profile based on a set of international indicators, highlighting a given country’s institutional strengths and weaknesses relative to a set of country comparators. The findings of the G-BID can provide a structured and up-to-date empirical guidance for further in-depth analysis in the specific areas of interest, given the nature of the World Bank engagement in a country and/or complementarity with other ongoing country-level diagnostics (SCDs, CEMs, CPFs and the like).")
          )
        ),

        ## Map -----------------------------------------------------------------

        tabItem(
          tabName = "map",
          
          fluidRow(
            box(
              width = 9,
              
              h1(textOutput("map_title")),
              h3(textOutput("map_year")),
              
              plotlyOutput(
                "map",
                height = "700px"
              )
            ),
            
            box(
              width = 3,
              
              pickerInput(
                inputId = "map_var",
                label = "Indicator", 
                choices = indicator_list
              ),
              
              pickerInput(
                inputId = "map_year",
                label = "Year", 
                choices = communes %>% pull(year) %>% unique
              )
            )
          )
          
        ),

        ## Commune profile ----------------------------------------------------

        tabItem(
          tabName = "profile",
          
          fluidRow(
            
            box(
              width = 9,
              
              h1(textOutput("profile_title")),
               
              fluidRow(
                
                column(
                  width = 12,
                  h3(textOutput("line_plot_title")),
                  h4(textOutput("line_plot_unit")),
                  plotlyOutput("line_plot")
                )
                
              ),
              br(),
              h3("Capacite institutionelle"),
              
              fluidRow(
                tableOutput("table")
              )
              
            ),
            
            box(
              width = 3,
              
              pickerInput(
                inputId = "profile_commune",
                label = NULL, 
                choices = communes %>% pull(commune),
                selected = "Banfora"
              ),
              
              pickerInput(
                inputId = "profile_var",
                label = "Indicator", 
                choices = indicator_list
              )
            )
          )
        ),
        
        ## Data download -------------------------------------------------------
        
        tabItem(
          tabName = "data",
          
          box(
            width = 12,
            
            fluidRow(  
              
              column(
                width = 4,
                pickerInput(
                  inputId = "data_var",
                  label = "Indicateurs", 
                  choices = indicator_list,
                  selected = indicator_list,
                  options = list(
                    `actions-box` = TRUE), 
                  multiple = TRUE
                )
              ),
              
              column(
                width = 2,
                pickerInput(
                  inputId = "data_region",
                  label = "Région", 
                  choices = communes %>% pull(region) %>% unique,
                  selected = communes %>% pull(region) %>% unique,
                  options = list(
                    `actions-box` = TRUE), 
                  multiple = TRUE
                )
              ),
              column(
                width = 2,
                pickerInput(
                  inputId = "data_province",
                  label = "Province", 
                  choices = communes %>% pull(province) %>% unique,
                  selected = communes %>% pull(province) %>% unique,
                  options = list(
                    `actions-box` = TRUE), 
                  multiple = TRUE
                )
              ),
              column(
                width = 2,
                pickerInput(
                  inputId = "data_commune",
                  label = "Commune", 
                  choices = communes %>% pull(commune) %>% unique,
                  selected = communes %>% pull(commune) %>% unique,
                  options = list(
                    `actions-box` = TRUE), 
                  multiple = TRUE
                )
              ),
              
              column(
                width = 2,
                pickerInput(
                  inputId = "data_year",
                  label = "Anée", 
                  choices = communes %>% filter(!is.na(year)) %>% pull(year) %>% unique,
                  selected = communes %>% filter(!is.na(year)) %>% pull(year) %>% unique,
                  options = list(
                    `actions-box` = TRUE), 
                  multiple = TRUE
                )
              )
            )
          ),
          
          fluidRow(
            box(
              width = 12,
              
              dataTableOutput("data")
            )
          )
        )
      )
    )
  )
