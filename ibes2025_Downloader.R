setwd("C:/2025IBESMAIN/")

#--- Download HQ Data for all interview_status
source("main/Rscripts/Data Download/download HQ data.R", local = T , echo = T)
# 
# #--- Generate Error Report on only Cases with Status of Completed, Approved, 
# #Discard Incomplete Cases as well as Rejected Cases
# source("", local = T , echo = T)
# 
# #--- Generate Monitor Report on only Cases with Status of Completed, Approved
# #Discard Incomplete Cases as well as Rejected Cases
# source("", local = T , echo = T)
# 
# source("main/Rscripts/hqScripts/getOS_Script.R", local = T , echo = F)
# cat(currentOs)