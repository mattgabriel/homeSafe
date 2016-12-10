library(lubridate)
library(forecast)
library(reshape)
library(ggplot2)
# import data
df <- read.csv("/Users/d.timmers1/hackaway/dutchopen2016/homeSafe/Model/HistoricData/WeatherData/tempIn.tsv",
               stringsAsFactors = FALSE, header = TRUE, sep="\t", strip.white=TRUE)
# convert string to timestamp format
df$time <- as.POSIXct(df$time, format="%d/%m/%Y %H:%M", tz = "CET")
# shift time to current time
load("/Users/d.timmers1/hackaway/dutchopen2016/homeSafe/Model/mydf.Rdata")
diffDays <- as.double(difftime(mydf$timestamp[1], df$time[1], units = "days"))
df$time <- df$time + lubridate::days(diffDays)
# make the mother*er burn
df[1437:1440,]$temp <- df[1437:1440,]$temp + c(0.5, 1.5, 3, 5)

# Fitting the model as the data is streaming in
trainData <- df$temp[1:720] # first week to train model
testData <- df$temp[721:1440] # second week to test the strength of the model
fit <- forecast::ets(trainData)
# fittedDF will keep the data about the goodness-of-fit of the model
fittedDF <- data.frame(val=numeric(), # true measures value
                       forecast=numeric(), # predicted value
                       lower=numeric(), # lower bound on predicted value
                       upper=numeric(),
                       amse=numeric(),
                       model=character(),
                       stringsAsFactors = FALSE) # upper bound on predicted value
loopData <- trainData
fit <- forecast::ets(loopData)
for(idx in 1:720) {
  print(paste("fitting iteration", idx, "where training data has size", length(loopData)))
  # forecast next value based on previously build model
  fc <- forecast::forecast(loopData, model = fit, h = 1, robust = TRUE, level = c(99.9))
  # read the new value
  newValue <- testData[idx]
  newRow <- data.frame(newValue, fc$mean[1] ,fc$lower[1], fc$upper[1], fit$amse, fit$method, 
                       stringsAsFactors = FALSE)
  fittedDF[idx,] <- newRow[1,]
  # the traindata gets updated
  loopData <- c(tail(loopData, -1), newValue)
  # train the new model
  fit <- forecast::ets(loopData)
}
fittedDF <- cbind(fittedDF, ts = tail(df$time, -720))

save(fittedDF, file = "/Users/d.timmers1/hackaway/dutchopen2016/homeSafe/Model/HistoricData/fitted_model.RData")
