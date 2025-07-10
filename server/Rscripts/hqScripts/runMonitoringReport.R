setwd("C:/2025IBESMAIN/")

if(!require(RStata)) install.packages('RStata')
library(RStata)
if(!require(openxlsx)) install.packages('openxlsx')


# showNotification("Stata Prep & ErrorCheck Script Started", type = "message", duration = 5)

z<- paste0("\"C:\\Program Files\\Stata",myStataVersion,"\\StataMP-64\"")
options("RStata.StataPath" = z)
options("RStata.StataVersion" = myStataVersion)
stata("help regress")

monReportStataDofile <- "server/doFiles/03. run all monitorRepot Scripts.do"
#clear stata error folder contents
reportsDir <- "reports/"
monitorReportDir <- paste0(reportsDir,"monitorReports/")
districtMonitorReportDir <- paste0(monitorReportDir,"districts")

ifelse(dir.exists(file.path(districtMonitorReportDir)),unlink(districtMonitorReportDir, recursive = TRUE),"individErrDir Directory Exists")
#create data download, hq download and extracted directories
ifelse(!dir.exists(file.path(reportsDir)), dir.create(file.path(reportsDir)), "Data Directory Exists")
ifelse(!dir.exists(file.path(monitorReportDir)), dir.create(file.path(monitorReportDir)), "Data Directory Exists")
ifelse(!dir.exists(file.path(districtMonitorReportDir)), dir.create(file.path(districtMonitorReportDir)), "Data Directory Exists")

temp_dir <- "temp/"
ifelse(dir.exists(file.path(temp_dir)),unlink(temp_dir, recursive = TRUE),"temp_dir Directory Exists")
ifelse(!dir.exists(file.path(temp_dir)), dir.create(file.path(temp_dir)), "temp_dir Directory Exists")


if(!require(future)) install.packages("future")
library(future)
plan(multisession)
setwd("C:/2025IBESMAIN/")
library(tidyverse)

# Run tasks asynchronously
f1 <- future({
  print("stata code started")
  library(RStata)
  
  myStataVersion <- parse_integer(read_file("currentStataVersion.txt"))
  
  z<- paste0("\"C:\\Program Files\\Stata",myStataVersion,"\\StataMP-64\"")
  options("RStata.StataPath" = z)
  options("RStata.StataVersion" = myStataVersion)
  stata("help regress")
  
  monReportStataDofile <- "server/doFiles/03. run all monitorRepot Scripts.do"
  #clear stata error folder contents

  # incProgress(0.2) 
  # Run Stata command
  stata(monReportStataDofile)
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
      incProgress(progress / 100, detail = paste("Progress:", round(progress, 1), "%"))
    }
  }
  Sys.sleep(0.1) # Poll every 0.1 seconds
}

# Collect results
results <- value(list(f1))
print(results)

# incProgress(0.2) 
stata(monReportStataDofile)
ifelse(dir.exists(file.path(temp_dir)),unlink(temp_dir, recursive = TRUE),"temp_dir Directory Exists")

# showNotification("Monitor Report generation complete", type = "message", duration = 5)
