####Step 1: Load Libraries####
library(tidyverse)
library(tidycensus)

####Step 2: Download some Aggregate Income at Tract Level and County Levels####

#Create new dataframe with GEOIDs of all census tracts 
#Create a new variable with state census_county_fips codes

us <- unique(fips_codes$state)[1:51]

#Download Aggregate Income for Census Tracts in 2015


aggregate_tract_income_2015 <- map_df(us, function(x) {get_acs(geography = "tract", 
                                      variables = c(aggregate_tract_income = "B19313_001"), year = 2015,
                                      state = x) 
})


#Simplify and organize the data extracted

newaggregate_tract_income_2015 <- aggregate_tract_income_2015 %>% 
  select('GEOID', 'NAME', 'estimate') %>% 
  rename('Aggregate Tract Income 2015'= 'estimate')

#Download Aggregate Income for US Counties in 2015

aggregate_county_income_2015 <- map_df(us, function(x) {get_acs(geography = "county", 
                                       variables = c(aggregate_tract_income = "B19313_001"), year =2015,
                                       state = x) 
})


#Simplify and organize the data 

newaggregate_county_income_2015 <- aggregate_county_income_2015 %>% 
  select('GEOID', 'NAME', 'estimate') %>% 
  rename('Aggregate County Income 2015'= 'estimate', 
         'census_county_fips'="GEOID")

#Create a new column with county census_county_fips for census tracts using frst 5 digits of GEOIDs

newaggregate_tract_income_2015$census_county_fips <- substr(newaggregate_tract_income_2015$GEOID, 1,5)


#Join the 2015 Aggregate Tract Income with the 2015 County Aggregate Income 
GNI_by_Census_tract <- left_join(newaggregate_tract_income_2015, newaggregate_county_income_2015,
                                 by= "census_county_fips")

#Convert Census FIPS codes to a numeric for easier merging
GNI_by_Census_tract$census_county_fips <- as.numeric(GNI_by_Census_tract$census_county_fips)



#Next, load in the census- BEA county FIPS crosswalk(file will be titled "CountyCrosswalkFull")
#Create a dataframe with the crosswalk between census and BEA FIPS codes
census_bea_crosswalk <- CountyCrosswalkFull[,c(1,2,3,4)]

#Add crosswalk to GNI dataframe
GNI_by_Census_tract <- left_join(GNI_by_Census_tract, census_bea_crosswalk, by = "census_county_fips")

####Step 3: Add in Values for National GNI and GDP####

#Create a column with the value of the Gross National Income of the US in 2018 (taken from https://fred.stlouisfed.org/series/MKTGNIUSA646NWDB 
#and https://data.worldbank.org/indicator/NY.GNP.MKTP.CD?locations=US)

GNI_by_Census_tract$National_GNI_2015 <- 18700478000000

#Create a column with the value of GDP from 2018 ( source: https://fred.stlouisfed.org/series/GDPA#0, and 
#https://fred.stlouisfed.org/release/tables?rid=53&eid=41047&od=2015-01-01#)

GNI_by_Census_tract$National_GDP_2015 <- 18224780000000


GNI_by_Census_tract <- GNI_by_Census_tract[,c(1,4,8,2,10,11,6,3)]


#####Step 4: Add in County GDP Information from BEA#####


#Download the GDP by County file from BEA website (https://www.bea.gov/data/gdp/gdp-county). 
#The file will be titled "GCP_Release_1" 
#First, rename the relevant column "2015 County GDP

colnames(GCP_Release_1)[colnames(GCP_Release_1)=="..9"] <- "2015 County GDP"

#Simplify GDP file

GDP <-subset(GCP_Release_1, IndustryName == 'All Industries', select = c("FIPS","Countyname","Postal","LineCode", "IndustryName", "2015 County GDP"))

countygdp <- GDP[,c("FIPS", 'Countyname','2015 County GDP')]

#Convert columns to numerics for dataframe joins

countygdp$`2015 County GDP` <- as.numeric(countygdp$`2015 County GDP`)
countygdp$FIPS <- as.numeric(countygdp$FIPS)

#Create a combined file with County GDPs
#Remeber to join based on BEA ccounty FIPS, b/c this information is from the BEA and will not match the 
#Census County FIPS exactly. 

GNI_by_Census_tract <- left_join(GNI_by_Census_tract, countygdp, by= c("bea_county_fips"= "FIPS"))

#BEA GDP estimates are in thousands of dollars, so make sure to multiply by 1000

GNI_by_Census_tract$`2015 County GDP` <- (GNI_by_Census_tract$`2015 County GDP`) *1000

######Step 5: Create County and Tract Income Fractions####

GNI_by_Census_tract$Countyname <- NULL

GNI_by_Census_tract$County_GDP_Fraction <- (GNI_by_Census_tract$`2015 County GDP`)/(GNI_by_Census_tract$National_GDP_2015)

GNI_by_Census_tract$Tract_Income_Fraction <- (GNI_by_Census_tract$`Aggregate Tract Income 2015`)/(GNI_by_Census_tract$`Aggregate County Income 2015`)

GNI_by_Census_tract$GNI_per_tract <- (GNI_by_Census_tract$National_GNI_2015)*
  (GNI_by_Census_tract$County_GDP_Fraction)*
  (GNI_by_Census_tract$Tract_Income_Fraction)

####Step 6: GNI is taken per capita, so need to divide by population####


ctpop <- map_df(us, function(x) {get_acs(geography = "tract", 
                                         variables = "B15003_001" , year = 2015,
                                         state = x) })


ctpop <- ctpop[c('GEOID','NAME','estimate')] %>%
  rename('2015_Tract_population'= 'estimate')


GNI_by_Census_tract <- left_join(GNI_by_Census_tract, ctpop, by = "GEOID")

GNI_by_Census_tract$GNIppc_per_tract <- (GNI_by_Census_tract$GNI_per_tract)/(GNI_by_Census_tract$'2015_Tract_population')

####Step 7: Create the Income Index####

GNI_by_Census_tract$Income_Index <-((log(GNI_by_Census_tract$GNIppc_per_tract)-log(100))/(log(75000)-log(100)))


  