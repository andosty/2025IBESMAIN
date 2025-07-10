#---------------------------------------------------------------------------
#---  Create Clean/Fresh Output Folders for the Prep FIles Generation    ---
#---------------------------------------------------------------------------
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

#---------------------------------------------------------------------------
#---  Call the Stata Programme to Run the Stata Master Prep Do File      ---
#---------------------------------------------------------------------------
#Note: This Master Do File runs both the Preps and the Error Do files, generate Monitor Reports

z<- paste0("\"C:\\Program Files\\Stata",myStataVersion,"\\StataMP-64\"")
options("RStata.StataPath" = z)
options("RStata.StataVersion" = myStataVersion)
stata("help regress")

# Run Stata command
prepErrorCheckStataDofile <- "main/doFiles/00. run stata Master Do file.do"

ifelse(dir.exists(file.path(individErrDir)),unlink(individErrDir, recursive = TRUE),"individErrDir Directory Exists")
#create data download, hq download and extracted directories
ifelse(!dir.exists(file.path(individErrDir)), dir.create(file.path(individErrDir)), "Data Directory Exists")

#----- RUn the Stata Do FIle --------------
stata(prepErrorCheckStataDofile)

# wait 5 secs for stata prep and error files to be saved
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

saveWorkbook(wb,filename,overwrite = TRUE)
# showNotification("Stata Prep & ErrorCheck Script Completed", type = "message", duration = 5)

ifelse(dir.exists(file.path(temp_dir)),unlink(temp_dir, recursive = TRUE),"temp_dir Directory Exists")


#-------------------------------------------------------------------------------
#---  Create Clean/Fresh Output Folders for the Monitor Report Generation    ---
#-------------------------------------------------------------------------------

#clear stata error folder contents
reportsDir <- "reports/"
monitorReportDir <- paste0(reportsDir,"monitorReports/")
# districtMonitorReportDir <- paste0(monitorReportDir,"districts")

# ifelse(dir.exists(file.path(districtMonitorReportDir)),unlink(districtMonitorReportDir, recursive = TRUE),"individErrDir Directory Exists")
#create data download, hq download and extracted directories
ifelse(!dir.exists(file.path(reportsDir)), dir.create(file.path(reportsDir)), "Data Directory Exists")
ifelse(!dir.exists(file.path(monitorReportDir)), dir.create(file.path(monitorReportDir)), "Data Directory Exists")
# ifelse(!dir.exists(file.path(districtMonitorReportDir)), dir.create(file.path(districtMonitorReportDir)), "Data Directory Exists")

temp_dir <- "temp/"
ifelse(dir.exists(file.path(temp_dir)),unlink(temp_dir, recursive = TRUE),"temp_dir Directory Exists")
ifelse(!dir.exists(file.path(temp_dir)), dir.create(file.path(temp_dir)), "temp_dir Directory Exists")

monReportStataDofile <- "main/doFiles/03. run all monitorRepot Scripts.do"
stata(monReportStataDofile)

cat("process complete, please effect your backups")

#-----------------------------------------------------------------
#---  Make backup of monitor report and error excel files      ---
#-----------------------------------------------------------------

# bakup MonitorReport and Excel Error Files
errorReport_filename = paste0(errorFiles_dir,"errorReport_bySections.xlsx")
monitorReport_filename = paste0(monitorReportDir,"excel/IBES_monitor_report.xlsx")

other_folder <- "other/"  # Replace with your folder path
monitorReport_Backupfolder <- paste0(other_folder, "monitor_report_backups/")
errorReport_Backupfolder <-paste0(other_folder, "error_report_backups/")

# Backup MonitorReport Excel File
if (file.exists(monitorReport_filename)) {
  if (!dir.exists(monitorReport_Backupfolder)) {
    dir.create(monitorReport_Backupfolder, recursive = TRUE)
  }
  new_filename <- paste0(monitorReport_Backupfolder,"IBES_monitor_report ",dataDownloadtTime, ".xlsx")
  file.copy(monitorReport_filename, new_filename, overwrite = TRUE)
}


# Backup errorReport Excel File
if (file.exists(errorReport_filename)) {
  if (!dir.exists(errorReport_Backupfolder)) {
    dir.create(errorReport_Backupfolder, recursive = TRUE)
  }
  new_filename <- paste0(errorReport_Backupfolder,"errorReport_bySections ",dataDownloadtTime, ".xlsx")
  file.copy(errorReport_filename, new_filename, overwrite = TRUE)
}


