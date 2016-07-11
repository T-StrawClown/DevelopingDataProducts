#require("ggplot2")
require("lunar")
require("dplyr")
require("lubridate")
require("leaflet")
require("maps")
require("rCharts")
require("googleVis")
library(stringr)

ptm <- proc.time()
message("reading csv file")
# # https://catalog.data.gov/dataset/crimes-2001-to-present-398a4
# ds_raw <- read.csv("D:/temp/Crimes_-_2001_to_present.csv", nrows = 1000, stringsAsFactors = F)
ds_raw <- read.csv("D:/temp/Crimes_-_2001_to_present.csv", stringsAsFactors = F)
#
print(proc.time() - ptm)

message("calculating moon phases")
ds_crimes <- ds_raw %>%
    select(id = ID,
           date = Date,
           type = Primary.Type,
           distr = District,
           lat = Latitude,
           lon = Longitude) %>%
    mutate(date = parse_date_time(date, c("%m/%d/%y %I:%M%S %p"), tz = "America/Chicago"),
           day = as.Date(date),
           year = year(day),
           month = month(day),
           type = as.factor(type),
           distr = as.factor(distr),
           moon = as.factor(lunar.phase(date, name = 4)))
print(proc.time() - ptm)

message("creating tidy data")
crimes.tidy <- ds_crimes %>%
    filter(year > 2008) %>%
    filter(!is.na(moon) & !is.na(distr))
print(proc.time() - ptm)

message("preparing final datasets")
crimes.all <- crimes.tidy %>%
    group_by(moon, day, year, month, type, distr) %>%
    filter(!is.na(moon) & !is.na(distr)) %>%
    summarise(cnt = n())

crimes.by_day <- crimes.all %>%
    group_by(day, year, month, moon) %>%
    summarize(cnt = sum(cnt))

print(proc.time() - ptm)
rm(list = c("ds_raw", "ds_crimes"))
message("saving image to disk")
save.image("data/crimes.RData")
message("done")
print(proc.time() - ptm)

crimes.by_yearmonth <- crimes.by_day %>%
    mutate(ym = as.POSIXct(paste(year, month, "01", sep = "-"))) %>%
    #mutate(ym = as.numeric(as.POSIXct(paste(year, month, "01", sep = "-")))) %>%
    group_by(ym, moon) %>%
    summarize(cnt = sum(cnt)) %>%
    filter(!is.na(ym))

plot(gvisAnnotationChart(crimes.by_yearmonth,
                         datevar = "ym",
                         numvar = "cnt",
                         idvar = "moon",
                         options = list(
                             colors="['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']",
                             curvetype = "function"
                         )))

# plot(gvisSteppedAreaChart(crimes.by_yearmonth,
#                           xvar = "ym",
#                           yvar = "cnt",
#                           options = list(
#                             colors="['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']"
#                           )))

# t <- "line"
# p2 <- Rickshaw$new()
# p2$layer(cnt ~ ym, group = "moon", data = crimes.by_yearmonth, type = t,
#          colors = c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3"))
# p2$set(slider = TRUE)
# p2
# 

# 
# full.ds <- subset(crimes.by_day, moon == "Full")
# nonfull.ds <- subset(crimes.by_day, moon != "Full")
# full.sims <- matrix(data = sample(full.ds$cnt,
#                                   100 * 100,
#                                   replace = T),
#                     nrow = 100,
#                     ncol = 100)
# nonfull.sims <- matrix(data = sample(nonfull.ds$cnt,
#                                      100 * 100,
#                                      replace = T),
#                        nrow = 100,
#                        ncol = 100)
# full.means <- apply(full.sims, 1, mean)
# nonfull.means <- apply(nonfull.sims, 1, mean)
# 
# ggplot() +
#     geom_density(data = as.data.frame(full.means),
#                  aes(x = full.means),
#                  color = "#386cb0",
#                  size = 1.2,
#                  show.legend = F) +
#     stat_density(data = as.data.frame(full.means),
#                  aes(x = full.means, color = "Full"),
#                  geom = "line",
#                  position = "identity") +
#     geom_vline(xintercept = mean(full.means) + c(-1,1) * qnorm(.975) * sd(full.means),
#                linetype = "dashed",
#                color = "#386cb0") +
#     geom_vline(xintercept = mean(full.means),
#                color = "#386cb0") +
#     geom_density(data = as.data.frame(nonfull.means),
#                  aes(x = nonfull.means),
#                  color = "salmon",
#                  show.legend = F) +
#     stat_density(data = as.data.frame(nonfull.means),
#                  aes(x = nonfull.means, color = "Other"),
#                  geom = "line",
#                  position = "identity") +
#     geom_vline(xintercept = mean(nonfull.means) + c(-1,1) * qnorm(.975) * sd(nonfull.means),
#                linetype = "dashed",
#                color = "salmon") +
#     geom_vline(xintercept = mean(nonfull.means),
#                color = "salmon") +
#     scale_colour_manual(name = "moon", 
#                         values = c("Full" = "#386cb0", "Other"="salmon"),
#                         labels = c("Full", "Other"),
#                         guide = "legend")

# plt <- colorFactor(c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3"), domain = levels(crimes.tidy$moon))
# crimes.geo <- crimes.tidy %>%
#     filter(year == 2011 & month == 6 &!is.na(lat) & !is.na(lon))
# leaflet(crimes.geo) %>%
#     addTiles() %>%  # Add default OpenStreetMap map tiles
#     # addLegend(position = "topright",
#     #           pal = plt,
#     #           values = ~moon,
#     #           opacity = .5,
#     #           title = "Moon") %>%
#     # addCircleMarkers(lng = ~lon,
#     #                  lat = ~lat,
#     #                  radius = 3,
#     #                  color = ~plt(moon),
#     #                  popup = ~type,
#     #                  opacity = .5)
#     addMarkers(lng = ~lon,
#                lat = ~lat,
#                popup = ~type,
#                clusterOptions = markerClusterOptions())
#     # addCircles(lng = ~lon,
#     #            lat = ~lat,
#     #            fillColor = "orange")
#                         