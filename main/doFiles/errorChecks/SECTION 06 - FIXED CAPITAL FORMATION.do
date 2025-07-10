//  use "C:\2025IBESMAIN\Data\prep\sectionData\section_06 FIXED CAPITAL FORMATION Roster.dta" , clear
 
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear


*
merge 1:m interview__id using "$HQData\s6r1_fixed_capital.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge


* is Any Sector *  //checks that applies to all sectors and has passed any of the Eligibilities*
// gl isAnySector (canStartInterv & canAnsBusQues & inrange(ids01,1,9))
gl isAnySector ((s00a_q09a == 1 | s00a_q09b == 1 | s00a_q09c==1 ) & (s00a_q10a == 1 | s00a_q10b == 1 | s00a_q10c == 1) & inrange(qtype,1,9))
 

************************************************
* Check for LIST THE VARIOUS ASSET (s6q1) errors
************************************************
* 1. Check for missing responses
gl invalidassetmissing ($isAnySector & missing(s6q1))

* 2. Check if "TOTAL" (any case) is included
* Improved to handle cases where TOTAL might be part of another word (e.g., "TOTALITY")
gl totalmissing ($isAnySector & !regexm(upper(s6q1), "TOTAL($|\|)") & !missing(s6q1))

* Apply all checks
replace section = "Section 06" if $invalidassetmissing | $totalmissing 
replace error_flag = 1 if $invalidassetmissing | $totalmissing 

* Set appropriate error messages
replace errorCheck = cond($invalidassetmissing, "Missing response", ///
                       "'TOTAL' not found") ///
                    if $invalidassetmissing | $totalmissing 

replace errorMessag = cond($invalidassetmissing, ///
                       "Que. 1: Asset list cannot be blank", ///
                       "Que. 1: 'TOTAL' must be included as a separate asset item") ///
                    if $invalidassetmissing | $totalmissing

* Save only error cases (with improved handling of empty datasets)

keep if error_flag == 1
if _N > 0 {
    insobs 1
    drop error_flag
    save "$error_report\Section6_Q1_assetlist_invalid.dta", replace
}


**************************
*Question 1a, first check 
**************************


//
//
// **************************************
// *Question , second check 
// **************************************
// * Error checks for s6r1q0 (18 response categories + 99=Other + 100=TOTAL)
// * Requirements:
// *   1. No missing responses
// *   2. Code 100 (TOTAL) must be present exactly once
//
// * Step 1: Check for missing responses
// gen missing_response = missing(s6r1q0)
//
// * Step 2: Check for presence and uniqueness of TOTAL (code 100)
// bysort interview__id interview__key: egen total_count = total(s6r1q0 == 100)
// gen total_missing = (total_count == 0)
// gen total_duplicate = (total_count > 1)
//
// * Define error conditions
// gl invalid_s6r1q0_missing ($Anysector & missing_response == 1)
// gl invalid_s6r1q0_nototal ($Anysector & total_missing == 1)
// gl invalid_s6r1q0_duptotal ($Anysector & total_duplicate == 1)
//
// * Apply error flags and messages
// * 1. Check for missing responses
// replace section = "Section 06" if $invalid_s6r1q0_missing
// replace error_flag = 1 if $invalid_s6r1q0_missing
// replace errorCheck = "Missing response" if $invalid_s6r1q0_missing
// replace errorMessag = "Que.0: Response cannot be blank" if $invalid_s6r1q0_missing
//
// * 2. Check for missing TOTAL
// replace section = "Section 06" if $invalid_s6r1q0_nototal & error_flag == 0
// replace error_flag = 1 if $invalid_s6r1q0_nototal & error_flag == 0
// replace errorCheck = "TOTAL missing" if $invalid_s6r1q0_nototal
// replace errorMessag = "Que.0: Code 100 (TOTAL) must be included exactly once" if $invalid_s6r1q0_nototal
//
// * 3. Check for duplicate TOTAL
// replace section = "Section 06" if $invalid_s6r1q0_duptotal & error_flag == 0
// replace error_flag = 1 if $invalid_s6r1q0_duptotal & error_flag == 0
// replace errorCheck = "Duplicate TOTAL" if $invalid_s6r1q0_duptotal
// replace errorMessag = "Que.0: Code 100 (TOTAL) can only appear once" if $invalid_s6r1q0_duptotal
//
// * Clean up temporary variables
// drop missing_response total_count total_missing total_duplicate
//
// * Save error report
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section6_R1Q0_response_errors.dta", replace
//
//
// **************************************
// *Question 1a, first check 
// **************************************
//
//
//
//
//
// ***********************************
// *Question 1a,s6r1q1a second check
// ***********************************
//
// * Error checks for s6r1q1a (Book value availability)
// * Requirements:
// *   1. No missing responses (must be 1 or 2)
// *   2. Should only be answered when s6r1q0!=100
//
// * Step 1: Check for missing or invalid responses
// gen invalid_response = !inlist(s6r1q1a, 1, 2) & !missing(s6r1q1a)
// gen missing_response = missing(s6r1q1a)
//
// * Step 2: Check if answered when s6r1q0==100 (shouldn't be)
// gen answered_when_total = (s6r1q0 == 100) & !missing(s6r1q1a)
//
// * Define error conditions
// gl invalid_s6r1q1a_missing ($Anysector & missing_response == 1 & s6r1q0 != 100)
// gl invalid_s6r1q1a ($Anysector & invalid_response == 1 & s6r1q0 != 100)
// gl invalid_s6r1q1a_total ($Anysector & answered_when_total == 1)
//
// * Apply error flags and messages
// * 1. Check for missing responses (when required)
// replace section = "Section 06" if $invalid_s6r1q1a_missing
// replace error_flag = 1 if $invalid_s6r1q1a_missing
// replace errorCheck = "Missing response" if $invalid_s6r1q1a_missing
// replace errorMessag = "Que.1a: Book value response cannot be blank for non-TOTAL assets" if $invalid_s6r1q1a_missing
//
// * 2. Check for invalid responses (when required)
// replace section = "Section 06" if $invalid_s6r1q1a_invalid & error_flag == 0
// replace error_flag = 1 if $invalid_s6r1q1a_invalid & error_flag == 0
// replace errorCheck = "Invalid response" if $invalid_s6r1q1a_invalid
// replace errorMessag = "Que.1a: Response must be 1 (Yes) or 2 (No)" if $invalid_s6r1q1a_invalid
//
// * 3. Check if answered for TOTAL (shouldn't be)
// replace section = "Section 06" if $invalid_s6r1q1a_total & error_flag == 0
// replace error_flag = 1 if $invalid_s6r1q1a_total & error_flag == 0
// replace errorCheck = "Answered for TOTAL" if $invalid_s6r1q1a_total
// replace errorMessag = "Que.1a: Should not be answered when code is 100 (TOTAL)" if $invalid_s6r1q1a_total
//
// * Clean up temporary variables
// drop invalid_response missing_response answered_when_total
//
// * Save error report
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section6_R1Q1a_errors.dta", replace
//
//
//
