library(ggplot2)
library(dplyr)
library(lattice)
library(plyr)

mydf <- data.frame(timestamp=seq(from = as.POSIXct('2016-11-27 00:00:01'), to=as.POSIXct('2016-12-02 00:00:00'), by = "sec"))

# create loudness data
df2 <- data.frame()
for (i in 1:5){
    dayQ <- as.numeric('21600')
    df1 <- data.frame(loudness=c(sample(45:49, dayQ, replace=TRUE),  # night
                            sample(50:75, dayQ, replace=TRUE),       # morning
                            sample(48:85, dayQ, replace=TRUE),       # afternoon
                            sample(48:70, dayQ, replace=TRUE)),      # evening/night
                      addRandomness=c(round(runif(dayQ, 0.0, 1), digits=2), 
                                      round(runif(dayQ, 4.0, 15), digits=2), 
                                      round(runif(dayQ, 0.0, 17), digits=2), 
                                      round(runif(dayQ, 0.0, 8), digits=2)),
                     timeOfDay=c(sample('night', dayQ, replace=TRUE), 
                             sample('morning', dayQ, replace=TRUE),
                             sample('afternoon', dayQ, replace=TRUE),
                             sample('evening', dayQ, replace=TRUE))
                  )
    df2 <- rbind(df2,df1)
}
df3 <- cbind(mydf, df2)
df3$loudnessRand <- (df3$loudness-df3$addRandomness)



## Calculate the mean for every hour or minute using cut() to define 
## the factors and ddply() to calculate the means. 
## getmeans() is applied for each unique combination of the
## hosts and hour factors.
getmeans  <- function(Df) c(x1 = mean(Df$loudnessRand), x2 = mean(Df$loudnessRand))
df3$minuteAver <- cut(df3$timestamp, breaks = "min")
Means <- ddply(df3, .(timeOfDay, minuteAver), getmeans)
Means$minuteAver <- as.POSIXct(Means$minuteAver, tz = "GMT")


# create xts object to use dygraphs
q1 <- as.xts(Means$x1, Means$minuteAver)
dygraph(q1)%>% dyRangeSelector()

# try to fit a model
ts1 <- ts(Means$minuteAver, Means$x1)
hw <- HoltWinters(ts1, beta=FALSE, gamma=FALSE)
predicted <- predict(hw, n.ahead = 300, prediction.interval = FALSE)

dygraph(predicted, main = "Predicted loudness activity") %>%s
    dyAxis("x", drawGrid = FALSE) %>%
    dySeries(c("lwr", "fit", "upr"), label = "Loudness") %>%
    dyOptions(colors = RColorBrewer::brewer.pal(3, "Set1"))

## A plot for each host.
#xyplot(df3$minuteAver ~ minuteAver | hosts, data = Means, type = "o",
#       scales = list(x = list(relation = "free", rot = 90)))


# long-term moving average of anomaly
# ff <- 10
# Means$ma <- stats:::filter(Means$x1, rep(1/ff, ff), sides = 2)
# with (Means, lines2D(day, x1,
#                        colvar = x1 > 80,
#                        col = c("#d7e31c", "#818810"),
#                        main = "Loudness log", type = "h",
#                        colkey = FALSE, las = 1, xlab = "minute", ylab = ""))
# lines2D(Means$day, Means$ma, add = TRUE)
# dev.off()





