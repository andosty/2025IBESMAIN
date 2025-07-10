*==================================
* SECTION 01: INTERVIEW COVERPAGE 
*==================================

*****************************
* Question C1.2.0. second check
*****************************
* C1.2.0, Response for Has the establishment name changed since the listing (IBE I) is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve
gl invalidNameChangeQues ($isAnySector & missing(id13a)| !inlist(id13a, 1,2))  


replace section = "Section 01" if $invalidNameChangeQues
replace error_flag = 1         if $invalidNameChangeQues
replace errorCheck  = cond(missing(id13a), "Missing Check", "Invalid selection") if $invalidNameChangeQues
replace errorMessage = cond(missing(id13a), ///
  "Que. 1.2.0,  Has the Establishment=(" + EstablishmentName + ") name changed,cannot be blank", ///
  "Que. 1.2.0, option selected for Establishment=(" + EstablishmentName + ") if Name has been changed is not valid (must be either YES OR NO)") if $invalidNameChangeQues

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.0.dta", replace
// restore

*******************************
* Question C1.2.0b First check
*******************************
* C1.2.2b,  Name for New Establishment Name is not expected
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl UnexpectedNewName ($isAnySector & !missing(id13a) & id13a == 2 & !missing(id13n))  

* Map numeric values to "Yes"/"No"
tempvar id13a_label
gen `id13a_label' = ""
replace `id13a_label' = "Yes" if id13a == 1
replace `id13a_label' = "No"  if id13a == 2

replace error_flag = 1 if $UnexpectedNewName
replace section = "Section 1"       if $UnexpectedNewName
replace errorCheck = "Not Expected" if $UnexpectedNewName
replace errorMessage = ("Que.1.2.0b, New Establishment Name=('" + id13n + "')" + ///
"is not expected if Establishment name change is=('" + `id13a_label' + "')") if $UnexpectedNewName

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.0b1.dta", replace
// restore

********************************
* Question C1.2.0b second check
********************************
* C1.2.0b, Name for New Establishment Name is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl invalidNewName ($isAnySector & (!missing(id13a) & id13a == 1 & (missing(id13n)| (!missing(id13n) & (wordcount(id13n) < 2)))))  

* Map numeric values to "Yes"/"No"
tempvar id13a_label
gen `id13a_label' = ""
replace `id13a_label' = "Yes" if id13a == 1
replace `id13a_label' = "No"  if id13a == 2

replace section = "Section 1" if $invalidNewName
replace error_flag = 1        if $invalidNewName
replace errorCheck  = cond(missing(id13n), "Missing check", "Invalid description") if $invalidNewName
replace errorMessage = ///
  cond(missing(id13n), ///
    "Que. 1.2.0b, New-Name for old-Name Establishment=('" + EstablishmentName + "') cannot be blank if Establishment name change is ('" + `id13a_label' + "')", ///
    `"Que. 1.2.0b,New name of the Establishment=("' + id13n + `") is not accepted, describe its full name"')  if $invalidNewName

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.0b2.dta", replace
// restore


*****************************
* Question C1.2.1b second check
*****************************
* C1.2.1b, Response for Has the Establishment Digital Address changed since the listing (IBES I) is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve
gl ChangeNewGPDA ($isAnySector & missing(id13pb)| !inlist(id13pb, 1,2))  


replace section = "Section 01" if $ChangeNewGPDA
replace error_flag = 1         if $ChangeNewGPDA
replace errorCheck  = cond(missing(id13pb), "Missing Check", "Invalid selection") if $ChangeNewGPDA
replace errorMessage = cond(missing(id13pb), ///
  "Que. 1.2.1b,  Has the Establishment=(" + EstablishmentName + ") Digital Address changed,cannot be blank", ///
  "Que. 1.2.1b, option selected for Establishment=(" + EstablishmentName + ") Digital Address has been changed is not valid (must be either YES OR NO)") if $ChangeNewGPDA

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.1b.dta", replace
// restore


*******************************
* Question C1.2.1c first check
*******************************
* C1.2.1c,  New Establishment Digital Address is not expected
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl UnexpectedChangeNewGPDA ($isAnySector & !missing(id13pb) & id13pb == 2 & !missing(id13pc))  

