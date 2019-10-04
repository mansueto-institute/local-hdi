#############Expected Education Index####################

#Load packages 

library(tidycensus)
library(tidyverse)
library(tigris)
library(tmap) 
library(purr)

#Generate variable that allows that later code to loop through all the states

us <- unique(fips_codes$state)[1:51]



#######Calculate Enrollment ratio for 5 to 9 year olds 

####Get data on number of student enrolled in  school

#Get data for male students in public schools ages 5 to 9, male students in private schools ages 5 to 9, 
#female students in public schools ages 5 to 9, and female students in private schools ages 5 to 9

malpub5to9<- map_df(us, function(x) { get_acs(geography = "county", 
                     variables = c( malpub5to9= "B14003_005"), 
                     state = x) })

malpri5to9 <- map_df(us, function(x) { get_acs(geography = "county", 
                      variables = c( malpri5to9= "B14003_014"), 
                      state = x) })


fempub5to9 <- map_df(us, function(x) { get_acs(geography = "county", 
                      variables = c( fempub5to9= "B14003_033"), 
                      state = x) })

fempri5to9 <- map_df(us, function(x) { get_acs(geography = "county", 
                      variables = c( fempri5to9= "B14003_042"), 
                      state = x) })

#Add total enrolled student Values together for 5 to 9 yr olds

Totalstu5to9 <- malpub5to9 %>%
  select(GEOID)

Totalstu5to9$totalenrolled5to9 <- (malpub5to9$estimate)+ (malpri5to9$estimate)+ 
  (fempub5to9$estimate)+ (fempri5to9$estimate)

#Calculate total population of 5 to 9 yr olds 

totmal5to9 <- map_df(us, function(x) { get_acs(geography = "county", 
                      variables = c( totmal5to9= "B01001_004"), 
                      state = x) })

totfem5to9 <- map_df(us, function(x) { get_acs(geography = "county", 
                      variables = c( totfem5to9= "B01001_028"), 
                      state = x) })

totpop5to9 <- totmal5to9 %>%
  select(GEOID)

totpop5to9$totalpop5to9 <- (totmal5to9$estimate)+ (totfem5to9$estimate)

#Merge the frames 

expectedu <- merge(Totalstu5to9, totpop5to9, by = "GEOID")

#Create Enrollment percentage 

expectedu$enroll5to9 <- (expectedu$totalenrolled5to9)/ (expectedu$totalpop5to9)


#######Calculate Enrollment ratio for 10 to 14 year olds 

##Get data on number of student enrolled in  school

#Get data for male students in public schools ages 10 to 14, male students in private schools ages 10 to 14, 
#female students in public schools ages 10 to 14, and female students in private schools ages 10 to 14

malpub10to14<- map_df(us, function(x) { get_acs(geography = "county", 
                       variables = c( malpub10to14= "B14003_006"), 
                       state = x) })

malpri10to14 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( malpri10to14= "B14003_015"), 
                        state = x) })


fempub10to14 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( fempub10to14= "B14003_034"), 
                        state = x) })

fempri10to14 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( fempri10to14= "B14003_043"), 
                        state = x) })

#Add total enrolled student Values together for 10 to 14 yr olds

Totalstu10to14 <- malpub10to14 %>%
  select(GEOID)

Totalstu10to14$totalenrolled10to14 <- (malpub10to14$estimate)+ (malpri10to14$estimate)+ 
  (fempub10to14$estimate)+ (fempri10to14$estimate)

#Calculate total population of 10 to 14 yr olds 

totmal10to14 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( totmal10to14= "B01001_005"), 
                        state = x) })

totfem10to14 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( totfem10to14= "B01001_029"), 
                        state = x) })

totpop10to14 <- totmal10to14 %>%
  select(GEOID)

totpop10to14$totalpop10to14 <- (totmal10to14$estimate)+ (totfem10to14$estimate)

#Merge the frames 

expectedu10to14 <- merge(Totalstu10to14, totpop10to14, by = "GEOID")

expectedu <- merge(expectedu, expectedu10to14, by = "GEOID")

#Create Enrollment percentage 

expectedu$enroll10to14 <- (expectedu$totalenrolled10to14)/ (expectedu$totalpop10to14)

#######Calculate Enrollment ratio for 15 to 17 year olds###########

