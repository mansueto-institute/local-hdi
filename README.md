
# Neighborhood-Level Human Development Index

## Overview
This is the code accompanying the article Human Development of US Cities and Neighborhoods. 


## Data 

The Life Expectancy component of the HDI was calculated using tract-level life expectancy estimates from the CDC's USALEEP Project[(4)](https://www.cdc.gov/nchs/nvss/usaleep/usaleep.html) 
and County-Level Life Expectancy Estimates from the Institute of Health Metrics and Evaluation. [(5)](http://ghdx.healthdata.org/record/ihme-data/united-states-life-expectancy-and-age-specific-mortality-risk-county-1980-2014)
USALEEP calculated a single tract-level estimate for 2010-2015, and the IHME calculated county-level estimates for every year from 1980 to 2014.

The Education Component of the HDI was calculated using tract level estimates for total population, educational attainment for population over 25 years of age, and school enrollment ratios for population under 25 years old,  from the American Community Survey 5 Year Estimates from 2015.
These reflected estimates from the 2010-2015 time frame. 
Example from Alabama [(6)](https://factfinder.census.gov/faces/tableservices/jsf/pages/productview.xhtml?pid=ACS_17_5YR_S1501&prodType=table)  
The data was extracted using the tidycensus package for the Census Bureau API [(7)](https://walkerke.github.io/tidycensus/articles/basic-usage.html)

The Income Component of the HDI was calculated using data from the US Bureau of Economic Analysis and ACS 5-year estimates. 
Gross National Income for 2015 was taken the UN Data repository [(9)] ((https://data.un.org/Data.aspx?q=GNI&d=WDI&f=Indicator_Code%3aNY.GNP.MKTP.PP.KD).
GDP by County estimates for 2012 -2015 was downloaded from the US BEA website. [(10)](https://www.bea.gov/data/gdp/gdp-county) 
County and Census Tract Aggregate Income estimates for 2015, as well as tract level Population estimates, were taken from the American Community Survey 5 Year Estimates from 2015.


## Code 
Run Scripts in following order: 
1. Life Expectancy Index 
2. Income Index 
3. Expected Education (Expect_edu) index
4. Mean Years of Education (mean_edu) index 
5. Final education (final_edu) index 
6. HDI Calculation



## Output 

## Author 
Created by Suraj (Neil) Sheth

## License 
MIT

