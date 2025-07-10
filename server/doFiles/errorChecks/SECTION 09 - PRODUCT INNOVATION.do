* SECTION 9 PRODUCT INNOVATION  *
* --------------------------------

use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl errorDataVars (section errorCheck errorMessage)
		
gl firmIsCurrentlyManufacturing ( $isAnySector & qtype == 3) //current sector is using the manufacturing Questionnaire
gl innovQueBlank (missing(value)) //currently set sector for the manufacturing questionnaire

* Check 1 ,CHeck if Product Innovation cells are Missing Check for MAnufacturing Questionnaire
*********************************************

// IF Firm is Manufacturing, then Question on IF FIRM HAS INNOVATION CANNOT BE BLANK Sec9_Q1
// // keep $metaDataVars $errorDataVars $startInterviewVars s8q1a s8q2 s8q3 
ren (s9q1a s9q2 s9q3) (s9_q1a s9_q1b s9_q1c ) // rename to match the alphabet que numbering
keep if $firmIsCurrentlyManufacturing

// insobs 1
generate id = _n
rename (s9_q1*) (value=)
reshape long value, i(id) j(varName) string
replace varName = subinstr(varName, "s9_q", "Que.", .)

replace error_flag = 1 if $innovQueBlank
keep if error_flag == 1
replace section = "Section 09" if $innovQueBlank
replace errorCheck = "Invalid Response" if $innovQueBlank
replace errorMessage = varName +  " cannot be blank" if $innovQueBlank

//save the dataset
keep if error_flag == 1 & !missing(id00)
// // keep $metaDataVars $errorDataVars
insobs 1
save "$error_report\Section09_q1a_1b_1c_missing.dta", replace

// second check A, an inovative firm with zero percent innovation, Sec9_Q2
// ---------------------------------------------------------------
* all answers required if firm has innovation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
drop s8q1__0-s8q4c  // drop section 8 revenue vars



// ren (s8q1a s8q2 s8q3) (s8q1a s8q1b s8q1c)
// ren (s9q1 s9q2 s9q3 s9q17o) (s9_q1a s9_q1b s9_q1c s9_q17other ) // rename to match the alphabet que numbering
ren (s9q1a s9q2 s9q3 ) (s9_q1a s9_q1b s9_q1c  ) // rename to match the alphabet que numbering
// ren (s9q4 s9q5 s9q6 s9q7 ) (s9q2a s9q2b s9q2c s9q2d)
gl innovativeManufacturer ($firmIsCurrentlyManufacturing  & (s9_q1a==1 | s9_q1b==1 | s9_q1c==1)) //current sector is using the manufacturing questionnaire and firm has an innovation

gl zeroPercInnovManufacturer ((s9q4 + s9q5 + s9q6 + s9q7 == 100 ) & (s9q4 + s9q5 + s9q6 == 0) )
keep if $innovativeManufacturer

insobs 1
replace error_flag = 1 if $innovativeManufacturer & $zeroPercInnovManufacturer
replace section = "Section 09" if $innovativeManufacturer & $zeroPercInnovManufacturer
replace errorCheck = "0% Innovative Manufacturer" if $innovativeManufacturer & $zeroPercInnovManufacturer
replace errorMessage = "total innovations% ('new to firm' + 'market' + 'rest of world'') = '0' , is invalid, for a firm with innovation" if $innovativeManufacturer & $zeroPercInnovManufacturer

keep if error_flag == 1  & !missing(id00)
// // keep $metaDataVars $errorDataVars
insobs 1
save "$error_report\Section09_q2a_2b_2c_zeroSum.dta", replace



// second check B, an inovative firm with total percent innovation + others not 100% ,Sec9_Q2
// ---------------------------------------------------------------
* all answers required if firm has innovation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
drop s8q1__0-s8q4c  // drop section 8 revenue vars

ren (s9q1a s9q2 s9q3 s9q17o) (s9_q1a s9_q1b s9_q1c s9_q17other ) // rename to match the alphabet que numbering
ren (s9q4 s9q5 s9q6 s9q7 ) (s9q2a s9q2b s9q2c s9q2d)
// gl innovativeManufacturer (s1qso2 == 3 & (s9_q1a==1 | s9_q1b==1 | s9_q1c==1)) //current sector is using the manufacturing questionnaire and firm has an innovation

gl invalidPercInnovManufacturer ((s9q2a + s9q2b + s9q2c + s9q2d != 100 )  )
keep if $invalidPercInnovManufacturer

