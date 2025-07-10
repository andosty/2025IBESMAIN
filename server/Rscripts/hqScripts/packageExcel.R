if(!require(openxlsx))  install.packages("openxlsx")
library(haven)

errorfile <-paste0("reports/errorFiles/err_dta_Merge/ibes_ii mergedErrs.dta")  
if(file.exists(errorfile)){
  
  ErrorDataset <- read_dta(errorfile) %>% 
    select(interview__key,id00, EstablishmentName ,Sub_Sector,
           regCode,Region, distCode, District, 
           Team,Supervisor,SupervisorContact,
           EnumeratorName,EnumContact,qtype,
           section, errorCheck, errorMessage
     ) %>%
    mutate(
      Region = haven::as_factor(Region),
      qtype = haven::as_factor(qtype)
           )

  
  if(nrow(ErrorDataset)>0){
    regionNames_distinct <-  select(ErrorDataset,regCode,Region )  %>% distinct(regCode,Region)
    
    totalpackagingCount = nrow(ErrorDataset%>%distinct(EnumeratorName,Team,regCode))
      #make reg folder
      report_dir <- "reports/"
      ifelse(!dir.exists(file.path(report_dir)), dir.create(file.path(report_dir)), "report_dir Directory Exists")
      packError_dir <-paste0(report_dir,"packaged_errors/")
      ifelse(dir.exists(file.path(packError_dir)),unlink(packError_dir, recursive = TRUE),"packError_dir Directory Exists")
      ifelse(!dir.exists(file.path(packError_dir)), dir.create(file.path(packError_dir)), "packError_dir Directory Exists")
      excelPackagedError_dir <-paste0(packError_dir,"Excel/")
      ifelse(!dir.exists(file.path(excelPackagedError_dir)), dir.create(file.path(excelPackagedError_dir)), "excelPackagedError_dir Directory Exists")
      
    # region level
      progress <- 0
    for (i in 1:nrow(regionNames_distinct)) {
     
      
      inc_val <- round((1 /totalpackagingCount),4)
      
      progress <- inc_val + inc_val
      currentPercent = round((progress /totalpackagingCount),4)
      
      i_row <- regionNames_distinct[i,]
      
      #region dataset, to subset the district
      regionDataSet <- select(ErrorDataset,regCode,Region )  %>% filter(regCode== i_row$regCode) %>% distinct(regCode,.keep_all = T)
      
      regionError_dir <-paste0(excelPackagedError_dir,str_pad(regionDataSet$regCode, width = 2,pad = "0"),"_",regionDataSet$Region,"/")
      ifelse(!dir.exists(file.path(regionError_dir)), dir.create(file.path(regionError_dir)), "regionError_dir Directory Exists")
      
      districtNames_distinct <-  select(ErrorDataset , 
                                        regCode,Region, distCode, District ) %>% 
                                filter(regCode== i_row$regCode) %>%
                                distinct(regCode,distCode, .keep_all = T)

      # district level data
      for (j in 1:nrow(districtNames_distinct)) {
        j_row <- districtNames_distinct[j,]
        
        districtError_dir <-paste0(regionError_dir,str_pad(j_row$distCode, width = 4,pad = "0")," ",gsub("[^a-zA-Z()\\]", "", j_row$District)  ,"/")
        ifelse(!dir.exists(file.path(districtError_dir)), dir.create(file.path(districtError_dir)), "districtError_dir Directory Exists")
        
        
      #team level
        teamDistrict_distinct <- select(ErrorDataset,
                                        regCode,Region, distCode, District,
                                        Team,Supervisor,SupervisorContact)  %>%
                                    filter(regCode== i_row$regCode &
                                           distCode ==j_row$distCode
                                           ) %>%
                                    distinct(regCode,distCode,Team, .keep_all = T)
      
        # intvwr level
        for (x in 1:nrow(teamDistrict_distinct)) {
          x_row <- teamDistrict_distinct[x,]
          
          
          
          teamError_dir <-paste0(districtError_dir,str_to_title(x_row$Team)," - ",str_to_title(gsub("[^[:alnum:][:space:]]","",x_row$Supervisor)) ,"/")
          ifelse(!dir.exists(file.path(teamError_dir)), dir.create(file.path(teamError_dir)), "teamError_dir Directory Exists")
          
          
          interviewers_inTeamDataset <- select(ErrorDataset,
                          regCode,Region, distCode, District,
                          Team,Supervisor,SupervisorContact,
                          EnumeratorName,EnumContact)  %>%
            filter(regCode== x_row$regCode &
                     distCode ==x_row$distCode &
                     Team == x_row$Team
            ) %>%
            distinct(regCode,distCode , Team, EnumeratorName, .keep_all = T)
          
          # interviewer error data for saving
          for (y in 1:nrow(interviewers_inTeamDataset)) {
            y_row <- interviewers_inTeamDataset[y,]
            
            enumName<-str_to_title(gsub("[^[:alnum:][:space:]]","",y_row$EnumeratorName))
            enumContact<-str_to_title(gsub("[^[:alnum:][:space:]]","",y_row$EnumContact))
            
            
            filename <-paste0(teamError_dir, enumName," - ", enumContact,".xlsx")

            currentInterviewer <- ErrorDataset %>%
              filter(
                regCode       == y_row$regCode &
                  distCode    == y_row$distCode &
                  Team        == y_row$Team &
                  EnumeratorName == y_row$EnumeratorName &
                EnumContact == y_row$EnumContact
              )
            
            
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
            
            
            incProgress(inc_val)
            
          }
        }
        
        showModal(
          modalDialog(
            title = "Message",
            "Excel Errors Packaged successfully.",
            div(paste("The Error Excel files have been packaged per interviewer, team and district"), style="font-size:14px; font-weight:bold"),
            easyClose = TRUE,
            footer = tagList( modalButton("Okay") )
          )
        )
      }
    }
      
  }else{
      showNotification("There are no Errors in your current ErrorCheck Output", type = "message", duration = 10)
  }

} else {
  showNotification("ErrorCheck Output file not found. Did You RUN the Action 2 Successfully", type = "warning", duration = 10)
}

