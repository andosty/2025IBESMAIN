setwd("C:/2025IBESMAIN/")

if(!require(devtools)) install.packages("devtools")
if(!require(SurveySolutionsAPI)) devtools::install_github("michael-cw/SurveySolutionsAPI", build_vignettes = T)
if(!require(susoapi)) devtools::install_github("arthur-shaw/susoapi")
if(!require(susoflows)) devtools::install_github("arthur-shaw/susoflows")
if(!require(tidyverse)) install.packages("tidyverse")

# library(SurveySolutionsAPI)
# library(susoapi)
# library(susoflows)
library(tidyverse)

library(susoapi )



#----------------------------------------------
#   SERVER AUTH
#----------------------------------------------
# server authentication:
sqlSvr <- readRDS("server/cred/ibesii_svr.rds")
set_credentials(
  server = sqlSvr$server,
  workspace =currentWorkSpace,
  user = sqlSvr$usr,
  password = sqlSvr$pswd
)
# set_credentials(
#   server = sqlSvr$server, workspace=currentWorkSpace,   # workspace = sqlSvr$workspace,
#   user =sqlSvr$usr, password = sqlSvr$pswd
# )
# suso_set_key(sqlSvr$server,sqlSvr$usr, sqlSvr$pswd)
#----------------------------------------------

rejectReportDir <- "reports/rejectionReports/"

ifelse(dir.exists(file.path(rejectReportDir)),unlink(rejectReportDir, recursive = TRUE),"individErrDir Directory Exists")
#create data download, hq download and extracted directories
ifelse(!dir.exists(file.path(rejectReportDir)), dir.create(file.path(rejectReportDir)), "Data Directory Exists")



##### Error Reject #####

library(haven)
ibes_ii_mergedErrors <- read_dta("Reports/errorFiles/err_dta_Merge/ibes_ii mergedErrs.dta") %>%
  group_by(interview__key,interview__id) %>%
  mutate( errorCount = n()) %>%
  distinct( Region,regCode, District, distCode, EZ, EA_num,id00,
            interview__id, interview__key, EstablishmentName, qtype, 
            Team, Supervisor, SupervisorContact, 
            EnumeratorName, EnumContact,
            section, errorCount
            ) %>%
  mutate( section = str_squish(trimws(str_replace(str_to_lower(section), "section" ,""))),
          errorSections = str_c(section, collapse = ", "),
          ) %>%
  distinct( Region,regCode, District, distCode, EZ, EA_num,id00,
            interview__id, interview__key, EstablishmentName, qtype, 
            Team, Supervisor, SupervisorContact, 
            EnumeratorName, EnumContact,errorSections,errorCount) %>%
  mutate(
          errorSections = str_c(paste("Total erros =",errorCount, ". These errors are in section(s)", errorSections))
  ) %>%  ungroup() 


# ibes_ii_mergedErrors <- ibes_ii_mergedErrors %>% slice(1:20)

if(nrow(ibes_ii_mergedErrors)>0) {
  progress <- 0
  failedRejects = data.frame() 
  successRejects = data.frame() 
  totalCases = nrow(ibes_ii_mergedErrors)
  
  for (i in 1:totalCases) {
    inc_val <- round((1 /totalCases),4)
    progress <- i
    currentPercent = round((progress /totalCases),4)
    
    row1 <- ibes_ii_mergedErrors[i,]
    row2 <- susoapi::get_interview_stats(row1$interview__id ,workspace=currentWorkSpace) %>%
      mutate(interview__id = str_remove_all(InterviewId,"-")) 
    
    rowPerson <-left_join(row1,row2)
    
    #Rejecting a case as hq
    if( susoapi::reject_interview_as_hq( interview_id= rowPerson$interview__id,
                                         comment = rowPerson$errorSections,
                                         responsible_id = rowPerson$ResponsibleId ,
                                         verbose = TRUE )==TRUE ){ 
      successRejects <- dplyr::bind_rows(successRejects,rowPerson)
    } else{   
      failedRejects <- dplyr::bind_rows(failedRejects,rowPerson)
      }
    incProgress(inc_val, detail = paste("Progress:", round(currentPercent*100, 1), "%"))
  }
}

#save rejections feedback
if(exists("failedRejects")){
  if(nrow(failedRejects)==0)
    failedRejects <- data.frame(Region = "no observations")
} else if (!exists("failedRejects")) {
  failedRejects <- data.frame(Region = "no observations")
}

if(exists("successRejects")){
  if(nrow(successRejects)==0)
    successRejects <- data.frame(Region = "no observations")
} else if(!exists("successRejects")) {
  successRejects <- data.frame(Region = "no observations")
}


# Create a list with your datasets (named list creates sheet names)
rejectReport_datasets_list <- list(
  "succesful_rejects" = successRejects,
  "failed_rejects" = failedRejects
)

# Write to Excel file
if(!require(writexl)) install.packages("writexl")
library(writexl)
filename <-paste0(rejectReportDir,"case_rejection_status_report.xlsx")  
write_xlsx(rejectReport_datasets_list,filename)



