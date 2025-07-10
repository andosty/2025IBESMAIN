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

************************************
*    Interviewer/Team Assignment stats
************************************
// call in the interviewr assignment data
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
 drop Region Role supLoginId SupervisorId InterviewId ResponsibleId	ResponsibleName AssignmentId InterviewTransactions_Count
 ren region Region
 ren Regioncode regionCode
 ren Districtcode districtCode	
 ren assignemntQtySumTotal establishment_total
 ren TeamNumber Team
 // bring Region as first column
 order Region regionCode
// sort the data
 sort  Region  districtCode Team SupervisorName EnumeratorName

//  save "$rootDir\server\frame\interviewer assingment frame.dta" , replace
//  use "$rootDir\server\frame\interviewer assingment frame.dta" , clear
 
 gen assignments_not_received = assignmentCreated_count - assignment_receivedByTablet
//  gen transactions_outstanding = establishment_total - InterviewTransactions_Count
 
 *assess scripts
do "$do_file_loc\assessCode.do" 

// //national
// if $myAccessLevel==0 {
// 	gen myVAr=1 	
// 	} 
// //non-national	
// if $myAccessLevel>0 {
// 	gen allThem= 2 
// } 
 
 
// Get unique district codes in the filtered dataset as levels
levelsof districtCode, local(districts)
//
// quietly duplicates report districtCode  
// global distinct_count = r(unique_value)  
// display "Number of distinct values: $distinct_count"  
// local increment = 25/$distinct_count
// Create a timestamp for filenames
// local timestamp = subinstr("$S_DATE $S_TIME", ":", "-", .)
// local timestamp = subinstr("`timestamp'", " ", "_", .)

// Create a directory for district report output (if it doesn't exist)
capture mkdir $dist_monitor_report_dir

// Loop through each current regdist level
foreach regdist of local districts {
    preserve    
	
    // Keep only current regdist level data
    keep if districtCode == `regdist'
    
    // only continue to export if there are observations
    if _N > 0 {
	// interviewer assingment
        // Export to Excel
        export excel using "$dist_monitor_report_dir/monitorReport_`regdist'.xlsx", ///
            firstrow(variables) sheet("Intrvwr Assignments") replace
			
	// team assingment
	generate id = _n
	collapse (count)  enumerators_count = id ///
	(sum) establishment_total assignmentCreated_count assignment_receivedByTablet assignments_not_received , ///
	by(Region regionCode District districtCode Team SupervisorName SupervisorContact)
		// Export to Excel
		export excel using "$dist_monitor_report_dir/monitorReport_`regdist'.xlsx", ///
		firstrow(variables) sheet("Team Assignments") sheetreplace			
    }
    else {
		insobs 1
		// interviewer assingment
			// Export to Excel
			export excel using "$dist_monitor_report_dir/monitorReport_`regdist'.xlsx", ///
				firstrow(variables) sheet("Intrvwr Assignments") replace
			
		// team assingment
		generate id = _n
		collapse (count)  enumerators_count = id ///
		(sum) establishment_total assignmentCreated_count assignment_receivedByTablet assignments_not_received , ///
		by(Region regionCode District districtCode Team SupervisorName SupervisorContact)
			// Export to Excel
			export excel using "$dist_monitor_report_dir/monitorReport_`regdist'.xlsx", ///
			firstrow(variables) sheet("Team Assignments") sheetreplace	
		}
    
    restore
}

//   local progress = `progress' + `increment'
  local progress = 25
  file open progfile using "$tempsaveDir\progress.txt", write text replace
 file write progfile "`progress'"
 file close progfile
************************************
*    Establishment Assignment stats
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
 drop Region  //supLoginId SupervisorId InterviewId ResponsibleId	ResponsibleName AssignmentId InterviewTransactions_Count
 ren region Region
 ren Regioncode regionCode
 ren Districtcode districtCode
 ren TeamNumber Team
 ren EnumerationZoneNumber EZ
  
 gen ques_Status=.
	replace ques_Status=0 if Status=="Deleted"
	replace ques_Status=1 if Status=="InterviewerAssigned"
	replace ques_Status=2 if Status=="Completed"
	replace ques_Status=3 if Status=="RejectedBySupervisor" 
	replace ques_Status=4 if Status=="ApprovedBySupervisor" 
	replace ques_Status=5 if Status=="RejectedByHeadquarters"  
	replace ques_Status=6 if Status=="ApprovedByHeadquarters" 
	
	replace ques_Status=1 if !(inrange(ques_Status,2,6) | inlist(ques_Status,0,1 )) //Restored, Created, Restarted, SentToCapi

	lab def ques_Status 0 "Deleted" 1"InterviewerAssigned" 2 "Completed" 3"RejectedBySupervisor" 4"ApprovedBySupervisor" 5"RejectedByHeadquarters" 6"ApprovedByHeadquarters" 
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
//   lab def bus_sec  1 "AGRICULTURE" 2 "MINING AND QUARRYING" 3"MANUFACTURING" ///
// 				   4 "ELECTRICITY AND WATER" 5"CONSTRUCTION" 6"SERVICES 1"  ///
// 				   7 "SERVICES 2" 8"WHOLESALE AND RETAIL TRADE" 
 
 lab val business_sector_listing s1qso2
 
 // bring Region as first column
 order Region regionCode
 order Region-Status ques_Status
 // reposition business_sector_listing near Subsectorofbusiness, at where it should be
 order Region-Subsectorofbusiness business_sector_listing
 drop Subsectorofbusiness ResponsibleName AssignmentId QuestionnaireId ErrorsCount Status
 order Region regionCode District districtCode Team SupervisorName SupervisorContact EnumeratorName EnumeratorContact System NameofEstablishment business_sector_listing
 ren System id00
 ren business_sector_listing bus_sec_listing
