#Load Libraries
library(tidycensus)
library(tidyverse)


#The S1401 table has the information necessary to construct the index 

#Create a list of FIPS codes for US 
us <- unique(fips_codes$state)[1:51]

#Load school enrollment by age for 2019 ACS 5- year estimates 
school_enroll<- map_df(us, function(x) { get_acs(geography = "tract",
                                                 year= 2015,
                                                 cache_table= TRUE,
                                                 output= "wide",
                                                 table = "S1401_C01", 
                                                 state = x, 
                                                 survey = "acs5") })



#Select Name, GEOID, and columns with total pop and pop in school for age groups between 3 and 25

enrollment_ratio <- school_enroll %>% 
  select(1:2,31:50)

#Select estimates columns, rename them based on their variables, calculate percent enrollment for each cohort, and calculate edu index at county level
enrollment_ratio <-enrollment_ratio %>% 
  select("GEOID","NAME", ends_with("E")) %>%
  rename("5_9tot"="S1401_C01_015E" ,
         "5_9school"= "S1401_C01_016E" ,
         "10_14tot"= "S1401_C01_017E",
         "10_14school"= "S1401_C01_018E", 
         "15_17tot"= "S1401_C01_019E" ,
         "15_17school"= "S1401_C01_020E", 
         "18_19tot"= "S1401_C01_021E", 
         "18_19school"= "S1401_C01_022E",
         "20_24tot"= "S1401_C01_023E", 
         "20_24school"= "S1401_C01_024E")%>%
  mutate("per5_9" = .[[4]]/.[[3]], 
         "per10_14"= .[[6]]/.[[5]], 
         "per15_17"= .[[8]]/.[[7]], 
         "per18_19"= .[[10]]/.[[9]], 
         "per20_24"= .[[12]]/.[[11]], 
         "5_to_24_total_pop"= .[[3]] + .[[5]] + .[[7]] + .[[9]] + .[[11]])%>%
  mutate("County_GEOID"= substr(enrollment_ratio$GEOID, 1,5))

enrollment_ratio$tract_expect_edu_raw <- ((5*enrollment_ratio$per5_9)+ (5*enrollment_ratio$per10_14)+
                                      (3*enrollment_ratio$per15_17)+ (2* enrollment_ratio$per18_19)+ (5*enrollment_ratio$per20_24)) 

enrollment_ratio$tract_expect_edu_index= (enrollment_ratio$tract_expect_edu_raw)/18 




#Load school enrollment for counties 
county_school_enroll<- map_df(us, function(x) { get_acs(geography = "county",
                                                 year= 2015,
                                                 cache_table= TRUE,
                                                 output= "wide",
                                                 table = "S1401_C01", 
                                                 state = x, 
                                                 survey = "acs5") })

county_enrollment_ratio <- county_school_enroll %>% 
  select(1:2,31:50)

county_enrollment_ratio <-county_enrollment_ratio %>% 
  select("GEOID","NAME", ends_with("E")) %>%
  rename("County_GEOID" = "GEOID",
    "5_9tot"="S1401_C01_015E" ,
         "5_9school"= "S1401_C01_016E" ,
         "10_14tot"= "S1401_C01_017E",
         "10_14school"= "S1401_C01_018E", 
         "15_17tot"= "S1401_C01_019E" ,
         "15_17school"= "S1401_C01_020E", 
         "18_19tot"= "S1401_C01_021E", 
         "18_19school"= "S1401_C01_022E",
         "20_24tot"= "S1401_C01_023E", 
         "20_24school"= "S1401_C01_024E")%>%
  mutate("per5_9" = .[[4]]/.[[3]], 
         "per10_14"= .[[6]]/.[[5]], 
         "per15_17"= .[[8]]/.[[7]], 
         "per18_19"= .[[10]]/.[[9]], 
         "per20_24"= .[[12]]/.[[11]])

county_enrollment_ratio$county_expect_edu_raw <- ((5*county_enrollment_ratio$per5_9)+ (5*county_enrollment_ratio$per10_14)+
                                      (3*county_enrollment_ratio$per15_17)+ (2* county_enrollment_ratio$per18_19)+ (5*county_enrollment_ratio$per20_24)) 

county_enrollment_ratio$county_expect_edu_index= (county_enrollment_ratio$county_expect_edu_raw)/18 

small_county <- county_enrollment_ratio %>% 
  select("County_GEOID", "county_expect_edu_index")

#Join files for tracts to have county expect edu values included 

final_enrollment_ratio <- left_join(enrollment_ratio, small_county, 
                                                      by = "County_GEOID")

final_enrollment_ratio <-final_enrollment_ratio %>%
  mutate('final_expect_edu_index' = case_when( `5_to_24_total_pop` == 0 ~ NA_real_,
                                               `5_to_24_total_pop`!=0 & tract_expect_edu_index== "NaN" ~ county_expect_edu_index,
                                               TRUE ~ tract_expect_edu_index ))



#create
expect_edu_index <- final_enrollment_ratio %>% 
  select("GEOID", "NAME", "final_expect_edu_index")%>% 
  rename("expect_edu_index"= "final_expect_edu_index")


#Save 
write.csv(expect_edu_index, "expect_edu_index.csv")
