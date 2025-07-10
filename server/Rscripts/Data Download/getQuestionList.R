questlist <- suso_getQuestDetails(workspace =Sys.getenv("new_wp") ) %>%  #currentWorkSpace
  filter( 
    Variable == "ibes_ii"
  ) %>%
  mutate(    Queue_job_id = NA_integer_  ) %>%
  filter(Version == currentDataVersion)