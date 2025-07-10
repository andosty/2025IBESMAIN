******************************
* SECTION 2: EMPLOYMENT AND EARNINGS - FINAL VERSION *
******************************

* This file contains comprehensive error checks for Section 2 (Employment and Earnings)
* Includes basic checks, advanced sector-specific checks, dictionary validation rules,
* and new outlier checks for supplements.
* Following the exact format of SECTION 0A template.
* Created: May 21, 2025
* Last Updated: June 02, 2025 

* Define global macros for sector eligibility (Ensure these are defined in your main script)
// gl isAnySector ($canStartInterv & $canAnsBusQues) // Assuming these globals exist
// gl isAgricSec    (Sub_Sector == 1 & $canStartInterv & $canAnsBusQues)
// gl isMinQuaSec   (Sub_Sector == 2 & $canStartInterv & $canAnsBusQues)
// gl isManufSec    (Sub_Sector == 3 & $canStartInterv & $canAnsBusQues)
// gl isElectwatSec (Sub_Sector == 4 & $canStartInterv & $canAnsBusQues)
// gl isConstrucSec (Sub_Sector == 5 & $canStartInterv & $canAnsBusQues)
// gl isServ1Sec    (Sub_Sector == 6 & $canStartInterv & $canAnsBusQues)
// gl isServ2Sec    (Sub_Sector == 7 & $canStartInterv & $canAnsBusQues)
// gl isWholeRetailSec (Sub_Sector == 8 & $canStartInterv & $canAnsBusQues)
// gl isEnvironSec     (Sub_Sector == 9 & $canStartInterv & $canAnsBusQues)

* defining a default global safe version:
gl isAnySector (1 == 1) // Applies to all observations if globals not set

* Defining tolerance for floating point comparison
local tolerance = 0.01



*************************************
* PART 0: LOAD AND MERGE EMPLOYEE COUNT ROSTER DATA
*************************************

* Loading the roster file
use "C:\2025IBESMAIN\HQData\s2r1_persons_engaged_1.dta", clear

* Keeping only relevant numeric IDs
keep if inlist(s2r1_persons_engaged_1__id, 3, 4, 5, 7, 8, 9)

* Keeping necessary variables
keep interview__key s2r1_persons_engaged_1__id s2r1q1

* Reshape wide using numeric IDs
reshape wide s2r1q1, i(interview__key) j(s2r1_persons_engaged_1__id)

* Rename reshaped vars for clarity
rename s2r1q13 operatives_engaged
rename s2r1q14 managers_engaged
rename s2r1q15 other_employees_engaged
rename s2r1q17 working_proprietors_engaged
rename s2r1q18 learners_engaged
rename s2r1q19 family_workers_engaged

* Generating the combined variable
gen specific_group_engaged = operatives_engaged + managers_engaged + other_employees_engaged + ///
                         working_proprietors_ + learners_engaged + family_workers_engaged

* Save to temp and merge with main data
tempfile subgroup_counts
save `subgroup_counts'

use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
merge 1:1 interview__key using `subgroup_counts'
keep if _merge == 3
drop _merge

save "$prepData\ibes_ii Estabs valid_dateCase_only.dta", replace
*************************************
* PART 1: BASIC ERROR CHECKS
*************************************

*************************************
* TOTAL PERSONS ENGAGED CHECKS
*************************************
*************************
* Check 1: Total Persons Engaged (Combined Missing/Invalid + Org Type Checks)
*************************
*Sec 2, Total Persons Engaged validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

decode id17, gen(id17_new) // Ownership Type
decode id20, gen(id20_new) // Legal Organization

* Condition 1: Missing or less than 1 (Basic check)
gl invalidBasicPersonsEngaged ($isAnySector & (missing(s2r1q1_persons_engaged_total) | (!missing(s2r1q1_persons_engaged_total) & s2r1q1_persons_engaged_total < 1)))

* Condition 2: Low count (<=5) for specific ownership/legal types (Govt, Foreign, Public Ltd, Private Ltd, Other Ltd, Coop, Other)
gl lowCountPersonsEngaged ($isAnySector & (inlist(id17,1,3) | inrange(id20,3,11)) & !missing(s2r1q1_persons_engaged_total) & s2r1q1_persons_engaged_total <= 5)

* Condition 3: Partnership (id20=2) requires at least 2 persons engaged
gl lowPartnerEngaged ($isAnySector & id20 == 2 & !missing(s2r1q1_persons_engaged_total) & s2r1q1_persons_engaged_total < 2)

* Combine conditions
gl invalidPersonsEngaged ($invalidBasicPersonsEngaged | $lowCountPersonsEngaged | $lowPartnerEngaged)

replace section = "Section 02" if $invalidPersonsEngaged
replace error_flag = 1 if $invalidPersonsEngaged
replace errorCheck = cond($invalidBasicPersonsEngaged, "Invalid Persons Engaged (Missing or < 1)", cond($lowPartnerEngaged, "Invalid Persons Engaged (Partnership < 2)", "Low Persons Engaged for Org Type")) if $invalidPersonsEngaged
replace errorMessage = cond($invalidBasicPersonsEngaged, ///
    cond(missing(s2r1q1_persons_engaged_total), "S2Q1 Error: Total Persons Engaged is missing. This value is required.", "S2Q1 Error: Total Persons Engaged must be 1 or more. Current number of Persons engaged = " + string(s2r1q1_persons_engaged_total)), ///
    cond($lowPartnerEngaged, ///
    "S2Q1 Error: Partnerships (Legal Org = " + id20_new + ") must have at least 2 persons engaged. Current number of Persons engaged = " + string(s2r1q1_persons_engaged_total), ///
    "S2Q1 Warning: Total Persons Engaged = " + string(s2r1q1_persons_engaged_total) + " seems low for Ownership Type = " + id17_new + " and  Legal Org = " + id20_new + ". Please verify and make necessary correction.")) if $invalidPersonsEngaged

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_persons_engaged.dta", replace

*************************************
* EMPLOYEES CHECKS
*************************************

*************************
* Check 2: Total Employees (Combined Missing/Invalid + Org Type Checks)
*************************
*Sec 2, Total Employees validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

decode id17, gen(id17_new)
decode id20, gen(id20_new)

* Condition 1: Missing or less than 0 (Basic check - allowing 0 employees, but not if not Sole Proprietor)
gl invalidBasicEmployees ($isAnySector & (missing(s2r1q1_employee_total) | (!missing(s2r1q1_employee_total) & s2r1q1_employee_total < 0) | (!missing(s2r1q1_employee_total) & s2r1q1_employee_total < 1 & id20 != 1)))

* Condition 2: Low count (<=2) for specific ownership/legal types (Govt, Foreign, Partnership, Public Ltd, Private Ltd, Other Ltd, Coop, Other)
gl lowCountEmployees ($isAnySector & (inlist(id17,1,3) | inrange(id20,3,11)) & !missing(s2r1q1_employee_total) & s2r1q1_employee_total <= 2 & s2r1q1_employee_total > 0)

* Combine conditions
gl invalidEmployees ($invalidBasicEmployees | $lowCountEmployees)

replace section = "Section 02" if $invalidEmployees
replace error_flag = 1 if $invalidEmployees
replace errorCheck = cond($invalidBasicEmployees, "Invalid Total Employees (Missing, <0, or <1 for Non-Sole Prop)", "Low Total Employees for Org Type") if $invalidEmployees
replace errorMessage = cond($invalidBasicEmployees, ///
    cond(missing(s2r1q1_employee_total), "S2Q1.1 Error: Total Employees is missing. This value is required.", ///
        cond(s2r1q1_employee_total < 0, "S2Q1.1 Error: Total Employees cannot be negative. Current number of Employees = " + string(s2r1q1_employee_total), ///
        "*S2Q1.1 Error: Total Employees must be at least 1 for Legal Org = " + id20_new + ".  Current number of Employees = " + string(s2r1q1_employee_total))), ///
    "S2Q1.1 Warning: Total Employees = " + string(s2r1q1_employee_total) + " seems low  for Ownership Type = " + id17_new + " and Legal Org = " + id20_new + ". Please verify the number of employees.") if $invalidEmployees

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_employees.dta", replace

