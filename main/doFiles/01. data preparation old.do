*-----------------------------------------
// renaming of meta-data vars 
*-----------------------------------------
gl metaDataVars (interview__key interview__id id00 EstablishmentName Sub_Sector Region regCode District distCode DistrictTypeCode Sub_MetroCode EZ EA_num Estab_number StreetName Suburb ExactLocation Town Team Supervisor SupervisorContact EnumeratorName EnumContact qtype interview__id)

// gl metaDataSectionVars (interview__key interview__id id00 EstablishmentName Sub_Sector Region regCode District distCode DistrictTypeCode Sub_MetroCode EZ EA_num Estab_number StreetName Suburb ExactLocation Town Team Supervisor SupervisorContact EnumeratorName EnumContact )

gl metaGpsVars (nav1__Latitude nav1__Longitude nav1__Accuracy nav1__Altitude nav1__Timestamp s00a_q13__Latitude s00a_q13__Longitude s00a_q13__Accuracy s00a_q13__Altitude s00a_q13__Timestamp)

gl dateTimeVars ( currentDate current_year current_month yearAgo_month_string)




use "$HQData\ibes_ii.dta", clear
ren (id06 ids01 id10 id10a id11 ///
id11a id11b id11c id11d id07 ///
id08 id09 id12 id01 id02 ///
id01a id02a id03 id05 id11e s1qso2) ///
(EstablishmentName 	Sub_Sector 			Region 			regCode 		District ///
distCode 			DistrictTypeCode 	Sub_MetroCode 	EA_num			StreetName /// regdist
Suburb 			ExactLocation 		Town 			EnumeratorName	EnumContact ///
Supervisor 		SupervisorContact 	Team 			EZ 				Estab_number 		qtype)

* fix encode regionCode variable
gen region=.
replace region=1 if Region=="WESTERN"
replace region=2 if Region=="CENTRAL"
replace region=3 if Region=="GREATER ACCRA" 
replace region=4 if Region=="VOLTA" 
replace region=5 if Region=="EASTERN" 
replace region=6 if Region=="ASHANTI" 
replace region=7 if Region=="WESTERN NORTH" 
replace region=8 if Region=="AHAFO" 
replace region=9 if Region=="BONO" 
replace region=10 if Region=="BONO EAST" 
replace region=11 if Region=="OTI"  
replace region=12 if Region=="NORTHERN" 
replace region=13 if Region=="SAVANNAH" 
replace region=14 if Region=="NORTH EAST" 
replace region=15 if Region=="UPPER EAST" 
replace region=16 if Region=="UPPER WEST"
 tab region,m
 lab def region 1"Western" 2 "Central" 3"Greater Accra" 4"Volta" 5"Eastern" 6"Ashanti"  7"Western North" 8"Ahafo" 9"Bono" 10"Bono East" 11"Oti"  12"Northern" 13"Savannah" 14"North East" 15 "Upper East" 16"Upper West"
lab val region region
 tab region,m
 
 drop Region
 ren region  Region
 order $metaDataVars
 
 * to do
 * remove string ##N/A## and replace with blanks in Stata

*-----------------------------------------
// SORT THE DATA SET , the data by regioncode
*-----------------------------------------
sort regCode distCode DistrictTypeCode Sub_MetroCode Team EZ EA_num Estab_number
// save "$prepData\ibes_ii.dta", replace

// check invalid date cases

*-----------------------------------------
// INVALID DATE
*-----------------------------------------
* practice is on 30th may
// gen surveyStartDate = "2025-05-30"
gen surveyStartDate = "2025-05-27"  // day1 field practice was on the 27th
gen todaySystemDate = "$S_DATE" 
// egen interview_date = ends(currentDate), punct(T)
egen interview_date = ends(s00a_q08a), punct(T)
gen interview_date_num = date(interview_date, "YMD")

egen gps_date = ends(s00a_q13__Timestamp), punct(T)
gen gps_date_num = date(gps_date, "YMD")

* check if the date of interveiw (ie currentDate) is between survey startDate and current Date (i.e now)
gen byte date_within_surveyPeriod = inrange(interview_date_num, date(surveyStartDate, "YMD"), date(todaySystemDate, "DMY")) & inrange(gps_date_num, date(surveyStartDate, "YMD"), date(todaySystemDate, "DMY")) 

// value label for type of legal organization
lab def id20 1 "Sole Proprietorship" 2 "Partnership" 3 "Limited Liability Company" 4 "Unlimited Liability Company(Private and Public)" 5 "Subsidary Business" 6 "Proffesional Body" 7 "Government Institution" 8 "Non-Government Organization (NGO)" 9 "Cooperative" 10 "Association/Group" 11 "Exteranl Company" , modify

label values id20 id20
sort $metaDataVars
save "$prepData\ibes_ii Estabs_all both_wrong_and_valid_Dates.dta", replace

