# library(susoflows)

setwd("C:/2025IBESMAIN/")

if(!require(devtools)) install.packages("devtools")
if(!require(susoapi)) devtools::install_github("arthur-shaw/susoapi")
if(!require(tidyverse)) install.packages("tidyverse")

library(tidyverse)
library(susoapi )


intvwrSyncReportDir <- "reports/interviewer_sync_report/"

ifelse(dir.exists(file.path(intvwrSyncReportDir)),unlink(intvwrSyncReportDir, recursive = TRUE),"syncReport Directory Exists")
#create syncReport directory
ifelse(!dir.exists(file.path(intvwrSyncReportDir)), dir.create(file.path(intvwrSyncReportDir)), "syncReport Directory Exists")


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

library(haven) 
frame <- read_dta("server/frame/interviewer assingment frame.dta") %>%
  select(Region, Regioncode, District, Districtcode, TeamNumber,
         SupervisorName, SupervisorContact, InterviewId ,EnumeratorName, EnumeratorContact,
         ResponsibleId ,ResponsibleName) %>% distinct(ResponsibleName,EnumeratorName,TeamNumber, .keep_all = T )


# frame <- frame %>% slice(1:10)
InterviewerSyncLog = data.frame()
progress <- 0
for (i in 1:nrow(frame)) {
  totalInterviewerCount = nrow(frame)
  
  inc_val <- round((1 /totalInterviewerCount),4)
  
  
  progress <- i
  currentPercent = round((progress /totalInterviewerCount),4)
  
  # row <- frame[2,]
  row <- frame[i,]
  logData<- get_user_action_log(
      user_id=row$ResponsibleId,
      start = as.character(today()-30),
      end = as.character(today())) %>%
    filter(str_detect( str_to_lower(Message),"sync")) %>%
    arrange(desc(Time)) %>%
    rename(ResponsibleId = UserId)
  logUsr <- left_join(row, logData)
  
  InterviewerSyncLog <- dplyr::bind_rows(InterviewerSyncLog, logUsr) 
  incProgress(inc_val, detail = paste("Progress:", round(currentPercent*100, 1), "%"))
}


if(!require(lubridate)) install.packages("lubridate")
library(lubridate)
InterviewerSyncLog <- InterviewerSyncLog %>%
  select(-c(ResponsibleId,InterviewId)) %>%
  mutate( Time = format(ymd_hms(Time,tz=Sys.timezone()), "%Y-%m-%d %I:%M:%S %p"),
  ) %>%
  arrange(Regioncode, Districtcode ,TeamNumber, SupervisorName,EnumeratorName, desc(Time) )

# Write to Excel file
if(!require(writexl)) install.packages("writexl")
library(writexl)
filename <-paste0(intvwrSyncReportDir,"intvwr_sync_log_report.xlsx")  
write_xlsx(InterviewerSyncLog,filename)