*************************
* Check 3: Operatives (Combined Missing/Invalid + Org Type Checks)
*************************
*Sec 2, Operatives validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

decode id17, gen(id17_new)
decode id20, gen(id20_new)

* Condition 1: Missing when Total Employees > 0, or less than 0 (Basic check, allow 0 if Total Emp = 0 or Sole Prop)
gl invalidBasicOperatives ($isAnySector & ((!missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0 & missing(operatives_engaged)) | (!missing(operatives_engaged) & operatives_engaged < 0) | (!missing(operatives_engaged) & operatives_engaged < 1 & id20 != 1 & s2r1q1_employee_total > 5)))

* Condition 2: Low count (<=5) if Total Employees is greater than or equal 20 for specific ownership/legal types (Govt, Foreign, Public Ltd, Private Ltd, Other Ltd, Coop, Other)
gl lowCountOperatives ($isAnySector & (inlist(id17,1,3) | inrange(id20,3,11)) & !missing(operatives_engaged) & operatives_engaged <= 5 & s2r1q1_employee_total >= 20)

* Combine conditions
gl invalidOperatives ($invalidBasicOperatives | $lowCountOperatives)

replace section = "Section 02" if $invalidOperatives
replace error_flag = 1 if $invalidOperatives
replace errorCheck = cond($invalidBasicOperatives, "Invalid Operatives (Missing, <0, or <1 for Non-Sole Prop)", "Low Operatives for Org Type") if $invalidOperatives
replace errorMessage = cond($invalidBasicOperatives, ///
    cond(missing(operatives_engaged) & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0, "S2Q1.1.1 Error: Operatives employee is missing, but Total Employees > 0.", ///
        cond(operatives_engaged < 0, "S2Q1.1.1 Error: Operatives employee cannot be negative. Current number of Operatives = " + string(operatives_engaged), ///
        "S2Q1.1.1 Error: Operatives employee must be at least 1 if Total Employees > 5 and Legal Org is not Sole Proprietor (Legal Org = " + id20_new + "). Current number of Operatives = " + string(operatives_engaged))), ///
    "S2Q1.1.1 Warning: Operatives employee = " + string(operatives_engaged) + " seems low (<=5 if Total Employees>=20) for Ownership Type = " + id17_new + " and Legal Org = " + id20_new + ". Please verify the number of operatives.") if $invalidOperatives

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_operatives.dta", replace

*************************
* Check 4: Paid Managers (Combined Missing/Invalid + Org Type Checks)
*************************
*Sec 2, Paid Managers validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

decode id17, gen(id17_new)
decode id20, gen(id20_new)

* Condition 1: Missing when Total Employees > 0, or less than 0 (Basic check, allow 0 if Sole Prop)
gl invalidBasicManagers ($isAnySector & ((!missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0 & missing(managers_engaged)) | (!missing(managers_engaged) & managers_engaged < 0) | (!missing(managers_engaged) & managers_engaged < 1 & id20 != 1 & s2r1q1_employee_total >= 5)))

* Condition 2: Low count (<=1) if Total employees is >= 20 for specific ownership/legal types (Govt, Foreign, Partnership, Public Ltd, Private Ltd, Other Ltd, Coop, Other - excluding Sole Prop and Partnership for this check)
gl lowCountManagers ($isAnySector & (inlist(id17,1,3) | inrange(id20,3,11)) & !missing(managers_engaged) & managers_engaged <= 1 & s2r1q1_employee_total >=20)

* Combine conditions
gl invalidManagers ($invalidBasicManagers | $lowCountManagers)

replace section = "Section 02" if $invalidManagers
replace error_flag = 1 if $invalidManagers
replace errorCheck = cond($invalidBasicManagers, "Invalid Paid Managers (Missing, <0, or <1 for Non-Sole Prop)", "Low Paid Managers for Org Type") if $invalidManagers
replace errorMessage = cond($invalidBasicManagers, ///
    cond(missing(managers_engaged) & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0, "S2Q1.1.2 Error: Number of Paid Managers  is missing, but Total Employees > 0.", ///
        cond(managers_engaged < 0, "S2Q1.1.2 Error: Number of Paid Managers cannot be negative. Current number of Paid Managers = " + string(managers_engaged), ///
        "S2Q1.1.2 Error: Number of Paid Managers must be at least 1 if Total Employees >= 5 and Legal Org is not Sole Proprietor (Legal Org = " + id20_new + "). Current number of Paid Managers = " + string(managers_engaged))), ///
    "S2Q1.1.2 Warning: number of Paid Managers = " + string(managers_engaged) + " seems low (<=1 for employee_total >=20) for Ownership Type = " + id17_new + " / Legal Org = " + id20_new + ". Please verify and make correction.") if $invalidManagers

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section02_managers.dta", replace

*************************
* Check 5: Other Employees (Combined Missing/Invalid + Org Type Checks)
*************************
*Sec 2, Other Employees validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

decode id17, gen(id17_new)
decode id20, gen(id20_new)

* Condition 1: Missing when Total Employees > 0, or less than 0 (Basic check)
gl invalidBasicOtherEmployees ($isAnySector & ((!missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0 & missing(other_employees_engaged)) | (!missing(other_employees_engaged) & other_employees_engaged < 0)))

* Condition 2: Low count (<=2) if s2r1q1_employee_total >=20 for specific ownership/legal types (Govt, Foreign, Partnership, Public Ltd, Private Ltd, Other Ltd, Coop, Other)
gl lowCountOtherEmployees ($isAnySector & (inlist(id17,1,3) | inrange(id20,2,11)) & !missing(other_employees_engaged) & other_employees_engaged <= 2 & other_employees_engaged > 0 & s2r1q1_employee_total>= 20)

* Combine conditions
gl invalidOtherEmployees ($invalidBasicOtherEmployees | $lowCountOtherEmployees)

replace section = "Section 02" if $invalidOtherEmployees
replace error_flag = 1 if $invalidOtherEmployees
replace errorCheck = cond($invalidBasicOtherEmployees, "Invalid Other Employees (Missing or <0)", "Low Other Employees for Org Type") if $invalidOtherEmployees
replace errorMessage = cond($invalidBasicOtherEmployees, ///
    cond(missing(other_employees_engaged) & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0, "S2Q1.1.3 Error: Other Employees count is missing, but Total Employees > 0.", ///
    "S2Q1.1.3 Error: Other Employees count cannot be negative. Current value = " + string(other_employees_engaged)), ///
    "S2Q1.1.3 Warning: Other Employees count = " + string(other_employees_engaged) + " seems low (<=2 if employee_total>=20) for Ownership Type = " + id17_new + " and Legal Org = " + id20_new + ". Please verify.") if $invalidOtherEmployees

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_other_employees.dta", replace

*************************************
* UNPAID WORKERS CHECKS
*************************************

*************************
* Check 6: Total Unpaid Workers (Combined Missing/Invalid)
*************************
*Sec 2, Total Unpaid Workers validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

decode id17, gen(id17_new)
decode id20, gen(id20_new)

