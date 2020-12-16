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


## QUESTION OF INTEREST

1. How much of the mortality toll of COVID-19 can be predicted by county-level characteristics such as the state, the geographic region, how rural or urban the county is, racial/ethnic composition, county median income and poverty rates, how educated the county inhabitants are, etc. while addressing multicollinearity? How have these trends changed over time? 

2. What is the “best model” to predict “lagged” COVID-19 deaths, or the rate of COVID-19 deaths per 100K people in a county population? What is the relationship between reported cases and “lagged” COVID-19 deaths? 

3. Is there any evidence in Google Mobility data at the county level that increased time spent at home may be related to reported deaths from COVID-19 per capita at the county level? 


## DATA SOURCES

#### COVID-19 DATA
- Acquire data that is used by the COVID Tracking Project, Johns Hopkins University, using the Datahub package and infrastructure. 
- Data is updated daily
- Data is not geocoded, and only has the county and/or city text name
- Data is collated by volunteers, and is sometimes inconsistently reported/has corrections
- Variables of interest are date, location, total cases as of that date, and total deaths as of the date 

### COUNTY DATA
- Data sources from the US Census, particularly the 5-Year Annual Community Survey, last performed in 2018
- Some data sourced using Census-provided API to retrieve information using FIPS codes; other data sourced from the USDA Economic Research Service via flat files
- All data is at county level, as defined by FIPS Code
- 64,000+ variables in the ACS alone 
- I selected the variables  total population, Black population, Native American population, Hispanic population (not mutually exclusive), percent in poverty, median income for county, and education variables (percent with high school diploma only, percent with Bachelor’s degree or higher)

### GOOGLE MOBILITY DATA
- Reports from Google from Google maps data, reported aggregated at county level as a time series
- Data is updated daily, I hand-downloaded the CSV
- Data is geocoded using FIPS 
- Data is not reported for all counties, and this changes over time 
- Data gap for ~50% of counties in September that I reached out to Google to ask about 
- Variables of interest are percent change in activity from baseline in various settings (work, shopping, home, etc.) The most consistently reported was time at home spent relative to baseline, which was generally elevated (although not everywhere!) 

### COUNTY SHAPE FILES (FOR TABLEAU) 
- Shape file that uses FIPS to code counties
- Provides polygons and locations for US counties and states 
- I hand loaded the .CSV and imported it into Tableau 

## DATA ISSUES

### Geocoding the county names in the COVID-19 Dataset
- Some counties have the same name as the state that they are located in (New York County, Utah County, etc.) and geocoders tended to code these as states, not counties
- Some areas were included in the COVID-19 dataset that are not at the county level at all (such as at the city level), and in some cases are places that used to be part of different FIPS codes, so the geocoder would sometimes get these codes wrong 

### Data types
- FIPS codes should be coded as strings and sometimes contain leading zeroes, but they  are often implicitly read as integers/floats in both Excel, Python, and R leading to leading zero loss without explicitly altering their data type during import 
###  Geographic Data consistency
- Although Puerto Rico was included in the COVID-19 data, and is available in many Census datasets, I was only able to find comprehensive data for educational attainment, poverty, and rural-urban divides in flat file format from the USDA Economic Research Service, which omitted Puerto Rico in their poverty estimates, which I used as the backbone of my counties dataset. 

### API performance
- Using the Census API, the average call/response time for a single variable for a single county that I clocked was about 1.5 seconds, so for roughly 3300 counties, it took about 80 minutes to look up a single variable 
- Looking up several variables took many hours (overnight)
- This illustrates the performance benefit of using a .CSV for this purpose, but finding .CSVs was difficult
-- Next time, using something like Google Cloud with public data sets preloaded would be by far preferable then going out and finding my own or using the Census API 

### Google Mobility Data
- Google mobility data was not available for every county for every day
- This may have been because there were not enough Google users in that county on a specific day to a) protect the privacy of users and b) calculate valid measurements
- There was also a “revision” made to the files which I found may have resulted in a fair amount of missing data during mid-August into early September
- I reached out to Google via Twitter and email,  but since this was late in the game,I was never able to determine what the issue was/is
The residential change from baseline was a) the most reliably populated, and b) unaffected by this issue, so I ended up using it in my regression to avoid dropping tons of data 


## TOOLS USED 
### Data Wrangling - Python Jupyter Notebooks
- Download the day’s COVID data (final analysis done on 2020-12-09
- Import mobility data using flat files 
- Import county data using flat files and API
- Geocode and clean the COVID dataset
- Merge the datasets together
- Unit tests using Pytest to ensure that counties weren’t duplicated or missing
- Subset different datasets to feed into Tableau 

### Analysis - Python JuPyter Notebook using R-style regression
- Assess multicollinearity using VIF and corrplot 
- Python implementation of all-subsets regression
- Selecting models using BIC and Adjusted R-Squared as well as logic and judgment

### Visualization - Python using Seaborn, Tableau

## DATA TRANSFORMATION
### Creating new variables to support analysis
- Data change over time 
   - New deaths
    - New cases
- Rolling Averages
   - Helps to eliminate spikiness and data anomalies (negative counts due to revisions, holidays, weekend effects, etc.) 
   - Seven day non-centered windows 
- Data lag 
   - Deaths 7, 14, 21 days after the cases reported on day T
- Per capita measures 
   - Deaths, cases, by 100K population
   - Population by county is very right-tailed, with a median of 25K, a mean of 101K, and a standard deviation of 325K
   - Raw measures by themselves are not always very helpful, but inherent tension here because reporting by 100K population can also skew human impact
- Final dataset comprises > 1 million rows, with one row per county per day for 3,100+ counties, and the cases, deaths, rolling averages, per capita, and county-level variables such as per capita income 

## SUMMARY OF FINDINGD
- Multicollinearity between many measures poses challenges to analysis
   - Examples of highly correlated variables: percent living in poverty and percent with Bachelor's degree or higher, and both of these correlate with median income of a given county. Mobility data indicating "staying at home" correlates highly with higher income counties, which also tend to be urban areas rather than rural or remote areas. 
- Data at a county level is rather imprecise 
   - Ex: Boston, Newton, Lowell, and Weston are in the same county but are very different communities
- Percentage of population identifying as Black is a significant predictor of death toll for COVID-19, although this measure is correlated with other measures that also act as predictors for higher per capita death toll from COVID-19
   - A model with multiple interactions would be a good next step to analyze this
- There are omitted variables in this analysis, such as the rate of true disease prevalence, the rate of hospitalization, different rates of reporting cases and deaths, and many others
- 100 reported cases seem to predict roughly .5 - 1.5 deaths from COVID reported 14-21 days later, and this seems pretty stable over time since approximately June 1
- Many models of deaths (either new deaths or total death toll from COVID-19 show an increase in adjusted R squared up until the early Fall of 2020, and then falls in adjusted R squared later. This may be due to a more widespread disease toll that is affecting nearly all US counties more “equally” than before (at the county level) 

