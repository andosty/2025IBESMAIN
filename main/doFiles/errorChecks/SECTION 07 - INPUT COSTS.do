*========================================*
*========================================*
*========================================*
*
*========================================*
* SECTION 07: INPUT COSTS *
*========================================*
*1. QUANTITY AND COST OF PRINCIPAL MATERIALS PURCHASED DURING THE 2023 FINANCIAL YEAR

************************
*Question 0 first check
************************
*Sec 07.0, Roster list cannot be blank
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*
merge 1:m interview__id using "$HQData\s7r1.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge

gl blankRosterListQues ($isAnySector & (missing(s7q1) | length(s7q1)<3| !regexm(s7q1, "[^0-9]")))  

replace section = "Section 07" if $blankRosterListQues
replace error_flag = 1 if $blankRosterListQues
replace errorCheck = "Invalid Response"  if $blankRosterListQues
replace errorMessag = "Q0: Description of material = '"+s7q1+"' is invalid" if $blankRosterListQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7q1.dta", replace



**************************
*Question 1 second check
**************************
*Sec 07.1, CPC is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
**preserve
merge 1:m interview__id using "$HQData\s7r1.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge
decode s7r1q1, gen(s7r1q1_new)
gl InvalidCPCQues ($isAnySector & (missing(s7r1q1) | !inrange(s7r1q1, 01111,99000)))

replace section = "Section 07" if $InvalidCPCQues
replace error_flag = 1 if $InvalidCPCQues
replace errorCheck = "Invalid Response" if $InvalidCPCQues
replace errorMessag = "Q1.1: The description='"+s7q1+", the CPC option selected='"+s7r1q1_new+"' is invalid" if $InvalidCPCQues

//save the dataset
keep if error_flag == 1 
insobs 1
drop error_flag
save "$error_report\Section07_s7r1q1.dta", replace



**************************
*Question 2 second check
**************************
*Sec 07.2, Unit of measure is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
**preserve
* 
merge 1:m interview__id using "$HQData\s7r1.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge

decode s7r1q1, gen(s7r1q1_new)
decode s7r1q2, gen(s7r1q2_new)

gl InvalidUnitOfMeasureQues ($isAnySector & (missing(s7r1q2) | !inrange(s7r1q2, 2,999)))   //check unit of measure

replace section = "Section 07" if $InvalidUnitOfMeasureQues
replace error_flag = 1 if $InvalidUnitOfMeasureQues
replace errorCheck = "Invalid Response" if $InvalidUnitOfMeasureQues
replace errorMessag = "Q1.2: The description='"+s7q1+"', CPC option selected='"+s7r1q1_new+"', but unit of measure='"+s7r1q2_new+"' is invalid" if $InvalidUnitOfMeasureQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r1q2.dta", replace



**************************
*Question 3 second check
**************************
*Sec 07.3, Average Unit Price (GH₵) is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r1.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge
 
decode s7r1q1, gen(s7r1q1_new)

gl InvalidAveUnitPriceQues ($isAnySector & (missing(s7r1q3) | !inrange(s7r1q3, 1,9999999999.99)))

replace section = "Section 07" if $InvalidAveUnitPriceQues
replace error_flag = 1 if $InvalidAveUnitPriceQues
replace errorCheck = "Invalid Response" if $InvalidAveUnitPriceQues
replace errorMessag = "Q1.3: The description='"+s7q1+"', CPC option selected='"+s7r1q1_new+"', but avg unit Price='"+string(s7r1q3)+"' is invalid" if $InvalidAveUnitPriceQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r1q3.dta", replace



**************************
// *Question 4a second check
// **************************
// *Sec 07.4a, Total Delivery Cost (GH₵) is invalid
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
// *preserve
// merge 1:m interview__id using "$HQData\s7r1.dta"
// keep if _merge == 3  // Drop observations only in the master data
// drop _merge
// *
// merge m:1 interview__id using "$HQData\ibes_ii.dta"
// drop if _merge == 2  // Drop observations only in the master data
// drop _merge
// 
// decode s7r1q1, gen(s7r1q1_new)
// 
// gl InvalidTotalDeliCostQues ($isAnySector & inrange(ids01,1,5) & (missing(s7r1q4a) | !inrange(s7r1q4a, 1,9999999999.99)))
//
// replace section = "Section 07" if $InvalidTotalDeliCostQues
// replace error_flag = 1 if $InvalidTotalDeliCostQues
// replace errorCheck = "Invalid Response" if $InvalidTotalDeliCostQues
// replace errorMessag = "The description='"+s7q1+"', CPC option selected='"+s7r1q1_new+"', but total delivery cost='"+string(s7r1q4a)+"' is invalid" if $InvalidTotalDeliCostQues
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section07_s7r1q4a.dta", replace



**************************
*Question 4b second check
**************************
*Sec 07.4b, Total Cost in Purchasers' Price (GH₵) is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r1.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge
*
merge m:1 interview__id using "$HQData\ibes_ii.dta"
drop if _merge == 2  // Drop observations only in the master data
drop _merge

