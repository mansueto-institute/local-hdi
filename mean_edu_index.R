###################################Mean Edu Index##########################
#Load packages 

library(tidycensus)
library(tidyverse)
library(tigris)
library(tmap) 
library(purr)

#Create variable with all the US States' FIPS codes
us <- unique(fips_codes$state)[1:51]


##############Total Population###########
#Use the map_df function to bind all of the frames generated by all of the states 
#The function(x) part serves to create a loop for all of the states 

#Extracts total population that is 25 years and older in a census tract
totalpop <- map_df(us, function(x) {
  get_acs(geography = "tract", variables =  "B15003_001", 
                    state = x) }) 


#Make simplified file with just estimated population 
totalpop2 <- totalpop %>%
  select(GEOID, NAME, estimate) %>% 
  rename('totalpop'= "estimate")

#######################Doctoral Degree (I8)###########

docpop <- map_df(us, function(x) {
  get_acs(geography = "tract", 
                  variables = "B15003_025", 
                  state = x) })


docpop2 <- docpop %>%
  select(GEOID, estimate) %>% 
  rename('docpop_I8'= "estimate")

docpop2$percentdoc_I8 = (docpop2$docpop_I8 )/(totalpop2$totalpop)

#Creates mean index file which has total population in each tract 25 years or older and the number of people in that ISCED classification

meanindex <- merge(totalpop2, docpop2, by = "GEOID")

################### (I7)##############################

#Professional Degree Pop

professionalpop <- map_df(us, function(x) { 
  get_acs(geography = "tract", 
                           variables = "B15003_024", 
                           state = x) })

professionalpop2 <- professionalpop %>%
  select(GEOID, estimate) %>% 
  rename('professionalpop_I7'= "estimate")


#Master's Pop (I7)


masterspop <-map_df(us, function(x) { get_acs(geography = "tract", 
                      variables = "B15003_023", 
                      state = x) })

masterspop2 <- masterspop %>%
  select(GEOID, estimate) %>% 
  rename('masterspop_I7'= "estimate")

#Combine masters and professional

masterspop2$combined_I7 = (masterspop2$masterspop_I7)+ (professionalpop2$professionalpop_I7)

masterspop2$percentI7 = (masterspop2$combined_I7)/(totalpop2$totalpop)

combinedd_I7= masterspop2 %>% 
  select(GEOID, combined_I7, percentI7)

meanindex <- merge(meanindex, combinedd_I7, by = "GEOID")

########I6############ 

#Bachelor's Degree 

bachelorspop <-map_df(us, function(x) { get_acs(geography = "tract", 
                        variables = "B15003_022", 
                        state = x) })

bachelorspop2 <- bachelorspop %>%
  select(GEOID, estimate) %>% 
  rename('bachelorspop_I6'= "estimate")

bachelorspop2$percentbachelors_I6 = (bachelorspop2$bachelorspop_I6 )/(totalpop2$totalpop)

meanindex <- merge(meanindex, bachelorspop2, by = "GEOID")
#############I5#################### 

#Associate's Degree 

associatespop <-map_df(us, function(x) { get_acs(geography = "tract", 
                         variables = "B15003_021", 
                         state = x) })

associatespop2 <- associatespop %>%
  select(GEOID, estimate) %>% 
  rename('associatespop_I5'= "estimate")

associatespop2$percentassociates_I5 = (associatespop2$associatespop_I5 )/(totalpop2$totalpop)

meanindex <- merge(meanindex, associatespop2, by = "GEOID")

################I4/I3######################### 

#People who started college and didn't finish

partialcolpop <-map_df(us, function(x) { get_acs(geography = "tract", 
                         variables =  "B15003_020", 
                         state = x) })

partialcolpop2 <- partialcolpop %>%
  select(GEOID, estimate) %>% 
  rename('partialcolpop_I4'= "estimate")

partialcolpop2$percentpartialcolpop_I4 = (partialcolpop2$partialcolpop_I4 )/(totalpop2$totalpop)

#People with less than 1 year of college 

somcolpop <-map_df(us, function(x) { get_acs(geography = "tract", 
                     variables = "B15003_019", 
                     state = x) })

somcolpop2 <- somcolpop %>%
  select(GEOID, estimate) %>% 
  rename('somcolpop_I4'= "estimate")

somcolpop2$percentsomcol_I4 = (somcolpop2$somcolpop_I4 )/(totalpop2$totalpop)

#GED 

