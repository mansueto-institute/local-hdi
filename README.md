
# Neighborhood-Level Human Development Index
Goal: Calculate the Human Development Index at the Census tract level

## Research Question 
As stated by the UN, “The Human Development Index is a summary measure of average achievement in key dimensions of human development”. 
[(1)](http://hdr.undp.org/en/content/human-development-index-hdi)
Constructing the HDI at the local level will help bridge the ideas of "neighborhood effects" in Sociology with the Capabilities Approach of Human Development in economics and political science. 
[(2)](https://scholar.harvard.edu/sampson/filter_by/neighborhood-effects) 
[(3)](https://www.iep.utm.edu/sen-cap/)
The goal of this project was to integrate data streams from the Centers For Disease Control, US Bureau of Economic Analysis, and the US Census Bureau to construct the HDI at the census tract level, in order identify disparities in health, education, and income between different neighborhoods across the US.


## Data 

The Life Expectancy component of the HDI was calculated using tract-level life expectancy estimates from the CDC's USALEEP Project[(4)](https://www.cdc.gov/nchs/nvss/usaleep/usaleep.html) 
and County-Level Life Expectancy Estimates from the Institute of Health Metrics and Evaluation. [(5)](http://ghdx.healthdata.org/record/ihme-data/united-states-life-expectancy-and-age-specific-mortality-risk-county-1980-2014)
USALEEP calculated a single tract-level estimate for 2010-2015, and the IHME calculated county-level estimates for every year from 1980 to 2014.

The Education Component of the HDI was calculated using tract level estimates for total population, educational attainment for population over 25 years of age, and school enrollment ratios for population under 25 years old,  from the American Community Survey 5 Year Estimates from 2015.
These reflected estimates from the 2010-2015 time frame. 
Example from Alabama [(6)](https://factfinder.census.gov/faces/tableservices/jsf/pages/productview.xhtml?pid=ACS_17_5YR_S1501&prodType=table)  
The data was extracted using the tidycensus package for the Census Bureau API [(7)](https://walkerke.github.io/tidycensus/articles/basic-usage.html)

The Income Component of the HDI was calculated using data from the US Bureau of Economic Analysis and ACS 5-year estimates. 
Gross National Income for 2015 (approx $19 trillion in 2011 $ PPP) was taken the UN Data repository [(9)} ((https://data.un.org/Data.aspx?q=GNI&d=WDI&f=Indicator_Code%3aNY.GNP.MKTP.PP.KD).
GDP by County estimates for 2012 -2015 was downloaded from the US BEA website. [(10)](https://www.bea.gov/data/gdp/gdp-county) 
County and Census Tract Aggregate Income estimates for 2015, as well as tract level Population estimates, were taken from the American Community Survey 5 Year Estimates from 2015.

## Methods/Definitions

The Human Development Index is the geometric mean of three indexes- the life expectancy index, the education index, and the income index. 
Each of these indices as internationally set "goalposts" designating certain values as upper and lower bounds. 
To allow comparisons between local US neighborhood HDIs and International HDIs, we have kept the same goalposts as the UN Development Program (UNDP) when calculating our HDI.

### Life Expectancy Index
Census Tract Level estimates of Life expectancy were taken from the USALEEP study.
County-level Life expectancy estimates (calculated by the Institute for Health Metrics and Evaluation) were substituted for tracts that did not have Life Expectancy values calculated by USALEEP. 
The UNDP life expectancy index was then calculated for each tract. 
The equation for the index is as follows: 

>LEI= (LE-85)/ (85-20) 

85 years old is the upper bound for life expectancy, and 20 years is the lower bound. 

### Income Index 

The UN uses Gross National Income is used to calculate the income index.
To keep our measures consistent with international standards, the Gross National Income for the US in 2015 was down allocated to each US tract based on tract share of US aggregate income, as reported by the Census Bureau . 


> Tract Level Gross National Income = (2015 US GNI) x  (2015 Census Tract Aggregate Income/ 2015 US National Aggregate Income)

These values were then divided by the total population of the tract to get an estimate of GNI per capita at the tract level. 

>Tract Level GNIppc = (Tract Level GNI/Tract Population)

These values were then used to calculate an Income Index for each census tract, using the equation listed below: 

>Income Index = (ln (GNIppc) -ln(100))/ ((ln(75,000) - ln(100)))

$100 is the lower bound for yearly income, and $75,000 is the upper bound.

### Education Index

The education index is a composite of two different indexes, the mean years of schooling index and the expected years of schooling index. 

#### Mean Years of Schooling Index

The mean years of schooling index is the average number of years of schooling for people 25 and older. 
This is calculated by converting the educational attainment levels of the population into average years of schooling as set by International Standard Classification of Education (ISCED) [(13)](http://uis.unesco.org/en/topic/international-standard-classification-education-isced)
This value is then put into the index, which is as follows: 

MYSI= MYS/ 15 

For the purposes of our study, we calculated the mean education index at the census tract level to capture the average education of adults in each tract.

#### Expected Years of Schooling Index

The expected years of schooling index is the number of years of schooling the population under 25 years old is expected to achieve, based on current enrollment rates. 
The enrollment rate for each age group is calculated, and then multiplied by the number of years they are expected to have been in school. 

> (Enrollment ratio for age group) *(Number of years that age group represents)

For example: 

> (# of 5 to 9 yr olds in school)/(# of 5 to 9 yr olds total) *5

These values are then summed and then put in the expected years of education index, which is as follows: 

> EYSI= EYS/18 

The expected education index requires all age groups from 5 to 25 to be represented to be calculated properly. There are a number of census tracts with missing age cohorts that cannot have an expected education index value calculated. In these cases, the county expected education index was substituted for the tract index. In the 4 counties which also had incomplete age cohorts (and therefore no expected education index value), the mean years of education was used to calclate the final education index. This is in line with the UN's philosophy that each of the values are "perfectly substitutable." 

#### Calculating Final Education Index

The values for MYSI and EYSI for each tract are then averaged for the education index '

>EI= (MYSI+EYSI)/2

### Computing Final HDI 

The HDI is a geometric mean of the 3 above indices: 

>HDI = (LEI+ EI+ II) ^ (1/3)


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

