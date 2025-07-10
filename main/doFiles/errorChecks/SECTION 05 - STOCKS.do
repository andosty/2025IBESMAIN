******************************
* SECTION 5: STOCKS - FINAL VERSION (Reorganized) *
******************************

* This file contains comprehensive error checks for Section 5 (Stocks)
* Includes basic checks, advanced sector-specific checks, and dictionary validation rules
* Following the exact format of SECTION 0A template
* Created: May 22, 2025
* Last Updated: May 22, 2025 (Updated with correct dataset paths and merge step)

* Load the main dataset
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Merge with the Section 5 stock data
merge 1:m interview__id using "$HQData\s5r1_stock.dta"
drop if _merge == 2  // Drop observations only in the using data
drop _merge
* Generate business age
gen business_age = current_year - id22 if !missing(id22)

* Save the merged dataset for future use
save "$tempsaveDir\ibes_ii_sec5_Merge.dta", replace

* Now use the merged dataset for error checks
use "$tempsaveDir\ibes_ii_sec5_Merge.dta", clear
preserve

// * Define global macros for sector eligibility
// gl isAgricSec    (Sub_Sector == 1 & canStartInterv & canAnsBusQues) // Agriculture
// gl isMinQuaSec   (Sub_Sector == 2 & canStartInterv & canAnsBusQues) // Mining & Quarry
// gl isManufSec    (Sub_Sector == 3 & canStartInterv & canAnsBusQues) // Manufacturing
// gl isElectwatSec (Sub_Sector == 4 & canStartInterv & canAnsBusQues) // Electricity & Water
// gl isConstrucSec (Sub_Sector == 5 & canStartInterv & canAnsBusQues) // Construction
// gl isServ1Sec    (Sub_Sector == 6 & canStartInterv & canAnsBusQues) // Services 1
// gl isServ2Sec    (Sub_Sector == 7 & canStartInterv & canAnsBusQues) // Services 2
// gl isWholeRetailSec (Sub_Sector == 8 & canStartInterv & canAnsBusQues) // Wholesale & Retail
// gl isEnvironSec     (Sub_Sector == 9 & canStartInterv & canAnsBusQues) // Environmental Sector
//
// * Define a global macro for any sector (for checks that apply to all sectors)
// gl isAnySector (canStartInterv & canAnsBusQues)

* Define tolerance for floating point comparison
local tolerance = 0.01

*************************************
* PART 1: STOCK TYPE CHECKS
*************************************

*************************
* Check 1: Missing Stock Type ID
*************************
*Sec 5, Stock Type ID cannot be blank
gl blankStockTypeID ($isAnySector & missing(s5r1_stock__id))  

replace section = "Section 05" if $blankStockTypeID
replace error_flag = 1 if $blankStockTypeID
replace errorCheck = "Missing Check" if $blankStockTypeID
replace errorMessag = "Stock Type ID (s5r1_stock__id) cannot be blank" if $blankStockTypeID

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_stock_type_a.dta", replace

*************************
* Check 2: Invalid Stock Type ID
*************************
*Sec 5, Stock Type ID must be a valid code (1-14, 99, 100)
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

gl invalidStockTypeID ($isAnySector & !missing(s5r1_stock__id) & !(s5r1_stock__id >= 1 & s5r1_stock__id <= 14 | s5r1_stock__id == 99 | s5r1_stock__id == 100))

replace section = "Section 05" if $invalidStockTypeID
replace error_flag = 1 if $invalidStockTypeID
replace errorCheck = "Invalid Value" if $invalidStockTypeID
replace errorMessag = "Stock Type ID (s5r1_stock__id) must be a valid code (1-14, 99, or 100), current value: " + string(s5r1_stock__id) if $invalidStockTypeID

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_stock_type_b.dta", replace

***************************************
* Check 3: Sector-Appropriate Stock Type
***************************************
* Section 5: Stock type must match business sector

* Step 1: Load data
use "$tempsaveDir\ibes_ii_sec5_Merge.dta", clear

* Step 2: Define sector macros
gl isAgricSec ($isAnySector & Sub_Sector == 1)
gl isManufSec ($isAnySector & Sub_Sector == 3)
gl isWholeRetailSec ($isAnySector & Sub_Sector == 8)

**************************************************
* A. Check for inappropriate stock type - Agriculture
**************************************************
* Reload data
use "$tempsaveDir\ibes_ii_sec5_Merge.dta", clear

gen agricBadStockFlag = 0
replace agricBadStockFlag = 1 if $isAgricSec & ///
    !missing(s5r1_stock__id) & ///
    s5r1_stock__id != 99 & s5r1_stock__id != 100 & ///
    !inrange(s5r1_stock__id, 1, 8)

replace section = "Section 05" if agricBadStockFlag
replace error_flag = 1 if agricBadStockFlag
replace errorCheck = "Sector-Appropriate Check" if agricBadStockFlag
replace errorMessag = "Agriculture business using inappropriate stock type (" + ///
    string(s5r1_stock__id) + "). Expected types 1–8 for agriculture. Please verify." if agricBadStockFlag

keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_stock_type_c.dta", replace