* Map numeric values to "Yes"/"No"
tempvar id13pb_label
gen `id13pb_label' = ""
replace `id13pb_label' = "Yes" if id13pb == 1
replace `id13pb_label' = "No"  if id13pb == 2

replace error_flag = 1 if $UnexpectedChangeNewGPDA
replace section = "Section 1"       if $UnexpectedChangeNewGPDA
replace errorCheck = "Not Expected Check" if $UnexpectedChangeNewGPDA
replace errorMessage = ("Que.1.2.1c, New Establishment Digital Address=('" + id13pc + "')" + ///
"is not expected if Establishment Digital Addresss change is=('" + `id13pb_label' + "')") if $UnexpectedChangeNewGPDA

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.1c1.dta", replace
// restore


*****************************
* Question C1.2.1c second check
*****************************
* C1.2.1c,  New Establishment Digital Address is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

* Map numeric values to "Yes"/"No"
tempvar id13pb_label
gen `id13pb_label' = ""
replace `id13pb_label' = "Yes" if id13pb == 1
replace `id13pb_label' = "No"  if id13pb == 2

// replace id13pc = strtrim(ustrnormalize(id13pc, "nfc")) // Normalize text
// replace id13pc = subinstr(id13pc, char(160), "", .) // Remove hidden spaces
// replace id13pc = stritrim(id13pc) // Remove extra internal spaces
// replace id13pc = subinstr(id13pc, "–", "-", .) // Replace en-dash with hyphen


* 3. Update the invalid condition
gl invalidNewGPDA ($isAnySector & !missing(id13pb) & id13pb == 1 & ///
    (missing(id13pc) | (!missing(id13pc) & !ustrregexm(id13pc, "^[a-zA-Z]{2}-[0-9]{3}-[0-9]{3,4}$"))))
	
replace section = "Section 01" if $invalidNewGPDA
replace error_flag = 1         if $invalidNewGPDA
replace errorCheck  = cond(missing(id13pc), "Missing check", "Invalid description") if $invalidNewGPDA
replace errorMessage = ///
    cond(missing(id13pc), ///
     "Que. 1.2.1c, New Digital Address for (" + EstablishmentName + ") cannot be blank if Establishment Digital Addresss change is=('" + `id13pb_label' + "')", ///
      "Que. 1.2.1c, The New Digital Address('" + id13pc + "') is not a valid Digital Address for (" + EstablishmentName + ")"  ) if $invalidNewGPDA
	
// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.1c2.dta", replace
// restore


*******************************
* Question C1.2.2b second check
*******************************
* C1.2.2b,  New Establishment Postal Address is invalid

use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl invalidPostalAddress ($isAnySector & (missing(id13b)| !missing(id13b) & !inlist(id13b, 1,2)))  

replace section = "Section 01" if $invalidPostalAddress
replace error_flag = 1         if $invalidPostalAddress
replace errorCheck  = cond(missing(id13b), "Missing Check", "Invalid selection") if $invalidPostalAddress
replace errorMessage = cond(missing(id13b), ///
  "Que. 1.2.2b, Has the (" + EstablishmentName + ") Postal Address change, cannot be blank", ///
  "Que. 1.2.2b, option selected for (" + EstablishmentName + ") Postal Address is not valid (must be either YES OR NO)") if $invalidPostalAddress

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.2b.dta", replace
// restore

*****************************
* Question C1.2.2c First check
*****************************
* C1.2.2c,  New Establishment Postal Address is not expected
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

* Map numeric values to "Yes"/"No"
tempvar id13b_label
gen `id13b_label' = ""
replace `id13b_label' = "Yes" if id13b == 1
replace `id13b_label' = "No"  if id13b == 2

gl UnexpecteNewPostalAddress ($isAnySector & !missing(id13b) & id13b == 2 & !missing(id13c))  

replace error_flag = 1 if $UnexpecteNewPostalAddress
replace section = "Section 01" if $UnexpecteNewPostalAddress
replace errorCheck = "Not Expected" if $UnexpecteNewPostalAddress
replace errorMessage = ("Que.1.2.2c, New Establishment Postal Address=('" + id13c + "')" + ///
"is not expected if Establishment Postal Address change is=('" + `id13b_label' + "')") if $UnexpecteNewPostalAddress

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.2c1.dta", replace
// restore

