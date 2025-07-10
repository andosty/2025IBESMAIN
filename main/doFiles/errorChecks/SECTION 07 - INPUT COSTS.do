*========================================*
*========================================*
*========================================*

*use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*use "C:\2025IBESMAIN\HQData\HQ_Extracted\s7r1.dta"
**preserve

*========================================*
* SECTION 07: INPUT COSTS *
*========================================*

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
replace errorMessag = "Description of material = '"+s7q1+"' is invalid" if $blankRosterListQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7q1.dta", replace
*restore


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
replace errorMessag = "The description='"+s7q1+", the CPC option selected='"+s7r1q1_new+"' is invalid" if $InvalidCPCQues

//save the dataset
keep if error_flag == 1 
insobs 1
drop error_flag
save "$error_report\Section07_s7r1q1.dta", replace
*restore


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
replace errorMessag = "The description='"+s7q1+"', CPC option selected='"+s7r1q1_new+"', but unit of measure='"+s7r1q2_new+"' is invalid" if $InvalidUnitOfMeasureQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r1q2.dta", replace
*restore


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
replace errorMessag = "The description='"+s7q1+"', CPC option selected='"+s7r1q1_new+"', but avg unit Price='"+string(s7r1q3)+"' is invalid" if $InvalidAveUnitPriceQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r1q3.dta", replace
*restore


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
// *restore


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
replace errorMessag = "The description='"+s7q1+"', CPC option selected='"+s7r1q1_new+"', but total cost='"+string(s7r1q4b)+"' is invalid" if $InvalidTotalCostPurchQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r1q4b.dta", replace
*restore


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
replace errorMessag = "The description='"+s7q1+"', CPC option selected='"+s7r1q1_new+"', but domestic delivery cost='"+string(s7r1q5)+"' is invalid" if $InvalidDomesDelivCostQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r1q5.dta", replace
*restore


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
replace errorMessag = "The description='"+s7q1+"', CPC option selected='"+s7r1q1_new+"', but imported delivery cost='"+string(s7r1q6)+"' is invalid" if $InvalidImportedDelivCostQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r1q6.dta", replace
*restore


*========================================*
* SECTION 07.A: INPUT COSTS *
*========================================*

**************************
*Question 1 second check
**************************
*Sec 07.1(7A), CPC is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r1.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge
*
merge m:1 interview__id using "$HQData\ibes_ii.dta"
drop if _merge == 2  // Drop observations only in the master data
drop _merge

decode s7ar1q1, gen(s7ar1q1_new)

gl Invalid7ACPCQues (($isAnySector & inlist(ids01,8)) & (missing(s7ar1q1) | !inrange(s7ar1q1, 01111,99000)))

replace section = "Section 07" if $Invalid7ACPCQues
replace error_flag = 1 if $Invalid7ACPCQues
replace errorCheck = "Invalid Response" if $Invalid7ACPCQues
replace errorMessag = "The (CSM)description='"+s7aq1+", the CPC option selected='"+s7ar1q1_new+"' is invalid" if $Invalid7ACPCQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7ar1q1.dta", replace
**restore
//
//
// **************************
// *Question 2 second check
// **************************
// *Sec 07.2(7A), Reporting period is invalid
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
// *preserve
// merge 1:m interview__id using "$HQData\s7ar1.dta"
// keep if _merge == 3  // Drop observations only in the master data
// drop _merge
// *
// // merge m:1 interview__id using "$HQData\ibes_ii.dta"
// // drop if _merge == 2  // Drop observations only in the master data
// // drop _merge
//
// decode s7ar1q1, gen(s7ar1q1_new)
//
// gl InvalidReportingPeriodQues ($isAnySector & inlist(ids01,8) & (missing(s7ar1q2)))   //check unit of measure
//
// replace section = "Section 07" if $InvalidReportingPeriodQues
// replace error_flag = 1 if $InvalidReportingPeriodQues
// replace errorCheck = "Invalid Response" if $InvalidReportingPeriodQues
// replace errorMessag = "The (CSM)description='"+s7aq1+"', CPC option selected='"+s7ar1q1_new+"', but Reporting period='"+s7ar1q2+"' is invalid" if $InvalidReportingPeriodQues
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section07_s7ar1q2.dta", replace
// *restore


**************************
*Question 3 second check
**************************
*Sec 07.3(7A), Opening Stock (GH₵) is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7ar1.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge
*
merge m:1 interview__id using "$HQData\ibes_ii.dta"
drop if _merge == 2  // Drop observations only in the master data
drop _merge

decode s7ar1q1, gen(s7ar1q1_new)

gl InvalidOpeningStockQues ($isAnySector & inlist(ids01,8) & (missing(s7ar1q3) | !inrange(s7ar1q3, 1,9999999999.99)))