// sort the data
 sort  Region  districtCode Team SupervisorName EnumeratorName
// tab ques_Status ReceivedByDevice  * further analysis

// Get unique district codes in the filtered dataset as levels
levelsof districtCode, local(districts)
// Loop through each districts level
foreach regdist of local districts {
preserve    
	
	drop  InterviewId ResponsibleId	
    // Keep only current regdist level data
    keep if districtCode == `regdist'
    
    // only continue to export if there are observations
    if _N > 0 {
	// detail establishment assingment
        // Export to Excel
        export excel using "$dist_monitor_report_dir/monitorReport_`regdist'.xlsx", ///
            firstrow(variables) sheet("Assingment frame") sheetreplace
		
	// check for duplicating estabCode during Assignment
		duplicates tag id00 , gen(dups)
		keep if dups > 0
		insobs 1
		
		// Export Assignment Dups to Excel
			export excel using "$dist_monitor_report_dir/monitorReport_`regdist'.xlsx", ///
				firstrow(variables) sheet("Assignment EstabDups") sheetreplace
			
	// check for EZs in data
  restore
	preserve
		keep if districtCode == `regdist'
		gen interviews = 0 
		gen interviews_approved = 0 
		replace interviews = 1 if ques_Status > 1
		replace interviews_approved = 1 if ques_Status == 6 
		generate id = _n
		
		collapse (count) estabs_expected = id   (sum) estabs_submitted =  interviews estabs_HQ_Approved = interviews_approved , ///
			by(Region regionCode District districtCode EZ  ///
			Team SupervisorName SupervisorContact EnumeratorName EnumeratorContact)  			
// 			(first) TeamNumber SupervisorName SupervisorContact EnumeratorName EnumeratorContact, ///
// 			by(Region regionCode District districtCode EnumerationZoneNumber)  // DistrictTypeCode Submetrocode
		
		gen estabs_not_HQ_Approved = estabs_expected - estabs_HQ_Approved
		order Region-estabs_HQ_Approved estabs_not_HQ_Approved
		// Export EZ summaries to Excel
			export excel using "$dist_monitor_report_dir/monitorReport_`regdist'.xlsx", ///
				firstrow(variables) sheet("EZ Summary") sheetreplace	
				
		collapse (first) Team SupervisorName SupervisorContact EnumeratorName EnumeratorContact ///
				(sum) estabs_expected estabs_submitted  estabs_HQ_Approved  , ///
				by(Region regionCode District districtCode EZ )  		
		order Region regionCode District districtCode EZ
		sort Region regionCode District districtCode EZ
		// Export EZ summaries to Excel
			export excel using "$dist_monitor_report_dir/monitorReport_`regdist'.xlsx", ///
				firstrow(variables) sheet("EZ_in_data") sheetreplace			
    }
    else {
		insobs 1
		// interviewer assingment
			// Export to Excel
			export excel using "$dist_monitor_report_dir/monitorReport_`regdist'.xlsx", ///
				firstrow(variables) sheet("Assingment frame") sheetreplace		
		}    
		
	restore
}

 local progress = 45
 file open progfile using "$tempsaveDir\progress.txt", write text replace
 file write progfile "`progress'"
 file close progfile
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
	collapse (count) estabs_expected = id   (sum) estabs_submitted =  interviews estabs_HQ_Approved = interviews_approved ///
		(first) Team SupervisorName SupervisorContact EnumeratorName EnumeratorContact, ///
		by(Region regionCode District districtCode EZ bus_sec_listing ResponsibleId	 interview__id)  //   InterviewId 

	order Region - districtCode EZ Team SupervisorName SupervisorContact EnumeratorName EnumeratorContact bus_sec_listing
	sort  Region - districtCode  EZ Team SupervisorName EnumeratorName bus_sec_listing  
	 
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
	use  "$prepData\ibes_ii Estabs_duplicating_only.dta", clear
