# setwd("C:/2025IBESMAIN/")

currentDataVersion <- parse_integer(read_file("currentDataVersion.txt"))
if(!require(devtools)) install.packages("devtools")
if(!require(SurveySolutionsAPI)) devtools::install_github("michael-cw/SurveySolutionsAPI", build_vignettes = T)
if(!require(susoapi)) devtools::install_github("arthur-shaw/susoapi")
if(!require(susoflows)) devtools::install_github("arthur-shaw/susoflows")
if(!require(RStata)) install.packages('RStata')
if(!require(tidyverse)) install.packages("tidyverse")
if(!require(openxlsx)) install.packages('openxlsx')
if(!require(fs)) install.packages('fs')


#load packages
# library(RCurl)
# library(dplyr)
library(lubridate)
# library(stringi)
# library(stringr)
# library(tidyr)
# library(tidytext)
library(tidyverse)
# library(haven)
library(readxl)
# library(gdata)
# library(jsonlite)

library(readr)


########
library(SurveySolutionsAPI)
library(susoapi)
library(susoflows)
# 
# #load packages
# library(RCurl)
# library(dplyr)
# library(lubridate)
# library(stringi)
# library(stringr)
# library(susoapi)
# library(susoflows)
# library(tidyr)
# library(tidytext)
# library(tidyverse)
# library(haven)
# library(readxl)
# library(gdata)
# library(jsonlite)
# library(tm)
# #########


data_download_dir <- "HQData/"
hqDownload_dir    <- paste(data_download_dir,'HQ_Download/',sep='')
hq_extracted_dir  <- paste(data_download_dir,'HQ_Extracted/',sep='')

errorReports_dir <- "Reports/errorFiles/errors_report"

#delete data download directory
ifelse(dir.exists(file.path(data_download_dir)),unlink(data_download_dir, recursive = TRUE),"data_download_dir Directory Exists")
ifelse(dir.exists(file.path(errorReports_dir)),unlink(errorReports_dir, recursive = TRUE),"errorReports_dir Directory Exists")
#create data download, hq download and extracted directories
ifelse(!dir.exists(file.path(data_download_dir)), dir.create(file.path(data_download_dir)), "Data Directory Exists")
ifelse(!dir.exists(file.path(hqDownload_dir)), dir.create(file.path(hqDownload_dir)), "Data Directory Exists")
ifelse(!dir.exists(file.path(hq_extracted_dir)), dir.create(file.path(hq_extracted_dir)), "Data Directory Exists")

notificationMessages()
showNotification("Conncection to HQ Server started", type = "message", duration = 3)

questlist <- susoapi::get_questionnaires()

questlist <- suso_getQuestDetails(workspace = Sys.getenv("new_wp") ) %>%  #currentWorkSpace
    filter( 
      Variable == "ibes_ii"
      ) %>%
    mutate(    Queue_job_id = NA_integer_  ) %>%
    filter(Version == currentDataVersion)

incProgress(0.1)
#STEP 1: create export queues first
for (i in 1:nrow(questlist)){
  # icbtQues <- questlist [1,]
  icbtQues <- questlist [i,]
  # # start export process; get job ID
  if( started_job_id <-susoapi::start_export(
    qnr_id= icbtQues$QuestionnaireIdentity,
    export_type = "STATA",
    include_meta = TRUE,
    interview_status = "All"
    )
  ){
    questlist <-questlist %>% mutate(
      Queue_job_id = case_when(
        questlist$QuestionnaireIdentity == icbtQues$QuestionnaireIdentity ~ started_job_id,
        TRUE ~ Queue_job_id)
    )  }}

# start_export(
#   qnr_id = "b7b1d49f63ee416ea12fe98ec914d58f$7",
#   export_type = "STATA",
#   interview_status = "All",
#   include_meta = TRUE
# ) -> started_job_id
# 
# 
# susoapi::start_export(
#   qnr_id = icbtQues$QuestionnaireId , 
#   export_type = "STATA",
#   interview_status = "All",
#   include_meta = TRUE
# )
# 
# 
# ls <- susoapi::get_questionnaires(  server =Sys.getenv("new_sv"),
#                                     workspace =  Sys.getenv("new_wp"),
#                                     user = Sys.getenv("old_u"),
#                                     password = Sys.getenv("old_d")
#                                     )
# 
# 
# 
# questlist <- suso_getQuestDetails(workspace = sqlSvr$workspace) 
# 
# started_job_id <-SurveySolutionsAPI::start_export(questID =  icbtQues$QuestionnaireIdentity,  version = 1, workStatus = "Completed")
# started_job_id <-susoflows::download_data(questID =  icbtQues$QuestionnaireIdentity,  version = 1, workStatus = "Completed")

#STEP 2: create download function
dataDownload_function <- function(que_id){
  tryCatch({ get_export_file(job_id = que_id, path = hqDownload_dir,  ) },
           #if an error occurs, tell me the error
           error=function(e) {
             message('A Download Error Occurred')
             print(e)  },
           #if a warning occurs, tell me the warning
           warning=function(w) {
             message('Warning, Download Error Occurred')
             print(w)
             # return(NA)
           }
  )
}

showNotification("Data Download Queue Started", type = "message", duration = 5)

