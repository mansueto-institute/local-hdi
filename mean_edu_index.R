#Load Libraries
library(tidyverse)
library(tidycensus)

#Get Variable names for ACS Table B15003 

v15 <- load_variables(2015, "acs5", cache = TRUE)

v15 <- v15 %>% 
  filter(str_detect(name,"B15003"))


#Create set of state Abbreviations 
us <- unique(fips_codes$state)[1:51]



#Get ACS Table B15003, which has ed. Attainment 
edu_attain<- map_df(us, function(x) { get_acs(geography = "tract",
                                                 year= 2015,
                                                 cache_table= TRUE,
                                                 output= "wide",
                                                 table = "B15003", 
                                                 state = x, 
                                                 survey = "acs5") })



#Select estimates columns 

simple_edu_attain <- edu_attain %>%
  select("GEOID","NAME", ends_with("E")) 

simple_edu_attain <- as.data.frame(simple_edu_attain)

#Sum columns according to ISCED classifications of Grades

tract_isced <- simple_edu_attain %>%
  mutate("I8"= B15003_025E, 
         'I7'= B15003_024E+ B15003_023E, 
         'I6'= B15003_022E,
         'I5'= B15003_021E, 
         'I4+I3'= B15003_020E+ B15003_019E+ B15003_018E+ B15003_017E, 
         'I2'= B15003_016E+ B15003_015E+ B15003_014E+ B15003_013E, 
         'I1'= B15003_012E + B15003_011E+ B15003_010E, 
        'I03'= B15003_009E + B15003_008E+ B15003_007E+ B15003_006E+ B15003_005E
        + B15003_004E + B15003_003E, 
        'I02+I01'= B15003_002E ) %>%
  select('GEOID', 'NAME', 'B15003_001E', starts_with("I"))

#Convert to percentages by dividing by total pop 25 yrs and older

tract_isced[,4:12]<- tract_isced[,4:12]/tract_isced[,3]


#Calculate mean edu of tracts 

tract_isced <- tract_isced %>%
  mutate('mean_edu'= ((I8* 21)+ (I7* 18)+ (I6*16)+ (I5*14)+ 
           (`I4+I3`*12) + (I2*9) + (I1*6)+ (I03*3)+ 
           (`I02+I01`*0)))

#Calculate index by dividing by 15

tract_isced <- tract_isced %>% 
  mutate("mean_edu_index" = mean_edu/15)

#Create Short File
mean_edu_index <- tract_isced %>%
  select('GEOID','NAME', 'mean_edu_index') 

