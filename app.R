# 1 Header --------------------------------------------------------

# Chart creator script
# app.R
# Original author: Ewout Jaspers
# Original date: 24/01/2020
# Release date: 24/01/2020
# Version 0.1
# R version 3.3.2 (2016-10-31)
# Written: R-Studio Desktop
# Script to produce ED-Weekly publication

# Load Packages -----------------------------------------------------------

library(dplyr)
library(shiny)
library(readr)
library(jsonlite)
library(stringr)

# Define UI for application that draws a histogram
ui <- fluidPage(
  theme = "nss-shiny.css",
  HTML(
    '<script src="https://d3js.org/d3.v4.min.js"></script></script> <style>html{font-size: 16px}</style>'
  ),
  div(class = "main-title", h1("Chart settings creator")),
  p(
    "This is the first version of the chart settings file creator. With this creator a chart settings file can be created and previewed "
  ),
  uiOutput("files_select"),
  fluidRow(column(
    3,
    actionButton("submit_filename", "Submit file names")
  ),
  column(7, uiOutput(
    "scroll_indication"
  ))),
  div(class = "created-files",
      h3(textOutput("DataFileNameOut")),
      h3(textOutput(
        "BaseSettingFileName"
      )),
      h3(textOutput(
        "SettingFileNameOut"
      ))),
  fluidRow(
    column(4, class = "sidebar",
           uiOutput("setting_list")),
    column(8,
           uiOutput("radio"),
           uiOutput("chart"))
    
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  list_js_files <- c(list.files(path = "./www/js")) %>%
    str_subset(pattern = "(?i)js$")
  
  list_settings_files <- c(list.files(path = "./www/settings")) %>%
    str_subset(pattern = "(?i)json$")
  
  list_data_files <- c(list.files(path = "./www/data")) %>%
    str_subset(pattern = "(?i)csv$")
  
  list_settings_new <- c("New settings file", list_settings_files)
  
  if(file.exists("./save_selection.rds")){
    prev_selection <- readRDS("./save_selection.rds")
  } else {
    prev_selection <- list(
      pub_date = Sys.Date(),
      chart_topic = "Chart topic",
      chart_number = 1,
      data_filename = "",
      settings_filename = "",
      js_filename = ""
    )
  }
  
  output$files_select <- renderUI(
    div(
      dateInput(
        "pub_date",
        "Publication date: ",
        value = prev_selection$pub_date,
        min = NULL,
        max = NULL,
        format = "yyyy-mm-dd",
        startview = "month",
        weekstart = 1,
        language = "en",
        width = NULL
      ),
      p(
        "Chart topic, data file or settings file cannot contain %, this can cause an error when downloading the settings file."
      ),
      textInput(
        "chart_topic",
        label = "Chart topic: ",
        value = prev_selection$chart_topic
      ),
      numericInput(
        "chart_number",
        "Chart number: ",
        prev_selection$chart_number,
        min = 1,
        max = 4
      ),
      selectizeInput(
        'DataFileNameIn',
        label = "Data file (only csv files):",
        choices = list_data_files,
        selected = prev_selection$data_filename,
        multiple = FALSE,
        width = "500px",
        options = list(create = TRUE, maxItems = 1)
      ),
      selectizeInput(
        'SettingsFileNameIn',
        label = "Setting files (only json files):",
        choices = list_settings_new,
        selected = prev_selection$settings_filename,
        multiple = FALSE,
        width = "500px",
        options = list(create = TRUE, maxItems = 1)
      ),
      selectizeInput(
        'JsFileNameIn',
        label = "Select JavaScript file (use to most recent version): ",
        choices = list_js_files,
        selected = prev_selection$js_filename,
        multiple = FALSE,
        width = "500px",
        options = list(create = TRUE, maxItems = 1)
      )
    )
  )
  
  
  observeEvent(input$submit_filename, {
    output$scroll_indication <-
      renderUI(
        HTML(
          '<p class="look_down">&darr; Set and download chart settings below &darr;</p>'
        )
      )
    
    save_selection <- list(
      pub_date = input$pub_date,
      chart_topic = input$chart_topic,
      chart_number = input$chart_number,
      data_filename = input$DataFileNameIn,
      settings_filename = input$SettingsFileNameIn,
      js_filename = input$JsFileNameIn
    )
    saveRDS(save_selection, "./save_selection.rds")
    
    output$radio <-
      renderUI(div(
        p(
          "Please note previous setting files might be overwritten when creating the charts. (If the chart number, chart name, data file and publication date are identical)."
        ),
        actionButton(
          "create_settings_file",
          "Create/reload and test settings",
          style = "margin-bottom: 10px;"
        ),
        radioButtons(
          "size",
          "Chart size:",
          c(
            "Small" = "320px",
            "Medium" = "740px",
            "Large" = "980px",
            "Responsive" = "auto"
          )
        )
      ))
    
    filename <- paste0("./www/data/", input$DataFileNameIn)
    
    data <- read_csv(filename)
    
    if (input$SettingsFileNameIn != "New settings file") {
      settings_filename <-
        paste0("./www/settings/", input$SettingsFileNameIn)
      start_settings <- read_json(settings_filename)
    }
    
    col_names <- colnames(data)
    
    
    publication_date <- format(input$pub_date, "%Y%m%d")
    
    
    output_settings_file <-
      paste0(
        publication_date,
        "-s",
        input$chart_number,
        "-",
        input$chart_topic,
        "-",
        str_sub(input$DataFileNameIn, end = -5) ,
        "-js0.2.json"
      )
    
    output$DataFileNameOut <-
      renderText({
        paste0("Used data file: ", input$DataFileNameIn)
      })
    
    output$BaseSettingFileName <-
      renderText({
        paste0("Base settings file: ", input$SettingsFileNameIn)
      })
    
    output$SettingFileNameOut <-
      renderText({
        paste0("Output settings file: ", output_settings_file)
      })
    
    set_date_cat <- col_names[1]
    set_dateFormatInput <- "%Y-%m-%d"
    set_locationNames <- col_names[2:3]
    set_locationLabels <- NULL
    set_variableNames <- col_names[4]
    set_variableLabels <- NULL
    set_measureName <- NULL
    set_measureLabel <- NULL
    set_xformat <- "%Y"
    set_xlabel <- "x label"
    set_ylabel <- "y label"
    set_title <- ""
    set_dateFormatTooltip <- "%B %Y"
    set_chartType <- "line"
    set_margin_top <- 25
    set_margin_right <- 20
    set_margin_bottom <- 45
    set_margin_left <- 65
    set_sm_ticks <- 4
    set_md_ticks <- 4
    set_lg_ticks <- 6
    set_line_stroke <- 2
    set_colour_I <- "#004785"
    set_colour_II <- "#007db3"
    set_colour_III <- "#4c7ea9"
    set_colour_IV <- "#99daf5"
    set_colour_V <- "#4cbeed"
    set_colour_VI <- "#99b5ce"
    
    if (input$SettingsFileNameIn != "New settings file") {
      set_date_cat <- start_settings$dateCatName
      set_dateFormatInput <- start_settings$dateFormatInput
      set_locationNames <-
        paste0(unlist(start_settings$locationNames))
      set_locationLabels <-
        paste0(unlist(start_settings$locationLabels))
      set_variableNames <-
        paste0(unlist(start_settings$variableNames))
      set_variableLabels <-
        paste0(unlist(start_settings$variableLabels))
      set_measureName <-
        paste0(unlist(start_settings$measureName))
      set_measureLabel <-
        paste0(unlist(start_settings$measureLabel))
      set_xformat <- start_settings$xFormatString
      set_xlabel <- start_settings$xlabel
      set_ylabel <- start_settings$ylabel
      set_title <- start_settings$title
      set_dateFormatTooltip <- start_settings$dateFormatTooltip
      set_chartType <- start_settings$chartType
      set_margin_top <- start_settings$margin$top
      set_margin_right <- start_settings$margin$right
      set_margin_bottom <- start_settings$margin$bottom
      set_margin_left <- start_settings$margin$left
      set_sm_ticks <- start_settings$numberofticks$sm
      set_md_ticks <- start_settings$numberofticks$md
      set_lg_ticks <- start_settings$numberofticks$lg
      set_line_stroke <- start_settings$lineStroke
      set_colour_I <- start_settings$colours$I
      set_colour_II <- start_settings$colours$II
      set_colour_III <- start_settings$colours$III
      set_colour_IV <- start_settings$colours$IV
      set_colour_V <- start_settings$colours$V
      set_colour_VI <- start_settings$colours$VI
    }
    
    date_format_input_choices <-
      c(
        "%d/%m/%Y",
        "%d/%m/%y",
        "%Y-%m-%d",
        "%d-%m-%Y",
        "%d-%m-%y",
        "%Y/%m/%d",
        "%Y%m%d",
        "%d%m%Y"
      )
    
    xformat_choices <-
      c(
        "%Y",
        "%m%Y",
        "%m-%Y",
        "%m %Y",
        "%b-%Y",
        "%b%Y",
        "%b %Y",
        "%d %b %Y",
        "%d-%b-%Y",
        "%B %Y",
        "%d %B %Y",
        "%d-%m-%Y",
        "%d/%m/%Y"
      )
    
    dateFormatTooltip_choices <-
      c(
        "%Y",
        "%m%Y",
        "%m-%Y",
        "%m %Y",
        "%b-%Y",
        "%b%Y",
        "%b %Y",
        "%d %b %Y",
        "%d-%b-%Y",
        "%B %Y",
        "%d %B %Y",
        "%d-%m-%Y",
        "%d/%m/%Y"
      )
    
    
    output$setting_list <- renderUI({
      div(
        h4("Settings menu"),
        tabsetPanel(
          type = "tabs",
          tabPanel(
            "Input date",
            div(
              selectizeInput(
                'date_or_cat',
                label = "Date or category column name: ",
                choices = col_names,
                selected = set_date_cat,
                multiple = FALSE,
                options = list(create = TRUE, maxItems = 1)
              ),
              p(textOutput("date_format")),
              selectizeInput(
                'date_format_input',
                label = "Date format in file: ",
                choices = date_format_input_choices,
                selected = set_dateFormatInput,
                multiple = FALSE,
                options = list(create = TRUE, maxItems = 1)
              ),
              p("Date format can be typed.")
            )
          ),
          tabPanel("Dropdowns",
                   div(
                     div(class = "setting-option setting-option__no-border",
                         fluidRow(
                           column(
                             12,
                             class = "col-lg-6",
                             selectizeInput(
                               'location_names_1',
                               label = "NHSBoard column:",
                               choices = col_names,
                               selected = set_locationNames[1],
                               multiple = FALSE,
                               options = list(create = TRUE, maxItems = 1)
                             )
                           ),
                           column(
                             12,
                             class = "col-lg-6",
                             selectizeInput(
                               'location_labels_1',
                               label = "NHSBoard label:",
                               choices = set_locationLabels,
                               selected = set_locationLabels[1],
                               multiple = FALSE,
                               options = list(create = TRUE, maxItems = 1)
                             )
                           )
                         )),
                     div(
                       class = "setting-option",
                       p("Location column and label (optional)"),
                       fluidRow(
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'location_names_2',
                             label = "Location column:",
                             choices = col_names,
                             selected = set_locationNames[2],
                             multiple = FALSE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         ),
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'location_labels_2',
                             label = "Location label: ",
                             choices = set_locationLabels,
                             selected = set_locationLabels[2],
                             multiple = FALSE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         )
                       )
                     ),
                     div(
                       class = "setting-option",
                       p("Measure column and label (optional)"),
                       fluidRow(
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'measure_name',
                             label = "Measure column: ",
                             choices = col_names,
                             selected = set_measureName,
                             multiple = TRUE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         ),
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'measure_label',
                             label = "Measure label:",
                             choices = set_measureLabel ,
                             selected = set_measureLabel ,
                             multiple = TRUE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         )
                       )
                     )
                   )),
          tabPanel("Variables",
                   div(
                     div(
                       class = "setting-option setting-option__no-border",
                       p("variable 1 column and label"),
                       fluidRow(
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'var_names_1',
                             label = "Variable 1 column:",
                             choices = col_names,
                             selected = set_variableNames[1],
                             multiple = TRUE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         ),
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'var_labels_1',
                             label = "Variable 1 label:",
                             choices = set_variableLabels,
                             selected = set_variableLabels[1],
                             multiple = TRUE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         )
                       )
                     ),
                     div(
                       class = "setting-option",
                       p("variable 2 column and label (optional)"),
                       fluidRow(
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'var_names_2',
                             label = "Variable 2 column:",
                             choices = col_names,
                             selected = set_variableNames[2],
                             multiple = TRUE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         ),
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'var_labels_2',
                             label = "Variable 2 label:",
                             choices = set_variableLabels,
                             selected = set_variableLabels[2],
                             multiple = TRUE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         )
                       )
                     ),
                     div(
                       class = "setting-option",
                       p("variable 3 column and label (optional)"),
                       fluidRow(
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'var_names_3',
                             label = "Variable 3 column:",
                             choices = col_names,
                             selected = set_variableNames[3],
                             multiple = TRUE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         ),
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'var_labels_3',
                             label = "Variable 3 label:",
                             choices = set_variableLabels,
                             selected = set_variableLabels[3],
                             multiple = TRUE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         )
                       )
                     ),
                     div(
                       class = "setting-option",
                       p("variable 4 column and label (optional)"),
                       fluidRow(
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'var_names_4',
                             label = "Variable 4 column:",
                             choices = col_names,
                             selected = set_variableNames[4],
                             multiple = TRUE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         ),
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'var_labels_4',
                             label = "Variable 4 label:",
                             choices = set_variableLabels,
                             selected = set_variableLabels[4],
                             multiple = TRUE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         )
                       )
                     ),
                     div(
                       class = "setting-option",
                       p("variable 5 column and label (optional)"),
                       fluidRow(
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'var_names_5',
                             label = "Variable 5 column:",
                             choices = col_names,
                             selected = set_variableNames[5],
                             multiple = TRUE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         ),
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'var_labels_5',
                             label = "Variable 5 label:",
                             choices = set_variableLabels,
                             selected = set_variableLabels[5],
                             multiple = TRUE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         )
                       )
                     ),
                     div(
                       class = "setting-option",
                       p("variable 6 column and label (optional)"),
                       fluidRow(
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'var_names_6',
                             label = "Variable 6 column:",
                             choices = col_names,
                             selected = set_variableNames[6],
                             multiple = TRUE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         ),
                         column(
                           12,
                           class = "col-lg-6",
                           selectizeInput(
                             'var_labels_6',
                             label = "Variable 6 label:",
                             choices = set_variableLabels,
                             selected = set_variableLabels[6],
                             multiple = TRUE,
                             options = list(create = TRUE, maxItems = 1)
                           )
                         )
                       )
                     )
                   )),
          tabPanel(
            "Text",
            div(
              selectizeInput(
                'xformat',
                label = "Set x axis date format:",
                choices = xformat_choices ,
                selected = set_xformat,
                multiple = FALSE,
                options = list(create = TRUE, maxItems = 1)
              ),
              p("Date format can be typed."),
              textInput("xlabel",  label = "Set x label:", value = set_xlabel),
              textInput("ylabel",  label = "Set y label:", value = set_ylabel),
              textInput("title",  label = "Title: ", value = set_title),
              selectizeInput(
                'date_format_tooltip',
                label = "Date format in tooltip: ",
                choices = dateFormatTooltip_choices,
                selected = set_dateFormatTooltip,
                multiple = FALSE,
                options = list(create = TRUE, maxItems = 1)
              )
            )
          ),
          tabPanel(
            "Format",
            div(
              selectInput(
                "chart_type",
                "Select chart type:",
                c(
                  "Line chart" = "line",
                  "Bar chart" = "bar",
                  "Category bar chart" = "catbar"
                ),
                selected = set_chartType
              ),
              
              p("Margin:"),
              fluidRow(
                column(
                  5,
                  numericInput(
                    "margin_top",
                    "Top: ",
                    set_margin_top,
                    min = 0,
                    max = 100
                  )
                ),
                column(
                  5,
                  numericInput(
                    "margin_bottom",
                    "Bottom: ",
                    set_margin_bottom,
                    min = 0,
                    max = 100
                  )
                ),
                column(
                  5,
                  numericInput(
                    "margin_left",
                    "Left: ",
                    set_margin_left,
                    min = 0,
                    max = 100
                  )
                ),
                column(
                  5,
                  numericInput(
                    "margin_right",
                    "Right: ",
                    set_margin_right,
                    min = 0,
                    max = 100
                  )
                )
              ),
              p("Number of ticks by screen size:"),
              fluidRow(
                column(
                  3,
                  numericInput(
                    "ticks_sm",
                    "Small: ",
                    set_sm_ticks,
                    min = 0,
                    max = 10
                  )
                ),
                column(
                  3,
                  numericInput(
                    "ticks_md",
                    "Medium: ",
                    set_md_ticks,
                    min = 0,
                    max = 10
                  )
                ),
                column(
                  3,
                  numericInput(
                    "ticks_lg",
                    "Large: ",
                    set_lg_ticks,
                    min = 0,
                    max = 10
                  )
                )
              ),
              numericInput(
                "line_stroke",
                "Adjust line stroke: ",
                set_line_stroke,
                min = 1,
                max = 4
              ),
              div(
                class = "setting-option",
                p("Colours"),
                div(
                  textInput("colourI",  label = "Set colour I:", value = set_colour_I),
                  textInput("colourII",  label = "Set colour II:", value = set_colour_II),
                  textInput("colourIII",  label = "Set colour III:", value = set_colour_III),
                  textInput("colourIV",  label = "Set colour IV:", value = set_colour_IV),
                  textInput("colourV",  label = "Set colour V:", value = set_colour_V),
                  textInput("colourVI",  label = "Set colour VI:", value = set_colour_VI)
                )
              )
              
            )
          )
        )
        
      )
      
      
    })
    
  })
  
  observeEvent(input$date_or_cat, {
    output$date_format <- renderText({
      filename <- paste0("./www/data/", input$DataFileNameIn)
      
      basedata <- read_csv(filename)
      
      row1_date <- basedata %>%
        select(input$date_or_cat)
      
      return(
        paste0(
          "Preview of format in the selected date column (Please note that excel tends to show date columns as dd/mm/yyy even if the actual data is yyyy-mm-dd): ",
          row1_date[[1, 1]]
        )
      )
      
    })
    
    
  })
  
  observeEvent(input$create_settings_file, {
    measureName <- input$measure_name
    measureLabel <- input$measure_label
    
    if (is.null(measureName)) {
      measureName <- ""
      measureLabel <- ""
      
    }
    
    location_names_all <-
      c(input$location_names_1, input$location_names_2)
    location_names_all <-
      location_names_all[location_names_all != ""]
    
    
    location_labels_all <-
      c(input$location_labels_1, input$location_labels_2)
    location_labels_all <-
      location_labels_all[location_labels_all != ""]
    
    
    var_names_all <-
      c(
        input$var_names_1,
        input$var_names_2,
        input$var_names_3,
        input$var_names_4,
        input$var_names_5,
        input$var_names_6
      )
    var_names_all <- var_names_all[var_names_all != ""]
    
    
    var_labels_all <-
      c(
        input$var_labels_1,
        input$var_labels_2,
        input$var_labels_3,
        input$var_labels_4,
        input$var_labels_5,
        input$var_labels_6
      )
    var_labels_all <- var_labels_all[var_labels_all != ""]
    
    
    
    setting_list <- list(
      "chartType" = unbox(input$chart_type),
      "dateFormatInput" = unbox(input$date_format_input),
      "dateFormatTooltip" = unbox(input$date_format_tooltip),
      "locationNames" = location_names_all,
      "locationLabels" = location_labels_all,
      "dateCatName" = unbox(input$date_or_cat),
      "measureName" = unbox(measureName),
      "measureLabel" = unbox(measureLabel),
      "variableNames" = var_names_all,
      "variableLabels" = var_labels_all,
      "title" = unbox(input$title),
      "xlabel" = unbox(input$xlabel),
      "ylabel" = unbox(input$ylabel),
      "xFormatString" = unbox(input$xformat),
      "circlesize" = unbox(6),
      "highlight_circlesize" = unbox(10),
      "colourNumbers " = c("I", "II", "III", "IV", "V", "VI"),
      "colours" = list(
        "I" = unbox(input$colourI),
        "II" =  unbox(input$colourII),
        "III" = unbox(input$colourIII),
        "IV" = unbox(input$colourIV),
        "V" = unbox(input$colourV),
        "VI" = unbox(input$colourVI)
      ),
      "font_family" = unbox("'Helvetica Neue', Helvetica, Arial, sans-serif"),
      "lineStroke" = unbox(input$line_stroke),
      "margin" = list(
        "top" = unbox(input$margin_top),
        "right" = unbox(input$margin_right),
        "bottom" = unbox(input$margin_bottom),
        "left" = unbox(input$margin_left)
      ),
      "ticks" = unbox(4),
      "numberofticks" = list(
        "sm" = unbox(input$ticks_sm),
        "md" = unbox(input$ticks_md),
        "lg" = unbox(input$ticks_lg)
      ),
      "minWidth" = unbox(320),
      "maxWidth" = unbox(920),
      "divWidth" = unbox(320),
      "h" = unbox(600),
      "w" = unbox(400)
    )
    
    filename <- paste0("./www/data/", input$DataFileNameIn)
    
    publication_date <- format(input$pub_date, "%Y%m%d")
    
    base_list <- toJSON(setting_list, pretty = TRUE)
    
    output_settings_file <-
      paste0(
        publication_date,
        "-s",
        input$chart_number,
        "-",
        input$chart_topic,
        "-",
        str_sub(input$DataFileNameIn, end = -5)  ,
        "-js0.2.json"
      )
    
    write(base_list,
          paste0("./www/settings/", output_settings_file))
    
    
    script_code <-
      paste0(
        '<script id="jscode" src="./js/allinone.v.0.3.min.js" type="text/javascript" ',
        'data-filename="./data/',
        input$DataFileNameIn,
        '" ',
        ' data-id="chart-1" ',
        ' data-settings="./settings/',
        output_settings_file,
        '" ',
        '></script>'
      )
    
    
    download_code <-
      
      style <- reactive({
        style <- paste0('margin-bottom: 20px;  width: ', input$size, ';')
        return(style)
        
      })
    
    output$chart <- renderUI({
      div(
        h4("Preview page"),
        p(
          "The created settings file can be found in the settings folder: www/settings. Place this file together
          with the data file in the publications folder for the PHI publications team."
        ),
        a(
          "Download settings file*",
          class = "btn",
          href = paste0("/settings/", output_settings_file),
          download = ""
        ),
        div(id = "chart-1", style = style()),
        p(
          "* The settings file can also be found in the www/settings folder"
        ),
        HTML(script_code)
        )
      
    })
    
    
  })

}

# Run the application
shinyApp(ui = ui, server = server)