incProgress(0.2, detail = paste("Synced Interviews:", round(20), "%"))

#STEP 3: implement the download
Sys.sleep(120) # wait for 2 minute, to try again
for (i in 1:nrow(questlist)){  #------ NEW DOWNLOAD SCRIPT START #
  # icbtQues <- questlist [3,]
  icbtQues <- questlist [i,]
  # # CHECK EXPORT JOB PROGESS, UNTIL COMPLETE, specifying ID of job started in prior step
  exportFeedback <- get_export_job_details(job_id = started_job_id)

  if(exportFeedback$ExportStatus =='Completed' & exportFeedback$HasExportFile == TRUE ){
    que_id = icbtQues$Queue_job_id
    dataDownload_function(que_id)
    rm(que_id, exportFeedback)
  } else{
    #wait for 1 minute and try again
    Sys.sleep(120) # wait for 2 minute, to try again
    exportFeedback <- get_export_job_details(job_id = started_job_id)
    que_id = icbtQues$Queue_job_id
    dataDownload_function(que_id)
    rm(que_id, exportFeedback)
  }
}  #---------- DOWNLOAD SCRIPT ENDs here


incProgress(0.2, detail = paste("Synced Interviews:", round(35), "%"))

#unzip each version of the files (although expect 1 file, as per version)
zipppedFiles <- list.files(path = hqDownload_dir, pattern = "*.zip", full.names = T)

for (zipfile in zipppedFiles) {
  #take each zip file and extract
  if (file.exists(zipfile)) {
    unzip( zipfile, exdir=hq_extracted_dir)
  }
}

showNotification("Data Download Complete", type = "message", duration = 5)
incProgress(0.2, detail = paste("Synced Interviews:", round(40), "%"))

library(haven)
ibes_ii <- read_dta("HQData/HQ_Extracted/ibes_ii.dta") %>%
  mutate(
    regCode = parse_integer(id10a) ,
    regdist = parse_integer(id11a) ,
    id03 = as.character(paste0("TEAM ",str_pad(parse_number(id03), width=2, pad="0"))),
  )

subDf <- data.frame()

# write_dta(currentUser(),"thiUser.dt")

for (i in 1:nrow(currentUser()) ) {
  row <- currentUser()[i,]

  if(str_to_lower(row$AccessLevel)=="district"){
    subDf <- dplyr::bind_rows(subDf,
                   ibes_ii %>%
                    filter( regCode >= row$startRegionCode &  row$endRegionCode <= regCode ) %>%
                    filter( row$startDistrictCode >= regdist &  row$endDistrictCode <= regdist ) %>%
                    select(-c(regCode,regdist))
                 )

  } else if(str_to_lower(currentUser()$AccessLevel) =="regional"){
    subDf <- dplyr::bind_rows(subDf,
                               ibes_ii %>%
                                filter( regCode >= row$startRegionCode & row$endRegionCode <= regCode ) %>%
                                select(-c(regCode,regdist))
    )
  } else if (str_to_lower(currentUser()$AccessLevel) == "national"){
    # leave the file as it is
  }
}
incProgress(0.01)
incProgress(0.2, detail = paste("Synced Interviews:", round(50), "%"))

# save filtered Dta
write_dta(subDf,"HQData/HQ_Extracted/ibes_ii.dta")
# write_dta(subDf,"HQData/HQ_Extracted/ibes_iisubfdkk.dta")
rm(ibes_ii)
# take each of the extracted files and filter them to assigned zones

subDf <- subDf %>% select(interview__key, interview__id) %>% distinct()
stataFiles <- list.files(path = hq_extracted_dir, pattern = "*.dta", full.names = T)
# stataFiles <- stataFiles[-1]

#filter each dataset, if user is not national, then filter to assigned dataset
for (statafile in stataFiles) {
  DF_data <- data.frame()

  if( !str_detect("HQData/HQ_Extracted/assignment__actions.dta", statafile )){
    for (i in 1:nrow(currentUser()) ) {
          if ( !(str_to_lower(currentUser()$AccessLevel) == "national")){
            x<- read_dta(statafile)
            x <- x %>% filter(interview__key %in% subDf$interview__key & interview__id %in% subDf$interview__id )
            DF_data <- dplyr::bind_rows(DF_data,x)
            rm(x)
          }
      }
  }
  write_dta(DF_data,statafile)
  rm(DF_data)
}

ifelse(dir.exists(file.path(hqDownload_dir)),unlink(hqDownload_dir, recursive = TRUE),"data_download_dir Directory Exists")

library(fs)
Files <- list.files(path = hq_extracted_dir, full.names = T)
file.copy(list.files(path = hq_extracted_dir, full.names = T), data_download_dir,  overwrite = TRUE)
ifelse(dir.exists(file.path(hq_extracted_dir)),unlink(hq_extracted_dir, recursive = TRUE),"data_download_dir Directory Exists")
incProgress(0.1)

showNotification("Getting Server frame data", type = "message", duration = 5)
incProgress(0.1, detail = paste("pulling frame:", round(65), "%"))
source("server/Rscripts/hqScripts/get intvrs.R", local = T, echo = T)
incProgress(0.1, detail = paste("pulling frame:", round(100), "%"))


