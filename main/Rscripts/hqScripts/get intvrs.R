# setwd("/srv/shiny-server/ibes2025")
setwd("C:/2025IBESMAIN/")
library(jsonlite)
library(lubridate) 
library(tidyverse)
# library(SurveySolutionsAPI)

currentWorkSpace <- sqlSvr$workspace

#----------------------------------------------
#   SERVER AUTH
#----------------------------------------------
# # # server authentication:
# sqlSvr <- readRDS("server/cred/ibesii_svr.rds")
# suso_clear_keys()
# suso_set_key( sqlSvr$server, sqlSvr$usr, sqlSvr$pswd, currentWorkSpace)
# suso_keys()
# 
# # get Questionaires
questlist <- suso_getQuestDetails(workspace =currentWorkSpace) %>%
  filter(Variable=="ibes_ii") %>%
  filter(Version == currentDataVersion)


library(lubridate)
# getting a list of all supervisors on the server.
# list of supervisors
# suprevisors_all <- suso_getSV(workspace = sqlSvr$workspace)
# suprevisors_current <- suprevisors_all %>%
#   mutate(date = ymd(as.Date(CreationDate))) %>%
#   filter( date >= as.Date(assignmentStartDate) ) %>%
#   rename(
#     sup_IsLocked=IsLocked, 
#     sup_CreationDate=CreationDate ,
#     sup_UserId = UserId, 
#     sup_UserName =UserName, 
#     sup_Date = date,
#     sup_DeviceId = DeviceId
#   )



# receive all the interviewers in the team.
# list of interviewers
Sys.sleep(5)
# interviewers_all = data.frame()
# for (i in 1:nrow(suprevisors_all)) {
#   row <- suprevisors_all[i,]
#   intvr <- suso_getINT(workspace = sqlSvr$workspace, sv_id =row$UserId)
#   interviewers_all <- dplyr::bind_rows(interviewers_all,intvr)
#   rm(intvr)
# }

# interviewers_current <-  interviewers_all %>%
#   mutate(date = ymd(as.Date(CreationDate))) %>%
#   filter( date >= as.Date(assignmentStartDate) )


#

# list of assignments
# incProgress(0.7, detail = paste("pulling frame:", round(70), "%"))

# assignments_all <- suso_get_assignments(workspace =sqlSvr$workspace)
# assignments_current <- assignments_all %>%
#   mutate(date = ymd(as.Date(CreatedAtUtc))) %>%
#   filter(Quantity > -1 ) %>%
#   filter( date >= as.Date(assignmentStartDate) )

new_assignments <- susoapi::get_assignments(
  qnr_id =  "b7b1d49f-63ee-416e-a12f-e98ec914d58f", 
  qnr_version = currentDataVersion
)

# NewAsignmentDetails <- susoapi::get_assignment_details(id=23451)

NewAsignmentDetails = data.frame()
for (i in 1:nrow(new_assignments)) {
  # row <- new_assignments[1,]
  row <- new_assignments[i,]
  assign_id_details <- susoapi::get_assignment_details(id=row$Id) 
  NewAsignmentDetails <- dplyr::bind_rows(NewAsignmentDetails,assign_id_details)
  rm(assign_id_details)
}

NewAsignmentDetailsName = data.frame()
for (i in 1:nrow(NewAsignmentDetails %>% distinct(ResponsibleName))) {
  # row <- NewAsignmentDetails[1,]
  row <- NewAsignmentDetails[i,]
  # loginFullname <- susoapi::get_user_details(row$ResponsibleName) 
  loginFullname <- SurveySolutionsAPI::suso_getINT_info( workspace = sqlSvr$workspace , int_id = row$ResponsibleId )
  NewAsignmentDetailsName <- dplyr::bind_rows(NewAsignmentDetailsName,loginFullname)
  # rm(loginFullname)
}

