library(ggplot2)
library(lubridate)
library(httr)

# post url for sending alerts
alertURL <- "http://52.57.102.57/api/state/"

# load the historic data
load("/Users/d.timmers1/hackaway/dutchopen2016/homeSafe/Model/HistoricData/fitted_model.RData")

# add in the prio time-intervals
low_prio_iv <- lubridate::interval(as.POSIXct("2016-12-06 09:45:00"), as.POSIXct("2016-12-06 11:30:00"))
high_prio_iv <- lubridate::interval(as.POSIXct("2016-12-10 23:00:00"), as.POSIXct("2016-12-10 23:45:00"))

# shade the areas where an alert is sent
add_shaded_rect <- function(intersect, rect_fill){
  rect <- data.frame(xstart = lubridate::int_start(intersect),
                     xend = lubridate::int_end(intersect)
  )
  geom_rect(data = rect, aes(xmin = xstart, xmax = xend, 
                             ymin = -Inf, ymax = Inf), 
            fill = rect_fill, alpha = 0.4)
}

plotTemperature <- function(startIdx, windowSize, sendAlertLow, sendAlertHigh){
  if(startIdx < NROW(fittedDF) - 48 - windowSize) {
    plotDF <- tail(fittedDF, -48)[startIdx:(startIdx + windowSize - 1), ]
  } else {
    plotDF <- tail(fittedDF, -48)
  }
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
    if(sendAlertLow) {
      url <- paste0(alertURL, "LOW")
      resp <- httr::POST(url)
      if(resp$status_code == 200) {
        print("successfully sent MID alert")
      } else {
        print("failed to sent MID alert")
      }
    }
  }
  intersect_high <- lubridate::intersect(iv, high_prio_iv)
  # check intersection with high prio interval
  if(!is.na(intersect_high)) { 
    p1 <- p1 + add_shaded_rect(intersect_high, "red")
    if(sendAlertHigh) {
      url <- paste0(alertURL, "MID")
      resp <- httr::POST(url)
      if(resp$status_code == 200) {
        print("successfully sent HIGH alert")
      } else {
        print("failed to sent HIGH alert")
      }
    }
  }
  print(p1)
  
  return( list(low = sendAlertLow, high = sendAlertHigh) )
}


airDF <- data.frame(ts = tail(fittedDF, -48)$ts, quality = 3)
airDF[669:672,]$quality <- airDF[669:672,]$quality - c(1, 1, 2, 3)
# alerting intervals
air_low_prio_iv <- lubridate::interval(as.POSIXct("2016-12-10 22:45:00"), as.POSIXct("2016-12-10 23:15:00"))
air_high_prio_iv <- lubridate::interval(as.POSIXct("2016-12-10 23:15:00"), as.POSIXct("2016-12-10 23:45:00"))

plotAirQuality <- function(startIdx, windowSize){
  if(startIdx < NROW(fittedDF) - 48 - windowSize) {
    plotDF <- airDF[startIdx:(startIdx + windowSize - 1),]
  } else {
    plotDF <- airDF
  }
  
  iv <- lubridate::interval(plotDF$ts[1], plotDF$ts[NROW(plotDF)])
  # create the plot
  p2 <- ggplot() +
    ylim(0, 3.5) +
    geom_line(data = plotDF, aes(x = ts, y = quality))
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
}