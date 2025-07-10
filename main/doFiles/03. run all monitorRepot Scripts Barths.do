cd "C:\2025IBESMAIN"
gl rootDir "C:\2025IBESMAIN"
gl prepData "$rootDir\Data\prep\dateTime and Dups"
gl sectionData "$rootDir\Data\prep\sectionData"

gl do_file_loc "$rootDir\server\doFiles"
gl tempsaveDir "$rootDir\temp"

gl report_dir "$rootDir\Reports"
gl monitor_report_dir "$report_dir\monitorReports"
gl dist_monitor_report_dir "$monitor_report_dir\districts"

// gl prepData "C:\2025IBESMAIN\Data\prep\dateTime and Dups"
// gl sectionData "C:\2025IBESMAIN\Data\prep\sectionData"

//create monitor report dir if it does not exist
capture mkdir $report_dir
capture mkdir $monitor_report_dir

// Calculate progress percentage
    local progress = 5
    // Write progress to a file
    file open progfile using "$tempsaveDir\progress.txt", write text replace
    file write progfile "`progress'"
	file close progfile
	
************************************************
*FRAME FILE
*	
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
drop Region Role supLoginId SupervisorId ResponsibleId	ResponsibleName AssignmentId InterviewTransactions_Count Regioncode Districtcode QuestionnaireVersion interviewerCreationDate
*
renvars region TeamNumber EnumeratorContact EnumeratorName SupervisorName SupervisorContact assignmentCreated_count assignment_receivedByTablet assignemntQtySumTotal InterviewId / Region Team InterPhone InterName SuperName SuperPhone AssignCount AssignReceived TotalEst interview__id
*
gen AssignNotReceived = AssignCount - AssignReceived
*
sort Team
order Region Team
save IBESframe.dta,replace
	
	
****************************************************
****************************************************
//Enumerator Stat
*
use "$sectionData\section_00_01 COVER, IDENTIFICATION AND CLASSIFICATION", clear
generate id = _n
	
ren EnumContact InterPhone
ren EnumeratorName InterName
ren regCode regionCode
ren distCode districtCode
ren Supervisor SuperName
ren SupervisorContact SuperPhone

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
	
* Eligibilities *
gl canAnsBusQues (s00a_q09a == 1 | s00a_q09b == 1 | s00a_q09c==1 ) //  ABLE TO ANSWER Ques on THE Bus Act OF THIS ESTABLISHMENT in any of the three tries
gl canStartInterv (s00a_q10a == 1 | s00a_q10b == 1 | s00a_q10c == 1) // ABLE to start interview is Yes in any of the three tries

gen failed_interviewCount = 0
replace failed_interviewCount = 1 if !($canAnsBusQues & $canStartInterv)

destring regionCode districtCode, replace	
merge 1:1 interview__id  using "$tempsaveDir\intvwrExpectedRosterStats"
// merge with prep deleted summaries
merge 1:1 interview__id  using "$tempsaveDir\prepError_error_all" , nogenerate

ren estabs_expected ExpEst
ren estabs_submitted IntEst

collapse (first) Team SuperName SuperPhone InterName InterPhone  ///
(sum) ExpEst IntEst prep_delete_count prep_DupDeleted  ///
prep_InvalidDateDeleted  estab_pass_prep = intrvws_Completed intrvws_Sup_Rejected  ///	
 intrvws_Completed intrvws_Sup_Approved intrvws_HQ_Rejected intrvws_HQ_Approved , by(Region regionCode District districtCode ResponsibleId) //note the responsibleID will account for the enumerator	
 
gen DiffEst = ExpEst - IntEst
gen PercNS = DiffEst *100 / ExpEst
gen percent_prepPassed = estab_pass_prep / ExpEst * 100
gen percent_HQ_Approved = intrvws_HQ_Approved / ExpEst * 100
*

drop regionCode districtCode ResponsibleId intrvws_Sup_Rejected intrvws_Sup_Approved

sort Team
order Region District Team InterName InterPhone ExpEst IntEst DiffEst PercNS ///
prep_delete_count- percent_HQ_Approved SuperName SuperPhone
save enumstats.dta,replace

loc date: display %tcCCYYNNDD!-HHMM clock("`c(current_date)'`c(current_time)'", "DMYhms")
export excel using "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("enumstats") cell(A1) firstrow(variables) sheetreplace
cap putexcel set "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("enumstats") modify
cap putexcel (A1:AZ1), bold txtrotate(45)

**************************************
**************************************
//At Team level
use enumstats.dta,clear
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
save teamstats.dta,replace
export excel using "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("teamstats") cell(A1) firstrow(variables) sheetreplace
cap putexcel set "$dist_monitor_report_dir\IBES_monitor_report_`date'.xlsx", sheet("teamstats") modify
cap putexcel (A1:AZ1), bold txtrotate(45)


*************************************************************
*************************************************************
//Duplicates
use "$sectionData\section_00_01 COVER, IDENTIFICATION AND CLASSIFICATION", clear

renvars EnumContact EnumeratorName regCode distCode Supervisor SupervisorContact/ InterPhone InterName regionCode districtCode SuperName SuperPhone
*
duplicates tag , gen(dups)




		
	
				
				
	
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
	
	// 	gen submittedCases = 0
	// 	replace submittedCases=1 if interview__status >=65
