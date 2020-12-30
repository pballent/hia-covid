
# COVID-19 Impacts on the US: Assembling a Large Dataset for Regression Analysis and Visualization

I compiled COVID data from a few different publicly available sources as part of a term project for a class in the Health Informatics and Analytics MS program at the Tufts University School of Medicine. 

The full presentation is available [online](https://docs.google.com/presentation/d/e/2PACX-1vRIzsLQuog1xqa6DBsB7gwYrb-0ciUR3HrKJXlPqOix5xYM7DNlx5843hiWaJzrS1NstusXbK8IIJl_/pub?start=false&loop=false&delayms=3000)

{{.Inner}}

{{< rawhtml >}}
<p><iframe src="https://docs.google.com/presentation/d/e/2PACX-1vRIzsLQuog1xqa6DBsB7gwYrb-0ciUR3HrKJXlPqOix5xYM7DNlx5843hiWaJzrS1NstusXbK8IIJl_/embed?start=false&loop=false&delayms=60000" frameborder="0" width="960" height="569" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe></p>
{{< rawhtml >}}



## COVID-19 BACKGROUND
- As of mid-December 2020, close to 300,000 Americans have died from COVID-19, with 2,500-3,000 dying each day from the disease as part of a fall/winter “spike”
- In June 2020, the Federal Reserve forecasted a 6.5% decline in GDP in 2020 amid a  “collapse in employment” as a result of the pandemic and public health measures taken to address it (CEPAL, 2020). 
- In addition to the death and morbidity caused by the disease, many have pointed to the devastating effects of the economic damage, closed schools, isolation due to public health measures, etc. 
- Impacts have fallen disproportionately on Black, Hispanic, immigrant, and other disadvantaged communities due to the intersection of environmental racism, occupational hazards, inequalities in social determinants of health, and other factors. 


## QUESTIONS OF INTEREST 
1. How much of the mortality toll of COVID-19 can be predicted by county-level characteristics such as the state, the geographic region, how rural or urban the county is, racial/ethnic composition, county median income, poverty rates, how educated the county inhabitants are, etc. while addressing multicollinearity? How have these trends changed over time? 

2. What is the “best model” to predict “lagged” COVID-19 deaths, or the rate of COVID-19 deaths per 100K people in a county population? What is the relationship between reported cases and “lagged” COVID-19 deaths? 

3. Is there any evidence in Google Mobility data at the county level that increased time spent at home may be related to reported deaths from COVID-19 per capita at the county level? 


## DATA SOURCES

### COVID-19 DATA
- Acquire data that is used by the COVID Tracking Project, Johns Hopkins University, using the Datahub.io infrastructure via Python. 
- Data is updated daily
- Data is not geocoded, and only has the county and/or city text name
- Data is collated by volunteers and is sometimes inconsistently reported/has corrections
- Variables of interest are date, location, total cases as of that date, and total deaths as of the date 

### COUNTY DATA
- Data sources from the US Census, particularly the 5-Year Annual Community Survey, last performed in 2018
- Some data sourced using Census-provided API to retrieve information using FIPS codes; other data sourced from the USDA Economic Research Service via flat files
- All data is at the county level, as defined by FIPS Code
- There are 64,000+ variables in the ACS 5 alone 
- I selected the variables  total population, Black population, Native American population, Hispanic population (not mutually exclusive), percent in poverty, median income for each county, and education variables (percent with high school diploma only, percent with Bachelor’s degree or higher)

### GOOGLE MOBILITY DATA
- Reports from Google from Google maps data, reported aggregated at the county level as a time series
- Data is updated daily, I hand-downloaded the CSV
- Data is geocoded using FIPS 
- Data is not reported for all counties, and this changes over time 
- Data gap for ~50% of counties in September that I reached out to Google to ask about 
- Variables of interest are percent change in activity from baseline in various settings (work, shopping, home, etc.) The most consistently reported was time at home spent relative to baseline, which was generally elevated (although not everywhere!) 

### COUNTY SHAPE FILES (FOR TABLEAU) 
- Shapefile that uses FIPS to code counties
- Provides polygons and locations for US counties and states 
- I hand loaded the .CSV and imported it into Tableau 

## DATA ISSUES

### Geocoding the county names in the COVID-19 Dataset
- Some counties have the same name as the state that they are located in (New York County, Utah County, etc.) and geocoders tended to code these as states, not counties
- Some jurisdictions were included in the COVID-19 dataset that are not at the county level at all (such as at the city level), and in some cases are places that used to be part of different FIPS codes, so the geocoder would sometimes get these codes wrong 

### Data types
- FIPS codes should be coded as strings and sometimes contain leading zeroes, but they  are often implicitly read as integers/floats in both Excel, Python, and R leading to leading zero loss without explicitly altering their data type during import 

###  Geographic data consistency
- Although Puerto Rico was included in the COVID-19 data, and is available in many Census datasets, I was only able to find comprehensive data for educational attainment, poverty, and rural-urban divides in flat-file format from the USDA Economic Research Service, which omitted Puerto Rico in their poverty estimates, which I used as the backbone of my counties dataset. 

### API performance
- Using the Census API, the average call/response time for a single variable for a single county that I clocked was about 1.5 seconds, so for roughly 3300 counties, it took about 80 minutes to look up a single variable 
- Looking up several variables took many hours (overnight)
- This illustrates the performance benefit of using a .CSV for this purpose
    - Next time, using something like Google Cloud with public data sets preloaded would be by far preferable than going out and finding my own or using the Census API 

### Google mobility data
- Google mobility data was not available for every county for every day
- This may have been because there were not enough Google users in that county on a specific day to a) protect the privacy of users and b) calculate valid measurements
- There was also a “revision” made to the files which I found may have resulted in a fair amount of missing data from mid-August into early September
- I reached out to Google via Twitter and email, but I was never able to determine what the issue was/is
- The residential change from baseline was a) the most reliably populated, and b) unaffected by this issue, so I ended up using it in my regression to avoid dropping large percentages of the data for this period. 
- Working with the Google mobility data had inherent risks in biasing the model, since Google mobility data was only available for some counties (approximately 65% of the data was lost when dropping all rows that did not contain Google Mobility data residential change from baseline), and these tended to be more urban areas with higher populations, incomes, education, etc. This non-random distribution of NULL Google mobility data was verified with a chi-squared test on a random sample of the data that yielded a p value less than < 2.2e-16. 