CurrentAsignmentDetails <- left_join(NewAsignmentDetails ,
                                     NewAsignmentDetailsName %>% 
                                       rename(ResponsibleName=UserName) %>%
                                       select(ResponsibleName, FullName, CreationDate,PhoneNumber,SupName = SupervisorName,SupervisorId) %>%
                                        arrange(ResponsibleName, desc(CreationDate),FullName ) %>%
                                       distinct(),
                                     by = join_by(ResponsibleName)
                                     ) %>% 
                            mutate(Districtcode = substr((str_pad(id11a,width = 7,pad = "0")),1,4) ) %>% #mutate to 4digit district code
                            rename( 
                                    EnumeratorName = FullName, 
                                    EnumeratorContact = PhoneNumber ,
                                    Region = id10, 
                                    Regioncode = id10a, 
                                    District = id11,
                                    # Districtcode = id11a, 
                                    TeamNumber = id03, 
                                    SupervisorName = id01a, 
                                    SupervisorContact = id02a, 
                                    # supLoginId, 
                                    # SupervisorId ,
                                    # InterviewId ,
                                    AssignmentId = Id
                                    ) %>%
                            select( 
                              Region, Regioncode, District ,Districtcode, TeamNumber, 
                              SupervisorName, SupName, SupervisorContact, 
                              SupervisorId , #supLoginId
                              EnumeratorName, EnumeratorContact , everything()
                              ) %>%
                            arrange(Regioncode,Districtcode,SupervisorName,  EnumeratorName )

saveRDS(CurrentAsignmentDetails , "server/frame/interviewer/ assignementDetailsVer8.RDS")
write_dta(CurrentAsignmentDetails , "server/frame/interviewer assignementDetailsVer8.RDS.dta")

# assignments summary
asignments_current_summary <- CurrentAsignmentDetails %>%
  mutate(Districtcode = substr((str_pad(id11a,width = 7,pad = "0")),1,4)) %>% #mutate to 4digit district code
  arrange(id10, id10a ,   id11, id11a,    id03, ResponsibleName,FullName, PhoneNumber) %>%  #region, district, team, interviewer,
  rename(
    Region = id10, 
    Regioncode = id10a, 
    District = id11, 
    # Districtcode  = id11a,
    TeamNumber =id03 ,
  ) %>%
  group_by(Region,Regioncode,Districtcode,TeamNumber,  ResponsibleId,ResponsibleName) %>% #districtName
  summarise(
    District = first(District),
    interviewer_name  = first(FullName) ,
    interviewer_contact = first(PhoneNumber) ,
    assignmentCreated_count = n_distinct(Id),
    assignemntQtySumTotal = sum(Quantity),
    assignment_receivedByTablet = sum(ifelse(!is.na(ReceivedByTabletAtUtc),1,0 )) , #n_distinct(ReceivedByTabletAtUtc),
    InterviewTransactions_Count = sum(InterviewsCount, na.rm = T),
  ) %>%
  relocate(District , .after = Districtcode) %>%
  arrange(Regioncode, Districtcode, ResponsibleName)

# get dup loginIDs
# Check for duplicate rows across all columns
duplicatesAD <- duplicated(asignments_current_summary)

# To get the duplicate rows
duplicateAD_rows <- asignments_current_summary[duplicatesAD, ]


interviewers_current_details = data.frame()
for (i in 1:nrow(CurrentAsignmentDetails %>% distinct(AssignmentId, ResponsibleName,ResponsibleId, .keep_all = T))) {
  row <- interviewers_current[i,]
  
  interviewers_current_details <- dplyr::bind_rows(interviewers_current_details,
                                                   suso_getINT_info(
                                                     workspace = currentWorkSpace,
                                                     int_id = row$UserId
                                                   )
  )
}

# merge to interviewers detail
interviewers_current_frame <- left_join(
  interviewers_current_details %>%  rename(intervierCreationDate=CreationDate, ResponsibleName=UserName,   ResponsibleId=UserId , interviewer_name =FullName, interviewer_contact=PhoneNumber),
  asignments_current_summary,
  by = join_by(ResponsibleId, ResponsibleName)) %>%
  select(-c(IsRelinkAllowed,IsArchived,IsLocked,IsLockedBySupervisor, IsLockedByHeadquarters))  %>%
  select(
    Region, Regioncode, Districtcode, SupervisorName, TeamNumber,
    ResponsibleName, interviewer_name,interviewer_contact,Role,intervierCreationDate,
         assignmentCreated_count,assignemntQtySumTotal, assignment_receivedByTablet,InterviewTransactions_Count,
         ResponsibleId,
         SupervisorId
  )

