
*************************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

*net install roman.pkg

***********************************
* SECTION 3: BUSINESS CHALLENGES AND OPPORTUNITIES *
***********************************

**************************
*Question 1, first check 
**************************
/*
gl unexpectedbuscha (missing(s3q1a) )

use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
keep interview__key interview__id id00 Sub_Sector EstablishmentName  s3q1a*
keep in 3/6
reshape long s3q1a,  i(interview__key interview__id id00 Sub_Sector EstablishmentName) j(varCheck)

*changing the number to roman numerals
toroman varCheck,gen(romanVar) lower
gen busCha = "Que 1."+ romanVar

replace section = "Section 03" if $missingbuscha
replace error_flag = 1 if $missingbuscha
replace errorCheck = "Missing Check"  if $missingbuscha
replace errorMessag = "Que1."+ string(varCheck) + "cannot be blank" if $missingbuscha

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q1_buschallmissing.dta", restore
*/

**************************
*Question 1, second check 
**************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

*// preserve 

// keep interview__key interview__id id00 Sub_Sector EstablishmentName  s3q1a*

generate id = _n
reshape long s3q1a, i(id) j(varCheck) 

*gen busCha2 = "s3q1a"+string(varCheck)

* Convert varCheck to Roman numerals for labeling
toroman varCheck, gen(romanVar) lower
gen busCha = "Que 1." + romanVar

* Error if response does not fall in the range of 1–6
gl invalidbusratn ($isAnySector & (!inrange(s3q1a, 1, 6) | missing(s3q1a)))

replace section     = "Section 03" if $invalidbusratn
replace error_flag  = 1           if $invalidbusratn
replace errorCheck  = cond(missing(s3q1a), "Missing response", "Invalid selection") if $invalidbusratn
replace errorMessag = cond(missing(s3q1a), ///
    busCha + ": Response cannot be blank", ///
    busCha + ": Response = '" + string(s3q1a) + "' is not valid (must be between 1–6)") if $invalidbusratn

* Save errors only
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q1_invalidbusratn.dta", replace
*restore

**************************
*Question 2, first check 
**************************

/*
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
keep interview__key interview__id id00 Sub_Sector EstablishmentName  s3q2a*
keep in 3/6
reshape long s3q2a,  i(interview__key interview__id id00 Sub_Sector EstablishmentName) j(varCheck)

gen bus_imp = "s3q2a"+string(varCheck)


replace section = "Section 03" if $missingbusimp
replace error_flag = 1 if $missingbusimp
replace errorCheck = "Missing Check"  if $missingbusimp
replace errorMessag = "Que.1"+ string(varCheck) + "cannot be blank" if $missingbusimp

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q2_busImpmissing.dta", restore
*/


**************************
*Question 2, second check 
**************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Keep only relevant variables
// keep interview__key interview__id id00 Sub_Sector EstablishmentName s3q2a*

* Reshape to long format to process multiple questions
generate id = _n
reshape long s3q2a, i(id) j(varCheck) 

* Generate variable name for reference
gen busCha2 = "s3q2a" + string(varCheck)

* Global to flag invalid responses (not in 1–4 or missing)
gl invalidbusimp ($isAnySector & (!inrange(s3q2a, 1, 4) | missing(s3q2a)))

* Error reporting block
replace section      = "Section 03" if $invalidbusimp
replace error_flag   = 1           if $invalidbusimp
replace errorCheck   = cond(missing(s3q2a), "Missing response", "Invalid selection") if $invalidbusimp
replace errorMessag  = cond(missing(s3q2a), ///
    "Que." + string(varCheck) + ": Response cannot be blank", ///
    "Que." + string(varCheck) + ": Response = '" + string(s3q2a) + "' is not valid (must be between 1–4)") if $invalidbusimp

* Save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q3_busChallenge.dta", replace


**************************
*Question 3, second check 
**************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl invalidbusperc ($isAnySector & (!inrange(s3q3, 1, 4) | missing(s3q3)))

replace section     = "Section 03" if $invalidbusperc
replace error_flag  = 1           if $invalidbusperc
replace errorCheck  = cond(missing(s3q3), "Missing response", "Invalid selection") if $invalidbusperc
replace errorMessag = cond(missing(s3q3), ///
    "Que. 3: Perception of business environment cannot be blank", ///
    "Que. 3: Response = '" + string(s3q3) + "' is not valid (must be between 1–4)") if $invalidbusperc

