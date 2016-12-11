library(httr)
library(ggplot2)
library(dplyr)
library(magrittr)

limit <- 100
getURL <- paste0("http://52.57.102.57/api/sensor/1480981386/1484881386/", limit * 5)
cols <- c("id", "sensor", "charValue", "ts_str")

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
  df <- as.data.frame(mat, stringsAsFactors = FALSE)
  names(df) <- cols
  
  # some parsing things
  df %<>%
    dplyr::filter(sensor != "AirQuality_1") %>%
    dplyr::mutate(value = as.numeric(charValue)) %>%
    dplyr::arrange(ts_str)
  
  # make sure each sensor has the same number of observations
  num_extra_rows <- NROW(df) %% 4
  if(num_extra_rows > 0) {
    df <- head(df, -num_extra_rows)
  }
  
  df %>% 
    cbind(data.frame(x = rep(1:(NROW(df) / 4), each = 4)))
}

plotLiveData <- function(df) {
  ggplot(data = df, aes(x = x, y = value, group = sensor, colour = sensor)) +
    geom_line(size = 1.3) +
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank()) +
    theme(legend.text=element_text(size=16)) +
    theme(legend.title=element_text(size=18))
}

#df <- getLiveData()
#plotLiveData(df)