gedpop <-map_df(us, function(x) { get_acs(geography = "tract", 
                  variables = "B15003_018", 
                  state = x) })

gedpop2 <- gedpop %>%
  select(GEOID, estimate) %>% 
  rename('gedpop_I4'= "estimate")

gedpop2$percentged_I4 = (gedpop2$gedpop_I4 )/(totalpop2$totalpop)

#high School diploma

diplomapop <-map_df(us, function(x) { get_acs(geography = "tract", 
                      variables =  "B15003_017", 
                      state = x) })

diplomapop2 <- diplomapop %>%
  select(GEOID, estimate) %>% 
  rename('diplomapop_I4'= "estimate")

diplomapop2$percentdiploma_I4 = (diplomapop2$diplomapop_I4 )/(totalpop2$totalpop)

#Combine 1 year of college, less than 1 year college, GED, and High School Diploma

diplomapop2$combined_I4 = (diplomapop2$diplomapop_I4)+ (gedpop2$gedpop_I4)+ (somcolpop2$somcolpop_I4)+ (partialcolpop2$partialcolpop_I4)

diplomapop2$percentI4 = (diplomapop2$combined_I4)/(totalpop2$totalpop)

combinedd_I4= diplomapop2 %>% 
  select(GEOID, combined_I4, percentI4)

meanindex <- merge(meanindex, combinedd_I4, by = "GEOID")

############I2############ 

#Grade 12 no diploma 

grade12pop <-map_df(us, function(x) { get_acs(geography = "tract", 
                      variables = "B15003_016", 
                      state = x) })

grade12pop2 <- grade12pop %>%
  select(GEOID, estimate) %>% 
  rename('grade12pop_I2'= "estimate")

#Grade 11 

grade11pop <-map_df(us, function(x) { get_acs(geography = "tract", 
                      variables = "B15003_015", 
                      state = x) })

grade11pop2 <- grade11pop %>%
  select(GEOID, estimate) %>% 
  rename('grade11pop_I2'= "estimate")

#Grade 10 

grade10pop <-map_df(us, function(x) { get_acs(geography = "tract", 
                      variables = "B15003_014", 
                      state = x) })

grade10pop2 <- grade10pop %>%
  select(GEOID, estimate) %>% 
  rename('grade10pop_I2'= "estimate") 

#Grade 9 

grade9pop <-map_df(us, function(x) { get_acs(geography = "tract", 
                     variables =  "B15003_013", 
                     state = x) })

grade9pop2 <- grade9pop %>%
  select(GEOID, estimate) %>% 
  rename('grade9pop_I2'= "estimate")

#Combine grade 12 no diploma, grade 11, grade 10, and grade 9 

grade9pop2$combined_I2 = (grade9pop2$grade9pop_I2 )+ (grade10pop2$grade10pop_I2)+ (grade11pop2$grade11pop_I2)+ (grade12pop2$grade12pop_I2)

grade9pop2$percentI2 = (grade9pop2$combined_I2)/(totalpop2$totalpop)

combinedd_I2= grade9pop2 %>% 
  select(GEOID, combined_I2, percentI2)

meanindex <- merge(meanindex, combinedd_I2, by = "GEOID")


###############I1############################### 

#Grade 8 

grade8pop <-map_df(us, function(x) { get_acs(geography = "tract", 
                     variables = "B15003_012", 
                     state = x) })

grade8pop2 <- grade8pop %>%
  select(GEOID, estimate) %>% 
  rename('grade8pop_I1'= "estimate")

#Grade 7 

grade7pop <-map_df(us, function(x) { get_acs(geography = "tract", 
                     variables = "B15003_011", 
                     state = x) })

grade7pop2 <- grade7pop %>%
  select(GEOID, estimate) %>% 
  rename('grade7pop_I1'= "estimate") 

#Grade 6 

grade6pop <-map_df(us, function(x) { get_acs(geography = "tract", 
                     variables = "B15003_010", 
                     state = x) })

grade6pop2 <- grade6pop %>%
  select(GEOID, estimate) %>% 
  rename('grade6pop_I1'= "estimate") 


#Combine Grades 8, 7, and 6 

grade6pop2$combined_I1 = (grade6pop2$grade6pop_I1 )+ (grade7pop2$grade7pop_I1)+ (grade8pop2$grade8pop_I1)

grade6pop2$percentI1 = (grade6pop2$combined_I1)/(totalpop2$totalpop)