* Condition 1: Missing or less than 0 (Basic check)
gl invalidUnpaidWorkers ($isAnySector & (missing(s2r1q1_unpaid_workers_total) | (!missing(s2r1q1_unpaid_workers_total) & s2r1q1_unpaid_workers_total < 0)))

replace section = "Section 02" if $invalidUnpaidWorkers
replace error_flag = 1 if $invalidUnpaidWorkers
replace errorCheck = "Invalid Unpaid Workers (Missing or <0)" if $invalidUnpaidWorkers
replace errorMessage = cond(missing(s2r1q1_unpaid_workers_total), "S2Q1.2 Error: Total Unpaid Workers count is missing. This value is required.", ///
    "S2Q1.2 Error: Total number of Unpaid Workers cannot be negative. Current Total Unpaid Workers = " + string(s2r1q1_unpaid_workers_total)) if $invalidUnpaidWorkers

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_unpaid_workers.dta", replace

*************************************
* NATIONAL SERVICE PERSONS CHECKS
*************************************

*************************
* Check 7: National Service Persons (Combined Missing/Invalid + Org Type Checks)
*************************
*Sec 2, National Service Persons validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

decode id17, gen(id17_new)
decode id20, gen(id20_new)

* Condition 1: Missing or less than 0 (Basic check)
gl invalidBasicNationalService ($isAnySector & (missing(s2r1q1_national_service_total) | (!missing(s2r1q1_national_service_total) & s2r1q1_national_service_total < 0)))

* Condition 2: Low count (<=5) if s2r1q1_persons_engaged_total>=50 for specific ownership/legal types (Govt, Foreign, Partnership, Public Ltd, Private Ltd, Other Ltd, Coop, Other)
gl lowCountNationalService ($isAnySector & (inlist(id17,1,3) | inrange(id20,2,11)) & !missing(s2r1q1_national_service_total) & s2r1q1_national_service_total <= 5 & s2r1q1_national_service_total > 0 & s2r1q1_persons_engaged_total>=20)

* Combine conditions
gl invalidNationalService ($invalidBasicNationalService | $lowCountNationalService)

replace section = "Section 02" if $invalidNationalService
replace error_flag = 1 if $invalidNationalService
replace errorCheck = cond($invalidBasicNationalService, "Invalid National Service (Missing or <0)", "Low National Service for Org Type") if $invalidNationalService
replace errorMessage = cond($invalidBasicNationalService, ///
    cond(missing(s2r1q1_national_service_total), "S2Q1.3 Error: National Service Persons engaged is missing. This value is required.", ///
    "S2Q1.3 Error: National Service Persons engaged cannot be negative. Current National Service Persons engaged = " + string(s2r1q1_national_service_total)), ///
    "S2Q1.3 Warning: National Service Persons count = " + string(s2r1q1_national_service_total) + " seems low (<=5 if persons_engaged_total>=50) for Ownership Type = " + id17_new + " and Legal Org = " + id20_new + ". Please verify.") if $invalidNationalService

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_national_service.dta", replace 

*************************************
* PAYMENT CHECKS
*************************************

*************************
* Check 8: Total Payment (Wages & Salaries) (Combined Missing/Invalid)
*************************
*Sec 2, Total Payment validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

decode id20, gen(id20_new)

* Condition: Missing when Total Employees > 0, OR less than 1 when Total Employees > 0
gl invalidTotalPayment ($isAnySector & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0 & (missing(s2q36f) | (!missing(s2q36f) & s2q36f < 1)))

replace section = "Section 02" if $invalidTotalPayment
replace error_flag = 1 if $invalidTotalPayment
replace errorCheck = "Invalid Total Payment (Wages)" if $invalidTotalPayment
replace errorMessage = cond(missing(s2q36f), ///
    "S2Q2 Error: Total Wages and Salaries (s2q36f) is missing, but Total Employees = " + string(s2r1q1_employee_total) + ". Payment is expected.", ///
    "S2Q2 Error: Total Wages and Salaries (s2q36f) = " + string(s2q36f) + " is less than 1, but Total Employees = " + string(s2r1q1_employee_total) + ". Payment is expected to be positive.") if $invalidTotalPayment

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_total_payment.dta", replace

*************************
* Check 9: Operatives Payments (s2q34mi)
*************************
*Sec 2, Operatives Payments validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Condition: Missing when Operatives count > 0, or less than 0
gl invalidOperativesPayment ($isAnySector & ((!missing(operatives_engaged) & operatives_engaged > 0 & missing(s2q34mi)) | (!missing(s2q34mi) & s2q34mi < 0)))

replace section = "Section 02" if $invalidOperativesPayment
replace error_flag = 1 if $invalidOperativesPayment
replace errorCheck = "Invalid Operatives Payment (Missing or <0)" if $invalidOperativesPayment
replace errorMessage = cond(missing(s2q34mi) & !missing(operatives_engaged) & operatives_engaged > 0, ///
  "S2Q2.1 Error: Payment for Operatives is missing, but Operatives count = " + string(operatives_engaged) + ". Please verify if applicable.", ///
  "S2Q2.1 Error: Payment for Operatives cannot be negative. Current Operatives Payment = " + string(s2q34mi)) if $invalidOperativesPayment

//save the dataset
keep if error_flag == 1
if _N > 0 {
    insobs 1
    replace error_flag = . in L
    save "$error_report\Section2_operatives_payment.dta", replace
}

*************************
* Check 10: Paid Managers Payments (s2q35mi)
*************************
*Sec 2, Paid Managers Payments validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Condition: Missing when Managers count > 0, or less than 0
gl invalidManagersPayment ($isAnySector & ((!missing(managers_engaged) & managers_engaged > 0 & missing(s2q35mi)) | (!missing(s2q35mi) & s2q35mi < 0)))

replace section = "Section 02" if $invalidManagersPayment
replace error_flag = 1 if $invalidManagersPayment
replace errorCheck = "Invalid Paid Managers Payment (Missing or <0)" if $invalidManagersPayment
replace errorMessage = cond(missing(s2q35mi) & !missing(managers_engaged) & managers_engaged > 0, ///
  "S2Q2.2 Error: Payment for Paid Managers is missing, but Managers count = " + string(managers_engaged) + ". Please verify if applicable.", ///
  "S2Q2.2 Error: Payment for Paid Managers cannot be negative. Current Paid_managers Payment = " + string(s2q35mi)) if $invalidManagersPayment

//save the dataset
keep if error_flag == 1
if _N > 0 {
    insobs 1
    replace error_flag = . in L
    save "$error_report\Section2_managers_payment.dta", replace
}


*************************
* Check 11: Social Security (Combined Missing/Invalid + State Owned Check)
*************************
*Sec 2, Social Security validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

decode id17, gen(id17_new)

* Condition 1: Missing when Total Employees > 0, or less than 0
gl invalidBasicSocSec ($isAnySector & ((!missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0 & missing(s2q37)) | (!missing(s2q37) & s2q37 < 0)))

* Condition 2: State-owned enterprise (id17=1) reports zero or very low (<=0) SSNIT payment
gl stateOwned_nonSocSec ($isAnySector & id17 == 1 & !missing(s2q37) & s2q37 <= 0)

* Combine conditions
gl invalidSocialSecurity ($invalidBasicSocSec | $stateOwned_nonSocSec)