replace section = "Section 07" if $InvalidOpeningStockQues
replace error_flag = 1 if $InvalidOpeningStockQues
replace errorCheck = "Invalid Response" if $InvalidOpeningStockQues
replace errorMessag = "The (CSM)description='"+s7aq1+"', CPC option selected='"+s7ar1q1_new+"', but Opening stock='"+string(s7ar1q3)+"' is invalid" if $InvalidOpeningStockQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7ar1q3.dta", replace
*restore


**************************
*Question 4 second check
**************************
*Sec 07.4(7A), Purchases (GH₵) is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7ar1.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge
*
merge m:1 interview__id using "$HQData\ibes_ii.dta"
drop if _merge == 2  // Drop observations only in the master data
drop _merge

decode s7ar1q1, gen(s7ar1q1_new)
 
gl InvalidPurchasesQues ($isAnySector & inlist(ids01,8) & (missing(s7ar1q4) | !inrange(s7ar1q4, 1,9999999999.99)))

replace section = "Section 07" if $InvalidPurchasesQues
replace error_flag = 1 if $InvalidPurchasesQues
replace errorCheck = "Invalid Response" if $InvalidPurchasesQues
replace errorMessag = "The (CSM)description='"+s7aq1+"', CPC option selected='"+s7ar1q1_new+"', but Purchases='"+string(s7ar1q4)+"' is invalid" if $InvalidPurchasesQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7ar1q4.dta", replace
*restore


**************************
*Question 5 second check
**************************
*Sec 07.5(7A), Proportion made in Ghana is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7ar1.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge
*
merge m:1 interview__id using "$HQData\ibes_ii.dta"
drop if _merge == 2  // Drop observations only in the master data
drop _merge

decode s7ar1q1, gen(s7ar1q1_new)

gl InvalidProMadeGHQues ($isAnySector & inlist(ids01,8) & (missing(s7ar1q5) | !inrange(s7ar1q5, 0,100)))

replace section = "Section 07" if $InvalidProMadeGHQues
replace error_flag = 1 if $InvalidProMadeGHQues
replace errorCheck = "Invalid Response" if $InvalidProMadeGHQues
replace errorMessag = "The (CSM)description='"+s7aq1+"', CPC option selected='"+s7ar1q1_new+"', but Proportion made in Ghana='"+string(s7ar1q5)+"' is invalid" if $InvalidProMadeGHQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7ar1q5.dta", replace
*restore


**************************
*Question 6 second check
**************************
*Sec 07.6(7A), Sales (GH₵) is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7ar1.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge
*
merge m:1 interview__id using "$HQData\ibes_ii.dta"
drop if _merge == 2  // Drop observations only in the master data
drop _merge

decode s7ar1q1, gen(s7ar1q1_new)
  
gl InvalidSalesQues ($isAnySector & inlist(ids01,8) & (missing(s7ar1q6) | !inrange(s7ar1q6, 1,9999999999.99)))

replace section = "Section 07" if $InvalidSalesQues
replace error_flag = 1 if $InvalidSalesQues
replace errorCheck = "Invalid Response" if $InvalidSalesQues
replace errorMessag = "The (CSM)description='"+s7aq1+"', CPC option selected='"+s7ar1q1_new+"', but Sales='"+string(s7ar1q6)+"' is invalid" if $InvalidSalesQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r1q6.dta", replace
*restore


**************************
*Question 7 second check
**************************
*Sec 07.7(7A), Closing Stock (GH₵) is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
*preserve
merge 1:m interview__id using "$HQData\s7r1.dta"
keep if _merge == 3  // Drop observations only in the master data
drop _merge
*
merge m:1 interview__id using "$HQData\ibes_ii.dta"
drop if _merge == 2  // Drop observations only in the master data
drop _merge

decode s7ar1q1, gen(s7ar1q1_new)
 
gl InvalidClosingStockQues ($isAnySector & inlist(ids01,8) & (missing(s7ar1q7) | !inrange(s7ar1q7, 1,999999.99)))

replace section = "Section 07" if $InvalidClosingStockQues
replace error_flag = 1 if $InvalidClosingStockQues
replace errorCheck = "Invalid Response" if $InvalidClosingStockQues
replace errorMessag = "The (CSM)description='"+s7aq1+"', CPC option selected='"+s7ar1q1_new+"', but Closing Stock='"+string(s7ar1q7)+"' is invalid" if $InvalidClosingStockQues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section07_s7r1q7.dta", replace
*restore


