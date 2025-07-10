# setwd("C:/2025IBESMAIN/")

if(!require(RStata)) install.packages('RStata')
if(!require(tidyverse)) install.packages("tidyverse")

library(tidyverse)

library(haven)

data_dir <- "Data/"
prep_dir <- paste0(data_dir,"prep/")
dateTime_Dups_dir <- paste0(prep_dir,"dateTime and Dups/")
sectionData_dir <-   paste0(prep_dir,"sectionData/")

temp_dir <- "temp/"
ifelse(dir.exists(file.path(temp_dir)),unlink(temp_dir, recursive = TRUE),"temp_dir Directory Exists")
ifelse(!dir.exists(file.path(temp_dir)), dir.create(file.path(temp_dir)), "temp_dir Directory Exists")

ifelse(dir.exists(file.path(data_dir)),unlink(data_dir, recursive = TRUE),"data_dir Directory Exists")
#create data download, hq download and extracted directories
ifelse(!dir.exists(file.path(data_dir)), dir.create(file.path(data_dir)), "data_dir Directory Exists")
ifelse(!dir.exists(file.path(prep_dir)), dir.create(file.path(prep_dir)), "prep_dir Directory Exists")
ifelse(!dir.exists(file.path(dateTime_Dups_dir)), dir.create(file.path(dateTime_Dups_dir)), "dateTime_Dups_dir Directory Exists")
ifelse(!dir.exists(file.path(sectionData_dir)), dir.create(file.path(sectionData_dir)), "sectionData_dir Directory Exists")


reports_dir <- "reports/"
ifelse(!dir.exists(file.path(reports_dir)), dir.create(file.path(reports_dir)), "reports_dir Directory Exists")

errorFiles_dir <- paste0(reports_dir, "errorFiles/")
ifelse(dir.exists(file.path(errorFiles_dir)),unlink(errorFiles_dir),"data_dir Directory Exists")
ifelse(!dir.exists(file.path(errorFiles_dir)), dir.create(file.path(errorFiles_dir)), "reports_dir Directory Exists")

individErrDir <- paste0(errorFiles_dir, "errors_report/")
ifelse(!dir.exists(file.path(reports_dir)), dir.create(file.path(reports_dir)), "reports_dir Directory Exists")
# ifelse(!dir.exists(file.path(errorDir)), dir.create(file.path(errorDir)), "errorDir Directory Exists")
ifelse(!dir.exists(file.path(individErrDir)), dir.create(file.path(individErrDir)), "individErrDir Directory Exists")

errorMerge <- paste0(errorFiles_dir ,"err_dta_Merge/")
errorDir <- errorMerge
ifelse(!dir.exists(file.path(errorMerge)), dir.create(file.path(errorMerge)), "errorMerge Directory Exists")

myStataVersion <- 17

# showNotification("Stata Prep & ErrorCheck Script Started", type = "message", duration = 5)

z<- paste0("\"C:\\Program Files\\Stata",myStataVersion,"\\StataMP-64\"")
options("RStata.StataPath" = z)
options("RStata.StataVersion" = myStataVersion)
stata("help regress")

mainStataDofile <- "server/doFiles/00. run stata do files.do"
#clear stata error folder contents


ifelse(dir.exists(file.path(individErrDir)),unlink(individErrDir, recursive = TRUE),"individErrDir Directory Exists")
#create data download, hq download and extracted directories
ifelse(!dir.exists(file.path(individErrDir)), dir.create(file.path(individErrDir)), "Data Directory Exists")

# # incProgress(0.2) 
# Run Stata command
# stata(mainStataDofile, echo = TRUE ,wait = FALSE)

if(!require(future)) install.packages("future")
library(future)
plan(multisession)
# setwd("C:/2025IBESMAIN/")

# Run tasks asynchronously
f1 <- future({
  print("stata code started")
  library(RStata)
  
  myStataVersion <- parse_integer(read_file("currentStataVersion.txt"))
  
  z<- paste0("\"C:\\Program Files\\Stata",myStataVersion,"\\StataMP-64\"")
  options("RStata.StataPath" = z)
  options("RStata.StataVersion" = myStataVersion)
  stata("help regress")
  
  # Run Stata command
  mainStataDofile <- "server/doFiles/00. run stata do files.do"
  stata(mainStataDofile)
  1
})


f2 <- future({
  Sys.sleep(3)
  print("Task 2 done")
  2
})

# This runs immediately

# Initialize progress file
progFile <- "temp/progress.txt"
ifelse(file.exists(progFile), unlink(progFile),"file not exist")

progress <- 0
while (progress < 100) {
  if(file.exists(progFile)) {
    # Read progress
    # parse_integer(read_file("currentStataVersion.txt"))
    new_progress <- parse_integer((read_file(progFile)))
    if (!is.na(new_progress) && new_progress > progress) {
      progress <- new_progress
      print(progress)
      # Update Shiny progress bar
      # incProgress(progress / 100, detail = paste("Progress:", round(progress, 1), "%"))
    }
  }
  Sys.sleep(0.1) # Poll every 0.1 seconds
}

# Collect results
results <- value(list(f1, f2))
print(results)


# read_file(paste0(progFile))


# while (progress < 100) { }
Sys.sleep(5)
file_loc <- paste0(errorDir,"ibes_ii mergedErrs.dta")
ibes_ii_mergedErrs <- read_dta(file_loc) %>%
  select(interview__key,interview__id,id00,Estab_number,EstablishmentName,Town,starts_with("enum"),
         # EnumContact,
         interview__status,qtype ,section,errorCheck, errorMessage ) %>% #s1qso2
  # rename(qtype = s1qso2) %>%
  mutate(qtype =ifelse(!is.na(qtype),as.character(haven::as_factor(qtype)),"N/A"))

filename <-paste0("reports/errorFiles/errorReport_bySections.xlsx", sep="")  

library(openxlsx)
wb <- createWorkbook(filename) #create the workbook if file does not exist

sectionNames <- ibes_ii_mergedErrs %>% select(section) %>% distinct() %>% arrange(section)

for (i in 1:nrow(sectionNames)) {
  rowSection <- sectionNames[i,]
  data <- ibes_ii_mergedErrs %>% filter(section == rowSection$section)
  
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
# # incProgress(0.99, detail = paste("Synced Interviews:", round(90), "%"))

saveWorkbook(wb,filename,overwrite = TRUE)
# showNotification("Stata Prep & ErrorCheck Script Completed", type = "message", duration = 5)

ifelse(dir.exists(file.path(temp_dir)),unlink(temp_dir, recursive = TRUE),"temp_dir Directory Exists")


# error interviewer excel