#interviews assigned per region in current version
table0 <- asignments_current_summary %>% group_by(Regioncode, Region) %>%
  summarise(
            total_trainees_serverAssigned = n_distinct(ResponsibleName),
            some_assignment_receivedByTablet =  sum( ifelse(assignment_receivedByTablet-assignmentCreated_count!=0 & assignment_receivedByTablet !=0 ,1,0), na.rm = T),
            all_assignment_receivedByTablet =  sum( ifelse(assignment_receivedByTablet==assignmentCreated_count,1,0), na.rm = T),
            atleast_receivedCurrentAssignment = some_assignment_receivedByTablet+ all_assignment_receivedByTablet,
            # at_least_started_a_case = sum(ifelse(InterviewTransactions_Count>0 ,1 , 0) ,na.rm = T)
            ) %>%
  mutate(
    percent_Tablet_hasAssignment =scales::percent( round(atleast_receivedCurrentAssignment/total_trainees_serverAssigned ,2)),
    # percent_NO_fieldPractice = 100- percent_fieldPractice ,
         ) #%>%
  # filter(!is.na(Region)) 

library(haven)
interview_diagnostics <- read_dta("HQData/interview__diagnostics.dta") 

ibesInteviewSummary <- read_dta("HQData/ibes_ii.dta") %>%
  # made_first_attempt  # read GPs on first attempt  # got contact person
  select(interview__id, interview__key, 
         s00a_q09a, 
         s00a_q11b1__Timestamp, s00a_q11b2__Timestamp, s00a_q13__Timestamp,
         id21 ) %>%
  left_join(interview_diagnostics %>%   select(interview__id, interview__key, responsible ) ) %>%
  mutate(
    atleast_made_1stAttempt = ifelse(!is.na(s00a_q09a),1,0),
    atleast_readGPS =ifelse((!is.na(s00a_q11b1__Timestamp) & nchar(s00a_q11b1__Timestamp)>6) |
                             ( !is.na(s00a_q11b2__Timestamp) & nchar(s00a_q11b2__Timestamp)>6) |
                              (!is.na(s00a_q13__Timestamp) & nchar(s00a_q13__Timestamp)>6) ,1,0),
    atleast_gotContactPerson = ifelse(!is.na(id21) & nchar(id21)>5 ,1,0)
  ) %>%
  group_by(responsible) %>%
  summarise(
    atleast_made_1stAttempt = sum(atleast_made_1stAttempt, na.rm = T),
    atleast_readGPS = sum(atleast_readGPS, na.rm = T),
    atleast_gotContactPerson = sum(atleast_gotContactPerson, na.rm = T),
  )
  

library(haven)
interview_COmpletedCasesSummary <- interview_diagnostics %>%
  mutate( interview__status =  haven::as_factor(interview__status)) %>%
  group_by(   responsible   ) %>%
  summarise(
    completedCases = sum(ifelse(interview__status=="Completed",1,0))
  ) 

ibesInteviewSummaryK <- ibesInteviewSummary %>% 
  left_join(interview_COmpletedCasesSummary, by = join_by(responsible)) %>% rename(ResponsibleName = responsible) %>%
  left_join(asignments_current_summary) %>%
  # left_join(select(interviewers_current_frame,Region,Regioncode,Districtcode, SupervisorName , TeamNumber, responsible=ResponsibleName, interviewer_name, interviewer_contact )) %>%
  select(Region,Regioncode,Districtcode, interviewer_name , ResponsibleName,interviewer_contact,TeamNumber,
         assignmentCreated_count, assignemntQtySumTotal , assignment_receivedByTablet,
         atleast_made_1stAttempt, atleast_readGPS , atleast_gotContactPerson , completedCases, ResponsibleId
         # everything()
         ) %>% #SupervisorName , TeamNumber
  relocate( - ResponsibleId) %>%
  arrange(Regioncode,Districtcode,  TeamNumber,interviewer_name)  #SupervisorName


