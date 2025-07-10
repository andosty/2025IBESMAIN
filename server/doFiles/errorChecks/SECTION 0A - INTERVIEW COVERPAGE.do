*==================================
* SECTION 0A: INTERVIEW COVERPAGE 
*==================================


************************
*Question 9a first check
************************
*Sec 0A.9a, Answers to Establishment Question cannot be blank
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl blankAnsEstablishmentQues (missing(s00a_q09a))  

replace section = "Section 0A" if $blankAnsEstablishmentQues
replace error_flag = 1 if $blankAnsEstablishmentQues
replace errorCheck = "Missing Check"  if $blankAnsEstablishmentQues
replace errorMessage = "Que. 9a,First-Attempt, Are you able to answer Ques concerning the business cannot be blank" if $blankAnsEstablishmentQues

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q09a1.dta", replace
// restore

**************************
*Question 9a second check
**************************
*Sec 0A.9a, start interview is invalid if not Yes or No
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl InvalidAnsEstablishmentQues (!missing(s00a_q09a) & !inlist(s00a_q09a, 1,2))  // response exist But not Yes (1) or No (2)

replace section = "Section 0A" if $InvalidAnsEstablishmentQues
replace error_flag = 1 if $InvalidAnsEstablishmentQues
replace errorCheck = "invalid response"  if $InvalidAnsEstablishmentQues
replace errorMessage = "Que. 9a, First-Attempt, response provided for ='" + string(s00a_q09a) + "' is invalid" if $InvalidAnsEstablishmentQues

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q09a2.dta", replace
// restore

************************
*Question 9b first check
************************
*Sec 0A.9b, Answer Establishment Question cannot be blank
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl blankAnsEstablishmentQues ((s00a_q09a == 2 & !missing(s00a_q11a) | (s00a_q09a == 1 & s00a_q10a == 2 & !missing(s00a_q11a))) & missing(s00a_q09b))  

replace section = "Section 0A" if $blankAnsEstablishmentQues
replace error_flag = 1 if $blankAnsEstablishmentQues
replace errorCheck = "Missing Check"  if $blankAnsEstablishmentQues
replace errorMessage = "Que. 9b, Second-Attempt, Are you able to answer Ques concerning the business cannot be blank if didn't start on First-Attempt" if $blankAnsEstablishmentQues

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q09b1.dta", replace
// restore

**************************
*Question 9b second check
**************************
*Sec 0A.9b, start interview is invalid if not Yes or No
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl InvalidAnsEstablishmentQues ( ///
    (s00a_q09a == 2 & !missing(s00a_q11a)) | /// 
    (s00a_q09a == 1 & s00a_q10a == 2 & !missing(s00a_q11a)) ) & ///
!missing(s00a_q09b) & !inlist(s00a_q09b, 1, 2)   // response exist But not Yes (1) or No (2)
 
replace section = "Section 0A" if $InvalidAnsEstablishmentQues
replace error_flag = 1 if $InvalidAnsEstablishmentQues
replace errorCheck = "invalid response"  if $InvalidAnsEstablishmentQues
replace errorMessage = "Que. 9b, Second-Attempt, response provided for ='" + string(s00a_q09b) + "' is invalid" if $InvalidAnsEstablishmentQues

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q09b2.dta", replace
// restore

************************
*Question 9c first check
************************
*Sec 0A.9b, Answer Establishment Question cannot be blank
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl blankAnsEstablishmentQues ((s00a_q09b == 2 & !missing(s00a_q11b) | (s00a_q09b == 1 & s00a_q10a == 2 & !missing(s00a_q11b))) & missing(s00a_q09c)) 

replace section = "Section 0A" if $blankAnsEstablishmentQues
replace error_flag = 1 if $blankAnsEstablishmentQues
replace errorCheck = "Missing Check"  if $blankAnsEstablishmentQues
replace errorMessage = "Que. 9c,Third-Attempt, Are you able to answer Ques concerning the business cannot be blank if didn't start on Second-Attempt" if $blankAnsEstablishmentQues

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q09c1.dta", replace
// restore

**************************
*Question 9c second check
**************************
*Sec 0A.9b, start interview is invalid if not Yes or No
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl InvalidAnsEstablishmentQues ( ///
    (s00a_q09b == 2 & !missing(s00a_q11b)) | (s00a_q09b == 1 & s00a_q10b == 2 & !missing(s00a_q11b))  ) & ///
!missing(s00a_q09c) & !inlist(s00a_q09c, 1, 2)   // response exist But not valid (1=Yes, 2=No)