insobs 1
replace error_flag = 1 if $innovativeManufacturer & $invalidPercInnovManufacturer
replace section = "Section 09" if $innovativeManufacturer & $invalidPercInnovManufacturer
replace errorCheck = "invalid %Sum Innovative Manufacturer" if $innovativeManufacturer & $invalidPercInnovManufacturer
gen totalInnov_andOther_Percent = s9q2a + s9q2b + s9q2c + s9q2d 
replace errorMessage = "total innovations% ='" + string(totalInnov_andOther_Percent) + "', is invalid, for a firm with innovation" if $innovativeManufacturer & $invalidPercInnovManufacturer

keep if error_flag == 1  & !missing(id00)
// // keep $metaDataVars $errorDataVars
insobs 1
save "$error_report\Section09_q2a_2b_2c_not100PercSum.dta", replace


// third check, an invalid innovation description such as blank or one-word ,Sec9_Q3 s8q8
// --------------------------------------------------------------------------
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
drop s8q1__0-s8q4c  // drop section 8 revenue vars
ren (s9q1a s9q2 s9q3) (s9_q1a s9_q1b s9_q1c ) // rename to match the alphabet que numbering
	
// ren (s8q1a s8q2 s8q3) (s8q1a s8q1b s8q1c)
gl badInnovationDescription ($innovativeManufacturer & (wordcount(s9q8) < 2 & strlen(s9q8) < 4) )

keep if $badInnovationDescription
replace error_flag = 1 if $badInnovationDescription
replace section = "Section 09" if $badInnovationDescription
replace errorCheck = "Invalid Innovation Description" if $badInnovationDescription
replace errorMessage = "the described innovation ='" + s9q8 + "' is invalid" if $badInnovationDescription

keep if error_flag == 1
// // keep $metaDataVars $errorDataVars
insobs 1
save "$error_report\Section09_q7_badInnovationDescription.dta", replace


// fourth check, innovativeManufacturer cannot have blank objective for innovation Sec9_Q4_A_to_H
// --------------------------------------------------------------------------
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
gl missingInnovationObjective ($innovativeManufacturer & missing(s9q1) )  // note sq8q here is variable values after pivot

drop s8q1__0-s8q4c  // drop section 8 revenue vars
ren (s9q1a s9q2 s9q3) (s9_q1a s9_q1b s9_q1c ) // rename to match the alphabet que numbering

keep if $innovativeManufacturer
// keep $metaDataVars  $errorDataVars $startInterviewVars s9_q1a s9_q1b s9_q1c    s8q9 s8q10 s8q11 s8q12 s8q13 s8q14 s8q15 s8q16 s8q17 // s8q17 other spec

generate id = _n

// pivot the table longer
reshape long s9q1, i(id) j(varName) 
gen varLetter = char(64 + varName+1) if inrange(varName+1, 1, 26)
gen varNameNew = "Ques 4." + varLetter

replace error_flag = 1 if $missingInnovationObjective
replace section = "Section 09" if $missingInnovationObjective
replace errorCheck = "Invalid Response" if $missingInnovationObjective
replace errorMessage = varNameNew +  " InnovationObjective cannot be blank" if $missingInnovationObjective

//save the dataset
keep if error_flag == 1
insobs 1
// // keep $metaDataVars $errorDataVars
save "$error_report\Section09_q4a_to_d_missingIn.dta", replace


// fifth check, innovativeManufacturer too many count of 'i dont know' or all 'No' response to why objective for innovation ,   /// s8q17 other spec is excluded
// --------------------------------------------------------------------------
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
gl many_No_DontKnow_InnovObj ($innovativeManufacturer & (value==2 | value==2) )  // note s8q here is variable values after pivot,  thus renamed to column name as 'value'

drop s8q1__0-s8q4c  // drop section 8 revenue vars
ren (s9q1a s9q2 s9q3 s9q8) (s9_q1a s9_q1b s9_q1c s9q8 ) // rename to match the alphabet que numbering

keep if $innovativeManufacturer  // uncomment this line to run
// // keep $metaDataVars $errorDataVars  s9_q1a s9_q1b s9_q1c  s8q9 s8q10 s8q11 s8q12 s8q13 s8q14 s8q15 s8q16 

generate id = _n

reshape long s9q, i(id) j(varName)  
replace varName = varName -8
gen varLetter = char(64 + varName) if inrange(varName, 1, 26)
gen varNameNew = "Ques 4(" + varLetter + ")."
ren s9q value

keep if ( !missing(value) & value != 1)

