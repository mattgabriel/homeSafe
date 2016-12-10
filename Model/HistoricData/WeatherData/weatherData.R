library(lubridate)
library(httr)
library(zoo)

hourlyTemperature <- function(numHours) {
  apiKey <- "0931d38a6a444dd82e0978b30d8f2062"
  
  tsNow <- Sys.time()
  # round down to the hour
  lubridate::minute(tsNow) <- 0
  lubridate::second(tsNow) <- 0
  tsHours <- tsNow - lubridate::hours(0:numHours)
  tmpVec <- c()
  for(ts in tsHours) {
    tsUnix <- round(as.numeric(ts))
    getUrl <- paste0("https://api.darksky.net/forecast/0931d38a6a444dd82e0978b30d8f2062/51.923104,4.469507,",tsUnix)
    resp <- httr::GET(getUrl)
    respContent <- httr::content(resp, "parsed")
    # convert from Fahrenheit to Celcius
    tmpVec <- c(tmpVec, (respContent$currently$temperature - 32) * 5/9)
  }
  
  zoo(tmpVec, tsHours)
}

# let's get the last four weeks
hours <- 24 * 7 * 4
tempOut <- hourlyTemperature(hours)
save(tempOut, file = "/Users/d.timmers1/hackaway/dutchopen2016/homeSafe/Model/HistoricData/WeatherData/tempOut.RData")