*****************************
* Question C1.2.2c second check
*****************************
* C1.2.2c, New Establishment Postal Address is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

* Clean and standardize the postal address
gen str cleaned_id13c = lower(strtrim(id13c))
replace cleaned_id13c = ustrregexra(cleaned_id13c, "\s+", " ")

// gl validPostalRegex "^(p\.?\s*o\.?\s*box|post\.?\s*office\.?\s*box)\s+([a-zA-Z]{2})?\s*\d+([,]?\s*[a-z\s]*)?$"

gl invalidPostalAddress ($isAnySector & ///
    (!missing(id13b) & id13b == 1 & ///
    (missing(id13c) | ///
    (!missing(id13c) & !regexm(cleaned_id13c, "^(p\.?\s*o\.?\s*box|post\.?\s*office\.?\s*box)\s+([a-zA-Z]{2})?\s*\d+([,]?\s*[a-z\s]*)?$")))))

* Map numeric values to "Yes"/"No"
tempvar id13b_label
gen `id13b_label' = ""
replace `id13b_label' = "Yes" if id13b == 1
replace `id13b_label' = "No" if id13b == 2

* Apply error flags and messages
replace error_flag = 1 if $invalidPostalAddress
replace section = "Section 01" if $invalidPostalAddress
replace errorCheck = cond(missing(id13c), "Missing response", "Invalid Format") if $invalidPostalAddress
replace errorMessage = cond(missing(id13c), ///
    "Que. 1.2.2c: New Postal Address for " + EstablishmentName + " cannot be blank if Postal Address change is ('" + `id13b_label' + "')", ///
    "Que. 1.2.2c: ('" + id13c + "') is invalid if Postal Address change is ('" + `id13b_label' + "'). Valid formats: " + ///
    "P.O.BOX 123,Location or PMB 789,KNUST") if $invalidPostalAddress
	
// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.2c2.dta", replace
// restore


*****************************
* Question c1.2.3a second check
*****************************
* C1.2.3a,  New Establishment Telephone Number is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl invalidTelnumber ($isAnySector & (missing(id14b))|(!missing(id14b) & !inlist(id14b, 1,2)))  

replace section = "Section 01" if $invalidTelnumber
replace error_flag = 1            if $invalidTelnumber
replace errorCheck  = cond(missing(id14b), "Missing check", "Invalid selection") if $invalidTelnumber
replace errorMessage = cond(missing(id14b), ///
  "Que. 1.2.3a, Has the (" + EstablishmentName + ") Telephone number change Ques, cannot be blank", ///
  "Que. 1.2.3a, option selected for (" + EstablishmentName + "),New Telephone number is invalid (must be either YES OR NO)") if $invalidTelnumber


// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.3a.dta", replace
// restore

*****************************
* Question C1.2.3b First check
*****************************
* C1.2.3b, is the contact A GH number is not expected

use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl UnexpectedNewTelnumber ($isAnySector & !missing(id14b) & id14b == 2 & !missing(id14c2))  

* Map numeric values to "Yes"/"No"
tempvar id14b_label
gen `id14b_label' = ""
replace `id14b_label' = "Yes" if id14b == 1
replace `id14b_label' = "No" if id14b == 2

replace error_flag = 1 if $UnexpectedNewTelnumber
replace section = "Section 01" if $UnexpectedNewTelnumber
replace errorCheck = "Not Expected" if $UnexpectedNewTelnumber
replace errorMessage = "Que.1.2.3b, New GH Establishment Telephone Number is not expected if Change in Estab contact is =('" ///
 + `id14b_label' + "')" if $UnexpectedNewTelnumber

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.3b1.dta", replace
// restore

*****************************
* Question C1.2.3b second check
*****************************
* C1.2.3b, is the contact A GH number is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl WhatNewTelnumber ($isAnySector & (!missing(id14b) & id14b == 1 & missing(id14c2)) | (!missing(id14b) & id14b == 1 & !missing(id14c2) & !inlist(id14c2, 1,2)))

replace error_flag = 1 if $WhatNewTelnumber
replace section = "Section 01" if $WhatNewTelnumber
replace errorCheck = cond(missing(id14c2), "Missing check", "Invalid selection") if $WhatNewTelnumber
replace errorMessage = cond(missing(id14c2), ///
    "Que. 1.2.3b, Is (" + EstablishmentName + ") contact a Gh number cannot be blank", ///
  "Que. 1.2.3b, Is (" + EstablishmentName + ") contact a GH number, not valid (must be either YES OR NO)") if $WhatNewTelnumber
	
// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.3b2.dta", replace
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


*****************************
* Question C1.2.3c second check
*****************************
* C1.2.3c, Ghanaian contact number is not invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gen byte is_missing_gh_number = !missing(id14c2) & id14c2 == 1 & missing(id14c)

gen str3 contact_prefix = substr(id14c, 1, 3)

*local macro with all valid prefixes to make the code more readable
local valid_prefixes "020 023 024 025 026 027 028 029 050 053 054 055 056 057 059 031 032 033 034 035 036 037 038 039"

gen byte is_invalid_prefix = 1 // Initialize the variable first


* valid prefixes
foreach prefix of local valid_prefixes {
    replace is_invalid_prefix = 0 if contact_prefix == "`prefix'"
}

