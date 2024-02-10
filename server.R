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
  
  
  # Map -------------------------------------------------
  
  output$map <- renderLeaflet({
    points <- points()
    
    # number of shapes displayed - added to map with `addControl()`
    pointsDisplayed <- HTML({
      paste0("Gardens Displayed: ",
             div(id = "shapes-number", nrow(points)))
    })
    
    startingIconFormat <- 
      makeIcon(
        iconUrl = "www/images/location_dot.png",
        iconWidth = 14,
        iconHeight = 17
      )
    
    startingHtmlLegend <- "<img src='images/location_dot.png' style='width:17px; height:20px;'> Garden"
    
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
      addControl(
        layerId = "legend",
        html = startingHtmlLegend,
        position = "bottomleft"
      ) |> 
      addLayersControl(
        baseGroups = c("Street", "Satellite"),
        options = layersControlOptions(collapsed = TRUE)
      )
  })
  
  # update symbology using proxy
  observeEvent(input$map_marker, {
    
    points <- points()
    
    if (input$map_marker == "Tier") {
      
      iconFormat <-
        makeIcon(
          iconUrl = paste0("www/images/", str_to_lower(points$tier), ".png"),
          iconWidth = case_when(
            points$tier == "Butterfly" ~ 20,
            points$tier == "Chrysalis" ~ 15,
            points$tier == "Caterpillar" ~ 25,
            points$tier == "Egg" ~ 20
          ),
          iconHeight = case_when(
            points$tier == "Butterfly" ~ 15,
            points$tier == "Chrysalis" ~ 17,
            points$tier == "Caterpillar" ~ 25,
            points$tier == "Egg" ~ 12
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
      
      opacity <- 1
      
    } else if (input$map_marker == "Simple") {
      
      iconFormat <-
        makeIcon(
          iconUrl = "www/images/location_dot.png",
          iconWidth = 14,
          iconHeight = 17
        )
      
      htmlLegend <- "<img src='images/location_dot.png' style='width:17px; height:20px;'> Garden"
      
      opacity <- 0.6
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
        ),
        options = markerOptions(opacity = opacity)
      ) |> 
      removeControl("legend") |> 
      addControl(
        layerId = "legend",
        html = htmlLegend,
        position = "bottomleft"
      )
  })
  
  # Data Update -----------------------------------------
  
  observeEvent(
    input$update, {
      source("R/check_for_updates.R")
      updates <- check_for_updates()

      if (updates == FALSE) {
        showModal(modalDialog(
          renderText("Do you still want to update? Fetching and geocoding new data will take a couple of minutes"),
          title="No new addreses found",
          footer = tagList(actionButton("update_addresses_confirm", "Updates Addresses"),
                           modalButton("Cancel")
          )
        ))

      } else {
        
        showModal(modalDialog(
          renderText("Fetching and geocoding new data will take a couple of minutes"),
          title="New addresses found!",
          footer = tagList(actionButton("update_addresses_confirm", "Updates Addresses"),
                           modalButton("Cancel")
          )
        ))
      }
    }
  )
  
  observeEvent(input$update_addresses_confirm, { 
    removeModal()
    withProgress(
      {
        source("R/process_addresses.R")
        process_addresses(addresses)
        incProgress(1/10, message = "reloading app")
        
        session$reload()
      }
    )
  })
})