keep if date_within_surveyPeriod ==0
save "$prepData\ibes_ii Estabs wrong_dateCase_only.dta", replace

use "$prepData\ibes_ii Estabs_all both_wrong_and_valid_Dates.dta", clear
** bring back this code for running
keep if date_within_surveyPeriod >= 1
sort $metaDataVars 
save "$prepData\ibes_ii Estabs valid_dateCase_only.dta", replace

*-----------------------------------------
// CHECK FOR DUPLICATES
*-----------------------------------------
// check dulicated id01 cases
// use "$prepData\ibes_ii.dta", clear
* gen duplicates by establishment full id 
duplicates tag id00, gen(dups0)

* gen duplicates by meta identifiers excluding id00
duplicates tag regCode distCode DistrictTypeCode Sub_MetroCode EZ EA_num Estab_number, gen(dups1)

// save the establishment duplicating status file to the prep folder
save "$prepData\ibes_ii Estabs_all both_unique_and_dups.dta", replace

// save the dups only, to the prep folder
keep if dups0 > 1 | dups1 > 1
// save the dups only, to the prep folder
save "$prepData\ibes_ii Estabs_duplicating_only", replace

//  save no_dups observations to the prep folder 

use "$prepData\ibes_ii Estabs_all both_unique_and_dups.dta", clear
save "$prepData\ibes_ii Estabs_unique_only", replace

*-----------------------------------------
// Group the data by Sections
*-----------------------------------------
// note: this only saves cases that have passed the wrong-date and duplicate checks , and had no issues there

* 1. SAVE Section 0:COVER, Section0A:INTERVIEW COVERPAGE as well as Section01:IDENTIFICATION AND CLASSIFICATION INFORMATION together
*--------------------------------------------------------------------------------------------------------------------------------------


use "$prepData\ibes_ii Estabs_unique_only", clear
* Save Section 0:Cover and Section 1:Identification
keep $metaDataVars $metaGpsVars $dateTimeVars id* s00a* id* s1q* interview__status
sort $metaDataVars
save "$sectionData\section_00_01 COVER, IDENTIFICATION AND CLASSIFICATION", replace


* 2. SAVE Section 2:EMPLOYMENT AND EARNINGS
*--------------------------------------------- 
use "$HQData\s2r1_persons_engaged_1.dta" , clear
// drop s2r1q1
gl byGroupVars (interview__key interview__id)
// first collapse sum condition, personsEngaged 
preserve
keep if s2r1_persons_engaged_1__id==1 
if _N == 0 {
gen s2_personsEngaged_Total =.
gen s2_personsEngaged_Male =.
gen s2_personsEngaged_Female =. 
} 
if _N > 0 {
collapse (sum) s2_personsEngaged_Total=s2r1q1 s2_personsEngaged_Male=s2r1q2  s2_personsEngaged_Female=s2r1q3 , by(interview__key interview__id) 
}

* to do, label the variable descriptions 
// label variable personEngageVariable "Person Engaged Variable Description"

save"$tempsaveDir\condition1_sums" , replace
restore

// second collapse sum condition, employee
preserve
keep if s2r1_persons_engaged_1__id==2
if _N == 0 {
gen s2_employee_Total =.
gen s2_employee_Male =.
gen s2_employee_Female =. 
} 
if _N > 0 {
collapse (sum) s2_employee_Total=s2r1q1 s2_employee_Male=s2r1q2  s2_employee_Female=s2r1q3 , by ($byGroupVars)
}
save "$tempsaveDir\condition2_sums" , replace
restore

// third collapse sum condition, operatives
preserve
keep if s2r1_persons_engaged_1__id==3
if _N == 0 {
gen s2_operatives_Total =.
gen s2_operatives_Male =.
gen s2_operatives_Female =. 
} 
if _N > 0 {
collapse (sum) s2_operatives_Total=s2r1q1 s2_operatives_Male=s2r1q2  s2_operatives_Female=s2r1q3 , by ($byGroupVars)
}
save "$tempsaveDir\condition3_sums" , replace
restore

// fourth collapse sum condition, paid managers and directors
preserve
keep if s2r1_persons_engaged_1__id==4
if _N == 0 {
gen s2_paidMangrDirs_Total =.
gen s2_paidMangrDirs_Male =.
gen s2_paidMangrDirs_Female =. 
} 
if _N > 0 {
collapse (sum) s2_paidMangrDirs_Total=s2r1q1 s2_paidMangrDirs_Male=s2r1q2  s2_paidMangrDirs_Female=s2r1q3 , by ($byGroupVars)
}
save "$tempsaveDir\condition4_sums" , replace
restore

