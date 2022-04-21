## Shiny app to display the sensitivity of FWI Indices to weather variables.

library(shiny)
library(raster)
library(rgdal)
library(spatial.tools)
library(cffdrs)

#fwi
# Define UI for application that draws a histogram
shinyUI(
  fixedPage(
  
  # Application title
  titlePanel("Fire Weather Index Visualization Tool"),
  hr(),
  print("This tool is intended to display the effect of weather variables on the forecast FWI indices. In effect it is a \"what-if\" calculator for tomorrows FWI values."),
  sidebarLayout(

    ## Side bar create an inset gery panel
    sidebarPanel(
      
      ## Temperature Slider Bar
      sliderInput("temp",
                  "Temperature:",
                  min = -5,
                  max = 40,
                  value = 22),
      ## Relative Humidity Slider Bar
      sliderInput("rh",
                  "Relative Humidity:",
                  min = 0,
                  max = 100,
                  value = 30),
      ## Wind Speed Slider Bar
      sliderInput("ws",
                  "Wind Speed:",
                  min = 0,
                  max = 75,
                  value = 15),
      ## Precipitation Slider Bar
      sliderInput("prec",
                  "Precipitation:",
                  min = 0,
                  max = 50,
                  value = 0),
      ## Month of the Year Slider Bar
      sliderInput("month",
                  "Month of Interest",
                  min=1,
                  max=12,
                  value = 7),
      ## Numeric FFMC Starting Code
      numericInput("ffmc",
                   "Starting Fine Fuel Moisture Code",
                   min=0, max=101,value = 85),
      ## Numeric DMC Starting Code
      numericInput("dmc",
                   "Starting Duff Moisture Code",
                   min=0, max=1000,value = 20),
      ## Numeric DC Starting Code
      numericInput("dc",
                   "Starting Drought Code",
                   min=0, max=2500,value = 300)
      
    ),
    
    ## The main panel is the main spot to get thing shown
    mainPanel(
      
      ## Tabular view of FWI outputs from the above numeric values
       tableOutput("fwitable"),
    
       ## Selector for what weather variable should be plotted (X-Axis)
       div(style="display: inline-block",selectInput("wxvar",
                          label = "Weather Variable",
                          choices = c("Temperature",
                                      "Relative Humidity",
                                      "Wind Speed",
                                      "Precipitation"),
                          selected = "Wind Speed")),
      
       ## Selector for what FWI variable should be plotted (Y-Axis)
       div(style="display: inline-block",selectInput("fwivar",
                          label = "Fire Weather Index",
                          choices = c("Fine Fuel Moisture Code",
                                      "Duff Moisture Code",
                                      "Drought Code",
                                      "Initial Spread Index",
                                      "Build Up Index",
                                      "Fire Weather Index"),
                          selected = "Fire Weather Index")),
       
       ## Selector for a fixed Y-axis
       div(style="display: inline-block",radioButtons(inputId = "fixy",
                                                     label = "Fixed Axes",
                                                     choices = c("Yes","No"),
                                                     selected = "No")),
        ## Plot the output
        plotOutput("fwi.graph"),
       ## Selector for what weather variable should be plotted (X-Axis)
       div(style="display: inline-block",selectInput("fuel",
                                                     label = "Fuel Type",
                                                     choices = c("C-1",
                                                                 "C-2",
                                                                 "C-3",
                                                                 "C-4",
                                                                 "C-5",
                                                                 "C-6",
                                                                 "C-7",
                                                                 "D-1",
                                                                 "D-2",
                                                                 "O-1a",
                                                                 "O-1b",
                                                                 "M-1",
                                                                 "M-2",
                                                                 "M-3",
                                                                 "M-4",
                                                                 "S-1",
                                                                 "S-2",
                                                                 "S-3"),
                                                     selected = "C-2")),
       
       ## Selector for what FWI variable should be plotted (Y-Axis)
       div(style="display: inline-block",selectInput("fbpvar",
                                                     label = "Fire Behaviour Output",
                                                     choices = c("Crown Fraction Burned",
                                                                 "Head Fire Intensity",
                                                                 "Rate of Spread (Head)",
                                                                 "Rate of Spread (Flank)",
                                                                 "Rate of Spread (Back)"),
                                                     selected = "Head Fire Intensity")),
       ## Plot the output
       plotOutput("fbp.graph")
    )

  ),
  hr(),
  print("All information freely available and reproducible using the CFFDRS R package. CFFDRS, the Canadian Forest Fire Danger Rating System is a product of the Canadian Forest Service. Accompanying documentation is available at: http://cfs.nrcan.gc.ca/pubwarehouse/pdfs/10068.pdf and its updates: http://cfs.nrcan.gc.ca/publications/download-pdf/31414")
))
