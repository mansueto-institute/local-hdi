###############Life Expectancy Index###############
#Step 1:Load Required Libraries
library(tidycensus)
library(tidyverse)
library(readxl)
library(gdata)

#Download Life Expectancy estimates by County from IHME website 
#(http://ghdx.healthdata.org/record/ihme-data/united-states-life-expectancy-and-age-specific-mortality-risk-county-1980-2014)
#(Select the first excel document in the "Files" tab, import with "location" line as first row)


url <- 'http://ghdx.healthdata.org/sites/default/files/record-attached-files/IHME_USA_COUNTY_LE_MORTALITY_RISK_1980_2014_NATIONAL_XLSX.zip'
download.file(url, 'my_data.zip')
unzip('my_data.zip')
newcountyLE <- read_excel('IHME_USA_COUNTY_LE_MORTALITY_RISK_1980_2014_NATIONAL_Y2017M05D08.XLSX', skip =1)




#Create new dataframe with only county names, FIPS codes, and calculated life expectancies for 2014

newLE <- newcountyLE[c('Location', 'FIPS', "Life expectancy, 2014*")]


#Select only rows with FIPS codes larger  than 100 to only include counties (remove states and countries)

onlycountyLE  <- newLE %>%
  filter(FIPS >100)

#Shorten the Life expectancy value row to only the first 5 characters, which are the predicted LE 
#(other numbers are expected range)

onlycountyLE$`Life expectancy, 2014*` <- substr(onlycountyLE$`Life expectancy, 2014*`, 1, 5)

#Convert columns to numerics for manipulation
onlycountyLE$`Life expectancy, 2014*` <- as.numeric(onlycountyLE$`Life expectancy, 2014*`)
#onlycountyLE$FIPS <- as.numeric(onlycountyLE$FIPS)

#Paste leading zero for some rows of FIPS codes to allow for GEOID intergration
onlycountyLE$FIPS <- formatC(onlycountyLE$FIPS, width = 5, format = "d", flag = "0")

##Step 2: CDC Data 
#Download CDC Dataset on US Life Expectancies at Tract Level 
#(https://www.cdc.gov/nchs/nvss/usaleep/usaleep.html)
#It imports all columns as numerics, removing leading zeros from all of the columns- these have to be added back in

temp <- tempfile()
download.file('https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NVSS/USALEEP/CSV/US_A.CSV', temp)
US_A <- read.csv(temp)
unlink(temp)

#Create new dataframe with Tract GEOIDs and Life Expectancies

cdcLE <- US_A %>% 
  select('Tract.ID', 'e.0.') %>% 
  rename('GEOID'= 'Tract.ID', 
         'life expectancy'= 'e.0.')

# Add Leading Zeros Back to Tract IDs 
cdcLE$GEOID <- str_pad(cdcLE$GEOID, 11, pad = "0")

#Create an extra column with county level FIPS codes using the first five digits of the Census Tract GEOIDs

cdcLE$FIPS <- substr(cdcLE$GEOID, 1,5)
cdcLE$GEOID <- as.character(cdcLE$GEOID)


#Since the USALEEP Dataset does not have GEOIDs for all the census tracts in the US, use the tidycensus library 
#to download a complete set of GEOIDs

us <- unique(fips_codes$state)[1:51]


percapitaincome <- map_df(us, function(x) {
  get_acs(geography = "tract", 
          variables = "B01003_001", 
          state = x) }) 


allLE <- percapitaincome[c('GEOID')]

#Create a column of FIPS codes based on the complete set of GEOIDs

allLE$FIPS <-substr(allLE$GEOID, 1,5)

#allLE$FIPS <- as.numeric(allLE$FIPS)
#allLE$GEOID <- as.numeric(allLE$GEOID)

#Merge the complete GEOID list with the County Life expectancies and the Tract level Life expectancies

allLE <- left_join(x= allLE, y= onlycountyLE,
                   by ='FIPS')


allLE <- left_join(x= allLE, y= cdcLE,
                   by ='GEOID')

#Rename the columns for clarification

allLE <- rename(allLE, 'tract LE'= 'life expectancy', 
                "FIPS"= "FIPS.x", 
                "County LE"= "Life expectancy, 2014*")

#Replace "NA" values in the "Tract LE" column with values from County LE column

allLE$`tract LE`[is.na(allLE$`tract LE`)] <- allLE$`County LE`[is.na(allLE$`tract LE`)]


#Create a final dataframe with the complete list of GEOIDs, FIPS codes, and LE values (with county substituitions)

finalLE <- allLE %>% 
  select('GEOID', 'FIPS', "tract LE")

#calculate the Life Expectancy Index

finalLE$LEindex = (finalLE$`tract LE` - 20)/65

le_index <- finalLE %>% 
  select('GEOID', 'FIPS', "LEindex") %>%
  rename("le_index" = "LEindex")

write.csv(le_index, "le_index.csv")
write.csv(finalLE, "LE_raw_values.csv")
