* SECTION 13 - FIRM LEVEL CAPABILITIES, TRUST AND INTERACTION
* --------------------------------
gl errorDataVars (section errorCheck errorMessage)		
gl firmIsCurrentlyManufacturing ( $isAnySector & s1qso2 == 3) //current sector is using the manufacturing Questionnaire

// -----------------------------------------------------------------------------------
* Check 1 ,CHeck if firm has innovation activity Q1 Cells are Missing or has invalid values for Manufacturing Questionnaire
*********************************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
gl QueAnsBlank ($firmIsCurrentlyManufacturing & missing(value)) 
gl QueAnsInvalid ($firmIsCurrentlyManufacturing & !missing(value) & !inrange(value,1,3)) 
gl notExpectedToAns ($isAnySector & s1qso2 != 3 & !missing(value))
gl QueAnsInvalid_Missing ($QueAnsBlank | $QueAnsInvalid | $notExpectedToAns)

// keep if $notExpectedToAns
// keep if $firmIsCurrentlyManufacturing
// // keep $metaDataVars $errorDataVars s12q*

ren (s12q1 s12q2 s12q3 s12q4) (frimCap_Q1_=)
ren (s12q5 s12q6 s12q7) (frimCap_Q2_=)
ren (s12q8 s12q9 s12q10 s12q11) (frimCap_Q3_=)
ren (s12q12 s12q13 s12q14 s12q15) (frimCap_Q4_=)
ren (s12q16 s12q17 s12q18 s12q19 s12q20) (frimCap_Q5_=)

generate id = _n
reshape long frimCap_, i(id) j(varName) string
ren frimCap_ value

gen q_num = substr(varName, 1, strpos(varName, "_") - 1) if strpos(varName, "_") > 0
// gen q_num_r = real(q_num)
// gen q_num_r = real(substr(q_num, 2, 1))
gen sub_Qnum = regexs(1) if regexm(varName, "12q(.*)")
gen sub_q_num = real(sub_Qnum)
drop sub_Qnum

sort q_num sub_q_num
gen sub_varName = .
replace sub_varName = sub_q_num if q_num=="Q1"
replace sub_varName = sub_q_num - 4 if q_num=="Q2"
replace sub_varName = sub_q_num - 7 if q_num=="Q3"
replace sub_varName = sub_q_num - 11 if q_num=="Q4"
replace sub_varName = sub_q_num - 15 if q_num=="Q5"

sort id varName q_num varName 
// replace sub_varName = cond(q_num=="Q1", sub_q_num, ///
// 					  cond(q_num=="Q2" & sub_q_num - 4, ///
// 					  cond(q_num=="Q3" & sub_q_num - 9, ///
// 					  cond(q_num=="Q4" & sub_q_num - 11, ///
// 					  sub_varName)))) // keeps original value if no conditions met
					  
gen varLetter = char(64 + (sub_varName)) if inrange((sub_varName), 1, 26)
gen quesVar = q_num + "("+varLetter + ")."

replace error_flag = 1 if $QueAnsInvalid_Missing
keep if error_flag == 1
replace section = "Section 13" if $QueAnsInvalid_Missing
replace errorCheck = "Invalid Response" if $QueAnsInvalid_Missing
replace errorMessage =quesVar+  " cannot be blank" if $QueAnsBlank
replace errorMessage =quesVar+  " response ='" + string(value) +  " is not expected for Non-Manufacturing Firm" if $notExpectedToAns

replace errorMessage =quesVar +  " response ='" + string(value) + "' is invalid" if $QueAnsInvalid

////
//save the dataset
keep if error_flag == 1 & !missing(id00)
// keep $metaDataVars $errorDataVars
insobs 1
save "$error_report\Section13_invalid_MissingResponse.dta", replace
// --------------------------------------------------------------------------