****************************************************
* B. Check for inappropriate stock type - Manufacturing
****************************************************
use "$tempsaveDir\ibes_ii_sec5_Merge.dta", clear

gen manufBadStockFlag = 0
replace manufBadStockFlag = 1 if $isManufSec & ///
    !missing(s5r1_stock__id) & ///
    s5r1_stock__id != 99 & s5r1_stock__id != 100 & ///
    !inrange(s5r1_stock__id, 9, 12)

replace section = "Section 05" if manufBadStockFlag
replace error_flag = 1 if manufBadStockFlag
replace errorCheck = "Sector-Appropriate Check" if manufBadStockFlag
replace errorMessag = "Manufacturing business using inappropriate stock type (" + ///
    string(s5r1_stock__id) + "). Expected types 9–12 for manufacturing. Please verify." if manufBadStockFlag

keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_stock_type_d.dta", replace

**************************************************
* C. Check for inappropriate stock type - Retail/Wholesale
**************************************************
use "$tempsaveDir\ibes_ii_sec5_Merge.dta", clear

gen retailBadStockFlag = 0
replace retailBadStockFlag = 1 if $isWholeRetailSec & ///
    !missing(s5r1_stock__id) & ///
    s5r1_stock__id != 99 & s5r1_stock__id != 100 & ///
    !inrange(s5r1_stock__id, 13, 14)

replace section = "Section 05" if retailBadStockFlag
replace error_flag = 1 if retailBadStockFlag
replace errorCheck = "Sector-Appropriate Check" if retailBadStockFlag
replace errorMessag = "Retail/Wholesale business using inappropriate stock type (" + ///
    string(s5r1_stock__id) + "). Expected types 13–14 for retail/wholesale. Please verify." if retailBadStockFlag

keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_stock_type_e.dta", replace


*************************************
* OTHER SPECIFY CHECKS
*************************************

*************************
* Check 4: Missing Other Specification
*************************
*Sec 5, Other Specification (s5r1_oth) cannot be blank if Stock Type is "Other" (99)
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

gl blankOtherSpecification ($isAnySector & !missing(s5r1_stock__id) & s5r1_stock__id == 99 & missing(s5r1_oth))

replace section = "Section 05" if $blankOtherSpecification
replace error_flag = 1 if $blankOtherSpecification
replace errorCheck = "Missing Check" if $blankOtherSpecification
replace errorMessag = "Other Specification (s5r1_oth) cannot be blank when Stock Type is 'Other' (99)" if $blankOtherSpecification

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_other_spec_a.dta", replace

*************************
* Check 5: Unnecessary Other Specification
*************************
*Sec 5, Other Specification (s5r1_oth) should be blank or "NONE" when Stock Type is not "Other" (99)
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

gl unnecessaryOtherSpecification ($isAnySector & !missing(s5r1_stock__id) & s5r1_stock__id != 99 & !missing(s5r1_oth) & upper(s5r1_oth) != "NONE")

replace section = "Section 05" if $unnecessaryOtherSpecification
replace error_flag = 1 if $unnecessaryOtherSpecification
replace errorCheck = "Logical Consistency" if $unnecessaryOtherSpecification
replace errorMessag = "Other Specification (s5r1_oth) should be blank or 'NONE' when Stock Type is not 'Other' (99). Current Stock Type: " + string(s5r1_stock__id) + ", Other Specification: " + s5r1_oth if $unnecessaryOtherSpecification

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_other_spec_b.dta", replace

*************************
* Check 6: Other Specify Contains Preloaded Option
*************************
*Sec 5, Other Specification (s5r1_oth) should not match any of the preloaded stock types
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

* Create a flag for when the Other Specification matches a preloaded option
gen other_spec_matches_preloaded = 0

* Check if Other Specification matches any of the preloaded stock types
* Note: These strings should match exactly the text of the preloaded stock types
replace other_spec_matches_preloaded = 1 if !missing(s5r1_oth) & s5r1_stock__id == 99 & ///
    (upper(s5r1_oth) == upper("Agriculture input (fertilizer, pesticides, seeds and seedlings, breeding stocks-day old chicks, fingerlings, feed, etc.)") | ///
     upper(s5r1_oth) == upper("Other materials and supplies (heating bulbs, boots, mask, etc.)") | ///
     upper(s5r1_oth) == upper("Livestock, fish or poultry purchased for resale (cattle, sheep, goat, broilers, tilapia, etc.)") | ///
     upper(s5r1_oth) == upper("Farm produce purchased for resale (paddy rice, cocoa beans, yams, etc.)") | ///
     upper(s5r1_oth) == upper("Other goods purchased for resale (feed, fertilizer, pesticides, and seedlings)") | ///
     upper(s5r1_oth) == upper("Agricultural output harvested (in warehouses, barns and other storage facilities, honey, etc.)") | ///
     upper(s5r1_oth) == upper("Herds of livestock, fish or poultry (including old-layers) produced within the establishment not kept for reproduction") | ///
     upper(s5r1_oth) == upper("Crops and forest plantation (work in progress)") | ///
     upper(s5r1_oth) == upper("Raw materials and supplies (at current replacement cost in purchasers' prices)") | ///
     upper(s5r1_oth) == upper("Work in progress (in purchasers' prices)") | ///
     upper(s5r1_oth) == upper("Fuel (in purchasers' prices)") | ///
     upper(s5r1_oth) == upper("Finished goods (at ex-factory prices)") | ///
     upper(s5r1_oth) == upper("Goods purchased for resale (purchasers' price)") | ///
     upper(s5r1_oth) == upper("Goods purchased for resale (at ex-factory prices)"))

