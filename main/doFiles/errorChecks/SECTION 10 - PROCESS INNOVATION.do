* SECTION 10: PROCESS INNOVATION
* --------------------------------


gl errorDataVars (section errorCheck errorMessage)		
gl firmIsCurrentlyManufacturing ( $isAnySector & s1qso2 == 3) //current sector is using the manufacturing Questionnaire

gl InnovImplementVars  s9q1 s9q2 s9q3  /// firm
 s9q1b s9q2b s9q3b  /// Ghanaian Market
 s9q1c s9q2c s9q3c   /// Outside Ghana
 
* process invocation implementation objective vars
gl InnovImplObj_vars s9q5 s9q6 s9q7 s9q8 s9q9 s9q10 s9q11 
* process invocation implementation objective achievement vars
gl InnovImplAch_vars s9q5b s9q6b s9q7b s9q8b s9q9b s9q10b s9q11b
 

// -----------------------------------------------------------------------------------
* Check 1 ,CHeck if Process Innovation Implementation Cells are Missing for MAnufacturing Questionnaire
*********************************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
gl processInnovQueAnsBlank (missing(value)) 
gl processInnovQueAnsInvalid (!missing(value) & !inrange(value,1,3)) 

gl missing_invalid_procInnoc ($processInnovQueAnsBlank | $processInnovQueAnsInvalid)

// IF Firm is Manufacturing, then Question on IF FIRM HAS INNOVATION CANNOT BE BLANK Sec9_Q1
drop s8q1__0-s8q4c  // drop section 8 revenue vars

keep if $firmIsCurrentlyManufacturing
// keep $metaDataVars $errorDataVars $startInterviewVars $InnovImplementVars

 
 rename (s9q*c ) (procInnoc_OutsideGH_=)
 rename (s9q*b ) (procInnoc_GhanaMkt_=)
 rename (s9q* ) (procInnoc_firm_=)

generate id = _n
// rename (procInnoc_*) (value=)
reshape long procInnoc_, i(id) j(varName) string
replace varName = subinstr(varName, "s9q", "Q", .)

ren procInnoc_ value

drop if missing(id00)

replace error_flag = 1 if $missing_invalid_procInnoc
keep if error_flag == 1
replace section = "Section 10" if $missing_invalid_procInnoc
replace errorCheck = "Invalid Response" if $processInnovQueAnsBlank
replace errorMessage ="Process Innovation - 1. INNOVATION, " + varName +  " cannot be blank" if $processInnovQueAnsBlank

replace errorMessage ="Process Innovation Que, " + varName +  " response ='" + string(value) + "' is invalid" if $processInnovQueAnsInvalid

//save the dataset
keep if error_flag == 1 & !missing(id00)
// keep $metaDataVars $errorDataVars
insobs 1
save "$error_report\Section10_q1_firm_ghMkt_Outside_missing.dta", replace
// --------------------------------------------------------------------------

// second check, an invalid process innovation implementation description such as blank or one-word ,Sec10_Q4 s9q4
// --------------------------------------------------------------------------
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
drop s8q1__0-s8q4c  // drop section 8 revenue vars

// manufacturing firm in implementing innovation
keep if $firmIsCurrentlyManufacturing 
drop $startInterviewVars

// keep $metaDataVars  $errorDataVars $InnovImplementVars $InnovImplObj_vars $InnovImplAch_vars  