// fifth collapse sum condition, Other Employees
preserve
keep if s2r1_persons_engaged_1__id==5
if _N == 0 {
gen s2_otherEmployees_Total =.
gen s2_otherEmployees_Male =.
gen s2_otherEmployees_Female =. 
} 
if _N > 0 {
collapse (sum) s2_otherEmployees_Total=s2r1q1 s2_otherEmployees_Male=s2r1q2  s2_otherEmployees_Female=s2r1q3 , by ($byGroupVars)
}
save "$tempsaveDir\condition5_sums" , replace
restore

// sixth collapse sum condition, unpaidWorkers
preserve
keep if s2r1_persons_engaged_1__id==6
if _N == 0 {
gen s2_unpaidWorkers_Total =.
gen s2_unpaidWorkers_Male =.
gen s2_unpaidWorkers_Female =. 
} 
if _N > 0 {
collapse (sum) s2_unpaidWorkers_Total=s2r1q1 s2_unpaidWorkers_Male=s2r1q2  s2_unpaidWorkers_Female=s2r1q3 , by ($byGroupVars)
}
save "$tempsaveDir\condition6_sums" , replace
restore    

// seventh collapse sum condition, working Proprietors and active business partners
preserve
keep if s2r1_persons_engaged_1__id==7
if _N == 0 {
keep interview__key interview__id
gen s2_wkPropActBuzPrt_Total =.
gen s2_wkPropActBuzPrt_Male =.
gen s2_wkPropActBuzPrt_Female =. 
} 
if _N > 0 {
collapse (sum) s2_wkPropActBuzPrt_Total=s2r1q1 s2_wkPropActBuzPrt_Male=s2r1q2  s2_wkPropActBuzPrt_Female=s2r1q3 , by ($byGroupVars)
}
save "$tempsaveDir\condition7_sums" , replace
restore

// eight collapse sum condition, working Proprietors and active business partners
preserve
keep if s2r1_persons_engaged_1__id==8
if _N == 0 {
keep interview__key interview__id
gen s2_learners_Total =.
gen s2_learners_Male =.
gen s2_learners_Female =. 
} 
if _N > 0 {
collapse (sum) s2_learners_Total=s2r1q1 s2_learners_Male=s2r1q2  s2_learners_Female=s2r1q3 , by ($byGroupVars)
}
save "$tempsaveDir\condition8_sums" , replace
restore

// Ninth collapse sum condition, working Proprietors and active business partners
preserve
keep if s2r1_persons_engaged_1__id==9
if _N == 0 {
keep interview__key interview__id
gen s2_contrbFamWkr_Total =.
gen s2_contrbFamWkr_Male =.
gen s2_contrbFamWkr_Female =. 
} 

if _N > 0 {
collapse (sum) s2_contrbFamWkr_Total=s2r1q1 s2_contrbFamWkr_Male=s2r1q2  s2_contrbFamWkr_Female=s2r1q3 , by ($byGroupVars)
}
save "$tempsaveDir\condition9_sums" , replace
restore

// tenth collapse sum condition, working Proprietors and active business partners
preserve
keep if s2r1_persons_engaged_1__id==10
if _N == 0 {
keep interview__key interview__id
gen s2_learners_Total =.
gen s2_learners_Male =.
gen s2_learners_Female =. 
} 

if _N > 0 {
collapse (sum) s2_learners_Total=s2r1q1 s2_learners_Male=s2r1q2  s2_learners_Female=s2r1q3 , by ($byGroupVars)
}
save "$tempsaveDir\condition10_sums" , replace
restore

// eleventh collapse sum condition, working Proprietors and active business partners
preserve
keep if s2r1_persons_engaged_1__id==11
if _N == 0 {
keep interview__key interview__id
gen s2_nationalService_Total =.
gen s2_nationalService_Male =.
gen s2_nationalService_Female =. 
} 

if _N > 0 {
collapse (sum) s2_nationalService_Total=s2r1q1 s2_nationalService_Male=s2r1q2  s2_nationalService_Female=s2r1q3 if s2r1_persons_engaged_1__id==11, by ($byGroupVars)
}
save "$tempsaveDir\condition11_sums" , replace 
restore

use "$tempsaveDir\condition1_sums", clear
merge 1:1 $byGroupVars using "$tempsaveDir\condition2_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\condition3_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\condition4_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\condition5_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\condition6_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\condition7_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\condition8_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\condition9_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\condition10_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\condition11_sums", nogenerate
save "$tempsaveDir\personsEngagedRoster_sums" , replace 

// merge with main ibes meta data
use "$prepData\ibes_ii Estabs_unique_only", clear
keep $metaDataVars s2q*

merge 1:1 $byGroupVars using "$tempsaveDir\personsEngagedRoster_sums"
keep if _merge==3
drop _m
order $metaDataVars s2_* s2q*
sort $metaDataVars

// gl canStartInterv (s00a_q10a == 1 | s00a_q10b == 1 | s00a_q10c == 1) // ABLE to start interview is Yes in any of the three tries
// gl isAnySector ((s00a_q09a == 1 | s00a_q09b == 1 | s00a_q09c==1 ) & (s00a_q10a == 1 | s00a_q10b == 1 | s00a_q10c == 1) & inrange(s1qso2,1,9))
// keep if $canStartInterv $isAnySector