gen byte is_invalid_gh_number = !missing(id14c2) & id14c2 == 1 & !missing(id14c) & is_invalid_prefix

gen byte InvalidGhNewTelnumber = is_missing_gh_number | is_invalid_gh_number
gl InvalidGhNewTelnumber "InvalidGhNewTelnumber"

replace error_flag = 1 if $InvalidGhNewTelnumber
replace section = "Section 01" if $InvalidGhNewTelnumber
replace errorCheck = cond(missing(id14c), "Missing check", "Invalid Entry - Establishment Contact") if $InvalidGhNewTelnumber
replace errorMessage = cond(missing(id14c), ///
    "Que. 1.2.3c, Ghanaian contact number for (" + EstablishmentName + ") cannot be blank", ///
    "Que. 1.2.3c, Contact prefix - " + id14c + " of " + EstablishmentName + " not related to any network in Ghana") if $InvalidGhNewTelnumber

//Save data set
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.3c2.dta", replace
// restore

*****************************
* Question C1.2.3c Third check
*****************************
* C1.2.3c,  Ghanaian contact number (contact number length) checks
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl InvalidlengthGhnumber ($isAnySector  & !missing(id14c) & (strlen(id14c) < 10 | strlen(id14c) > 10))
replace error_flag = 1 if $InvalidlengthGhnumber
replace section = "Section 01" if $InvalidlengthGhnumber
replace errorCheck = "invalid Gh contact length" if $InvalidlengthGhnumber
replace errorMessage = "Que. 1.2.3c," + EstablishmentName  + "'s contact length - " + (id14c) + " needs to be checked" if $InvalidlengthGhnumber
	
// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.3c3.dta", replace
// restore

********************************
* Question C1.2.3d First check   // Making reference with QC1.2.3c
********************************
* C1.2.3d, Foreign contact number is not expected
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl UnexpectedForeignNewTelnumber ($isAnySector & !missing(id14c2) & id14c2 == 1 & !missing(id14c3))

* Map numeric values to "Yes"/"No"
tempvar id14c2_label
gen `id14c2_label' = ""
replace `id14c2_label' = "Yes" if id14c2 == 1
replace `id14c2_label' = "No"  if id14c2 == 2

replace error_flag = 1 if $UnexpectedForeignNewTelnumber
replace section = "Section 1" if $UnexpectedForeignNewTelnumber
replace errorCheck = "Not Expected" if $UnexpectedForeignNewTelnumber
replace errorMessage = "Que.1.2.3d, Foreign contact Number for (" + EstablishmentName + ") is not expected if it is a GH conatct ('" ///
 + `id14b_label' + "')" if $UnexpectedForeignNewTelnumber

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.3d1.dta", replace
// restore

*****************************
* Question C1.2.3d second check
*****************************
* C1.2.3d,  Foreign contact number is not invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

// First define any helper variables you need
gen byte is_foreign_selected = !missing(id14c2) & id14c2 == 2

// Better approach for checking Ghanaian prefixes
gen str3 contact_prefix = substr(id14c3, 1, 3)
gen byte has_ghanaian_prefix = 0

// Define valid prefixes in a local macro
local ghana_prefixes "020 023 024 025 026 027 028 029 050 053 054 055 056 057 059 031 032 033 034 035 036 037 038 039"

