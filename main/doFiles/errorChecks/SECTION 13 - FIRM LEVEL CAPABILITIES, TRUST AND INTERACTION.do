* SECTION 13 - FIRM LEVEL CAPABILITIES, TRUST AND INTERACTION
* --------------------------------
gl errorDataVars (section errorCheck errorMessage)		
gl firmIsCurrentlyManufacturing ( $isAnySector & qtype == 3) //current sector is using the manufacturing Questionnaire

**************************************************************************************************************
* CHeck if firm has LEVEL CAPABILITIES Fields as Missing or has invalid values for Manufacturing Questionnaire
**************************************************************************************************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
keep if inlist(interview__status, 100,120 ,130) 

gl QueAnsBlank ($firmIsCurrentlyManufacturing & missing(value)) 
gl QueAnsInvalid ($firmIsCurrentlyManufacturing & !missing(value) & !inrange(value,1,3)) 
gl notExpectedToAns ($isAnySector & qtype != 3 & !missing(value))
gl QueAnsInvalid_Missing ($QueAnsBlank | $QueAnsInvalid | $notExpectedToAns)

// keep if $notExpectedToAns
// keep if $firmIsCurrentlyManufacturing
// // keep $metaDataVars $errorDataVars s12q*

ren (s13q1 s13q2 s13q3 s13q4) (frimCap_Q1_=)
ren (s13q5 s13q6 s13q7) (frimCap_Q2_=)
ren (s13q8 s13q9 s13q10 s13q11) (frimCap_Q3_=)
ren (s13q12 s13q13 s13q14 s13q15) (frimCap_Q4_=)
ren (s13q16 s13q17 s13q18 s13q19 s13q20) (frimCap_Q5_=)

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


**********************************************************
*  Too many Indifferent response for the whole section   *
**********************************************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
keep if inlist(interview__status, 100,120 ,130) 
gl manyIndifferenceResp (percentIndifferent >= 30) 

keep if  $firmIsCurrentlyManufacturing
generate id = _n
reshape long s13, i(id) j(varName) string

order interview__key interview__id id00 EstablishmentName Sub_Sector Region regCode District distCode EZ Estab_number StreetName Suburb ExactLocation Town Team Supervisor SupervisorContact EnumeratorName EnumContact qtype nav1__Latitude nav1__Longitude nav1__Accuracy nav1__Altitude nav1__Timestamp s00a_q08a s00a_q09a s00a_q10a s00a_q11a s00a_q11oth_a s00a_q08b s00a_q09b s00a_q10b s00a_q11b s00a_q11oth_b s00a_q11b1__Latitude s00a_q11b1__Longitude s00a_q11b1__Accuracy s00a_q11b1__Altitude s00a_q11b1__Timestamp s00a_q08c s00a_q09c s00a_q10c s00a_q11c s00a_q11oth_c s00a_q11b2__Latitude s00a_q11b2__Longitude s00a_q11b2__Accuracy s00a_q11b2__Altitude s00a_q11b2__Timestamp s00a_q12 s00a_q12oth s00a_q13__Latitude s00a_q13__Longitude s00a_q13__Accuracy s00a_q13__Altitude s00a_q13__Timestamp gpsAccuracy currentDate current_year current_month yearAgo_month_string id13a id13n id13p id13pb id13pc id13 id13b id13c id14 id14b id14c2 id14c id14c3 id15 id15b id15c id16 id16b id16c id17 id17b id17c id18 id18b id18bc id18c id18c1 id19 sssys_irnd has__errors interview__status assignment__id surveyStartDate todaySystemDate interview_date interview_date_num gps_date gps_date_num date_within_surveyPeriod section errorCheck errorMessage error_flag s13 varName
collapse (count) indifferent = s13 if s13 == 2, by(id interview__key - error_flag)
*total questions in S13 are 20
gen percentIndifferent = indifferent /20 *100

keep if $manyIndifferenceResp

replace error_flag = 1 if $manyIndifferenceResp
keep if error_flag == 1
replace section = "Section 13" if $manyIndifferenceResp
replace errorCheck = "Many Indifferent Response" if $manyIndifferenceResp
replace errorMessage =  "Respondent gave '" + string(indifferent) +  "' out of 20 questions with response = 'Indifferent'. Having '"+ string(percentIndifferent) + "'% indifferent response for the whole of section-13 is not okay. Please probe respondent very well" if $manyIndifferenceResp
 insobs 1
save "$error_report\Section13_manyIndifferenceResponse.dta", replace

********************************************************************************
*   zero employees who have the skills to fuse or link newly acquired knowledge with existing knowledge   *
********************************************************************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
keep if inlist(interview__status, 100,120 ,130) 
gl zeroEmployeeSkillDifuser (s13q8==1 & s2r1q1_employee_total==0) 

