# shiny ui

dashboardPage(
  dashboardHeader(title = "Pollinator Habitats",
                  tags$li(
                    class = "dropdown",
                    shinyWidgets::actionBttn(
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
                     ),
                     menuItem(
                       "Settings",
                       tabName = "settings",
                       icon = icon("gear"),
                       menuSubItem(
                         shinyWidgets::actionBttn(
                           inputId = "update",
                           label = "Updates Addresses",
                           icon = icon("database"),
                           style = "simple",
                           size = "sm"
                         ),
                         icon = NULL
                       )
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
    
    # menu items
    tabItems(
      # MAP --------------------------------------------------------
      tabItem(tabName = "map",
              
              fluidRow(
                # column(width = 2,
                div(class = "col-sm-3 col-md-3 col-lg-2",
                    box(
                      width = "100%",
                      selectInput("map_marker",
                                  "Garden marker type:",
                                  c("Simple", "Tier"))
                    )),
                
                div(class = "col-sm-12 col-md-12 col-lg-10",
                    box(
                      width = "100%",
                      leafletOutput("map") |>
                        withSpinner(type = 8)
                    ))
              ))
    )
  )
)