// if has observations then generate else generate blank dataset
if  _N > 0 {
	collapse (count) total_no_dontNo_ObejectiveQues = value , by(id $metaDataVars $errorDataVars)
	
	keep if total_no_dontNo_ObejectiveQues > 7
	
	if _N > 0 { 
		replace error_flag = 1 if total_no_dontNo_ObejectiveQues > 7
		replace section = "Section 09" if total_no_dontNo_ObejectiveQues > 7
		replace errorCheck = "InnovationObjective" if total_no_dontNo_ObejectiveQues > 7
		replace errorMessage = "Cannot have all 8 InnovationObectives being 'No' or 'Dont Know' for A business that introduced a significantly new/improved goods or service in Section-9 Ques.1 (a,b,c)" 
		
		// // keep $metaDataVars $errorDataVars
		save "$error_report\Section09_q4a_InnovObj_all_Nos_and_DontKnows.dta", replace 
		} 		
		
		if _N == 0  {			
		insobs 1	
		
		// // keep $metaDataVars $errorDataVars
		save "$error_report\Section09_q4a_InnovObj_all_Nos_and_DontKnows.dta", replace 
		}
}  

if _N == 0 {		
	
	insobs 1
// 	gen section = ""
// 	gen errorCheck = ""
// 	gen errorMessage = ""
// 	gen error_flag =.
	
	// // keep $metaDataVars $errorDataVars
	save "$error_report\Section09_q4a_InnovObj_all_Nos_and_DontKnows.dta", replace 
}

 
// sixth check, if other-specify objective for innovation, then provide other specify objective
// --------------------------------------------------------------------------------------------
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
gl otherSpec_InnovObj_missing ($innovativeManufacturer & s8q17b== 1 & (missing(s8q17o) | wordcount(s8q17o) < 2 | strlen(s8q17o) < 4 )) 
drop s8q1__0-s8q4c  // drop section 8 revenue vars
ren (s8q1a s8q2 s8q3) (s9_q1a s9_q1b s9_q1c ) // rename to match the alphabet que numbering

keep if $otherSpec_InnovObj_missing  // uncomment this line to run
// // // keep $metaDataVars $errorDataVars  s8q17b s8q17o

* check for missing, invalid response and out of range

		replace error_flag = 1 if $otherSpec_InnovObj_missing
		replace section = "Section 09" if $otherSpec_InnovObj_missing
		replace errorCheck = "invalid response" 
		replace errorMessage = "Answer to Q4.H Other Specify is 'Yes', but failed to provided the detailed specification."  if $otherSpec_InnovObj_missing & missing(s8q17o)
		
	replace errorMessage = "Answer to Q4.H Other Specify is 'Yes', but the provided other specification ='" + s8q17o +"' is invalid "  if $otherSpec_InnovObj_missing & (wordcount(s8q17o) < 2 | strlen(s8q17o) < 4 )

		insobs 1
		// // keep $metaDataVars $errorDataVars
		save "$error_report\Section09_q4h_OtherSpecifyInnovation.dta", replace 

		
// inconsistent innovation Q1 to Objective Reason in Q4
// ----------------------------------------------------
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
gl inconsistent_InnovObj ($innovativeManufacturer & /// 
 (inlist(s9_q1c== 2,3) & s8q12==1) & /// no export innovation but has export innov objectives
 ((inlist(s9_q1a== 2,3) | inlist(s9_q1b== 2,3)) &  s8q11==1) ) // no domestic innovation but has domestic innov objectives
 
drop s8q1__0-s8q4c  // drop section 8 revenue vars
ren (s8q1a s8q2 s8q3) (s9_q1a s9_q1b s9_q1c ) // rename to match the alphabet que numbering

keep if $inconsistent_InnovObj  // uncomment this line to run
// // // keep $metaDataVars $errorDataVars  s9_q1a s9_q1b s9_q1c  s8q11 s8q12

// check for missing, invalid response and out of range

		replace error_flag = 1 if $inconsistent_InnovObj
		replace section = "Section 09" if $inconsistent_InnovObj
		replace errorCheck = "inconsistent Innovation Obj" 
		replace errorMessage = "Q14.H objective to export to foreign market =' "+ string(s8q12)  +"'. But Q1.c. if firm made any innovation to the rest of the world = '"+ string(s9_q1c) + "'" if $inconsistent_InnovObj & (inlist(s9_q1c== 2,3) & s8q12==1)
		
		replace errorMessage = "Q14.C objective to increase domestic market =' "+ string(s8q11)  +"'. But Q1.a If innovations New to firm ='"+ string(s9_q1a)+"' and Q1b If innovations New to Ghanaian Market ='" + string(s9_q1b) + "'" if $inconsistent_InnovObj & ((inlist(s9_q1a== 2,3) | inlist(s9_q1b== 2,3)) &  s8q11==1)  

		keep if error_flag==1
		insobs 1
		// // keep $metaDataVars $errorDataVars
		save "$error_report\Section09_q4D_InconsistentInnovationObj.dta", replace 


