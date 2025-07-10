if(!require(devtools)) install.packages("devtools")
if(!require(SurveySolutionsAPI)) devtools::install_github("michael-cw/SurveySolutionsAPI", build_vignettes = T)
if(!require(susoapi)) devtools::install_github("arthur-shaw/susoapi")
if(!require(susoflows)) devtools::install_github("arthur-shaw/susoflows")
if(!require(RStata)) install.packages('RStata')
if(!require(tidyverse)) install.packages("tidyverse")
if(!require(stringr)) install.packages("stringr")
if(!require(openxlsx)) install.packages('openxlsx')
if(!require(fs)) install.packages('fs')
if(!require(parallel)) install.packages("parallel")
if(!require(doParallel)) install.packages("doParallel")

library(SurveySolutionsAPI)
library(susoapi)
library(susoflows)
library(tidyverse)
library(RStata)
library(haven)
library(dplyr)
library(readr)
library(stringr)

assignmentStartDate <- as.character(read_file("notepads/assignmentDate.txt"))
myStataVersion <- parse_integer(read_file("notepads/currentStataVersion.txt"))
currentDataVersion <- parse_integer(read_file("notepads/currentDataVersion.txt"))
currentStartDate <- as.character(read_file("notepads/currentStartDate.txt"))

#make dirs
data_download_dir <- "HQData/"
hqDownload_dir    <- paste(data_download_dir,'HQ_Download/',sep='')
hq_extracted_dir  <- paste(data_download_dir,'HQ_Extracted/',sep='')

errorReports_dir <- "Reports/errorFiles/errors_report"

#delete data download directory
ifelse(dir.exists(file.path(data_download_dir)),unlink(data_download_dir, recursive = TRUE),"data_download_dir Directory Exists")
ifelse(dir.exists(file.path(errorReports_dir)),unlink(errorReports_dir, recursive = TRUE),"errorReports_dir Directory Exists")
#call notification for folder recreation as TRUE
#create data download, hq download and extracted directories
source("main/Rscripts/hqScripts/noficationMessage.R",local = T)
ifelse(!dir.exists(file.path(data_download_dir)), dir.create(file.path(data_download_dir)), "Data Directory Exists")
ifelse(!dir.exists(file.path(hqDownload_dir)), dir.create(file.path(hqDownload_dir)), "Data Directory Exists")
ifelse(!dir.exists(file.path(hq_extracted_dir)), dir.create(file.path(hq_extracted_dir)), "Data Directory Exists")

#----------------------------------------------
#   SERVER AUTH
#----------------------------------------------
# server authentication:
# this is set on the server directly
#----------------------------------------------


#---------------------------------------------------------------------------------------
#   GET QUESTIONAIRES
#---------------------------------------------------------------------------------------
#get Suso Questionaires
source("main/Rscripts/Data Download/getQuestionList.R", local = T)
#----------------------------------------------------------------


#---------------------------------------------------------------------------
# CREATE TIME OF DOWNLOAD
#---------------------------------------------------------------------------

library(lubridate)
dataDownloadStarted <- format(now(), "%a %d %b %Y, %I:%M %p")
currentDateTime = Sys.time()

currentDate = as.Date(currentDateTime)
currentHourMinute = format(as.POSIXct(currentDateTime), format = "%H-%M%p")
#----------------------------------------------------------------------------


#---------------------------------------------------------
#   CREATE DATA EXPORT QUEUES
#---------------------------------------------------------
#STEP 1: create export queues first
for (i in 1:nrow(questlist)){
  icbtQues <- questlist [i,]
  # # start export process; get job ID
  if( started_job_id <-susoapi::start_export(
    qnr_id= icbtQues$QuestionnaireIdentity,
    export_type = "STATA",
    include_meta = TRUE,
    interview_status = "All" )
  ){
    questlist <-questlist %>% mutate(
      Queue_job_id = case_when(
        questlist$QuestionnaireIdentity == icbtQues$QuestionnaireIdentity ~ started_job_id,
        TRUE ~ Queue_job_id)
    )  }}

#----------------------------------------------
#   CREATE DATA DOWNLOAD FUNCTION
#----------------------------------------------
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

