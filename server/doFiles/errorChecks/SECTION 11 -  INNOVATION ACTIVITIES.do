* SECTION 10: INNOVATION ACTIVITIES
* --------------------------------
gl errorDataVars (section errorCheck errorMessage)		
gl firmIsCurrentlyManufacturing ( $isAnySector & s1qso2 == 3) //current sector is using the manufacturing Questionnaire

gl InnovActivityVars s10q1 s10q2 s10q3 s10q4 s10q5 s10q6 s10q7
 
* process invocation implementation objective vars
gl InnovImplObj_vars s9q5 s9q6 s9q7 s9q8 s9q9 s9q10 s9q11 
* process invocation implementation objective achievement vars
gl InnovImplAch_vars s9q5b s9q6b s9q7b s9q8b s9q9b s9q10b s9q11b
 

// -----------------------------------------------------------------------------------
* Check 1 ,CHeck if firm has innovation activity Q1 Cells are Missing or has invalid values for Manufacturing Questionnaire
*********************************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
gl innovActivityAnsBlank (missing(value)) 
gl innovActivityAnsInvalid (!missing(value) & !inrange(value,1,3)) 

gl innovActivity_invalid_resp ($innovActivityAnsBlank | $innovActivityAnsInvalid)

keep if $firmIsCurrentlyManufacturing
// keep $metaDataVars $errorDataVars $startInterviewVars $InnovActivityVars

generate id = _n
reshape long s10q, i(id) j(innov_Activity) 
gen varLetter = char(64 + innov_Activity) if inrange(innov_Activity, 1, 26)
drop innov_Activity
gen innov_ActivityQue = "1.InnovActivity.(" + varLetter + ")."
ren s10q value

drop if missing(id00)

replace error_flag = 1 if $innovActivity_invalid_resp
keep if error_flag == 1
replace section = "Section 11" if $innovActivity_invalid_resp
replace errorCheck = "Invalid Response" if $innovActivityAnsBlank
replace errorMessage =innov_ActivityQue +  " cannot be blank" if $innovActivityAnsBlank

replace errorMessage =innov_ActivityQue + " response ='" + string(value) + "' is invalid" if $innovActivityAnsInvalid

//save the dataset
keep if error_flag == 1 & !missing(id00)
// keep $metaDataVars $errorDataVars
insobs 1
save "$error_report\Section12_Q1_InnovActivity.dta", replace
// --------------------------------------------------------------------------


// // second check, if Q1 otherSpec is yes, check the other specified entry
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// keep if $firmIsCurrentlyManufacturing 
// // keep $metaDataVars $errorDataVars s10q7  /// firm has otherSpecified Activity var
//
// & s10q7==1  /// firm has otherSpecified Activity


// second third, checking expenditure estimates cannot be blank
// --------------------------------------------------------------------------
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
gl innovAct_ExpEst_vars s10q8 s10q9 s10q10 s10q11 s10q12  //Q2 expenditure estimate vars
gl missingExpValue (missing(value) | value < 0)
drop s8q1__0-s8q4c  // drop section 8 revenue vars

// manufacturing firm in implementing innovation
keep if $firmIsCurrentlyManufacturing 
drop $startInterviewVars
// keep $InnovActivityVars 

// // keep $metaDataVars  $errorDataVars $InnovImplementVars $InnovImplObj_vars $InnovImplAch_vars  

// get firms that has atleaast one of the innovation implementation as YES
gen isInnovActivity_Firm = 0  
foreach varname of global InnovActivityVars {
    replace isInnovActivity_Firm = 1 if `varname' == 1
}

// keep only innovation activity firms
keep if isInnovActivity_Firm==1

// show vars indicating where firm has innovation activity = Yes
gen InnovActivity_msg = ""

// generate innovation implementing firm variable indicator message
foreach varname of global InnovActivityVars {	 
replace InnovActivity_msg = InnovActivity_msg + "1.InnovActivity(" + char(64 + real(subinstr("`varname'", "s10q", "", .) )) + ")" + "='Yes', " if  !missing(`varname') & `varname' == 1   
}

// drop InnovActivityVars vars no longer needed, as they are now in the message
foreach oldVarName of global InnovActivityVars {
	drop `oldVarName'
}

// prefix rename , innovation implementation obective vars 
foreach objVar of global innovAct_ExpEst_vars {
    rename `objVar' exp_`objVar'
}