***************************************************
*8: FUEL PURCHASED DURING THE 2023 FINANCIAL YEAR
***************************************************
*Sec 07.8, FUEL PURCHASED is invalid
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
// *preserve
// merge 1:m interview__id using "$HQData\s7r2.dta"
// keep if _merge == 3  // Drop observations only in the master data
// drop _merge
//
// decode s7r2__id, gen(s7r2__id_new)
// 
// gl InvalidFuelPurchasedQues ($isAnySector & missing(s7r2__id)) | (!inrange(s7r2__id, 1,10)|!inrange(s7r2__id, 99,100))
//
// replace section = "Section 07" if $InvalidFuelPurchasedQues
// replace error_flag = 1 if $InvalidFuelPurchasedQues
// replace errorCheck = "Invalid Response" if $InvalidFuelPurchasedQues
// replace errorMessag = "Fuel Purchased='"+s7r2__id_new+"' is invalid" if $InvalidFuelPurchasedQues
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section07_s7r2__id.dta", replace
// *restore


// ***************************************************
// *8: FUEL PURCHASED DURING -OTHER
// ***************************************************
// *Sec 07.8, FUEL PURCHASED Other is invalid
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
// *preserve
// merge 1:m interview__id using "$HQData\s7r2.dta"
// keep if _merge == 3  // Drop observations only in the master data
// drop _merge
// 
// decode s7r2__id, gen(s7r2__id_new)
//
// gl InvalidFuelPurchasedOSQues ($isAnySector & (inlist(s7r2__id, 99) & missing(s7r2_oth)))
//
// replace section = "Section 07" if $InvalidFuelPurchasedOSQues
// replace error_flag = 1 if $InvalidFuelPurchasedOSQues
// replace errorCheck = "Invalid Response" if $InvalidFuelPurchasedOSQues
// replace errorMessag = "Fuel Purchased ID-OS=='"+s7r2__id_new+"' is invalid" if $InvalidFuelPurchasedOSQues
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section07_s7r2_oth.dta", replace
// *restore
//
//
// ***************************
// *Question 8.1 second check
// ***************************
// *Sec 07.8, Purchaser's Price is invalid
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
// *preserve
// merge 1:m interview__id using "$HQData\s7r2.dta"
// keep if _merge == 3  // Drop observations only in the master data
// drop _merge
//  
// gl InvalidPurchPriceQues ($isAnySector & (missing(s7r2q1) | !inrange(s7r2q1, 1,9999999999.99)))
//
// replace section = "Section 07" if $InvalidPurchPriceQues
// replace error_flag = 1 if $InvalidPurchPriceQues
// replace errorCheck = "Invalid Response" if $InvalidPurchPriceQues
// replace errorMessag = "Purchased price=='"+string(s7r2q1)+"' is invalid" if $InvalidPurchPriceQues
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section07_s7r2q1.dta", replace
// *restore
// 
//
// ***************************************************
// *9: SUMMARY OF OPERATING COST 
// ***************************************************
// *Sec 07.9, Roster:OPERATING COST is invalid
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
// *preserve
// merge 1:m interview__id using "$HQData\s7r3.dta"
// keep if _merge == 3  // Drop observations only in the master data
// drop _merge
// 
// decode s7r3__id, gen(s7r3__id_new) 
//
// gl InvalidOperatingCostQues ($isAnySector & (missing(s7r3__id) | (!inrange(s7r3__id, 1,5)|!inrange(s7r3__id, 99,100))))
//
// replace section = "Section 07" if $InvalidOperatingCostQues
// replace error_flag = 1 if $InvalidOperatingCostQues
// replace errorCheck = "Invalid Response" if $InvalidOperatingCostQues
// replace errorMessag = "Operating cost='"+s7r3__id_new+"' is invalid" if $InvalidOperatingCostQues
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section07_s7r3__id.dta", replace
// *restore
//
//
// ***************************************************
// *9: SUMMARY OF OPERATING COST -OTHER
// ***************************************************
// *Sec 07.9, Roster:OPERATING COST Other is invalid
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
// *preserve
// merge 1:m interview__id using "$HQData\s7r3.dta"
// keep if _merge == 3  // Drop observations only in the master data
// drop _merge
// 
// gl InvalidOperatingCostOSQues ($isAnySector & (inlist(s7r3__id, 99) & missing(s7r3_oth)))
//
// replace section = "Section 07" if $InvalidOperatingCostOSQues
// replace error_flag = 1 if $InvalidOperatingCostOSQues
// replace errorCheck = "Invalid Response" if $InvalidOperatingCostOSQues
// replace errorMessag = "Operating Cost ID-OS='"+s7r3_oth+"' is invalid" if $InvalidOperatingCostOSQues
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section07_s7r3_oth.dta", replace
// *restore
//
//
// ***************************
// *Question 9.1 second check
// ***************************
// *Sec 07.9.1, Delivery Cost is invalid
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
// *preserve
// merge 1:m interview__id using "$HQData\s7r3.dta"
// keep if _merge == 3  // Drop observations only in the master data
// drop _merge
// 
// decode s7r3__id, gen(s7r3__id_new)
//
// gl InvalidDeliveCostQues ($isAnySector & (missing(s7r3q1) | !inrange(s7r3q1, 0,9999999999.99)))
//
// replace section = "Section 07" if $InvalidDeliveCostQues
// replace error_flag = 1 if $InvalidDeliveCostQues
// replace errorCheck = "Invalid Response" if $InvalidDeliveCostQues
// replace errorMessag = "The description='"+s7r3__id_new+"', but  delivery cost='"+string(s7r3q1)+"' is invalid" if $InvalidDeliveCostQues
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section07_s7r3q1.dta", replace
// *restore
//
//
// ***************************************************
// *10: OTHER COST DURING THE 2023 FINANCIAL YEAR
// ***************************************************
// *Sec 07.10, Roster: OTHER COST is invalid
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
// *preserve
// merge 1:m interview__id using "$HQData\s7r4.dta"
// keep if _merge == 3  // Drop observations only in the master data
// drop _merge
//  
// decode s7r4__id, gen(s7r4__id_new)
// 
// gl InvalidOtherCostQues ($isAnySector & (missing(s7r4__id) | (!inrange(s7r4__id, 1,26)|!inrange(s7r4__id, 99,100))))
//
// replace section = "Section 07" if $InvalidOtherCostQues
// replace error_flag = 1 if $InvalidOtherCostQues
// replace errorCheck = "Invalid Response" if $InvalidOtherCostQues
// replace errorMessag = "Other Cost='"+s7r4__id_new+"' is invalid" if $InvalidOtherCostQues
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section07_s7r4__id.dta", replace
// *restore
//
//
// ***************************************************
// *9: SUMMARY OF OPERATING COST -OTHER
// ***************************************************
// *Sec 07.9, Roster:OTHER COST- Other is invalid
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
// *preserve
// merge 1:m interview__id using "$HQData\s7r4.dta"
// keep if _merge == 3  // Drop observations only in the master data
// drop _merge
// 
// gl InvalidOtherCostOSQues ($isAnySector & (inlist(s7r4__id, 99) & missing(s7r4_oth)))
//
// replace section = "Section 07" if $InvalidOtherCostOSQues
// replace error_flag = 1 if $InvalidOtherCostOSQues
// replace errorCheck = "missing check"  if $InvalidOtherCostOSQues 
// replace errorMessag = "Que. 10(OS): Other Cost ID-OS cannot be blank" if $InvalidOtherCostOSQues
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section07_s7r4_oth.dta", replace
// *restore
//
//
// ****************************
// *Question 10.1 second check
// ****************************
// *Sec 07.10.1, Cost is invalid
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
// *preserve
// merge 1:m interview__id using "$HQData\s7r4.dta"
// keep if _merge == 3  // Drop observations only in the master data
// drop _merge
//  
// gl InvalidCostQues ($isAnySector & (missing(s7r4q1) | !inrange(s7r4q1, 1,9999999999.99)))
//
// replace section = "Section 07" if $InvalidCostQues
// replace error_flag = 1 if $InvalidCostQues
// replace errorCheck = cond(missing(s7r4q1), "Mising response", "Invalid selection") if $InvalidCostQues
// replace errorMessag = cond(missing(s7r4q1), "Que. 10.1: Cost cannot be blank", "Que. 10.1: Cost is invalid") if $InvalidCostQues
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section07_s7r4q1.dta", replace
// *restore
//
//
// ***************************************************
// *11. PAYMENT TO SUB-CONTRACTORS FOR WORK DONE
// ***************************************************
// ****************************
// *Question 11.1 second check
// ****************************
// *Sec 07.11.1, Total payments to sub-contractors for work  is invalid
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta" , clear
// *preserve
// merge 1:m interview__id using "$HQData\ibes_ii.dta"
// keep if _merge == 3  // Drop observations only in the master data
// drop _merge
//  
// gl InvalidSubContracttQues ($isAnySector & inlist(ids01,5) & (missing(s6q6c) | !inrange(s6q6c, 1,9999999999.99)))
//
// replace section = "Section 07" if $InvalidSubContracttQues
// replace error_flag = 1 if $InvalidSubContracttQues
// replace errorCheck = cond(missing(s7r4q1), "Mising response", "Invalid selection") if $InvalidSubContracttQues
// replace errorMessag = cond(missing(s7r4q1), "Que. 11: Total payments to sub-contractors for work cannot be blank", "Que. 11: Total payments to sub-contractors for work is invalid") if $InvalidSubContracttQues
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section07_s6q6c.dta", replace
// *restore
//
//
