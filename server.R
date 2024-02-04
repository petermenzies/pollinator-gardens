# shiny server

print("server")

# Define server logic
shinyServer(function(input, output, session) {
  # reactive file reading ---------------------------------------
  
  # points
  points_reader <- reactiveFileReader(
    intervalMillis = 1.8e6,
    session = session,
    filePath = "data/temp/points.RDS",
    readFunc = readRDS
  )
  
  points <- reactive(points_reader())
  
  # refresh app button ----
  observeEvent(input$refresh, {
    shinyjs::js$refresh_page()
  })
  
  
  # Shape viewer -------------------------------------------------
  
  output$map <- renderLeaflet({
    points <- points()
    
    # number of shapes displayed - added to map with `addControl()`
    pointsDisplayed <- HTML({
      paste0("Gardens Displayed: ",
             div(id = "shapes-number", nrow(points)))
    })
    
    startingIconFormat <- 
      makeIcon(
        iconUrl = paste0("www/images/", points$tier, ".png"),
        iconWidth = case_when(
          points$tier == "Butterfly" ~ 25,
          points$tier == "Chrysalis" ~ 17,
          points$tier == "Caterpillar" ~ 25,
          points$tier == "Egg" ~ 25
        ),
        iconHeight = case_when(
          points$tier == "Butterfly" ~ 20,
          points$tier == "Chrysalis" ~ 20,
          points$tier == "Caterpillar" ~ 25,
          points$tier == "Egg" ~ 15
        )
      )
    
    htmlLegend <- 
      "<div style='line-height: 2;'>
       <img src='images/butterfly.png' style='width:20px; height:15px;'> Butterfly
       <br/>
       <img src='images/chrysalis.png' style='width:15px;height:20px;'> Chrysalis
       <br/>
       <img src='images/caterpillar.png' style='width:20px;height:15px;'> Caterpillar
       <br/>
       <img src='images/egg.png' style='width:20px;height:13px;'> Egg
       </div>"
    
    # render map
    leaflet(points) |>
      addTiles(
        urlTemplate = "https://mts1.google.com/vt/lyrs=s&hl=en&src=app&x={x}&y={y}&z={z}&s=G",
        attribution = "Google Earth",
        group = "Satellite"
      ) |> 
      addProviderTiles("CartoDB.Positron", group = "Street") |>
      addMarkers(
        icon = startingIconFormat,
        popup = paste0(
          "<b>",
          points$tier,
          "</b><br>",
          points$address
        )
      ) |> 
      addControl(pointsDisplayed, position = "topright") |> 
      addLayersControl(
        baseGroups = c("Street", "Satellite"),
        options = layersControlOptions(collapsed = TRUE)
      )
  })
  
  # update symbology using proxy
  observe({
    
    points <- points()
    
    iconFormat <-
      if (input$map_marker == "Tier") {
        
        makeIcon(
          iconUrl = paste0("www/images/", str_to_lower(points$tier), ".png"),
          iconWidth = case_when(
            points$tier == "Butterfly" ~ 25,
            points$tier == "Chrysalis" ~ 17,
            points$tier == "Caterpillar" ~ 25,
            points$tier == "Egg" ~ 25
          ),
          iconHeight = case_when(
            points$tier == "Butterfly" ~ 20,
            points$tier == "Chrysalis" ~ 20,
            points$tier == "Caterpillar" ~ 25,
            points$tier == "Egg" ~ 15
          )
        )
      } else if (input$map_marker == "Simple") {
        
        makeIcon(
          iconUrl = "www/images/location_dot.png",
          iconWidth = 17,
          iconHeight = 20
        )
      }
    
    htmlLegend <- 
      if (input$map_marker == "Tier") {
        
        "<div style='line-height: 2;'>
         <img src='images/butterfly.png' style='width:20px; height:15px;'> Butterfly
         <br/>
         <img src='images/chrysalis.png' style='width:15px;height:20px;'> Chrysalis
         <br/>
         <img src='images/caterpillar.png' style='width:20px;height:15px;'> Caterpillar
         <br/>
         <img src='images/egg.png' style='width:20px;height:13px;'> Egg
         </div>"
        
      } else if (input$map_marker == "Simple") {
        
        "<img src='images/location_dot.png' style='width:17px; height:20px;'> Garden"
      }
    
    leafletProxy("map", data = points) |> 
      clearMarkers() |> 
      addMarkers(
        icon = iconFormat,
        popup = paste0(
          "<b>",
          points$tier,
          "</b><br>",
          points$address
        )
      ) |> 
      removeControl("legend") |> 
      addControl(
        layerId = "legend",
        html = htmlLegend,
        position = "bottomleft"
      )
  })
})
