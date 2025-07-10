********************************************
* Integrated Business Establishment Survey *
* Purpose: Error Checks					   *
* Author: DQM Team						   *
* Date Created: 20250512				   *
* Date Updated: 20250512				   *
********************************************

clear

***** Define Global Variables ******
gl rootDir "C:\2025IBESMAIN"
gl prepData "$rootDir\Data\prep\dateTime and Dups"
gl sectionData "$rootDir\Data\prep\sectionData"
gl HQData "$rootDir\HQData"
gl reportsDir "$rootDir\reports"
gl error_report "$reportsDir\errorFiles\errors_report"
// gl monitor_report_dir "$reportsDir\monitorsReport"
gl do_file_loc "C:\2025IBESMAIN\server\doFiles"
gl do_file_errorSectionChecks_loc "C:\2025IBESMAIN\server\doFiles\errorChecks"
gl tempsaveDir "C:\2025IBESMAIN\temp"

// Calculate progress percentage
    local progress = 5
    // Write progress to a file
    file open progfile using "$tempsaveDir\progress.txt", write text replace
    file write progfile "`progress'"
	file close progfile

*prep the data
do "$do_file_loc\01. data preparation.do" 


// Calculate progress percentage
    local progress = 10
    // Write progress to a file
    file open progfile using "$tempsaveDir\progress.txt", write text replace
    file write progfile "`progress'"
	file close progfile
	
	
* run errorChecks
*create error report folder for individual error files
// shell rmdir /s /q "$error_report"
// shell mkdir /s /q "$error_report/errors_report"
//
// *create monitor reports dir if not exist
// shell mkdir /s /q "$reportsDir"
// shell mkdir /s /q "$monitor_report_dir"
// shell rm -rf "folderpath"  //lnx
// rmdir "$error_report"
// mkdir "$error_report"

do "$do_file_loc\02. run all errorChecks.do" 
*------------------------------------------------------
* END OF APPENDING VARIOUS ERROR DTA FILES
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
			append using "`file'"
		}
	}
	
	// bcos of insob 1, we need to drop those blanks
	drop if missing(errorMessage) & missing(error_flag)
	
	sort id00 interview__key interview__id  Estab_number EstablishmentName  EnumeratorName  section errorCheck  errorMessage
	
	decode(interview__status) , gen(interview__status_new)
	drop interview__status
	ren interview__status_new interview__status 
	
// 	insobs 1
	
	save "$reportsDir\errorFiles\err_dta_Merge\ibes_ii mergedErrs.dta", replace

// END OF APPENDING VARIOUS ERROR DTA FILES
*------------------------------------------------------

// filter to DQM assigned data
// getM and Rections here

// Calculate progress percentage
    local progress = 100
    // Write progress to a file
    file open progfile using "$tempsaveDir\progress.txt", write text replace
    file write progfile "`progress'"
	file close progfile
	
*****Getting Interviewers who worked
//use "$rootDir\HQData\interview__diagnostics.dta", clear

/*use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear

merge m:1 interview__id using "$HQData\interview__diagnostics.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge







	