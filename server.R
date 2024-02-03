# shiny server

print("server")

# Define server logic
shinyServer(function(input, output, session) {
  # reactive file reading ---------------------------------------
  
  # shapes
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
    
    # format map popup based on whether it's a fishing sector or not
    # map_popup <-
    #   paste0(
    #     "<b>",
    #     shapes$sector,
    #     "</b>",
    #     "<br><b>Response ID:</b> ",
    #     shapes$response_id,
    #     "<br><b>Gear Type:</b> ",
    #     shapes$geartype,
    #     "<br><b>Gear Collected?</b> ",
    #     shapes$gear_collected
    #   )
    
    # number of shapes displayed - added to map with `addControl()`
    points_displayed <- HTML({
      paste0("Gardens Displayed: ",
             div(id = "shapes-number", nrow(points)))
    })
    
    # render map
    leaflet(points) |>
      addProviderTiles("Esri.WorldImagery", group = "Esri") |>
      addTiles(
        urlTemplate = "https://mts1.google.com/vt/lyrs=s&hl=en&src=app&x={x}&y={y}&z={z}&s=G",
        attribution = 'Google',
        group = "Google Earth"
        ) |> 
      addProviderTiles("CartoDB.Positron", group = "Light") |>
      addCircles() |> 
      addControl(points_displayed, position = "topright") |> 
      addLayersControl(
        baseGroups = c("Light", "Google Earth", "Esri"),
        options = layersControlOptions(collapsed = TRUE)
      )
  })
})