combinedd_I1= grade6pop2 %>% 
  select(GEOID, combined_I1, percentI1)

meanindex <- merge(meanindex, combinedd_I1, by = "GEOID")


#####################I03##########

#Grade 5

grade5pop <-map_df(us, function(x) { get_acs(geography = "tract", 
                     variables = "B15003_009", 
                     state = x) })

grade5pop2 <- grade5pop %>%
  select(GEOID, estimate) %>% 
  rename('grade5pop_I03'= "estimate")

#Grade 4 

grade4pop <-map_df(us, function(x) { get_acs(geography = "tract", 
                     variables = "B15003_008", 
                     state = x) })

grade4pop2 <- grade4pop %>%
  select(GEOID, estimate) %>% 
  rename('grade4pop_I03'= "estimate")

#Grade 3 

grade3pop <-map_df(us, function(x) { get_acs(geography = "tract", 
                     variables = "B15003_007", 
                     state = x) })

grade3pop2 <- grade3pop %>%
  select(GEOID, estimate) %>% 
  rename('grade3pop_I03'= "estimate")

#Grade 2 

grade2pop <-map_df(us, function(x) { get_acs(geography = "tract", 
                     variables = "B15003_006", 
                     state = x) })

grade2pop2 <- grade2pop %>%
  select(GEOID, estimate) %>% 
  rename('grade2pop_I03'= "estimate")

#Grade 1 


grade1pop <-map_df(us, function(x) { get_acs(geography = "tract", 
                     variables = "B15003_005", 
                     state = x) })

grade1pop2 <- grade1pop %>%
  select(GEOID, estimate) %>% 
  rename('grade1pop_I03'= "estimate")

#Kindergarten 


kindergartenpop <-map_df(us, function(x) { get_acs(geography = "tract", 
                           variables = "B15003_004", 
                           state = x) })

kindergartenpop2 <- kindergartenpop %>%
  select(GEOID, estimate) %>% 
  rename('kindergartenpop_I03'= "estimate")

#Nursey School 

NSpop <-map_df(us, function(x) { get_acs(geography = "tract", 
                 variables = "B15003_003", 
                 state = x) })

NSpop2 <- NSpop %>%
  select(GEOID, estimate) %>% 
  rename('NSpop_I03'= "estimate")

#Combine Grade 5, 4, 3, 2, 1, Kindergarten, and Nursery School (NS) 

NSpop2$combined_I03 = (grade5pop2$grade5pop_I03 )+ (grade4pop2$grade4pop_I03)+ (grade3pop2$grade3pop_I03)+ (grade2pop2$grade2pop_I03)+ (grade1pop2$grade1pop_I03)+ 
  (kindergartenpop2$kindergartenpop_I03)+ (NSpop2$NSpop_I03)

NSpop2$percentI03 = (NSpop2$combined_I03)/(totalpop2$totalpop)

combinedd_I03= NSpop2 %>% 
  select(GEOID, combined_I03, percentI03)

meanindex <- merge(meanindex, combinedd_I03, by = "GEOID")


############I01/I02######################### 

#Population with no formal education

noedupop <-map_df(us, function(x) { get_acs(geography = "tract", 
                    variables =  "B15003_002", 
                    state = x) })

noedupop2 <- noedupop %>%
  select(GEOID, estimate) %>% 
  rename('noedupop_I01'= "estimate")

noedupop2$percentI01 = (noedupop2$noedupop_I01)/(totalpop2$totalpop)

meanindex <- merge(meanindex, noedupop2, by = "GEOID")

############Building the Mean Edu Index############ 

#Multiply percentages in each of  International Standard Classification of Education (ISCED) levels (used 
#by the UNDP) by the number of years the UNDP allocates to each level to get an average number of years of education
#in the adult population

meanindex$topofindex <- (meanindex$percentdoc_I8 *21) + (meanindex$percentI7 * 18) +
  (meanindex$percentbachelors_I6 * 16) + (meanindex$percentassociates_I5 *14) + (meanindex$percentI4 * 12)+ 
  (meanindex$percentI2 * 9)+ (meanindex$percentI1 *6)+ (meanindex$percentI03 *3)+ 
  (meanindex$percentI01*0)

#Divide that by 15 (goalpost set by UN) to create Mean Education Index

meanindex$meanyearsofschoolindex <- (meanindex$topofindex)/15


#####Save File#####

setwd()
write.csv(meanindex, "allstatesmeanindex.csv")