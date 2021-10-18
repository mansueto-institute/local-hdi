hdi_dataset <- income_index

hdi_dataset2 <- left_join(hdi_dataset, final_edu_index, by = "GEOID")

hdi_dataset3 <- left_join(hdi_dataset2, le_index, by = "GEOID")

final_hdi <- hdi_dataset3 %>%
  select('GEOID','NAME.x', 4:11, '2015_Tract_population',  
         'unadjusted_income_index','adjusted_income_index', "expect_edu_index", "mean_edu_index", "final_edu_index", "le_index") %>% 
  rename('tract_name' = 'NAME.x') %>%
  mutate(unadjusted_hdi= ((unadjusted_income_index)*(le_index)* (final_edu_index))^(1/3)) %>%
  mutate(adjusted_hdi= ((adjusted_income_index)*(le_index)* (final_edu_index))^(1/3))

final_hdi$stategeoid <- substr(final_hdi$GEOID, 1,2)

write.csv(final_hdi, "final_hdi.csv")