table1 <- ibesInteviewSummaryK %>% group_by(Region, Regioncode) %>%
  summarise(
    atleast_made_1stAttempt =  sum(ifelse(atleast_made_1stAttempt>0 ,1,0)),
    atleast_readGPS =  sum(ifelse(atleast_readGPS>0 ,1,0)),
    atleast_gotContactPerson =  sum(ifelse(atleast_gotContactPerson>0 ,1,0)),
    completedCases =  sum(ifelse(completedCases>0 ,1,0))
  ) 

tableALL <- left_join(table0, table1,
                      by = join_by(Regioncode, Region)
                      )%>%
            mutate(
              percentage_GotFirstAttempt = scales::percent( round(atleast_made_1stAttempt /total_trainees_serverAssigned ,2)),
              percentage_reachedContactPerson =scales::percent( round(atleast_gotContactPerson /total_trainees_serverAssigned ,2)),
              percentage_withCaseCompleted = scales::percent( round(completedCases /total_trainees_serverAssigned ,2))
            ) %>%
            rename(
              `total trainees given assignment on server (T)` = total_trainees_serverAssigned,
              `tablet received SOME assignment (S)` = some_assignment_receivedByTablet,
              `tablet received ALL assignment (A)` = all_assignment_receivedByTablet,
              `trainess that atleast synced to RECEIVE assignemt (R = S+A)` = atleast_receivedCurrentAssignment,
              `percent Trainees with Tablet that have received Assignment (R/T)`= percent_Tablet_hasAssignment ,
              `percent Trainees atleast reached FirstAttempt`= percentage_GotFirstAttempt ,
              `percent Trainees atlleat reached Name of Contact Person`= percentage_reachedContactPerson ,
              `Trainees with atleast a Completed-Case (CC)`= completedCases ,
              `percent Trainees that completed a case (CC/T)`= percentage_withCaseCompleted ,
              # `trainess that atleast opened a case as started` = at_least_started_a_case  
            ) %>% arrange(Regioncode)

# Create a named list of dataframes, where names will be sheet names
dataframes <- list(
  "regional summary" = tableALL,
  "enumerator summary" = ibesInteviewSummaryK %>% rename( LoginID = ResponsibleName)
)
library(writexl)
filename <- "Regional Training IBESS-II Report CAPI Version8 FieldPractice.xlsx"
write_xlsx(dataframes, filename)

# names(ibesInteviewSummaryK)

#### to tall
# SupervisorName, SupervisorId, Role,  UserName
# 
# xyz <- susoapi::get_assignment_details()
# xyz <- SurveySolutionsAPI::suso_getINT_info( workspace = sqlSvr$workspace , int_id  ="57b5b2c9-31d2-47ed-9a51-25fa9a2a38c6"   )

# xyz <- get_assignments(responsible = "57b5b2c9-31d2-47ed-9a51-25fa9a2a38c6")

# get job process 
# incProgress(0.7, detail = paste("pulling frame:", round(75), "%"))

svr_interviews_fetch = data.frame()
for (i in 1:nrow(questlist)) {
  row <- questlist[i,]
  svr_Qnr <- SurveySolutionsAPI::suso_getQuestDetails(
    workspace = sqlSvr$workspace,
    quid    =  row$QuestionnaireId,
    version   = row$Version,
    operation.type = "interviews"
  )
  svr_interviews_fetch<- dplyr::bind_rows(svr_interviews_fetch,svr_Qnr)
}


# work on same assignment to same person

InterviewerJournalData_fetch <- svr_interviews_fetch %>%
  # filter(as.Date(LastEntryDate) >= currentStartDate ) %>%
  unnest(FeaturedQuestions)

# Check for duplicate rows across all columns
duplicates <- duplicated(InterviewerJournalData_fetch)
# To get the duplicate rows
duplicate_rows <- InterviewerJournalData_fetch[duplicates, ]