gl otherSpecMatchesPreloaded ($isAnySector & other_spec_matches_preloaded == 1)

replace section = "Section 05" if $otherSpecMatchesPreloaded
replace error_flag = 1 if $otherSpecMatchesPreloaded
replace errorCheck = "Other Specify Redundancy" if $otherSpecMatchesPreloaded
replace errorMessag = "Other Specification '" + s5r1_oth + "' matches a preloaded stock type. Please select the appropriate stock type instead of using 'Other'." if $otherSpecMatchesPreloaded

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_other_spec_c.dta", replace

*************************
* Check 7: NONE Validation for Other Specify
*************************
*Sec 5, If Other Specification (s5r1_oth) contains 'NONE', stock values must be 0
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

gl inconsistentNoneSpecification ($isAnySector & !missing(s5r1_oth) & upper(s5r1_oth) == "NONE" & ///
    (!missing(s5r1q1) & s5r1q1 > 0 | !missing(s5r1q2) & s5r1q2 > 0))

replace section = "Section 05" if $inconsistentNoneSpecification
replace error_flag = 1 if $inconsistentNoneSpecification
replace errorCheck = "Dictionary Validation" if $inconsistentNoneSpecification
replace errorMessag = "Other Specification contains 'NONE' but stock values are not 0. Beginning: " + string(s5r1q1) + ", Ending: " + string(s5r1q2) + ". If 'Other Specify' contains 'NONE', stock values must be 0." if $inconsistentNoneSpecification

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_other_spec_d.dta", replace

*************************
* Check 8: Non-NONE Validation for Other Specify
*************************
*Sec 5, If Other Specification (s5r1_oth) does not contain 'NONE', at least one stock value should be > 0
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

gl inconsistentNonNoneSpecification ($isAnySector & !missing(s5r1_oth) & upper(s5r1_oth) != "NONE" & s5r1_stock__id == 99 & ///
    (missing(s5r1q1) | s5r1q1 == 0) & (missing(s5r1q2) | s5r1q2 == 0))

replace section = "Section 05" if $inconsistentNonNoneSpecification
replace error_flag = 1 if $inconsistentNonNoneSpecification
replace errorCheck = "Dictionary Validation" if $inconsistentNonNoneSpecification
replace errorMessag = "Other Specification is '" + s5r1_oth + "' but all stock values are 0. If 'Other Specify' is not 'NONE', at least one stock value should be greater than 0." if $inconsistentNonNoneSpecification

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_other_spec_e.dta", replace

*************************************
* BEGINNING OF FINANCIAL YEAR STOCK CHECKS
*************************************

*************************
* Check 9: Missing Beginning Stock Value
*************************
*Sec 5, Beginning Stock Value (s5r1q1) cannot be blank
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

gl blankBeginningStock ($isAnySector & missing(s5r1q1))  

replace section = "Section 05" if $blankBeginningStock
replace error_flag = 1 if $blankBeginningStock
replace errorCheck = "Missing Check" if $blankBeginningStock
replace errorMessag = "Beginning Stock Value (s5r1q1) cannot be blank" if $blankBeginningStock

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_beginning_stock_a.dta", replace

*************************
* Check 10: Invalid Beginning Stock Value
*************************
*Sec 5, Beginning Stock Value (s5r1q1) must be non-negative
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

gl invalidBeginningStock ($isAnySector & !missing(s5r1q1) & s5r1q1 < 0)

replace section = "Section 05" if $invalidBeginningStock
replace error_flag = 1 if $invalidBeginningStock
replace errorCheck = "Invalid Value" if $invalidBeginningStock
replace errorMessag = "Beginning Stock Value (s5r1q1) must be non-negative, current value: " + string(s5r1q1) if $invalidBeginningStock

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_beginning_stock_b.dta", replace

*************************
* Check 11: Beginning Stock Outlier
*************************
*Sec 5, Flag unusually high beginning stock values
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

* Define threshold for outlier detection (adjust based on your data)
local beginning_stock_threshold = 10000000  // 10 million GHC, tp be adjusted as needed