replace section = "Section 0A" if $InvalidAnsEstablishmentQues
replace error_flag = 1 if $InvalidAnsEstablishmentQues
replace errorCheck = "invalid response"  if $InvalidAnsEstablishmentQues
replace errorMessage = "Que. 9c,Third-Attempt, response provided for ='" + string(s00a_q09c) + "' is invalid" if $InvalidAnsEstablishmentQues

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q09c2.dta", replace
// restore


************************
*Question 8a first 
************************
*Sec 0A.8a,Start interview Date and Time cannot be blank
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl blankinterviewDate_Time (missing(s00a_q08a) )

replace section = "Section 0A" if $blankinterviewDate_Time
replace error_flag = 1 if $blankinterviewDate_Time
replace errorCheck = "Missing Check"  if $blankinterviewDate_Time
replace errorMessage = "Que. 8a, First-Attempt Start interview Date and Time cannot be blank" if $blankinterviewDate_Time

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q08a.dta", replace
// restore


************************
*Question 8b first check
************************
*Sec 0A.8b,Start interview Date and Time cannot be blank
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl blankinterviewDate_Time ((s00a_q09a == 2 & !missing(s00a_q11a) | (s00a_q09a == 1 & s00a_q10a == 2 & !missing(s00a_q11a))) & missing(s00a_q08b))

replace section = "Section 0A" if $blankinterviewDate_Time
replace error_flag = 1 if $blankinterviewDate_Time
replace errorCheck = "Missing Check"  if $blankinterviewDate_Time
replace errorMessage = "Que. 8b, Second-Attempt Start interview Date and Time cannot be blank" if $blankinterviewDate_Time

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q08b.dta", replace
// restore


************************
*Question 8c first check
************************
*Sec 0A.8a,Start interview Date and Time cannot be blank
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl blankinterviewDate_Time ((s00a_q09b == 2 & !missing(s00a_q11b) | (s00a_q09a == 1 & s00a_q10b == 2 & !missing(s00a_q11b))) & missing(s00a_q08c))

replace section = "Section 0A" if $blankinterviewDate_Time
replace error_flag = 1 if $blankinterviewDate_Time
replace errorCheck = "Missing Check"  if $blankinterviewDate_Time
replace errorMessage = "Que. 8c, Third-Attempt Start interview Date and Time cannot be blank" if $blankinterviewDate_Time

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q08c.dta", replace
// restore


*************************
*Question 10a first check
************************
*Sec 0A.10a, start the interview cannot be blank
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl blankstartinterview (!missing(s00a_q09a) & s00a_q09a == 1 & missing(s00a_q10a))

replace section = "Section 0A" if $blankstartinterview
replace error_flag = 1 if $blankstartinterview
replace errorCheck = "Missing Check"  if $blankstartinterview
replace errorMessage = "Que. 10a, First-Attempt, Is it possible to start the interview cannot be blank" if $blankstartinterview

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q10a1.dta", replace
// restore

**************************
*Question 10a second check
**************************
*Sec 0A.10a, start interview is invalid if not Yes or No
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl invalidstartinterview (s00a_q09a == 1 & !missing(s00a_q10a) & !inlist(s00a_q10a, 1,2))

replace section = "Section 0A" if $invalidstartinterview
replace error_flag = 1 if $invalidstartinterview
replace errorCheck = "invalid response"  if $invalidstartinterview
replace errorMessage = "Que. 10a, First-Attempt, response provided for ='" + string(s00a_q10a) + "' is invalid" if $invalidstartinterview

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q10a2.dta", replace
// restore

*************************
*Question 10b first check
************************
*Sec 0A.10b, start the interview cannot be blank
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl blankstartinterview (!missing(s00a_q09b) & s00a_q09b == 1 & missing(s00a_q10b))

replace section = "Section 0A" if $blankstartinterview
replace error_flag = 1 if $blankstartinterview
replace errorCheck = "Missing Check"  if $blankstartinterview
replace errorMessage = "Que. 10b, second-Attempt, Is it possible to start the interview cannot be blank if didn't start on First-Attempt'" if $blankstartinterview

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q10b1.dta", replace
// restore

**************************
*Question 10b second check
**************************
*Sec 0A.10b, start interview is invalid if not Yes or No
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl invalidstartinterview (s00a_q09b == 1 & !missing(s00a_q10b) & !inlist(s00a_q10b, 1,2))

replace section = "Section 0A" if $invalidstartinterview
replace error_flag = 1 if $invalidstartinterview
replace errorCheck = "invalid response"  if $invalidstartinterview
replace errorMessage = "Que. 10b, second-Attempt, response provided for ='" + string(s00a_q10b) + "' is invalid" if $invalidstartinterview

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q10b2.dta", replace
// restore

