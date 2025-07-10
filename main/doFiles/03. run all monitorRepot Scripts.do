cd "C:\2025IBESMAIN"
gl rootDir "C:\2025IBESMAIN"
gl prepData "$rootDir\Data\prep\dateTime and Dups"
gl sectionData "$rootDir\Data\prep\sectionData"

gl do_file_loc "$rootDir\server\doFiles"
gl tempsaveDir "$rootDir\temp"

gl report_dir "$rootDir\Reports"
gl monitor_report_dir "$report_dir\monitorReports"
gl dist_monitor_report_dir "$monitor_report_dir\districts"

gl prepData "C:\2025IBESMAIN\Data\prep\dateTime and Dups"
gl sectionData "C:\2025IBESMAIN\Data\prep\sectionData"

//create monitor report dir if it does not exist
capture mkdir $report_dir
capture mkdir $monitor_report_dir

// Calculate progress percentage
local progress = 5
// Write progress to a file
file open progfile using "$tempsaveDir\progress.txt", write text replace
file write progfile "`progress'"
file close progfile

***************************************************
***************************************************
*FRAME 
use "$rootDir\server\frame\interviewer assingment frame.dta" , clear
destring Regioncode Districtcode, replace
// encode region codes
gen region=.
replace region=1 if Region=="WESTERN"
replace region=2 if Region=="CENTRAL"
replace region=3 if Region=="GREATER ACCRA" 
replace region=4 if Region=="VOLTA" 
replace region=5 if Region=="EASTERN" 
replace region=6 if Region=="ASHANTI" 
replace region=7 if Region=="WESTERN NORTH" 
replace region=8 if Region=="AHAFO" 
replace region=9 if Region=="BONO" 
replace region=10 if Region=="BONO EAST" 
replace region=11 if Region=="OTI"  
replace region=12 if Region=="NORTHERN" 
replace region=13 if Region=="SAVANNAH" 
replace region=14 if Region=="NORTH EAST" 
replace region=15 if Region=="UPPER EAST" 
replace region=16 if Region=="UPPER WEST"
tab region,m
lab def region 1"Western" 2 "Central" 3"Greater Accra" 4"Volta" 5"Eastern" 6"Ashanti"  7"Western North" 8"Ahafo" 9"Bono" 10"Bono East" 11"Oti"  12"Northern" 13"Savannah" 14"North East" 15 "Upper East" 16"Upper West"
lab val region region
tab region,m 
drop Region Role supLoginId SupervisorId ResponsibleName AssignmentId InterviewTransactions_Count Regioncode Districtcode QuestionnaireVersion interviewerCreationDate
*
renvars region TeamNumber EnumeratorContact EnumeratorName SupervisorName SupervisorContact assignmentCreated_count assignment_receivedByTablet assignemntQtySumTotal InterviewId / Region Team InterPhone InterName SuperName SuperPhone AssignCount AssignReceived TotalEst interview__id
*
gen AssignNotReceived = AssignCount - AssignReceived
*
sort Team
order Region Team
save "$tempsaveDir\IBESframe.dta",replace

// local progress = `progress' + `increment'
local progress = 25
file open progfile using "$tempsaveDir\progress.txt", write text replace
file write progfile "`progress'"
file close progfile

************************************
* Establishment Assignment stats
************************************
// Get establishment from frame status
use "$rootDir\server\frame\interviewer assingment journal.dta", clear
destring Regioncode Districtcode, replace
// encode region codes
gen region=.
replace region=1 if Region=="WESTERN"
replace region=2 if Region=="CENTRAL"
replace region=3 if Region=="GREATER ACCRA" 
replace region=4 if Region=="VOLTA" 
replace region=5 if Region=="EASTERN" 
replace region=6 if Region=="ASHANTI" 
replace region=7 if Region=="WESTERN NORTH" 
replace region=8 if Region=="AHAFO" 
replace region=9 if Region=="BONO" 
replace region=10 if Region=="BONO EAST" 
replace region=11 if Region=="OTI"  
replace region=12 if Region=="NORTHERN" 
replace region=13 if Region=="SAVANNAH" 
replace region=14 if Region=="NORTH EAST" 
replace region=15 if Region=="UPPER EAST" 
replace region=16 if Region=="UPPER WEST"
tab region,m
lab def region 1"Western" 2 "Central" 3"Greater Accra" 4"Volta" 5"Eastern" 6"Ashanti"  7"Western North" 8"Ahafo" 9"Bono" 10"Bono East" 11"Oti"  12"Northern" 13"Savannah" 14"North East" 15 "Upper East" 16"Upper West"
lab val region region
tab region,m 
drop Region 
*
renvars region Regioncode Districtcode TeamNumber EnumerationZoneNumber/ Region regionCode districtCode Team EZ

