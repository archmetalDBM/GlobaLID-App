library(shiny)
library(shinyvalidate)
library(bs4Dash)
library(waiter)
library(leaflet)
library(ggplot2)
library(plotly)
library(DT)
library(tidyr)
library(dplyr)
library(stringr)
library(lemon)
library(rmarkdown)
library(knitr)
library(kableExtra)
library(ks)

source("www/scripts/calculate_ratios.R")
source("www/scripts/calculate_model_ages.R")
source("www/scripts/geom_kde2d.R")
source("plot_module.R")
source("update.R")
credentials <- readRDS("data/credentials.rds")

# load datasets
data_complete <- readRDS("data/database_complete.rds") %>%
  unite(tooltip, `Sample number`, Country, `Political province/region`, `Mining area`, `Mining site`, sep = "<br>", remove = FALSE, na.rm = TRUE) %>%
  mutate(tooltip = paste0("Sample ID: ", tooltip)) %>%
  mutate(across(.cols = c(where(is.character) & !c("doi", "Location precision")), replace_na, "unknown"))

data_clean <- readRDS("data/database_clean.rds") %>%
  unite(tooltip, `Sample number`, Country, `Political province/region`, `Mining area`, `Mining site`, sep = "<br>", remove = FALSE, na.rm = TRUE) %>%
  mutate(tooltip = paste0("Sample ID: ", tooltip)) %>%
  mutate(across(.cols = c(where(is.character) & !c("doi", "Location precision")), replace_na, "unknown"))

commodities <- data_complete %>%
  select(`Metal (what can be produced by smelting)`) %>%
  drop_na() %>%
  mutate(sep_num = str_count(`Metal (what can be produced by smelting)`, ";")) %>%
  separate(`Metal (what can be produced by smelting)`, into = paste0("Metal", seq(1:1+max(.$sep_num))), sep = "; ", fill = "right") %>%
  pivot_longer(contains("Metal")) %>%
  select(value) %>%
  drop_na() %>%
  distinct() %>% 
  pull()

minerals <- data_complete %>%
  select(`Sample description (minerals)`) %>%
  drop_na() %>%
  mutate(sep_num = str_count(`Sample description (minerals)`, ";")) %>%
  separate(`Sample description (minerals)`, into = paste0("Mineral", seq(1:1+max(.$sep_num))), sep = "; ", fill = "right") %>%
  pivot_longer(contains("Mineral")) %>%
  select(value) %>%
  drop_na() %>%
  distinct() %>%
  pull()