* Save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q3_busPercinvalid.dta", replace



**************************
*Question 4, first check 
**************************
/*
gl blankratetech (missing(s3q4) )

replace section = "Section 03" if $blankratetech
replace error_flag = 1 if $blankratetech
replace errorCheck = "Missing Check"  if $blankratetech
replace errorMessag = "	Que. 3, rating of technology firm uses cannot be blank" if $blankratetech

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q3_rateTechmissing.dta", restore
*/


**************************
*Question 4, second check 
**************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// // preserve
gl invalidtechrate ($isAnySector & (!inrange (s3q4, 1,3)|missing(s3q4)))

replace section     = "Section 03" if $invalidtechrate 
replace error_flag  = 1           if $invalidtechrate 
replace errorCheck  = cond(missing(s3q4), "Missing response", "Invalid selection") if $invalidtechrate 
replace errorMessag = cond(missing(s3q4), ///
    "Que. 4: Main technology rating cannot be blank", ///
    "Que. 4: Response = '" + string(s3q4) + "' is not valid (must be between 1–3)") if $invalidtechrate 

// Save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q4_techrate invalid.dta" , replace


**************************
*Question 5, second check 
**************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
* Keep only relevant variables
// keep interview__key interview__id id00 Sub_Sector EstablishmentName s3q5a*
// keep in 3/6

* Reshape data from wide to long
reshape long s3q5a, i(interview__key interview__id id00 Sub_Sector EstablishmentName) j(varCheck)

* Convert varCheck to Roman numerals for question labels
toroman varCheck, gen(romanVar) lower
gen fcRate = "Que 5." + romanVar

* Flag invalid responses (outside 1–4 or missing)
gl invalidfcrate ($isAnySector & (!inrange(s3q5a, 1, 4) | missing(s3q5a)))

* Error reporting
replace section     = "Section 03" if $invalidfcrate
replace error_flag  = 1           if $invalidfcrate
replace errorCheck  = cond(missing(s3q5a), "Missing response", "Invalid selection") if $invalidfcrate
replace errorMessag = cond(missing(s3q5a), ///
    fcRate + ": Response for financial cost rating cannot be blank", ///
    fcRate + ": Response = '" + string(s3q5a) + "' is not valid (must be between 1–4)") if $invalidfcrate

* Save only invalid entries
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q5_invalidfcrate.dta", replace


**************************
*Question 6, second check 
**************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
gl invalidcompImp ($isAnySector & (!inrange (s3q6, 1,4)|missing(s3q6)))

replace section     = "Section 03" if $invalidcompImp
replace error_flag  = 1           if $invalidcompImp
replace errorCheck  = cond(missing(s3q6), "Missing response", "Invalid selection") if $invalidcompImp
replace errorMessag = cond(missing(s3q6), ///
    "Que. 6: Impression about business competition cannot be blank", ///
    "Que. 6: Response = '" + string(s3q6) + "' is not valid (must be between 1–4)") if $invalidcompImp

// Save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q6_compImpinvalid.dta", replace


**************************
*Question 7, second check 
**************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
gl invalidAfCF ($isAnySector & !inlist (s3q7, 1,2)|(missing(s3q7)))

/*
replace section = "Section 03" if $invalidAfCF
replace error_flag = 1 if $invalidAfCF
replace errorCheck = "invalid response"  if $invalidAfCF
replace errorMessag = "	Que. 7: Awareness of AfCFTA cannot be blank" if $invalidAfCF
*/

replace section = "Section 03" if $invalidAfCF
replace error_flag = 1 if $invalidAfCF
replace errorCheck = cond(missing(s3q7), "Missing response", "Invalid selection") if $invalidAfCF
replace errorMessag = cond(missing(s3q7), ///
    "Que. 7: Awareness of AfCFTA cannot be blank", ///
    "Que. 7: Response = '" + string(s3q7) + "' is not valid (must be between 1–2)") if $invalidAfCF

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q7_AfCFinvalid.dta", replace


**************************
*Question 8, first check 
**************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl unexpectedAbimp ($isAnySector & s3q7 != 1 & inrange(s3q8,1,5) )

replace section = "Section 03" if $unexpectedAbimp
replace error_flag = 1 if $unexpectedAbimp
replace errorCheck = "response not expected"  if $unexpectedAbimp
replace errorMessag = "Que. 8: Response not expected — respondent did not indicate being aware of AfCFTA (Q7 is not yes)" if $unexpectedAbimp

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q8_unexpectedAbimp.dta", replace


