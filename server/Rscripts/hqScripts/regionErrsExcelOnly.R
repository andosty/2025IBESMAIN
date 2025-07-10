regionNames_distinct <-  select(ErrorDataset,regCode,Region )  %>% distinct(regCode,Region)

for (i in 1:nrow(regionNames_distinct)) {
  
  reg_row <- regionNames_distinct[i,]
  filename <-paste0(excelPackagedError_dir,reg_row$regCode," ", reg_row$Region,".xlsx")
  
  currentInterviewer <- ErrorDataset %>%
    filter( Region == reg_row$Region  )
  
  
  library(openxlsx)
  wb <- createWorkbook(filename) #create the workbook  afresh
  sectionNames <- currentInterviewer %>% select(section) %>% distinct() %>% arrange(section)
  for (i in 1:nrow(sectionNames)) {
    rowSection <- sectionNames[i,]
    data <- currentInterviewer %>% filter(section == rowSection$section)
    
    sheetName_word <- paste0(rowSection$section)
    addWorksheet(wb,sheetName_word)
    
    width_vec <- apply(data, 2, function(x) max(nchar(as.character(x)) + 2, na.rm = TRUE))
    width_vec_header <- nchar(colnames(data))  + 3
    max_vec_header <- pmax(width_vec, width_vec_header)
    
    setColWidths(wb, sheet = sheetName_word, cols = 1:ncol(data), widths = max_vec_header )
    freezePane(wb, sheetName_word,  firstRow = TRUE)
    # freezePane(wb, sheetName_word, firstActiveRow = 2, firstActiveCol = 0)
    
    writeData(wb, sheet = sheetName_word, data, withFilter=TRUE)
  }
  saveWorkbook(wb,filename,overwrite = TRUE)
  
  
  # incProgress(inc_val)
  
}

  