replace section = "Section 02" if $invalidSocialSecurity
replace error_flag = 1 if $invalidSocialSecurity
replace errorCheck = cond($invalidBasicSocSec, "Invalid Social Security (Missing or <0)", "Low/No Social Security for State-Owned") if $invalidSocialSecurity
replace errorMessage = cond($invalidBasicSocSec, ///
    cond(missing(s2q37) & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0, "S2Q3.1 Error: Social Security (SSNIT Tier 1) payment is missing, but Total Employees = " + string(s2r1q1_employee_total) + ". Payment is expected.", ///
    "S2Q3.1 Error: Social Security (SSNIT Tier 1) payment cannot be negative. Current value = " + string(s2q37)), ///
    "S2Q3.1 Warning: State-Owned enterprise (Ownership Type = " + id17_new + ") reports low/zero Social Security (SSNIT Tier 1) payment = " + string(s2q37) + ". Payment is compulsory. Please verify.") if $invalidSocialSecurity

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag // Original code kept error_flag, removing for consistency
save "$error_report\Section02_social_security.dta", replace

*************************
* Check 12: Health Insurance (Combined Missing/Invalid)
*************************
*Sec 2, Health Insurance validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Condition: Missing when Total Employees > 0, or less than 0
gl invalidHealthInsurance ($isAnySector & ((!missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0 & missing(s2q38)) | (!missing(s2q38) & s2q38 < 0)))

replace section = "Section 02" if $invalidHealthInsurance
replace error_flag = 1 if $invalidHealthInsurance
replace errorCheck = "Invalid Health Insurance (Missing or <0)" if $invalidHealthInsurance
replace errorMessage = cond(missing(s2q38) & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0, ///
  "S2Q3.2 Error: Health Insurance payment is missing, but Total Employees = " + string(s2r1q1_employee_total) + ". Please verify if applicable.", ///
  "S2Q3.2 Error: Health Insurance payment cannot be negative. Current Health Insurance payment = " + string(s2q38)) if $invalidHealthInsurance

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_health_insurance.dta", replace

*************************
* Check 13: Private Pension (Combined Missing/Invalid)
*************************
*Sec 2, Private Pension validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Condition: Missing when Total Employees > 0, or less than 0
gl invalidPrivatePension ($isAnySector & ((!missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0 & missing(s2q39)) | (!missing(s2q39) & s2q39 < 0)))

replace section = "Section 02" if $invalidPrivatePension
replace error_flag = 1 if $invalidPrivatePension
replace errorCheck = "Invalid Private Pension (Missing or <0)" if $invalidPrivatePension
replace errorMessage = cond(missing(s2q39) & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0, ///
  "S2Q3.3 Error: Private Pension (Tier 3) payment is missing, but Total Employees = " + string(s2r1q1_employee_total) + ". Please verify if applicable.", ///
  "S2Q3.3 Error: Private Pension (Tier 3) payment cannot be negative. Current Private Pension (Tier 3) payment = " + string(s2q39)) if $invalidPrivatePension

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_private_pension.dta", replace

*************************
* Check 14: Workmen's Compensation (Combined Missing/Invalid)
*************************
*Sec 2, Workmen's Compensation validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Condition: Missing when Total Employees > 0, or less than 0
gl invalidWorkmensComp ($isAnySector & ((!missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0 & missing(s2q40)) | (!missing(s2q40) & s2q40 < 0)))

replace section = "Section 02" if $invalidWorkmensComp
replace error_flag = 1 if $invalidWorkmensComp
replace errorCheck = "Invalid Workmen's Comp (Missing or <0)" if $invalidWorkmensComp
replace errorMessage = cond(missing(s2q40) & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0, ///
  "S2Q3.4 Error: Workmen's Compensation payment is missing, but Total Employees = " + string(s2r1q1_employee_total) + ". Please verify if applicable.", ///
  "S2Q3.4 Error: Workmen's Compensation payment cannot be negative. Current Workmen's Compensation  = " + string(s2q40)) if $invalidWorkmensComp

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_workmens_comp.dta", replace

*************************
* Check 15: Transportation Allowance (Combined Missing/Invalid)
*************************
*Sec 2, Transportation Allowance validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Condition: Missing when Total Employees > 0, or less than 0
gl invalidTransportation ($isAnySector & ((!missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0 & missing(s2q41)) | (!missing(s2q41) & s2q41 < 0)))

replace section = "Section 02" if $invalidTransportation
replace error_flag = 1 if $invalidTransportation
replace errorCheck = "Invalid Transport Allowance (Missing or <0)" if $invalidTransportation
replace errorMessage = cond(missing(s2q41) & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0, ///
  "S2Q3.5 Error: Transportation Allowance payment is missing, but Total Employees = " + string(s2r1q1_employee_total) + ". Please verify if applicable.", ///
  "S2Q3.5 Error: Transportation Allowance payment cannot be negative. Current Transportation Allowance = " + string(s2q41)) if $invalidTransportation

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_transportation.dta", replace

*************************
* Check 16: Risk Allowance (Combined Missing/Invalid)
*************************
*Sec 2, Risk Allowance validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Condition: Missing when Total Employees > 0, or less than 0
gl invalidRiskAllowance ($isAnySector & ((!missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0 & missing(s2q42)) | (!missing(s2q42) & s2q42 < 0)))

replace section = "Section 02" if $invalidRiskAllowance
replace error_flag = 1 if $invalidRiskAllowance
replace errorCheck = "Invalid Risk Allowance (Missing or <0)" if $invalidRiskAllowance
replace errorMessage = cond(missing(s2q42) & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0, ///
  "S2Q3.6 Error: Risk Allowance payment is missing, but Total Employees = " + string(s2r1q1_employee_total) + ". Please verify if applicable.", ///
  "S2Q3.6 Error: Risk Allowance payment cannot be negative. Current Risk Allowance = " + string(s2q42)) if $invalidRiskAllowance

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_risk_allowance.dta", replace

*************************
* Check 17: Other Payments (Combined Missing/Invalid)
*************************
*Sec 2, Other Payments validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Condition: Missing when Total Employees > 0, or less than 0
gl invalidOtherPayments ($isAnySector & ((!missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0 & missing(s2q43)) | (!missing(s2q43) & s2q43 < 0)))

replace section = "Section 02" if $invalidOtherPayments
replace error_flag = 1 if $invalidOtherPayments
replace errorCheck = "Invalid Other Payments (Missing or <0)" if $invalidOtherPayments
replace errorMessage = cond(missing(s2q43) & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0, ///
  "S2Q3.7 Error: Other Payments value is missing, but Total Employees = " + string(s2r1q1_employee_total) + ". Please verify if applicable.", ///
  "S2Q3.7 Error: Other Payments value cannot be negative. Current Other Payments = " + string(s2q43)) if $invalidOtherPayments

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_other_payments.dta", replace

*************************
* Check 18: Total Supplements (Combined Missing/Invalid)
*************************
*Sec 2, Total Supplements validation
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Condition: Missing when Total Employees > 0, or less than 0
gl invalidTotalSupplements ($isAnySector & ((!missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0 & missing(s2q44f)) | (!missing(s2q44f) & s2q44f < 0)))

replace section = "Section 02" if $invalidTotalSupplements
replace error_flag = 1 if $invalidTotalSupplements
replace errorCheck = "Invalid Total Supplements (Missing or <0)" if $invalidTotalSupplements
replace errorMessage = cond(missing(s2q44f) & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0, ///
  "S2Q3.8 Error: Total Supplements value is missing, but Total Employees = " + string(s2r1q1_employee_total) + ". Please verify if applicable.", ///
  "S2Q3.8 Error: Total Supplements value cannot be negative. Current Total Supplements = " + string(s2q44f)) if $invalidTotalSupplements

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_total_supplements.dta", replace

*************************************
* PART 2: SUM & CONSISTENCY CHECKS
*************************************

*************************
* Check 19: Persons Engaged Sum Check
*************************
*Sec 2, Total Persons Engaged should equal sum of Employees, Unpaid Workers, and National Service Persons
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Set tolerance for acceptable difference
local tolerance 1