gen ques_Status=.
replace ques_Status=0 if Status=="Deleted"
replace ques_Status=1 if Status=="InterviewerAssigned"
replace ques_Status=2 if Status=="Completed"
// replace ques_Status=3 if Status=="RejectedBySupervisor" 
// replace ques_Status=4 if Status=="ApprovedBySupervisor" 
replace ques_Status=5 if Status=="RejectedByHeadquarters"  
replace ques_Status=6 if Status=="ApprovedByHeadquarters" 
	
replace ques_Status=1 if !(inrange(ques_Status,2,6) | inlist(ques_Status,0,1 )) //Restored, Created, Restarted, SentToCapi

lab def ques_Status 0 "Deleted" 1"InterviewerAssigned" 2 "Completed" /*3"RejectedBySupervisor" 4"ApprovedBySupervisor"*/ 5"RejectedByHeadquarters" 6"ApprovedByHeadquarters" 
lab val ques_Status ques_Status
//  ren Status ques_Status
 
// encode business_sector_listing codes
gen business_sector_listing=.
replace business_sector_listing=1 if Subsectorofbusiness=="AGRICULTURE"
replace business_sector_listing=2 if Subsectorofbusiness=="MINING AND QUARRYING"
replace business_sector_listing=3 if Subsectorofbusiness=="MANUFACTURING" 
replace business_sector_listing=4 if Subsectorofbusiness=="ELECTRICITY AND WATER" 
replace business_sector_listing=5 if Subsectorofbusiness=="CONSTRUCTION" 
replace business_sector_listing=6 if Subsectorofbusiness=="SERVICES 1" 
replace business_sector_listing=7 if Subsectorofbusiness=="SERVICES 2" 
replace business_sector_listing=8 if Subsectorofbusiness=="WHOLESALE AND RETAIL TRADE"
* 
lab val business_sector_listing s1qso2
* 
drop Subsectorofbusiness ResponsibleName AssignmentId QuestionnaireId ErrorsCount Status
order Region regionCode District districtCode Team SupervisorName SupervisorContact EnumeratorName EnumeratorContact System NameofEstablishment business_sector_listing
*
renvars System business_sector_listing / id00 bus_sec_listing
*
sort Region districtCode Team SupervisorName EnumeratorName
// tab ques_Status ReceivedByDevice  * further analysis


***************************
*    Interviewer stats
***************************
// restore has already been called
gen interviews = 0 
gen interviews_approved = 0 
replace interviews = 1 if ques_Status > 1
replace interviews_approved = 1 if ques_Status == 6 
gen interview__id = subinstr(InterviewId, "-", "", .)
	
generate id = _n
collapse (count) estabs_expected = id (sum) estabs_submitted =  interviews  /// 
estabs_HQ_Approved = interviews_approved (first) Team SupervisorName    ///
SupervisorContact EnumeratorName EnumeratorContact, ///
by(Region regionCode District districtCode EZ bus_sec_listing ResponsibleId	 interview__id)  //   InterviewId 
*
order Region - districtCode EZ Team SupervisorName SupervisorContact EnumeratorName EnumeratorContact bus_sec_listing
sort  Region - districtCode  EZ Team SupervisorName EnumeratorName bus_sec_listing  
*	 
save "$tempsaveDir\intvwrExpectedRosterStats" , replace 
	
// get estabs that failed prep
* get invalid date cases
use  "$prepData\ibes_ii Estabs wrong_dateCase_only.dta", clear
// 	destring regCode District, replace	
keep  Region regCode District distCode DistrictTypeCode Sub_MetroCode EZ EA_num Estab_number StreetName Suburb ExactLocation Town Team  interview__key interview__id id00 EstablishmentName Sub_Sector Supervisor SupervisorContact EnumeratorName EnumContact qtype interview__status surveyStartDate todaySystemDate interview_date interview_date_num gps_date gps_date_num date_within_surveyPeriod
if _N > 0 {
gen prepIssue = "invalid date"
generate prepError = "surveyStartDate ='"+surveyStartDate+"' but either GPS_Date ='" + gps_date+ "' or interveiwStart_Date ='" +interview_date+ "' is invalid"
} 