// non-manufacturing setor establishment answering Innovation section check
// --------------------------------------------------------------------------
* firm is not manufacturing bu has answered Innovation Questions
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
gl firmIsNotManufacturer ( $isAnySector & (inrange(s1qso2,1,2) | inrange(s1qso2,4,9) ) & s1qso2 != 3) //current sector is using the manufacturing Questionnaire
gl unexpectedResponse (unexpectedAnsVars>0)

drop s8q1__0-s8q4c s8q17o s8q8  // drop section 8 revenue vars
ren (s8q1a s8q2 s8q3) (s9_q1a s9_q1b s9_q1c ) // rename to match the alphabet que numbering

keep if $firmIsNotManufacturer  // uncomment this line to run

// // keep $metaDataVars $errorDataVars  s9_q1a s9_q1b s9_q1c  s8q*

generate id = _n
rename (s8q*) (value=)
reshape long value, i(id) j(varName) string

* expect all variables in Section 9 to be blank 
keep if ( !missing(value))

if _N > 0 { 
collapse (count) unexpectedAnsVars = value , by(id $metaDataVars $errorDataVars)

replace error_flag = 1 if $unexpectedResponse
replace section = "Section 09" if $unexpectedResponse
replace errorCheck = "Invalid Response" if $unexpectedResponse
replace errorMessage = string(s1qso2) + "establishment cannot answer Section 9 - Innovation Questions" 

keep if error_flag==1
insobs 1
// // keep $metaDataVars $errorDataVars
save "$error_report\Section09_NotExpected_to_be_here.dta", replace  } else {
	
insobs 1
// // keep $metaDataVars $errorDataVars
save "$error_report\Section09_NotExpected_to_be_here.dta", replace 
} 


// if objective was met must be answered if yes to Objective for innovation Questions
// -----------------------------------------------------------------------------------
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// gl many_No_DontKnow_InnovObj ($innovativeManufacturer & (value==2 | value==2) )  // note s8q here is variable values after pivot, thus renamed to column name as 'value'
drop s8q1__0-s8q4c  // drop section 8 revenue vars
ren (s8q1a s8q2 s8q3) (s9_q1a s9_q1b s9_q1c ) // rename to match the alphabet que numbering

keep if $innovativeManufacturer  // uncomment this line to run
// // keep $metaDataVars $errorDataVars  s9_q1a s9_q1b s9_q1c  s8q9 s8q9b s8q10 s8q10b s8q11 s8q11b s8q12 s8q12b s8q13 s8q13b s8q14 s8q14b s8q15 s8q15b s8q16 s8q16b s8q17 s8q17b 

generate id = _n

//rename the variable asking if var was objective for innovation to obj_varName
rename (s8*b ) (ach_value=)
rename (s8q*) (obj_value=)

// pivot the table longer
reshape long obj_value, i(id) j(varObj)  string 
reshape long ach_value, i(id varObj) j(varAch)  string 

// keep rows of each obj with its attainment status
keep if varObj == substr(varAch, 1, length(varAch) - 1)
// br id varObj varAch obj_value ach_value

gen NewKK = ustrregexra(varObj, "^.*?s8q", "")
destring (NewKK), generate(numericvar)
gen varLetter = char(64 + (numericvar-8)) if inrange((numericvar-8), 1, 26)
gen quesVar = "Ques 4(" + varLetter + ")"

gl notExpected_AchivementAns (obj_value!=1 & !missing(ach_value) )
gl Expect_AchivementAns (obj_value ==1 & missing(ach_value))
gl invalid_AchivementAns (obj_value ==1 & !missing(ach_value) & !inrange(ach_value,1,3))
gl invalidInnovEntry ($notExpected_AchivementAns | $Expect_AchivementAns | $invalid_AchivementAns)

replace error_flag = 1 if $invalidInnovEntry
replace section = "Section 09" if $invalidInnovEntry
replace errorCheck = "Invalid Response" if $invalidInnovEntry

replace errorMessage = quesVar + ".B if objective is achieved =' "+ string(ach_value) + "' is not expected if " + quesVar + "='" + string(obj_value) +"'" if $notExpected_AchivementAns

replace errorMessage = quesVar + ".B if objective is achieved cannot be blank if " + quesVar + "'='" +string(obj_value) if $Expect_AchivementAns

replace errorMessage = quesVar + ".B if objective is achieved response ='" + string(ach_value) + "'  is invalid. " + quesVar +  "='" + string(obj_value) +"'" if $invalid_AchivementAns

keep if error_flag==1
insobs 1
// // keep $metaDataVars $errorDataVars
save "$error_report\Section09_InnovationAchievement_missing_invalid.dta", replace 
*-----------------------------------------------------------------------------------------------------