##Get number of students enrolled in some form of school in age range

#Get data for male students in public schools ages 15 to 17, male students in private schools ages 15 to 17, 
#female students in public schools ages 15 to 17, and female students in private schools ages 15 to 17, 
#male students in public colleges ages 15 to 17, male students in private colleges ages 15 to 17,
#female students in public colleges ages 15 to 17, and female students in private colleges ages 15 to 17,

malpub15to17<- map_df(us, function(x) { get_acs(geography = "county", 
                       variables = c( malpub15to17= "B14003_007"), 
                       state = x) })

malpri15to17 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( malpri15to17= "B14003_016"), 
                        state = x) })


fempub15to17 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( fempub15to17= "B14003_035"), 
                        state = x) })

fempri15to17 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( fempri15to17= "B14003_044"), 
                        state = x) })

malpubcol15to17<- map_df(us, function(x) { get_acs(geography = "county", 
                          variables = c( malpubcol15to17= "B14004_004"), 
                          state = x) })

malpricol15to17<- map_df(us, function(x) { get_acs(geography = "county", 
                          variables = c( malpricol15to17= "B14004_009"), 
                          state = x) })

fempubcol15to17<- map_df(us, function(x) { get_acs(geography = "county", 
                          variables = c( fempubcol15to17= "B14004_020"), 
                          state = x) })

fempricol15to17<- map_df(us, function(x) { get_acs(geography = "county", 
                          variables = c( fempricol15to17= "B14004_025"), 
                          state = x) })



#Add total enrolled student Values together for 15 to 17 yr olds

Totalstu15to17 <- malpub15to17 %>%
  select(GEOID)

Totalstu15to17$totalenrolled15to17 <- (malpub15to17$estimate)+ (malpri15to17$estimate)+ 
  (fempub15to17$estimate)+ (fempri15to17$estimate)+ (malpubcol15to17$estimate)+ (malpricol15to17$estimate)+
  (fempubcol15to17$estimate)+ (fempricol15to17$estimate)

#Calculate total population of 15 to 17 yr olds 

totmal15to17 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( totmal15to17= "B01001_006"), 
                        state = x) })

totfem15to17 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( totfem15to17= "B01001_030"), 
                        state = x) })

totpop15to17 <- totmal15to17 %>%
  select(GEOID)

totpop15to17$totalpop15to17 <- (totmal15to17$estimate)+ (totfem15to17$estimate)

#Merge the frames 

expectedu15to17 <- merge(Totalstu15to17, totpop15to17, by = "GEOID")

expectedu <- merge(expectedu, expectedu15to17, by = "GEOID")

#Create Enrollment percentage 

expectedu$enroll15to17 <- (expectedu$totalenrolled15to17)/ (expectedu$totalpop15to17)


##############Enrollment data for 18-24 Year Olda#################

##Get number of students enrolled in high school

#Get data for male students in public schools ages 18 to 19, male students in private schools ages 18 to 19, 
#female students in public schools ages 18 to 19, and female students in private schools ages 18 to 19, 


malpub18to19<- map_df(us, function(x) { get_acs(geography = "county", 
                       variables = c( malpub18to19= "B14003_008"), 
                       state = x) })

malpri18to19 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( malpri18to19= "B14003_017"), 
                        state = x) })


fempub18to19 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( fempub18to19= "B14003_036"), 
                        state = x) })

fempri18to19 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( fempri18to19= "B14003_045"), 
                        state = x) })

##Get data on number of students enrolled in high school

#Get data for male students in public schools ages 20 to 24, male students in private schools ages 20 to 24, 
#female students in public schools ages 20 to 24, and female students in private schools ages 20 to 24, 


malpub20to24<- map_df(us, function(x) { get_acs(geography = "county", 
                       variables = c( malpub20to24= "B14003_009"), 
                       state = x) })

malpri20to24 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( malpri20to24= "B14003_018"), 
                        state = x) })


fempub20to24 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( fempub20to24= "B14003_037"), 
                        state = x) })

fempri20to24 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( fempri20to24= "B14003_046"), 
                        state = x) })

#male students in public colleges ages 18 to 24, male students in private colleges ages 18 to 24,
#female students in public colleges ages 18 to 24, and female students in private colleges ages 18 to 24,