*************************
*Question 10c first check
************************
*Sec 0A.10c, start the interview cannot be blank
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl blankstartinterview (!missing(s00a_q09c) & s00a_q09c == 1 & missing(s00a_q10c))

replace section = "Section 0A" if $blankstartinterview
replace error_flag = 1 if $blankstartinterview
replace errorCheck = "Missing Check"  if $blankstartinterview
replace errorMessage = "Que. 10c, Third-Attempt, Is it possible to start the interview cannot be blank if didn't start on the second-Attempt'" if $blankstartinterview

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q10c1.dta", replace
// restore

**************************
*Question 10c second check
**************************
*Sec 0A.10c, start interview is invalid if not Yes or No
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl invalidstartinterview (s00a_q09c == 1 & !missing(s00a_q10c) & !inlist(s00a_q10c, 1,2))

replace section = "Section 0A" if $invalidstartinterview
replace error_flag = 1 if $invalidstartinterview
replace errorCheck = "invalid response"  if $invalidstartinterview
replace errorMessage = "Que. 10c, Third-Attempt, response provided for ='" + string(s00a_q10c) + "' is invalid" if $invalidstartinterview

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q10c2.dta", replace
// restore

*************************
*Question 11abc First Check 
*************************
*Sec 0A.11abc, Reason why the establishment cannot be interviewed cannot be blank
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

foreach pair in a b c {

    * Assign appropriate attempt label
    if "`pair'" == "a" {
        local attempt_label "First-Attempt: Reason why the establishment cannot be interviewed cannot be blank"
    }
    else if "`pair'" == "b" {
        local attempt_label "Second-Attempt: Reason why the establishment cannot be interviewed cannot be blank if didn't start on First-attempt"
    }
    else if "`pair'" == "c" {
        local attempt_label "Third-Attempt: Reason why the establishment cannot be interviewed cannot be blank if didn't start on Second-attempt"
    }

    * Define global macro for error condition
    gl reasonNotStartInterview (s00a_q09`pair' == 1 & s00a_q10`pair' == 2 & missing(s00a_q11`pair')) | ///
                                 (s00a_q09`pair' == 2 & missing(s00a_q11`pair'))

    replace section = "Section 0A" if $reasonNotStartInterview
    replace error_flag = 1 if $reasonNotStartInterview
    replace errorCheck = "Missing Check " if $reasonNotStartInterview
    replace errorMessage = "Que. 11`pair', `attempt_label'" if $reasonNotStartInterview
}

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q11abc1.dta", replace
// restore


**************************
*Question 11abc second check
**************************
*Sec 0A.11abc, Reason why the establishment cannot be interviewed is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

capture program drop decode_yesno //  Define programs for label decoding