else {
gen prepIssue = ""	
generate prepError = ""
 }
keep Region-interview__status interview__key interview__id prepIssue prepError 
save "$tempsaveDir\prepError1" , replace 
	
* get duplicating cases
use "$prepData\ibes_ii Estabs_duplicating_only.dta", clear
*	
keep Region regCode District distCode DistrictTypeCode Sub_MetroCode EZ EA_num Estab_number StreetName Suburb ExactLocation Town Team  interview__key interview__id id00 EstablishmentName Sub_Sector Supervisor SupervisorContact EnumeratorName EnumContact qtype interview__status dups0

if _N > 0 {
gen prepIssue = "duplicate"
generate prepError = "This establishment is duplicating '" + string(dups0) + "' number of times"
}
else {
gen prepIssue = ""
generate prepError = ""
}

keep Region-interview__status interview__key interview__id prepIssue prepError id00 EstablishmentName
append using "C:\2025IBESMAIN\temp\prepError1.dta"
	
renvars regCode distCode EstablishmentName / regionCode districtCode EstName
	
gen prep_DupDeleted = 0
gen prep_InvalidDateDeleted = 0
replace prep_DupDeleted = 1 if prepIssue=="duplicate"
replace prep_InvalidDateDeleted = 1 if prepIssue=="invalid date"
save "$tempsaveDir\prepError_errordetails_all" , replace
*	
generate id = _n
collapse (count) prep_delete_count = id (sum) prep_DupDeleted prep_InvalidDateDeleted , by(interview__id)
*	
save "$tempsaveDir\prepError_error_all" , replace

local progress = 45
file open progfile using "$tempsaveDir\progress.txt", write text replace
file write progfile "`progress'"
file close progfile


****************************************************
****************************************************
//Enumerator Stat
use "$sectionData\section_00_01 COVER, IDENTIFICATION AND CLASSIFICATION", clear
generate id = _n

renvars EnumContact EnumeratorName regCode distCode Supervisor SupervisorContact / InterPhone InterName regionCode districtCode SuperName SuperPhone
*
gen intrvws_Sup_Rejected = 0
gen intrvws_Sup_Approved = 0
gen intrvws_Completed	 = 0
gen intrvws_HQ_Rejected	= 0
gen intrvws_HQ_Approved	= 0
*
replace intrvws_Sup_Rejected = 1 if interview__status == 65
replace intrvws_Completed	 = 1 if interview__status == 100
replace intrvws_Sup_Approved = 1 if interview__status == 120
replace intrvws_HQ_Rejected	= 1	if interview__status == 124
replace intrvws_HQ_Approved	= 1 if interview__status == 130
	
* Eligibilities *
gl canAnsBusQues (s00a_q09a == 1 | s00a_q09b == 1 | s00a_q09c==1 ) //  ABLE TO ANSWER Ques on THE Bus Act OF THIS ESTABLISHMENT in any of the three tries
gl canStartInterv (s00a_q10a == 1 | s00a_q10b == 1 | s00a_q10c == 1) // ABLE to start interview is Yes in any of the three tries

gen failed_interviewCount = 0
replace failed_interviewCount = 1 if !($canAnsBusQues & $canStartInterv)

destring regionCode districtCode, replace	
merge 1:1 interview__id using "$tempsaveDir\intvwrExpectedRosterStats"
// merge with prep deleted summaries
merge 1:1 interview__id using "$tempsaveDir\prepError_error_all" , nogenerate

renvars estabs_expected estabs_submitted / ExpEst IntEst

collapse (first) Team SuperName SuperPhone InterName InterPhone  ///
(sum) ExpEst IntEst prep_delete_count prep_DupDeleted  ///
prep_InvalidDateDeleted  estab_pass_prep = intrvws_Completed intrvws_Sup_Rejected  ///	
 intrvws_Completed intrvws_Sup_Approved intrvws_HQ_Rejected intrvws_HQ_Approved , by(Region regionCode District districtCode ResponsibleId) //note the responsibleID will account for the enumerator	
 
