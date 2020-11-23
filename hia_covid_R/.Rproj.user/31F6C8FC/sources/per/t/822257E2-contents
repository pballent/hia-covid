library(readr)

covid_dataset_sample <- read_csv("~/Documents/Scripts/covid_dataset_sample.csv")

counties_data <- read_csv("~/Documents/Scripts/counties_dataset_full.csv")

library(dplyr)

full_dataset <- merge(covid_dataset_sample, counties_data,by="County_FIPS")

## Getting the subset selection
library(leaps)
regfit = regsubsets(`Deaths_New_+14_RollingAvg` ~ 
                           factor(Region) + 
                           factor(UrbanCD) +
                           Confirmed_New_RollingAvg + 
                           Poverty_PCT_2018 +
                           SOME_COLLEGE_2018 +
                           Median_Income_2018 +
                      factor(Region)*Confirmed_New_RollingAvg +
                      factor(Region)*Poverty_PCT_2018 +
                      #factor(Region)*SOME_COLLEGE_2018 +
                      factor(Region)*Median_Income_2018
                           , 
                           data = full_dataset,
                           nvmax = 10)  #Best Subset Selection for ALL variables
reg.summary <- summary(regfit)

par(mfrow = c(1, 1))

plot(reg.summary$rss, xlab = "Number of Variables", ylab = "RSS", type = "l")
plot(reg.summary$bic, xlab = "Number of Variables", ylab = "BIC", type = "l")

which.max(reg.summary$adjr2)
which.min(reg.summary$bic)

coef(regfit,8)

plot(reg.summary$bic, xlab = "Number of Variables", ylab = "BIC", type = "l")

model <- lm(`Deaths_New_+14_RollingAvg` ~ 
              Confirmed_New_RollingAvg +
              factor(Region) + 
              factor(Region)*Confirmed_New_RollingAvg +
              Poverty_PCT_2018 +
              Poverty_PCT_2018*factor(Region) #+
              #Median_Income_2018
            ,
            data=full_dataset)
summary(model)


regfit = regsubsets(Deaths ~ 
                      #Confirmed_New_RollingAvg +
                      factor(Region) + 
                      #factor(Region)*Confirmed_New_RollingAvg +
                      Poverty_PCT_2018 +
                      Poverty_PCT_2018*factor(Region) +
                      Median_Income_2018 + 
                      Median_Income_2018*factor(Region), 
                    data = full_dataset,
                    nvmax = 10)  #Best Subset Selection for ALL variables
reg.summary <- summary(regfit)
plot(reg.summary$adjr2, xlab = "Number of Variables", ylab = "Adjusted RSq", 
     type = "l")
summary(regfit)
which.max(reg.summary$adjr2)
which.min(reg.summary$cp)

plot(regfit,scale="adjr2")

coef(regfit, 8)
plot(regfit,scale="adjr2")

model <- lm (Deaths ~ 
                               Confirmed_New_RollingAvg +
                               factor(Region) + 
                               factor(Region)*Confirmed_New_RollingAvg +
                               Poverty_PCT_2018 +
                               Poverty_PCT_2018*factor(Region) +
                               Median_Income_2018 + 
                               Median_Income_2018*factor(Region), 
                             data = full_dataset
)
summary(model)