# UI side -----------------------------------------------------------------
ui <- dashboardPage(
  title = "GlobaLID",
  fullscreen = TRUE,
  dark = TRUE,
  scrollToTop = TRUE,
  preloader = list(html = spin_1(), color = "#333e48"),
  header = dashboardHeader(
    title = dashboardBrand(
      title = "GlobaLID",
      color = "primary",
      href = NULL,
      image = "logo.svg",
    ),
    status = "white",
    border = TRUE,
    sidebarIcon = icon("bars"),
    controlbarIcon = icon("filter"),
    fixed = FALSE,
    leftUi = tags$li(class = "dropdown",
                     tags$head(tags$style(".headerRow{height:40px;}")),
                     tagList(
                       fluidRow(
                         class = "headerRow",
                         column(
                           width = 2, 
                           fluidRow(
                             column(
                               width = 4, 
                               align = "right",
                               "Database:"
                             ),
                             column(
                               width = 8, 
                               selectizeInput("database", NULL, choices = "Ores & Minerals")
                             )
                           )
                         ),
                         column(
                           width = 3, 
                           fluidRow(
                             column(
                               width = 6, 
                               checkboxInput("data_clean", "Only reliable data", value = TRUE)
                             ), 
                             column(
                               width = 6, 
                               checkboxInput("location_accuracy", "Only exact locations")
                             )
                           )
                         ),
                         column(
                           width = 2, 
                           fluidRow(
                             column(
                               width = 5, 
                               align = "right",
                               "Subset by"
                             ),
                             column(
                               width = 7, 
                               selectizeInput("group", NULL, choices = c("Country" = "Country",
                                                                         "Province" = "Political province/region",
                                                                         "Mining area" = "Mining area",
                                                                         "Mining site" = "Mining site"), 
                                              selected = "Mining area")
                             )
                           )
                         ),
                         column(
                           width = 2,
                           checkboxInput("data_unknown", "Exclude 'unknown's", value = FALSE)
                         ), 
                         column(
                           width = 2, 
                           conditionalPanel(
                             condition = "input.sidebar == 'graphs'", 
                             tagList(
                               fluidRow(
                                 column(width = 6,
                                        align = "right",
                                        "Colour palette:"), 
                                 column(
                                   width = 6, 
                                   selectizeInput("palette", NULL, 
                                                  choices = list(
                                                    "Viridis and similar" = list("viridis", "magma", "inferno", "plasma", "cividis"),
                                                    "ColourBrewer: diverging" = list("BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", "RdYlBu", "RdYlGn", "Spectral"),
                                                    "ColourBrewer: sequential" = list("Blues", "BuGn", "BuPu", "GnBu", "Greens", "Greys", "Oranges", "OrRd", "PuBu", "PuBuGn", "PuRd", "Purples", "RdPu", "Reds", "YlGn", "YlGnBu", "YlOrBr", "YlOrRd"),
                                                    "ColourBrewer: qualitative" = list("Accent", "Dark2", "Paired", "Pastel1", "Pastel2", "Set1", "Set2", "Set3")
                                                  )
                                   )
                                 )
                               )
                             )
                           )
                         )
                         
                       )
                     )
    ),
    rightUi = NULL
  ),
  sidebar = dashboardSidebar(
    skin = "light",
    status = "primary",
    elevation = 3,
    sidebarMenu(
      id = "sidebar",
      menuItem(
        "Map",
        tabName = "map",
        icon = icon("map-marked-alt")
      ),
      menuItem(
        "Explore",
        tabName = "graphs",
        icon = icon("chart-bar")
      ),
      menuItem(
        "Upload data",
        tabName = "upload",
        icon = icon("upload")
      ),
      menuItem(
        "Download",
        tabName = "download",
        icon = icon("download")
      ),
      menuItem(
        "References",
        tabName = "references",
        icon = icon("book")
      ),
      menuItem(
        "Instructions",
        tabName = "instructions",
        icon = icon("book-open")
      ),
      menuItem(
        "Resources",
        tabName = "resources",
        icon = icon("code")
      ),
      menuItem(
        "About",
        tabName = "about",
        icon = icon("info-circle")
      ),
      menuItem(
        "Contribute", 
        tabName = "contribute", 
        icon = icon("file-upload")
      ),
      menuItem(
        "Imprint & Privacy",
        tabName = "imprint",
        icon = icon("balance-scale")
      )
    )
  ),
  controlbar = dashboardControlbar(
    skin = "light",
    pinned = TRUE,
    collapsed = FALSE,
    overlay = FALSE,
    #width = "25vw",
    column(
      width = 12,
      align = "center",
      uiOutput("filter_countryOut"),
      uiOutput("filter_provinceOut"),
      uiOutput("filter_areaOut"),
      uiOutput("filter_siteOut"),
      hr(style = "border-top: 1px solid #adb5bd;"),
      uiOutput("filter_geolAgeOut"),
      uiOutput("filter_mineralOut"),
      uiOutput("filter_commodityOut"),
      uiOutput("filter_instrumentOut"),
      uiOutput("filter_yearOut")
    )
  ),
  footer = dashboardFooter(
    left = a(
      href = "mailto:thomas.rose@daad-alumni.de",
      target = "_blank", "Contact the GlobaLID Core team"  
    ),
    right = paste("Database status:", format(update_database,"%d %B %Y"))
  ),
  body = dashboardBody(
    
    use_waiter(),
    
    tags$style(HTML("
                  .dataTables_wrapper .dataTables_length, .dataTables_wrapper .dataTables_filter, .dataTables_wrapper .dataTables_info, .dataTables_wrapper .dataTables_processing, .dataTables_wrapper .dataTables_paginate, .dataTables_wrapper .dataTables_paginate .paginate_button.current:hover {
                  color: #6c757d;}

                  .dataTables_wrapper .dataTables_paginate .paginate_button{
                    box-sizing:border-box;display:inline-block;min-width:1.5em;padding:0.5em 1em;margin-left:2px;text-align:center;text-decoration:none !important;cursor:pointer;
                    *cursor:hand;color:#808080 !important;border:1px solid transparent;border-radius:2px}
                  .dataTables_length select {color: #000000; background-color: #adb5bd}
                  .dataTables_filter input {color: #000000; background-color: #adb5bd}

                  thead {color: #6c757d;}

                  tbody {color: #6c757d;}"
    )),
    
    tabItems(
      tabItem(
        tabName = "map",
        fluidRow(
          bs4Card(
            title = "Plots", 
            width = 3,
            maximizable = TRUE, 
            selectInput("preview_control", label = NULL, width = "100%",
                        choices = list("204Pb normalised" = "A", "206Pb normalised" = "B", "Age Model" = "C")), 
            plotOutput("preview", height = "70vh")
          ),
          bs4Card(
            title = "Map",
            width = 9,
            maximizable = TRUE, 
            fluidRow(
              column(
                width = 7,
                fluidRow(
                  column(
                    width = 3,
                    align = "right",
                    "Jump to (lat/lon)"
                  ), 
                  column(
                    width = 3,
                    numericInput("jump_lat", label = NULL, value = 51.48867, min = -90, max = 90, step = 0.1)
                  ),
                  column(
                    width = 3,
                    numericInput("jump_lon", label = NULL, value = 7.21685, min = -180, max = 180, step = 0.1)
                  ),
                  column(
                    width = 3,
                    align = "left",
                    actionButton("jump_button", "Go!")
                  )
                )
              )
            ), 
            leafletOutput("map_box", height = "70vh")
          )
        )
      ),
      tabItem(
        tabName = "graphs",
        plotExploreUI("plot1", "Plot 1", "207Pb/204Pb"), 
        plotExploreUI("plot2", "Plot 2", "208Pb/204Pb")
      ),
      tabItem(
        tabName = "upload",
        fluidRow(
          bs4Card(
            title = "Upload Form", 
            width = 3,
            maximizable = TRUE, 
            uiOutput("file_upload"),
            hr(style = "border-top: 1px solid #adb5bd;"), 
            h5("Parameters:"),
            radioButtons("sep", "Separator",
                         choices = c(Comma = ",",
                                     Semicolon = ";",
                                     Tab = "\t"),
                         selected = ","),
            radioButtons("dec", "Decimal sign",
                         choices = c(Point = ".",
                                     Comma = ","),
                         selected = "."),
            radioButtons("quote", "Quote",
                         choices = c(None = "",
                                     "Double Quote" = '"',
                                     "Single Quote" = "'"),
                         selected = '"'), 
            hr(style = "border-top: 1px solid #adb5bd;"), 
            fluidRow(
              column(
                width = 6, 
                actionButton("autopick", "Match database"), 
              ),
              column(
                width = 6, 
                actionButton("upload_reset", "Reset"), 
                align = "right"
              )
            )
          ),
          bs4Card(
            title = "Data Viewer",
            width = 9,
            maximizable = TRUE, 
            DT::dataTableOutput("upload_preview")
          )
        )
      ),
      tabItem(
        tabName = "download",
        bs4Card(
          title = "Download plots and datasets", 
          width = 12, 
          collapsible = FALSE,
          fluidRow(
            column(
              width = 5,
              fluidRow(
                checkboxInput("download_plot1", "Plot 1")
              ), 
              fluidRow(
                column(
                  width = 6,
                  numericInput("download_plot1_width", "Width", value = 15, min = 0, max = 50)
                ), 
                column(
                  width = 6,
                  numericInput("download_plot1_height", "Height", value = 10, min = 0, max = 50)
                )
              )
            ), 
            column(
              width = 1
            ), 
            column(
              width = 5,
              fluidRow(
                checkboxInput("download_plot2", "Plot 2")
              ), 
              fluidRow(
                column(
                  width = 6,
                  numericInput("download_plot2_width", "Width", value = 15, min = 0, max = 50)
                ), 
                column(
                  width = 6,
                  numericInput("download_plot2_height", "Height", value = 10, min = 0, max = 50)
                )
              )
            )
          ),
          hr(style = "border-top: 1px solid #adb5bd;"), 
          fluidRow(
            column(
              width = 5,
              fluidRow(
                checkboxInput("download_combineh", "Horizontally combined")
              ), 
              fluidRow(
                column(
                  width = 6,
                  numericInput("download_combineh_width", "Width", value = 20, min = 0, max = 50)
                ), 
                column(
                  width = 6,
                  numericInput("download_combineh_height", "Height", value = 15, min = 0, max = 50)
                )
              )
            ), 
            column(
              width = 1
            ), 
            column(
              width = 5,
              fluidRow(
                checkboxInput("download_combinev", "Vertically combined")
              ), 
              fluidRow(
                column(
                  width = 6,
                  numericInput("download_combinev_width", "Width", value = 15, min = 0, max = 50)
                ), 
                column(
                  width = 6,
                  numericInput("download_combinev_height", "Height", value = 20, min = 0, max = 50)
                )
              )
            )
          ), 
          "Please make sure that the plots have identical legends: only the legend of plot 1 will be shown.",
          hr(style = "border-top: 1px solid #adb5bd;"), 
          fluidRow(
            column(
              width = 4,
              selectInput("download_unit", "Unit of plot size", choices = c("cm", "mm", "in"))
            ), 
            column(
              width = 4,
              numericInput("download_dpi", "Resolution (dpi)", value = 300, min = 72, max = 4800)
            ), 
            column(
              width = 4,
              selectInput("download_plot_filetype", "File type", choices = c("tiff", "jpg", "png", "pdf", "eps"))
            )
          ),
          hr(style = "border-top: 3px solid #adb5bd;"), 
          fluidRow(
            column(
              width = 4, 
              fluidRow(
                checkboxInput("download_dataset", "Dataset used in plots")
              ), 
              fluidRow(
                checkboxInput("download_upload", "Enhanced uploaded data")
              )
            ),
            column(
              width = 4,
              selectInput("download_data_filetype", "File type - data", choices = c("txt - tab sep." = "txt", "csv - comma sep." = "csv1", "csv - semicolon sep." = "csv2"))
            ), 
            column(
              width = 4, 
              selectInput("download_references_filetype", "File type - References", choices = c("docx" = "docx", "txt" = "txt"))
            )
          ), 
          hr(style = "border-top: 3px solid #adb5bd;"),
          fluidRow(
            column(
              width = 10, 
              tags$b("Caution: ", style = "color: red;"), 
              "3D scatterplots will result in the download of an empty plot. Use the snapshot tool in the interactive plot instead."
            ),
            column(
              width = 2, 
              downloadButton("download"), 
              align = "right"
            )
          )
        )
      ),
      tabItem(
        tabName = "references",
        includeMarkdown("doc/references.md")
      ),
      tabItem(
        tabName = "instructions",
        includeMarkdown("doc/instructions.md")
      ), 
      tabItem(
        tabName = "resources", 
        includeMarkdown("doc/resources.md")
      ),
      tabItem(
        tabName = "about", 
        includeMarkdown("doc/about.md")
      ),
      tabItem(
        tabName = "imprint", 
        includeMarkdown("doc/imprint.md")
      ),
      tabItem(
        tabName = "contribute", 
        fluidRow(
          bs4Card(
            title = "Data upload", 
            width = 4,
            maximizable = TRUE, 
            fluidRow(
              column(
                width = 6, 
                fileInput("contribute_data", "Data (.csv, .txt)", 
                          accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv", ".txt")
                ), 
                radioButtons("contribute_sep", "Separator",
                             choices = c(Comma = ",",
                                         Semicolon = ";",
                                         Tab = "\t"),
                             selected = ","),
                radioButtons("contribute_dec", "Decimal sign",
                             choices = c(Point = ".",
                                         Comma = ","),
                             selected = "."),
                radioButtons("contribute_quote", "Quote",
                             choices = c(None = "",
                                         "Double Quote" = '"',
                                         "Single Quote" = "'"),
                             selected = '"'
                )
              ), 
              column(
                width = 6, 
                textInput("contribute_user", "Contributor"), 
                radioButtons("contribute_type", "Type of Contribution", 
                             choices = c("New data" = "new", 
                                         "Update data" = "update"
                             ), 
                             selected = "update"
                ),
                conditionalPanel(condition = "input.contribute_type == 'new'", 
                                 tagList(
                                   fileInput("contribute_publication", "Publications (.pdf)", 
                                             accept = c("application/pdf", ".pdf")
                                   ),
                                   textInput("contribute_doi", "DOI (or 'n/a')"), 
                                   textInput("contribute_citation", "Full citation")
                                 )
                )
                
              )
            ),
            hr(style = "border-top: 1px solid #adb5bd;"), 
            textAreaInput("contribute_comments", "Comments to data", rows = 3, placeholder = "Enter short summary of the contribution here")
          ),
          tabBox(
            id = "contribute_check",
            width = 8,
            side = "left",
            maximizable = TRUE, 
            tabPanel(
              title = "Instructions", 
              includeMarkdown("doc/contribute.md")
            ), 
            tabPanel(
              title = "Data Viewer", 
              DT::dataTableOutput("contribute_data_preview")
            ), 
            tabPanel(
              title = "Check & Submit", 
              h5("I confirm that"),
              checkboxGroupInput("contribute_checklist", NULL, 
                                 choiceNames = c("The data are correct to the best of my knowledge", 
                                                 "Submission of the data does not violate any copyright", 
                                                 "The data were correctly parsed",
                                                 "The data are UTF-8 encoded", 
                                                 "The data are following the notation of GlobaLID",
                                                 "The data do not contain malicious code."), 
                                 choiceValues = letters[1:6]),
              actionButton("contribute_submit", "Submit")
            )
          )
        )
      )
    )
  )
)

# Server side -------------------------------------------------------------
server <- function(input, output, session) {

  # Input validation --------------------------------------------------------
  
  iv <- InputValidator$new()
  
  general_iv <- InputValidator$new()
  general_iv$add_rule("group", sv_in_set(c("Country", "Political province/region", "Mining area", "Mining site")))
  general_iv$add_rule("sidebar", sv_in_set(c("map", "graphs", "upload", "download", "references", "instructions", "resources", "about", "contribute", "imprint")))
  
  database_iv <- InputValidator$new()
  database_iv$add_rule("database", ~ if(. != "Ores & Minerals") "Do not hack the app.")
  database_iv$add_rule("data_clean", ~ if(!is.logical(.)) "Do not hack the app.")
  database_iv$add_rule("location_accuracy", ~ if(!is.logical(.)) "Do not hack the app.")
  database_iv$add_rule("data_unknown", ~ if(!is.logical(.)) "Do not hack the app.")
  database_iv$add_rule("filter_country", sv_in_set(unique(data_complete$Country)))
  database_iv$add_rule("filter_province", sv_in_set(unique(data_complete$`Political province/region`)))
  database_iv$add_rule("filter_area", sv_in_set(unique(data_complete$`Mining area`)))
  database_iv$add_rule("filter_site", sv_in_set(unique(data_complete$`Mining site`)))
  database_iv$add_rule("filter_geolAge", sv_in_set(unique(data_complete$`Geol. period`)))
  database_iv$add_rule("filter_instrument", sv_in_set(unique(data_complete$`Instrument used`)))
  database_iv$add_rule("filter_year", sv_integer(allow_multiple = TRUE))
  database_iv$add_rule("filter_year", sv_between(min(data_complete$year, na.rm = TRUE), max(data_complete$year, na.rm = TRUE)))
  database_iv$add_rule("filter_commodity", sv_in_set(commodities))
  database_iv$add_rule("filter_mineral", sv_in_set(minerals))
  
  map_iv <- InputValidator$new()
  map_iv$add_rule("preview_control", sv_in_set(LETTERS[1:3]))
  map_iv$add_rule("jump_lat", sv_numeric())
  map_iv$add_rule("jump_lat", sv_between(-90, 90))
  map_iv$add_rule("jump_lon", sv_numeric())
  map_iv$add_rule("jump_lon", sv_between(-180, 180))
  
  plot_iv <- InputValidator$new()
  plot_iv$add_rule("palette", sv_in_set(c("viridis", "magma", "inferno", "plasma", "cividis", "BrBG", "PiYG", "PRGn", "PuOr", "RdBu", "RdGy", "RdYlBu", "RdYlGn", "Spectral", "Blues", "BuGn", "BuPu", "GnBu", "Greens", "Greys", "Oranges", "OrRd", "PuBu", "PuBuGn", "PuRd", "Purples", "RdPu", "Reds", "YlGn", "YlGnBu", "YlOrBr", "YlOrRd", "Accent", "Dark2", "Paired", "Pastel1", "Pastel2", "Set1", "Set2", "Set3")))
  
  upload_iv <- InputValidator$new()
  upload_iv$add_rule("sep", sv_in_set(c(",", ";", "\t")))
  upload_iv$add_rule("dec", sv_in_set(c(",", ".")))
  upload_iv$add_rule("quote", sv_in_set(c("'", '"', "")))

  download_iv <- InputValidator$new()
  download_iv$add_rule("download_plot1", ~ if(!is.logical(.)) "Do not hack the app.")
  download_iv$add_rule("download_plot1_width", sv_integer())
  download_iv$add_rule("download_plot1_width", sv_between(0, 50))
  download_iv$add_rule("download_plot1_height", sv_integer())
  download_iv$add_rule("download_plot1_height", sv_between(0, 50))
  download_iv$add_rule("download_plot2", ~ if(!is.logical(.)) "Do not hack the app.")
  download_iv$add_rule("download_plot2_width", sv_integer())
  download_iv$add_rule("download_plot2_width", sv_between(0, 50))
  download_iv$add_rule("download_plot2_height", sv_integer())
  download_iv$add_rule("download_plot2_height", sv_between(0, 50))
  download_iv$add_rule("download_combineh", ~ if(!is.logical(.)) "Do not hack the app.")
  download_iv$add_rule("download_combineh_width", sv_integer())
  download_iv$add_rule("download_combineh_width", sv_between(0, 50))
  download_iv$add_rule("download_combineh_height", sv_integer())
  download_iv$add_rule("download_combineh_height", sv_between(0, 50))
  download_iv$add_rule("download_combinev", ~ if(!is.logical(.)) "Do not hack the app.")
  download_iv$add_rule("download_combinev_width", sv_integer())
  download_iv$add_rule("download_combinev_width", sv_between(0, 50))
  download_iv$add_rule("download_combinev_height", sv_integer())
  download_iv$add_rule("download_combinev_height", sv_between(0, 50))
  download_iv$add_rule("download_unit", sv_in_set(c("cm", "in", "mm")))
  download_iv$add_rule("download_dpi", sv_integer())
  download_iv$add_rule("download_dpi", sv_between(72, 4800))
  download_iv$add_rule("download_plot_filetype", sv_in_set(c("tiff", "jpg", "png", "pdf", "eps")))
  download_iv$add_rule("download_dataset", ~ if(!is.logical(.)) "Do not hack the app.")
  download_iv$add_rule("download_upload", ~ if(!is.logical(.)) "Do not hack the app.")
  download_iv$add_rule("download_data_filetype", sv_in_set(c("txt", "csv1", "csv2")))
  download_iv$add_rule("download_references_filetype", sv_in_set(c("docx", "txt")))
  
  contribute_iv <- InputValidator$new()
  contribute_iv$add_rule("contribute_sep", sv_in_set(c(",", ";", "\t")))
  contribute_iv$add_rule("contribute_dec", sv_in_set(c(",", ".")))
  contribute_iv$add_rule("contribute_quote", sv_in_set(c("'", '"', "")))
  contribute_iv$add_rule("contribute_user", sv_regex("<|>", "Must not contain < or >.", invert = TRUE))
  contribute_iv$add_rule("contribute_type", sv_in_set(c("new", "update")))
  contribute_iv$add_rule("contribute_doi", sv_regex("<|>", "Must not contain < or >.", invert = TRUE))
  contribute_iv$add_rule("contribute_citation", sv_regex("<|>", "Must not contain < or >.", invert = TRUE))
  contribute_iv$add_rule("contribute_comments", sv_regex("<|>", "Must not contain < or >.", invert = TRUE))
  contribute_iv$add_rule("contribute_checklist", sv_in_set(letters[1:6]))
  
  iv$add_validator(database_iv)
  iv$add_validator(general_iv)
  iv$add_validator(map_iv)
  iv$add_validator(plot_iv)
  iv$add_validator(upload_iv)
  iv$add_validator(download_iv)
  iv$add_validator(contribute_iv)
  
  iv$enable()
  
  # Status handler ----------------------------------------------------------
  status <- reactiveValues(reset = TRUE)
  
  observeEvent(input$upload_reset, {
    status$reset <- TRUE
    autopick_data <- NULL
    filter$country <- NULL
    filter$province <- NULL
    filter$area <- NULL
  })
  
  observeEvent(input$upload_file, {
    status$reset <- FALSE
  })
  
  
  # Databases: Reference data  ----------------------------------------------  
  
  # The input variable "database" is saved and allocated to choose from different datasets, must be validated if it becomes active
  
  database <- reactive({
    
    req(database_iv$is_valid(), general_iv$is_valid())
    
    if (input$data_clean) {data <- data_clean} else {data <- data_complete}
    
    data <- data %>%
      filter(if(!is.null(input$filter_country)) Country %in% input$filter_country else TRUE) %>%
      filter({
        if (!is.null(input$filter_province) | !is.null(input$filter_area)) {
          (if(!is.null(input$filter_province)) `Political province/region` %in% input$filter_province else `Political province/region` == TRUE) | 
            (if(!is.null(input$filter_area)) `Mining area` %in% input$filter_area else `Mining area` == TRUE)
        } else {
          TRUE
        }
      }) %>%
      filter(if(!is.null(input$filter_site)) `Mining site` %in% input$filter_site else TRUE) %>%
      filter(if(!is.null(input$filter_commodity)) str_detect(`Metal (what can be produced by smelting)`, str_c(input$filter_commodity, collapse = "|")) else TRUE) %>%
      filter(if(!is.null(input$filter_mineral)) str_detect(`Sample description (minerals)`, str_c(input$filter_mineral, collapse = "|"))  else TRUE) %>%
      filter(if(!is.null(input$filter_geolAge)) `Geol. period` %in% input$filter_geolAge else TRUE) %>%
      filter(if(!is.null(input$filter_instrument)) `Instrument used` %in% input$filter_instrument else TRUE) %>%
      filter(if(!is.null(input$filter_year)) between(year, input$filter_year[1], input$filter_year[2]) else TRUE) %>%
      filter(if(all(!is.null(input$data_unknown), input$data_unknown)) !.data[[input$group]] == "unknown" else TRUE) %>%
      filter(if(all(!is.null(input$location_accuracy), input$location_accuracy)) {str_detect(database$`Location precision`, "exact|Exact")} else TRUE)
    
    if (dim(data)[1] == 0) {data <- NULL}
    
    data
    
  }) 
  
  # Databases: user data  --------------------------------------------------
  custom_data <- reactive({
    
    req(upload_iv$is_valid())
    
    if (!status$reset) {
      
      validate(need(tools::file_ext(input$upload_file$datapath) %in% c("csv", "txt"), "Please upload a csv or txt file."))
      
      upload_data <- read.delim(
        input$upload_file$datapath,
        header = TRUE,
        sep = input$sep,
        quote = input$quote,
        dec = input$dec
      )
      
      validate(need(ncol(upload_data) >= 2, "A problem occurred while parsing your file. Please chose the appropriate parameters for reading your data."))
      
      colnames(upload_data) <- stringr::str_to_lower(colnames(upload_data))
      
      colnames(upload_data) <- stringr::str_replace_all(colnames(upload_data), pattern = ".*6.*4.*", "206Pb/204Pb")
      colnames(upload_data) <- stringr::str_replace_all(colnames(upload_data), pattern = ".*7.*4.*", "207Pb/204Pb")
      colnames(upload_data) <- stringr::str_replace_all(colnames(upload_data), pattern = ".*8.*4.*", "208Pb/204Pb")
      colnames(upload_data) <- stringr::str_replace_all(colnames(upload_data), pattern = ".*4.*6.*", "204Pb/206Pb")
      colnames(upload_data) <- stringr::str_replace_all(colnames(upload_data), pattern = ".*7.*6.*", "207Pb/206Pb")
      colnames(upload_data) <- stringr::str_replace_all(colnames(upload_data), pattern = ".*8.*6.*", "208Pb/206Pb")
      colnames(upload_data) <- stringr::str_replace_all(colnames(upload_data), pattern = ".*6.*7.*", "206Pb/207Pb")
      colnames(upload_data) <- stringr::str_replace_all(colnames(upload_data), pattern = ".*8.*7.*", "208Pb/207Pb")
      colnames(upload_data) <- stringr::str_replace_all(colnames(upload_data), pattern = ".*lat.*", "latitude")
      colnames(upload_data) <- stringr::str_replace_all(colnames(upload_data), pattern = ".*l.*ng.*", "longitude")
      colnames(upload_data) <- stringr::str_replace_all(colnames(upload_data), pattern = ".*ample.*", "sample")
      colnames(upload_data) <- stringr::str_replace_all(colnames(upload_data), pattern = ".*gr.*", "group")
      
      if ("sample" %in% names(upload_data)) {upload_data$sample <- as.character(upload_data$sample)}
      if ("group" %in% names(upload_data)) {upload_data$group <- as.character(upload_data$group)}
      
      validate(need(length(setdiff(names(upload_data), c("206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb", "204Pb/206Pb", "207Pb/206Pb", "208Pb/206Pb", "206Pb/207Pb", "208Pb/207Pb", "latitude", "longitude", "sample", "group"))) == 0, "One or more columns in your data set are not supported by GlobaLID. For a list of supported columns, see chapter 'Upload and display of your data' in the instructions."))
      
      if ("206Pb/204Pb" %in% names(upload_data)) {validate(need(is.numeric(upload_data$`206Pb/204Pb`), "Columns for isotope ratios must contain only numeric values."))}
      if ("207Pb/204Pb" %in% names(upload_data)) {validate(need(is.numeric(upload_data$`207Pb/204Pb`), "Columns for isotope ratios must contain only numeric values."))}
      if ("208Pb/204Pb" %in% names(upload_data)) {validate(need(is.numeric(upload_data$`208Pb/204Pb`), "Columns for isotope ratios must contain only numeric values."))}
      if ("204Pb/206Pb" %in% names(upload_data)) {validate(need(is.numeric(upload_data$`204Pb/206Pb`), "Columns for isotope ratios must contain only numeric values."))}
      if ("207Pb/206Pb" %in% names(upload_data)) {validate(need(is.numeric(upload_data$`207Pb/206Pb`), "Columns for isotope ratios must contain only numeric values."))}
      if ("208Pb/206Pb" %in% names(upload_data)) {validate(need(is.numeric(upload_data$`208Pb/206Pb`), "Columns for isotope ratios must contain only numeric values."))}
      if ("206Pb/207Pb" %in% names(upload_data)) {validate(need(is.numeric(upload_data$`206Pb/207Pb`), "Columns for isotope ratios must contain only numeric values."))}
      if ("208Pb/207Pb" %in% names(upload_data)) {validate(need(is.numeric(upload_data$`208Pb/207Pb`), "Columns for isotope ratios must contain only numeric values."))}
      
      if ("latitude" %in% names(upload_data)) {
        validate(need(is.numeric(upload_data$latitude), "Columns for coordinates must contain only numeric values."))
        validate(need({min(upload_data$latitude, na.rm = TRUE) >= -90 & max(upload_data$latitude, na.rm = TRUE) <= 90}, "One or more of the latitude coordinates is out of bounds."))
        validate(need("longitude" %in% names(upload_data), "Please provide also the coordinates for the longitude or no coordinates at all."))
      }
      
      if ("longitude" %in% names(upload_data)) {
        validate(need(is.numeric(upload_data$longitude), "Columns for coordinates must contain only numeric values."))
        validate(need({min(upload_data$longitude, na.rm = TRUE) >= -180 & max(upload_data$longitude, na.rm = TRUE) <= 180}, "One or more of the longitude coordinates is out of bounds."))
        validate(need("latitude" %in% names(upload_data), "Please provide also the coordinates for the latitude or no coordinates at all."))
      }
      
      upload_data <- LI_ratios_all(upload_data)
      upload_data <- cbind(upload_data, LI_model_age(upload_data$`206Pb/204Pb`, upload_data$`207Pb/204Pb`, upload_data$`208Pb/204Pb`, model = "all"))
      
      if ("group" %in% colnames(upload_data)) {
        upload_data$tooltip <- upload_data$group
      } else {upload_data$group <- "This study"}
      
      if ("sample" %in% colnames(upload_data)) {
        upload_data$tooltip <- paste(upload_data$group, upload_data$sample, sep = "<br>")
      } else {
        upload_data$tooltip <- upload_data$group
      }
      
      upload_data
      
    } else {
      NULL
    }
    
  })
  
  # Auto-Pick data based on upload ------------------------------------------
  filter <- reactiveValues(
    country = NULL, 
    province = NULL, 
    area = NULL
  )
  
  observeEvent(input$autopick, {  
    autopick_data <- reactive({
      
      if (input$data_clean) {data <- data_clean} else {data <- data_complete}
      
      suppressWarnings(
        filter(data, between(`206Pb/204Pb`, min(custom_data()$`206Pb/204Pb`), max(custom_data()$`206Pb/204Pb`))) %>%
          union(filter(data, between(`207Pb/204Pb`, min(custom_data()$`207Pb/204Pb`), max(custom_data()$`207Pb/204Pb`)))) %>%
          union(filter(data, between(`208Pb/204Pb`, min(custom_data()$`208Pb/204Pb`), max(custom_data()$`208Pb/204Pb`)))) %>%
          union(filter(data, between(`206Pb/207Pb`, min(custom_data()$`206Pb/207Pb`), max(custom_data()$`206Pb/207Pb`)))) %>%
          union(filter(data, between(`208Pb/207Pb`, min(custom_data()$`208Pb/207Pb`), max(custom_data()$`208Pb/207Pb`)))) %>%
          union(filter(data, between(`204Pb/206Pb`, min(custom_data()$`204Pb/206Pb`), max(custom_data()$`204Pb/206Pb`)))) %>%
          union(filter(data, between(`207Pb/206Pb`, min(custom_data()$`207Pb/206Pb`), max(custom_data()$`207Pb/206Pb`)))) %>%
          union(filter(data, between(`208Pb/206Pb`, min(custom_data()$`208Pb/206Pb`), max(custom_data()$`208Pb/206Pb`))))
      )
      
    })
    
    filter$country <- unique(autopick_data()$Country)
    
    filter$province <- unique(autopick_data()$`Political province/region`)
    
    filter$area <- unique(autopick_data()$`Mining area`)
    
  })
  
  # Data filter: Control Panel Output ---------------------------------------
  
  output$filter_countryOut <- renderUI({
    
    if (input$data_clean) {data <- data_clean} else {data <- data_complete}
    
    selectizeInput("filter_country", "Countries", 
                   choices = sort(unique(data$Country)), 
                   selected = filter$country, multiple = TRUE)
  })
  
  output$filter_provinceOut <- renderUI({
    
    if (input$data_clean) {data <- data_clean} else {data <- data_complete}
    
    selectizeInput("filter_province", "Modern provinces (of selected countries)", 
                   choices = unique(data$`Political province/region`[data$Country %in% input$filter_country]),
                   selected = filter$province, multiple = TRUE)
  })
  
  output$filter_areaOut <- renderUI({
    
    if (input$data_clean) {data <- data_clean} else {data <- data_complete}
    
    selectizeInput("filter_area", "Mining Area (of selected countries)", 
                   choices = unique(data$`Mining area`[data$Country %in% input$filter_country]),
                   selected = filter$area, multiple = TRUE)
  })
  
  output$filter_siteOut <- renderUI({
    
    if (input$data_clean) {data <- data_clean} else {data <- data_complete}
    
    selectizeInput("filter_site", "Sites (of selected mining areas and provinces)", 
                   choices = unique(data$`Mining site`[data$`Political province/region` %in% input$filter_province | data$`Mining area` %in% input$filter_area]),
                   selected = NULL, multiple = TRUE)
  })
  
  output$filter_geolAgeOut <- renderUI({
    
    if (input$data_clean) {data <- data_clean} else {data <- data_complete}
    
    selectizeInput("filter_geolAge", "Geological Age", 
                   choices = unique(data %>% filter(if(!is.null(input$filter_country)) Country %in% input$filter_country else TRUE) %>%
                                      filter({
                                        if (!is.null(input$filter_province) | !is.null(input$filter_area)) {
                                          (if(!is.null(input$filter_province)) `Political province/region` %in% input$filter_province else `Political province/region` == TRUE) | 
                                            (if(!is.null(input$filter_area)) `Mining area` %in% input$filter_area else `Mining area` == TRUE)
                                        } else {
                                          TRUE
                                        }
                                      }) %>%
                                      filter(if(!is.null(input$filter_site)) `Mining site` %in% input$filter_site else TRUE) %>%
                                      pull(`Geol. period`)), 
                   selected = NULL, multiple = TRUE)
  })
  
  output$filter_commodityOut <- renderUI({
    
    if (input$data_clean) {data <- data_clean} else {data <- data_complete}
    
    checkboxGroupInput("filter_commodity", "Targeted metal", 
                       choices = unique(data %>% filter(if(!is.null(input$filter_country)) Country %in% input$filter_country else TRUE) %>%
                                          filter({
                                            if (!is.null(input$filter_province) | !is.null(input$filter_area)) {
                                              (if(!is.null(input$filter_province)) `Political province/region` %in% input$filter_province else `Political province/region` == TRUE) | 
                                                (if(!is.null(input$filter_area)) `Mining area` %in% input$filter_area else `Mining area` == TRUE)
                                            } else {
                                              TRUE
                                            }
                                          }) %>%
                                          filter(if(!is.null(input$filter_site)) `Mining site` %in% input$filter_site else TRUE) %>%
                                          select(`Metal (what can be produced by smelting)`) %>%
                                          drop_na() %>%
                                          mutate(sep_num = str_count(`Metal (what can be produced by smelting)`, ";")) %>%
                                          separate(`Metal (what can be produced by smelting)`, into = paste0("Metal", seq(1:1+max(.$sep_num))), sep = "; ", fill = "right") %>%
                                          pivot_longer(contains("Metal")) %>%
                                          select(value) %>%
                                          drop_na() %>%
                                          distinct() %>%
                                          arrange(value) %>%
                                          pull(value)
                       ), 
                       selected = NULL, inline = TRUE)
    
  })
  
  output$filter_mineralOut <- renderUI({
    
    if (input$data_clean) {data <- data_clean} else {data <- data_complete}
    
    selectizeInput("filter_mineral", "Ore minerals", 
                   choices = unique(data %>% filter(if(!is.null(input$filter_country)) Country %in% input$filter_country else TRUE) %>%
                                      filter({
                                        if (!is.null(input$filter_province) | !is.null(input$filter_area)) {
                                          (if(!is.null(input$filter_province)) `Political province/region` %in% input$filter_province else `Political province/region` == TRUE) | 
                                            (if(!is.null(input$filter_area)) `Mining area` %in% input$filter_area else `Mining area` == TRUE)
                                        } else {
                                          TRUE
                                        }
                                      }) %>%
                                      filter(if(!is.null(input$filter_site)) `Mining site` %in% input$filter_site else TRUE) %>%
                                      select(`Sample description (minerals)`) %>%
                                      drop_na() %>%
                                      mutate(sep_num = str_count(`Sample description (minerals)`, ";")) %>%
                                      separate(`Sample description (minerals)`, into = paste0("Mineral", seq(1:1+max(.$sep_num))), sep = "; ", fill = "right") %>%
                                      pivot_longer(contains("Mineral")) %>%
                                      select(value) %>%
                                      drop_na() %>%
                                      distinct() %>%
                                      arrange(value) %>%
                                      pull(value)
                   ), 
                   selected = NULL, multiple = TRUE)
    
  })
  
  output$filter_instrumentOut <- renderUI({
    
    if (input$data_clean) {data <- data_clean} else {data <- data_complete}
    
    checkboxGroupInput("filter_instrument", "Instrument used", 
                       choices = unique(data %>% filter(if(!is.null(input$filter_country)) Country %in% input$filter_country else TRUE) %>%
                                          filter({
                                            if (!is.null(input$filter_province) | !is.null(input$filter_area)) {
                                              (if(!is.null(input$filter_province)) `Political province/region` %in% input$filter_province else `Political province/region` == TRUE) | 
                                                (if(!is.null(input$filter_area)) `Mining area` %in% input$filter_area else `Mining area` == TRUE)
                                            } else {
                                              TRUE
                                            }
                                          }) %>%
                                          filter(if(!is.null(input$filter_site)) `Mining site` %in% input$filter_site else TRUE) %>%
                                          select(`Instrument used`) %>%
                                          drop_na() %>%
                                          mutate(sep_num = str_count(`Instrument used`, ",")) %>%
                                          separate(`Instrument used`, into = paste0("Instrument", seq(1:1+max(.$sep_num))), sep = ",", fill = "right") %>%
                                          pivot_longer(contains("Instrument")) %>%
                                          select(value) %>%
                                          drop_na() %>%
                                          distinct() %>%
                                          pull(value)
                       ), 
                       selected = NULL, inline = TRUE)
    
  })
  
  output$filter_yearOut <- renderUI({
    
    if (input$data_clean) {data <- data_clean} else {data <- data_complete}
    
    year <- data %>% filter(if(!is.null(input$filter_country)) Country %in% input$filter_country else TRUE) %>%
      filter({
        if (!is.null(input$filter_province) | !is.null(input$filter_area)) {
          (if(!is.null(input$filter_province)) `Political province/region` %in% input$filter_province else `Political province/region` == TRUE) | 
            (if(!is.null(input$filter_area)) `Mining area` %in% input$filter_area else `Mining area` == TRUE)
        } else {
          TRUE
        }
      }) %>%
      filter(if(!is.null(input$filter_site)) `Mining site` %in% input$filter_site else TRUE) %>%
      select(year) %>%
      summarise(across(year, list(min = min, max = max), na.rm = TRUE)) %>%
      pivot_longer(contains("year")) %>%
      pull(value)
    
    sliderInput("filter_year", label = "Publication year", min = year[1], max = year[2], value = year, sep = "")
  })
  
  # tab "map" output --------------------------------------------------------
  
  group_preview <- reactive({ as.factor(database()[[input$group]]) })
  
  output$map_box <- renderLeaflet({
    
    leaflet() %>%
      addTiles(group = "OSM") %>%
      addProviderTiles("OpenTopoMap", group = "Topo") %>%
      addProviderTiles("Stamen.TonerLite", group = "Greyscale") %>%
      addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%
      addProviderTiles("Jawg.Terrain", group = "Terrain", 
                       options = providerTileOptions(accessToken = "3uEzD8dtzA3IWndPaCQLaxyvwJ7GiltndZozyeuEDLn0Q8uOkT26FahxEvKgDQvb")) %>%
      addScaleBar(position = "bottomleft") %>%
      addEasyButton(easyButton(
        icon = "globe", title = "Zoom to data", ### button not rendering
        onClick = JS("function(btn, map) {
       var groupLayer = map.layerManager.getLayerGroup('Database');
       map.fitBounds(groupLayer.getBounds());
    }"))) %>%
      addLayersControl(
        baseGroups = c("OSM", "Topo", "Terrain", "Satellite", "Greyscale"),
        options = layersControlOptions(collapsed = TRUE),
        position = "bottomright")
  })
  
  observe({
    
    req(input$sidebar == "map")
    
    leafletProxy("map_box") %>%
      clearGroup("Database") 
    
    if (!is.null(database())) {
      
      pal <- colorFactor("viridis", group_preview() )
      
      leafletProxy("map_box") %>%
        addCircleMarkers(data = database(), color = ~pal(eval(as.symbol(input$group))), stroke = FALSE, fillOpacity = 0.5,
                         clusterOptions = markerClusterOptions(), group = "Database",
                         label = ~paste(sep = ", ",
                                        database()$`Mining area`,
                                        database()$`Mining site`,
                                        database()$`Add. information on mine`)) 
    }
    
    if (!is.null(custom_data())) {
      
      req(custom_data()$latitude, custom_data()$longitude)
      
      leafletProxy("map_box") %>%
        addCircleMarkers(data = custom_data(), color = "black", stroke = FALSE, fillOpacity = 0.5,
                         clusterOptions = markerClusterOptions(), group = "My data",
                         label = ~paste(sep = ", ",
                                        custom_data()$group,
                                        custom_data()$sample))
    }
    
    if (!is.null(database()) && !is.null(custom_data())) {
      
      custom_data()$latitude <- NA
      custom_data()$longitude <- NA
      
      leafletProxy("map_box") %>%
        addLayersControl(
          baseGroups = c("OSM", "Topo", "Terrain", "Satellite", "Greyscale"),
          overlayGroups = c("Database", "My data"),
          options = layersControlOptions(collapsed = TRUE),
          position = "bottomright") %>%
        fitBounds(lng1 = min(database()$Longitude, custom_data()$longitude, na.rm = TRUE), lat1 = min(database()$Latitude, custom_data()$latitude, na.rm = TRUE),
                  lng2 = max(database()$Longitude, custom_data()$longitude, na.rm = TRUE), lat2 = max(database()$Latitude, custom_data()$latitude, na.rm = TRUE))
      
    } else {
      leafletProxy("map_box") %>%
        addLayersControl(
          baseGroups = c("OSM", "Topo", "Terrain", "Satellite", "Greyscale"),
          overlayGroups = c("Database"),
          options = layersControlOptions(collapsed = TRUE),
          position = "bottomright") %>%
        fitBounds(lng1 = min(database()$Longitude, custom_data()$longitude, na.rm = TRUE), lat1 = min(database()$Latitude, custom_data()$latitude, na.rm = TRUE),
                  lng2 = max(database()$Longitude, custom_data()$longitude, na.rm = TRUE), lat2 = max(database()$Latitude, custom_data()$latitude, na.rm = TRUE))
    } 
  })
  
  observeEvent(input$upload_reset, {
    
    req(input$sidebar == "map")
    
    leafletProxy("map_box") %>%
      clearGroup("My data") %>%
      addLayersControl(
        baseGroups = c("OSM", "Topo", "Topo light", "Satellite", "Greyscale"),
        overlayGroups = c("Database"),
        options = layersControlOptions(collapsed = TRUE),
        position = "bottomright") %>%
      fitBounds(lng1 = min(database()$Longitude, na.rm = TRUE), lat1 = min(database()$Latitude, na.rm = TRUE),
                lng2 = max(database()$Longitude, na.rm = TRUE), lat2 = max(database()$Latitude, na.rm = TRUE))
  })
  
  observeEvent(input$jump_button, {
    
    req(map_iv$is_valid(), input$sidebar == "map")
    
    leafletProxy("map_box") %>%
      setView(input$jump_lon, input$jump_lat, 10)
  })
  
  output$preview <- renderPlot({
    
    req(map_iv$is_valid(), general_iv$is_valid())
    
    if (!is.null(database())) {
      
      switch(input$preview_control,
             "A" = {
               preview_plot1 <- ggplot(database(), aes(x = `206Pb/204Pb`, y = `207Pb/204Pb`, colour = group_preview())) +
                 labs(x = NULL, y = expression(""^"207"*"Pb/"^"204"*"Pb"), color = NULL)
               preview_plot2 <- ggplot(database(), aes(x = `206Pb/204Pb`, y = `208Pb/204Pb`, colour = group_preview())) +
                 labs(x = expression(""^"206"*"Pb/"^"204"*"Pb"), y = expression(""^"208"*"Pb/"^"204"*"Pb"), color = NULL)
             },
             "B" = {
               preview_plot1 <- ggplot(database(), aes(x = `207Pb/206Pb`, y = `208Pb/206Pb`, colour = group_preview())) +
                 labs(x = NULL, y = expression(""^"208"*"Pb/"^"206"*"Pb"), color = NULL)
               preview_plot2 <- ggplot(database(), aes(x = `207Pb/206Pb`, y = `204Pb/206Pb`, colour = group_preview())) +
                 labs(x = expression(""^"207"*"Pb/"^"206"*"Pb"), y = expression(""^"204"*"Pb/"^"206"*"Pb"), color = NULL)
             },
             "C" = {
               preview_plot1 <- ggplot(database(), aes(x = mu_SK75, y = Model_Age_SK75, colour = group_preview())) +
                 labs(x = NULL, y = "Model Age [Ma]", color = NULL) + 
                 scale_y_reverse()
               preview_plot2 <- ggplot(database(), aes(x = mu_SK75, y = kappa_SK75, colour = group_preview())) +
                 labs(x = expression(mu), y = expression(kappa), color = NULL)
             }
      )
      
      preview_plot1 <- preview_plot1 +
        geom_point(alpha = 0.5, size = 2) +
        scale_color_viridis_d() +
        theme_bw() +
        theme(legend.position = "hidden")
      
      preview_plot2 <- preview_plot2 +
        geom_point(alpha = 0.5, size = 2) +
        scale_color_viridis_d() +
        theme_bw() +
        theme(legend.position = "hidden")
      
      if (!is.null(custom_data())) {
        preview_plot1 <- preview_plot1 + 
          geom_point(data = custom_data(), color = "black", aes(shape = group), size = 1.5)
        
        preview_plot2 <- preview_plot2 + 
          geom_point(data = custom_data(), color = "black", aes(shape = group), size = 1.5)
      }
      
    grid_arrange_shared_legend(preview_plot1, preview_plot2, position = "bottom", ncol = 1, nrow = 2)
      
    } else {
      ggplot() + 
        geom_text(aes(x = 1, y = 1, label = str_wrap("No data selected!", width = 40)), size = 5) + 
        theme_void()
    }
    
  })
  
  # tab "Explore" output ----------------------------------------------------     
  
  plot_explore1 <- plotExploreServer("plot1", database, custom_data, {req(general_iv$is_valid()); reactive(input$group)}, {req(plot_iv$is_valid()); reactive(input$palette)})
  plot_explore2 <- plotExploreServer("plot2", database, custom_data, reactive(input$group), reactive(input$palette))
  
  # tab "Upload" output -----------------------------------------------------
  
  output$file_upload <- renderUI({
    input$upload_reset 
    fileInput("upload_file", "Choose file (.csv, .txt)", 
              accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv", ".txt")
    )
  })
  
  output$upload_preview <- DT::renderDataTable({
    
    if (!status$reset) {
      
      validate(need(!is.null(custom_data()), "A problem occurred while parsing your file. Please make sure it is in the correct format and the appropriate parameters for reading your data are chosen."))
      
      DT::datatable(custom_data() %>% select(-tooltip), rownames = FALSE, class = "compact", options = list(scrollX = TRUE))
    }
  })
  
  # tab "Download" output ---------------------------------------------------
  
  output$download <- downloadHandler(
    
    filename = "GlobaLID_download.zip",
    
    content = function(fname) {
      
      req(download_iv$is_valid(), database_iv$is_valid())
      
      tmpdir <- tempdir()
      
      filename_plot1 <- NULL
      filename_plot2 <- NULL
      filename_combineh <- NULL
      filename_combinev <- NULL
      filename_database  <- NULL
      filename_upload <- NULL
      
      if (any(input$download_plot1, input$download_plot2, input$download_combineh, input$download_combinev)) {
        
        plot_explore1 <- plot_explore1() + 
          labs(subtitle = paste("Made with GlobaLID 1.0, database status: ", format(update_database,"%Y-%m-%d"), sep = " ")) + 
          theme(plot.subtitle = element_text(colour = "grey50", size = 8))
        
        plot_explore2 <- plot_explore2() + 
          theme(plot.subtitle = element_text(colour = "grey50", size = 8)) 
        
        if (input$download_plot1 == TRUE) {
          filename_plot1 <- paste("Plot1", input$download_plot_filetype, sep = ".")
          
          ggsave(filename_plot1, plot = plot_explore1, path = tmpdir, device = input$download_plot_filetype,
                 width = input$download_plot1_width, height = input$download_plot1_height, unit = input$download_unit,
                 dpi = input$download_dpi)
        } 
        
        if (input$download_plot2 == TRUE) {
          filename_plot2 <- paste("Plot2", input$download_plot_filetype, sep = ".")
          
          plot_explore2 +
            labs(subtitle = paste("Made with GlobaLID 1.0, database status: ", format(update_database,"%Y-%m-%d"), sep = " ")) +
            ggsave(filename_plot2, path = tmpdir, device = input$download_plot_filetype,
                   width = input$download_plot2_width, height = input$download_plot2_height, unit = input$download_unit,
                   dpi = input$download_dpi)
        } 
        
        if (input$download_combineh == TRUE) {
          filename_combineh <- paste("Plot_combine_hor", input$download_plot_filetype, sep = ".")
          
          plot_down1 <- plot_explore1 + 
            theme(legend.position = "hidden")
          
          plot_down2 <- plot_explore2 + 
            labs(subtitle = paste("")) +
            theme(legend.position = "hidden")
          
          plot_h <- grid_arrange_shared_legend(plot_down1, plot_down2, position = "bottom", ncol = 2, nrow = 1)
          
          ggsave(filename_combineh, plot = plot_h, path = tmpdir, device = input$download_plot_filetype,
                 width = input$download_combineh_width, height = input$download_combineh_height, unit = input$download_unit,
                 dpi = input$download_dpi)
        } 
        
        if (input$download_combinev == TRUE) {
          filename_combinev <- paste("Plot_combine_ver", input$download_plot_filetype, sep = ".")
          
          plot_down1 <- plot_explore1 + 
            theme(legend.position = "hidden")
          
          plot_down2 <- plot_explore2 + 
            theme(legend.position = "hidden")
          
          plot_v <- grid_arrange_shared_legend(plot_down1, plot_down2, position = "right", ncol = 1, nrow = 2)
          
          ggsave(filename_combinev, plot = plot_v, path = tmpdir, device = input$download_plot_filetype,
                 width = input$download_combinev_width, height = input$download_combinev_height, unit = input$download_unit,
                 dpi = input$download_dpi)
        } 
      }
      
      if (input$download_dataset == TRUE) {
        filename_database <- paste("Database", str_extract(input$download_data_filetype, "[:alpha:]*"), sep = ".")
        
        database_down <- database() %>%
          select(-Status, -Note, -year, -tooltip)
        
        switch(input$download_data_filetype, 
               "txt" = write.table(database_down, file.path(tmpdir, filename_database), sep = "\t", row.names = FALSE), 
               "csv1" = write.csv(database_down, file.path(tmpdir, filename_database)),
               "csv2" = write.csv2(database_down, file.path(tmpdir, filename_database))
        )
      } 
      
      if (input$download_upload == TRUE & !is.null(input$upload_file$datapath)) {
        filename_upload <- paste("Upload_enhanced", str_extract(input$download_data_filetype, "[:alpha:]*"), sep = ".")
        
        upload_down <- custom_data() %>%
          select(-tooltip)
        
        switch(input$download_data_filetype, 
               "txt" = write.table(upload_down, file.path(tmpdir, filename_upload), sep = "\t", row.names = FALSE), 
               "csv1" = write.csv(upload_down, file.path(tmpdir, filename_upload)),
               "csv2" = write.csv2(upload_down, file.path(tmpdir, filename_upload))
        )
      } 
      
      references <- database() %>%
        select(Reference, doi) %>%
        mutate(doi = if_else(str_detect(doi, "https"), doi, paste0("https://doi.org/", doi))) %>%
        mutate(sep_num = str_count(Reference, ";")) %>%
        separate(Reference, into = paste0("Citation", seq(1:1+max(.$sep_num))), sep = "; ", fill = "right") %>%
        unite("Citation1", Citation1, doi, sep = " ", na.rm = TRUE) %>%
        pivot_longer(contains("Citation"), values_drop_na = TRUE) %>%
        select(value) %>%
        distinct() %>%
        arrange(value) %>%
        pull()
      
      filename_references <- paste("References_FilterSettings", str_extract(input$download_references_filetype, "[:alpha:]*"), sep = ".")
      
      filter_setting <- list("Country" = if (!is.null(input$filter_country)) {input$filter_country} else {"Filter not set"}, 
                             "Province" = if (!is.null(input$filter_province)) {input$filter_province} else {"Filter not set"}, 
                             "Area" = if (!is.null(input$filter_area)) {input$filter_area} else {"Filter not set"}, 
                             "Site" = if (!is.null(input$filter_site)) {input$filter_site} else {"Filter not set"}, 
                             "GeolAge" = if (!is.null(input$filter_geolAge)) {input$filter_geolAge} else {"Filter not set"}, 
                             "Minerals" = if (!is.null(input$filter_mineral)) {input$filter_mineral} else {"Filter not set"}, 
                             "Commodity" = if (!is.null(input$filter_commodity)) {input$filter_commodity} else {"Filter not set"}, 
                             "Instrument" = if (!is.null(input$filter_instrument)) {input$filter_instrument} else {"Filter not set"}, 
                             "Year" = input$filter_year
      )
      
      switch(input$download_references_filetype, 
             "txt" = {
               cat(rep("#", 76), sep = "", fill = 76, file = file.path(tmpdir, filename_references), append = FALSE)
               cat(rep("#", 3), rep(" ", 70), rep("#", 3), sep = "", fill = 76, file = file.path(tmpdir, filename_references), append = TRUE)
               cat(rep("#", 3), rep(" ", 31), "GlobaLID", rep(" ", 31), rep("#", 3), sep = "", fill = 76, file = file.path(tmpdir, filename_references), append = TRUE)
               cat(rep("#", 3), rep(" ", 70), rep("#", 3), sep = "", fill = 76, file = file.path(tmpdir, filename_references), append = TRUE)
               cat(rep("#", 3), rep(" ", 20), "(database status:  ", format(update_database,"%Y-%m-%d"), ")", rep(" ", 20), rep("#", 3), sep = "", fill = 76, file = file.path(tmpdir, filename_references), append = TRUE)
               cat(rep("#", 3), rep(" ", 70), rep("#", 3), sep = "", fill = 76, file = file.path(tmpdir, filename_references), append = TRUE)
               cat(rep("#", 3), rep(" ", 15), "Filter settings and References of export", rep(" ", 15), rep("#", 3), sep = "", fill = 76, file = file.path(tmpdir, filename_references), append = TRUE)
               cat(rep("#", 3), rep(" ", 70), rep("#", 3), sep = "", fill = 76, file = file.path(tmpdir, filename_references), append = TRUE)
               cat(rep("#", 76), sep = "", fill = 76, file = file.path(tmpdir, filename_references), append = TRUE)
               cat("\nFilter Settings ", sep = "\n", fill = 76, file = file.path(tmpdir, filename_references), append = TRUE)
               cat("\n Country: ", sep = "", file = file.path(tmpdir, filename_references), append = TRUE)
               cat(" ", filter_setting$Country, sep = "\n  ", file = file.path(tmpdir, filename_references), append = TRUE)
               cat("\n Province: ", sep = "", file = file.path(tmpdir, filename_references), append = TRUE)
               cat(" ", filter_setting$Province, sep = "\n  ", file = file.path(tmpdir, filename_references), append = TRUE)
               cat("\n Mining Area: ", sep = "", file = file.path(tmpdir, filename_references), append = TRUE)
               cat(" ", filter_setting$Area, sep = "\n  ", file = file.path(tmpdir, filename_references), append = TRUE)
               cat("\n Mining site: ", sep = "", file = file.path(tmpdir, filename_references), append = TRUE)
               cat(" ", filter_setting$Site, sep = "\n  ", file = file.path(tmpdir, filename_references), append = TRUE)
               cat("\n Geological Age: ", sep = "", file = file.path(tmpdir, filename_references), append = TRUE)
               cat(" ", filter_setting$GeolAge, sep = "\n  ", file = file.path(tmpdir, filename_references), append = TRUE)
               cat("\n Minerals: ", sep = "", file = file.path(tmpdir, filename_references), append = TRUE)
               cat(" ", filter_setting$Minerals, sep = "\n  ", file = file.path(tmpdir, filename_references), append = TRUE)
               cat("\n Commodity: ", sep = "", file = file.path(tmpdir, filename_references), append = TRUE)
               cat(" ", filter_setting$Commodity, sep = "\n  ", file = file.path(tmpdir, filename_references), append = TRUE)
               cat("\n Instrument: ", sep = "", file = file.path(tmpdir, filename_references), append = TRUE)
               cat(" ", filter_setting$Instrument, sep = "\n  ", file = file.path(tmpdir, filename_references), append = TRUE)
               cat("\n Publication year (range): ", sep = "", file = file.path(tmpdir, filename_references), append = TRUE)
               cat(" ", filter_setting$Year, sep = "\n  ", file = file.path(tmpdir, filename_references), append = TRUE)
               cat("\n", rep("=", 76), sep = "", fill = 77, file = file.path(tmpdir, filename_references), append = TRUE)
               cat("\nReferences ", sep = "", fill = 76, file = file.path(tmpdir, filename_references), append = TRUE)
               cat(" ", references, sep = "\n ", file = file.path(tmpdir, filename_references), append = TRUE)
             }, 
             "docx" = {
               rmarkdown::render("doc/References_export_word.Rmd", output_file = file.path(tmpdir, filename_references), envir = new.env(),
                                 params = list(references = references, 
                                               filter_setting = filter_setting, 
                                               update_database = update_database
                                 )
               )
             }
      )
      
      fs <- c(filename_references, filename_plot1, filename_plot2, filename_combineh, filename_combinev, filename_database, filename_upload)
      
      zip(zipfile=fname, files=fs, root = tmpdir)
    },
    
    contentType = "application/zip"
  )
  
  # tab "Contribute" output -------------------------------------------------
  
    # Check contributor's password --------------------------------------------
  
  pwd_check <- function(failed = FALSE) {
    modalDialog(
      title = "Password required",
      "Please identify yourself as registered contributor: ",
      textInput("password", NULL, placeholder = "Enter password here"),
      if (failed) {
        div(tags$b("Wrong password", style = "color: red;"))
      },
      footer = tagList(
        actionButton("confirm_cancel", "Cancel"),
        actionButton("confirm_pwd", "OK")
      ),
      easyClose = FALSE,
      fade = FALSE
    )
  }
  
  observeEvent(input$sidebar, {
    
    req(general_iv$is_valid(), input$sidebar == "contribute")
    
    showModal(pwd_check())
    
  })
  
  observeEvent(input$confirm_pwd, {
    
    req(general_iv$is_valid())
    
    if (input$password == credentials$pwd) {
      removeModal()
    } else {
      showModal(pwd_check(failed = TRUE))
    }
  })
  
  observeEvent(input$confirm_cancel, {
    
    req(general_iv$is_valid())
    
    updateTabItems(session, "sidebar", "map")
    removeModal()
  })
  
    # Output ------------------------------------------------------------------
  
  contribute_data <- reactive({
    
    req(contribute_iv$is_valid(), input$contribute_data)
    
    validate(need(tools::file_ext(input$contribute_data$datapath) %in% c("csv", "txt"), "Please upload a csv or txt file."))
    
    contribute_upload <- read.delim(
        input$contribute_data$datapath,
        header = TRUE,
        sep = input$contribute_sep,
        quote = input$contribute_quote,
        dec = input$contribute_dec
        )

    validate(need(ncol(contribute_upload) >= 2, "A problem occurred while parsing your file. Please chose the appropriate parameters for reading your data."))
    validate(need(length(setdiff(names(contribute_upload), c("Country", "Mining area",	"Mining site", "Add. information on mine", "Latitude", "Longitude", "Location precision", "Tectonic/geolog. super unit", "Tectonic/geolog. unit", "Tectonic/geolog. subunit", "Deposit type", "Metal (what can be produced by smelting)", "Sample description (minerals)", "Sample number", "Geol. period", "206Pb/204Pb", "207Pb/204Pb", "208Pb/204Pb", "206Pb/207Pb", "208Pb/207Pb", "204Pb/206Pb", "207Pb/206Pb", "208Pb/206Pb", "Instrument used", "year", "doi", "Reference", "Note"))) == 0, 
                  "One or more columns of the uploaded data are not supported by GlobaLID or filled in automatically. Please remove or rename them."))
    validate(need(all(c("Country", "Mining area",	"Mining site", "Add. information on mine", "Latitude", "Longitude", "Location precision", "Tectonic/geolog. super unit", "Tectonic/geolog. unit", "Tectonic/geolog. subunit", "Deposit type", "Metal (what can be produced by smelting)", "Sample description (minerals)", "Sample number", "Geol. period", "Instrument used", "year", "doi", "Reference", "Note") %in% names(contribute_upload)), 
                  "One or more columns with essential meta-information are missing. Please use the provided template and leave them empty if the information is not available."))
    
    validate(need(all(is.numeric(contribute_upload$Latitude), is.numeric(contribute_upload$Longitude)), "Columns for coordinates must contain only numeric values."))
    validate(need({min(contribute_upload$Latitude, na.rm = TRUE) >= -90 & max(contribute_upload$Latitude, na.rm = TRUE) <= 90}, "One or more of the latitude coordinates is out of bounds."))
    validate(need({min(contribute_upload$Longitude, na.rm = TRUE) >= -180 & max(contribute_upload$Longitude, na.rm = TRUE) <= 180}, "One or more of the longitude coordinates is out of bounds."))
    validate(need(all(contribute_upload[,grepl("20", colnames(contribute_upload))]), "Columns for isotope ratios must contain only numeric values."))
    validate(need(is.numeric(contribute_upload$year), "'year' must contain only numeric values."))
    
    contribute_upload
    
  })
  
  output$contribute_data_preview <- DT::renderDataTable({
    
   req(contribute_iv$is_valid())
    
    DT::datatable(contribute_data(), rownames = FALSE, class = "compact", options = list(scrollX = TRUE))
    
  })
  
  observeEvent(input$contribute_submit, {
    
    req(contribute_iv$is_valid())
    
    if (identical(input$contribute_checklist, letters[1:6])) {
      
      if (!is.null(input$contribute_data)) {status_data <- TRUE} else {status_data <- FALSE}
      if (!is.null(input$contribute_publication) || input$contribute_type == "update") {status_pdf <- TRUE} else {status_pdf <- FALSE}
      if (any(input$contribute_doi == "n/a", stringr::str_detect(input$contribute_doi, pattern = "10\\.[:digit:]*/[:graph:]*"), input$contribute_type == "update")) {status_doi <- TRUE} else {status_doi <- FALSE}
      if (!input$contribute_citation == "" || input$contribute_type == "update") {status_citation <- TRUE} else {status_citation <- FALSE}
      if (!is.null(input$contribute_type)) {status_type <- TRUE} else {status_type <- FALSE}
      if (!input$contribute_user == "") {status_user <- TRUE} else {status_user <- FALSE}
      if (!input$contribute_comments == "") {status_comment <- TRUE} else {status_comment <- FALSE}
      
      if (all(status_data, status_pdf, status_doi, status_citation, status_type, status_user, status_comment)) {
        
        tmpdir <- tempdir()
        
        # save files 
        # wrap all together and store/send, add timestamp
        
        #showModal(
        #  modalDialog(
        #    title = div("Contribution successful", style = "color: green;"),  
        #    "Thank you for you supporting GlobaLID!", 
        #    footer = modalButton("Close"), 
        #    easyClose = TRUE, 
        #    fade = FALSE
        #  )
        #)
        
      } else {
        showModal(
          modalDialog(
            title = div("Contribution submission failed", style = "color: red;"),  
            "The following information must be provided but is not: ", 
            if (!status_data) {div("- The data to add or update")},
            if (!status_pdf) {div("- The pdf of the publication")},
            if (!status_doi) {div("- A (valid) doi of the publication (or 'n/a' if no DOI is assigned)")},
            if (!status_citation) {div("- Full citation of the publication")},
            if (!status_type) {div("- The type of contribution (new or update)")},
            if (!status_user) {div("- Your name")},
            if (!status_comment) {"- A short summary of the contribution"},
            footer = modalButton("Close"), 
            easyClose = TRUE, 
            fade = FALSE
          )
        )
      }
      
    } else {
      
      showModal(
        modalDialog(
          title = div("Contribution submission failed", style = "color: red;"), 
          "Please confirm that your contribution is in accordance with ALL items on the checklist.",
          footer = modalButton("Close"), 
          easyClose = TRUE, 
          fade = FALSE
        )
      )
    }
    
    
  })
  
  # clean up ----------------------------------------------------------------
  
  #  session$onSessionEnded(function() {
  #   if (!is.null(fs)) {file.remove(fs, "download.zip")}
  #  })
  
}

shinyApp(ui, server)