gl outlierBeginningStock ($isAnySector & !missing(s5r1q1) & s5r1q1 > `beginning_stock_threshold')

replace section = "Section 05" if $outlierBeginningStock
replace error_flag = 1 if $outlierBeginningStock
replace errorCheck = "Outlier Check" if $outlierBeginningStock
replace errorMessag = "Beginning Stock Value (" + string(s5r1q1) + ") exceeds threshold of " + string(`beginning_stock_threshold') + ", please verify" if $outlierBeginningStock

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_beginning_stock_c.dta", replace

*************************************
* END OF FINANCIAL YEAR STOCK CHECKS
*************************************

*************************
* Check 12: Missing Ending Stock Value
*************************
*Sec 5, Ending Stock Value (s5r1q2) cannot be blank
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

gl blankEndingStock ($isAnySector & missing(s5r1q2))  

replace section = "Section 05" if $blankEndingStock
replace error_flag = 1 if $blankEndingStock
replace errorCheck = "Missing Check" if $blankEndingStock
replace errorMessag = "Ending Stock Value (s5r1q2) cannot be blank" if $blankEndingStock

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_ending_stock_a.dta", replace

*************************
* Check 13: Invalid Ending Stock Value
*************************
*Sec 5, Ending Stock Value (s5r1q2) must be non-negative
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

gl invalidEndingStock ($isAnySector & !missing(s5r1q2) & s5r1q2 < 0)

replace section = "Section 05" if $invalidEndingStock
replace error_flag = 1 if $invalidEndingStock
replace errorCheck = "Invalid Value" if $invalidEndingStock
replace errorMessag = "Ending Stock Value (s5r1q2) must be non-negative, current value: " + string(s5r1q2) if $invalidEndingStock

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_ending_stock_b.dta", replace

*************************
* Check 14: Ending Stock Outlier
*************************
*Sec 5, Flag unusually high ending stock values
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

* Define threshold for outlier detection (adjust based on your data)
local ending_stock_threshold = 10000000  // 10 million GHC, adjust as needed

gl outlierEndingStock ($isAnySector & !missing(s5r1q2) & s5r1q2 > `ending_stock_threshold')

replace section = "Section 05" if $outlierEndingStock
replace error_flag = 1 if $outlierEndingStock
replace errorCheck = "Outlier Check" if $outlierEndingStock
replace errorMessag = "Ending Stock Value (" + string(s5r1q2) + ") exceeds threshold of " + string(`ending_stock_threshold') + ", please verify" if $outlierEndingStock

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_ending_stock_c.dta", replace

*************************************
* LOGICAL CONSISTENCY CHECKS
*************************************

*************************
* Check 15: Unusual Stock Value Changes
*************************
*Sec 5, Flag unusual changes in stock values (>5x increase or >80% decrease) to be reviewed
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

* Calculate stock value change ratio
gen stock_change_ratio = s5r1q2 / s5r1q1 if !missing(s5r1q1) & !missing(s5r1q2) & s5r1q1 > 0

gl unusualStockIncrease ($isAnySector & !missing(stock_change_ratio) & stock_change_ratio > 5)

replace section = "Section 05" if $unusualStockIncrease
replace error_flag = 1 if $unusualStockIncrease
replace errorCheck = "Logical Consistency" if $unusualStockIncrease
replace errorMessag = "Unusual increase in stock value. Beginning: " + string(s5r1q1) + ", Ending: " + string(s5r1q2) + ", Ratio: " + string(stock_change_ratio) + ". Please verify." if $unusualStockIncrease

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_consistency_a.dta", replace

use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

* Calculate stock value change ratio
gen stock_change_ratio = s5r1q2 / s5r1q1 if !missing(s5r1q1) & !missing(s5r1q2) & s5r1q1 > 0

gl unusualStockDecrease ($isAnySector & !missing(stock_change_ratio) & stock_change_ratio < 0.2 & s5r1q1 >= 1000)

replace section = "Section 05" if $unusualStockDecrease
replace error_flag = 1 if $unusualStockDecrease
replace errorCheck = "Logical Consistency" if $unusualStockDecrease
replace errorMessag = "Unusual decrease in stock value. Beginning: " + string(s5r1q1) + ", Ending: " + string(s5r1q2) + ", Ratio: " + string(stock_change_ratio) + ". Please verify." if $unusualStockDecrease

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_consistency_b.dta", replace

*************************
* Check 16: Unchanged Stock Values
*************************
*Sec 5, Flag unchanged stock values throughout the year for active businesses
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear
// * Get current year from system date
// gen current_year = year(daily("today", "DMY"))


gl unchangedStockValues ($isAnySector & !missing(s5r1q1) & !missing(s5r1q2) & s5r1q1 == s5r1q2 & s5r1q1 > 1000 & business_age > 1)  // we need to calculate business age from year of commencemnet 

replace section = "Section 05" if $unchangedStockValues
replace error_flag = 1 if $unchangedStockValues
replace errorCheck = "Logical Consistency" if $unchangedStockValues
replace errorMessag = "Stock values unchanged throughout the year. Beginning: " + string(s5r1q1) + ", Ending: " + string(s5r1q2) + ". Please verify if this is accurate for an active business." if $unchangedStockValues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_consistency_c.dta", replace

*************************************
* SECTOR-SPECIFIC CHECKS
*************************************

*************************
* Check 17: Manufacturing Sector Stock Consistency
*************************
*Sec 5, Manufacturing businesses should have appropriate stock patterns
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

* Manufacturing businesses should have raw materials (type 9) and finished goods (type 12)
gl missingManufStockTypes ($isManufSec & ///
    !(s5r1_stock__id == 9 & s5r1q1 > 0 & s5r1q2 > 0) & ///
    !(s5r1_stock__id == 12 & s5r1q1 > 0 & s5r1q2 > 0) & ///
    business_age > 1)

replace section = "Section 05" if $missingManufStockTypes
replace error_flag = 1 if $missingManufStockTypes
replace errorCheck = "Manufacturing Sector Check" if $missingManufStockTypes
replace errorMessag = "Manufacturing business missing expected stock types. Should have both raw materials (type 9) and finished goods (type 12) with positive values. Please verify." if $missingManufStockTypes

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_manuf_a.dta", replace

*************************
* Check 18: Service Sector Stock Consistency
*************************
*Sec 5, Service businesses should have appropriate stock patterns
use "$tempsaveDir\ibes_ii_sec5_Merge.dta", clear

* Service businesses typically have low stock values
* Define service sector (adjust sub-sector codes if needed)
gen is_service_sector = inlist(Sub_Sector, 6, 7)

* Generate flag for high stock values in service sector
gen high_stock_service = is_service_sector & ///
    ((s5r1q1 > 1000000 & !missing(s5r1q1)) | /// the amount or figures to be reviewed
     (s5r1q2 > 1000000 & !missing(s5r1q2)))

* Apply error reporting
replace section = "Section 05" if high_stock_service
replace error_flag = 1 if high_stock_service
replace errorCheck = "Service Sector Check" if high_stock_service
replace errorMessag = "Service business has unusually high stock values. Beginning: " + string(s5r1q1) + ", Ending: " + string(s5r1q2) + ". Please verify if these values are accurate for a service business." if high_stock_service

* Save flagged records
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_service_a.dta", replace


*************************
* Check 19: Retail Sector Stock Consistency
*************************
*Sec 5, Retail businesses should have appropriate stock patterns
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

* Retail businesses should have goods for resale (types 13-14)
gl missingRetailStockTypes ($isWholeRetailSec & ///
    !(s5r1_stock__id == 13 & s5r1q1 > 0 & s5r1q2 > 0) & ///
    !(s5r1_stock__id == 14 & s5r1q1 > 0 & s5r1q2 > 0) & ///
    business_age > 1)

replace section = "Section 05" if $missingRetailStockTypes
replace error_flag = 1 if $missingRetailStockTypes
replace errorCheck = "Retail Sector Check" if $missingRetailStockTypes
replace errorMessag = "Retail business missing expected stock types. Should have goods purchased for resale (types 13-14) with positive values. Please verify." if $missingRetailStockTypes

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_retail_a.dta", replace

*************************
* Check 20: Agriculture Sector Stock Consistency
*************************
*Sec 5, Agriculture businesses should have appropriate stock patterns
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

* Agriculture businesses should have appropriate stock types (1-8)
gl missingAgricStockTypes ($isAgricSec & ///
    !(s5r1_stock__id >= 1 & s5r1_stock__id <= 8 & s5r1q1 > 0 & s5r1q2 > 0) & ///
    business_age > 1)

replace section = "Section 05" if $missingAgricStockTypes
replace error_flag = 1 if $missingAgricStockTypes
replace errorCheck = "Agriculture Sector Check" if $missingAgricStockTypes
replace errorMessag = "Agriculture business missing expected stock types. Should have agriculture-related stocks (types 1-8) with positive values. Please verify." if $missingAgricStockTypes

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_agric_a.dta", replace

*************************
* Check 21: Construction Sector Stock Consistency
*************************
*Sec 5, Construction businesses should have appropriate stock patterns
*************************
* Check 21: Construction Sector Stock Consistency
*************************

* Load the data
use "$tempsaveDir\ibes_ii_sec5_Merge.dta", clear

* Ensure business age exists
* (if not already created elsewhere, uncomment this line and adjust "id22" as needed)
* gen business_age = year(daily("today", "DMY")) - id22 // this was generated before saving the data 

* Define construction sector if not already defined
gen isConstructionSector = Sub_Sector == 5  // adjust if different

* Generate flag for missing expected stock types
gen missingConstructionStock = 0
replace missingConstructionStock = 1 if isConstructionSector & business_age > 1 & ///
    !(s5r1_stock__id == 9 & s5r1q1 > 0 & s5r1q2 > 0) & ///
    !(s5r1_stock__id == 10 & s5r1q1 > 0 & s5r1q2 > 0)

* Add error info
replace section = "Section 05" if missingConstructionStock
replace error_flag = 1 if missingConstructionStock
replace errorCheck = "Construction Sector Check" if missingConstructionStock
replace errorMessag = "Construction business missing expected stock types. Should have raw materials (type 9) and work in progress (type 10) with positive values. Please verify." if missingConstructionStock

* Save error records
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_construction_a.dta", replace


*************************************
* CROSS-SECTOR CONSISTENCY CHECKS
*************************************

*************************
// * Check 22: Stock-to-Revenue Ratios by Sector
// *************************
// *Sec 5, Different sectors have different typical stock-to-revenue ratios
// use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear
//
// * Calculate stock-to-revenue ratio
// gen stock_to_revenue_ratio = (s5r1q1 + s5r1q2) / (2 * total_revenue) if !missing(s5r1q1) & !missing(s5r1q2) & !missing(total_revenue) & total_revenue > 0
//
// * Define expected maximum stock-to-revenue ratio by sector // we can reviewed this based on total revenue 
// gen expected_max_stock_ratio = .
// replace expected_max_stock_ratio = 0.8 if Sub_Sector == 1  // Agriculture
// replace expected_max_stock_ratio = 0.5 if Sub_Sector == 2  // Mining
// replace expected_max_stock_ratio = 1.0 if Sub_Sector == 3  // Manufacturing
// replace expected_max_stock_ratio = 0.3 if Sub_Sector == 4  // Electricity & Water
// replace expected_max_stock_ratio = 0.6 if Sub_Sector == 5  // Construction
// replace expected_max_stock_ratio = 0.2 if Sub_Sector == 6  // Services 1
// replace expected_max_stock_ratio = 0.2 if Sub_Sector == 7  // Services 2
// replace expected_max_stock_ratio = 1.2 if Sub_Sector == 8  // Wholesale & Retail
// replace expected_max_stock_ratio = 0.5 if Sub_Sector == 9  // Environmental
//
// gl unusualStockRatio ($isAnySector & !missing(expected_max_stock_ratio) & !missing(stock_to_revenue_ratio) & ///
//     stock_to_revenue_ratio > expected_max_stock_ratio & total_revenue >= 10000)
//
// replace section = "Section 05" if $unusualStockRatio
// replace error_flag = 1 if $unusualStockRatio
// replace errorCheck = "Cross-Sector Consistency" if $unusualStockRatio
// replace errorMessag = "Unusually high stock-to-revenue ratio for this sector: " + string(stock_to_revenue_ratio) + " (expected maximum: " + string(expected_max_stock_ratio) + "). Please verify." if $unusualStockRatio
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section5_cross_sector_a.dta", replace

*************************
* Check 23: Stock Change Patterns by Sector
*************************
*Sec 5, Different sectors have different typical stock change patterns
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

* Calculate stock change percentage
gen stock_change_pct = 100 * (s5r1q2 - s5r1q1) / s5r1q1 if !missing(s5r1q1) & !missing(s5r1q2) & s5r1q1 > 0

* Define expected maximum stock change percentage by sector // this to be reveiewd 
gen expected_max_stock_change = .
replace expected_max_stock_change = 100 if Sub_Sector == 1  // Agriculture
replace expected_max_stock_change = 80 if Sub_Sector == 2  // Mining
replace expected_max_stock_change = 120 if Sub_Sector == 3  // Manufacturing
replace expected_max_stock_change = 50 if Sub_Sector == 4  // Electricity & Water
replace expected_max_stock_change = 100 if Sub_Sector == 5  // Construction
replace expected_max_stock_change = 50 if Sub_Sector == 6  // Services 1
replace expected_max_stock_change = 50 if Sub_Sector == 7  // Services 2
replace expected_max_stock_change = 150 if Sub_Sector == 8  // Wholesale & Retail
replace expected_max_stock_change = 80 if Sub_Sector == 9  // Environmental

gl unusualStockChange ($isAnySector & !missing(expected_max_stock_change) & !missing(stock_change_pct) & ///
    stock_change_pct > expected_max_stock_change & s5r1q1 >= 1000)

replace section = "Section 05" if $unusualStockChange
replace error_flag = 1 if $unusualStockChange
replace errorCheck = "Cross-Sector Consistency" if $unusualStockChange
replace errorMessag = "Unusually high stock change percentage for this sector: " + string(stock_change_pct) + "% (expected maximum: " + string(expected_max_stock_change) + "%). Please verify." if $unusualStockChange

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_cross_sector_b.dta", replace

*************************
* Check 24: Stock-to-Employee Ratios by Sector
*************************
*Sec 5, Different sectors have different typical stock-to-employee ratios
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

* Calculate stock per employee
gen stock_per_employee = (s5r1q1 + s5r1q2) / (2 * s2r1q1_persons_engaged_total) if !missing(s5r1q1) & !missing(s5r1q2) & !missing(s2r1q1_persons_engaged_total) & s2r1q1_persons_engaged_total > 0

* Define expected maximum stock per employee by sector (in GHC)
gen expected_max_stock_per_employee = .
replace expected_max_stock_per_employee = 50000 if Sub_Sector == 1  // Agriculture
replace expected_max_stock_per_employee = 100000 if Sub_Sector == 2  // Mining
replace expected_max_stock_per_employee = 200000 if Sub_Sector == 3  // Manufacturing
replace expected_max_stock_per_employee = 50000 if Sub_Sector == 4  // Electricity & Water
replace expected_max_stock_per_employee = 100000 if Sub_Sector == 5  // Construction
replace expected_max_stock_per_employee = 30000 if Sub_Sector == 6  // Services 1
replace expected_max_stock_per_employee = 30000 if Sub_Sector == 7  // Services 2
replace expected_max_stock_per_employee = 250000 if Sub_Sector == 8  // Wholesale & Retail
replace expected_max_stock_per_employee = 80000 if Sub_Sector == 9  // Environmental

gl unusualStockPerEmployee ($isAnySector & !missing(expected_max_stock_per_employee) & !missing(stock_per_employee) & ///
    stock_per_employee > expected_max_stock_per_employee & s2r1q1_persons_engaged_total >= 5)

replace section = "Section 05" if $unusualStockPerEmployee
replace error_flag = 1 if $unusualStockPerEmployee
replace errorCheck = "Cross-Sector Consistency" if $unusualStockPerEmployee
replace errorMessag = "Unusually high stock per employee for this sector: " + string(stock_per_employee) + " GHC (expected maximum: " + string(expected_max_stock_per_employee) + " GHC). Please verify." if $unusualStockPerEmployee

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_cross_sector_c.dta", replace

*************************************
* ADVANCED PATTERN DETECTION CHECKS
*************************************

*************************
* Check 25: Suspicious Rounding Pattern Check
*************************
*Sec 5, Check for suspicious rounding patterns that might indicate fabricated data
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

* Check if stock values are suspiciously rounded
gl suspiciousRounding ($isAnySector & !missing(s5r1q1) & !missing(s5r1q2) & ///
    s5r1q1 >= 10000 & s5r1q2 >= 10000 & ///
    (mod(s5r1q1, 10000) == 0 & mod(s5r1q2, 10000) == 0))

replace section = "Section 05" if $suspiciousRounding
replace error_flag = 1 if $suspiciousRounding
replace errorCheck = "Pattern Detection" if $suspiciousRounding
replace errorMessag = "Suspicious rounding pattern detected in stock values. Both values are rounded to nearest 10,000 (Beginning: " + string(s5r1q1) + ", Ending: " + string(s5r1q2) + "). Please verify." if $suspiciousRounding

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_pattern_a.dta", replace

*************************
* Check 26: Suspicious Identical Values Check
*************************
*Sec 5, Checking for suspiciously identical beginning and ending values
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

gl suspiciousIdenticalValues ($isAnySector & !missing(s5r1q1) & !missing(s5r1q2) & ///
    s5r1q1 == s5r1q2 & s5r1q1 >= 10000 & ///
    mod(s5r1q1, 1000) == 0)

replace section = "Section 05" if $suspiciousIdenticalValues
replace error_flag = 1 if $suspiciousIdenticalValues
replace errorCheck = "Pattern Detection" if $suspiciousIdenticalValues
replace errorMessag = "Suspicious identical values detected. Beginning and ending stock values are exactly the same rounded value: " + string(s5r1q1) + ". Please verify." if $suspiciousIdenticalValues

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_pattern_b.dta", replace

*************************
* Check 27: Suspicious Simple Ratio Pattern Check
*************************
*Sec 5, Check for suspicious simple ratio patterns
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

* Check for simple ratio patterns (exactly doubling, halving, etc.)
gl suspiciousSimpleRatio ($isAnySector & !missing(s5r1q1) & !missing(s5r1q2) & ///
    s5r1q1 >= 1000 & s5r1q2 >= 1000 & ///
    (abs(s5r1q2 / s5r1q1 - 2) < 0.01 | abs(s5r1q2 / s5r1q1 - 1.5) < 0.01 | abs(s5r1q2 / s5r1q1 - 0.5) < 0.01))

replace section = "Section 05" if $suspiciousSimpleRatio
replace error_flag = 1 if $suspiciousSimpleRatio
replace errorCheck = "Pattern Detection" if $suspiciousSimpleRatio
replace errorMessag = "Suspicious simple ratio pattern detected. Ending value (" + string(s5r1q2) + ") is exactly double, 1.5 times, or half of beginning value (" + string(s5r1q1) + "). Please verify." if $suspiciousSimpleRatio

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_pattern_c.dta", replace

*************************
* Check 28: Suspicious Digit Pattern Check
*************************
*Sec 5, Check for suspicious digit patterns that might indicate fabricated data
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

* Check for repeated digits in stock values
gen last_digits_beginning = mod(s5r1q1, 100) if !missing(s5r1q1)
gen last_digits_ending = mod(s5r1q2, 100) if !missing(s5r1q2)

gl suspiciousDigitPattern ($isAnySector & !missing(last_digits_beginning) & !missing(last_digits_ending) & ///
    s5r1q1 >= 10000 & s5r1q2 >= 10000 & ///
    (last_digits_beginning == 0 & last_digits_ending == 0 | ///
     last_digits_beginning == 11 | last_digits_beginning == 22 | last_digits_beginning == 33 | last_digits_beginning == 44 | ///
     last_digits_beginning == 55 | last_digits_beginning == 66 | last_digits_beginning == 77 | last_digits_beginning == 88 | ///
     last_digits_beginning == 99 | ///
     last_digits_ending == 11 | last_digits_ending == 22 | last_digits_ending == 33 | last_digits_ending == 44 | ///
     last_digits_ending == 55 | last_digits_ending == 66 | last_digits_ending == 77 | last_digits_ending == 88 | ///
     last_digits_ending == 99))

replace section = "Section 05" if $suspiciousDigitPattern
replace error_flag = 1 if $suspiciousDigitPattern
replace errorCheck = "Pattern Detection" if $suspiciousDigitPattern
replace errorMessag = "Suspicious digit pattern detected in stock values. Beginning: " + string(s5r1q1) + " (last digits: " + string(last_digits_beginning) + "), Ending: " + string(s5r1q2) + " (last digits: " + string(last_digits_ending) + "). Please verify." if $suspiciousDigitPattern

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_pattern_d.dta", replace

*************************************
* BUSINESS SIZE CONSISTENCY CHECKS
*************************************

*************************
* Check 29: Stock vs. Employee Count Consistency
*************************
*Sec 5, Stock values should be consistent with employee count
use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear

* Calculate average stock value
gen avg_stock = (s5r1q1 + s5r1q2) / 2 if !missing(s5r1q1) & !missing(s5r1q2)

gl inconsistentStockEmployeeRatio ($isAnySector & !missing(avg_stock) & !missing(s2r1q1_persons_engaged_total) & ///
    s2r1q1_persons_engaged_total <= 2 & avg_stock > 1000000)

replace section = "Section 05" if $inconsistentStockEmployeeRatio
replace error_flag = 1 if $inconsistentStockEmployeeRatio
replace errorCheck = "Business Size Consistency" if $inconsistentStockEmployeeRatio
replace errorMessag = "Very small business (only " + string(s2r1q1_persons_engaged_total) + " persons) has unusually high average stock value (" + string(avg_stock) + "). Please verify." if $inconsistentStockEmployeeRatio

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section5_business_size_a.dta", replace

*************************
// * Check 30: Stock vs. Revenue Consistency
// *************************
// *Sec 5, Stock values should be consistent with revenue // to be revisit based on total revenue
// use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear
//
// * Calculate average stock value
// gen avg_stock = (s5r1q1 + s5r1q2) / 2 if !missing(s5r1q1) & !missing(s5r1q2)
//
// gl inconsistentStockRevenueRatio ($isAnySector & !missing(avg_stock) & !missing(total_revenue) & ///
//     total_revenue < avg_stock / 5 & avg_stock > 50000)
//
// replace section = "Section 05" if $inconsistentStockRevenueRatio
// replace error_flag = 1 if $inconsistentStockRevenueRatio
// replace errorCheck = "Business Size Consistency" if $inconsistentStockRevenueRatio
// replace errorMessag = "Business has very low revenue (" + string(total_revenue) + ") compared to average stock value (" + string(avg_stock) + "). Please verify." if $inconsistentStockRevenueRatio
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section5_business_size_b.dta", replace

*************************
// * Check 31: Stock vs. Total Assets Consistency
// *************************
// *Sec 5, Stock values should be consistent with total assets /// if only we can get variable to total assets 
// use "$tempsaveDir\ibes_ii_sec5_Merge.dta" , clear
//
// * Calculate average stock value
// gen avg_stock = (s5r1q1 + s5r1q2) / 2 if !missing(s5r1q1) & !missing(s5r1q2)
//
// gl inconsistentStockAssetsRatio ($isAnySector & !missing(avg_stock) & !missing(total_assets) & ///
//     avg_stock > total_assets & avg_stock > 50000)
//
// replace section = "Section 05" if $inconsistentStockAssetsRatio
// replace error_flag = 1 if $inconsistentStockAssetsRatio
// replace errorCheck = "Business Size Consistency" if $inconsistentStockAssetsRatio
// replace errorMessag = "Stock value (" + string(avg_stock) + ") exceeds total assets (" + string(total_assets) + "). Please verify." if $inconsistentStockAssetsRatio
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section5_business_size_c.dta", replace

*************************************
* COMBINING ALL ERROR REPORTS
*************************************

* This section would combine all individual error reports into a master report
* Example code (commented out as it depends on your specific file structure):

/*
use "$error_report\Section5_stock_type_a.dta", clear
foreach file in "$error_report\Section5_stock_type_b.dta" "$error_report\Section5_stock_type_c.dta" "$error_report\Section5_stock_type_d.dta" "$error_report\Section5_stock_type_e.dta" "$error_report\Section5_other_spec_a.dta" "$error_report\Section5_other_spec_b.dta" "$error_report\Section5_other_spec_c.dta" "$error_report\Section5_other_spec_d.dta" "$error_report\Section5_other_spec_e.dta" "$error_report\Section5_beginning_stock_a.dta" "$error_report\Section5_beginning_stock_b.dta" "$error_report\Section5_beginning_stock_c.dta" "$error_report\Section5_ending_stock_a.dta" "$error_report\Section5_ending_stock_b.dta" "$error_report\Section5_ending_stock_c.dta" "$error_report\Section5_consistency_a.dta" "$error_report\Section5_consistency_b.dta" "$error_report\Section5_consistency_c.dta" "$error_report\Section5_manuf_a.dta" "$error_report\Section5_service_a.dta" "$error_report\Section5_retail_a.dta" "$error_report\Section5_agric_a.dta" "$error_report\Section5_construction_a.dta" "$error_report\Section5_cross_sector_a.dta" "$error_report\Section5_cross_sector_b.dta" "$error_report\Section5_cross_sector_c.dta" "$error_report\Section5_pattern_a.dta" "$error_report\Section5_pattern_b.dta" "$error_report\Section5_pattern_c.dta" "$error_report\Section5_pattern_d.dta" "$error_report\Section5_business_size_a.dta" "$error_report\Section5_business_size_b.dta" "$error_report\Section5_business_size_c.dta" {
    append using "`file'"
}
save "$error_report\Section5_AllErrors.dta", replace
*/

* End of Section 5 Error Checks
