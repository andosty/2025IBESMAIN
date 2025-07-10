# setwd("C:/2025IBESMAIN/")
setwd("/home/administrator/.wine/drive_c/2025IBESMAIN/")

#--- Download HQ Data for all interview_status
source("main/Rscripts/Data Download/download HQ data.R", local = T , echo = T)

#--- Call the Prep, ErrorCheck and MonitorReport Scripts -------
source("main/Rscripts/Data Prep, ErrorCheck, MonitorReport Script/call Stata Do Files.R", local = T , echo = T)

