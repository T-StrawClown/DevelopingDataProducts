
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
require("ggplot2")
require("lunar")
require("dplyr")
require("lubridate")
require("maps")
require("leaflet")
library(shiny)

shinyUI(
  fluidPage(
      # Row 1 - Map
      fluidRow(
          column(4,
              fluidRow(
                  column(4,
                         selectInput("year", "Choose a year:", 
                                     choices = seq(from = min(crimes.by_day$year), to = max(crimes.by_day$year)),
                                     selected = 2009)
                  ),
                  column(8,
                         sliderInput("month", "Choose a month:", 
                                     min = 1,
                                     max = 12,
                                     value = 1,
                                     step = 1)
                  )
              ),
              fluidRow(
                  column(12,
                         checkboxGroupInput("type",
                                            "Choose crime types:",
                                            choices = levels(crimes.tidy$type),
                                            inline = TRUE,
                                            selected = levels(crimes.tidy$type)[1]),
                         actionButton("showonmap", "Show on map")
                  )
              )
          ),
          column(8,
                 leafletOutput("mapPlot", height = 600)
          )
      ),
      # Row 2 - Some stats
      fluidRow(
          column(4,
                 sliderInput("sims",
                             "Number of simulations:",
                             min = 500,
                             max = 2000,
                             value = 1000,
                             step = 100),
                 sliderInput("sample",
                             "Sample size:",
                             min = 200,
                             max = 1000,
                             value = 500,
                             step = 100),
                 actionButton("resim", "Run simulation")
          ),
          column(4,
                 plotOutput("distPlot")
          ),
          column(4,
                 plotOutput("normPlot")
          )
      )
  )
)