decode s7r1q1, gen(s7r1q1_new)

gl InvalidTotalCostPurchQues ($isAnySector & inrange(ids01,6,7) & (missing(s7r1q4b) | !inrange(s7r1q4b, 1,9999999999.99)))

replace section = "Section 07" if $InvalidTotalCostPurchQues
replace error_flag = 1 if $InvalidTotalCostPurchQues
replace errorCheck = "Invalid Response" if $InvalidTotalCostPurchQues
replace errorMessag = "Q1.4: The description='"+s7q1+"', CPC option selected='"+s7r1q1_new+"', but total cost='"+string(s7r1q4b)+"' is invalid" if $InvalidTotalCostPurchQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r1q4b.dta", replace



**************************
*Question 5 second check
**************************
*Sec 07.5, Domestic delivery cost (GH₵) is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r1.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge

decode s7r1q1, gen(s7r1q1_new)
  
gl InvalidDomesDelivCostQues ($isAnySector & (missing(s7r1q5) | !inrange(s7r1q5, 1,9999999999.99)))

replace section = "Section 07" if $InvalidDomesDelivCostQues
replace error_flag = 1 if $InvalidDomesDelivCostQues
replace errorCheck = "Invalid Response" if $InvalidDomesDelivCostQues
replace errorMessag = "Q1.5: The description='"+s7q1+"', CPC option selected='"+s7r1q1_new+"', but domestic delivery cost='"+string(s7r1q5)+"' is invalid" if $InvalidDomesDelivCostQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r1q5.dta", replace



**************************
*Question 6 second check
**************************
*Sec 07.6, Imported delivery cost (GH₵) is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r1.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge

decode s7r1q1, gen(s7r1q1_new)

gl InvalidImportedDelivCostQues ($isAnySector & (missing(s7r1q6) | !inrange(s7r1q6, 1,9999999999.99)))

replace section = "Section 07" if $InvalidImportedDelivCostQues
replace error_flag = 1 if $InvalidImportedDelivCostQues
replace errorCheck = "Invalid Response" if $InvalidImportedDelivCostQues
replace errorMessag = "Q1.6: The description='"+s7q1+"', CPC option selected='"+s7r1q1_new+"', but imported delivery cost='"+string(s7r1q6)+"' is invalid" if $InvalidImportedDelivCostQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r1q6.dta", replace



***************************************************
*2: FUEL PURCHASED DURING THE 2023 FINANCIAL YEAR
***************************************************
*Sec 07.2.1, Fuel, except Gas (LPG) for generating electricity is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r2.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge

decode s7r2__id, gen(s7r2__id_new)

gl InvalidFuelPurchasedQues ($isAnySector & missing(s7r2__id)) | (!inrange(s7r2__id, 1,10)|!inrange(s7r2__id, 99,100))

replace section = "Section 07" if $InvalidFuelPurchasedQues
replace error_flag = 1 if $InvalidFuelPurchasedQues
replace errorCheck = "Invalid Response" if $InvalidFuelPurchasedQues
replace errorMessag = "Q2: Fuel Purchased='"+s7r2__id_new+"' is invalid" if $InvalidFuelPurchasedQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r2__id.dta", replace



***************************************************
*2: FUEL PURCHASED DURING -OTHER
***************************************************
*Sec 07.2.1O, FUEL PURCHASED Other is invalid
***************************
*Question 2.1O first check
***************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r2.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge

decode s7r2__id, gen(s7r2__id_new)

gl InvalidFuelPurchasedOSQues ($isAnySector & (inlist(s7r2__id, 99) & missing(s7r2_oth)))

replace section = "Section 07" if $InvalidFuelPurchasedOSQues
replace error_flag = 1 if $InvalidFuelPurchasedOSQues
replace errorCheck = "Invalid Response" if $InvalidFuelPurchasedOSQues
replace errorMessag = "Q2O(1): Fuel Purchased ID-OS=='"+s7r2__id_new+"' is invalid" if $InvalidFuelPurchasedOSQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r2_oth.dta", replace



***************************
*Question 2.1O second check
***************************
*Sec 07.8, Purchaser's Price is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r2.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge
 
gl InvalidPurchPriceQues ($isAnySector & (missing(s7r2q1) | !inrange(s7r2q1, 1,9999999999.99)))

replace section = "Section 07" if $InvalidPurchPriceQues
replace error_flag = 1 if $InvalidPurchPriceQues
replace errorCheck = "Invalid Response" if $InvalidPurchPriceQues
replace errorMessag = "Q2O(2):Purchased price=='"+string(s7r2q1)+"' is invalid" if $InvalidPurchPriceQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r2q1.dta", replace



***************************************************
*3: SUMMARY OF OPERATING COST 
***************************************************
*Sec 07.3, Roster:OPERATING COST is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r3.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge

decode s7r3__id, gen(s7r3__id_new) 

gl InvalidOperatingCostQues ($isAnySector & (missing(s7r3__id) | (!inrange(s7r3__id, 1,5)|!inrange(s7r3__id, 99,100))))