**************************
*Question 8, second check 
**************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl invalidAbimp ($isAnySector & s3q7 == 1 & (!inrange(s3q8, 1,5)|(missing(s3q8))))

replace section = "Section 03" if $invalidAbimp
replace error_flag = 1 if $invalidAbimp
replace errorCheck = "invalid response"  if $invalidAbimp
replace errorMessag = "	Que. 8, perception of ability of companies (AfCFTA) cannot be blank" if $invalidAbimp

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q8_Abimpinvalid.dta", replace

**************************
*Question 9, first check 
**************************
// aftac trade
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
egen rankTotal = rowtotal(s3q9_*)

gl unexpectedbusPos ($isAnySector & s3q7!=1  & rankTotal == 15)  //|
        //!missing(s3q9o)))

replace section = "Section 03" if $unexpectedbusPos
replace error_flag = 1 if $unexpectedbusPos
replace errorCheck = "response not expected"  if $unexpectedbusPos
replace errorMessag = "Que. 9: Response was not expected since 's3q7' was not selected as 1 (Yes)" if $unexpectedbusPos

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q9_unexpectedbusPos.dta", replace

//s i got here
**************************
*Question 9, second check 
**************************


// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
// *generating a variable that gets the no. of rankings i.e 5 rankings
// egen rankTotal = rowtotal(s3q9_*)
//
// gl invalidbusPos ($isAnySector & s3q7==1  & rankTotal != 15) 
//
//
// replace section    = "Section 03" if $invalidbusPos
// replace error_flag = 1           if $invalidbusPos
// replace errorCheck  = cond(missing(s3q9), "Missing response", "Invalid selection") if $invalidbusPos
// replace errorMessage = cond(missing(s3q9), ///
//   "Que. 9: Top 5 ways to position business cannot be blank", ///
//   "Que. 9: Selected option is not valid (must be between 1-18)") if $invalidbusPos
//
//  
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section3_Q9_busPosinvalid.dta", replace


**************************
*Question 9_otherspec, first check 
**************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

*generating a global that contains 5 selection 
gl unexpectedOthspec_q9 ($isAnySector & s3q7 == 1 & !inrange(s3q9__99, 1, 5) & !missing(s3q9o))


replace section = "Section 03" if $unexpectedOthspec_q9
replace error_flag = 1 if $unexpectedOthspec_q9
replace errorCheck = "not expected response" 
replace errorMessag = "Que. 9: Response(s) provided when AfCFTA (option 1 in Q7)/option 99 in Q9 was not selected" if $unexpectedOthspec_q9


//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q9_unexpectedOthspec.dta", replace


**************************
*Question 9_otherSpec, second check (further analysis)
**************************
//gl invalidOthspec !inrange (s3q9, 1,18)|(missing(s3q9) ) & s3q7 = 1
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

*check if any response plus q9_99 otherspec is ranked but specifying is blank
egen rankTotal = rowtotal(s3q9_*)
	
*revisit
gl invalidOthspec_q9 ($isAnySector & s3q7 == 1 & inrange(s3q9__99, 1, 5) & ///
    (missing(s3q9o) | wordcount(s3q9o) == 1 | strlen(trim(s3q9o)) < 4))
	
 
replace section= "Section 03" if $invalidOthspec_q9
replace error_flag = 1 if $invalidOthspec_q9
replace errorCheck = cond(missing(s3q9o), "Missing response", "Invalid response") if $invalidOthspec_q9

replace errorMessage = ///
    cond(missing(s3q9o), ///
        "Que. 9o: Top 5 ways to position business cannot be blank", ///
    cond(wordcount(s3q9o) == 1, ///
        "Que. 9o: Response must contain more than one word", ///
    cond(strlen(trim(s3q9o)) < 4, ///
        "Que. 9o: Response must be at least 5 characters long", ///
        "Que. 9o: Invalid response")) ///
    ) if $invalidOthspec_q9

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q9_Othspecinvalid.dta", replace


**************************
*Question 9_otherSpec, third check 
**************************

*further anlysis on other specify
*Sec 9oth, Other_specify for Reason why the establishment cannot be interviewed is already preloaded
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear


*Other Specify Check - Preloaded option
local strategies_AfCFTA_predefined "Gaining an understanding of the nuances of the AfCFTA agreement|Acquiring enough information as possible about any deals that are on the table|Adopt modern operations, strategies and systems to ensure competitiveness|" ///
"Higher value addition|Leveraging on Government of Ghana initiatives and support to increase production|" ///
"Diversifying product supply|Exploring opportunities in partnerships, clusters, mergers and acquisitions|" ///
"New product development and innovation|Invest more capital|Increase production|Lower operating costs|" ///
"Develop appropriate quality standards|Ensure to meet all requirements for registrations, certifications, licensing, and Inspections|" ///
"Invest in training or building capacity of workforce|Invest in information search and research and development|Adopt digital technologies|Improve export capabilities"

egen rankTotal = rowtotal(s3q9_*)

gl preloaded_othspec_q9oth ($isAnySector & s3q7 == 1 & (rankTotal==15 | inrange(s3q9__99, 1, 5)) & ///
    (!missing(s3q9o) & (wordcount(s3q9o) == 1 | strlen(trim(s3q9o)) < 4 | ///
    regexm(lower(s3q9o), "`strategies_AfCFTA_predefined'"))))


replace section = "Section 03" if $preloaded_othspec_q9oth
replace error_flag = 1 if $preloaded_othspec_q9oth
replace errorCheck = "Top 5 strategies (AfCFTA)" if $preloaded_othspec_q9oth
replace errorMessage = "Que. 9oth, Top 5 strategies (AfCFTA) = '" + s3q9o + "', is part of the preloaded option in Question 9" if $preloaded_othspec_q9oth


//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_q9other.dta", replace


**************************
*Question 10, second check 
**************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear


gl invalidbusGrowth ($isAnySector & !inlist (s3q10, 1,2)|(missing(s3q10)))

replace section = "Section 03" if $invalidbusGrowth
replace error_flag = 1 if $invalidbusGrowth
replace errorCheck = "invalid response"  if $invalidbusGrowth
replace errorMessag = "	Que. 10, response for perception of business growth is invalid" if $invalidbusGrowth

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section3_Q10_busGrowthinvalid.dta", replace