### Multicollinearity
- Multicollinearity between many measures poses challenges to analysis
    - Examples of highly correlated variables: percent living in poverty and percent with Bachelor's degree or higher, and both of these correlate with the median income of a given county. Mobility data indicating "staying at home" correlates highly with higher income counties, which also tend to be urban areas rather than rural or remote areas.

### Limitations of county-level analysis
- Data at a county level is fairly imprecise due to heterogeneity within counties
    For example, Boston, Newton, Lowell, and Weston are are in the same county in Massachusetts, but they are very different communities in terms of their income per capita, poverty rates, racial/ethnic makeup, housing density, etc.

### Ommitted variables
- There were many omitted variables in this analysis, such as the rate of true disease prevalence, county-level differences in how COVID-19 cases and deaths are recorded and reported, the rate of hospitalizations, test positivity rates, and many others

## TOOLS USED 
### Data Wrangling - Python Jupyter Notebooks
- Download the day’s COVID data (final analysis done on 2020-12-09) 
- Import mobility data using flat files 
- Import county data using flat files and API
- Geocode and clean the COVID dataset
- Merge the datasets together
- Unit tests using Pytest to ensure that counties weren’t duplicated or missing
- Subset different datasets to feed into Tableau 

### Analysis - Python Jupyter Notebook using R-style regression
- Assess multicollinearity using VIF and corrplot 
- Python implementation of all-subsets regression
- Selecting models using BIC and Adjusted R-Squared as well as logic and judgment