// Check each prefix one by one
foreach prefix of local ghana_prefixes {
    replace has_ghanaian_prefix = 1 if contact_prefix == "`prefix'"
}

// Define the condition
gen byte InvalidForeignNewTelnumber = $isAnySector & ///
    (is_foreign_selected & missing(id14c3)) | ///
    (is_foreign_selected & !missing(id14c3) & has_ghanaian_prefix)

replace error_flag = 1 if InvalidForeignNewTelnumber
replace section = "Section 01" if InvalidForeignNewTelnumber
replace errorCheck = cond(missing(id14c3), "Missing response", "Invalid Entry - Establishment Contact") if InvalidForeignNewTelnumber
replace errorMessage = cond(missing(id14c3), ///
    "Que. 1.2.3d, Foreign contact number for (" + EstablishmentName + ") cannot be blank", ///
    "Que. 1.2.3d, Contact prefix - " + id14c3 + " of " + EstablishmentName + " is related to a network in Ghana which shouldn't be") if InvalidForeignNewTelnumber

// Save only error cases
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.3d2.dta", replace
// restore


/*
*****************************
* Questions C1.2.3c and C1.2.3d Combined Checks
*****************************
* C1.2.3c – Ghanaian contact number must be valid
* C1.2.3d – Foreign contact number must not resemble a Ghanaian number

use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

*** Ghanaian Contact Number Check ***
gen byte is_missing_gh_number = !missing(id14c2) & id14c2 == 1 & missing(id14c)
gen str3 contact_prefix_gh = substr(id14c, 1, 3)

* Valid Ghanaian prefixes
local valid_prefixes "020 023 024 025 026 027 028 029 050 053 054 055 056 057 059 031 032 033 034 035 036 037 038 039"
gen byte is_invalid_prefix = 1
foreach prefix of local valid_prefixes {
    replace is_invalid_prefix = 0 if contact_prefix_gh == "`prefix'"
}

gen byte is_invalid_gh_number = !missing(id14c2) & id14c2 == 1 & !missing(id14c) & is_invalid_prefix
gen byte InvalidGhNewTelnumber = is_missing_gh_number | is_invalid_gh_number
gl InvalidGhNewTelnumber InvalidGhNewTelnumber

*** Foreign Contact Number Check ***
gen byte is_foreign_selected = !missing(id14c2) & id14c2 == 2
gen str3 contact_prefix_foreign = substr(id14c3, 1, 3)
gen byte has_ghanaian_prefix = 0
foreach prefix of local valid_prefixes {
    replace has_ghanaian_prefix = 1 if contact_prefix_foreign == "`prefix'"
}

gen byte InvalidForeignNewTelnumber = ///
    (is_foreign_selected & missing(id14c3)) | ///
    (is_foreign_selected & !missing(id14c3) & has_ghanaian_prefix)
gl InvalidForeignNewTelnumber InvalidForeignNewTelnumber

*** Combine and flag all errors ***
//capture drop error_flag
// gen byte error_flag = 0
replace error_flag = 1 if $InvalidGhNewTelnumber | $InvalidForeignNewTelnumber

// capture drop section
// gen section = ""
replace section = "Section 01" if error_flag == 1

// gen errorCheck = ""
replace errorCheck = "Missing check" if $InvalidGhNewTelnumber & missing(id14c)
replace errorCheck = "Invalid Entry - Establishment Contact" if $InvalidGhNewTelnumber & !missing(id14c)
replace errorCheck = "Missing check" if $InvalidForeignNewTelnumber & missing(id14c3)
replace errorCheck = "Invalid Entry - Establishment Contact" if $InvalidForeignNewTelnumber & !missing(id14c3)

// gen errorMessage = ""
replace errorMessage = "Que. 1.2.3c, Ghanaian contact number for (" + EstablishmentName + ") cannot be blank" ///
    if $InvalidGhNewTelnumber & missing(id14c)
replace errorMessage = "Que. 1.2.3c, Contact prefix - " + id14c + " of " + EstablishmentName + " not related to any network in Ghana" ///
    if $InvalidGhNewTelnumber & !missing(id14c)
replace errorMessage = "Que. 1.2.3d, Foreign contact number for (" + EstablishmentName + ") cannot be blank" ///
    if $InvalidForeignNewTelnumber & missing(id14c3)
replace errorMessage = "Que. 1.2.3d, Contact prefix - " + id14c3 + " of " + EstablishmentName + " is related to a network in Ghana which shouldn't be" ///
    if $InvalidForeignNewTelnumber & !missing(id14c3)

*** Save error report ***
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.3c_d_combined.dta", replace
// restore
*/