save "$sectionData\section_02 EMPLOYMENT AND EARNINGS", replace

* 3. SAVE Section 3:BUSINESS CHALLENGES AND OPPORTUNITIES
*---------------------------------------------------------
use "$prepData\ibes_ii Estabs_unique_only", clear
keep $metaDataVars s3q*
sort $metaDataVars
save "$sectionData\section_03 BUSINESS CHALLENGES AND OPPORTUNITIES", replace


* 4. SAVE Section 4:BUSINESS OPERATIONS
*---------------------------------------------------------
use "$prepData\ibes_ii Estabs_unique_only", clear
keep $metaDataVars s4q*
sort $metaDataVars
save "$sectionData\section_04 BUSINESS OPERATIONS", replace


* 5. SAVE Section 5:STOCK
*---------------------------------------------------------
use "$HQData\s5r1_stock.dta" , clear
// lab def stock_id 1 "agric_Input" 2 "otherMaterialSupply" 3 "liveStockFishPoultry" 4 "farmProdPurchResale" 5 "otherGoodsPurchResale" 6 "agricOutputHarvestStored" 7 "herdsLivstockFishPoultry" 8 "cropForestPlantation" 9 "rawMatSupply_currReplaceCost" 10 "workInProgress" 11 "fuel" 12 "finishedGoods" 13 "goodsPurchResale_purchPrice" 14 "goodsPurchResale_exFacPrice" 15 "otheSpecify" 100 "total" , modify
// label values s5r1_stock__id stock_id 
// drop s5r1_stock__id
// order interview__key interview__id stockID
// decode s5r1_stock__id, gen(stockID)

gl byGroupVars (interview__key interview__id)
// first collapse sum condition, 5.1 Agriculture input e.g. fertilizer, pesticides, seeds and seedlings, breeding stocks-day old chicks, fingerlings, feed, etc.(in purchasers' price)
preserve
keep if s5r1_stock__id==1 
if _N == 0 {
keep interview__key interview__id
gen AgricInput_stockYrB =.
gen AgricInput_stockYrE =.
gen AgricInput_stockYrBTot =. 
gen AgricInput_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) AgricInput_stockYrB=s5r1q1 AgricInput_stockYrE=s5r1q2 (first) AgricInput_stockYrBTot=s5r1q1_total AgricInput_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable AgricInput_stockYrB "Agriculture input , Value at Beg of Fin.Yr"
label variable AgricInput_stockYrE "Agriculture input , Value at End oF Fin.Yr"
label variable AgricInput_stockYrBTot "Agriculture input, Total Beg of Fin.Yr"
label variable AgricInput_stockYrETot "Agriculture input, Total End oF Fin.Yr"

save "$tempsaveDir\stock1_sums" , replace
restore

// second collapse sum condition,  5.2 Other materials and supplies e.g. heating bulbs, boots, mask, etc. (in purchasers' price)
preserve
keep if s5r1_stock__id==2
if _N == 0 {
keep interview__key interview__id
gen othMatSupply_stockYrB =.
gen othMatSupply_stockYrE =.
gen othMatSupply_stockYrBTot =. 
gen othMatSupply_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) othMatSupply_stockYrB=s5r1q1  othMatSupply_stockYrE=s5r1q2 (first)  othMatSupply_stockYrBTot=s5r1q1_total othMatSupply_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable othMatSupply_stockYrB "Other materials and supplies , Value at Beg of Fin.Yr"
label variable othMatSupply_stockYrE "Other materials and supplies , Value at End oF Fin.Yr"
label variable othMatSupply_stockYrBTot "Other materials and supplies, Total Beg of Fin.Yr"
label variable othMatSupply_stockYrETot "Other materials and supplies, Total End oF Fin.Yr"

save "$tempsaveDir\stock2_sums" , replace
restore

// third collapse sum condition, 5.3 Livestock, fish or poultry purchased for resale(ex-fac.Price)e.g. cattle, sheep, goat, broilers, tilapia, etc. (ex-fac.Price
preserve
keep if s5r1_stock__id==3
if _N == 0 {
keep interview__key interview__id
gen livestockFishPltry_stockYrB =.
gen livestockFishPltry_stockYrE =.
gen livestockFishPltry_stockYrBTot =. 
gen livestockFishPltry_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) livestockFishPltry_stockYrB=s5r1q1  livestockFishPltry_stockYrE=s5r1q2 (first)  livestockFishPltry_stockYrBTot=s5r1q1_total livestockFishPltry_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable livestockFishPltry_stockYrB "Livestock, fish or poultry purchased for resale(ex-fac.Price), Value at Beg of Fin.Yr"
label variable livestockFishPltry_stockYrE "Livestock, fish or poultry purchased for resale(ex-fac.Price), Value at End oF Fin.Yr"
label variable livestockFishPltry_stockYrBTot "Livestock, fish or poultry purchased for resale(ex-fac.Price), Total Beg of Fin.Yr"
label variable livestockFishPltry_stockYrETot "Livestock, fish or poultry purchased for resale(ex-fac.Price), Total End oF Fin.Yr"