gen DiffEst = ExpEst - IntEst
gen PercNS = DiffEst *100 / ExpEst
gen percent_prepPassed = estab_pass_prep / ExpEst * 100
gen percent_HQ_Approved = intrvws_HQ_Approved / ExpEst * 100
*
drop regionCode districtCode intrvws_Sup_Rejected intrvws_Sup_Approved
*
*merge 1:1 ResponsibleId using "$tempsaveDir\IBESframe" , nogenerate
*
sort Team
order Region District Team InterName InterPhone ResponsibleId ExpEst IntEst  ///
DiffEst PercNS prep_delete_count- percent_HQ_Approved SuperName SuperPhone
save "$tempsaveDir\enumstats.dta",replace
*
loc date: display %tcCCYYNNDD!-HHMM clock("`c(current_date)'`c(current_time)'", "DMYhms")
export excel using "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("enumstats") cell(A1) firstrow(variables) sheetreplace
cap putexcel set "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("enumstats") modify
cap putexcel (A1:AZ1), bold txtrotate(45)


**************************************
**************************************
//At Team level
use "$tempsaveDir\enumstats.dta",clear
*
collapse (sum) ExpEst IntEst DiffEst prep_delete_count prep_DupDeleted prep_InvalidDateDeleted estab_pass_prep intrvws_Completed intrvws_HQ_Rejected intrvws_HQ_Approved (first) SuperName SuperPhone District, by(Region Team) 
*
gen PercNS = DiffEst *100 / ExpEst
gen percent_prepPassed = estab_pass_prep / ExpEst * 100
gen percent_HQ_Approved = intrvws_HQ_Approved / ExpEst * 100
*
sort Team
order Region District Team SuperName SuperPhone ExpEst IntEst DiffEst PercNS ///
prep_delete_count- percent_HQ_Approved 
save "$tempsaveDir\teamstats.dta",replace
export excel using "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("teamstats") cell(A1) firstrow(variables) sheetreplace
cap putexcel set "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("teamstats") modify
cap putexcel (A1:AZ1), bold txtrotate(45)


*************************************************
*************************************************
* Duplicates
use "$tempsaveDir\prepError_errordetails_all" , clear
destring regionCode districtCode, replace	
*
keep if prepIssue=="duplicate"
renvars EnumeratorName Supervisor/ InterName SuperName
*
drop regionCode districtCode DistrictTypeCode Sub_MetroCode EZ EA_num  ///
StreetName Suburb ExactLocation Town SupervisorContact EnumContact
*
sort Team
order Region District Team InterName interview__key interview__id id00 Estab_number EstName interview__status qtype prepIssue prepError   ///
prep_DupDeleted prep_InvalidDateDeleted SuperName
*
insobs 1
save "$tempsaveDir\Duplicates.dta",replace
export excel using "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("Duplicates") cell(A1) firstrow(variables) sheetreplace
cap putexcel set "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("Duplicates") modify
cap putexcel (A1:AZ1), bold txtrotate(45)


*************************************************
*************************************************
* Gaps
use "$tempsaveDir\enumstats.dta",clear
*
drop InterPhone PercNS-percent_HQ_Approved SuperPhone
keep if ExpEst!=IntEst
sort Team
order Region District Team InterName ExpEst IntEst DiffEst SuperName
*
insobs 1
save "$tempsaveDir\Gaps.dta",replace
export excel using "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("Gaps") cell(A1) firstrow(variables) sheetreplace
cap putexcel set "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("Gaps") modify
cap putexcel (A1:AZ1), bold txtrotate(45)


*************************************************
*************************************************
* Export Prep Deleted Outputs Details
use "$tempsaveDir\prepError_errordetails_all" , clear
destring regionCode districtCode, replace	
*
keep if prepIssue=="invalid date"
renvars EnumeratorName Supervisor/ InterName SuperName
*
drop regionCode districtCode DistrictTypeCode Sub_MetroCode EZ EA_num  ///
StreetName Suburb ExactLocation Town SupervisorContact EnumContact
*
sort Team
order Region District Team InterName interview__key interview__id   ///
Estab_number interview__status qtype prepIssue prepError    ///
prep_DupDeleted prep_InvalidDateDeleted SuperName
*
insobs 1
save "$tempsaveDir\InvalidDates.dta",replace
export excel using "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("Invalid Dates") cell(A1) firstrow(variables) sheetreplace
cap putexcel set "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("Invalid Dates") modify
cap putexcel (A1:AZ1), bold txtrotate(45)