* Calculate expected total persons engaged
gen expected_persons_total = s2r1q1_employee_total + s2r1q1_unpaid_workers_total + s2r1q1_national_service_total if ///
    !missing(s2r1q1_employee_total) & !missing(s2r1q1_unpaid_workers_total) & !missing(s2r1q1_national_service_total)

* Define condition for inconsistency (allow small tolerance)
local inconsistentCond !missing(s2r1q1_persons_engaged_total) & ///
                      !missing(expected_persons_total) & ///
                      abs(s2r1q1_persons_engaged_total - expected_persons_total) > `tolerance'

* Apply checks
replace section = "Section 02" if `inconsistentCond'
replace error_flag = 1 if `inconsistentCond'
replace errorCheck = "Sum Check (Persons Engaged)" if `inconsistentCond'
replace errorMessage = "S2Q1.4 Sum Error: Total Persons Engaged = " + string(s2r1q1_persons_engaged_total) + " does not match the sum of its components (Employees = " + string(s2r1q1_employee_total) + ", Unpaid Workers = " + string(s2r1q1_unpaid_workers_total) + ", National Service = " + string(s2r1q1_national_service_total) + "). Expected sum = " + string(expected_persons_total) + ". Please verify counts." if `inconsistentCond'

* Save errors
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_sum_persons.dta", replace

*************************
* Check 20: Employees Sum Check
*************************
*Sec 2, Total Employees should equal sum of Operatives, Paid Managers, and Other Employees
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Set tolerance for acceptable difference
local tolerance 1

* Calculate expected total employees
gen expected_employees = operatives_engaged + managers_engaged + other_employees_engaged if ///
    !missing(operatives_engaged) & !missing(managers_engaged) & !missing(other_employees_engaged)

* Define condition for inconsistency
local inconsistentEmployeesCond !missing(s2r1q1_employee_total) & ///
                              !missing(expected_employees) & ///
                              abs(s2r1q1_employee_total - expected_employees) > `tolerance'

* Apply checks
replace section = "Section 02" if `inconsistentEmployeesCond'
replace error_flag = 1 if `inconsistentEmployeesCond'
replace errorCheck = "Sum Check (Employees)" if `inconsistentEmployeesCond'
replace errorMessage = "S2Q1.1 Sum Error: Total Employees = " + string(s2r1q1_employee_total) + " does not match the sum of its components (Operatives = " + string(operatives_engaged) + ", Managers = " + string(managers_engaged) + ", Other = " + string(other_employees_engaged) + "). Expected sum = " + string(expected_employees) + ". Please verify counts." if `inconsistentEmployeesCond'

* Save errors
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_sum_employees.dta", replace


*************************
* Check 21: Supplements Sum Check
*************************
*Sec 2, Total Supplements (s2q44f) should equal sum of components (s2q37-s2q43)
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Set tolerance for acceptable difference
local tolerance 1

* Calculate expected total supplements
gen expected_supplements = s2q37 + s2q38 + s2q39 + s2q40 + s2q41 + s2q42 + s2q43 if ///
    !missing(s2q37) & !missing(s2q38) & !missing(s2q39) & !missing(s2q40) & ///
    !missing(s2q41) & !missing(s2q42) & !missing(s2q43)

* Define condition for inconsistency (allow relative tolerance for large values)
local inconsistentSupplementsCond !missing(s2q44f) & ///
                            !missing(expected_supplements) & ///
                            abs(s2q44f - expected_supplements) > `tolerance' * max(abs(s2q44f), 1)

* Apply checks
replace section = "Section 02" if `inconsistentSupplementsCond'
replace error_flag = 1 if `inconsistentSupplementsCond'
replace errorCheck = "Sum Check (Supplements)" if `inconsistentSupplementsCond'
replace errorMessage = "S2Q3.8 Sum Error: Total Supplements = " + string(s2q44f) + " does not match the sum of its components (Social Security, Health Ins, Pension, etc.). Expected sum = " + string(expected_supplements) + ". Difference = " + string(s2q44f - expected_supplements) + ". Please verify payments." if `inconsistentSupplementsCond'

* Save errors
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_sum_supplements.dta", replace


*************************************
* LOGICAL CONSISTENCY CHECKS
*************************************

*************************
* Check 22: Employees vs Payment Consistency
*************************
*Sec 2, If Total Employees > 0, Total Payment (Wages) should be > 0
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl inconsistentEmployeesPayment ($isAnySector & !missing(s2r1q1_employee_total) & !missing(s2q36f) & s2r1q1_employee_total > 0 & s2q36f == 0)

replace section = "Section 02" if $inconsistentEmployeesPayment
replace error_flag = 1 if $inconsistentEmployeesPayment
replace errorCheck = "Logical Consistency (Emp > 0, Pay = 0)" if $inconsistentEmployeesPayment
replace errorMessage = "S2Q1.1/S2Q2 Logic Error: Total Employees = " + string(s2r1q1_employee_total) + " (positive), but Total Wages and Salaries = 0. Payment made to employee is expected. Please verify." if $inconsistentEmployeesPayment

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_consistency_emp_pay.dta", replace

*************************
* Check 23: Payment vs Employees Consistency
*************************
*Sec 2, If Total Payment (Wages) > 0, Total Employees should be > 0
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl inconsistentPaymentEmployees ($isAnySector & !missing(s2r1q1_employee_total) & !missing(s2q36f) & s2r1q1_employee_total == 0 & s2q36f > 0)

replace section = "Section 02" if $inconsistentPaymentEmployees
replace error_flag = 1 if $inconsistentPaymentEmployees
replace errorCheck = "Logical Consistency (Pay > 0, Emp = 0)" if $inconsistentPaymentEmployees
replace errorMessage = "S2Q2/S2Q1.1 Logic Error: Total Wages and Salaries = " + string(s2q36f) + " (positive), but Total Employees = 0. Employees are expected if payment is made. Please verify." if $inconsistentPaymentEmployees

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_consistency_pay_emp.dta", replace

*************************
* Check 24: Managers vs Employees Ratio
*************************
*Sec 2, Paid Managers should not exceed 50% of Total Employees for businesses with > 5 employees
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl inconsistentManagersRatio ($isAnySector & !missing(s2r1q1_employee_total) & !missing(managers_engaged) & s2r1q1_employee_total > 5 & managers_engaged > 0.5 * s2r1q1_employee_total)

replace section = "Section 02" if $inconsistentManagersRatio
replace error_flag = 1 if $inconsistentManagersRatio
replace errorCheck = "Logical Consistency (Manager Ratio)" if $inconsistentManagersRatio
replace errorMessage = "S2Q1.1.2/S2Q1.1 Logic Warning: Paid Managers = " + string(managers_engaged) + " exceeds 50% of Total Employees = " + string(s2r1q1_employee_total) + ". This manager ratio seems high. Please verify." if $inconsistentManagersRatio

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_consistency_manager_ratio.dta", replace

*************************
// * Check 25: Payment per Employee Consistency
// *************************
// *Sec 2, Payment per employee (based on Total Wages) should be within reasonable range
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
// * Calculate payment per employee
// gen payment_per_employee = s2q36f / s2r1q1_employee_total if !missing(s2q36f) & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0
//
// * Defining minimum and maximum reasonable payment per employee (thresholds to be adjusted as needed)
// local min_payment_per_employee = 1000  // Example: 1,000 GHC per year
// local max_payment_per_employee = 500000 // Example: 500,000 GHC per year
//
// gl inconsistentPaymentPerEmployee ($isAnySector & !missing(payment_per_employee) & (payment_per_employee < `min_payment_per_employee' | payment_per_employee > `max_payment_per_employee'))
//
// replace section = "Section 02" if $inconsistentPaymentPerEmployee
// replace error_flag = 1 if $inconsistentPaymentPerEmployee
// replace errorCheck = "Logical Consistency (Payment/Employee Range)" if $inconsistentPaymentPerEmployee
// replace errorMessage = "S2Q4/S2Q1.1 Logic Warning: Average payment per employee (Total Wages / Total Employees) = " + string(payment_per_employee) + " is outside the expected range (" + string(`min_payment_per_employee') + " to " + string(`max_payment_per_employee') + "). Please verify Total Wages and Total Employees." if $inconsistentPaymentPerEmployee
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section2_consistency_pay_per_emp.dta", replace

