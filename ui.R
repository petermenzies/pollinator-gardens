# shiny ui

dashboardPage(
  dashboardHeader(title = "Certified Pollinator Gardens",
                  tags$li(
                    class = "dropdown",
                    actionBttn(
                      inputId = "refresh",
                      label = "Restart App",
                      icon = icon("refresh"),
                      style = "simple",
                      size = "sm"
                    )
                  )),
  
  dashboardSidebar(collapsed = TRUE,
                   sidebarMenu(
                     id = "tabs",
                     menuItem(
                       "Map",
                       tabName = "map",
                       icon = icon("map", verify_fa = F)
                     )
                   )),
  
  dashboardBody(
    # BODY TOP-LEVEL -----------
    
    # javascript
    shinyjs::useShinyjs(),
    shinyjs::extendShinyjs(text = "shinyjs.refresh_page = function() { location.reload(); }", functions = "refresh_page"),
    
    # styling
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    
    # main menu items
    tabItems(# SHAPE VIEWER --------------------------------------------------------
             tabItem(tabName = "map",
                     
                     fluidRow(
                       div(class = "col-sm-12 col-md-12 col-lg-8",
                           
                           box(
                             width = "100%",
                             leafletOutput("map") |>
                               withSpinner(type = 8)
                           ))
                     )))
  )
)
