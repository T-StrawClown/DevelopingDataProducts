
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

# require("ggplot2")
# require("lunar")
# require("dplyr")
# require("lubridate")
# require("maps")
# require("leaflet")
# require("googleVis")
# library(shiny)
# 
# load("data/crimes.RData")

shinyServer(function(input, output) {

  output$distPlot <- renderPlot({

    # plots.density.by_moon <- 
    ggplot(data = crimes.by_day,
           aes(x = cnt, color = moon)) +
    geom_density(show.legend = F) +
    stat_density(geom = "line",
                 position = "identity") +
    #scale_color_brewer(type = "qual", guide = "legend") +
    scale_color_manual(values = c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3")) +
    geom_density(data = subset(crimes.by_day, moon == "Full"),
                 aes(x = cnt),
                 color = "#4daf4a",
                 size = 1.2,
                 show.legend = F) +
    ggtitle("Density of crimes per day") +
    ylab("") + xlab("")
  })
  
  runSimsFull <- eventReactive(input$resim, {
      
      full.ds <- subset(crimes.by_day, moon == "Full")
      full.sims <- matrix(data = sample(full.ds$cnt,
                                        input$sims * input$sample,
                                        replace = T),
                          nrow = input$sims,
                          ncol = input$sample)
      full.means <- apply(full.sims, 1, mean)
  }, ignoreNULL = FALSE)
  
  runSimsNonFull <- eventReactive(input$resim, {
      
      nonfull.ds <- subset(crimes.by_day, moon != "Full")
      nonfull.sims <- matrix(data = sample(nonfull.ds$cnt,
                                           input$sims * input$sample,
                                           replace = T),
                             nrow = input$sims,
                             ncol = input$sample)
      nonfull.means <- apply(nonfull.sims, 1, mean)
  }, ignoreNULL = FALSE)
  
  output$normPlot <- renderPlot({
    
    full.means <- runSimsFull()
    nonfull.means <- runSimsNonFull()
    ggplot() +
    geom_density(data = as.data.frame(full.means),
                 aes(x = full.means),
                 color = "#4daf4a",
                 size = 1.2,
                 show.legend = F) +
    stat_density(data = as.data.frame(full.means),
                 aes(x = full.means, color = "Full"),
                 geom = "line",
                 position = "identity") +
    geom_vline(xintercept = mean(full.means) + c(-1,1) * qnorm(.975) * sd(full.means),
               linetype = "dashed",
               color = "#4daf4a") +
    geom_vline(xintercept = mean(full.means),
               color = "#4daf4a") +
    geom_density(data = as.data.frame(nonfull.means),
                 aes(x = nonfull.means),
                 color = "salmon",
                 show.legend = F) +
    stat_density(data = as.data.frame(nonfull.means),
                 aes(x = nonfull.means, color = "Other"),
                 geom = "line",
                 position = "identity") +
    geom_vline(xintercept = mean(nonfull.means) + c(-1,1) * qnorm(.975) * sd(nonfull.means),
               linetype = "dashed",
               color = "salmon") +
    geom_vline(xintercept = mean(nonfull.means),
               color = "salmon") +
    scale_colour_manual(name = "moon", 
                        values = c("Full" = "#4daf4a", "Other"="salmon"),
                        labels = c("Full", "Other"),
                        guide = "legend") +
    ggtitle("Density of simulated means of crimes per day") +
    xlab("") + ylab("")
    
  })
  
  
  output$mapPlot <- renderLeaflet({
      input$showonmap
      chicago <- isolate({
          plt <- colorFactor(c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3"), domain = levels(crimes.tidy$moon))
          crimes.geo <- crimes.tidy %>%
              filter(year == input$year & month == input$month & type == input$type &!is.na(lat) & !is.na(lon))
          chicago <- leaflet(crimes.geo) %>%
                     addTiles()  # Add default OpenStreetMap map tiles
              # addLegend(position = "topright",
              #           pal = plt,
              #           values = ~moon,
              #           opacity = .5,
              #           title = "Moon") %>%
              # addCircleMarkers(lng = ~lon,
              #                  lat = ~lat,
              #                  radius = 3,
              #                  color = ~plt(moon),
              #                  popup = ~type,
              #                  opacity = .5)
          if (nrow(crimes.geo) > 0) {
              addMarkers(chicago,
                         lng = ~lon,
                         lat = ~lat,
                         popup = ~type,
                         clusterOptions = markerClusterOptions())
          }
          else {
              setView(chicago,
                      lng = -87.67617,
                      lat = 41.77304,
                      zoom = 10)
          }
      })
      return(chicago)
  })
  
  # Google chart
  output$googlechart <- renderGvis({
      if (!exists("crimes.by_yearmonth")) {
          crimes.by_yearmonth <- crimes.by_day %>%
              #mutate(ym = as.numeric(as.POSIXct(paste(year, month, "01", sep = "-")))) %>%
              mutate(ym = as.POSIXct(paste(year, month, "01", sep = "-"))) %>%
              group_by(ym, moon) %>%
              summarize(cnt = sum(cnt)) %>%
              filter(!is.na(ym))
      }
      gvisAnnotationChart(crimes.by_yearmonth,
                          datevar = "ym",
                          numvar = "cnt",
                          idvar = "moon",
                          options = list(
                              colors = "['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']",
                              width = 1100,
                              height = 300,
                              dateFormat = "MMM yyyy",
                              numberFormats = "#,###",
                              scaleFormat = "#,###",
                              thickness = 2
                          ),
                          chartid = "googlechart")
  })

})