# Remove duplicates, keeping the first occurrence
InterviewerJournalData_fetch <- InterviewerJournalData_fetch[!duplicated(InterviewerJournalData_fetch), ]
# nrow(InterviewerJournalData_fetch0)
nrow(InterviewerJournalData_fetch)

InterviewerJournalData_fetch <- InterviewerJournalData_fetch %>%
  pivot_wider(
    id_cols = c(
      InterviewId, QuestionnaireId, QuestionnaireVersion, AssignmentId,
      ResponsibleId, ResponsibleName, ErrorsCount,Status,LastEntryDate,
      ReceivedByDevice, ReceivedByDeviceAtUtc
    ),
    id_expand = FALSE,
    names_from = Question,
    values_from = Answer)


# Need to convert list columns to character with a Function
# convertListColumns_toChar <- function(data) {
#   for (col in names(data)) {
#     if (is.list(data[[col]])) {
#       data[[col]] <- sapply(data[[col]], function(x) paste(x, collapse = ","))
#     }
#   }
#   return(data)
# }
# 
# # Example usage
# InterviewerJournalData_fetch <- convertListColumns_toChar(InterviewerJournalData_fetch)

# incProgress(0.7, detail = paste("pulling frame:", round(85), "%"))

# set for stata dataset varnames format
columnNames <- colnames(InterviewerJournalData_fetch)
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
names(InterviewerJournalData_fetch) <- columnNames

InterviewerJournalData_fetch <- InterviewerJournalData_fetch %>%
  mutate(
    System = str_pad(System,width = 14, pad = "0"),
    Districtcode = as.numeric(substr(System,1,4)),
    Regioncode = as.numeric(substr(System,1,2))
         )



InterviewerJournalData_fetchRedo <- InterviewerJournalData_fetch %>%
  arrange(desc(QuestionnaireVersion),desc(LastEntryDate)) %>%
  distinct(ResponsibleName,ResponsibleId, .keep_all = T) %>%
  select(
    InterviewId, ResponsibleId, QuestionnaireVersion, AssignmentId, ResponsibleName,
    Region ,  Regioncode , District , Districtcode,
    SupervisorName ,  SupervisorContact , TeamNumber,
    EnumeratorName , EnumeratorContact 
  ) %>%
  mutate(
    EnumeratorName = ifelse( is.na(EnumeratorName) | nchar(str_squish(EnumeratorName))<1,ResponsibleName, EnumeratorName),
    EnumeratorName = str_to_title( str_squish(trimws(EnumeratorName)))
  )

interviewers_current_frame <- interviewers_current_frame %>%
  rename( supLoginId = SupervisorName ) %>%
  left_join(InterviewerJournalData_fetchRedo ,
            by = join_by(ResponsibleId, ResponsibleName)
  ) %>%
  arrange(desc(intervierCreationDate))%>%
  distinct(ResponsibleName,ResponsibleId, .keep_all = T) %>%
  select(
    Region , Regioncode , District , Districtcode , 
    TeamNumber, SupervisorName , SupervisorContact  , 
    supLoginId , SupervisorId , InterviewId , 
    interviewer_name ,EnumeratorName, interviewer_contact , EnumeratorContact, Role , 
    QuestionnaireVersion , 
    intervierCreationDate , 
    assignmentCreated_count , assignemntQtySumTotal , assignment_receivedByTablet , InterviewTransactions_Count , 
    ResponsibleId , ResponsibleName , AssignmentId
  ) %>% 
  arrange(Regioncode,Districtcode, TeamNumber, SupervisorName,EnumeratorName ) %>%
  filter(Role=="Interviewer") %>%
  mutate(EnumeratorName= ifelse(nchar(str_squish(EnumeratorName))<3 ,interviewer_name, EnumeratorName),
         EnumeratorContact= ifelse(nchar(str_squish(EnumeratorContact))<3 ,interviewer_contact, EnumeratorContact),
         EnumeratorName = str_to_title(str_squish(trimws(EnumeratorName))),
         interviewer_name = str_to_title(str_squish(trimws(interviewer_name)))
  ) %>%
  select(-c(interviewer_name,interviewer_contact)) %>%
  rename( interviewerCreationDate= intervierCreationDate) %>%
  filter( !is.na(Region))

