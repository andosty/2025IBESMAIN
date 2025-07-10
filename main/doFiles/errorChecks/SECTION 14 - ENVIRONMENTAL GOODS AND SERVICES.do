*=============================================
* SECTION 14: ENVIRONMENTAL GOODS AND SERVICES 
*=============================================

*Sub-section 1 (ENVIRONMENTAL PROTECTION/RESOURCE MANAGEMENT GOODS PRODUCED)
****************************************************************************

*Q1.Did your establishment produce environmental goods and services in the 2023 financial year?
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve


gl invalidEnviroGoodsServices ($isAnySector & missing(s14q1)| !inlist(s14q1, 1,2))  

replace section = "Section 14" if $invalidEnviroGoodsServices
replace error_flag = 1         if $invalidEnviroGoodsServices
replace errorCheck  = cond(missing(s14q1), "Missing check", "Invalid selection") if $invalidEnviroGoodsServices
replace errorMessage = cond(missing(s14q1), ///
  "Que. 1.2.0,  Did the Establishment=(" + EstablishmentName + ") produce enviro goods&services in the 2023 financial year,cannot be blank", ///
  "Que. 1.2.0, option selected for Establishment=(" + EstablishmentName + ") if produce enviro goods&services is not valid (must be either YES OR NO)") if $invalidEnviroGoodsServices

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section14_sec1Q1.dta", replace
// restore


*Sub-section 1 (ENVIRONMENTAL PROTECTION/RESOURCE MANAGEMENT GOODS PRODUCED)
*****************************************************************************
//Q2a,b,c. Indicate the Type(s) of environmental goods and services produced,starting with the principal product

* Not Expected and Expected-Check but missing
***********************************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gen sub_section_Q2_UnExpec = !missing(s14q1) & s14q1 == 2 & (!missing(s14q2a) | !missing(s14q2b) | !missing(s14q2c))
gen sub_section_Q3_UnExpec = !missing(s14q1) & s14q1 == 2 & ( ///
    (!missing(s14q3a) | !missing(s14q3b)) | ///
    (!missing(s14bq3a) | !missing(s14bq3b)) | ///
    (!missing(s14cq3a) | !missing(s14cq3b)) )

gen sub_section_Q2_Expec = !missing(s14q1) & s14q1 == 1 & (missing(s14q2a) | missing(s14q2b) | missing(s14q2c))
gen sub_section_Q3_Expec = !missing(s14q1) & s14q1 == 1 & ( ///
    (missing(s14q3a) | missing(s14q3b)) | ///
    (missing(s14bq3a) | missing(s14bq3b)) | ///
    (missing(s14cq3a) | missing(s14cq3b)) )

gen Unexpected = sub_section_Q2_UnExpec | sub_section_Q3_UnExpec
gen Expected = sub_section_Q2_Expec | sub_section_Q3_Expec

gl EnviroGoodsService ($isAnySector & (Unexpected | Expected))

