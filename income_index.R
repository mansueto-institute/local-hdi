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

#Sum all tract incomes to get an aggregate national income 
newaggregate_tract_income_2015$national_aggregate_income <- 
  sum(newaggregate_tract_income_2015$`Aggregate Tract Income 2015`, na.rm = TRUE)

#Create a tract fraction of the natonal aggregate income 

newaggregate_tract_income_2015$fraction_of_nat_income <- 
  ((newaggregate_tract_income_2015$`Aggregate Tract Income 2015`)/(newaggregate_tract_income_2015$national_aggregate_income))


#Create column with 2015 National GNI value in 2011 $ PPP (https://data.un.org/Data.aspx?q=GNI&d=WDI&f=Indicator_Code%3aNY.GNP.MKTP.PP.KD)
#The UN's 2016 HDI report used GNI in 2011 $ PPP (http://hdr.undp.org/sites/default/files/hdr_2016_statistical_annex.pdf) in 2015, 
#so that is what we will use here 
newaggregate_tract_income_2015$National_GNI_2015 <- 19096853723915.5

#Caluclate Tract GNI by multiplying income fraction by National GNI

newaggregate_tract_income_2015$Tract_GNI <- 
  (newaggregate_tract_income_2015$National_GNI_2015)*
  (newaggregate_tract_income_2015$fraction_of_nat_income)

#Calculate population of each tract

ctpop <- map_df(us, function(x) {get_acs(geography = "tract", 
                                         variables = "S0101_C01_001" , year = 2015,
                                         state = x) })


ctpop <- ctpop[c('GEOID','NAME','estimate')] %>%
  rename('2015_Tract_population'= 'estimate')


GNI_by_Census_tract <- left_join(newaggregate_tract_income_2015, ctpop, by = "GEOID")

GNI_by_Census_tract$GNIppc_per_tract <- (GNI_by_Census_tract$Tract_GNI)/(GNI_by_Census_tract$'2015_Tract_population')

#Take Tract IDs to Create County FIPS

GNI_by_Census_tract$CountyGEOID <- substr(GNI_by_Census_tract$GEOID, 1,5)



#Download County FIPS to CBSA Corsswalk 
temp <- tempfile()
download.file('https://data.nber.org/cbsa-csa-fips-county-crosswalk/cbsa2fipsxw.csv', temp)
crosswalk <- read_csv(temp, 
                      col_types = cols(fipsstatecode = col_character(), 
                                       fipscountycode = col_character()))
unlink(temp)


crosswalk <- crosswalk %>%
mutate("CountyGEOID"= paste0(fipsstatecode, fipscountycode))%>%
  rename("countyname"= "countycountyequivalent")


#Join Files to get county to cbsa crosswalk
GNI_by_MSA <- left_join(GNI_by_Census_tract, crosswalk, by = "CountyGEOID")


#Download Regional Price Parity File from BEA (https://apps.bea.gov/regional/histdata/releases/1117rpi/index.cfm)
temp <- tempfile()
download.file('https://apps.bea.gov/regional/histdata/releases/0917rpi/rpp0917.zip', temp)
whole_rpp <- read.csv(unz(temp, 'RPP_2008_2015_MSA.csv'))
unlink(temp)

regional_ppp <- whole_rpp[grep("RPPs: All items",
                                                    whole_rpp$Description), ]

regional_ppp_2015 <- regional_ppp[,c('GeoFIPS','GeoName','X2015')]

regional_ppp_2015 <- rename(regional_ppp_2015, "2015 MSA PPP"= "X2015")


regional_ppp_2015 <- rename(regional_ppp_2015, 
                            "cbsa"= "GeoFIPS")

regional_ppp_2015$cbsa <- as.numeric(regional_ppp_2015$cbsa)

GNI_MSA_withppp <- left_join(GNI_by_MSA, regional_ppp_2015, by = c("cbsacode"= "cbsa"))

GNI_MSA_withppp$`2015 MSA PPP`[is.na(GNI_MSA_withppp$`2015 MSA PPP`)] <- 87.8

GNI_MSA_withppp$MultiplyPPP <- 1/((GNI_MSA_withppp$`2015 MSA PPP`)/100)

GNI_MSA_withppp$Adjusted_tractGNI <- (GNI_MSA_withppp$Tract_GNI)*
  (GNI_MSA_withppp$MultiplyPPP)

GNI_MSA_withppp$Adjusted_tract_GNIppc <- (GNI_MSA_withppp$Adjusted_tractGNI)/
  (GNI_MSA_withppp$`2015_Tract_population`)

#Create Income Index 

income_index <- GNI_MSA_withppp %>% 
  select( 'GEOID', 'CountyGEOID', 'NAME.x', 12:18,23, '2015_Tract_population',   'GNIppc_per_tract', 'Adjusted_tract_GNIppc') %>% 
  mutate(adjusted_income_index=  (log(Adjusted_tract_GNIppc) -log(100))/ ((log(75000) - log(100)))) %>%  
  mutate(unadjusted_income_index=  (log(GNIppc_per_tract) -log(100))/ ((log(75000) - log(100))))


#Save File 
write.csv(income_index, "income_index.csv")