*************************
* Check 26: Zero Payment with Positive Components
*************************
*Sec 2, Total Payment (s2q36f) is zero, but some supplements (s2q37-s2q43) are positive
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Calculate sum of positive supplements
gen positive_supplements_sum = 0
foreach var of varlist s2q37 s2q38 s2q39 s2q40 s2q41 s2q42 s2q43 {
    replace positive_supplements_sum = positive_supplements_sum + `var' if !missing(`var') & `var' > 0
}

gl zeroPayPositiveComponents ($isAnySector & !missing(s2q36f) & s2q36f == 0 & positive_supplements_sum > 0)

replace section = "Section 02" if $zeroPayPositiveComponents
replace error_flag = 1 if $zeroPayPositiveComponents
replace errorCheck = "Logical Consistency (Zero Pay, Pos Supplements)" if $zeroPayPositiveComponents
replace errorMessage = "S2Q2.5/S2Q3.1-7 Logic Error: Total Wages and Salaries = 0, but the sum of positive supplement components (Social Security, Health Ins, etc.) = " + string(positive_supplements_sum) + ". If supplements were paid, Total Wages should likely be positive. Please verify." if $zeroPayPositiveComponents

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_consistency_zero_pay_pos_comp.dta", replace

*************************
* Check 27: High Ratio of Other Employees
*************************
*Sec 2, 'Other Employees' (other_employees_engaged) constitute a very high proportion of total employees
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Calculate proportion of 'Other Employees'
gen other_employee_prop = other_employees_engaged / s2r1q1_employee_total if !missing(other_employees_engaged) & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > 0

* Flag if 'Other Employees' are more than 75% of total employees ( threshold can be adjusted as needed) //show the id20 and id17 for more clarity
gl highOtherEmployeeProp ($isAnySector & !missing(other_employee_prop) & other_employee_prop > 0.75 & s2r1q1_employee_total >= 5)

replace section = "Section 02" if $highOtherEmployeeProp
replace error_flag = 1 if $highOtherEmployeeProp
replace errorCheck = "Logical Consistency (High Other Emp Ratio)" if $highOtherEmployeeProp
replace errorMessage = "S2Q1.3/S2Q1.1.3 Logic Warning: 'Other Employees' = " + string(other_employees_engaged) + " make up more than 75% of Total Employees = " + string(s2r1q1_employee_total) + ". Ratio = " + string(other_employee_prop, "%9.2f") + ". Please verify classification of employees." if $highOtherEmployeeProp

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_consistency_high_other_emp.dta", replace


*************************
* Check 28: Zero Employees but Positive Persons Engaged 
*************************
*Sec 2, Total Persons Engaged > 0 but Total Employees = 0 verifying if indeed all persons engaged are upaid/NSP
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl zeroEmpPosEngaged ($isAnySector & !missing(s2r1q1_persons_engaged_total) & s2r1q1_persons_engaged_total > 0 & !missing(s2r1q1_employee_total) & s2r1q1_employee_total == 0 & inlist(id20!=1,2))

replace section = "Section 02" if $zeroEmpPosEngaged
replace error_flag = 1 if $zeroEmpPosEngaged
replace errorCheck = "Logical Consistency (Zero Emp, Pos Engaged)" if $zeroEmpPosEngaged
replace errorMessage = "S2Q1/S2Q1.1 Logic Error: Total Persons Engaged = " + string(s2r1q1_persons_engaged_total) + " (positive), but Total Employees = 0. This implies all persons engaged are Unpaid Workers or National Service. Please verify persons engage categories." if $zeroEmpPosEngaged

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_consistency_zero_emp_pos_engaged.dta", replace

*************************************
* PART 3: OUTLIER CHECKS
*************************************

*************************
// * Check 29: Employee Count Outlier
// *************************
// *Sec 2, Flag unusually high employee counts
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
// * Defining threshold for outlier detection (adjust based on data distribution)
// local employee_threshold = 1000  // Example: Flag if > 1000 employees
//
// gl outlierEmployeeCount ($isAnySector & !missing(s2r1q1_employee_total) & s2r1q1_employee_total > `employee_threshold')
//
// replace section = "Section 02" if $outlierEmployeeCount
// replace error_flag = 1 if $outlierEmployeeCount
// replace errorCheck = "Outlier Check (Employee Count)" if $outlierEmployeeCount
// replace errorMessage = "S2Q1.1 Outlier Warning: Total Employee count = " + string(s2r1q1_employee_total) + " exceeds the verification threshold of " + string(`employee_threshold') + ". Please confirm this large value is correct." if $outlierEmployeeCount
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section2_outlier_emp_count.dta", replace

*************************
// * Check 30: Payment Outlier (Total Wages)
// *************************
// *Sec 2, Flagging unusually high total wages and salaries
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
// * Defining threshold for outlier detection (adjust based on data distribution)
// local payment_threshold = 10000000  // Example: 10 million GHC
//
// gl outlierPayment ($isAnySector & !missing(s2q36f) & s2q36f > `payment_threshold')
//
// replace section = "Section 02" if $outlierPayment
// replace error_flag = 1 if $outlierPayment
// replace errorCheck = "Outlier Check (Total Wages)" if $outlierPayment
// replace errorMessage = "S2Q4 Outlier Warning: Total Wages and Salaries = " + string(s2q36f) + " exceeds the verification threshold of " + string(`payment_threshold') + ". Please confirm this large value is correct." if $outlierPayment
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section2_outlier_payment.dta", replace

*************************
// * Check 31: Suspicious Payment Values (e.g., ending in .99)
// *************************
// *Sec 2, Check for payment values that might indicate estimations or placeholders
// use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear
//
// * Check if Total Wages ends in .99
// gl suspiciousPaymentEnding ($isAnySector & !missing(s2q36f) & s2q36f > 0 & abs(s2q36f - round(s2q36f)) > 0.001 & abs(round(s2q36f, 0.01) - s2q36f) < 0.001 & mod(round(s2q36f * 100), 100) == 99)
//
// replace section = "Section 02" if $suspiciousPaymentEnding
// replace error_flag = 1 if $suspiciousPaymentEnding
// replace errorCheck = "Pattern Detection (Payment Ending .99)" if $suspiciousPaymentEnding
// replace errorMessage = "S2Q4 Pattern Warning: Total Wages and Salaries = " + string(s2q36f) + " ends in .99. This might indicate an estimate or placeholder value. Please verify." if $suspiciousPaymentEnding
//
// //save the dataset
// keep if error_flag == 1
// insobs 1
// drop error_flag
// save "$error_report\Section2_pattern_payment_ending.dta", replace

*******************************************************
* PART 4: NEW SUPPLEMENT OUTLIER CHECKS FROM COORDINATOR
********************************************************
* Check 31: Average salary for Operatives > Managers
*Sec 2, Check if Average Salary for Operatives > Managers
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Generate average salaries only when both components are valid
gen avg_salary_operative = s2q34mi / operatives_engaged if !missing(s2q34mi, operatives_engaged) & operatives_engaged > 0
gen avg_salary_manager = s2q35mi / managers_engaged if !missing(s2q35mi, managers_engaged) & managers_engaged > 0