save "$tempsaveDir\stock3_sums" , replace
restore 

// fourth collapse sum condition, 5.4 Farm produce purchased for resale e.g., paddy rice, cocoa beans, yams, etc. (ex-fac.Price)
preserve
keep if s5r1_stock__id==4
if _N == 0 {
keep interview__key interview__id
gen farmProdPurResale_stockYrB =.
gen farmProdPurResale_stockYrE =.
gen farmProdPurResale_stockYrBTot =. 
gen farmProdPurResale_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) farmProdPurResale_stockYrB=s5r1q1  farmProdPurResale_stockYrE=s5r1q2 (first)  farmProdPurResale_stockYrBTot=s5r1q1_total farmProdPurResale_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}
label variable farmProdPurResale_stockYrB "Farm produce purchased for resale , Value at Beg of Fin.Yr"
label variable farmProdPurResale_stockYrE "Farm produce purchased for resale , Value at End oF Fin.Yr"
label variable farmProdPurResale_stockYrBTot "Farm produce purchased for resale, Total Beg of Fin.Yr"
label variable farmProdPurResale_stockYrETot "Farm produce purchased for resale, Total End oF Fin.Yr"


save "$tempsaveDir\stock4_sums" , replace
restore

// fifth collapse sum condition, 5.5 Other goods purchased for resale e.g. feed, fertilizer, pesticides, and seedlings (ex-fac.Price)
preserve
keep if s5r1_stock__id==5
if _N == 0 {
keep interview__key interview__id
gen othGdsPurchResale_stockYrB =.
gen othGdsPurchResale_stockYrE =.
gen othGdsPurchResale_stockYrBTot =. 
gen othGdsPurchResale_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) othGdsPurchResale_stockYrB=s5r1q1  othGdsPurchResale_stockYrE=s5r1q2 (first)  othGdsPurchResale_stockYrBTot=s5r1q1_total othGdsPurchResale_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable othGdsPurchResale_stockYrB "Other goods purchased for resale, Value at Beg of Fin.Yr"
label variable othGdsPurchResale_stockYrE "Other goods purchased for resale, Value at End oF Fin.Yr"
label variable othGdsPurchResale_stockYrBTot "Other goods purchased for resale, Total Beg of Fin.Yr"
label variable othGdsPurchResale_stockYrETot "Other goods purchased for resale, Total End oF Fin.Yr"

save "$tempsaveDir\stock5_sums" , replace
restore

// sixth collapse sum condition, 5.6 Agricultural outputs harvested, and stored in warehouses, barns and other storage facilities, etc. (ex-fac.Price
preserve
keep if s5r1_stock__id==6
if _N == 0 {
keep interview__key interview__id
gen agricOutputHarvSt_stockYrB =.
gen agricOutputHarvSt_stockYrE =.
gen agricOutputHarvSt_stockYrBTot =. 
gen agricOutputHarvSt_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) agricOutputHarvSt_stockYrB=s5r1q1  agricOutputHarvSt_stockYrE=s5r1q2 (first)  agricOutputHarvSt_stockYrBTot=s5r1q1_total agricOutputHarvSt_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable agricOutputHarvSt_stockYrB "Agric outputs harvested, stored in warehouses, etc, Value at Beg of Fin.Yr"
label variable agricOutputHarvSt_stockYrE "Agric outputs harvested, stored in warehouses, etc, Value at End oF Fin.Yr"
label variable agricOutputHarvSt_stockYrBTot "Agric outputs harvested, stored in warehouses, etc,Total at Beg of Fin.Yr"
label variable agricOutputHarvSt_stockYrETot "Agric outputs harvested, stored in warehouses, etc,Total at End oF Fin.Yr"

save "$tempsaveDir\stock6_sums" , replace
restore

// seventh collapse sum condition, 5.7 Herds of livestock, fish or poultry including old-layers produced within the establishment not kept for reproduction (ex-fac.Price)
preserve
keep if s5r1_stock__id==7
if _N == 0 {
keep interview__key interview__id
gen herdsLivstkFishPltry_stockYrB =.
gen herdsLivstkFishPltry_stockYrE =.
gen herdsLivstkFishPltry_stockYrBTot =. 
gen herdsLivstkFishPltry_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) herdsLivstkFishPltry_stockYrB=s5r1q1  herdsLivstkFishPltry_stockYrE=s5r1q2 (first)  herdsLivstkFishPltry_stockYrBTot=s5r1q1_total herdsLivstkFishPltry_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable herdsLivstkFishPltry_stockYrB "Herds of livestock, fish or poultry (ex-fac.Price), Value at Beg of Fin.Yr"
label variable herdsLivstkFishPltry_stockYrE "Herds of livestock, fish or poultry (ex-fac.Price), Value at End oF Fin.Yr"
label variable herdsLivstkFishPltry_stockYrBTot "Herds of livestock, fish or poultry (ex-fac.Price),Total at Beg of Fin.Yr"
label variable herdsLivstkFishPltry_stockYrETot "Herds of livestock, fish or poultry (ex-fac.Price),Total at End oF Fin.Yr"