// check estimates required at Q2
generate id = _n
reshape long exp_s10q, i(id) j(innov_Activity) string
ren exp_s10q value

replace innov_Activity  = "2.InnovActExpenditure(" + char(64 + (real(innov_Activity)-7)) + ")" 

sort id innov_Activity

replace error_flag = 1 if missing(value) 
keep if error_flag == 1

replace section = "Section 11" if $missingExpValue
replace errorCheck = "Invalid Response" if $missingExpValue
replace errorMessage = innov_Activity + "' response is missing" +  " ." + InnovActivity_msg if $missingExpValue

// keep $metaDataVars $errorDataVars
insobs 1
save "$error_report\Section10_q2_expenditure.dta", replace


// gourth check, Q3,4 and 5 employeed hired during innovataion activity
// --------------------------------------------------------------------------
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// gl innovAct_ExpEst_vars s10q8 s10q9 s10q10 s10q11 s10q12  //Q2 expenditure estimate vars
// gl missingExpValue (missing(value) | value < 0)
drop s8q1__0-s8q4c  // drop section 8 revenue vars

// manufacturing firm in implementing innovation
keep if $firmIsCurrentlyManufacturing 
drop $startInterviewVars
// keep $InnovActivityVars 

// // keep $metaDataVars  $errorDataVars $InnovImplementVars $InnovImplObj_vars $InnovImplAch_vars  

// get firms that has atleaast one of the innovation implementation as YES
gen isInnovActivity_Firm = 0  
foreach varname of global InnovActivityVars {
    replace isInnovActivity_Firm = 1 if `varname' == 1
}

// keep only innovation activity firms
keep if isInnovActivity_Firm==1

// show vars indicating where firm has innovation activity = Yes
gen InnovActivity_msg = ""

// generate innovation implementing firm variable indicator message
foreach varname of global InnovActivityVars {	 
replace InnovActivity_msg = InnovActivity_msg + "1.InnovActivity(" + char(64 + real(subinstr("`varname'", "s10q", "", .) )) + ")" + "='Yes', " if  !missing(`varname') & `varname' == 1   
}

// drop InnovActivityVars vars no longer needed, as they are now in the message
foreach oldVarName of global InnovActivityVars {
	drop `oldVarName'
}

//
// stop
//
//
// gl invalidDetail_InnovObjDescr ($firmIsCurrentlyManufacturing & isInnovImplement_Firm==1 & (missing(s9q4) | wordcount(s9q4) < 2 | strlen(s9q4) < 4 )) 
//
// drop s8q1__0-s8q4c  // drop section 8 revenue vars
//
// // manufacturing firm in implementing innovation
// keep if $firmIsCurrentlyManufacturing 
//
// // get firms that has atleaast one of the innovation implementation as YES
// gen isInnovImplement_Firm = 0  
// foreach varname of global InnovImplementVars {
//     replace isInnovImplement_Firm = 1 if `varname' == 1
// }
//
// // keep only innovation implementation firms
// keep if isInnovImplement_Firm==1
//
// rename (s9q1 s9q2 s9q3 ) (firm_=)
// rename (s9q1b s9q2b s9q3b) (GhanaMkt_=)
// rename (s9q1c s9q2c s9q3c) (OutsideGH_=)
//
// // generate innovation implementing firm variable indicator message 
// unab newInnovImpVarlist  : OutsideGH* GhanaMkt* firm*
// global newInnovImpl_varList `newInnovImpVarlist'
//
// // show vars where firm has innovProcessImplement = Yes
// gen InnovImplement_msg = ""
//
// foreach varname of global newInnovImpl_varList {	 
//     replace InnovImplement_msg = InnovImplement_msg +subinstr("`varname'", "s9q", "Q", .) + "='Yes', " if  !missing(`varname') & `varname' == 1   
// }
//
// // keeep observations that are flagged with the error checks
// replace error_flag = 1 if $invalidDetail_InnovObjDescr
// keep if  error_flag == 1
//
// // genereate the error messages
// replace section = "Section 11" if $invalidDetail_InnovObjDescr
// replace errorCheck = "invalid response"		if $invalidDetail_InnovObjDescr
// replace errorMessage = "Q4. provided detailed firm's main process innovation ='" + s9q4 + "', is invalid" +  " ." + InnovImplement_msg if $invalidDetail_InnovObjDescr
//
// insobs 1
// // keep $metaDataVars $errorDataVars
// save "$error_report\Section10_q1_InvalidInnovationDescription.dta", replace 