gl highOperativeSalary ($isAnySector & !missing(avg_salary_operative, avg_salary_manager) & avg_salary_operative > avg_salary_manager)

replace section = "Section 02" if $highOperativeSalary
replace error_flag = 1 if $highOperativeSalary
replace errorCheck = "Outlier Check (Operatives Salary > Managers Salary)" if $highOperativeSalary
replace errorMessage = "S2Q2.1/S2Q2.2 Outlier Warning: Average Salary for Operatives = " + string(avg_salary_operative, "%9.2f") + " exceeds that of Managers = " + string(avg_salary_manager, "%9.2f") + ". then prompt field officers to correct or confirm the salaries for the operatives or the managers" if $highOperativeSalary

* Save flagged cases
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_outlier_operative_gt_manager.dta", replace

* Check 32: Average salary for Other Employees > Managers
 *Sec 2, Check if Average Salary for Other Employees > Managers
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Generate average salaries only when components are valid
gen total_salary_other = s2q36mi + s2q37mi if !missing(s2q36mi, s2q37mi)
gen avg_salary_other = total_salary_other / other_employees_engaged if !missing(total_salary_other, other_employees_engaged) & other_employees_engaged > 0
gen avg_salary_manager = s2q35mi / managers_engaged if !missing(s2q35mi, managers_engaged) & managers_engaged > 0

gl highOtherSalary ($isAnySector & !missing(avg_salary_other, avg_salary_manager) & avg_salary_other > avg_salary_manager)

replace section = "Section 02" if $highOtherSalary
replace error_flag = 1 if $highOtherSalary
replace errorCheck = "Outlier Check (Other Employees Salary > Managers Salary)" if $highOtherSalary
replace errorMessage = "S2Q2.4/S2Q2.2 Outlier Warning: Average Salary for Other Employees = " + string(avg_salary_other, "%9.2f") + " exceeds that of Managers = " + string(avg_salary_manager, "%9.2f") + ". then prompt field officers to correct or confirm the salaries for the other employees or the managers" if $highOtherSalary

* Save flagged cases
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_outlier_other_gt_manager.dta", replace


*************************
* Check 33: High Social Security Percentage
*************************
*Sec 2, Check if Social Security (s2q37) is > 20% of Total Wages (s2q36f)
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Calculate percentage only if Total Wages > 0
gen soc_sec_pct = 100 * (s2q37 / s2q36f) if !missing(s2q37) & !missing(s2q36f) & s2q36f > 0

gl highSocSecPct ($isAnySector & !missing(soc_sec_pct) & soc_sec_pct > 20)

replace section = "Section 02" if $highSocSecPct
replace error_flag = 1 if $highSocSecPct
replace errorCheck = "Outlier Check (High SSNIT %)" if $highSocSecPct
replace errorMessage = "S2Q3.1/S2Q2.5 Outlier Warning: Social Security (SSNIT Tier 1) payment = " + string(s2q37) + " is more than 20% of Total Wages = " + string(s2q36f) + ". Percentage = " + string(soc_sec_pct, "%9.1f") + "%. then prompt field officer to correct or confirm the value for Compulsory National Social Security (Tier 1)." if $highSocSecPct

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_outlier_high_ssnit_pct.dta", replace

*************************
* Check 34: Private Pension Exceeds Total Wages
*************************
*Sec 2, Check if Private Pension (s2q39) > Total Wages (s2q36f)
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl pensionExceedsWages ($isAnySector & !missing(s2q39) & !missing(s2q36f) & s2q39 > s2q36f)

replace section = "Section 02" if $pensionExceedsWages
replace error_flag = 1 if $pensionExceedsWages
replace errorCheck = "Outlier Check (Pension > Wages)" if $pensionExceedsWages
replace errorMessage = "S2Q3.3/S2Q2.5 Outlier Error: Private Pension (Tier 3) payment = " + string(s2q39) + " is greater than Total Wages = " + string(s2q36f) + ". then prompt field officer to correct or confirm the values for Private Pension Scheme (Tier 3, provident fund, etc.)." if $pensionExceedsWages

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_outlier_pension_exceeds_wages.dta", replace

*************************
* Check 35: Workmen's Comp Exceeds Total Wages
*************************
*Sec 2, Check if Workmen's Compensation (s2q40) > Total Wages (s2q36f)
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl workmensCompExceedsWages ($isAnySector & !missing(s2q40) & !missing(s2q36f) & s2q40 > s2q36f)

replace section = "Section 02" if $workmensCompExceedsWages
replace error_flag = 1 if $workmensCompExceedsWages
replace errorCheck = "Outlier Check (Workmen's Comp > Wages)" if $workmensCompExceedsWages
replace errorMessage = "S2Q3.4/S2Q2.5 Outlier Error: Workmen's Compensation payment = " + string(s2q40) + " is greater than Total Wages = " + string(s2q36f) + ". then prompt field officer to correct or confirm the values for Workmen’s accident compensation" if $workmensCompExceedsWages

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_outlier_workmens_comp_exceeds_wages.dta", replace

*************************
* Check 36: Transport Allowance Exceeds Total Wages
*************************
*Sec 2, Check if Transportation Allowance (s2q41) > Total Wages (s2q36f)
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl transportExceedsWages ($isAnySector & !missing(s2q41) & !missing(s2q36f) & s2q41 > s2q36f)

replace section = "Section 02" if $transportExceedsWages
replace error_flag = 1 if $transportExceedsWages
replace errorCheck = "Outlier Check (Transport > Wages)" if $transportExceedsWages
replace errorMessage = "S2Q3.5/S2Q2.5 Outlier Error: Transportation Allowance = " + string(s2q41) + " is greater than Total Wages = " + string(s2q36f) + ". Tthen prompt field officer to correct or confirm the values for Transportation, accommodation, and clothing allowance" if $transportExceedsWages

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_outlier_transport_exceeds_wages.dta", replace

*************************
* Check 37: Risk Allowance Exceeds Total Wages
*************************
*Sec 2, Check if Risk Allowance (s2q42) > Total Wages (s2q36f)
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl riskExceedsWages ($isAnySector & !missing(s2q42) & !missing(s2q36f) & s2q42 > s2q36f)

replace section = "Section 02" if $riskExceedsWages
replace error_flag = 1 if $riskExceedsWages
replace errorCheck = "Outlier Check (Risk > Wages)" if $riskExceedsWages
replace errorMessage = "S2Q3.6/S2Q2.5 Outlier Error: Risk Allowance = " + string(s2q42) + " is greater than Total Wages = " + string(s2q36f) + ". then prompt field officer to correct or confirm the values for Risk allowance" if $riskExceedsWages

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_outlier_risk_exceeds_wages.dta", replace

*************************************
* PART 5: ADVANCED SECTOR-SPECIFIC CHECKS 
*************************************

*************************************
* AGRICULTURE SECTOR CHECKS
*************************************

*************************
* Check 38: Agriculture Sector Employee Composition Check
*************************
* Sec 2, Agriculture businesses typically have more operatives than managers
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl isAgricSec ($isAnySector & Sub_Sector == 1)

* Generate a flag for high manager-to-operative ratio
gen agriHighManagerFlag = 0
replace agriHighManagerFlag = 1 if $isAgricSec & !missing(operatives_engaged, managers_engaged) & operatives_engaged > 0 & managers_engaged > 0 & (managers_engaged / operatives_engaged) > 0.5