// 	destring regCode District, replace	
	keep  Region regCode District distCode DistrictTypeCode Sub_MetroCode EZ EA_num Estab_number StreetName Suburb ExactLocation Town Team  interview__key interview__id id00 EstablishmentName Sub_Sector Supervisor SupervisorContact EnumeratorName EnumContact qtype interview__status 
	if _N > 0 {
	    gen prepIssue = "duplicate"
	    generate prepError = "This establishment is duplicating '" + dups0 + "' number of times"
	}
	 else {
	     gen prepIssue = ""
	     generate prepError = ""
	 }
	keep Region-interview__status interview__key interview__id prepIssue prepError
	append using "C:\2025IBESMAIN\temp\prepError1.dta"
	
	ren regCode regionCode
	ren distCode districtCode
	
	gen prep_DupDeleted = 0
	gen prep_InvalidDateDeleted = 0
	replace prep_DupDeleted = 1 if prepIssue=="duplicate"
	replace prep_InvalidDateDeleted = 1 if prepIssue=="invalid date"
	save "$tempsaveDir\prepError_errordetails_all" , replace
	
	generate id = _n
	collapse (count) prep_delete_count = id (sum) prep_DupDeleted prep_InvalidDateDeleted , by(interview__id)
	
	save "$tempsaveDir\prepError_error_all" , replace
	
// merge with current prepped data to check for changes in Qtypes
	//	get data that has passed prep, and see work done by interviewer in each EZ
	use "$sectionData\section_00_01 COVER, IDENTIFICATION AND CLASSIFICATION", clear
	generate id = _n
	
	ren EnumContact EnumeratorContact
	ren regCode regionCode
	ren distCode districtCode
	ren Supervisor SupervisorName
	
	* Eligibilities *
	gl canAnsBusQues (s00a_q09a == 1 | s00a_q09b == 1 | s00a_q09c==1 ) //  ABLE TO ANSWER Ques on THE Bus Act OF THIS ESTABLISHMENT in any of the three tries
	gl canStartInterv (s00a_q10a == 1 | s00a_q10b == 1 | s00a_q10c == 1) // ABLE to start interview is Yes in any of the three tries

	gen failed_interviewCount = 0
	replace failed_interviewCount = 1 if !($canAnsBusQues & $canStartInterv)
	
	*** for now, we would only deal with submitted cases from completed status upward
	label list interview__status	
	//           -1 Deleted
	//            0 Restored
	//           20 Created
	//           40 SupervisorAssigned
	//           60 InterviewerAssigned
	//           65 RejectedBySupervisor	*
	//           80 ReadyForInterview
	//           85 SentToCapi
	//           95 Restarted
	//          100 Completed				*
	//          120 ApprovedBySupervisor 	*
	//          125 RejectedByHeadquarters  *
	//          130 ApprovedByHeadquarters  *
		
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
	collapse (first) Team SupervisorName SupervisorContact EnumeratorName EnumeratorContact qtype  ///
	(sum)  failed_interviewCount ///
	intrvws_Sup_Rejected intrvws_Completed intrvws_Sup_Approved intrvws_HQ_Rejected intrvws_HQ_Approved, ///
	by(Region regionCode District districtCode EZ bus_sec_listing interview__id)
	
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


 local progress = 75
 file open progfile using "$tempsaveDir\progress.txt", write text replace
 file write progfile "`progress'"
 file close progfile
* Export Prep Deleted Outputs Details
use "$tempsaveDir\prepError_errordetails_all" , clear
destring regionCode districtCode, replace	

foreach regdist of local districts {
	preserve    
	keep if districtCode == `regdist'	
	keep if prepIssue=="invalid date"
	//Prep Invalid Date Data  
	// stata would only continue to export if there are observations
	if _N == 0 {
		insobs 1
	}
	// EXPORT TO EXCEL
	export excel using "$dist_monitor_report_dir/monitorReport_`regdist'.xlsx", ///
			firstrow(variables) sheet("Invalid Dates") sheetreplace
	restore
	preserve
	
	//Prep Duplicates Data
	keep if districtCode == `regdist'	
	keep if prepIssue=="duplicate"
	//stata would only continue to export if there are observations
	if _N == 0 {
		insobs 1
	}
	// EXPORT TO EXCEL
	export excel using "$dist_monitor_report_dir/monitorReport_`regdist'.xlsx", ///
			firstrow(variables) sheet("Duplicates") sheetreplace	
		
	restore
}

//   local progress = (100 / 100)
 local progress = 100
 file open progfile using "$tempsaveDir\progress.txt", write text replace
 file write progfile "`progress'"
 file close progfile
 