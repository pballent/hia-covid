library(readr)
library(dplyr)

full_dataset_sample <- read_csv("/Users/philip.ballentine/Documents/hia_covid_repo/hia_covid_data_assets/hia_covid_combined_sample.csv")

head(full_dataset_sample)

## Getting the subset selection
library(leaps)
regfit = regsubsets(`Deaths_New_14_RollingAvg_PER_100K` ~ 
                           factor(Metro) +
                           Confirmed_New_RollingAvg_PER_100K + 
                           Poverty_PCT_2018 +
                           #factor(StateCD) + 
                           PCT_Black_ACS +
                           #retail_and_recreation_percent_change_from_baseline +
                           #workplaces_percent_change_from_baseline +
                           #residential_percent_change_from_baseline +
                           HS_DIPLOMA_ONLY_2018 +
                           BACHELORS_PLUS_2018 + 
                           Median_Income_2018
                           , 
                           data = full_dataset_sample,
                           nvmax = 10,
                           #really.big = TRUE
                           )  #Best Subset Selection for ALL variables


reg.summary <- summary(regfit)

par(mfrow = c(1, 3))


plot(reg.summary$rss, xlab = "Number of Variables", ylab = "RSS", type = "l")
plot(reg.summary$bic, xlab = "Number of Variables", ylab = "BIC", type = "l")
plot(reg.summary$adjr2, xlab = "Number of Variables", ylab = "Rsq", type = "l")


which.max(reg.summary$adjr2)
which.min(reg.summary$bic)

coef(regfit,5)


#install.packages("mixl")
#install.packages("jtools") 
# https://cran.r-project.org/web/packages/jtools/vignettes/summ.html#Other_options


#https://www.rdocumentation.org/packages/lsr/versions/0.5/topics/quantileCut
#install.packages("lsr")
library(lsr)


full_dataset_sample$POV_QUANT <- quantileCut(full_dataset_sample$Poverty_PCT_2018,5,labels=c(1,2,3,4,5))

library(jtools)
model <- lm(`Deaths_New_14_RollingAvg_PER_100K` ~ 
              Confirmed_New_RollingAvg_PER_100K
            + factor(Metro)
            + factor(POV_QUANT)
            + PCT_Black_ACS
            + PCT_Black_ACS*factor(POV_QUANT)
            #+ PCT_Black_ACS*factor(Metro)
            ,
            data=full_dataset_sample)
summ(model,digits = 5)
summary(model)


library(psych)
describeBy(full_dataset_sample$Poverty_PCT_2018, group=full_dataset_sample$POV_QUANT)

##
library(leaps)
regfit = regsubsets(`Deaths_New_14_RollingAvg_PER_100K` ~ 
                      factor(Metro) +
                      Confirmed_New_RollingAvg_PER_100K +
                      Poverty_PCT_2018 +
                      PCT_Black_ACS +
                      factor(POV_QUANT) +
                      residential_PCT_CFB_RollingAvg +
                      workplaces_PCT_CFB_RollingAvg +
                      HS_DIPLOMA_ONLY_2018 +
                      BACHELORS_PLUS_2018 + 
                      Median_Income_2018
                    , 
                    data = full_dataset_sample,
                    nvmax = 10,
                    )  #Best Subset Selection for ALL variables


reg.summary <- summary(regfit)

par(mfrow = c(1, 3))


plot(reg.summary$rss, xlab = "Number of Variables", ylab = "RSS", type = "l")
plot(reg.summary$bic, xlab = "Number of Variables", ylab = "BIC", type = "l")
plot(reg.summary$adjr2, xlab = "Number of Variables", ylab = "Rsq", type = "l")


which.max(reg.summary$adjr2)
which.min(reg.summary$bic)

coef(regfit,8)

coef(regfit,10)

model_big <- lm(
  `Deaths_New_28_RollingAvg_PER_100K` ~ 
    factor(Metro) +
    Deaths_New_RollingAvg_PER_100K +
    Poverty_PCT_2018 +
    #PCT_Black_ACS +
    #factor(POV_QUANT) +
    #residential_PCT_CFB_RollingAvg +
    workplaces_PCT_CFB_RollingAvg +
    HS_DIPLOMA_ONLY_2018 #+
    #BACHELORS_PLUS_2018 + 
    #Median_Income_2018
, 
data = full_dataset_sample)
 summ(model_big, digits=5, confint = TRUE)
 
 
 
 full_dataset_sample$STAYHOME_QUANT <- quantileCut(full_dataset_sample$residential_PCT_CFB_RollingAvg,10,labels=c(1,2,3,4,5,6,7,8,9,10))
 describeBy(full_dataset_sample$residential_PCT_CFB_RollingAvg, group=full_dataset_sample$STAYHOME_QUANT)
 
 
 full_dataset_sample$DEATHSCHANGE <- full_dataset_sample$Deaths_New_28_RollingAvg_PER_100K - full_dataset_sample$Deaths_New_7_RollingAvg_PER_100K
 
 model_big <- lm(
   `DEATHSCHANGE` ~ 
     #`Deaths_New_RollingAvg_PER_100K` +
     factor(Metro) +
     Confirmed_New_RollingAvg_PER_100K +
     #Poverty_PCT_2018 +
     #PCT_Black_ACS +
     residential_PCT_CFB_RollingAvg +
     retail_and_recreation_PCT_CFB_RollingAvg +
     #residential_PCT_CFB_RollingAvg*factor(Metro) +
     workplaces_PCT_CFB_RollingAvg
     #HS_DIPLOMA_ONLY_2018 #+
   #BACHELORS_PLUS_2018 + 
   #Median_Income_2018
   , 
   data = full_dataset_sample)
 summ(model_big, digits=5, confint = TRUE)
 
 summary(model_big)
 
 dat$size <- ifelse(dat$Sepal.Length < median(dat$Sepal.Length),
                    "small", "big"
 )
 
 
 ## CHI SQUARE TEST OF MOBILITY NULLITY
full_dataset_sample$Mob_ISNA <- ifelse(is.na(full_dataset_sample$residential_PCT_CFB), "NULL", "NOT_NULL")

METRO_CHISQ <- cbind.data.frame(full_dataset_sample$Mob_ISNA, full_dataset_sample$residential_PCT_CFB, full_dataset_sample$Metro)

head(METRO_CHISQ)
summary(table(full_dataset_sample$Mob_ISNA, full_dataset_sample$Metro))

library(ggplot2)

ggplot(METRO_CHISQ) +
  aes(x = full_dataset_sample$Mob_ISNA, fill = full_dataset_sample$Metro) +
  geom_bar() +
  scale_fill_hue() +
  theme_minimal()


test <- chisq.test(table(full_dataset_sample$Mob_ISNA, full_dataset_sample$Metro))
test