#----------------------------------------------
#   START THE CREATED DATA DOWNLOAD FUNCTION
#----------------------------------------------
#STEP 3: implement the download
Sys.sleep(120) # wait for 2 minute, to try again
for (i in 1:nrow(questlist)){  #------ NEW DOWNLOAD SCRIPT START #
  # icbtQues <- questlist [3,]
  icbtQues <- questlist [i,]
  # # CHECK EXPORT JOB PROGESS, UNTIL COMPLETE, specifying ID of job started in prior step
  exportFeedback <- get_export_job_details(job_id = started_job_id)
  
  if(exportFeedback$ExportStatus =='All' & exportFeedback$HasExportFile == TRUE ){
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
}  
#---------------    DOWNLOAD SCRIPT ENDs here    -------------------------


#-------------------------------------------------------------------------
#   UNZIP THE DOWNLOAD DATA
#-------------------------------------------------------------------------
#unzip each version of the files (although expect 1 file, as per version)
zipppedFiles <- list.files(path = hqDownload_dir, pattern = "*.zip", full.names = T)

for (zipfile in zipppedFiles) {
  #take each zip file and extract
  if (file.exists(zipfile)) {
    unzip( zipfile, exdir=hq_extracted_dir)
  }
}
#----------------------------------------------------------------


#-----------------------------------------------------------------
#  FIX SOME META IDENTIFIER COLUMNS IN THE  DATASET
#-----------------------------------------------------------------
ibesFileName <- "HQData/HQ_Extracted/ibes_ii.dta"
ibes_ii <- read_dta(ibesFileName)

#fix district code to 4 digit with starting zeros, as a string
ibes_ii$id11a <- replace(ibes_ii$id11a, is.na(ibes_ii$id11a), 0)
ibes_ii$id11a <- str_pad(ibes_ii$id11a, width = 7, side = "left", pad = "0")
# convert 4 digit district code back to numeric
ibes_ii$id11a <- as.numeric(substr(ibes_ii$id11a, 1, 4))

# save the corrected dataset
write_dta( ibes_ii,ibesFileName)
#-----------------------------------------------------------------------

# save filtered Dta
# write_dta(subDf,"HQData/HQ_Extracted/ibes_ii.dta")
# write_dta(subDf,"HQData/HQ_Extracted/ibes_iisubfdkk.dta")
rm(ibes_ii)
# take each of the extracted files and filter them to assigned zones

ifelse(dir.exists(file.path(hqDownload_dir)),unlink(hqDownload_dir, recursive = TRUE),"data_download_dir Directory Exists")

library(fs)
Files <- list.files(path = hq_extracted_dir, full.names = T)
file.copy(list.files(path = hq_extracted_dir, full.names = T), data_download_dir,  overwrite = TRUE)
ifelse(dir.exists(file.path(hq_extracted_dir)),unlink(hq_extracted_dir, recursive = TRUE),"data_download_dir Directory Exists")
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
## PULL SERVER ASSIGNMENT & CASE STATUS INFORMATION
#-----------------------------------------------------------------------
# suprevisors_all <- SurveySolutionsAPI::suso_getSV()  %>%
#     rename(
#       sup_IsLocked=IsLocked,
#       sup_CreationDate=CreationDate ,
#       sup_UserId = UserId,
#       sup_UserName =UserName,
#       # sup_Date = date,
#       sup_DeviceId = DeviceId
#     )

QuesDetails <- suso_getQuestDetails(
  workspace  =  Sys.getenv("new_wp") ,
  quid   = questlist$QuestionnaireId,
  version  = currentDataVersion,
  # operation.type = c( "statuses")
  operation.type = c( "interviews")
  # operation.type = c("list", "statuses", "structure", "interviews")
)

nrow(QuesDetails%>% distinct(ResponsibleName) )
table(QuesDetails$Status)

QuesDetailsUnnest <- QuesDetails %>%
  unnest(FeaturedQuestions)


QuesDetailsPivot <- QuesDetailsUnnest %>%
  pivot_wider(
    id_cols = c(
      InterviewId, QuestionnaireId, QuestionnaireVersion, AssignmentId,
      ResponsibleId, ResponsibleName, ErrorsCount,Status,LastEntryDate,
      ReceivedByDevice, ReceivedByDeviceAtUtc
    ),
    id_expand = FALSE,
    names_from = Question,
    values_from = Answer)

# set for stata dataset varnames format
columnNames <- colnames(QuesDetailsPivot)
for (i in seq_along(columnNames)) {
  if(grepl(" ", columnNames[i]) | (str_detect(columnNames[i], "PRE-LOAD")) |grepl("-", columnNames[i]) ) {
    vName <- gsub(".*?\\((.*?)\\).*", "\\1", columnNames[i])
    vName <- gsub("\\[PRE-LOAD]", "", vName)
    vName <- gsub("\\/", "", vName)
    vName <- gsub(" ", "", vName)
    vName <- gsub("'s", "", vName)
    vName <- gsub("-", "",vName)
    columnNames[i] = vName
  }
}
names(QuesDetailsPivot) <- columnNames

QuesDetailsPivot <- QuesDetailsPivot %>%
  mutate(
    System = str_pad(System,width = 14, pad = "0"),
    Districtcode = as.numeric(substr(System,1,4)),
    Regioncode = as.numeric(substr(System,1,2))
  )


# GEt each interviewer details for the assignment
# install.packages("foreach")
library(foreach)
# install.packages("parallel")
library(parallel)
clusterCores <- makeCluster(detectCores()-2) # leave 2 cores for the os
clusterCores
# install.packages("doParallel")
library(doParallel)
registerDoParallel(clusterCores)  # register workers

intvwrLoginID <- array(unique(QuesDetailsPivot$ResponsibleId))

getUserLoginDetails <- foreach (n = intvwrLoginID) %do%
  {
    SurveySolutionsAPI::suso_getINT_info(int_id = n, Sys.getenv("new_wp"))
  }

InterviewerDetails <- bind_rows(getUserLoginDetails) %>%
  select(SupervisorName,
         SupervisorId,
         UserId,
         UserName,
         PhoneNumber,
         FullName) %>%
  rename(
    ResponsibleId    = UserId,
    ResponsibleName   = UserName,
    interviewer_userName = FullName,
    interviewer_userContact = PhoneNumber,
    intervwr_supName = SupervisorName,
    intervwr_supResponsibleId = SupervisorId
  )

# Stop the cluster
stopCluster(clusterCores)

QuesDetailsPivot <- QuesDetailsPivot %>%
  left_join(InterviewerDetails , 
            by = join_by(ResponsibleName, ResponsibleId)
            ) %>%
  mutate(
    EnumeratorContact = ifelse( (is.na(EnumeratorContact) | nchar(str_squish(EnumeratorContact))<9) & !is.na(interviewer_userContact) & nchar(str_squish(interviewer_userContact))>=9,interviewer_userContact, EnumeratorContact),
    EnumeratorName = ifelse( (is.na(EnumeratorName) | nchar(str_squish(EnumeratorName))<5) & (!is.na(interviewer_userName) &  nchar(str_squish(interviewer_userName))>=5 ) ,interviewer_userName, EnumeratorName),
    
    EnumeratorName = str_to_title( str_squish(trimws(EnumeratorName))),
    interviewer_userName = str_to_title( str_squish(trimws(interviewer_userName))),
    
    interviewer_userContact = ifelse(interviewer_userContact==EnumeratorContact, NA_character_,interviewer_userContact),
    interviewer_userName = ifelse(interviewer_userName==EnumeratorName, NA_character_,interviewer_userName)
  ) %>%
  rename(
    Estab_Number = EstablishmentReferenceNumber,
    EstablishmentReferenceNumber = System
  ) %>%
  select(
    Region, Regioncode, District, Districtcode, EnumerationZoneNumber, 
    TeamNumber, SupervisorName, SupervisorContact, EnumeratorName, EnumeratorContact, ResponsibleName, SuburbArea,
    EstablishmentReferenceNumber, Estab_Number,
    NameofEstablishment,  Subsectorofbusiness, everything()
  )%>%
  arrange(Regioncode, Districtcode, EnumerationZoneNumber, TeamNumber, SupervisorName, EnumeratorName,SuburbArea, EstablishmentReferenceNumber ) %>%
  mutate(TeamNumber = as.character(paste0("TEAM ",str_pad(parse_number(TeamNumber), width=2, pad="0"))))

current_ServerAssignments <- QuesDetailsPivot %>%
  group_by(Region,
           Regioncode,
           Districtcode,
           TeamNumber,
           ResponsibleId,
           ResponsibleName) %>%
  summarise(
    District = first(District),
    EnumeratorName= first(EnumeratorName)  ,
    EnumeratorContact = first(EnumeratorContact) ,
    # assignmentCreated_count = n_distinct(AssignmentId),
    assignemntQtySumTotal = n_distinct(EstablishmentReferenceNumber),
    assignmentQty_receivedByTablet = sum(ifelse(!is.na(
      ReceivedByDeviceAtUtc
    ), 1, 0)) 
    # InterviewTransactions_Count = sum(InterviewsCount, na.rm = T),
  ) %>%
  relocate(District , .after = Districtcode) %>%
  relocate(ResponsibleName , .after = EnumeratorName) %>%
  relocate(-ResponsibleId) %>%
  arrange(Regioncode, Districtcode, TeamNumber, EnumeratorName)


#save assignment from server frame to stata file
library(haven)
frame_dir <- "main/frame/"
ifelse(!dir.exists(file.path(frame_dir)),  dir.create(file.path(frame_dir)), "frame_dir Directory Exists")
write_dta(current_ServerAssignments ,paste0(frame_dir, "interviewer assingment status.dta"))
write_dta(QuesDetailsPivot , paste0(frame_dir,"interviewer assingment journal.dta"))
#---------------------------------------------------------


#----------------------------------------------------------------------------------------------
#   Bench Test some of the long process script, and use the least time consuming function
#-----------------------------------------------------------------------------------------------
#### STOP HERE
# # install.packages("bench")
# library(bench)
# times <- bench::mark(
#   for (i in 1:nrow(ass_50) ) {
#     assignment_row <- assignments_all_0[i,]
#     detailsAssignmt <-  susoapi::get_assignment_details( workspace  =sqlSvr$workspace,   id = assignment_row$Id  )
#     AssignmentDetails_0 <- dplyr::bind_rows(AssignmentDetails_0, detailsAssignmt)
#     rm(detailsAssignmt)
#   },
#   foreachh_assignmentID(x = AssID ,wkspace =sqlSvr$workspace),
#   iterations =5
# )
#-----------------------------------------------------------------------------------------------