* Map numeric values to "Yes"/"No"
tempvar s14q1_label
gen `s14q1_label' = ""
replace `s14q1_label' = "Yes" if s14q1 == 1
replace `s14q1_label' = "No"  if s14q1 == 2

replace error_flag = 1 if $EnviroGoodsService
replace section = "Section 1"       if $EnviroGoodsService
replace errorCheck = cond(Unexpected, "Not Expected", "Expected But Missing") if $EnviroGoodsService
replace errorMessage = cond(Unexpected, ///
    "Q2/Q3: Unexpected response from ('" + EstablishmentName + "') — if producing Enviro goods&services is=('" + `s14q1_label' + "')", ///
    "Q2/Q3: Expected response missing from ('" + EstablishmentName + "') — if producing Enviro goods&services is=('" + `s14q1_label' + "')") if $EnviroGoodsService


// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section14_sec1Q2&Q3_1.dta", replace
// restore


* Environmental Goods & Services: Value checks
************************************************
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

* 1. Expected but Missing Outputs
*********************************
gen check_missing_value = ///
    (!missing(s14q2a) & missing(s14r1aq1)) | ///
    (!missing(s14q2b) & missing(s14r1bq1)) | ///
    (!missing(s14q2c) & missing(s14r1cq1))

* 2. Negative/Invalid Values in Output Responses
************************************************
gen check_negative_output = ///
    (!missing(s14r1aq1) & s14r1aq1 < 0) | ///
    (!missing(s14r1bq1) & s14r1bq1 < 0) | ///
    (!missing(s14r1cq1) & s14r1cq1 < 0)

* 3. Negative/Invalid Values in Value Variables
***********************************************
gen check_negative_value_fields = ///
    (!missing(s14q3a)   & s14q3a   < 0) | ///
    (!missing(s14aq3b)  & s14aq3b  < 0) | ///
    (!missing(s14bq3a)  & s14bq3a  < 0) | ///
    (!missing(s14bq3b)  & s14bq3b  < 0) | ///
    (!missing(s14cq3a)  & s14cq3a  < 0) | ///
    (!missing(s14cq3b)  & s14cq3b  < 0)

gl EnviroGoodsService_Values ($isAnySector & (check_missing_value | check_negative_output | check_negative_value_fields))

replace error_flag = 1         if $EnviroGoodsService_Values
replace section = "Section 1"  if $EnviroGoodsService_Values

replace errorCheck = ///
    cond(check_missing_value, "Expected But Missing Output", ///
    cond(!check_missing_value & check_negative_output, "Negative Value in Output Fields", ///
    cond(check_negative_value_fields, "Negative Value in Value Variables", errorCheck))) if $EnviroGoodsService_Values

replace errorMessage = ///
    cond(check_missing_value, ///
        "Q2: Output value is missing for at least one declared Enviro product/service in '" + EstablishmentName + "'", ///
    cond(!check_missing_value & check_negative_output, ///
        "Q2: Output value is negative for at least one Enviro product/service in '" + EstablishmentName + "'", ///
    cond(check_negative_value_fields, ///
        "Q3: Negative value detected in Environmental value components for '" + EstablishmentName + "'", ///
    errorMessage))) if $EnviroGoodsService_Values

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section14_sec1Q2&Q3_2.dta", replace
// restore
	
*****************************
* Question C1.2.3c First check
*****************************
* C1.2.3c, Ghanaian contact number is not expected
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl UnexpectedGhNewTelnumber ($isAnySector & !missing(id14c2) &  id14c2 == 2 & !missing(id14c))

* Map numeric values to "Yes"/"No"
tempvar id14c2_label
gen `id14c2_label' = ""
replace `id14c2_label' = "Yes" if id14c2 == 1
replace `id14c2_label' = "No"  if id14c2 == 2

