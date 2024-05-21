#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shinydashboard) #Used for boxes(), fluidPage(), fluidRow()
library(DT) #Used for Datatable rendering
library(shinyWidgets) #pickerINput; select all button
library(name) #shiny icons?
library(leaflet) #interactive maps
library(rcompanion) #histogram with normal curve
library(mapview) #to create maps from shp files
library(RColorBrewer) #create color schemes for maps
library(leafpop) #modify popup table for mapview maps
library(heplots) #chi-square plots
library(ggpubr) #qqplot


source("scripts/preprocessing.R")

# Define UI for application 
ui <- dashboardPage(
  
    # Application title
    dashboardHeader(
      title = "CalEnviro 4.0 Data"
    ),
    
    dashboardSidebar(
      sidebarMenu(
        id = 'sidebar',
        menuItem('Information', tabName = 'info', icon = icon('circle-info')),
        menuItem('Dataset', tabName = 'dataset', icon = icon('table')),
        menuItem('Filter Map By County', tabName = 'county', icon = icon('map')),
        menuItem('Filter Map By City', tabName = 'city', icon = icon('map')),
        menuItem('Normality', tabName = 'normality', icon = icon('chart-simple'))
      ),
      
      conditionalPanel(
        pickerInput(
          inputId = 'column',
          'Choose some columns',
          choices = colnames(master_df),
          selected = colnames(master_df)[1:10],
          options = list(`actions-box` = TRUE, `live-search`=TRUE),
          multiple = T
        ), condition = " input.sidebar == 'dataset' "
      ),
      
      conditionalPanel(
        pickerInput(
        inputId = 'county',
        'Choose A County',
        choices = county_list,
        options = list(`actions-box` = TRUE, `live-search`=TRUE),
        multiple = F
      ),
        condition = " input.sidebar == 'county' "
    ),
    
      conditionalPanel(
        pickerInput(
          inputId = 'popup_col_county',
          'Choose variable of interest (click on map areas for variable information)',
          choices = shp_master_names[!(shp_master_names %in% unwanted_vars)],
          selected = c(
            "total_population"
          ),
          options = list(`live-search`=TRUE, `dropup-auto`=FALSE),
          multiple = F
        ), condition = " input.sidebar == 'county' "
      ),
    
    conditionalPanel(
      pickerInput(
        inputId = 'color_col_county',
        'Choose variable to show color for',
        choices = c(scientific_cols, ethnicity_cols, 'ces_4_0_score'),
        options = list(`actions-box` = TRUE, `live-search`=TRUE, `dropup-auto`=FALSE),
        multiple = F
      ), condition = " input.sidebar == 'county' "
    ),
    
    conditionalPanel(
      pickerInput(
        inputId = 'city',
        'Choose A City',
        choices = unique(as.list(shp_and_master$approximate_location)),
        options = list(`actions-box` = TRUE, `live-search`=TRUE),
        multiple = F
      ),
      condition = " input.sidebar == 'city' "
    ),
    
    conditionalPanel(
      pickerInput(
        inputId = 'popup_col_city',
        'Choose variables of interest (click on map areas for variable information)',
        choices = shp_master_names[!(shp_master_names %in% unwanted_vars)],
        selected = c(
          "total_population"
        ),
        options = list(`live-search`=TRUE, `actions-box` = TRUE,  `dropup-auto`=FALSE),
        multiple = T
      ), condition = " input.sidebar == 'city' "
    ),
    
    conditionalPanel(
      pickerInput(
        inputId = 'color_col_city',
        'Choose variable to show color for',
        choices = c(scientific_cols, ethnicity_cols, 'ces_4_0_score'),
        options = list(`actions-box` = TRUE, `live-search`=TRUE, `dropup-auto`=FALSE),
        multiple = F
      ), condition = " input.sidebar == 'city' "
    ),
    
    
    
    conditionalPanel(
      pickerInput(
        inputId = 'normality_col',
        'Choose variable of interest',
        choices = c(scientific_cols, ethnicity_cols),
        options = list(`actions-box` = TRUE, `live-search`=TRUE),
        multiple = F
      ), condition = " input.sidebar == 'normality' "
    )
    ),
    dashboardBody(
      tabItems(
        tabItem(
          tabName = 'dataset',
          DTOutput('master_df')
        ),
        
        tabItem(
          tabName = 'county',
          leafletOutput("countymap", height = 780)
        ),
        
        tabItem(
          tabName = 'city',
          leafletOutput("citymap", height=780)
        ),
        
        tabItem(
          tabName = 'normality',
          fluidPage(
            fluidRow(
              box(plotOutput('histogram')),
              box(plotOutput('qqplot'))
            )
          )
        ),
        
        tabItem(
          tabName = 'info',
          fluidPage(
            uiOutput("pdf")
          )
        )
       
    
      )
    )
        
    )
  



