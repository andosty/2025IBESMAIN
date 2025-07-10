********************************************
* Integrated Business Establishment Survey *
* Purpose: Error Checks					   *
* Author: DQM Team						   *
* Date Created: 20250512				   *
* Date Updated: 20250710				   *
********************************************

clear

*-----------------------------------
*  Define Global Variables 
*-----------------------------------
gl rootDir "C:\2025IBESMAIN"
gl prepData "$rootDir\Data\prep\dateTime and Dups"
gl sectionData "$rootDir\Data\prep\sectionData"
gl HQData "$rootDir\HQData"
gl reportsDir "$rootDir\reports"
gl error_report "$reportsDir\errorFiles\errors_report"
// gl monitor_report_dir "$reportsDir\monitorsReport"
gl do_file_loc "$rootDir\main\doFiles"
gl do_file_errorSectionChecks_loc "$do_file_loc\errorChecks"
gl tempsaveDir "$rootDir\temp"

*------------------------------------------------------
*  Prep the downloaded data
*------------------------------------------------------
do "$do_file_loc\01. data preparation.do" 

*------------------------------------------------------
* Check the data for content errors
*------------------------------------------------------
do "$do_file_loc\02. run all errorChecks.do" 


*------------------------------------------------------
* APPENDING VARIOUS ERROR DTA FILES TO ONE STATA FILE
*------------------------------------------------------
*append error files
// Set your working directory to the folder containing the files
clear
cd "$error_report"
	// Get list of all .dta files
	local files: dir . files "*.dta"

	// Check if there are files to merge
	if `: word count `files'' == 0 {
		display as error "No .dta files found in the directory"
		exit
	}

	// Initialize with the first file
	use `: word 1 of `files'', clear

	// Append remaining files
	foreach file of local files {
		if "`file'" != "`: word 1 of `files''" {
			append using "`file'" , force
		}
	}
	
	// bcos of insob 1, we need to drop those blanks
	drop if missing(errorMessage) & missing(error_flag)
	
	sort id00 interview__key interview__id  Estab_number EstablishmentName  EnumeratorName  section errorCheck  errorMessage
	
	decode(interview__status) , gen(interview__status_new)
	
	// keep cases with status as that is not rejected and below
	label list interview__status
	keep if inlist(interview__status, 100,120 ,130) // status 100 = Completed, 120 = ApprovedBySupervisor, and 130 = ApprovedByHeadquarters
	drop interview__status
	ren interview__status_new interview__status 

// 	keep if interview__status
// 	insobs 1
	
	
	save "$reportsDir\errorFiles\err_dta_Merge\ibes_ii mergedErrs.dta", replace

// END OF APPENDING VARIOUS ERROR DTA FILES
*------------------------------------------------------








	