save "$tempsaveDir\stock7_sums" , replace
restore

// Eighth collapse sum condition, 5.8 Crops and forest plantation (work in progress) (in purchasers’ price)
preserve
keep if s5r1_stock__id==8
if _N == 0 {
keep interview__key interview__id
gen cropForestPlanta_stockYrB =.
gen cropForestPlanta_stockYrE =.
gen cropForestPlanta_stockYrBTot =. 
gen cropForestPlanta_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) cropForestPlanta_stockYrB=s5r1q1  cropForestPlanta_stockYrE=s5r1q2 (first)  cropForestPlanta_stockYrBTot=s5r1q1_total cropForestPlanta_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable cropForestPlanta_stockYrB "Crops and forestPantation (work in progress, purchPrice), Value at Beg of Fin.Yr"
label variable cropForestPlanta_stockYrE "Crops and forestPantation (work in progress, purchPrice), Value at End oF Fin.Yr"
label variable cropForestPlanta_stockYrBTot "Crops and forestPantation (work in progress, purchPrice),Total at Beg of Fin.Yr"
label variable cropForestPlanta_stockYrETot "Crops and forestPantation (work in progress, purchPrice),Total at End oF Fin.Yr"

save "$tempsaveDir\stock8_sums" , replace
restore

// Nineth collapse sum condition, 5.9 Raw materials and supplies (at current replacement cost in purchasers' prices)
preserve
keep if s5r1_stock__id==9
if _N == 0 {
keep interview__key interview__id
gen rawMatSup_cReC_stockYrB =.
gen rawMatSup_cReC_stockYrE =.
gen rawMatSup_cReC_stockYrBTot =. 
gen rawMatSup_cReC_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) rawMatSup_cReC_stockYrB=s5r1q1  rawMatSup_cReC_stockYrE=s5r1q2 (first)  rawMatSup_cReC_stockYrBTot=s5r1q1_total rawMatSup_cReC_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable rawMatSup_cReC_stockYrB "Raw materials and supplies(curr.Replace.Cost in purchPrice), Value at Beg of Fin.Yr"
label variable rawMatSup_cReC_stockYrE "Raw materials and supplies(curr.Replace.Cost in purchPrice), Value at End oF Fin.Yr"
label variable rawMatSup_cReC_stockYrBTot "Raw materials and supplies(curr.Replace.Cost in purchPrice),Total at Beg of Fin.Yr"
label variable rawMatSup_cReC_stockYrETot "Raw materials and supplies(curr.Replace.Cost in purchPrice),Total at End oF Fin.Yr"

save "$tempsaveDir\stock9_sums" , replace
restore

// tenth collapse sum condition, 5.10 Work in progress (in purchasers’ prices)
preserve
keep if s5r1_stock__id==10
if _N == 0 {
keep interview__key interview__id
gen workInProgress_stockYrB =.
gen workInProgress_stockYrE =.
gen workInProgress_stockYrBTot =. 
gen workInProgress_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) workInProgress_stockYrB=s5r1q1  workInProgress_stockYrE=s5r1q2 (first)  workInProgress_stockYrBTot=s5r1q1_total workInProgress_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable workInProgress_stockYrB "Work in progress (purchPrice), Value at Beg of Fin.Yr"
label variable workInProgress_stockYrE "Work in progress (purchPrice), Value at End oF Fin.Yr"
label variable workInProgress_stockYrBTot "Work in progress (purchPrice),Total at Beg of Fin.Yr"
label variable workInProgress_stockYrETot "Work in progress (purchPrice),Total at End oF Fin.Yr"

save "$tempsaveDir\stock10_sums" , replace
restore

// eleventh collapse sum condition, 5.11 Fuel (in purchasers’ prices”)
preserve
keep if s5r1_stock__id==11
if _N == 0 {
keep interview__key interview__id
gen fuel_stockYrB =.
gen fuel_stockYrE =.
gen fuel_stockYrBTot =. 
gen fuel_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) fuel_stockYrB=s5r1q1  fuel_stockYrE=s5r1q2 (first)  fuel_stockYrBTot=s5r1q1_total fuel_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable fuel_stockYrB "Fuel (purchPrice), Value at Beg of Fin.Yr"
label variable fuel_stockYrE "Fuel (purchPrice), Value at End oF Fin.Yr"
label variable fuel_stockYrBTot "Fuel (purchPrice),Total at Beg of Fin.Yr"
label variable fuel_stockYrETot "Fuel (purchPrice),Total at End oF Fin.Yr"