program define decode_yesno
    args var var_label
    capture decode `var', gen(`var_label')
    if _rc {
        gen `var_label' = cond(`var' == 1, "Yes", cond(`var' == 2, "No", string(`var')))
    }
end

capture program drop decode_reason
program define decode_reason
    args var var_label
    capture decode `var', gen(`var_label')
    if _rc {
        gen `var_label' = ""
        replace `var_label' = "POTENTIAL REFUSAL" if `var' == 1
        replace `var_label' = "NO COMPETENT RESPONDENT" if `var' == 2
        replace `var_label' = "NONE AT ESTABLISHMENT" if `var' == 3
        replace `var_label' = "MOVED TO ANOTHER LOCATION" if `var' == 4
        replace `var_label' = "MOVED TO NEIGHBORING COUNTRY" if `var' == 5
        replace `var_label' = "MOVED TO UNKNOWN LOCATION" if `var' == 6
        replace `var_label' = "ESTABLISHMENT NOT FOUND" if `var' == 7
        replace `var_label' = "ESTABLISHMENT CLOSED DOWN" if `var' == 8
    }
end

foreach pair in a b c {
    
    tempvar q09`pair'_label q11`pair'_label // Generate temporary variable names
    
    
    decode_yesno s00a_q09`pair' `q09`pair'_label' //  Decode labels
    decode_reason s00a_q11`pair' `q11`pair'_label'

    * Define and apply error conditions
    gl reasonCannotStartInterview (s00a_q09`pair' == 1 & s00a_q10`pair' == 2 & !missing(s00a_q11`pair') & inrange(s00a_q11`pair', 2, 8))
    
    replace section = "Section 0A" if $reasonCannotStartInterview
    replace error_flag = 1 if $reasonCannotStartInterview
    replace errorCheck = "Reason Cannot Start Interview (Q11`pair')" if $reasonCannotStartInterview
    replace errorMessage = "Q11`pair'. Reason='" + `q11`pair'_label' + "' is inconsistent with response Q9`pair'='" + `q09`pair'_label' + "'" if$reasonCannotStartInterview
}

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q11abc2.dta", replace
// restore


************************************
*Question 11abc_oth first check
************************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

foreach pair in a b c {
    
    * Define full variable references for each pair
    local q09 = "s00a_q09`pair'"
    local q10 = "s00a_q10`pair'"
    local q11 = "s00a_q11`pair'"
    local q11oth = "s00a_q11oth_`pair'"

    * Assign attempt-specific error message
    if "`pair'" == "a" {
        local errormsg "Que. 11aoth, First-Attempt: Other_specify for Reason why the establishment cannot be interviewed cannot be blank"
    }
    else if "`pair'" == "b" {
        local errormsg "Que. 11both, Second-Attempt: Other_specify for Reason why the establishment cannot be interviewed cannot be blank if didn't start on First-attempt"
    }
    else if "`pair'" == "c" {
        local errormsg "Que. 11coth, Third-Attempt: Other_specify for Reason why the establishment cannot be interviewed cannot be blank if didn't start on Second-attempt"
    }

    * Define the condition as a global macro
    gl StartInterview_oth_blank (`q09' == 1 & `q10' == 2 & `q11' == 99 & missing(`q11oth')) | ///
                                 (`q09' == 2 & `q11' == 99 & missing(`q11oth'))

    replace section = "Section 0A" if $StartInterview_oth_blank
    replace error_flag = 1 if $StartInterview_oth_blank
    replace errorCheck = "Missing Check (Q11`pair'_oth)" if $StartInterview_oth_blank
    replace errorMessage = "`errormsg'" if $StartInterview_oth_blank
}

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q11abc_oth_1.dta", replace
// restore


************************************
* Question 11abc_oth second check
************************************
* Sec 0A.11abcoth, Other_specify for Reason why the establishment cannot be interviewed is already preloaded

use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

foreach pair in a b c {
    
    local q09    = "s00a_q09`pair'"
    local q10    = "s00a_q10`pair'"
    local q11    = "s00a_q11`pair'"
    local q11oth = "s00a_q11oth_`pair'"

gen otherspec_s00a_q11oth_`pair' = ((`q09' == 1 & `q10' == 2 & `q11' == 99) | (`q09' == 2 & `q11' == 99)) & ///
        regexm(lower(`q11oth'), ///
        "potential refusal|refus|unwill|declin|not interest|deny|reject|no participat|" + ///
        "no competent respondent at time of the visit|no owner|no manager|no staff|no one to talk|" + ///
        "none at establishment for an extended amount of time|long time|extended|months no one|owner travel|" + ///
        "establishment moved to another village/town/district|relocat|moved to [town]|new address|different district|" + ///
        "establishment moved to a neighboring country|moved abroad|overseas|another country|emigrat|" + ///
        "establishment moved to unknown location|unknown where|no idea where|no trace|disappear|" + ///
        "establishment not found|not exist|demolish|wrong address|gps wrong|no shop|cannot locate|" + ///
        "wrong gps at a different electrical shop|gps brought me to a different establishment|road construct|" + ///
        "establishment closed down|permanently clos|shut down|no longer operat|bankrupt|out of business|" + ///
        "establishment operated for only 2 months in 2023|" + ///
        "the shop is closed for the day|shop closed temporarily because the owner is said to be bereaved|" + ///
        "shopowner was not around at the time of visit|not around|absent|away today|closed temp|temporarily|bereav|sick")
		
		 * Assign custom error message per attempt
    local attempt_msg = cond("`pair'" == "a", "First-Attempt", ///
                        cond("`pair'" == "b", "Second-Attempt", "Third-Attempt"))

    * Apply error info for flagged rows
    replace section = "Section 0A" if otherspec_s00a_q11oth_`pair' == 1
    replace error_flag = 1 if otherspec_s00a_q11oth_`pair' == 1
    replace errorCheck = "Reason specified is already preloaded in (Q11`pair')" if otherspec_s00a_q11oth_`pair' == 1
  replace errorMessage = ///
			"Que. 11`pair'oth, `attempt_msg': Other_specify reason '" + `q11oth' + "' is already preloaded in the options" if otherspec_s00a_q11oth_`pair' == 1

}

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q11abc_oth_2.dta", replace
// restore

******************************			   
* Question 12 Location of Interview first check
******************************
*Sec 0A.12,  Location of Interview cannot be blank
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl blankinterviewlocation ($isAnySector & missing(s00a_q12))
replace section = "Section 0A" if $blankinterviewlocation
replace error_flag = 1 if $blankinterviewlocation
replace errorCheck = "Missing Check"  if $blankinterviewlocation
replace errorMessage = "Que. 12, location of interview cannot be blank" if $blankinterviewlocation

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q12a.dta", replace
// restore

******************************			   
* Question 12 Location of Interview second check
******************************
*Sec 0A.12,  invalid response for Location of Interview 
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl invalidinterviewlocation ($isAnySector & !missing(s00a_q12) & !inlist(s00a_q12, 1,2,99))
replace section = "Section 0A" if $invalidinterviewlocation
replace error_flag = 1 if $invalidinterviewlocation
replace errorCheck = "invalid response"  if $invalidinterviewlocation
replace errorMessage = "Que. 12, location of interview cannot be blank" if $invalidinterviewlocation

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q12b.dta", replace
// restore


******************************			   
* Question 12oth Location of Interview first check
******************************
*Sec 0A.12oth,  Location of Interview cannot be blank
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl blankinterviewlocation_oth ($isAnySector & !missing(s00a_q12) & s00a_q12 == 99 & missing(s00a_q12oth))

replace section = "Section 0A" if $blankinterviewlocation_oth
replace error_flag = 1 if $blankinterviewlocation_oth
replace errorCheck = "invalid response"  if $blankinterviewlocation_oth
replace errorMessage = "Que. 12(oth), location of interview cannot be blank" if $blankinterviewlocation_oth

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q12(oth)a.dta", replace
// restore


******************************			   
* Question 12oth Location of Interview second check
******************************
*Sec 0A.12oth, Location of Interview is already preloaded
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

*Other Specify Check - Preloaded option
local interview_loc_predefined "establishment|annex|office|business|small shop|sole|office|Primary|location|Adjacent facility|Facility|Factory" ///
"site|Principal|Central|Head quarters|Branch|Secondary|Satellite|Extension|Annex|building|kiosk|own store|store|container|Support office|Auxiliary"

gl preloaded_otherSpec_s00a_q12oth ($isAnySector & !missing(s00a_q12) & s00a_q12 == 99 & !missing(s00a_q12oth) & regex(lower(s00a_q12oth),"`interview_loc_predefined'"))

replace section = "Section 0A" if $preloaded_otherSpec_s00a_q12oth
replace error_flag = 1 if $preloaded_otherSpec_s00a_q12oth
replace errorCheck = "Other-specify Interview Loc" if $preloaded_otherSpec_s00a_q12oth
replace errorMessage = "Que.12(oth), Other-specified interview location ='" + s00a_q12oth + ///
					   "', is part of the preloaded option" if $preloaded_otherSpec_s00a_q12oth

//save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section0A_q12(oth)b.dta", replace
// restore
					   

******************************			   
* Question 13 GPS coordinates of the interview location - first check
******************************
*Sec 0A.13, Blank GPS coordinates of the interview location 

use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl blankGpsAccuracy ($isAnySector & (missing(s00a_q13__Latitude) | missing(s00a_q13__Longitude) | missing(s00a_q13__Accuracy) | ///
						missing(s00a_q13__Altitude)  | missing(s00a_q13__Timestamp) )) 

replace error_flag = 1 if $blankGpsAccuracy
replace section = "Section 0A" if $blankGpsAccuracy
replace errorCheck = "GPS Cordinate location" if $blankGpsAccuracy
replace errorMessage = "Que.13, GPS coordinates of the interview location cannot be blank " if $blankGpsAccuracy

//save the dataset
keep if error_flag == 1
insobs 1
save "$error_report\Section0A_q13a.dta", replace
// restore


******************************			   
* Question 13 GPS coordinates of the interview location - second check
******************************
*Sec 0A.13, invalid GPS coordinates of the interview location (GPS accuracy > 5)

use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl badGpsAccuracy ($isAnySector & !missing(s00a_q13__Accuracy) & s00a_q13__Accuracy > 5)

replace error_flag = 1 if $badGpsAccuracy
replace section = "Section 0A" if $badGpsAccuracy
replace errorCheck = "GPS Accuracy" if $badGpsAccuracy
replace errorMessage = "Que.13, GPS accuracy ='" + string(s00a_q13__Accuracy) + "metres' is weak. Move to a less shady area & Retake your GPS, " if $badGpsAccuracy
	
	//save the dataset
keep if error_flag == 1
insobs 1
save "$error_report\Section0A_q13b.dta", replace
// restore

*section 0A Done
*-----------------------------------------------------------------------------------------------------------------