### Visualization 
- I used Python, particularly matplotlib and Seaborn to generate graphs for my presentation
- I also leveraged Tableau to generate additional chloropleth [visuals](https://docs.google.com/presentation/d/e/2PACX-1vTGiSVwu4VAjxvYI3fTH5XnyGvsVXZc07FXMHlqqT8gU86zR4LyYIZCFMvBHuh_2g/embed?start=false&loop=false&delayms=60000)

## DATA TRANSFORMATION
### Creating new variables to support analysis
- Change over time in the data
    - Total cases -> New confirmed
    - Total deaths -> New deaths
- 7-day Rolling Averages
   - Helps to eliminate spikiness and data anomalies (negative counts due to revisions, holidays, weekend effects, etc.) 
   - Seven-day non-centered windows
- Data lag 
   - Deaths 7, 14, 21 days after the cases reported on day T
- Per capita measures 
   - Deaths, cases, by 100K population
   - Population by county is very right-tailed, with a median of 25K, a mean of 101K, and a standard deviation of 325K
   - Raw measures by themselves are not always very helpful, but inherent tension here because reporting by 100K population can also misrepresent the human impact of total lives lost versus lives lost relative to county population 
- As of 2020-12-09, the dataset included > 1.01 million rows, with one row per county per day for 3,100+ counties, and the cases, deaths, rolling averages, per capita, and county-level variables

## ANALYSIS METHODOLOGY
- I principally used Ordinary Least Squares (OLS) linear regression models to examine the data, along with descriptive statistics
- I implemented a version of all subsets regression, where I selected 8 predictor variables from the 68 total variables and tested their performance against different dependent variables
- I also tested how these regressions performed over segments of the full dataset, running them on the period 2020-06-01 to 2020-12-01 (the period for which the best data is available and when widespread testing and reporting of COVID-19 cases and deaths has been available), as well as one-month periods or three-month periods within this time frame 
- To assess multicollinearity, I used Variable Inflation Factor (VIF) analysis and tried to reduce the number of correlated variables that I included in any of my models.
   - For example, I consistently used poverty percentage instead of median income at the county level because the former had a VIF of 8.8 and the latter had a VIF of 5.4.


## SPECIFIC FINDINGS 
### County Level Characteristics and Total COVID-19 Mortality Per 100,000 Population
In my judgment, the "best" one-level OLS linear regression model of the mortality toll of COVID-19 that relied on county-level characteristics was `Deaths_PER_100K ~ C(Metro) + PCT_Black_ACS + Poverty_PCT_2018 + C(StateCD)` 
- For the entire period 2020-06-01 to 2020-12-01, this model achieved an adjusted R squared of 0.268. Since the variables for county percentage of Black population and percentage in poverty were pretty highly correlated due to racial injustice and inequality in America, a two-level model would be a good next step for investigation. 
- Examining all possible subsets of selected variables in regression (255 regressions total), it became clear that state-level factors were significant. The highest adjusted R squared achievable without `StateCD` in the model was .14, while this model achieved an adjusted R squared of over .26. 
- In this model, the coefficient for a 1% increase in the poverty rate in a given county was a 1.1389 (1.112 - 1.165) increase in that county's rate of deaths per 100,000 population from COVID-19. 
   - As an example, while a county with 1 million residents might have a death rate of 50 per 100,000 population (total deaths: 500), this model suggests that if that county had a percentage of Black residents 10 percentage points higher, it would predict a death rate of 50 + (1.14 * 10) or 61.4 deaths per 100,000 population (total deaths: 614). 
- In this model, the coefficient for a 1% increase in the percentage of the Black population in a given county was a .83 (.818 - .845) increase in that county's rate of deaths per 100,000 population from COVID-19.
   - As an example, while a county with 1 million residents might have a death rate of 50 per 100,000 population (total deaths: 500), this model suggests that if that county had a poverty percentage 10 percentage points higher, it would predict a death rate of 50 + (.83 * 10) or 58.3 deaths per 100,000 population (total deaths: 583). 
- There is a correlation in the dataset between counties with higher percentages of Black population and more poverty, due to systemic racism and racial inequality in our society, so these effects often acted in tandem together. Using our existing example, county with both a 10% higher percentage of population in poverty and a 10% higher percentage Black population would predict a death rate of 50 + (.83 * 10) + (1.14 * 10) or 69.7 (total deaths: 697). This illustrates the strong relationship in the data showing COVID-19's unequal impact along racial and socioeconomic lines. 

### Predicting New Deaths from COVID-19 per 100,000 Population
In my judgment, the "best" one-level OLS linear regression model of new deaths from COVID-19 per 100,000 Population was `Deaths_New_14_RollingAvg_PER_100K ~ Confirmed_New_RollingAvg_PER_100K + Poverty_PCT_2018 + C(StateCD)`. 
- This was the highest-performing 3-factor model in the time period 2020-06 to 2020-12, and it did not perform much worse than any of the models with 4-8 variables included. The highest adjusted R squared achieved was .11 with a 7-variable model, and this 3-level model achieved an adjusted R squared of 0.140.
- In this model, each newly reported case (per 100k population) is estimated to result in .0120 deaths (.012-.012) reported 14 days later. 
- In this model, each percentage point of residents in poverty is estimated to result in a daily reported death rate per 100,000 population that is .0105 higher (.010 - .011). 
- In this model, there are large state fixed effects, which may indicate that state policies are having an important impact on the actual COVID-19 mortality rate, or that there are state-level differences in the reporting of cases and/or deaths. I think that both of these options are likely true. 

### Spending Time at Home (Google Mobility Data) and Total COVID-19 Mortality Per 100,000 Population
The regression model `Deaths_PER_100K ~ residential_PCT_CFB_RollingAvg + Poverty_PCT_2018 + C(StateCD) + PCT_Black_ACS + C(Metro)` achieved an adjusted R squared of 0.417 while keeping multicollinearity relatively limited. 
- This model shows an *association* of an increase in staying home relative to baseline of 1%  with an increased rate of death from COVID-19 per 100,000 population of 1.0972 (1.031 - 1.163). This may indicate that people in areas more impacted by COVID-19 deaths are staying home more, even when adding in poverty, state, percentage Black population, and metropolitan setting to the regression. Adding a month fixed effect increased this coefficient up to around 1.5, demonstrating that this trend is durable across the course of the pandemic.
- Since some counties did not have Google mobility measurements, and these counties tended to be less urban and less densely populated, this result is affected by the loss of many of the observations in the original dataset in a non-random way. 

### Model Performance Decline in Fall 2020
- Almost all of the models seeking to predict total COVID-19 deaths per capita or new COVID-19 deaths were increasingly effective at predicting the county's death toll from the April-September time period, and their adjusted R squared measures began to fall starting in the period September - November. 
- This analysis excludes the Google Mobility data because of the data gap beginning in August and the large number of counties with no Google mobility measurement.
- This may indicate that there was more local disparity in collecting case and death data earlier in the pandemic, and this decreased over time as testing became more widespread and there were more resources devoted to data collection. However, this explanation does not explain why the models' performance began to decline after September 2020.
- The decline in model performance, if it shows anything meaningful, may indicate that the pandemic death toll has become less impacted by county-level factors since the beginning of the fall "surge" and COVID-19 has spread more evenly across the country and is affecting counties more “equally” than before. 