save "$tempsaveDir\stock11_sums" , replace
restore

// twelfth collapse sum condition, 5.12 Finished goods (at ex-factory prices)
preserve
keep if s5r1_stock__id==12
if _N == 0 {
keep interview__key interview__id
gen finishedGoods_stockYrB =.
gen finishedGoods_stockYrE =.
gen finishedGoods_stockYrBTot =. 
gen finishedGoods_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) finishedGoods_stockYrB=s5r1q1  finishedGoods_stockYrE=s5r1q2 (first)  finishedGoods_stockYrBTot=s5r1q1_total finishedGoods_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable finishedGoods_stockYrB "Finished goods(ex-fac.Price), Value at Beg of Fin.Yr"
label variable finishedGoods_stockYrE "Finished goods(ex-fac.Price), Value at End oF Fin.Yr"
label variable finishedGoods_stockYrBTot "Finished goods(ex-fac.Price),Total at Beg of Fin.Yr"
label variable finishedGoods_stockYrETot "Finished goods(ex-fac.Price),Total at End oF Fin.Yr"

save "$tempsaveDir\stock12_sums" , replace
restore

// thirteenth collapse sum condition, 5.13 Goods purchased for resale (purchasers’ price)
preserve
keep if s5r1_stock__id==13
if _N == 0 {
keep interview__key interview__id
gen gdsPurchResal_pPric_stockYrB =.
gen gdsPurchResal_pPric_stockYrE =.
gen gdsPurchResal_pPric_stockYrBTot =. 
gen gdsPurchResal_pPric_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) gdsPurchResal_pPric_stockYrB=s5r1q1  gdsPurchResal_pPric_stockYrE=s5r1q2 (first)  gdsPurchResal_pPric_stockYrBTot=s5r1q1_total gdsPurchResal_pPric_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable gdsPurchResal_pPric_stockYrB "Goods purchased for resale(purchPrice), Value at Beg of Fin.Yr"
label variable gdsPurchResal_pPric_stockYrE "Goods purchased for resale(purchPrice), Value at End oF Fin.Yr"
label variable gdsPurchResal_pPric_stockYrBTot "Goods purchased for resale(purchPrice),Total at Beg of Fin.Yr"
label variable gdsPurchResal_pPric_stockYrETot "Goods purchased for resale(purchPrice),Total at End oF Fin.Yr"

save "$tempsaveDir\stock13_sums" , replace
restore

// fourteenth collapse sum condition, 5.14 Goods purchased for resale (ex-fac.Prices)
preserve
keep if s5r1_stock__id==14
if _N == 0 {
keep interview__key interview__id
gen gdsPurResale_exFaPr_stockYrB =.
gen gdsPurResale_exFaPr_stockYrE =.
gen gdsPurResale_exFaPr_stockYrBTot =. 
gen gdsPurResale_exFaPr_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) gdsPurResale_exFaPr_stockYrB=s5r1q1  gdsPurResale_exFaPr_stockYrE=s5r1q2 (first)  gdsPurResale_exFaPr_stockYrBTot=s5r1q1_total gdsPurResale_exFaPr_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable gdsPurResale_exFaPr_stockYrB "Goods purchased for resale(ex-fac.Price), Value at Beg of Fin.Yr"
label variable gdsPurResale_exFaPr_stockYrE "Goods purchased for resale(ex-fac.Price), Value at End oF Fin.Yr"
label variable gdsPurResale_exFaPr_stockYrBTot "Goods purchased for resale(ex-fac.Price),Total at Beg of Fin.Yr"
label variable gdsPurResale_exFaPr_stockYrETot "Goods purchased for resale(ex-fac.Price),Total at End oF Fin.Yr"

save "$tempsaveDir\stock14_sums" , replace
restore