keep if  $firmIsCurrentlyManufacturing
keep if $zeroEmployeeSkillDifuser

decode s13q8, generate(s13q8_new)

replace error_flag = 1 if $zeroEmployeeSkillDifuser
keep if error_flag == 1
replace section = "Section 13" if $zeroEmployeeSkillDifuser
replace errorCheck = "Inconsistent Response" if $zeroEmployeeSkillDifuser
replace errorMessage =  "Q3. If response for 'employees have the skills to fuse knowledge' = '"+ s13q8_new +"', while total employees ='" + string(s2r1q1_employee_total)  + "'. Then, who are the employees you referring to?" if $zeroEmployeeSkillDifuser
 insobs 1
save "$error_report\Section13_zeroEmployeeSkillDifuser.dta", replace

********************************************************************************
*   establishment does not keep records but can make regular technology audit  *
********************************************************************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
keep if inlist(interview__status, 100,120 ,130) 

keep if  $firmIsCurrentlyManufacturing

gl nonRecordAudit (s1q5>1 & s13q3==1) 
keep if $nonRecordAudit

decode s13q3, generate(s13q3_new)
decode s1q5, generate(s1q5_new)
decode id17, generate(id17_new)

replace error_flag = 1 if $nonRecordAudit
replace section = "Section 13" if $nonRecordAudit
replace errorCheck = "Inconsistence Response" if $nonRecordAudit 
replace errorMessage = "Q1c. establishment with ownership type = '" + id17_new + "', answers that, regular conduct of technological audit of our company ='" + s13q3_new +  "' but if the establishment keep some form of record or accounts =  '" + s1q5_new +"'. This is not consistent" if $nonRecordAudit

// keep $metaDataVars $errorDataVars
insobs 1
save "$error_report\Section13_NoRecordKeeper_DoesTechAudit.dta", replace


********************************************************************************
*  Establishment with small employees but has knowledge-coordinating department 
********************************************************************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
keep if inlist(interview__status, 100,120 ,130) 
keep if $firmIsCurrentlyManufacturing
decode id17, generate(id17_new)
gl smallfirmSizeDeparment (s13q10 == 1 & s2r1q1_persons_engaged_total < 5) 

keep if $smallfirmSizeDeparment

replace error_flag = 1 if $smallfirmSizeDeparment
replace section = "Section 13" if $smallfirmSizeDeparment
replace errorCheck = "Inconsistence Response" if $smallfirmSizeDeparment 
replace errorMessage = "Q3c. establishment with ownership type = '" + id17_new + "', answers that, total persons engages ='" + string(s2r1q1_persons_engaged_total) +  "'. This is too small to have a depertment for knowledge coordination within the establishment" if $smallfirmSizeDeparment

insobs 1
save "$error_report\Section13_smallFirmSizeForKnowledgeDepartment.dta", replace


********************************************************************************
*  Establishment has well-organized Marketing department but total persons engaged too small
********************************************************************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
keep if inlist(interview__status, 100,120 ,130) 
keep if $firmIsCurrentlyManufacturing
decode id17, generate(id17_new)
gl smallfirmSizeDeparment (s13q12 == 1 & s2r1q1_persons_engaged_total < 5) 

keep if $smallfirmSizeDeparment

replace error_flag = 1 if $smallfirmSizeDeparment
replace section = "Section 13" if $smallfirmSizeDeparment
replace errorCheck = "Inconsistence Response" if $smallfirmSizeDeparment 
replace errorMessage = "Q3c. establishment with ownership type = '" + id17_new + "', answers that, total persons engages ='" + string(s2r1q1_persons_engaged_total) +  "'. This is too small to have a well-organized marketing department in an establishment" if $smallfirmSizeDeparment

insobs 1
save "$error_report\Section13_smallFirmSizeForMarketingDepartment.dta", replace


********************************************************************************
*  Cannot have increased sales of new product if there are no commercialised new products
********************************************************************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
keep if inlist(interview__status, 100,120 ,130) 
keep if $firmIsCurrentlyManufacturing
decode id17, generate(id17_new)
decode s13q13, generate(s13q13_new)
decode s13q14, generate(s13q14_new)

gl newSalesNewProdError (s13q13 > 1 & s13q14 == 1) 

keep if $newSalesNewProdError

replace error_flag = 1 if $newSalesNewProdError
replace section = "Section 13" if $newSalesNewProdError
replace errorCheck = "Inconsistence Response" if $newSalesNewProdError 
replace errorMessage = "Q4c. establishment answers that, 'there are commercialize products and services that are completely new to unit in your establishment' ='" + s13q13_new +  "'. but also says , establishment has increases in sales of new product in existing markets ='" +  s13q14_new+ "'" if $newSalesNewProdError

insobs 1
save "$error_report\Section13_newSalesNewProdError.dta", replace