* Set error info
replace section = "Section 02" if agriHighManagerFlag
replace error_flag = 1 if agriHighManagerFlag
replace errorCheck = "Agriculture Sector Check (Manager Ratio)" if agriHighManagerFlag
replace errorMessage = "S2Q3.1/S2Q3.2 Sector Warning (Agriculture): Manager-to-operative ratio = " + string(managers_engaged / operatives_engaged, "%9.2f") + " seems high for agriculture. Operatives = " + string(operatives_engaged) + ", Managers = " + string(managers_engaged) + ". Please verify." if agriHighManagerFlag

* Save the errors
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_agri_manager_ratio.dta", replace

*************************
* Check 39: Agriculture Sector Unpaid Worker Check
*************************
*Sec 2, Agriculture businesses often have unpaid family workers, especially smaller/newer ones
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Flag if small/younger agri business reports zero unpaid workers
gl agriNoUnpaidWorkers ($isAgricSec & !missing(s2r1q1_unpaid_workers_total) & s2r1q1_unpaid_workers_total == 0 & !missing(s2r1q1_employee_total) & s2r1q1_employee_total < 10 & !missing(s1q2a) & s1q2a > 2) // s1q2a = years at location

replace section = "Section 02" if $agriNoUnpaidWorkers
replace error_flag = 1 if $agriNoUnpaidWorkers
replace errorCheck = "Agriculture Sector Check (No Unpaid)" if $agriNoUnpaidWorkers
replace errorMessage = "S2Q1.2 Sector Warning (Agriculture):  small agriculture business (Employees = " + string(s2r1q1_employee_total) + ", Years at Location = " + string(s1q2a) + ") reports no unpaid workers. Unpaid family worker is common in small agric businesses. Please verify." if $agriNoUnpaidWorkers

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_agri_no_unpaid.dta", replace

*************************************
* MANUFACTURING SECTOR CHECKS
*************************************

*************************
* Check 40: Manufacturing Sector Employee Composition Check
*************************
*Sec 2, Manufacturing businesses typically have a high proportion of operatives
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl isManufSec ($isAnySector & Sub_Sector == 3)

* Flag if operatives are less than 30% of total employees (for businesses with >= 5 employees)
gl manufLowOperatives ($isManufSec & !missing(s2r1q1_employee_total) & !missing(operatives_engaged) & s2r1q1_employee_total >= 5 & (operatives_engaged / s2r1q1_employee_total) < 0.3)

replace section = "Section 02" if $manufLowOperatives
replace error_flag = 1 if $manufLowOperatives
replace errorCheck = "Manufacturing Sector Check (Low Operatives)" if $manufLowOperatives
replace errorMessage = "S2Q1.1/S2Q1.1.1 Sector Warning (Manufacturing): Proportion of operatives = " + string(operatives_engaged / s2r1q1_employee_total, "%9.2f") + " (Operatives = " + string(operatives_engaged) + " / Total Employees = " + string(s2r1q1_employee_total) + ") seems low for manufacturing. Please verify." if $manufLowOperatives

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_manuf_low_operatives.dta", replace

*************************************
* CONSTRUCTION SECTOR CHECKS
*************************************

*************************
* Check 41: Construction Sector Risk Allowance Check
*************************
*Sec 2, Construction businesses often have risk allowances
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl isConstrucSec ($isAnySector & Sub_Sector == 5)

* Flag if construction business with >= 5 employees reports zero risk allowance
gl construcNoRiskAllowance ($isConstrucSec & !missing(s2r1q1_employee_total) & s2r1q1_employee_total >= 5 & !missing(s2q42) & s2q42 == 0)

replace section = "Section 02" if $construcNoRiskAllowance
replace error_flag = 1 if $construcNoRiskAllowance
replace errorCheck = "Construction Sector Check (No Risk Pay)" if $construcNoRiskAllowance
replace errorMessage = "S2Q3.6 Sector Warning (Construction): Construction business with Employees = " + string(s2r1q1_employee_total) + " reports no risk allowance (s2q42 = 0). Risk allowance is common in this sector. Please verify." if $construcNoRiskAllowance

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_construc_no_risk.dta", replace

*************************************
* WHOLESALE/RETAIL SECTOR CHECKS
*************************************

*************************
* Check 42: Wholesale/Retail Sector Transportation Allowance Check
*************************
*Sec 2, Wholesale/Retail businesses often have transportation allowances
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl isWholeRetailSec ($isAnySector & Sub_Sector == 8)

* Flag if wholesale/retail business with >= 5 employees reports zero transport allowance
gl retailNoTransportAllowance ($isWholeRetailSec & !missing(s2r1q1_employee_total) & s2r1q1_employee_total >= 5 & !missing(s2q41) & s2q41 == 0)

replace section = "Section 02" if $retailNoTransportAllowance
replace error_flag = 1 if $retailNoTransportAllowance
replace errorCheck = "Wholesale/Retail Sector Check (No Transport Pay)" if $retailNoTransportAllowance
replace errorMessage = "S2Q3.5 Sector Warning (Wholesale/Retail): Business with Employees = " + string(s2r1q1_employee_total) + " reports no transportation allowance (s2q41 = 0). Transport allowance is common in this sector. Please verify." if $retailNoTransportAllowance

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_retail_no_transport.dta", replace

*************************
* Check 43: Wholesale/Retail Sector Employee Composition Check
*************************
*Sec 2, Wholesale/Retail businesses typically have fewer operatives compared to manufacturing
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

* Flag if operatives are more than 60% of total employees (for businesses with >= 10 employees)
gl retailHighOperatives ($isWholeRetailSec & !missing(s2r1q1_employee_total) & !missing(operatives_engaged) & s2r1q1_employee_total >= 10 & (operatives_engaged / s2r1q1_employee_total) > 0.6)

replace section = "Section 02" if $retailHighOperatives
replace error_flag = 1 if $retailHighOperatives
replace errorCheck = "Wholesale/Retail Sector Check (High Operatives)" if $retailHighOperatives
replace errorMessage = "S2Q1.1.1/S2Q1.1 Sector Warning (Wholesale/Retail): Proportion of operatives = " + string(operatives_engaged / s2r1q1_employee_total, "%9.2f") + " (Operatives = " + string(operatives_engaged) + " / Total Employees = " + string(s2r1q1_employee_total) + ") seems high for wholesale/retail. Please verify classification." if $retailHighOperatives

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_retail_high_operatives.dta", replace

*************************************
* SERVICE SECTOR CHECKS
*************************************

*************************
* Check 44: Service Sector Employee Composition Check
*************************
*Sec 2, Service businesses typically have fewer operatives
use "$prepData\ibes_ii Estabs valid_dateCase_only.dta", clear

gl isServSec ($isAnySector & (Sub_Sector == 6 | Sub_Sector == 7))

* Flag if operatives are more than 50% of total employees (for businesses with >= 10 employees)
gl serviceHighOperatives ($isServSec & !missing(s2r1q1_employee_total) & !missing(operatives_engaged) & s2r1q1_employee_total >= 10 & (operatives_engaged / s2r1q1_employee_total) > 0.5)

replace section = "Section 02" if $serviceHighOperatives
replace error_flag = 1 if $serviceHighOperatives
replace errorCheck = "Service Sector Check (High Operatives)" if $serviceHighOperatives
replace errorMessage = "S2Q1.1.1/S2Q1.1 Sector Warning (Service): Proportion of operatives = " + string(operatives_engaged / s2r1q1_employee_total, "%9.2f") + " (Operatives = " + string(operatives_engaged) + " / Total Employees = " + string(s2r1q1_employee_total) + ") seems high for a service business. Please verify classification." if $serviceHighOperatives

//save the dataset
keep if error_flag == 1
insobs 1
drop error_flag
save "$error_report\Section2_service_high_operatives.dta", replace

