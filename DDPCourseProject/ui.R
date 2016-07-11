
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
require("googleVis")
library(shiny)
options(RCHART_TEMPLATE = 'Rickshaw.html')

shinyUI(
  tabsetPanel(
      tabPanel("Info",
          fluidPage(
              fluidRow(
                  column(11, offset = 1,
                      h2("Summary"),
                      p("This work is done as a part of Developing Data Products by John Hopkins University course on Coursera."),
                      p("Here is a small proof that moon phase has no influence on crime rate, at least in the city of Chicago."),
                      p(),
                      h4("About data"),
                      p("The source dataset reflects reported incidents of crime (with the exception of murders
                        where data exists for each victim) that occurred in the City of Chicago from 2001 to present,
                        minus the most recent seven days. Data is extracted from the Chicago Police Department's
                        CLEAR (Citizen Law Enforcement Analysis and Reporting) system. In order to protect the privacy
                        of crime victims, addresses are shown at the block level only and specific locations are not identified."),
                      p(),
                      p("I have filtered dataset to start from year 2009 to keep application running at least at bearable level.
                        Should one want to recreate current application using full dataset, the data can be found here",
                      a("https://catalog.data.gov/dataset/crimes-2001-to-present-398a4",
                        href = "https://catalog.data.gov/dataset/crimes-2001-to-present-398a4",
                        target="_blank"), 
                      "and R source code can be found here ",
                      a("https://github.com/T-StrawClown/DevelopingDataProducts",
                        href = "https://github.com/T-StrawClown/DevelopingDataProducts",
                        target = "_blank")),
                      p(),
                      h4("About application"),
                      p("On Maps tab it is possible view locations of individual crimes of chosen type and month."),
                      p(),
                      p("On Moon phase tab there's a proof that full moon has no influence on crime rates. I used Bootstrapping for
                        simulations and verified means of simulated data with their 95% confidence intervals, which clearly shows that
                        on average number of crimes committed per day during full moon is not significantly different from average number
                        of crimes committed during all other phases of the moon.")
                  )
              )   
          )
      ),
      tabPanel("Map",
          fluidPage(
              # Row 1 - Map
              fluidRow(
                  column(4, align = "center",
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
              )
          )
      ),
      tabPanel("Moon Phases",
           # Row  - Some stats
           fluidRow(# Simulations
               column(4, align = "center",
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
           ),
           # fluidRow( # Radio buttons
           #     column(8, offset = 4, align = "center",
           #            radioButtons("rickshawtype", "Choose type of chart:",
           #                         c("Stacked" = "area",
           #                           "Line" = "line"),
           #                         inline = TRUE)
           #     )
           # ),
           fluidRow(# Google chart
               column(8, offset = 4, align = "center",
                      htmlOutput("googlechart")
               )
               
           )
      )
  )
)