replace error_flag = 1 if $UnexpectedGhNewTelnumber
replace section = "Section 01" if $UnexpectedGhNewTelnumber
replace errorCheck = "Not Expected" if $UnexpectedGhNewTelnumber
replace errorMessage = "Que.1.2.3c, Ghanaian contact Number for (" + EstablishmentName + ") is not expected if it is not a GH contact ('" ///
 + `id14b_label' + "')"  " if $UnexpectedGhNewTelnumber

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.3c1.dta", replace
// restore
	
	
	
	
*Sub-section 2 (ENVIRONMENTAL PROTECTION EXPENDITURE ACCOUNTS BY SPECIALIST PRODUCERS)
**************************************************************************************
// Q1. IN PRODUCING ENVIRONMENTAL PROTECTION SERVICES BY SPECIALIST PRODUCERS, WHAT IS THE TOTAL VALUE OF OUTPUT AND INPUT?
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

* 1. Not Expected Outputs
***************************
gen Value_Inputs_Unexpected = !missing(s14s2q1) & s14s2q1 == 2 & (!missing(s14s2q1a) | !missing(s14s2q1b))
gen Value_Output_Unexpected = !missing(s14s2q1) & s14s2q1 == 2 & (!missing(s14s2q1c) | !missing(s14s2q1d))

* 2. Expected but Missing Outputs
*********************************
gen Value_Inputs_missing = !missing(s14s2q1) & s14s2q1 == 1 & (missing(s14s2q1a) | missing(s14s2q1b)) 
gen Value_Output_missing = !missing(s14s2q1) & s14s2q1 == 1 & (missing(s14s2q1c) | missing(s14s2q1d))

* 3. Negative/Invalid Values in Inputs and Outputs
**************************************************
gen Value_Inputs_Invalid = (!missing(s14s2q1a) & s14s2q1a < 0) | (!missing(s14s2q1b) & s14s2q1b < 0)
gen Value_Output_Invalid = (!missing(s14s2q1c) & s14s2q1c < 0) | (!missing(s14s2q1d) & s14s2q1d < 0)

* 4. Logical Consistency Check: Output should be >= Input
*********************************************************
gen check_output_less_than_input = ///
    !missing(s14s2q1a, s14s2q1b, s14s2q1c, s14s2q1d) & ///
    (s14s2q1c + s14s2q1d) < (s14s2q1a + s14s2q1b)

	
gen Unexpected_Values = Value_Inputs_Unexpected | Value_Output_Unexpected 
gen Missing_Values = Value_Inputs_missing | Value_Output_missing
gen Invalid_Values = Value_Inputs_Invalid | Value_Output_Invalid


gl Expen_Account ($isAnySector & (Unexpected_Values | Missing_Values | Invalid_Values | check_output_less_than_input))


replace error_flag = 1         if $Expen_Account
replace section = "Section 1"  if $Expen_Account


replace errorCheck = ///
    cond(Unexpected_Values, "Not Expected", ///
    cond(Missing_Values, "Expected But Missing Value", ///
    cond(!Missing_Values & Invalid_Values, "Invalid (Negative) Value Entered", ///
    cond(!Missing_Values & !Invalid_Values & check_output_less_than_input, "Output Less Than Input", errorCheck)))) if $Expen_Account


	replace errorMessage = ///
    cond(Unexpected_Values, ///
        "Sub-Section 2: Unexpected value(s) provided when response was 'No' to producing environmental protection services — Establishment '" + EstablishmentName + "'", ///
    cond(Missing_Values, ///
        "Sub-Section 2: Missing value(s) in Input or Output expenditure for Establishment '" + EstablishmentName + "'", ///
    cond(Invalid_Values, ///
        "Sub-Section 2: Negative value(s) found in expenditure fields for Establishment '" + EstablishmentName + "'", ///
    cond(check_output_less_than_input, ///
        "Sub-Section 2: Total Output (Domestic + Export) is less than Input (Domestic + Import) for Establishment '" + EstablishmentName + "'", ///
    errorMessage)))) if $Expen_Account
	

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section14_sec2Q1.dta", replace
// restore


* Sub-Section 2: // Missing Value and Invalid Checks (Q2–Q7b)

* 1. Unexpected Responses (entered when s14s2q1 == 2)
******************************************************
gen check_unexpected_s2q2  = !missing(s14s2q1) & s14s2q1 == 2 & !missing(s14s2q2)
gen check_unexpected_s2q3  = !missing(s14s2q1) & s14s2q1 == 2 & !missing(s14s2q3)
gen check_unexpected_s2q4  = !missing(s14s2q1) & s14s2q1 == 2 & !missing(s14s2q4)
gen check_unexpected_s2q5  = !missing(s14s2q1) & s14s2q1 == 2 & !missing(s14s2q5)
gen check_unexpected_s2q6  = !missing(s14s2q1) & s14s2q1 == 2 & !missing(s14s2q6)
gen check_unexpected_s2q7  = !missing(s14s2q1) & s14s2q1 == 2 & !missing(s14s2q7)
gen check_unexpected_s2q7a = !missing(s14s2q1) & s14s2q1 == 2 & !missing(s14s2q7a)
gen check_unexpected_s2q7b = !missing(s14s2q1) & s14s2q1 == 2 & !missing(s14s2q7b)

* 2. Expected But Missing Responses — only if s14s2q1 == 1
**********************************************************
gen check_missing_s2q2  = !missing(s14s2q1) & s14s2q1 == 1 & missing(s14s2q2)
gen check_missing_s2q3  = !missing(s14s2q1) & s14s2q1 == 1 & missing(s14s2q3)
gen check_missing_s2q4  = !missing(s14s2q1) & s14s2q1 == 1 & missing(s14s2q4)
gen check_missing_s2q5  = !missing(s14s2q1) & s14s2q1 == 1 & missing(s14s2q5)
gen check_missing_s2q6  = !missing(s14s2q1) & s14s2q1 == 1 & missing(s14s2q6)
gen check_missing_s2q7  = !missing(s14s2q1) & s14s2q1 == 1 & missing(s14s2q7)
gen check_missing_s2q7a = !missing(s14s2q1) & s14s2q1 == 1 & missing(s14s2q7a)
gen check_missing_s2q7b = !missing(s14s2q1) & s14s2q1 == 1 & missing(s14s2q7b)

* 3. Invalid (Negative) Responses — only if s14s2q1 == 1
********************************************************
gen check_invalid_s2q2  = !missing(s14s2q1) & s14s2q1 == 1 & s14s2q2  < 0
gen check_invalid_s2q3  = !missing(s14s2q1) & s14s2q1 == 1 & s14s2q3  < 0
gen check_invalid_s2q4  = !missing(s14s2q1) & s14s2q1 == 1 & s14s2q4  < 0
gen check_invalid_s2q5  = !missing(s14s2q1) & s14s2q1 == 1 & s14s2q5  < 0
gen check_invalid_s2q6  = !missing(s14s2q1) & s14s2q1 == 1 & s14s2q6  < 0
gen check_invalid_s2q7  = !missing(s14s2q1) & s14s2q1 == 1 & s14s2q7  < 0
gen check_invalid_s2q7a = !missing(s14s2q1) & s14s2q1 == 1 & s14s2q7a < 0
gen check_invalid_s2q7b = !missing(s14s2q1) & s14s2q1 == 1 & s14s2q7b < 0

* 4. Combine All Error Flags
*****************************
gen Section2_Additional_Errors = ///
    check_unexpected_s2q2 | check_unexpected_s2q3 | check_unexpected_s2q4 | check_unexpected_s2q5 | ///
    check_unexpected_s2q6 | check_unexpected_s2q7 | check_unexpected_s2q7a | check_unexpected_s2q7b | ///
    check_missing_s2q2 | check_missing_s2q3 | check_missing_s2q4 | check_missing_s2q5 | ///
    check_missing_s2q6 | check_missing_s2q7 | check_missing_s2q7a | check_missing_s2q7b | ///
    check_invalid_s2q2 | check_invalid_s2q3 | check_invalid_s2q4 | check_invalid_s2q5 | ///
    check_invalid_s2q6 | check_invalid_s2q7 | check_invalid_s2q7a | check_invalid_s2q7b

gl Expen_Q2_Q7b ($isAnySector & Section2_Additional_Errors)

* 5. Apply Error Flags and Labels
**********************************
replace error_flag = 1 if $Expen_Q2_Q7b
replace section = "Section 2" if $Expen_Q2_Q7b

replace errorCheck = ///
    cond((check_unexpected_s2q2 | check_unexpected_s2q3 | check_unexpected_s2q4 | check_unexpected_s2q5 | ///
          check_unexpected_s2q6 | check_unexpected_s2q7 | check_unexpected_s2q7a | check_unexpected_s2q7b), ///
         "Not Expected", ///
    cond((check_missing_s2q2 | check_missing_s2q3 | check_missing_s2q4 | check_missing_s2q5 | ///
          check_missing_s2q6 | check_missing_s2q7 | check_missing_s2q7a | check_missing_s2q7b), ///
         "Expected But Missing Value", ///
    cond((check_invalid_s2q2 | check_invalid_s2q3 | check_invalid_s2q4 | check_invalid_s2q5 | ///
          check_invalid_s2q6 | check_invalid_s2q7 | check_invalid_s2q7a | check_invalid_s2q7b), ///
         "Invalid (Negative) Value Entered", errorCheck))) if $Expen_Q2_Q7b

replace errorMessage = ///
    cond((check_unexpected_s2q2 | check_unexpected_s2q3 | check_unexpected_s2q4 | check_unexpected_s2q5 | ///
          check_unexpected_s2q6 | check_unexpected_s2q7 | check_unexpected_s2q7a | check_unexpected_s2q7b), ///
         "Section 2: Response(s) in Q2–Q7b not expected as s14s2q1 = 'No' — Establishment '" + EstablishmentName + "'", ///
    cond((check_missing_s2q2 | check_missing_s2q3 | check_missing_s2q4 | check_missing_s2q5 | ///
          check_missing_s2q6 | check_missing_s2q7 | check_missing_s2q7a | check_missing_s2q7b), ///
         "Section 2: Missing value(s) in Q2–Q7b — Establishment '" + EstablishmentName + "'", ///
    cond((check_invalid_s2q2 | check_invalid_s2q3 | check_invalid_s2q4 | check_invalid_s2q5 | ///
          check_invalid_s2q6 | check_invalid_s2q7 | check_invalid_s2q7a | check_invalid_s2q7b), ///
         "Section 2: Negative value(s) found in Q2–Q7b — Establishment '" + EstablishmentName + "'", errorMessage))) if $Expen_Q2_Q7b
	
// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section14_sec2Q2-Q8.dta", replace
// restore


* Sub-section 2 (ENVIRONMENTAL PROTECTION TOTAL VALUE OF CAPITAL TRANSFERS)
**************************************************************************************
// Q8. WHAT IS THE TOTAL VALUE OF CAPITAL TRANSFERS (LOCAL AND INTERNATIONAL) RECEIVED/SENT ON FINANCING ENVIRONMENTAL PROTECTION SERVICES IN 2023?

use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

* 1. Not Expected (Unexpected) Values
**************************************
gen Transfers_Sent_Unexpected = !missing(s14s2q1) & s14s2q1 == 2 & (!missing(s14s2q8a) | !missing(s14s2q8b))
gen Transfers_Received_Unexpected = !missing(s14s2q1) & s14s2q1 == 2 & (!missing(s14s2q8c) | !missing(s14s2q8d))

* 2. Expected but Missing Values
********************************
gen Transfers_Sent_Missing = !missing(s14s2q1) & s14s2q1 == 1 & (missing(s14s2q8a) | missing(s14s2q8b))
gen Transfers_Received_Missing = !missing(s14s2q1) & s14s2q1 == 1 & (missing(s14s2q8c) | missing(s14s2q8d))

* 3. Negative/Invalid Values
*****************************
gen Transfers_Sent_Invalid = (!missing(s14s2q8a) & s14s2q8a < 0) | (!missing(s14s2q8b) & s14s2q8b < 0)
gen Transfers_Received_Invalid = (!missing(s14s2q8c) & s14s2q8c < 0) | (!missing(s14s2q8d) & s14s2q8d < 0)

* 4. Logical Check: Received should not exceed Sent
***************************************************
gen check_received_exceeds_sent = ///
    !missing(s14s2q8a, s14s2q8b, s14s2q8c, s14s2q8d) & ///
    (s14s2q8c + s14s2q8d) > (s14s2q8a + s14s2q8b)

gen Unexpected_Transfers = Transfers_Sent_Unexpected | Transfers_Received_Unexpected
gen Missing_Transfers    = Transfers_Sent_Missing | Transfers_Received_Missing
gen Invalid_Transfers    = Transfers_Sent_Invalid | Transfers_Received_Invalid

gl Capital_Transfers ($isAnySector & (Unexpected_Transfers | Missing_Transfers | Invalid_Transfers | check_received_exceeds_sent))

replace error_flag = 1         if $Capital_Transfers
replace section = "Section 14" if $Capital_Transfers

replace errorCheck = ///
    cond(Unexpected_Transfers, "Not Expected", ///
    cond(Missing_Transfers, "Expected But Missing Value", ///
    cond(!Missing_Transfers & Invalid_Transfers, "Invalid (Negative) Value Entered", ///
    cond(!Missing_Transfers & !Invalid_Transfers & check_received_exceeds_sent, "Transfers Received Exceed Transfers Sent", errorCheck)))) if $Capital_Transfers

replace errorMessage = ///
    cond(Unexpected_Transfers, ///
        "Q8: Unexpected capital transfer value reported by Establishment '" + EstablishmentName + "' when Q1 indicates they do NOT produce environmental protection services.", ///
    cond(Missing_Transfers, ///
        "Q8: Missing capital transfer values (Sent or Received) for Establishment '" + EstablishmentName + "'", ///
    cond(Invalid_Transfers, ///
        "Q8: Negative capital transfer values found for Establishment '" + EstablishmentName + "'", ///
    cond(check_received_exceeds_sent, ///
        "Q8: Transfers Received (Local + Int'l) exceed Transfers Sent for Establishment '" + EstablishmentName + "'", ///
    errorMessage)))) if $Capital_Transfers

* Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section14_sec2Q8.dta", replace
// restore


* Sub-section 2 (ENVIRONMENTAL PROTECTION EXPENDITURE Incurred)
**************************************************************
// Q9. INDICATE THE ENVIRONMENTAL PROTECTION EXPENDITURE INCURRED ON THE FOLLOWING ENVIRONMENTAL ASSETS

use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

* Initialize flags
gen Unexpected_Values     = 0
gen Missing_Values        = 0
gen Invalid_Values        = 0
gen Consistency_Errors    = 0

* Loop through all 9 asset categories
forvalues i = 1/9 {
    
    * Generate field-wise unexpected check: If s14s2q1 == 2, these should be missing
    gen Asset_`i'_Unexpected = !missing(s14s2q1) & s14s2q1 == 2 & ///
        (!missing(s14r2q1_`i') | !missing(s14r2q2_`i') | !missing(s14r2q3_`i'))
    replace Unexpected_Values = 1 if Asset_`i'_Unexpected
    
    * Expected but missing (s14s2q1 == 1, but values missing)
    gen Asset_`i'_Missing = !missing(s14s2q1) & s14s2q1 == 1 & ///
        (missing(s14r2q1_`i') | missing(s14r2q2_`i') | missing(s14r2q3_`i'))
    replace Missing_Values = 1 if Asset_`i'_Missing

    * Negative values check
    gen Asset_`i'_Negative = (!missing(s14r2q1_`i') & s14r2q1_`i' < 0) | ///
                             (!missing(s14r2q2_`i') & s14r2q2_`i' < 0) | ///
                             (!missing(s14r2q3_`i') & s14r2q3_`i' < 0)
    replace Invalid_Values = 1 if Asset_`i'_Negative

    * Logical consistency: End < Begin - Depreciation (with 0.01 tolerance)
    gen Asset_`i'_Inconsistent = !missing(s14r2q1_`i', s14r2q2_`i', s14r2q3_`i') & ///
        (s14r2q3_`i' < (s14r2q1_`i' - s14r2q2_`i' - 0.01))
    replace Consistency_Errors = 1 if Asset_`i'_Inconsistent
}

* Define combined check
gl Asset_Checks ($isAnySector & (Unexpected_Values | Missing_Values | Invalid_Values | Consistency_Errors))

* Flag records
replace error_flag = 1 if $Asset_Checks
replace section = "Section 14" if $Asset_Checks

* Error Type
replace errorCheck = ///
    cond(Unexpected_Values, "Not Expected", ///
    cond(Missing_Values, "Expected But Missing Value", ///
    cond(!Missing_Values & Invalid_Values, "Invalid (Negative) Value Entered", ///
    cond(!Missing_Values & !Invalid_Values & Consistency_Errors, ///
        "Book Value End ≠ (Book Value Beginning - Depreciation)", errorCheck)))) ///
    if $Asset_Checks

replace errorMessage = ///
    cond(Unexpected_Values, ///
        "Sub-Section 2: Unexpected value(s) in Environmental Assets fields for Establishment '" + EstablishmentName + "'", ///
    cond(Missing_Values, ///
        "Sub-Section 2: Missing value(s) in Environmental Assets fields for Establishment '" + EstablishmentName + "'", ///
    cond(Invalid_Values, ///
        "Sub-Section 2: Negative value(s) found in Environmental Assets fields for Establishment '" + EstablishmentName + "'", ///
    cond(Consistency_Errors, ///
        "Sub-Section 2: Book Value End (" + string(s14r2q3_i') + ") " + ///
        "< (Book Value Beginning (" + string(s14r2q1_i') + ") " + ///
        "- Depreciation (" + string(s14r2q2_i') + ")) " + ///
        "for asset 'asset_name' in Establishment '" + EstablishmentName + "'", ///
    errorMessage)))) if $Asset_Checks

* Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section14_sec2Q9.dta", replace
// restore


*Sub-section 3 WASTE DISPOSAL AND MANAGEMENT
********************************************
// Q1. How did your establishment dispose of non-process wastewater in 2023?
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

* 1. Missing Check - No response at all
gen missing_response = missing(s14s3q1_01) & missing(s14s3q1_02) & ///
                     missing(s14s3q1_03) & missing(s14s3q1_04) & ///
                     missing(s14s3q1_05) & missing(s14s3q1_06) & ///
                     missing(s14s3q1_98)

* 2. Not Applicable cannot be combined with other options
gen not_applicable_invalid = s14s3q1_98 == 1 & ///
                           (s14s3q1_01 == 1 | s14s3q1_02 == 1 | ///
                            s14s3q1_03 == 1 | s14s3q1_04 == 1 | ///
                            s14s3q1_05 == 1 | s14s3q1_06 == 1)

gl non_process_wastewater ($isAnySector & (missing_response | not_applicable_invalid))  

replace error_flag = 1         if $non_process_wastewater  
replace section = "Section 14" if $non_process_wastewater  

replace errorCheck = ///
    cond(missing_response, "Missing Response", ///
    cond(not_applicable_invalid, "'Not Applicable' Selected With Other Options", errorCheck)) if $non_process_wastewater  

replace errorMessage = ///
    cond(missing_response, ///
        "Section 14.3: Missing response for non-process wastewater disposal method in Establishment '" + EstablishmentName + "'", ///
    cond(not_applicable_invalid, ///
        "Section 14.3: Cannot select 'Not Applicable' with other non-process wastewater disposal methods in Establishment '" + EstablishmentName + "'", ///
    errorMessage)) if $non_process_wastewater  
	
* Save the data set
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section14_sec3Q1.dta", replace
// restore

*Sub-section 3 WASTE DISPOSAL AND MANAGEMENT
********************************************
// Q2. How did your establishment dispose of processed wastewater in 2023?
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

* 1. Missing Check - Verify at least one response is provided
gen missing_response = missing(s14s3q2_01) & missing(s14s3q2_02) & ///
                     missing(s14s3q2_03) & missing(s14s3q2_04) & ///
                     missing(s14s3q2_05) & missing(s14s3q2_06)

* 2. Validity Check - 'Not Applicable' (option 06) cannot combine with other options
gen not_applicable_invalid = (s14s3q2_06 == 1) & ///
                           (s14s3q2_01 == 1 | s14s3q2_02 == 1 | ///
                            s14s3q2_03 == 1 | s14s3q2_04 == 1 | ///
                            s14s3q2_05 == 1)

gl processed_wastewater ($isAnySector & (missing_response | not_applicable_invalid))

replace error_flag = 1         if $processed_wastewater
replace section = "Section 14" if $processed_wastewater

replace errorCheck = ///
    cond(missing_response, "Missing Response", ///
    cond(not_applicable_invalid, "Invalid Option Combination", errorCheck)) if $processed_wastewater

replace errorMessage = ///
    cond(missing_response, ///
        "Section 14.3: No disposal method selected for processed wastewater in Establishment '" + EstablishmentName + "'", ///
    cond(not_applicable_invalid, ///
        "Section 14.3: 'Not Applicable' cannot be combined with other disposal methods for processed wastewater in Establishment '" + EstablishmentName + "'", ///
    errorMessage)) if $processed_wastewater

* Save error cases
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section14_sec3Q2.dta", replace
// restore


*Sub-section 3 WASTE DISPOSAL AND MANAGEMENT
********************************************
// Q3. What was the composition of your establishment solid waste in 2023?
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

* 1. Missing Check - Verify at least one response is provided
gen missing_response = missing(s14s3q3_01) & missing(s14s3q3_02) & ///
                     missing(s14s3q3_03) & missing(s14s3q3_04) & ///
                     missing(s14s3q3_05) & missing(s14s3q3_98)

* 2. Validity Check - 'Not Applicable' (option 98) cannot combine with other options
gen not_applicable_invalid = (s14s3q3_98 == 1) & ///
                           (s14s3q3_01 == 1 | s14s3q3_02 == 1 | ///
                            s14s3q3_03 == 1 | s14s3q3_04 == 1 | ///
                            s14s3q3_05 == 1)

gl solid_waste ($isAnySector & (missing_response | not_applicable_invalid))

replace error_flag = 1         if $solid_waste
replace section = "Section 14" if $solid_waste

replace errorCheck = ///
    cond(missing_response, "Missing Response", ///
    cond(not_applicable_invalid, "Invalid Option Combination", errorCheck)) if $solid_waste

replace errorMessage = ///
    cond(missing_response, ///
        "Section 14.3: No composition selected for solid waste in Establishment '" + EstablishmentName + "'", ///
    cond(not_applicable_invalid, ///
        "Section 14.3: 'Not Applicable' cannot be combined with other solid waste composition options in Establishment '" + EstablishmentName + "'", ///
    errorMessage)) if $solid_waste

* Save the data set
keep if error_flag == 1
insobs 1
// drop_flag
save "$error_report\Section14_sec3Q3.dta", replace
// restore


*Sub-section 3 WASTE DISPOSAL AND MANAGEMENT
********************************************
// Q4. How did the establishment mainly dispose/treat solid waste (refuse) in 2023?
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

* 1. Missing Check - Verify a response is provided
gen missing_response = missing(s14s34d)

gl solid_waste_disposal ($isAnySector & missing_response)

replace error_flag = 1         if $solid_waste_disposal
replace section = "Section 14" if $solid_waste_disposal

replace errorCheck = "Missing Response" if $solid_waste_disposal

replace errorMessage = ///
    "Section 14.3: No disposal method selected for solid waste in Establishment '" + ///
    EstablishmentName + "'" if $solid_waste_disposal

* Save the data set
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section14_sec3Q4.dta", replace
// restore


*Sub-section 3 WASTE DISPOSAL AND MANAGEMENT
********************************************
// Q5. How did the establishment mainly handle air pollution/smoke/dust in 2023?
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

* 1. Missing Check - Verify a response is provided
gen missing_response = missing(s14s3q5)

gl air_pollution_handling ($isAnySector & missing_response)

replace error_flag = 1         if $air_pollution_handling
replace section = "Section 14" if $air_pollution_handling

replace errorCheck = "Missing Response" if $air_pollution_handling

replace errorMessage = ///
    "Section 14.3: No method selected for air pollution handling in Establishment '" + ///
    EstablishmentName + "'" if $air_pollution_handling

* Save the data set
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section14_sec3Q5.dta", replace
// restore


*Sub-section 3 WASTE DISPOSAL AND MANAGEMENT
********************************************
// Combined validation for Q4 & Q5
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

* Initialize error dataset
tempfile errors
save `errors', emptyok

* Check Q4 - Solid waste disposal
gen missing_q4 = missing(s14s34d)
gl q4_error ($isAnySector & missing_q4)

if $q4_error {
    preserve
    keep if $q4_error
    gen errorCheck = "Missing Response (Q4)"
    gen errorMessage = "Section 14.3: No solid waste disposal method selected in Establishment '" + ///
                     EstablishmentName + "'"
    gen error_flag = 1
    gen section = "Section 14"
    keep Establishment* error* section
    append using `errors'
    save `errors', replace
    restore
}

* Check Q5 - Air pollution handling
gen missing_q5 = missing(s14s3q5)
gl q5_error ($isAnySector & missing_q5)

if $q5_error {
    preserve
    keep if $q5_error
    gen errorCheck = "Missing Response (Q5)"
    gen errorMessage = "Section 14.3: No air pollution handling method selected in Establishment '" + ///
                     EstablishmentName + "'"
    gen error_flag = 1
    gen section = "Section 14"
    keep Establishment* error* section
    append using `errors'
    save `errors', replace
    restore
}

* save data set
use `errors', clear
insobs 1
save "$error_report\Section14_sec3_Q4Q5.dta", replace
// restore