*
local progress = 75
file open progfile using "$tempsaveDir\progress.txt", write text replace
file write progfile "`progress'"
file close progfile
*

*************************************************
*************************************************
* Sector Change
use "$sectionData\section_00_01 COVER, IDENTIFICATION AND CLASSIFICATION", clear
generate id = _n

renvars EnumContact EnumeratorName regCode distCode Supervisor SupervisorContact / InterPhone InterName regionCode districtCode SuperName SuperPhone
	
* Eligibilities *
gl canAnsBusQues (s00a_q09a == 1 | s00a_q09b == 1 | s00a_q09c==1 ) //  ABLE TO ANSWER Ques on THE Bus Act OF THIS ESTABLISHMENT in any of the three tries
gl canStartInterv (s00a_q10a == 1 | s00a_q10b == 1 | s00a_q10c == 1) // ABLE to start interview is Yes in any of the three tries

gen failed_interviewCount = 0
replace failed_interviewCount = 1 if !($canAnsBusQues & $canStartInterv)
	
*** for now, we would only deal with submitted cases from completed status upward
label list interview__status	
		
gen intrvws_Sup_Rejected = 0
gen intrvws_Sup_Approved = 0
gen intrvws_Completed	 = 0
gen intrvws_HQ_Rejected	= 0
gen intrvws_HQ_Approved	= 0
	
replace intrvws_Sup_Rejected = 1  	if interview__status == 65
replace intrvws_Completed	 = 1	if interview__status == 100
replace intrvws_Sup_Approved = 1 	if interview__status == 120
replace intrvws_HQ_Rejected	= 1		if interview__status == 124
replace intrvws_HQ_Approved	= 1  	if interview__status == 130
*
ren Sub_Sector bus_sec_listing
collapse (first) Team SuperName SuperPhone InterName InterPhone qtype   ///
(sum) failed_interviewCount intrvws_Sup_Rejected intrvws_Completed   ///
intrvws_Sup_Approved intrvws_HQ_Rejected intrvws_HQ_Approved,    ///
by(Region regionCode District districtCode EZ bus_sec_listing interview__id)
	
label values qtype s1qso2
    	
// compute for sector changes
gen sector_change = 0
replace sector_change = 1 if bus_sec_listing != qtype
	
// 	ren Sub_Sector bus_sec_listing
destring regionCode districtCode, replace	
merge 1:1 interview__id  using "$tempsaveDir\intvwrExpectedRosterStats"
// merge with prep deleted summaries
merge 1:1 interview__id  using "$tempsaveDir\prepError_error_all" , nogenerate
	
collapse (first) Team SuperName SuperPhone InterName InterPhone  ///
(sum) estabs_expected estabs_submitted prep_delete_count prep_DupDeleted  ///
prep_InvalidDateDeleted  estab_pass_prep = intrvws_Completed     ///	
intrvws_Sup_Rejected intrvws_Completed intrvws_Sup_Approved      ///
intrvws_HQ_Rejected intrvws_HQ_Approved changed_qtype=sector_change,   ///
by(Region regionCode District districtCode bus_sec_listing ResponsibleId)
		
levelsof districtCode, local(districts)
*
drop prep_delete_count-intrvws_HQ_Approved
sort Team
order Region regionCode District districtCode Team SuperName SuperPhone InterName InterPhone bus_sec_listing
*
drop if ResponsibleId==""
save "$tempsaveDir\Qtypechange.dta",replace