*****************************
* Question C1.2.4a second check
*****************************
* C1.2.4a, Establishment Email Change is not invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl invalidEmailAddress ($isAnySector & missing(id15b)| !inlist(id15b, 1,2))  

replace section = "Section 01" if $invalidEmailAddress
replace error_flag = 1            if $invalidEmailAddress
replace errorCheck  = cond(missing(id15b), "Missing check", "Invalid selection") if $invalidEmailAddress
replace errorMessage = cond(missing(id15b), ///
  "Que. 1.2.4a, Has (" + EstablishmentName + ") Email Address change, cannot be blank", ///
  "Que. 1.2.4a, option selected for (" + EstablishmentName + ") Email Address is not valid (must be either YES OR NO)") if $invalidEmailAddress

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.4a.dta", replace
// restore

*****************************
* Question C1.2.4b First check
*****************************
* C1.2.4b, Enter the new Email is not expected
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl UnexpectedNewEmail ($isAnySector & !missing(id15b) & id15b == 2 & !missing(id15c))  

* Map numeric values to "Yes"/"No"
tempvar id15b_label
gen `id15b_label' = ""
replace `id15b_label' = "Yes" if id15b == 1
replace `id15b_label' = "No"  if id15b == 2

replace error_flag = 1 if $UnexpectedNewEmail
replace section = "Section 01" if $UnexpectedNewEmail
replace errorCheck = "Not Expected" if $UnexpectedNewEmail
replace errorMessage = "Que.1.2.4b, New Email for (" + EstablishmentName + ") is not expected if Estab Email is the same ('" ///
 + `id15b_label' + "') " if $UnexpectedNewEmail

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.4b1.dta", replace
// restore

*****************************
* Question C1.2.4b second check
*****************************
* C1.2.4b, New Email is invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

// Create indicators for each validation rule
gen NewEmail_missing = $isAnySector & !missing(id15b) & id15b == 1 & missing(id15c)
gen NewEamilFormat_Invalid = $isAnySector  & id15b == 1 & !missing(id15c) & ///
!regexm(id15c,"^[A-Za-z0-9._%+-]+@(gmail|yahoo|outlook|hotmail|icloud|(.*\.gov|.*\.edu|.*\.org|.*\.gh))\.(com|net|org|gov|edu|gh)$")

// Combine all error conditions
gl InvalidNewEmail = NewEmail_missing | NewEamilFormat_Invalid 


replace error_flag = 1 if $InvalidNewEmail
replace section = "Section 01" if $InvalidNewEmail
replace errorCheck = cond(missing(id15c), "Missing response", "Invalid Email Address - Format") if $InvalidNewEmail
replace errorMessage = cond(missing(id15c), ///
			"Que. 1.2.4b, Is (" + EstablishmentName + ") New Email cannot be blank", ///
			"Que. 1.2.4b, New email address '" + id15c + "' entered for " + EstablishmentName + ///
						   "is not a valid format (eg. user@example.com).") if $InvalidNewEmail	
						   
// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.4b2.dta", replace
// restore


*****************************
* Question C1.2.4a second check
*****************************
* C1.2.4a, Establishment Email Change is not invalid
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
// preserve

gl invalidEmailAddress ($isAnySector & missing(id15b)| !inlist(id15b, 1,2))  

replace section = "Section 01" if $invalidEmailAddress
replace error_flag = 1            if $invalidEmailAddress
replace errorCheck  = cond(missing(id15b), "Missing check", "Invalid selection") if $invalidEmailAddress
replace errorMessage = cond(missing(id15b), ///
  "Que. 1.2.4a, Has (" + EstablishmentName + ") Email Address change, cannot be blank", ///
  "Que. 1.2.4a, option selected for (" + EstablishmentName + ") Email Address is not valid (must be either YES OR NO)") if $invalidEmailAddress

// Save the dataset
keep if error_flag == 1
insobs 1
// drop error_flag
save "$error_report\Section01_1.2.4a.dta", replace
// restore

