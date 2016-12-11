library(lubridate)
library(forecast)
library(reshape)
library(ggplot2)

# load the historic data
load("/Users/d.timmers1/hackaway/dutchopen2016/homeSafe/Model/HistoricData/fitted_model.RData")

# add in the prio time-intervals
low_prio_iv <- lubridate::interval(as.POSIXct("2016-12-06 09:45:00"), as.POSIXct("2016-12-06 11:30:00"))
high_prio_iv <- lubridate::interval(as.POSIXct("2016-12-10 23:00:00"), as.POSIXct("2016-12-10 23:45:00"))

startIdx <- 1
windowSize <- 4 * 24 # window size of 24 hours
stepSize <- 1 * 4 * 3 #a single unit is a 15min step in time
maxSize <- NROW(fittedDF)

add_shaded_rect <- function(intersect, rect_fill){
  rect <- data.frame(xstart = lubridate::int_start(intersect),
                     xend = lubridate::int_end(intersect)
  )
  geom_rect(data = rect, aes(xmin = xstart, xmax = xend, 
                             ymin = -Inf, ymax = Inf), 
            fill = rect_fill, alpha = 0.4)
}

while(startIdx + windowSize - 1 <= maxSize) {
  print(paste("window = ",startIdx, ":", startIdx + windowSize - 1))
  plotDF <- fittedDF[startIdx:(startIdx + windowSize - 1), ]
  iv <- lubridate::interval(plotDF$ts[1], plotDF$ts[NROW(plotDF)])
  # Create the model annotations
  modelName <- plotDF[NROW(plotDF),]$model
  MSE <- plotDF[NROW(plotDF), ]$amse
  # create the plot
  p1 <- ggplot() +
    geom_line(data = plotDF, aes(x = ts, y = val)) +
    geom_ribbon(data = plotDF, aes(x = ts, ymin=lower, ymax=upper), alpha=0.3) +
    ggtitle(paste0("model:", modelName, "\n error: ", MSE)) +
    theme(plot.title = element_text(size = 16))
  
  # check intersection with low prio interval
  intersect_low <- lubridate::intersect(iv, low_prio_iv)
  if(!is.na(intersect_low)) { 
    p1 <- p1 + add_shaded_rect(intersect_low, "orange") 
  }
  intersect_high <- lubridate::intersect(iv, high_prio_iv)
  # check intersection with high prio interval
  if(!is.na(intersect_high)) { 
    p1 <- p1 + add_shaded_rect(intersect_high, "red")
  }
  print(p1)
  startIdx <- startIdx + stepSize
}

# let's add in the air quality sensor.
airDF <- data.frame( time = df$time, quality = 3)
airDF[1437:1440,]$quality <- airDF[1437:1440,]$quality - c(1, 1, 2, 3)

startIdx <- 1
windowSize <- 4 * 24 # window size of 1 day
stepSize <- 2 * 24 # step size of 0.5 day
air_low_prio_iv <- lubridate::interval(as.POSIXct("2016-12-10 22:45:00"), as.POSIXct("2016-12-10 23:15:00"))
air_high_prio_iv <- lubridate::interval(as.POSIXct("2016-12-10 23:15:00"), as.POSIXct("2016-12-10 23:45:00"))
while(startIdx + windowSize - 1 <= maxSize) {
  print(paste("window = ",startIdx, ":", startIdx + windowSize - 1))
  plotDF <- airDF[720 + startIdx:(startIdx + windowSize - 1),]
  iv <- lubridate::interval(plotDF$time[1], plotDF$time[NROW(plotDF)])
  # create the plot
  p2 <- ggplot() +
    ylim(0, 3.5) +
    geom_line(data = plotDF, aes(x = time, y = quality))
  # check intersection with low prio interval
  intersect_low <- lubridate::intersect(iv, air_low_prio_iv)
  if(!is.na(intersect_low)) { 
    p2 <- p2 + add_shaded_rect(intersect_low, "orange") 
  }
  intersect_high <- lubridate::intersect(iv, air_high_prio_iv)
  # check intersection with high prio interval
  if(!is.na(intersect_high)) { 
    p2 <- p2 + add_shaded_rect(intersect_high, "red")
  }
  print(p2)
  startIdx <- startIdx + stepSize
}