replace section = "Section 07" if $InvalidOperatingCostQues
replace error_flag = 1 if $InvalidOperatingCostQues
replace errorCheck = "Invalid Response" if $InvalidOperatingCostQues
replace errorMessag = "Q3:Operating cost='"+s7r3__id_new+"' is invalid" if $InvalidOperatingCostQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r3__id.dta", replace
*restore


***************************************************
*3: SUMMARY OF OPERATING COST -OTHER
***************************************************
*Sec 07.3, Roster:OPERATING COST Other is invalid
***************************
*Question 3.1o first check
***************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r3.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge

gl InvalidOperatingCostOSQues ($isAnySector & (inlist(s7r3__id, 99) & missing(s7r3_oth)))

replace section = "Section 07" if $InvalidOperatingCostOSQues
replace error_flag = 1 if $InvalidOperatingCostOSQues
replace errorCheck = "Invalid Response" if $InvalidOperatingCostOSQues
replace errorMessag = "Q3o(1):Operating Cost ID-OS='"+s7r3_oth+"' is invalid" if $InvalidOperatingCostOSQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r3_oth.dta", replace



***************************
*Question 3.1o second check
***************************
*Sec 07.3.1o, Delivery Cost is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r3.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge

decode s7r3__id, gen(s7r3__id_new)

gl InvalidDeliveCostQues ($isAnySector & (missing(s7r3q1) | !inrange(s7r3q1, 0,9999999999.99)))

replace section = "Section 07" if $InvalidDeliveCostQues
replace error_flag = 1 if $InvalidDeliveCostQues
replace errorCheck = "Invalid Response" if $InvalidDeliveCostQues
replace errorMessag = "Q3o(2):The description='"+s7r3__id_new+"', but  delivery cost='"+string(s7r3q1)+"' is invalid" if $InvalidDeliveCostQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r3q1.dta", replace



***************************************************
*4: OTHER COST DURING THE 2023 FINANCIAL YEAR
***************************************************
*Sec 07.4, Roster: OTHER COST is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r4.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge
 
decode s7r4__id, gen(s7r4__id_new)

gl InvalidOtherCostQues ($isAnySector & (missing(s7r4__id) | (!inrange(s7r4__id, 1,26)|!inrange(s7r4__id, 99,100))))

replace section = "Section 07" if $InvalidOtherCostQues
replace error_flag = 1 if $InvalidOtherCostQues
replace errorCheck = "Invalid Response" if $InvalidOtherCostQues
replace errorMessag = "Q4:Other Cost='"+s7r4__id_new+"' is invalid" if $InvalidOtherCostQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r4__id.dta", replace



***************************************************
*4o: SUMMARY OF OPERATING COST -OTHER
***************************************************
*Sec 07.4.1o, Roster:OTHER COST- Other is invalid
****************************
*Question 4.1o first check
****************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r4.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge

gl InvalidOtherCostOSQues ($isAnySector & (inlist(s7r4__id, 99) & missing(s7r4_oth)))

replace section = "Section 07" if $InvalidOtherCostOSQues
replace error_flag = 1 if $InvalidOtherCostOSQues
replace errorCheck = "missing check"  if $InvalidOtherCostOSQues 
replace errorMessag = "Q4O(1):: Other Cost ID-OS cannot be blank" if $InvalidOtherCostOSQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r4_oth.dta", replace



****************************
*Question 4.1o second check
****************************
*Sec 07.10.1, Cost is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r4.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge
 
gl InvalidCostQues ($isAnySector & (missing(s7r4q1) | !inrange(s7r4q1, 1,9999999999.99)))

replace section = "Section 07" if $InvalidCostQues
replace error_flag = 1 if $InvalidCostQues
replace errorCheck = cond(missing(s7r4q1), "Mising response", "Invalid selection") if $InvalidCostQues
replace errorMessag = cond(missing(s7r4q1), "Que. 10.1: Cost cannot be blank", "Que. 10.1: Cost is invalid") if $InvalidCostQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r4q1.dta", replace



***************************************************
*5. PAYMENT TO SUB-CONTRACTORS FOR WORK DONE
***************************************************
****************************
*Question 1.1 second check
****************************
*Sec 07..1, Total payments to sub-contractors for work  is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r5_payment_sub_contractor.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge
 
gl InvalidSubContracttQues ($isAnySector /*& inlist(ids01,5)*/ & (missing(s7r5q1) | !inrange(s7r5q1, 1,9999999999.99)))

replace section = "Section 07" if $InvalidSubContracttQues
replace error_flag = 1 if $InvalidSubContracttQues
replace errorCheck = cond(missing(s7r5q1), "Mising response", "Invalid selection") if $InvalidSubContracttQues
replace errorMessag = cond(missing(s7r5q1), "Que. 11: Total payments to sub-contractors for work cannot be blank", "Que. 11: Total payments to sub-contractors for work is invalid") if $InvalidSubContracttQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s6q6c.dta", replace