// get firms that has atleaast one of the innovation implementation as YES
gen isInnovImplement_Firm = 0  
foreach varname of global InnovImplementVars {
    replace isInnovImplement_Firm = 1 if `varname' == 1
}

// keep only innovation implementation firms
keep if isInnovImplement_Firm==1

rename (s9q1 s9q2 s9q3 ) (firm_=)
rename (s9q1b s9q2b s9q3b) (GhanaMkt_=)
rename (s9q1c s9q2c s9q3c) (OutsideGH_=)
 
unab newInnovImpVarlist  : OutsideGH* GhanaMkt* firm*
global newInnovImpl_varList `newInnovImpVarlist'

// show vars indicating where firm has innovProcessImplement = Yes
gen InnovImplement_msg = ""

// generate innovation implementing firm variable indicator message
foreach varname of global newInnovImpl_varList {	 
    replace InnovImplement_msg = InnovImplement_msg +subinstr("`varname'", "s9q", "Q", .) + "='Yes', " if  !missing(`varname') & `varname' == 1   
}

// drop InnovImpl_varList no longer needed, as they are now in the message
foreach oldVarName of global newInnovImpl_varList {
	drop `oldVarName'
//     rename `oldVarName' hasProcInnov_`oldVarName'
}

// prefix rename , innovation implementation obective vars 
foreach objVar of global InnovImplObj_vars {
    rename `objVar' procInnovObj_`objVar'
}

//prefix rename , if achieved innovation implementation obective vars
foreach achievementVars of global InnovImplAch_vars {
    rename `achievementVars' procInnovAch_`achievementVars'
}

//pivote the data
generate id = _n
// rename (procInnoc_*) (value=)
reshape long procInnovObj_, i(id) j(varObj) string
reshape long procInnovAch_, i(id varObj) j(varAch)  string 

// keep objectives with each matching row achievement vars
keep if varObj == substr(varAch, 1, length(varAch) - 1)

// rename to match the question variable indicators
replace varObj = subinstr(varObj, "s9q", "", .)

destring (varObj), gen(numericObjVar)
gen varLetter = char(64 + (numericObjVar-4)) if inrange((numericObjVar-4), 1, 26)
gen quesVar = "Q2. INNOVATION " + varLetter + "."
replace varObj = quesVar
drop numericObjVar quesVar
replace varAch ="B"

gl missingObj_resp (missing(procInnovObj_) ) // if any objective response has a missing value
gl invalidObj_resp (!$missingObj_resp & !inrange(procInnovObj_ , 1,3))  // if obj response not missing value but value is invalid obj response (not 1 to 3)
gl missingAch_resp (!$missingObj_resp & inlist(procInnovObj_ , 1) & missing(procInnovAch_))  // obj response is okay but if obj achievement response value is missing
gl invalidAch_resp (!$missingObj_resp & inrange(procInnovObj_ , 1,3) & !missing(procInnovAch_) & !inrange(procInnovAch_, 1,3 ) ) // if obj is okay but if invalid achieved response
gl Ach_resp_NotExpected ( (!$missingObj_resp & inrange(procInnovObj_,2,3) & !missing(procInnovAch_)) | /// if Obj is 'No or Dont Know ' then ObjAch should be missing
(!$missingObj_resp  & $missingObj_resp ) )  // if procObjAch is not missing but obj  which should be answered first is missing

gl allErrors ( $missingObj_resp | $invalidObj_resp | $missingAch_resp | $invalidAch_resp | $Ach_resp_NotExpected )  // 

// keeep observations that are flagged with the error checks
replace error_flag = 1 if $allErrors 
keep if error_flag == 1

// genereate the error messages
replace section = "Section 10" if $allErrors
replace errorCheck = "Invalid Response" if $allErrors

replace errorMessage = varObj + "' Objective for Innovation response is missing" +  " ." + InnovImplement_msg if $missingObj_resp
replace errorMessage = varObj + "='" + string(procInnovObj_) + "', this is invalid. " + InnovImplement_msg if $invalidObj_resp

replace errorMessage = varObj + varAch + " achievement response is missing. " + varObj + "' Objective for Innovation ='" + string(procInnovObj_)+ "' but if this was achieved in " + varObj + varAch + "='" + string(procInnovAch_)  if $missingAch_resp

replace errorMessage = varObj + varAch + " if objective was achieved ='" +  string(procInnovAch_) + "' is not valid.'" + varObj + "' Objective for Innovation ='" + string(procInnovObj_)+ "'"  if $invalidAch_resp

replace errorMessage = varObj + varAch + " if objective was achieved ='" +  string(procInnovAch_) + "' is not expected to be answered. '" + varObj + "' Objective for Innovation is ='" + string(procInnovObj_)+ "'"   if $Ach_resp_NotExpected

//save the dataset
keep if error_flag == 1 & !missing(id00)

// keep $metaDataVars $errorDataVars
insobs 1
save "$error_report\Section10_q2.dta", replace


// third check, main process innovation descrption cannot have blank, one word as well as invalid response)
// --------------------------------------------------------------------------
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
gl invalidDetail_InnovObjDescr ($firmIsCurrentlyManufacturing & isInnovImplement_Firm==1 & (missing(s9q4) | wordcount(s9q4) < 2 | strlen(s9q4) < 4 )) 

drop s8q1__0-s8q4c  // drop section 8 revenue vars

// manufacturing firm in implementing innovation
keep if $firmIsCurrentlyManufacturing 

// get firms that has atleaast one of the innovation implementation as YES
gen isInnovImplement_Firm = 0  
foreach varname of global InnovImplementVars {
    replace isInnovImplement_Firm = 1 if `varname' == 1
}

// keep only innovation implementation firms
keep if isInnovImplement_Firm==1

rename (s9q1 s9q2 s9q3 ) (firm_=)
rename (s9q1b s9q2b s9q3b) (GhanaMkt_=)
rename (s9q1c s9q2c s9q3c) (OutsideGH_=)

// generate innovation implementing firm variable indicator message 
unab newInnovImpVarlist  : OutsideGH* GhanaMkt* firm*
global newInnovImpl_varList `newInnovImpVarlist'

// show vars where firm has innovProcessImplement = Yes
gen InnovImplement_msg = ""

foreach varname of global newInnovImpl_varList {	 
    replace InnovImplement_msg = InnovImplement_msg +subinstr("`varname'", "s9q", "Q", .) + "='Yes', " if  !missing(`varname') & `varname' == 1   
}

// keeep observations that are flagged with the error checks
replace error_flag = 1 if $invalidDetail_InnovObjDescr
keep if  error_flag == 1

// genereate the error messages
replace section = "Section 10" if $invalidDetail_InnovObjDescr
replace errorCheck = "invalid response"		if $invalidDetail_InnovObjDescr
replace errorMessage = "Q4. provided detailed firm's main process innovation ='" + s9q4 + "', is invalid" +  " ." + InnovImplement_msg if $invalidDetail_InnovObjDescr

insobs 1
// keep $metaDataVars $errorDataVars
save "$error_report\Section10_q1_InvalidInnovationDescription.dta", replace 