//
// /*
// **************************
// *Question 11, first check 
// **************************
// gl unexpectedbusPos s3q7 != 1
// //!inrange (s3q8, 1,3)|(missing(s3q8) )
//
// replace section = "Section 03" if $unexpectedbusPos
// replace error_flag = 1 if $iunexpectedbusPos
// replace errorCheck = "response not expected"  if $unexpectedbusPos
// replace errorMessag = "	" if $unexpectedbusPos
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section3_Q11_unexpectedbusPos.dta", restore
// */
//
// **************************
// *Question 11, second check 
// **************************
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
//
// egen rankTotal11 = rowtotal(s3q11_*)
//
// gl invalidinvestFac ($isAnySector & rankTotal11 !=15)
//
// replace section = "Section 03" if $invalidinvestFac
// replace error_flag = 1 if $invalidinvestFac
// replace errorCheck = "invalid response"  if $invalidinvestFac
// replace errorMessag = "	Que. 11, response for top 5 invest factors is invalid" if $invalidinvestFac
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section3_Q11_investFacinvalid.dta", replace
//
//
// **************************
// *Question 11_otherSpec, first check 
// **************************
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
//	
// *
// gl unexpectedOthspec ($isAnySector & !inrange(s3q11__99, 1, 5) & !missing(s3q11o)) 
//
// replace section = "Section 03" if $unexpectedOthspec
// replace error_flag = 1 if $unexpectedOthspec
// replace errorCheck = "not expected response"  if $unexpectedOthspec
// replace errorMessage = "Que. 11o: 'Other (specify)' provided without ranking 'Other' (option 99) is unexpected" if $unexpectedOthspec
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section3_Q11_unexpectedOthspec.dta", replace
//
//
// **************************
// *Question 11_otherSpec, second check 
// **************************
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
// egen rankTotal = rowtotal(s3q11_*)
//	
// *
// gl invalidOthspec11 ($isAnySector & inrange(s3q11__99, 1, 5) &  ///
//    (missing(s3q11o) | wordcount(s3q11o) == 1 | strlen(trim(s3q11o)) < 4))
//
//
// replace section = "Section 03" if $invalidOthspec11
// replace error_flag = 1 if $invalidOthspec11
// replace errorCheck = "invalid response"  if $invalidOthspec11
// replace errorMessag = "	Que. 11, top 5 ways to position business is invalid" if $invalidOthspec11
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section3_Q11_Othspecinvalid.dta", replace
//
//
// **************************
// *Question 11_otherSpec, third check 
// **************************
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
//
// *further anlysis on other specify
// // *Sec 9oth, Other_specify for Reason why the establishment cannot be interviewed is already preloaded
// // use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// // // preserve
// //
// // *Other Specify Check - Preloaded option
// // local strategies_AfCFTA_predefined "Gaining an understanding of the nuances of the AfCFTA agreement|Acquiring enough information as possible about any deals that are on the table|Adopt modern operations, strategies and systems to ensure competitiveness|" ///
// // "Higher value addition|Leveraging on Government of Ghana initiatives and support to increase production|" ///
// // "Diversifying product supply|Exploring opportunities in partnerships, clusters, mergers and acquisitions|" ///
// // "New product development and innovation|Invest more capital|Increase production|Lower operating costs|" ///
// // "Develop appropriate quality standards|Ensure to meet all requirements for registrations, certifications, licensing, and Inspections|" ///
// // "Invest in training or building capacity of workforce|Invest in information search and research and development|Adopt digital technologies|Improve export capabilities"
// //
// //
// // // gl preloaded_otherspec_s3q11oth ($isAnySector & ( (!inrange(s3q11, 1, 21) | s3q11_selected != 5) & ///
// // //                                   regexm(lower(s3q11o), "`strategies_AfCFTA_predefined'") ))
// //
// // gl preloaded_othspec_q9oth ($isAnySector & s3q7 == 1 & (rankTotal==15 | inrange(s3q9__99, 1, 5)) & ///
// //     (!missing(s3q9o) & (wordcount(s3q9o) == 1 | strlen(trim(s3q9o)) < 4 | ///
// //     regexm(lower(s3q9o), "`strategies_AfCFTA_predefined'"))))
// //
// //
// //
// // replace section = "Section 03" if $preloaded_otherspec_s3q11oth
// // replace error_flag = 1 if $preloaded_otherspec_s3q11oth
// // replace errorCheck = "Top 5 strategies (AfCFTA)" if $preloaded_otherspec_s3q11oth
// // replace errorMessage = "Que. 11oth, Top 5 investment decicions  ='" + string(s3q11) + "', is part of the preloaded option in Question 11" if $preloaded_otherspec_s3q11oth 
// //
// // //save the dataset
// // keep if error_flag == 1
// // insobs 1
// // drop error_flag
// // save "$error_report\Section3_q11other.dta", replace
//
//
// **************************
// *Question 12, second check 
// **************************
//
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
// gl invalidEnvperc ($isAnySector & (!inrange(s3q12, 1, 4) | missing(s3q12)))
//
// replace section = "Section 03" if $invalidEnvperc
// replace error_flag = 1 if $invalidEnvperc
// replace errorCheck = "invalid response"  if $invalidEnvperc
// replace errorMessag = "	Que. 12, perception of business growth is invalid" if $invalidEnvperc
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section3_Q12_EnvpercInvalid.dta", replace
//
//
// **************************
// *Question 13, second check 
// **************************
// *load data
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
// *generating a variable that contains 5 selection 
// gen byte s3q13_selected = 0
// foreach i of numlist 1/21 {
//     replace s3q13_selected = s3q13_selected + !missing(s3q13__`i')
// }
//
// gl invalidGovchange s3q13_selected == 0
//
//
// replace section = "Section 03" if $invalidGovchange
// replace error_flag = 1 if $invalidGovchange
// replace errorCheck = "invalid response"  if $invalidGovchange
// replace errorMessag = "	Que. 13, response for top 5 invest factors is invalid" if $invalidGovchange
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section3_Q13_Govchangeinvalid.dta", replace
//
//
// **************************
// *Question 13_otherSpec, first check 
// **************************
// *load data
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
//
// *generating a variable that contains 5 selection 
// gen byte has_99 = 0
// **# Bookmark #1
// foreach i of numlist 1/21 {
//     replace has_99 = 1 if s3q13__`i' == 99
// }
//
// gl unexpected13_Othspec ($isAnySector & !missing(s3q13o) & has_99 == 0)
//
// replace section = "Section 03" if $unexpected13_Othspec
// replace error_flag = 1 if $unexpected13_Othspec
// replace errorCheck = "not expected response"  if $unexpected13_Othspec
// replace errorMessag = "other-spcified cannot be blank for, specific change would you like from the Government to enhance the ease business" if $unexpected13_Othspec
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section3_Q13_unexpected13_Othspec.dta", replace
//
//
// **************************
// *Question 13_otherSpec, second check 
// **************************
// //gl invalidOthspec !inrange (s3q11, 1,18) | !inlist(s3q11,99) | s3q11=99 & s3q7 = 1 &(missing(s3q11o) )
//
// /*
// gl invalid13_Othspec ( (!inrange(s3q11, 1, 22) & s3q11 != 99) | (s3q11 == 99 & missing(s3q11o)) )
// */
// *load data
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
//
// gen byte s3q13_selected = 0
// foreach i of numlist 1/21 {
//     replace s3q13_selected = s3q13_selected + !missing(s3q13__`i')
// }
//
// gl invalid13_Othspec ($isAnySector & s3q13_selected == 0)
//
//
// replace section = "Section 03" if $invalid13_Othspec
// replace error_flag = 1 if $invalid13_Othspec
// replace errorCheck = "invalid response"  if $invalid13_Othspec
// replace errorMessag = "Que. 13, specific changes to position business is invalid" if $invalid13_Othspec
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section3_Q13_OthspecInvalid.dta", replace
//
//
// **************************
// *Question 13o_otherSpec, third check 
// **************************
// *load dataset
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
// *further anlysis on other specify
// *Sec 9oth, Other_specify for Reason why the establishment cannot be interviewed is already preloaded
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// // preserve
//
// *Other Specify Check - Preloaded option
// local speciChang_GovePredefined "Gaining an understanding of the nuances of the AfCFTA agreement|Acquiring enough information as possible about any deals that are on the table|Adopt modern operations, strategies and systems to ensure competitiveness|" ///
// "Higher value addition|Leveraging on Government of Ghana initiatives and support to increase production|" ///
// "Diversifying product supply|Exploring opportunities in partnerships, clusters, mergers and acquisitions|" ///
// "New product development and innovation|Invest more capital|Increase production|Lower operating costs|" ///
// "Develop appropriate quality standards|Ensure to meet all requirements for registrations, certifications, licensing, and Inspections|" ///
// "Invest in training or building capacity of workforce|Invest in information search and research and development|Adopt digital technologies|Improve export capabilities"
//
//
// * Step 1: Create flag for whether 99 was selected
// gen byte s3q13_has_99 = 0
// foreach i of numlist 1/21 {
//     replace s3q13_has_99 = 1 if s3q13__`i' == 99
// }
//
// * Step 2: Define global to flag invalid 'Other, specify' responses with preloaded values
// gl prel_othSpec_s3q13oth ($isAnySector & s3q13_has_99 == 0 & ///
// regexm(lower(s3q13o), "`speciChang_GovePredefined'"))
//
//
//
// replace section = "Section 03" if $prel_othSpec_s3q13oth
// replace error_flag = 1 if $prel_othSpec_s3q13oth
// replace errorCheck = "OtherSpec check" if $prel_othSpec_s3q13oth
// replace errorMessage = "Que. 13oth, Specific changes government to enhance business  ='" + s3q13o + "', is part of the preloaded option in Question 13o" if $prel_othSpec_s3q13oth 
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section3_q13oPredefined.dta", replace
//
//
//
// **************************
// *Question 14, second check 
// **************************
// *load dataset
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
// *generating a variable that contains 5 selection 
// gen byte s3q14_selected = 0
// foreach i of numlist 1/11 {
//     replace s3q14_selected = s3q14_selected + !missing(s3q14__`i')
// }
//
// gl invalidSecimprov ($isAnySector & s3q14_selected == 0)
//
//
// replace section = "Section 03" if $invalidSecimprov
// replace error_flag = 1 if $invalidSecimprov
// replace errorCheck = "invalid response"  if $invalidSecimprov
// replace errorMessag = "	Que. 14, response for perception of business improvement by sector is invalid" if $invalidSecimprov
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section3_Q14_SecimprovInvalid.dta", replace
//
//
// **************************
// *Question 14o_otherSpec, first check 
// **************************
// *load dataset
// // use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// //
// //
// // *generating a variable that contains 5 selection 
// // gen byte has_99 = 0
// // foreach i of numlist 1/11 {
// //     replace has_99 = 1 if s3q14__`i' == 99
// // }
// //
// //
// // gl unexpected14o_Othspec ($isAnySector & !missing(s3q14o) & has_99 == 0)
// //
// // replace section = "Section 03" if $unexpected14o_Othspec
// // replace error_flag = 1 if $iunexpected14o_Othspec
// // replace errorCheck = "not expected response"  if $unexpected14o_Othspec
// // replace errorMessag = "	 "if $unexpected13_Othspec
// //
// // //save the dataset
// // keep if error_flag == 1
// // insobs 1
// // drop error_flag
// // save "$error_report\Section3_Q14_unexpected14_Othspec.dta", replace
//
// //
// // **************************
// // *Question 14o_otherSpec, second check 
// // **************************
// // *load dataset
// // use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// //
// // *{I have to correct all other ques with other spec, q9,11,13 for word n character count}
// // gen byte other_specify_selected = 0
// // foreach i of numlist 1/12 {
// //     replace other_spec14_selected = 1 if s3q14_`i' == 99
// // }
// //
// //
// // // Define invalid: "Other (specify)" selected but missing/poor input
// // gl invalid14o_Othspec ($isAnySector & other_spec14_selected == 1 & ///
// //     (missing(s3q14_o) | wordcount(s3q14_o) < 2 | strlen(trim(s3q14_o)) < 4))
// //
// //
// // replace section = "Section 03" if $invalid14o_Othspec
// // replace error_flag = 1 if $invalid14o_Othspec
// //
// // replace errorCheck = cond(missing(s3q14_o), "Missing response", ///
// //                      cond(wordcount(s3q14_o) == 1, "Invalid response", ///
// //                      cond(strlen(trim(s3q14_o)) < 4, "Invalid response", "Invalid response"))) if $invalid14o_Othspec
// //
// // replace errorMessag = cond(missing(s3q14_o), ///
// //     "Que. 14o: Specific change to position business cannot be blank", ///
// //     cond(wordcount(s3q14_o) == 1, ///
// //         "Que. 14o: Response must contain more than one word", ///
// //     cond(strlen(trim(s3q14_o)) < 4, ///
// //         "Que. 14o: Response must be at least 4 characters long", ///
// //         "Que. 14o: Invalid response"))) if $invalid14o_Othspec
// //
// //
// // // Save the dataset
// // keep if error_flag == 1
// // insobs 1
// // drop error_flag
// // save "$error_report\Section3_Q14o_OthspecInvalid.dta", replace
//
//
//
// **************************
// // *Question 14o_otherSpec, third check (further analysis) 
// // **************************
// // *load dataset
// // use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// //
// // *further analysis on other specify
// // *Sec 9oth, Other_specify for Reason why the establishment cannot be interviewed is already preloaded
// // use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// // // preserve
// //
// // *Other Specify Check - Preloaded option
// // local sector_improvmnt_predefined "Invest more capital|Increase production|Lower operating costs|" ///
// // "Develop appropriate quality standards|Meet all requirements for registrations, certifications, licensing, and inspections|" ///
// // "Invest in training or building the capacity of the workforce|Invest in information search and research and development|" ///
// // "Adopt digital technologies|Participate in building infrastructure and other strategic national projects by providing private finance as well as marketing and managerial expertise|Improve export capabilities|Network with other businesses" 
// //
// //
// // * Step 1: Create flag for whether 99 was selected
// // gen byte s3q14_has_99 = 0
// // foreach i of numlist 1/12 {
// //     replace s3q14_has_99 = 1 if s3q14_`i' == 99
// // }
// //
// // * Step 2: Define global to flag invalid 'Other, specify' responses with preloaded values
// // gl preloaded_s3q14oth ($isAnySector & s3q14_has_99 == 0 & ///
// // regexm(lower(s3q14o), "`sector_improvmnt_predefined'"))
// //
// //
// // replace section = "Section 03" if $preloaded_s3q14oth
// // replace error_flag = 1 if $preloaded_s3q14oth
// // replace errorCheck = "OtherSpec check" if $preloaded_s3q14oth
// // replace errorMessage = "Que. 14oth, Specific changes government to enhance business  ='" + string(s3q14o) + "', is part of the preloaded option in Question 13o" if $preloaded_s3q14oth 
// //
// // //save the dataset
// // keep if error_flag == 1
// // insobs 1
// // drop error_flag
// // save "$error_report\Section3_q14oPreloaded.dta", replace
//