# # Summarize specific columns, grouped by a variable, showing frequencies
# regionalEnums <- interviewers_current_frame %>%
#   group_by(Region,Regioncode ) %>%
#   summarise(
#     interviewers_trainees = n_distinct(ResponsibleId)
#   )
# 
# library(gtsummary)
# table <- interviewers_current_frame %>%
#   tbl_summary(
#     include = c("ResponsibleId"), # Replace with your column names
#     by = "Region",           # Replace with your grouping column, if any
#     type = all_categorical() ~ "categorical", # Ensure categorical treatment
#     missing = "ifany"                 # Show missing values if present
#   ) %>%
#   add_n() %>%                        # Add sample size
#   bold_labels()
# 
# table

# incProgress(0.7, detail = paste("pulling frame:", round(90), "%"))

new_intvwrAssignment_frame = data.frame()
new_assignmentJournal_fetch = data.frame()
for (i in 1:nrow(currentUser()) ) {
  row <- currentUser()[i,]
  
  if(str_to_lower(row$AccessLevel)=="district"){
    new_intvwrAssignment_frame <- dplyr::bind_rows(new_intvwrAssignment_frame,
                               interviewers_current_frame %>%
                                filter( as.numeric(Regioncode) >= row$startRegionCode &  row$endRegionCode <= as.numeric(Regioncode)  ) %>%
                                filter( row$startDistrictCode >= as.numeric(Districtcode)  &  row$endDistrictCode <= as.numeric(Districtcode)  )
                                
    )
    
    new_assignmentJournal_fetch <- dplyr::bind_rows(new_assignmentJournal_fetch,
                                InterviewerJournalData_fetch %>%
                                  filter( as.numeric(Regioncode) >= row$startRegionCode &  row$endRegionCode <= as.numeric(Regioncode)  ) %>%
                                  filter( row$startDistrictCode >= as.numeric(Districtcode)  &  row$endDistrictCode <= as.numeric(Districtcode)  )
                                
    )
    
  } else if(str_to_lower(row$AccessLevel) =="regional"){
    new_intvwrAssignment_frame <- dplyr::bind_rows(new_intvwrAssignment_frame,
                                         interviewers_current_frame %>%
                                           filter( as.numeric(Regioncode) >= row$startRegionCode &  row$endRegionCode <= as.numeric(Regioncode)  )
    )
    
    new_assignmentJournal_fetch <- dplyr::bind_rows(new_assignmentJournal_fetch,
                                                    InterviewerJournalData_fetch %>%
                                                      filter( as.numeric(Regioncode) >= row$startRegionCode &  row$endRegionCode <= as.numeric(Regioncode)  ) 
    )
    
  } else if (str_to_lower(row$AccessLevel) == "national"){
    new_intvwrAssignment_frame <- interviewers_current_frame
    new_assignmentJournal_fetch <- InterviewerJournalData_fetch
    
    # leave the file as it is
  }
}

interviewers_current_frame = new_intvwrAssignment_frame %>% filter(!is.na(Region) & nchar(Region)>3)
InterviewerJournalData_fetch = new_assignmentJournal_fetch %>% filter(!is.na(Region) & nchar(Region)>3)

incProgress(0.7, detail = paste("pulling frame:", round(100), "%"))

#save
library(haven)
write_dta(interviewers_current_frame %>% mutate(TeamNumber = as.character(paste0("TEAM ",str_pad(parse_number(TeamNumber), width=2, pad="0")))), "server/frame/interviewer assingment frame.dta")
write_dta(InterviewerJournalData_fetch%>% mutate(TeamNumber = as.character(paste0("TEAM ",str_pad(parse_number(TeamNumber), width=2, pad="0")))), "server/frame/interviewer assingment journal.dta")


