library(httr)
library(ggplot2)
library(dplyr)

limit <- 200
getURL <- paste0("http://52.57.102.57/api/sensor/1480981386/1484881386/", limit)
cols <- c("id", "sensor", "value", "ts_str")

# helper function that turns string timestamps into POSIXct timestamps
get_timestamp <- function(ts){
  ts_UTC <- as.POSIXct(sub("T", " ", substr(ts,1,19)), format = ts_format, tz = "UTC")
  format(ts_UTC, tz="CET",usetz=TRUE)
}

getLiveData <- function() {
  # query for the data
  resp <- httr::GET(getURL)
  dat <- httr::content(resp, "parsed")
  
  # transform response into a dataframe
  mat <- matrix(unlist(dat$Data), ncol = 4, byrow = TRUE)
  df <- as.data.frame(mat)
  names(df) <- cols
  
  # parse date-time stamps
  df %>%
    dplyr::mutate(ts = get_timestamp(ts_str)) %>%
    dplyr::select(-ts_str, -id)
}

plotLiveData <- function(df) {
  ggplot(data = df, aes(x = ts, y = value, group = ))
}

df <- getLiveData()