malpubcol18to24<- map_df(us, function(x) { get_acs(geography = "county", 
                          variables = c( malpubcol18to24= "B14004_005"), 
                          state = x) })

malpricol18to24<- map_df(us, function(x) { get_acs(geography = "county", 
                          variables = c( malpricol18to24= "B14004_010"), 
                          state = x) })

fempubcol18to24<- map_df(us, function(x) { get_acs(geography = "county", 
                          variables = c( fempubcol18to24= "B14004_021"), 
                          state = x) })

fempricol18to24<- map_df(us, function(x) { get_acs(geography = "county", 
                          variables = c( fempricol18to24= "B14004_026"), 
                          state = x) })

#Add total enrolled student Values together for 18 to 24 yr olds

Totalstu18to24 <- malpub18to19 %>%
  select(GEOID)

Totalstu18to24$totalenrolled18to24 <- (malpub18to19$estimate)+ (malpri18to19$estimate)+ 
  (fempub18to19$estimate)+ (fempri18to19$estimate)+ (malpub20to24$estimate)+ (malpri20to24$estimate)+ 
  (fempub20to24$estimate)+ (fempri20to24$estimate)+
  (malpubcol18to24$estimate)+ (malpricol18to24$estimate)+
  (fempubcol18to24$estimate)+ (fempricol18to24$estimate)

#Calculate total population of 18 to 24 yr olds 

totmal18to19 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( totmal18to19= "B01001_007"), 
                        state = x) })

totmal20 <- map_df(us, function(x) { get_acs(geography = "county", 
                    variables = c( totmal20= "B01001_008"), 
                    state = x) })

totmal21 <- map_df(us, function(x) { get_acs(geography = "county", 
                    variables = c( totmal21= "B01001_009"), 
                    state = x) })

totmal22to24 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( totmal22to24= "B01001_010"), 
                        state = x) })

totfem18to19 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( totfem18to19= "B01001_031"), 
                        state = x) })

totfem20 <- map_df(us, function(x) { get_acs(geography = "county", 
                    variables = c( totfem20= "B01001_032"), 
                    state = x) })

totfem21<- map_df(us, function(x) { get_acs(geography = "county", 
                   variables = c( totfem21= "B01001_033"), 
                   state = x) })

totfem22to24 <- map_df(us, function(x) { get_acs(geography = "county", 
                        variables = c( totfem22to24= "B01001_034"), 
                        state = x) })

#Combine to get toal popluation of 18-24 year olds  
totpop18to24 <- totmal18to19 %>%
  select(GEOID)

totpop18to24$totalpop18to24 <- (totmal18to19$estimate)+ (totfem18to19$estimate)+ 
  (totmal20$estimate)+ (totfem20$estimate)+ 
  (totmal21$estimate)+ (totfem21$estimate)+ 
  (totmal22to24$estimate)+ (totfem22to24$estimate)

#Merge the frames 

expectedu18to24 <- merge(Totalstu18to24, totpop18to24, by = "GEOID")

expectedu <- merge(expectedu, expectedu18to24, by = "GEOID")

#Create Enrollment percentage 

expectedu$enroll18to24 <- (expectedu$totalenrolled18to24)/ (expectedu$totalpop18to24)

#Convert all of the "NAN"s generated by dividing 0/0 to "0" so that a composite measure can be calculated 

expectedu$enroll5to9[is.nan(expectedu$enroll5to9)] <- 0

expectedu$enroll10to14[is.nan(expectedu$enroll10to14)] <- 0

expectedu$enroll15to17[is.nan(expectedu$enroll15to17)] <- 0

expectedu$enroll18to24[is.nan(expectedu$enroll18to24)] <- 0

########Calculating expected education index####

#Multiply each enrollment percentage by the number of years in the age cohort, and then add them 
#together to get the avarage years of schooling  

expectedu$indivvalue <- (5* expectedu$enroll5to9)+ (5* expectedu$enroll10to14)+ (3* expectedu$enroll15to17)+
  (7* expectedu$enroll18to24)

#Divide by 18 (standard set by UN) to get the Expected Education Index

expectedu$expecteduindex <- (expectedu$indivvalue)/18 


###########Save File#########


write.csv(expectedu, "expectededu_all states.csv")


