// define global error vars
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gen section = ""
gen errorCheck = ""
gen errorMessage = ""
gen error_flag =.

save "$prepData\ibes_ii Estabs valid_dateCase_only.dta", replace


* Eligibilities *
gl canAnsBusQues (s00a_q09a == 1 | s00a_q09b == 1 | s00a_q09c==1 ) //  ABLE TO ANSWER QUESTIONS CONCERNING THE BUSINESS ACTIVITIES OF THIS ESTABLISHMENT in any of the three tries
gl canStartInterv (s00a_q10a == 1 | s00a_q10b == 1 | s00a_q10c == 1) // ABLE to start interview is Yes in any of the three tries

* is Any Sector *  //checks that applies to all sectors and has passed any of the Eligibilities*
// gl isAnySector (canStartInterv & canAnsBusQues & inrange(ids01,1,9))
gl isAnySector ((s00a_q09a == 1 | s00a_q09b == 1 | s00a_q09c==1 ) & (s00a_q10a == 1 | s00a_q10b == 1 | s00a_q10c == 1) & inrange(qtype,1,9))

gl startInterviewVars (s00a_q09a s00a_q09b s00a_q09c s00a_q10a s00a_q10b s00a_q10c)
gl metaDataVars (interview__key interview__id id00 Sub_Sector EstablishmentName qtype error_flag section errorCheck errorMessage)

* SECTION 0A: INTERVIEW COVERPAGE *
***********************************
do "$do_file_errorSectionChecks_loc\SECTION 0A - INTERVIEW COVERPAGE.do" 


* SECTION 1: IDENTIFICATION AND CLASSIFICATION INFORMATION *
************************************************************
* needs re-work
do "$do_file_errorSectionChecks_loc\SECTION 01 - IDENTIFICATION AND CLASSIFICATION INFORMATION.do" 


* SECTION 2 - EMPLOYMENT AND EARNINGS  *
****************************************
do "$do_file_errorSectionChecks_loc\SECTION 02 - EMPLOYMENT AND EARNINGS.do" 


* SECTION 3: BUSINESS CHALLENGES AND OPPORTUNITIES  *
*****************************************************
do "$do_file_errorSectionChecks_loc\SECTION 03 - BUSINESS CHALLENGES AND OPPORTUNITIES.do" 

// // Calculate progress percentage
//     local progress = 30
//     // Write progress to a file
//     file open progfile using "$tempsaveDir\progress.txt", write text replace
//     file write progfile "`progress'"
// 	file close progfile
* SECTION 05 : STOCKS  *
*****************************************************
//do "$do_file_errorSectionChecks_loc\SECTION 05 - STOCKS.do" 


* SECTION 06 : FIXED CAPITAL FORMATION  *
*****************************************************
do "$do_file_errorSectionChecks_loc\SECTION 06 - FIXED CAPITAL FORMATION.do" 


* SECTION 07 : INPUT COSTS *
*****************************************************
do "$do_file_errorSectionChecks_loc\SECTION 07 - INPUT COSTS.do"

// Calculate progress percentage
 /*   local progress = 50
    // Write progress to a file
    file open progfile using "$tempsaveDir\progress.txt", write text replace
    file write progfile "`progress'"
	file close progfile  */

* SECTION 09 : PRODUCT INNOVATION *
*****************************************************
do "$do_file_errorSectionChecks_loc\SECTION 09 - PRODUCT INNOVATION.do"
//
//
// * SECTION 10: PROCESS INNOVATION *
// *****************************************************
// do "$do_file_errorSectionChecks_loc\SECTION 10 - PROCESS INNOVATION.do"
//
//
// * SECTION 11: INNOVATION ACTIVITIES *
// *****************************************************
// do "$do_file_errorSectionChecks_loc\SECTION 11 -  INNOVATION ACTIVITIES.do"
//
//
//
// * SECTION 13 : FIRM LEVEL CAPABILITIES, TRUST AND INTERACTION  *
// *****************************************************
// do "$do_file_errorSectionChecks_loc\SECTION 13 - FIRM LEVEL CAPABILITIES, TRUST AND INTERACTION.do"


 
* SECTION 4: BUSINESS OPERATIONS

* SECTION 8: SALES AND OTHER RECEIPTS OF THIS ESTABLISHMENT
* SECTION 8: OUTPUT OF THIS ESTABLISHMENT
* SECTION 8: REVENUE
 
* SECTION 12: RESEARCH AND DEVELOPMENT (R&D)
* SECTION 14: ENVIRONMENTAL GOODS AND SERVICES (ALL SECTORS)
//do "$do_file_errorSectionChecks_loc\SECTION 14 - ENVIRONMENTAL GOODS AND SERVICES.do"


// Calculate progress percentage
    local progress = 90
    // Write progress to a file
    file open progfile using "$tempsaveDir\progress.txt", write text replace
    file write progfile "`progress'"
	file close progfile