ren Sub_Sector bus_sec_listing
collapse (first) Team SupervisorName SupervisorContact EnumeratorName   ///
EnumeratorContact qtype (sum)  failed_interviewCount intrvws_Sup_Rejected  ///
intrvws_Completed intrvws_Sup_Approved intrvws_HQ_Rejected intrvws_HQ_Approved, ///
by(Region regionCode District districtCode EZ bus_sec_listing interview__id)
*
label values qtype s1qso2
    	
	// 	compute for sector /// Qtype changes
	gen sector_change = 0
	replace sector_change = 1 if bus_sec_listing != qtype
	
	// 	ren Sub_Sector bus_sec_listing
	destring regionCode districtCode, replace	
	merge 1:1 interview__id  using "$tempsaveDir\intvwrExpectedRosterStats"
	// merge with prep deleted summaries
	merge 1:1 interview__id  using "$tempsaveDir\prepError_error_all" , nogenerate
	
	collapse (first) Team SupervisorName SupervisorContact EnumeratorName EnumeratorContact ///
		(sum) estabs_expected  ///
		estabs_submitted prep_delete_count prep_DupDeleted prep_InvalidDateDeleted  estab_pass_prep = intrvws_Completed ///	
		intrvws_Sup_Rejected intrvws_Completed intrvws_Sup_Approved intrvws_HQ_Rejected intrvws_HQ_Approved changed_qtype=sector_change, ///
		by(Region regionCode District districtCode bus_sec_listing ResponsibleId)
		
levelsof districtCode, local(districts)
// Loop through each districts level
foreach regdist of local districts {
	preserve    
 
    // Keep only current regdist level data
    keep if districtCode == `regdist'
    
    // only continue to export if there are observations
    if _N > 0 {
	    	drop prep_delete_count-intrvws_HQ_Approved
			order Region regionCode District districtCode Team SupervisorName SupervisorContact EnumeratorName EnumeratorContact bus_sec_listing
			sort regionCode districtCode Team SupervisorName EnumeratorName bus_sec_listing
			gen submit_QtypePerc_change = changed_qtype /estabs_submitted * 100
			drop ResponsibleId
			// EXPORT TO EXCEL
			export excel using "$dist_monitor_report_dir/monitorReport_`regdist'.xlsx", ///
				firstrow(variables) sheet("Interviewer QtypeChanges") sheetreplace	
	}
	restore
		
	//Interviewer Stats 
	preserve
	   // Keep only current regdist level data
    keep if districtCode == `regdist'
	  if _N > 0 {
		
			collapse (first) Team SupervisorName SupervisorContact EnumeratorName EnumeratorContact ///
				(sum) estabs_expected  ///
				estabs_submitted   prep_delete_count prep_DupDeleted prep_InvalidDateDeleted  estab_pass_prep = intrvws_Completed ///	
				intrvws_Sup_Rejected intrvws_Completed intrvws_Sup_Approved intrvws_HQ_Rejected intrvws_HQ_Approved changed_qtype, ///
				by(Region regionCode District districtCode ResponsibleId) //note the responsibleID will account for the enumerator			
			gen estab_Outstanding = estabs_expected - estabs_submitted
			order Region-estabs_submitted estab_Outstanding
			sort Region regionCode District districtCode  Team SupervisorName EnumeratorName // bus_sec_listing 
			gen percent_submitted = estabs_submitted / estabs_expected * 100
			gen percent_prepPassed = estab_pass_prep / estabs_expected * 100
			gen percent_HQ_Approved = intrvws_HQ_Approved / estabs_expected * 100
			gen percent_Qtype_change = changed_qtype / estabs_expected * 100
			order Region regionCode District districtCode Team SupervisorName SupervisorContact EnumeratorName EnumeratorContact 
			// EXPORT TO EXCEL
			ds ResponsibleId, not //  lists all variables except ResponsibleId
			local exportExcelVars `r(varlist)'
			export excel `exportExcelVars' using "$dist_monitor_report_dir/monitorReport_`regdist'.xlsx", ///
				firstrow(variables) sheet("Interviewer Stats") sheetreplace	 		
	
	//Team Stats 
			collapse  (sum) estabs_expected  ///
				estabs_submitted prep_delete_count prep_DupDeleted prep_InvalidDateDeleted  estab_pass_prep = intrvws_Completed ///	
				intrvws_Sup_Rejected intrvws_Completed intrvws_Sup_Approved intrvws_HQ_Rejected intrvws_HQ_Approved changed_qtype, ///
				by(Region regionCode District districtCode Team SupervisorName SupervisorContact) 
		
			gen percent_submitted = estabs_submitted / estabs_expected * 100
			gen percent_prepPassed = estab_pass_prep / estabs_expected * 100
			gen percent_HQ_Approved = intrvws_HQ_Approved / estabs_expected * 100
			gen percent_Qtype_change = changed_qtype / estabs_expected * 100
			// EXPORT TO EXCEL
			export excel using "$dist_monitor_report_dir/monitorReport_`regdist'.xlsx", ///
				firstrow(variables) sheet("Team Stats") sheetreplace	
	}

restore	
}

	