# Define server logic
server <- function(input, output) {
  
  #Information
  addResourcePath("folder",paste0(getwd(), "/references"))
  output$pdf <- renderUI({
    tags$iframe(style="height:785px; width:100%", src="folder/calenviroreport.pdf")
  })
  

  #Dataset 
  choose_column <- eventReactive(input$column, {
    master_df %>% select(input$column)
  })
  
  
  #Filter by County
  choose_shpmaster <- eventReactive(input$county, {
    shp_and_master %>% filter(california_county %in% input$county)
  })
  
  choose_countyshp <- eventReactive(input$county, {
    county_shp %>% filter(NAMELSAD %in% input$county)
  })

  choose_popup_cols_county <- eventReactive(input$popup_col_county, {
    shp_and_master %>% select(input$popup_col_county)
  })
  
  choose_color_col_county <- eventReactive(input$color_col_county, {
    shp_and_master %>% select(input$color_col_county)
  })
  
  
  
  #Filter by City
  choose_shpmaster2 <- eventReactive(input$city, {
    shp_and_master %>% filter(approximate_location == input$city)
  })
  
  choose_popup_cols_city <- eventReactive(input$popup_col_city, {
    shp_and_master %>% select(input$popup_col_city)
  })
  
  choose_color_col_city <- eventReactive(input$color_col_city, {
    shp_and_master %>% select(input$color_col_city)
  })
  
  #Normality
  choose_normal_col <- eventReactive(input$normality_col, {
    master_df %>% select(input$normality_col)
  })

  
  #Dataset
  output$master_df <- renderDT(choose_column())
  
  #Filter by County
  output$countymap <- renderLeaflet(
    {
    (mapview(choose_countyshp(), zcol = "NAMELSAD", burst = FALSE, alpha.regions= 0.1, lwd = 3, popup = FALSE) +
      mapview(choose_shpmaster(),
               zcol =input$color_col_county, 
               col.regions = brewer.pal(7, "Dark2"), na.color = "#A9A9A9",
               popup = popupTable(choose_shpmaster(),
                                  zcol = colnames(choose_popup_cols_county())[1:(ncol(choose_popup_cols_county())-1)]
               )
       )
  )@map
  })
  
  
  #Filter by City
  output$citymap <- renderLeaflet(
    {
    (mapview(choose_shpmaster2(),
                 zcol =input$color_col_city, 
                 col.regions = brewer.pal(7, "Dark2"), na.color = "#A9A9A9",
                 popup = popupTable(choose_shpmaster2(),
                                    zcol = colnames(choose_popup_cols_city())[1:(ncol(choose_popup_cols_city())-1)]
                                      
                 )
            )
    )@map
      
    })
  
  #Normality
  output$histogram <- renderPlot({
    plotNormalHistogram(master_df[[input$normality_col]], breaks = "FD", main = paste("Histogram of", input$normality_col),
         xlab = input$normality_col, ylab = "Frequency")
    })

  
  output$qqplot <- renderPlot(
    {
      qqnorm(master_df[[input$normality_col]], main = paste("QQ Plot of", input$normality_col))
      qqline(master_df[[input$normality_col]])
    }
  )
  

 

  
}

# Run the application 
shinyApp(ui = ui, server = server)