use "$tempsaveDir\Qtypechange.dta",clear
keep if bus_sec_listing==1
insobs 1
collapse (sum) AgricExp = estabs_expected AgricInt = estabs_submitted AgricDiff = changed_qtype, by (Region District /*Team SupervisorName EnumeratorName*/ ResponsibleId)
save "$tempsaveDir\QtypeAgric.dta",replace
*
use "$tempsaveDir\Qtypechange.dta",clear
keep if bus_sec_listing==2
insobs 1
collapse (sum) MinQryExp = estabs_expected MinQryInt = estabs_submitted MinQryDiff = changed_qtype, by (Region District /*Team SupervisorName EnumeratorName*/ ResponsibleId)
save "$tempsaveDir\QtypeMinQry.dta",replace
*
use "$tempsaveDir\Qtypechange.dta",clear
keep if bus_sec_listing==3
insobs 1
collapse (sum) ManufExp = estabs_expected ManufInt = estabs_submitted ManufDiff = changed_qtype, by (Region District /*Team SupervisorName EnumeratorName*/ ResponsibleId)
save "$tempsaveDir\QtypeManuf.dta",replace
*
use "$tempsaveDir\Qtypechange.dta",clear
keep if bus_sec_listing==4
insobs 1
collapse (sum) EWSExp = estabs_expected EWSInt = estabs_submitted EWSDiff = changed_qtype, by (Region District /*Team SupervisorName EnumeratorName*/ ResponsibleId)
save "$tempsaveDir\QtypeEWS.dta",replace
*
use "$tempsaveDir\Qtypechange.dta",clear
keep if bus_sec_listing==5
insobs 1
collapse (sum) ConsExp = estabs_expected ConsInt = estabs_submitted ConsDiff = changed_qtype, by (Region District /*Team SupervisorName EnumeratorName*/ ResponsibleId)
save "$tempsaveDir\QtypeCons.dta",replace
*
use "$tempsaveDir\Qtypechange.dta",clear
keep if bus_sec_listing==6
insobs 1
collapse (sum) Ser1Exp = estabs_expected Ser1Int = estabs_submitted Ser1Diff = changed_qtype, by (Region District /*Team SupervisorName EnumeratorName*/ ResponsibleId)
save "$tempsaveDir\QtypeSer1.dta",replace
*
use "$tempsaveDir\Qtypechange.dta",clear
keep if bus_sec_listing==7
insobs 1
collapse (sum) Ser2Exp = estabs_expected Ser2Int = estabs_submitted Ser2Diff = changed_qtype, by (Region District /*Team SupervisorName EnumeratorName*/ ResponsibleId)
save "$tempsaveDir\QtypeSer2.dta",replace
*
use "$tempsaveDir\Qtypechange.dta",clear
keep if bus_sec_listing==8
insobs 1
collapse (sum) WRTExp = estabs_expected WRTInt = estabs_submitted WRTDiff = changed_qtype, by (Region District /*Team SupervisorName EnumeratorName*/ ResponsibleId)
save "$tempsaveDir\QtypeWRT.dta",replace

*Merging All change sectors
use "$tempsaveDir\Qtypechange.dta",clear
collapse (first) Team SuperName InterName, by (Region District ResponsibleId)
*use "$tempsaveDir\QtypeAgric.dta",clear
merge 1:1 ResponsibleId  using "$tempsaveDir\QtypeAgric", nogenerate
merge 1:1 ResponsibleId  using "$tempsaveDir\QtypeMinQry", nogenerate
merge 1:1 ResponsibleId  using "$tempsaveDir\QtypeManuf", nogenerate
merge 1:1 ResponsibleId  using "$tempsaveDir\QtypeEWS", nogenerate
merge 1:1 ResponsibleId  using "$tempsaveDir\QtypeCons", nogenerate
merge 1:1 ResponsibleId  using "$tempsaveDir\QtypeSer1", nogenerate
merge 1:1 ResponsibleId  using "$tempsaveDir\QtypeSer2", nogenerate
merge 1:1 ResponsibleId  using "$tempsaveDir\QtypeWRT", nogenerate
*
drop if Region==.
*
ds, has(type numeric)
foreach var of varlist `r(varlist)' {
replace `var' = 0 if missing(`var')
}

sort Team 
order Region District Team InterName ResponsibleId AgricExp - WRTDiff SuperName
insobs 1
save "$tempsaveDir\SectorChange.dta",replace
export excel using "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("Changed Sector") cell(A1) firstrow(variables) sheetreplace
cap putexcel set "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("Changed Sector") modify
cap putexcel (A1:AZ1), bold txtrotate(45)


//   local progress = (100 / 100)
local progress = 100
file open progfile using "$tempsaveDir\progress.txt", write text replace
file write progfile "`progress'"
file close progfile
 