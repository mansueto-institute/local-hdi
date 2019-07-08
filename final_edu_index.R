#######################################Building the Final Edu Index###############################

final_edu_index <- meanindex %>% 
  select(GEOID, meanyearsofschoolindex)

final_edu_index$expecteduindex <- expectedu$expecteduindex

final_edu_index$eduindex <- ((expectedu$expecteduindex)+(meanindex$meanyearsofschoolindex))/2