// fifteenth collapse sum condition, 5.14 Goods purchased for resale (ex-fac.Prices)
preserve
keep if s5r1_stock__id==99
if _N == 0 {
gen otherSpecified_stockYrB =""
gen otherSpecified_stockYrB =.
gen otherSpecified_stockYrE =.
gen otherSpecified_stockYrBTot =. 
gen otherSpecified_stockYrETot =. 
} 
if _N > 0 {
collapse (first) otherSpecified_stock=s5r1_oth (sum) otherSpecified_stockYrB=s5r1q1  otherSpecified_stockYrE=s5r1q2 (first)  otherSpecified_stockYrBTot=s5r1q1_total otherSpecified_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable otherSpecified_stock "Other-Specified Stock Description text"
label variable otherSpecified_stockYrB "other-specified Stock Description, Value at Beg of Fin.Yr"
label variable otherSpecified_stockYrE "other-specified Stock Description, Value at End oF Fin.Yr"
label variable otherSpecified_stockYrBTot "other-specified Stock Description,Total at Beg of Fin.Yr"
label variable otherSpecified_stockYrETot "other-specified Stock Description,Total at End oF Fin.Yr"

save "$tempsaveDir\stock15_sums" , replace
restore

// Sixteenth collapse sum condition, TOTAL STOCK
preserve
keep if s5r1_stock__id==100
if _N == 0 {
gen total_stockYrB =.
gen total_stockYrE =.
gen total_stockYrBTot =. 
gen total_stockYrETot =. 
} 
if _N > 0 {
collapse (sum) total_stockYrB=s5r1q1  total_stockYrE=s5r1q2 (first)  total_stockYrBTot=s5r1q1_total total_stockYrETot=s5r1q2_total, by($byGroupVars ) 
}

label variable total_stockYrB "Total Stock, Value at Beg of Fin.Yr"
label variable total_stockYrE "Total Stock, Value at End oF Fin.Yr"
label variable total_stockYrBTot "Total Stock,Total at Beg of Fin.Yr"
label variable total_stockYrETot "Total Stock,Total at End oF Fin.Yr"

save "$tempsaveDir\stock16_sums" , replace
restore

use "$tempsaveDir\stock1_sums", clear
merge 1:1 $byGroupVars using "$tempsaveDir\stock2_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\stock3_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\stock4_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\stock5_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\stock6_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\stock7_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\stock8_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\stock9_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\stock10_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\stock11_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\stock12_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\stock13_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\stock14_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\stock15_sums", nogenerate
merge 1:1 $byGroupVars using "$tempsaveDir\stock16_sums", nogenerate
save "$tempsaveDir\stockRoster_sums" , replace 

// merge with main ibes meta data
use "$prepData\ibes_ii Estabs_unique_only", clear
keep $metaDataVars 

merge 1:1 $byGroupVars using "$tempsaveDir\stockRoster_sums"
keep if _merge==3
drop _m
order $metaDataVars
sort $metaDataVars

// label variable varname "label"
// gl canStartInterv (s00a_q10a == 1 | s00a_q10b == 1 | s00a_q10c == 1) // ABLE to start interview is Yes in any of the three tries
// gl isAnySector ((s00a_q09a == 1 | s00a_q09b == 1 | s00a_q09c==1 ) & (s00a_q10a == 1 | s00a_q10b == 1 | s00a_q10c == 1) & inrange(s1qso2,1,9))
// keep if $canStartInterv $isAnySector
save "$sectionData\section_05 STOCKS Flat Table", replace

use "$prepData\ibes_ii Estabs_unique_only", clear
keep $metaDataVars 
merge 1:m $byGroupVars using "$HQData\s5r1_stock.dta" 
keep if _merge==3
order $metaDataVars
sort $metaDataVars
drop _m
save "$sectionData\section_05 STOCKS Roster", replace


* 6. SAVE Section 6: FIXED CAPITAL FORMATION
*---------------------------------------------------------

* to do
* if establishment can start interview, and has qtype between 1 to 8 but did not answered section 6, use the _merge ==1 observations discussed below
* check Type of Asset (s6r1q0) if it matches asset descriptions in s6q1
* check if s6r1q1a==1 ( if is book value as at the beginning of the financial year 2023 available == Yes) but the value at s6r1q1 is not provided
* is IS DEPRECIATION VALUE AVAILABLE, s6r1q4a , cannot be blank if s6q1 is not 'total' and is not missing

use "$prepData\ibes_ii Estabs_unique_only", clear
keep $metaDataVars 
merge 1:m $byGroupVars using "$HQData\s6r1_fixed_capital.dta"

keep if _merge==3  // if observations for _merge==1 > 0 , then that is an error, respondent is expected to answer section6, this place must have observations for _merge==1 to be zero
order $metaDataVars
sort $metaDataVars s6r1_fixed_capital__id s6r1q0
drop _m
// destring 
// label list s6r1q0
save "$sectionData\section_06 FIXED CAPITAL FORMATION Roster", replace


* 7. SAVE Section 7: INPUT COSTS
*---------------------------------------------------------
*to do, check business type from qtype, check description of principal economic activity and other activity description, then check input cost description (s7aq1), with the selected CPC code (s7ar1q1) if it matches 
use "$prepData\ibes_ii Estabs_unique_only", clear
keep $metaDataVars 
merge 1:m $byGroupVars using "$HQData\s6r1_fixed_capital.dta"

keep if _merge==3  // if observations for _merge==1 > 0 , then that is an error, respondent is expected to answer section6, this place must have observations for _merge==1 to be zero
order $metaDataVars
sort $metaDataVars s6r1_fixed_capital__id s6r1q0
drop _m
// destring 
// label list s6r1q0
save "$sectionData\section_07 INPUT COSTS Roster", replace

// stop
// s7aq1   

