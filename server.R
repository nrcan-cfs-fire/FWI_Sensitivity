## Shiny app to display the sensitivity of FWI Indices to weather variables.
library(shiny)
library(raster)
library(rgdal)
library(spatial.tools)
library(cffdrs)

shinyServer(function(input, output) {
   
  ## Calculate the FWI Information for the table
  # This needs to be reactive in order to intake information from the input fields
  fwi.data <- reactive({
    
    fwi(input = data.frame(lat  = 55, 
                           long = -115, 
                           yr   = 2016, 
                           mon  = input$month, 
                           day  = 15,
                           temp = input$temp, 
                           rh   = input$rh, 
                           ws   = input$ws, 
                           prec = input$prec),
        init = c(input$ffmc,
                 input$dmc,
                 input$dc),
        out = "fwi")
    
  })
  
  ## Render the table, the data is considered a function because it is a reactive input
  output$fwitable <- renderTable({
    
  fwi.data()
    
  })
  #input <- data.frame(wxvar = "Wind Speed",fwivar = "Fire Weather Index",ffmc = 75,dmc = 20, dc = 300, temp = 25, rh = 30, prec=0, ws=15,month=7, fixy="Yes")
  
  ## Establish the ranges for each weather variable
  t.rng <- -5:40
  rh.rng <- 0:100
  ws.rng <- 0:75
  prec.rng <- 0:50
  
  ## Set some vertical limits for the FWI system
  
  ffmc.lim <- c(0,101)
  dmc.lim  <- c(0,200) 
  dc.lim   <- c(0,1000)
  isi.lim  <- c(0,100)
  bui.lim  <- c(0,200)
  fwi.lim  <- c(0,100)
  

  
  ## Build the plot for the FWI graph
  output$fwi.graph <- renderPlot({
    
      ## Need a vector of values to plot
      value <- vector()
      
      var.rng <- if(input$wxvar == "Temperature") {t.rng} else {
                 if(input$wxvar == "Relative Humidity") {rh.rng} else {
                 if(input$wxvar == "Wind Speed") {ws.rng} else {
                 if(input$wxvar == "Precipitation") {prec.rng} } } }
      
      fwi.var <- paste0(if(input$fwivar == "Fine Fuel Moisture Code"){"FFMC"},
                        if(input$fwivar == "Duff Moisture Code"){"DMC"},
                        if(input$fwivar == "Drought Code"){"DC"},
                        if(input$fwivar == "Initial Spread Index"){"ISI"},
                        if(input$fwivar == "Build Up Index"){"BUI"},
                        if(input$fwivar == "Fire Weather Index"){"FWI"})
      
      ## A for loop was used to calculate the individual FWI Indices, otherwise fwi() sees the data as continuous and creates unreasonable results.
      for(i in seq_along( var.rng ) ) {
        value[[i]] <-fwi(data.frame(lat  = 55,
                                    long = -115,
                                    yr   = 2016,
                                    mon  = input$month,
                                    day  = 15,
                                    temp = if(input$wxvar == "Temperature"){t.rng[i]} else {input$temp},
                                    rh   = if(input$wxvar == "Relative Humidity"){rh.rng[i]} else {input$rh},
                                    ws   = if(input$wxvar == "Wind Speed"){ws.rng[i]} else {input$ws},
                                    prec = if(input$wxvar == "Precipitation"){prec.rng[i]} else {input$prec}),
                         init = c(input$ffmc,
                                  input$dmc,
                                  input$dc),
                         out = "fwi")[,fwi.var]}
      
      sel_lim <- if(input$fixy == "Yes"){ 
                        { if(fwi.var == "FFMC"){ffmc.lim} else{
                          if(fwi.var == "DMC"){dmc.lim} else{
                          if(fwi.var == "DC"){dc.lim} else{
                          if(fwi.var == "ISI"){isi.lim} else{
                          if(fwi.var == "BUI"){bui.lim} else{
                          if(fwi.var == "FWI"){fwi.lim} }}}}} } } else {
                            No = c(min(value),max(value))}
    
    ## Begin the plotting function
    plot(main= paste0(input$fwivar," With a Variable ",input$wxvar ),
         
         ## X label
         xlab = input$wxvar,
         
         ## Y label
         ylab = input$fwivar,
         
         ## X values, based on inputs selected
         x = var.rng,
         
         ## Remove the axis, to be re-added later
         xaxt="n",
         
         ## If the X variable is RH, reverse the values of Y to indicate 100% RH is low hazard
         y = if(input$wxvar == "Relative Humidity"){rev(value)} else {value},
         
         ylim = c(sel_lim[1],sel_lim[2]),
         
         xaxs="i", yaxs="i",
    
         ## Make a line plot
         type="l"
         )
    
    ## Set up the axis
    axis(side = 1,
         
         at = var.rng,
         
         labels = if(input$wxvar == "Temperature"){t.rng} else {
                  if(input$wxvar == "Relative Humidity"){rev(rh.rng)} else {
                  if(input$wxvar == "Wind Speed"){ws.rng} else {
                  if(input$wxvar == "Precipitation"){prec.rng} } } })
    
    pt.x <- if(input$wxvar == "Temperature"){input$temp} else {
            if(input$wxvar == "Relative Humidity"){100 - input$rh} else {
            if(input$wxvar == "Wind Speed"){input$ws} else {
            if(input$wxvar == "Precipitation"){input$prec} } } }
    
    pt.y <- fwi(data.frame(lat  = 55, 
                           long = -115, 
                           yr   = 2016, 
                           mon  = input$month, 
                           day  = 15,
                           temp = input$temp, 
                           rh   = input$rh, 
                           ws   = input$ws, 
                           prec = input$prec),
                init = c(input$ffmc,
                         input$dmc,
                         input$dc),
                out = "fwi")[ , fwi.var ]
    
   # # Add a point based on the information selected by the user
    points(x = pt.x,
           y = pt.y, cex=2, pch=19, col="red")
    
    lines(x = c(-10, pt.x, pt.x),
          y = c(pt.y, pt.y, -10), cex=2, col="red")
    
  })
})
