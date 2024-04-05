
/*
-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title/Purpose 	: This do.file was developed by the Evans School Policy Analysis & Research Group (EPAR) 
				  for the construction of a set of agricultural development indicators 
				  using the Malawi National Panel Survey (TNPS) LSMS-ISA Wave 4 (2014-15)
*Author(s)		: Anu Sidhu, C. Leigh Anderson, Travis Reynolds, Chae Won Lee, Haley Skinner, Claire Gracia

*Acknowledgments: We acknowledge the helpful contributions of members of the World Bank's LSMS-ISA team, the FAO's RuLIS team, IFPRI, IRRI, 
				  and the Bill & Melinda Gates Foundation Agricultural Development Data and Policy team in discussing indicator construction decisions. 
				  All coding errors remain ours alone.
*Date			: 21 January 2018

----------------------------------------------------------------------------------------------------------------------------------------------------*/

*Data source
*-----------
*The Malawi National Panel Survey was collected by the National Statistical Office in Zomba 
*and the World Bank's Living Standards Measurement Study - Integrated Surveys on Agriculture(LSMS - ISA)
*The data were collected over the period April 2019 - March 2020.
*All the raw data, questionnaires, and basic information documents are available for downloading free of charge at the following link
*https://microdata.worldbank.org/index.php/catalog/3818

*Throughout the do-file, we sometimes use the shorthand LSMS to refer to the Malawi National Panel Survey.

*Summary of Executing the Master do.file
*-----------
*This Master do.file constructs selected indicators using the Malawi LSMS data set.
*Using data files from within the "378 - LSMS Burkina Faso, Malawi, Uganda" folder within the "raw_data" folder, 
*the do.file first constructs common and intermediate variables, saving dta files when appropriate 
*in R:\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\code
*These variables are then brought together at the household, plot, or individual level, saving dta files at each level when available 
*at the file path R:\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\created_data

*The processed files include all households, individuals, and plots in the sample where possible.
*Toward the end of the do.file, a block of code estimates summary statistics (mean, standard error of the mean, minimum, first quartile, median, third quartile, maximum) 
*of final indicators, restricted to the rural households only, disaggregated by gender of head of household or plot manager.
*The results will be outputted in the excel file "MWI_IHS_IHPS_W4_summary_stats.xlsx" at the file path "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\created_data"
*It is possible to modify the condition  "if rural==1" in the portion of code following the heading "SUMMARY STATISTICS" to generate all summary statistics for a different sub_population.

 
/*
OUTLINE OF THE DO.FILE
Below are the list of the main files created by running this Master do.file

*INTERMEDIATE FILES					MAIN FILES CREATED
*-----------------------------------------
--------------------------------------------
*HOUSEHOLD IDS						MWI_IHS_IHPS_W4_hhids.dta
*WEIGHTS							MWI_IHS_IHPS_W4_weights.dta
*INDIVIDUAL IDS						MWI_IHS_IHPS_W4_person_ids.dta
*HOUSEHOLD SIZE						MWI_IHS_IHPS_W4_hhsize.dta
*GPS COORDINATES					MWI_IHS_IHPS_W4_hh_coords.dta
*PLOT AREAS							MWI_IHS_IHPS_W4_plot_areas.dta
*PLOT-CROP DECISION MAKERS			MWI_IHS_IHPS_W4_plot_decision_makers.dta
*CROP UNIT CONVERSION FACTORS		MWI_IHS_IHPS_W4_cf.dta
									MWI_IHS_IHPS_W4_caloric_conversionfactor_crop_codes.dta
*ALL PLOTS							MWI_IHS_IHPS_W4_all_plots.dta
*TLU (Tropical Livestock Units)		MWI_IHS_IHPS_W4_TLU_Coefficients.dta

*GROSS CROP REVENUE					MWI_IHS_IHPS_W4_tempcrop_harvest.dta
									MWI_IHS_IHPS_W4_tempcrop_sales.dta
									MWI_IHS_IHPS_W4_permcrop_harvest.dta
									MWI_IHS_IHPS_W4_permcrop_sales.dta
									MWI_IHS_IHPS_W4_hh_crop_production.dta
									MWI_IHS_IHPS_W4_plot_cropvalue.dta
									MWI_IHS_IHPS_W4_parcel_cropvalue.dta
									MWI_IHS_IHPS_W4_crop_residues.dta
									MWI_IHS_IHPS_W4_hh_crop_prices.dta
									MWI_IHS_IHPS_W4_crop_losses.dta

*CROP EXPENSES						MWI_IHS_IHPS_W4_fertilizer_costs.dta
									MWI_IHS_IHPS_W4_seed_costs.dta
									MWI_IHS_IHPS_W4_land_rental_costs.dta
									MWI_IHS_IHPS_W4_asset_rental_costs.dta
									MWI_IHS_IHPS_W4_transportation_cropsales.dta
									
*MONOCROPPED PLOTS					MWI_IHS_IHPS_W4_monocrop_plots.dta
									Malawi_IHS_W4_`cn'_monocrop_hh_area.dta
									Malawi_IHS_W4_`cn'_monocrop.dta
									Malawi_IHS_W4_inputs_`cn'.dta

*LIVESTOCK INCOME					MWI_IHS_IHPS_W4_livestock_products.dta
									MWI_IHS_IHPS_W4_livestock_expenses.dta
									MWI_IHS_IHPS_W4_hh_livestock_products.dta
									MWI_IHS_IHPS_W4_livestock_sales.dta
									MWI_IHS_IHPS_W4_TLU.dta
									MWI_IHS_IHPS_W4_livestock_income.dta						

*FISH INCOME						MWI_IHS_IHPS_W4_fishing_expenses_1.dta
									MWI_IHS_IHPS_W4_fishing_expenses_2.dta
									MWI_IHS_IHPS_W4_fish_income.dta
									
*OTHER INCOME						MWI_IHS_IHPS_W4_other_income.dta
									MWI_IHS_IHPS_W4_land_rental_income.dta
									
*CROP INCOME						MWI_IHS_IHPS_W4_crop_income.dta
																	
*SELF-EMPLOYMENT INCOME				MWI_IHS_IHPS_W4_self_employment_income.dta
									MWI_IHS_IHPS_W4_agproducts_profits.dta
									MWI_IHS_IHPS_W4_fish_trading_revenue.dta
									MWI_IHS_IHPS_W4_fish_trading_other_costs.dta
									MWI_IHS_IHPS_W4_fish_trading_income.dta
									
*WAGE INCOME						MWI_IHS_IHPS_W4_wage_income.dta
									MWI_IHS_IHPS_W4_agwage_income.dta

*FARM SIZE / LAND SIZE				MWI_IHS_IHPS_W4_land_size.dta
									MWI_IHS_IHPS_W4_farmsize_all_agland.dta
									MWI_IHS_IHPS_W4_land_size_all.dta
*FARM LABOR							MWI_IHS_IHPS_W4_farmlabor_mainseason.dta
									MWI_IHS_IHPS_W4_farmlabor_shortseason.dta
									MWI_IHS_IHPS_W4_family_hired_labor.dta
									
*VACCINE USAGE						MWI_IHS_IHPS_W4_vaccine.dta
*ANIMAL HEALTH - DISEASES			MWI_IHS_IHPS_W4_livestock_diseases.dta
*LIVESTOCK WATER, FEEDING, HOUSING
*USE OF INORGANIC FERTILIZER		MWI_IHS_IHPS_W4_fert_use.dta
*USE OF IMPROVED SEED				MWI_IHS_IHPS_W4_improvedseed_use.dta

*REACHED BY AG EXTENSION			MWI_IHS_IHPS_W4_any_ext.dta
*MOBILE OWNERSHIP                   MWI_IHS_IHPS_W4_mobile_own.dta
*USE OF FORMAL FINANACIAL SERVICES	MWI_IHS_IHPS_W4_fin_serv.dta

*GENDER PRODUCTIVITY GAP 			MWI_IHS_IHPS_W4_gender_productivity_gap.dta
*MILK PRODUCTIVITY					MWI_IHS_IHPS_W4_milk_animals.dta
*EGG PRODUCTIVITY					MWI_IHS_IHPS_W4_eggs_animals.dta

*CONSUMPTION						MWI_IHS_IHPS_W4_consumption.dta
*HOUSEHOLD FOOD PROVISION			MWI_IHS_IHPS_W4_food_insecurity.dta
*HOUSEHOLD ASSETS					MWI_IHS_IHPS_W4_hh_assets.dta
*SHANNON DIVERSITY INDEX			MWI_IHS_IHPS_W4_shannon_diversity_index

*RATE OF FERTILIZER APPLICATION		MWI_IHS_IHPS_W4_fertilizer_application.dta
*HOUSEHOLD'S DIET DIVERSITY SCORE	MWI_IHS_IHPS_W4_household_diet.dta
*WOMEN'S CONTROL OVER INCOME		MWI_IHS_IHPS_W4_control_income.dta
*WOMEN'S AG DECISION-MAKING			MWI_IHS_IHPS_W4_make_ag_decision.dta
*WOMEN'S ASSET OWNERSHIP			MWI_IHS_IHPS_W4_ownasset.dta

*CROP YIELDS						MWI_IHS_IHPS_W4_yield_hh_crop_level.dta
*CROP PRODUCTION COSTS PER HECtaRE	MWI_IHS_IHPS_W4_hh_cost_land.dta
									MWI_IHS_IHPS_W4_hh_cost_inputs_lrs.dta
									MWI_IHS_IHPS_W4_hh_cost_inputs_srs.dta
									MWI_IHS_IHPS_W4_hh_cost_seed_lrs.dta
									MWI_IHS_IHPS_W4_hh_cost_seed_srs.dta		
									MWI_IHS_IHPS_W4_cropcosts_perha.dta

*FINAL FILES						MAIN FILES CREATED
*-------------------------------------------------------------------------------------
*HOUSEHOLD VARIABLES				MWI_IHS_IHPS_W4_household_variables.dta
*INDIVIDUAL-LEVEL VARIABLES			MWI_IHS_IHPS_W4_individual_variables.dta	
*PLOT-LEVEL VARIABLES				MWI_IHS_IHPS_W4_gender_productivity_gap.dta
*SUMMARY StaTISTICS					MWI_IHS_IHPS_W4_summary_stats.xlsx
*/


* General notes *
* HKS: The "reference" rainy and dry (dimba) seasons can refer to one of 2 seasons as per the BID
* HKS: For Malawi W4, some questions from the questionnaire were reserved only for the IHS cross-sectional interviews, while others were reserved for the IHPS panel data. Households are (generally) tracked across IHS and IHPS using the common identifier "case_id". Similar identifiers, such as "hhid" (IHS) and y4_hhid (IHPS) are not sufficient when incorporating both datasets, as they refer to only one. 
* HKS: For consistency across waves and for future integration into AgQueryPlus, HHID is being consistently renamed to hhid for all created/final data files. 

clear
set more off

clear matrix	
clear mata	
set maxvar 8000		
//ssc install findname      //need this user-written ado file for some commands to work_TH



*****************************
***** SET DIRECTOREIS *******
*****************************
*These paths correspond to the folders where the raw data files are located and where the created data and final data will be stored.
*global MWI_IHS_IHPS_W4_raw_data 			"\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\raw_data"
*global MWI_IHS_IHPS_W4_created_data 		"\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\temp" // hks 5/5/23: not sure why this would be temp??? there are files saved to both temp and creatd data recently; not sure who changed the file path?

* To accomodate the IHS+IHPS appended files, use TEMP folder I create in loop below
global MWI_IHS_IHPS_W4_raw_data 			"\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\Raw DTA Files\appended_data" // where appended_data file holds an appended version of raw data containing both the panel and cross sectional households

global MWI_IHS_IHPS_W4_created_data 		"\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\Final DTA Files\created_data"

global MWI_IHS_IHPS_W4_final_data  		"\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\Final DTA Files\outputs"

//Conventions: After section title, add initials; "IP" for in Progress/ "Complete [date] without check" if code is drafted but not checked; "Complete [date] + [Reviewer initials] checked [date]"


************************************************************************
*EXCHANGE RATE AND INFLATION FOR CONVERSION IN SUD IDS  
************************************************************************
global MWI_IHS_IHPS_W4_exchange_rate 2158
global MWI_IHS_IHPS_W4_gdp_ppp_dollar 205.61    // https://data.worldbank.org/indicator/PA.NUS.PPP -2017
global MWI_IHS_IHPS_W4_cons_ppp_dollar 207.24	 // https://data.worldbank.org/indicator/PA.NUS.PRVT.PP - Only 2016 data available 
global MWI_IHS_IHPS_W4_inflation 0.7366255144 // inflation rate 2015-2016. Data was collected during oct2014-2015. We want to adjust the monetary values to 2016 // hs 4/12/23: CPI 2015/CPI2017 = 250.6/340.2

* New poverty indicators added 4/12/23 by HS
global MWI_IHS_IHPS_W4_pov_threshold (1.90*78.7) // HS 4/12/23: 1.90*(CONS PPP 2011 = 78.7) //Calculation for WB's previous $1.90 (PPP) poverty threshold. This controls the indicator poverty_under_1_9; change the 1.9 to get results for a different threshold. Note this is based on the 2011 PPP conversion!
global MWI_IHS_IHPS_W4_poverty_nbs 7184 *(1.5263367917) // HS 4/12/23: According to this document, the national poverty line in Birr in 2015/16 was 7184 (https://dagethiopia.org/sites/g/files/zskgke376/files/2022-03/poverty_economic_growth_in_ethiopia-mon_feb_11_2019.pdf); thus to calculate this figure adjusted to 2018-19, we calculate inflation = CPI 2018/CPI 2015 = 382.5/250.6 = 1.5263367917
global MWI_IHS_IHPS_W4_poverty_215 2.15 * $MWI_IHS_IHPS_W4_inflation * $MWI_IHS_IHPS_W4_cons_ppp_dollar  // using 2017 values

 
********************************************************************************
*THRESHOLDS FOR WINSORIZATION -- RH, Complete 7/15/21 - not checked
********************************************************************************
global wins_lower_thres 1    						//  Threshold for winzorization at the bottom of the distribution of continous variables
global wins_upper_thres 99							//  Threshold for winzorization at the top of the distribution of continous variables

********************************************************************************
*GLOBALS OF PRIORITY CROPS 
********************************************************************************
*Enter the 12 priority crops here (maize, rice, wheat, sorghum, pearl millet (or just millet if not disaggregated), cowpea (doesn't exist in data), groundnut, common bean, yam (does not exist in data, just cocoyam), sweet potato, cassava, banana)
	*plus any crop in the top ten crops by area planted that is not already included in the priority crops - limit to 6 letters or they will be too long!
	*For consistency, add the 12 priority crops in order first, then the additional top ten crops

global topcropname_area "maize grdnt nkhwani mango soyabean pigpea tobacco cassav beans sorghum swtptt rice" 
global topcrop_area "1 11 42 52 35 36 5 49 34 32 28 17"
global comma_topcrop_area "1, 11, 42, 52, 35, 36, 5, 49, 34, 32, 28, 17"
global nb_topcrops : list sizeof global(topcropname_area) // Gets the current length of the global macro list "topcropname_area" 
display "$nb_topcrops"

global nb_topcrops : list sizeof global(topcropname_area)
set obs $nb_topcrops 
egen rnum = seq(), f(1) t($nb_topcrops)
gen crop_code = .
gen crop_name = ""
forvalues k=1(1)$nb_topcrops {
	local c : word `k' of $topcrop_area
	local cn : word `k' of $topcropname_area 
	replace crop_code = `c' if rnum==`k'
	replace crop_name = "`cn'" if rnum==`k'
}
drop rnum
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_cropname_table.dta", replace 

/*use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_all_plots.dta", clear
merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhsize.dta"
gen area= ha_planted*weight
collapse (sum) area, by (crop_code)*/

********************************************************************************
* POPULATION FIGURES 
********************************************************************************
* (https://databank.worldbank.org/source/world-development-indicators#)
global MWI_IHS_IHPS_W4_pop_tot 18867337
global MWI_IHS_IHPS_W4_pop_rur 15627061
global MWI_IHS_IHPS_W4_pop_urb 3240276

/********************************************************************************
* APPENDING Malawi IHPS data to IHS data (does not need to be re-run every time)
* After running, must change created_data file path back to raw/created_data (above)
********************************************************************************
* HKS 07.06.23: Adding a new global for appending in the panel data
global append_data "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-ihps-all-datasets"
* Issue: case_id doesn't account for split off households. For example, 2 households may both have a case_id of "210663390033", but have different y4_hhid (1309-002 and 1312-004) and often y3_hhid as well. Later, when trying to merge in hh_mod_a_filt_19.dta (to get case_id and qx),

* HKS 7/6/23: appending panel files (IHPS) in to IHS data; renaming HHID hhid
global temp_data "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\appended_data"
local directory_raw "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\raw_data"
local directory_panel "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-ihps-all-datasets"
cd "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\"
local raw_files : dir "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\raw_data" files "*.dta", respectcase
local panel_files : dir "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-ihps-all-datasets" files "*_19.dta", respectcase



*local panel_files : dir "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-ihps-all-datasets\bs" files "*_19.dta", respectcase


*  restrict to only those which haven't been run to completion
foreach panelfile of local panel_files {
			*local filename : subinstr local panelfile "19.dta" ""
			*isplay in red "`filename'"
	local raw_file = subinstr("`panelfile'", "_19", "", .)
			if !fileexists("${temp_data}/`raw_file'") { // if file has not yet been saved to temp_data
			if (!strpos("`panelfile'", "meta") & !strpos("`panelfile'", "com_") ){
				use "`directory_panel'/`panelfile'", clear // use IHPS
					display in red  "`directory_panel'/`panelfile'"
			local append_file "`directory_raw'/`raw_file'" // Append IHS
				display in red "we will be appending the following raw IHS data: `append_file'"
				
			*if (!strpos("`append_file'", "meta")) { // if the raw data (append file) does not contain "meta", appendfile
			preserve
				use "${append_data}\hh_mod_a_filt_19.dta", clear
				tostring HHID, replace
				replace HHID = y4_hhid
				*ren HHID hhid
				tempfile merge_file
				save `merge_file'
			restore

			capture tostring ag_e13_2*, replace
			capture destring ag_f39*, replace
			capture destring ag_h39*, replace
			capture tostring HHID, replace
			capture destring PID, replace
			capture replace HHID = y4
				if _rc {
					capture gen HHID = y4
				}

			append using "`append_file'"
			merge m:1 y4_hhid using "`merge_file'", nogen keep(1 3) keepusing(case_id HHID y4 qx ea) // merge in case_id to each of these IHPS file
			* Households that do not match from master are those which are in IHS but are not also in IHPS.
				ren qx panel_dummy
				ren HHID hhid
				ren y4_hhid y4_hhid_IHPS
				*replace hhid = y4 if hhid == ""
				display in red "we are saving to '${temp_data}\`raw_file'" 
				save "${temp_data}/`raw_file'", replace // Save in GH location
				}
}
}

use "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\raw_data\householdgeovariables_ihs5.dta", clear
duplicates drop
*drop if HHID == .
append using "R:\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-ihps-all-datasets\MWI W4\householdgeovariables_y4.dta"
			merge m:1 y4_hhid using "${append_data}\hh_mod_a_filt_19.dta", nogen keep(1 3) keepusing(case_id HHID y4 qx) // merge in case_id to each of these IHPS file
			*drop if HHID == .
			drop if case_id == ""
save "${temp_data}\householdgeovariables_ihs5", replace
 
* For other files in the original raw folder that were not edited - copy them into new "raw" (that is, my Temp folder):
use "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\raw_data\Agricultural Conversion Factor Database.dta", clear
save "${MWI_IHS_IHPS_W4_raw_data}\Agricultural Conversion Factor Database.dta", replace

use "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\raw_data\caloric_conversionfactor.dta", clear
	save "${MWI_IHS_IHPS_W4_raw_data}\caloric_conversionfactor.dta", replace

use "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\raw_data\ihs_seasonalcropconversion_factor_2020_alt-mod_update.dta", clear
	save "${MWI_IHS_IHPS_W4_raw_data}\ihs_seasonalcropconversion_factor_2020_alt-mod_update.dta", replace


use "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\raw_data\ihs_seasonalcropconversion_factor_2020_alt-mod_update.dta", clear
	save "${MWI_IHS_IHPS_W4_raw_data}\ihs_seasonalcropconversion_factor_2020_alt-mod_update.dta", replace

use "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\raw_data\Conversion_factors_perm.dta", clear
	save "${MWI_IHS_IHPS_W4_raw_data}\Conversion_factors_perm.dta", replace


*"${MWI_IHS_IHPS_W4_raw_data}/Conversion_factors_perm.dta"	*/

************************************************
*HOUSEHOLD IDS - CG complete 1/24/2024
************************************************
use "${MWI_IHS_IHPS_W4_raw_data}\hh_mod_a_filt.dta", clear
rename hh_wgt weight
recode region (100=1) (200=2) (300=3) //ALT 10.09.23: Added in to fix append issue
lab var region "1=North, 2=Central, 3=South"
gen rural = (reside==2)
ren reside stratum
ren ea_id ea
ren hh_a02a ta
keep hhid case_id stratum district ta ea rural region weight 
//replace case_id = hhid if case_id == " " //hhid uniquely identifies in this section
lab var rural "1=Household lives in a rural area"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", replace

********************************************************************************
* WEIGHTS * 
********************************************************************************
use "${MWI_IHS_IHPS_W4_raw_data}\hh_mod_a_filt.dta", clear
rename hh_a02a ta 
rename hh_a03 ea
rename hh_wgt weight
gen rural = (reside==2)
ren reside stratum
recode region (100=1) (200=2) (300=3) 
lab var region "1=North, 2=Central, 3=South" 
lab var rural "1=Household lives in a rural area"
keep case_id hhid region stratum district ta ea rural weight  
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_weights.dta", replace

************************************************
*INDIVIDUAL IDS - CG complete 1/24/24
************************************************
use "${MWI_IHS_IHPS_W4_raw_data}\hh_mod_b", clear
ren PID indiv	//At the individual-level, the IHPS data from 2010, 2013, and 2016, and 2019 can be merged using the variable PID - will be used later in data
keep hhid case_id indiv hh_b03 hh_b05a hh_b04
gen female=hh_b03==2 
lab var female "1= indivdual is female"
gen age=hh_b05a
lab var age "Indivdual age"
gen hh_head=hh_b04 if hh_b04==1
lab var hh_head "1= individual is household head"
replace hh_head = 0 if missing(hh_head)
drop hh_b03 hh_b05 hh_b04
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_person_ids.dta", replace

************************************************
*HOUSEHOLD SIZE - CG complete 1/24/24
************************************************
use "${MWI_IHS_IHPS_W4_raw_data}\hh_mod_b", clear
gen hh_members = 1	//Generate this so we can sum later and identify the # of hh members (each member gets a HHID so summing will help collapse this to see hh #)
rename hh_b04 relhead 
rename hh_b03 gender
gen fhh = (relhead==1 & gender==2)	//Female heads of households
collapse (sum) hh_members (max) fhh, by (case_id hhid)
lab var hh_members "Number of household members"
lab var fhh "1= Female-headed household"

merge 1:1 case_id hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", nogen keep(2 3)
total hh_members [pweight=weight]
matrix temp =e(b)
gen weight_pop_tot=weight*${MWI_IHS_IHPS_W4_pop_tot}/el(temp,1,1)
total hh_members [pweight=weight_pop_tot]
lab var weight_pop_tot "Survey weight - adjusted to match total population"
*Adjust to match total population but also rural and urban
total hh_members [pweight=weight] if rural==1
matrix temp =e(b)
gen weight_pop_rur=weight*${MWI_IHS_IHPS_W4_pop_rur}/el(temp,1,1) if rural==1
total hh_members [pweight=weight_pop_tot]  if rural==1

total hh_members [pweight=weight] if rural==0
matrix temp =e(b)
gen weight_pop_urb=weight*${MWI_IHS_IHPS_W4_pop_urb}/el(temp,1,1) if rural==0
total hh_members [pweight=weight_pop_urb]  if rural==0

egen weight_pop_rururb=rowtotal(weight_pop_rur weight_pop_urb)
total hh_members [pweight=weight_pop_rururb]  
lab var weight_pop_rururb "Survey weight - adjusted to match rural and urban population"
drop weight_pop_rur weight_pop_urb
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhsize.dta", replace

************************************************
*PLOT AREAS - CWL complete 10/27/22. not checked. // Updated 5/11/23 by HKS to model NGA W3; major changes are merging in conversion factors and calculating field_size (used later in plot rents)
************************************************
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_p", clear
gen season=2 //perm
rename plotid plot_id 
rename gardenid garden_id
//keep ag_p0_crops if ag_p02a !=. //make sure that the area of these crops are included
ren ag_p02a area
ren ag_p02b unit
duplicates drop //zero duplicate entry
drop if garden_id=="" // 9 obs deleted 
keep if strpos(plot_id, "T") & plot_id!="" //0 obs deleted 
collapse (max) area, by(hhid garden_id plot_id ag_p0_crops crop_code season unit)
collapse (sum) area, by(hhid garden_id plot_id season unit)
replace area=. if area==0 //the collapse (sum)function turns blank observations in 0s - as the raw data for ag_mod_p have no observations equal to 0, we can do a mass replace of 0s with blank observations so that we are not reporting 0s where 0s were not reported.
drop if area==. & unit==.

gen area_acres_est = area if unit==1 											//Permanent crops in acres
replace area_acres_est = (area*2.47105) if area == 2 & area_acres_est ==.		//Permanent crops in hectares
replace area_acres_est = (area*0.000247105) if area == 3 & area_acres_est ==.	//Permanent crops in square meters
keep hhid plot_id garden_id season area_acres_est

collapse (sum) area_acres_est, by (hhid plot_id garden_id season)
replace area_acres_est=. if area_acres_est==0 //the collapse function turns blank observations in 0s - as the raw data for ag_mod_p have no observations equal to 0, we can do a mass replace of 0s with blank observations so that we are not reporting 0s where 0s were not reported.


tempfile ag_perm
save `ag_perm'

//CWL: adding module o2 include tree/permcrop roster here
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_c.dta", clear // HS 2.3.23: RAINY SEASON crop data; data about PLOT ID, Garden ID (how many plots per HH? How many gardens and how many plots in that garden?) GPS conditions, area reporting info, etc.
	gen season = 0 
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_j.dta" // HS 2.3.23: DRY SEASON crop data; more GARDEN and PLOT info
	replace season = 1 if season ==. 
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_o2.dta" // HS 2.3.23:  PERMANENT CROPS
	replace season = 2 if season == .

* Counting acreage
gen area_acres_est = ag_c04a if ag_c04b == 1 										//Self-report in acres - rainy season 
replace area_acres_est = (ag_c04a*2.47105) if ag_c04b == 2 & area_acres_est ==.		//Self-report in hectares
replace area_acres_est = (ag_c04a*0.000247105) if ag_c04b == 3 & area_acres_est ==.	//Self-report in square meters
replace area_acres_est = ag_j05a if ag_j05b==1										//Replace with dry season measures if rainy season is not available
replace area_acres_est = (ag_j05a*2.47105) if ag_j05b == 2 & area_acres_est ==.		//Self-report in hectares
replace area_acres_est = (ag_j05a*0.000247105) if ag_j05b == 3 & area_acres_est ==.	//Self-report in square meters
replace area_acres_est = ag_o04a if ag_o04b==1										//Permanent crops in acres
replace area_acres_est = (ag_o04a*2.47105) if ag_o04b == 2 & area_acres_est ==.		//Permanent crops in hectares
replace area_acres_est = (ag_o04a*0.000247105) if ag_o04b == 3 & area_acres_est ==. //Permanent crops in square meters

* GPS MEASURE
gen area_acres_meas = ag_c04c														//GPS measure - rainy
replace area_acres_meas = ag_j05c if area_acres_meas==. 							//GPS measure - replace with dry if no rainy season measure
replace area_acres_meas = ag_o04c if area_acres_meas == . 							//GPS measure - permanent crops
keep if area_acres_est !=. | area_acres_meas !=. 									//Keep if acreage or GPS measure info is available

lab var season "season: 0=rainy, 1=dry, 2=tree crop"
	label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
	label values season season 

gen field_size= (area_acres_est* (1/2.47105))
replace field_size = (area_acres_meas* (1/2.47105))  if field_size==. & area_acres_meas!=. 
ren plot plot_id
ren gardenid garden_id
keep hhid case_id plot_id garden_id area_acres_est area_acres_meas field_size season	
gen gps_meas = area_acres_meas!=. 
lab var gps_meas "Plot was measured with GPS, 1=Yes" 

lab var area_acres_meas "Plot area in acres (GPSd)"
lab var area_acres_est "Plot area in acres (estimated)"
gen area_est_hectares=area_acres_est* (1/2.47105)  
gen area_meas_hectares= area_acres_meas* (1/2.47105)
lab var area_meas_hectares "Plot are in hectares (GPSd)"
lab var area_est_hectares "Plot area in hectares (estimated)"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_areas.dta", replace 

********************************************************************************
*GPS COORDINATES *
********************************************************************************
use "${MWI_IHS_IHPS_W4_raw_data}\householdgeovariables_ihs5.dta", clear
ren HHID hhid
tostring hhid, replace
merge 1:m case_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", nogen keep(3) 
ren ea_lat_mod latitude
ren ea_lon_mod longitude
keep case_id latitude longitude
gen GPS_level = "hhid"

save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hh_coords.dta", replace

********************************************************************************
*PLOT DECISION MAKERS 
********************************************************************************
use "${MWI_IHS_IHPS_W4_raw_data}/hh_mod_b.dta", clear  	
ren id_code indiv		
replace indiv=PID if indiv==.
drop if indiv==. //0 obs deleted
gen female =hh_b03==2
gen age = hh_b05a //3 missing values generated
gen head = hh_b04==1 if hh_b04!=.
keep indiv female age case_id hhid head 
lab var female "1=Individual is a female"
lab var age "Individual age"
lab var head "1=Individual is the head of household"
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_gender_merge.dta", replace //65,125 obs

use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_p.dta", clear 	
ren gardenid garden_id
ren plotid plot_id
drop if plot_id=="" | garden_id==""
keep if strpos(plot_id, "T") //R and D plots have been reported in previous modules
gen season=2
ren ag_p0c crop_code_perm
replace crop_code=39 if strpos(ag_p0d_oth, "SUGAR CANE") 
replace crop_code_perm=4 if strpos(ag_p0d_oth, "MANGO") 
recode crop_code_perm (.a=.)
replace crop_code_perm = crop_code if crop_code_perm == .
lab var crop_code_perm "TREE/PERMANENT CROP CODE"
drop if crop_code_perm ==. 
//Don't need to worry about multiple varieties of same crop on same plot 
duplicates drop hhid case_id crop_code_perm garden_id plot_id, force //hhid appears to uniquely identify all households here 

//In the absence of knowing a plot decision maker on any tree/perm plots (T1, T2,...TN) that do not show up in rainy/dry data, we are creating an assumption that the person that decides what to do with earnings for a particular crop is also the plot decision maker. We are only applying this assumption to households that grow a certain crop uniquely on one plot, but not multiple.
//TO DO: A few stray obs where the crop is in the os column and should be recoded. Mostly trees.

keep hhid case_id plot_id garden_id crop_code_perm season
duplicates tag hhid crop_code_perm, gen(dups)
preserve
keep if dups > 0 //7,144 obs deleted
keep hhid case_id plot_id season
duplicates drop
tempfile dm_p_hoh
gen source_file="mod_p"
save `dm_p_hoh' //reserve the multiple instances of similar crops for use in another recipe
restore
drop if dups>0 //restricting observations to those where a unique crop is grown on only one plot
drop dups
recast str50 hhid, force 
tempfile one_plot_per_crop
gen source_file="mod_p"
save `one_plot_per_crop'

use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_q.dta", clear 
drop if ag_q01==2 //drop if no crop was sold.
ren ag_q06a indiv1 
ren ag_q06b indiv2 
ren crop_code crop_code_perm
duplicates drop case_id crop_code_perm indiv1 indiv2, force
recast str50 hhid, force 
merge 1:1 hhid crop_code_perm  using `one_plot_per_crop', keep (3) nogen
keep hhid case_id garden_id plot_id indiv* crop_code_perm
reshape long indiv, i(hhid case_id garden_id plot_id crop_code_perm) j(dm_no)
drop crop_code_perm
recode indiv (.a=.)
duplicates drop
//For verification:
//bys hhid garden_id plot_id : gen obs=_n
//replace dm_no = obs
//drop obs 
//reshape wide indiv, i(hhid garden_id plot_id) j(dm_no)
//We now have up to 4 decisionmakers because of plots with multiple crops.
gen season=2
tempfile dm_p
save `dm_p'

//use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_b2.dta", clear
use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_d.dta", clear //No point in attempting to understand ownership because it isn't included in the instrument and all plots have at least one manager listed.
rename plotid plot_id
rename gardenid garden_id
drop if plot_id=="" | garden_id=="" //2 observations deleted
gen season=0
tempfile dm_r
ren ag_d01 indiv1 //manager
ren ag_d01_2a indiv2 //manager
ren ag_d01_2b indiv3 //manager
recode indiv* (0=.)
//Not used - actual ownership questions (b2_04) were not included in data
//ren ag_b213__0 indiv4 //owner
//ren ag_b213__1 indiv5 //owner
keep hhid case_id plot_id garden_id indiv* season
//collapse (firstnm) indiv*, by(hhid plot_id garden_id season)
duplicates drop
save `dm_r'

//use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_i2.dta", clear //ibid
use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_k.dta", clear
ren plotid plot_id
ren gardenid garden_id
drop if plot_id=="" | garden_id==""
gen season=1
gen indiv1=ag_k02 //manager
gen indiv2=ag_k02_2a //manager
gen indiv3=ag_k02_2b //manager
//gen indiv4=ag_i213a //owner
//gen indiv5=ag_i213b //owner
recode indiv* (0=.)

keep hhid case_id plot_id garden_id indiv* season 
collapse (firstnm) indiv*, by(hhid case_id plot_id garden_id season)
append using `dm_r'
//append using `dm_p'
recode indiv* (.a=.)
//gen nomgr = indiv1==. & indiv2==. & indiv3==. 
//replace indiv1=indiv4 if nomgr==1 //0 changes, no info in indiv4?
//replace indiv2=indiv5 if nomgr==1 //0 changes, also no info indiv5?
//drop nomgr
reshape long indiv, i(hhid case_id plot_id garden_id season) j(id_no)
append using `dm_p'
//preserve
preserve
bys hhid plot_id : egen mindiv = min(indiv)
keep if mindiv==. 
duplicates drop //1 obs deleted

append using `dm_p_hoh' 
recast str50 hhid, force 
merge m:m hhid using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_gender_merge.dta" //, nogen keep(1 3) //61,076 matched CG 3.26.2024
keep if head==1
tempfile hoh_plots
save `hoh_plots'
restore
drop if indiv==.
merge m:1 hhid indiv using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_gender_merge.dta", keep (1 3) nogen //41,341 matched CG 3.26.2024
append using `hoh_plots'
duplicates drop hhid plot_id garden_id season female, force 
duplicates tag hhid plot_id garden_id season, g(dups)
gen dm_gender = 1 if female==0 //why does this show up as dm_no? tabbing it doesn't make sense
replace dm_gender = 2 if female==1
replace dm_gender = 3 if dups > 0 
keep hhid case_id plot_id garden_id case_id season dm_gender
duplicates drop //0 duplicates
drop if dm_gender==. //56 deleted
drop if plot_id == "" //13,794 deleted
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_decision_makers.dta", replace


/* not working 
// using season as an id var
restore
drop if indiv==.
recast str50 hhid, force 
merge m:1 hhid indiv using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_gender_merge.dta", keep (1 3) nogen //4,358 not matched, 5,890 matched CG 2.1.2024
append using `hoh_plots'


// using season as an id var
preserve
duplicates drop hhid plot_id garden_id season female, force 
duplicates tag hhid plot_id garden_id season, g(dups)
gen dm_gender = 1 if female==0
replace dm_gender = 2 if female==1
replace dm_gender = 3 if dups > 0 //no dups found
keep hhid plot_id garden_id case_id season dm_gender
duplicates drop
restore

//w/o season - note no difference
duplicates drop hhid garden_id plot_id female, force
duplicates tag hhid garden_id plot_id, g(dups)
gen dm_gender = 1 if female==0
replace dm_gender = 2 if female==1
replace dm_gender = 3 if dups > 0
keep hhid plot_id garden_id case_id dm_gender
duplicates drop */

********************************************************************************
* FORMALIZED LAND RIGHTS * - No formalized land rights data available for W4
********************************************************************************
/*use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_b2.dta", clear
gen season=0
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_i2.dta"
replace season=1 if season==.
lab var season "season: 0=rainy, 1=dry, 2=tree crop"
label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
label values season season

// ag_b213__0 ag_b213__1 who owns this garden? 
// ag_i213a ag_i213b  who owns this garden?

gen formal_land_rights=1 if ag_b213__0 !=. & ag_b213__1 !=. 
replace formal_land_rights=1 if ag_i213a !=. & ag_i213b !=. & formal_land_rights==.
replace formal_land_rights=0 if  ag_b213__0 !=1 & ag_b213__1 !=1 & formal_land_rights==.
replace formal_land_rights=0 if ag_i213a !=1 & ag_i213b & formal_land_rights==.

//Primary Land Owner
gen indiv=ag_b204_2__0
replace indiv=ag_i204a_1 if ag_i204a_1!=. & indiv==.
recast str50 hhid, force 
merge m:1 hhid indiv using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_person_ids.dta", keep (1 3) nogen //SS 10.16.23 Only 684 observations matched 
ren indiv primary_land_owner
ren female primary_land_owner_female
drop age hh_head

//Secondary Land Owner
gen indiv=ag_b204_2__1
replace indiv=ag_i204a_2 if ag_i204a_2!=. & indiv==.
merge m:1 hhid indiv using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_person_ids.dta", keep (1 3) nogen //SS 10.16.23 Only 67 observations matched 
ren indiv secondary_land_owner_1
ren female secondary_land_owner_female_1
drop age hh_head

//Secondary Land Owner #2 
gen indiv=ag_b204_2__2
replace indiv=ag_i204a_3 if ag_i204a_3!=. & indiv==.
merge m:1 hhid indiv using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_person_ids.dta", keep (1 3) nogen //SS 10.16.23 Only 16 observations matched 
ren indiv secondary_land_owner_2
ren female secondary_land_owner_female_2
drop age hh_head

//Secondary Land Owner #3 
gen indiv=ag_b204_2__3
replace indiv=ag_i204a_4 if ag_i204a_4!=. & indiv==.
merge m:1 hhid indiv using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_person_ids.dta", keep (1 3) nogen //SS 10.16.23 Only 11 observations matched 
ren indiv secondary_land_owner_3
ren female secondary_land_owner_female_3
drop age hh_head

gen formal_land_rights_f=1 if formal_land_rights==1 & (primary_land_owner_female==1 | secondary_land_owner_female_1==1 | secondary_land_owner_female_2==1 | secondary_land_owner_female_3 ==1 )
preserve
collapse (max) formal_land_rights_f, by(hhid) //MGM 10.6.2023: QUESTION FOR ALT - I removed indiv from by() as compared to Nigeria because we have both primary and secondary land owners in MWI and we need one obs per househould, correct?		
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_land_rights_ind.dta", replace
restore
collapse (max) formal_land_rights_hh=formal_land_rights, by(hhid)
keep hhid formal_land_rights_hh
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_rights_hh.dta", replac
*/

************************************************
*CROP UNIT CONVERSION FACTORS
************************

*** Caloric conversions - 9/26/22 CWL addressed comments from ALT
	use "${MWI_IHS_IHPS_W4_raw_data}/caloric_conversionfactor.dta", clear
	
* Notes Addressed by CWL in Code Below * 	
	/*ALT: It's important to note that the file contains some redundancies (e.g., we don't need maize flour because we know the caloric value of the grain; white and orange sweet potato are identical, etc. etc.)
	So we need a step to drop the irrelevant entries. */
	//Also there's no way tea and coffee are just tea/coffee
	//Also, data issue: no crop code is indicative of green maize (i.e., sweet corn); I'm assuming this means cultivation information is not tracked for that crop
	//Calories for wheat flour are slightly higher than for raw wheat berries.
	
	* Drop redundant items
	drop if inlist(item_code, 101, 102, 103, 105, 202, 204, 206, 207, 301, 305, 405, 813, 820, 822, 901, 902) | cal_100g == .

	* Standardize item names to all UPPER CASE
	local item_name item_name
	foreach var of varlist item_name{
		gen item_name_upper=upper(`var')
	}
	
	* Create new crop code
	gen crop_code = .
	count if missing(crop_code) //106 missing (number of obs)
	
	// crop seed master list
	replace crop_code=1 if strpos(item_name_upper, "MAIZE") 
	replace crop_code=5 if strpos(item_name_upper, "TOBACCO")
	replace crop_code=11 if strpos(item_name_upper, "GROUNDNUT") 
    replace crop_code=17 if strpos(item_name_upper, "RICE")
	replace crop_code=34 if strpos(item_name_upper, "BEAN")
	replace crop_code=27 if strpos(item_name_upper, "GROUND BEAN") | strpos(item_name_upper, "NZAMA")
	replace crop_code=28 if strpos(item_name_upper, "SWEET POTATO")
	replace crop_code=29 if strpos(item_name_upper, "IRISH POTATO") | strpos(item_name_upper, "MALAWI POTATO")
	replace crop_code=30 if strpos(item_name_upper, "WHEAT")
	replace crop_code=31 if strpos(item_name_upper, "FINGER MILLET")  | strpos(item_name_upper, "MAWERE")
	replace crop_code=32 if strpos(item_name_upper, "SORGHUM")
	replace crop_code=33 if strpos(item_name_upper, "PEARL MILLET") | strpos(item_name_upper, "MCHEWERE")
	replace crop_code=35 if strpos(item_name_upper, "SOYABEAN")
	replace crop_code=36 if strpos(item_name_upper, "PIGEONPEA")| strpos(item_name_upper, "NANDOLO")
	replace crop_code=38 if strpos(item_name_upper, "SUNFLOWER")
	replace crop_code=39 if strpos(item_name_upper, "SUGAR CANE")
	replace crop_code=40 if strpos(item_name_upper, "CABBAGE")
	replace crop_code=41 if strpos(item_name_upper, "TANAPOSI")
	replace crop_code=42 if strpos(item_name_upper, "NKHWANI")
	replace crop_code=43 if strpos(item_name_upper, "OKRA")
	replace crop_code=44 if strpos(item_name_upper, "TOMATO")
	replace crop_code=45 if strpos(item_name_upper, "ONION")
	replace crop_code=46 if strpos(item_name_upper, "PIGEON PEA")
	replace crop_code=47 if strpos(item_name_upper, "PAPRIKA")

	count if missing(crop_code) //87 missing
	
	// food from tree/permanent crop master list
	replace crop_code=49 if strpos(item_name_upper,"CASSAVA") 
	replace crop_code=50 if strpos(item_name_upper,"TEA")
	replace crop_code=51 if strpos(item_name_upper,"COFFEE") 
	replace crop_code=52 if strpos(item_name_upper,"MANGO")
	replace crop_code=53 if strpos(item_name_upper,"ORANGE" )
	replace crop_code=54 if strpos(item_name_upper,"PAWPAW" )| strpos(item_name_upper, "PAPAYA")
	replace crop_code=55 if strpos(item_name_upper,"BANANA" )
	
	replace crop_code=56 if strpos(item_name_upper,"AVOCADO" )
	replace crop_code=57 if strpos(item_name_upper,"GUAVA" )
	replace crop_code=58 if strpos(item_name_upper,"LEMON" )
	replace crop_code=59 if strpos(item_name_upper,"NAARTJE" )| strpos(item_name_upper, "TANGERINE")
	replace crop_code=60 if strpos(item_name_upper,"PEACH" )
	replace crop_code=61 if strpos(item_name_upper,"POZA") | strpos(item_name_upper, "APPLE")
	replace crop_code=63 if strpos(item_name_upper,"MASAU")
	replace crop_code=64 if strpos(item_name_upper,"PINEAPPLE" )
	replace crop_code=65 if strpos(item_name_upper,"MACADEMIA" )
	//replace crop_code= X if strpos(item_name_upper,"COCOYAM") No cropcode for cocoyam.
	count if missing(crop_code) //76 missing
	drop if crop_code == . 
	
	// Extra step for maize: maize grain (104) is same as shelled (removed from cob) maize
	// Use shelled/unshelled  ratio in unit conversion file
	//ALT: m:m should be a 1:m merge because duplicates indicate a problem. 
	gen unit = 1 //kg
	gen region = 1 //region doesn't matter for our purposes but will help reduce redundant entries after merge.
	merge 1:m crop_code unit region using "${MWI_IHS_IHPS_W4_raw_data}/Agricultural Conversion Factor Database.dta", nogen keepusing(condition shell_unshelled) keep(1 3)
	replace edible_p = shell_unshelled * edible_p if shell_unshelled !=. & item_code==104
	
	// Extra step for groundnut: single item with edible portion that implies that value is for unshelled
	// If it's shelled, assume edible portion is 100
	replace edible_p = 100 if strpos(item_name,"Groundnut") & strpos(item_name, "Shelled") // 0 changes 
	
	//ALT: you need to keep condition to successfully merge this with the crop harvest data
	//Note to double check and make sure that you don't need to fill in the missing condition codes.
	keep item_name crop_code cal_100g edible_p condition
	
	// Assume shelled if edible portion is 100
	replace condition=1 if edible_p==100
	
	// More matches using crop_code_short
	ren crop_code crop_code_short
	save "${MWI_IHS_IHPS_W4_raw_data}/MWI_IHS_IHPS_W4_caloric_conversionfactor_crop_codes.dta", replace

********************************************************************************
*ALL PLOTS 
********************************************************************************
/*This is based off Malawi W2. 
Inputs to this section: 
					___change__> sect11f: area_planted, date of last harvest, losses, actual harvest of tree/permanent crop, anticipated harvest of field crops, expected sales
					__change___> secta3i: date of harvest, quantity harvested, future expected harvest
					ag_mod_i_13 / ag_mod_o_13: actual sales
				Workflow:
					Get area planted/harvested
					Determine what's *actually* a monocropped plot 
					Value crop (based on estimated value, anticipated sales value, or actual sales value? Seems like going in reverse order is best)*/
					
/*Purpose: (from Uganda W5)
Crop values section is about finding out the value of sold crops. It saves the results in temporary storage that is deleted once the code stops running, so the entire section must be ran at once (conversion factors require output from Crop Values section).

Plot variables section is about pretty much everything else you see below in all_plots.dta. It spends a lot of time creating proper variables around intercropped, monocropped, and relay cropped plots, as the actual data collected by the survey seems inconsistent here.

Many intermediate spreadsheets are generated in the process of creating the final .dta

Final goal is all_plots.dta. This file has regional, hhid, plotid, crop code, fieldsize, monocrop dummy variable, relay cropping variable, quantity of harvest, value of harvest, hectares planted and harvested, number of trees planted, plot manager gender, percent inputs(?), percent field (?), and months grown variables.

Note: Malawi has dry season, rainy season, and permanent/tree crop data in separate modules
*/

   ***************************
	*Crop values 
	***************************
	//Nonstandard unit values (kg values in plot variables section)
	use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_i.dta", clear
	gen season=0 //rainy season 
	append using "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_o.dta" 
	recode season (.=1) //dry season 
	append using "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_q.dta"
	recode season (.=2) //tree or permanent crop
	lab var season "season: 0=rainy, 1=dry, 2=tree crop"
	label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
	label values season season
	keep if ag_i01==1 | ag_o01==1 | ag_q01==1 // keep if crop was sold
	ren ag_i02a sold_qty //rainy: total sold
	replace sold_qty = ag_o02a if sold_qty ==. & ag_o02a!=. //dry
	replace sold_qty = ag_q02a if sold_qty ==. & ag_q02a!=. //tree/permanent 
	ren ag_i02b unit
	replace unit = ag_o02b if unit ==. & ag_o02b!=. 
	replace unit = ag_q02b if unit ==. & ag_q02b!=.
	ren ag_i02c condition
	replace condition = ag_o02c if condition ==. & ag_o02c! =. 
	replace condition = ag_q02c if condition ==. & ag_q02c! =. 
	ren ag_i03 sold_value
	replace sold_value=ag_o03 if sold_value==. & ag_o03!=.
	replace sold_value=ag_q03 if sold_value==. & ag_q03!=.
	rename crop_code crop_code_long 
	
	
	label define AG_M0B 49 "CASSAVA" 50 "TEA" 51 "COFFEE" 52 "MANGO" 53 "ORANGE" 54 "PAWPAW/PAPAYA" 55 "BANANA" 56 "AVOCADO" 57 "GUAVA" 58 "LEMON" 59 "NAARTJE (TANGERINE)" 60 "PEACH" 61 "POZA (CUSTARD APPLE)" 62 "MASUKU (MEXICAN APPLE)" 63 "MASAU" 64 "PINEAPPLE" 65 "MACADEMIA" 66 "OTHER (SPECIFY)" 67 "N/A" 68 "N/A", add

	label define relabel /*these exist already*/ 1 "MAIZE LOCAL" 2 "MAIZE COMPOSITE/OPV" 3 "MAIZE HYBRID" 4 "MAIZE HYBRID RECYCLED" 5 "TOBACCO BURLEY" 6 "TOBACCO FLUE CURED" 7 "TOBACCO NNDF" 8 "TOBACCOSDF" 9 "TOBACCO ORIENTAL" 10 "OTHER TOBACCO (SPECIFY)" 11 "GROUNDNUT CHALIMBANA" 12 "GROUNDNUT CG7" 13 "GROUNDNUT MANIPINTA" 14 "GROUNDNUT MAWANGA" 15 "GROUNDNUT JL24" 16 "OTHER GROUNDNUT(SPECIFY)" 17 "RISE LOCAL" 18 "RISE FAYA" 19 "RISE PUSSA" 20 "RISE TCG10" 21 "RISE IET4094 (SENGA)" 22 "RISE WAMBONE" 23 "RISE KILOMBERO" 24 "RISE ITA" 25 "RISE MTUPATUPA" 26 "OTHER RICE(SPECIFY)"  28 "SWEET POTATO" 29 "IRISH [MALAWI] POTATO" 30 "WHEAT" 34 "BEANS" 35 "SOYABEAN" 36 "PIGEONPEA(NANDOLO" 37 "COTTON" 38 "SUNFLOWER" 39 "SUGAR CANE" 40 "CABBAGE" 41 "TANAPOSI" 42 "NKHWANI" 43 "THERERE/OKRA" 44 "TOMATO" 45 "ONION" 46 "PEA" 47 "PAPRIKA" 48 "OTHER (SPECIFY)"/*cleaning up these existing labels*/ 27 "GROUND BEAN (NZAMA)" 31 "FINGER MILLET (MAWERE)" 32 "SORGHUM" 33 "PEARL MILLET (MCHEWERE)" /*now creating unique codes for tree crops*/ 49 "CASSAVA" 50 "TEA" 51 "COFFEE" 52 "MANGO" 53 "ORANGE" 54 "PAWPAW/PAPAYA" 55 "BANANA" 56 "AVOCADO" 57 "GUAVA" 58 "LEMON" 59 "NAARTJE (TANGERINE)" 60 "PEACH" 61 "POZA (CUSTADE APPLE)" 62 "MASUKU (MEXICAN APPLE)" 63 "MASAU" 64 "PINEAPPLE" 65 "MACADEMIA" /*adding other specified crop codes*/ 105 "MAIZE GREEN" 203 "SWEET POTATO WHITE" 204 "SWEET POTATO ORANGE" 207 "PLANTAIN" 208 "COCOYAM (MASIMBI)" 301 "BEAN, WHITE" 302 "BEAN, BROWN" 308 "COWPEA (KHOBWE)" 405 "CHINESE CABBAGE" 409 "CUCUMBER" 410 "PUMPKIN" 1800 "FODDER TREES" 1900 "FERTILIZER TREES" 2000 "FUEL WOOD TREES", modify
	label val crop_code_long relabel
	
	gen value_harvest = sold_value 	// HKS 08.08.23: As per ALT, sold_value ("total value of all crop sales") is what we want for value_harvest, since there is no observed price value data
	//count if missing(crop_code); CWL: 0 missing crop_code
	keep hhid case_id crop_code sold_qty unit sold_value condition value_harvest
	merge m:1 case_id hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_weights.dta", nogen keep(1 3)
	keep hhid case_id sold_qty unit sold_value crop_code region district ta ea rural weight  value_harv
	lab var region "1=North, 2=Central, 3=South" 

	* Calculate average sold value per crop unit (price_unit)
	gen price_unit = sold_value/sold_qty // HS 02.07.23 3 missing values, n = 10,544
	lab var price_unit "Average sold value per crop unit"
	gen obs=price_unit!=.
	drop if price_unit==. | price_unit == 0 // HKS 4/27/23: this line is not present in W1, is it necessary?

	merge m:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", nogen keep(1 3)	
	* HKS 08.08.23 - for incorporating value harvested later (to avoid having to use val_harvest_est)
	preserve
	collapse (sum) value_harvest sold_qty, by(hhid crop_code unit)
	tempfile value_harvest_data
		save `value_harvest_data'
	restore
		
	* Create a value for the price of each crop at different levels
	foreach i in hhid ea ta district region {
	preserve
	bys `i' crop_code unit : egen obs_`i'_price = sum(obs) 
	collapse (median) price_unit_`i'=price_unit [aw=weight], by (`i' unit crop_code obs_`i'_price) 
	tempfile price_unit_`i'_median
	save `price_unit_`i'_median'
	restore
	}
	collapse (median) price_unit_country = price_unit (sum) obs_country_price=obs [aw=weight], by(crop_code unit)
	tempfile price_unit_country_median
	save `price_unit_country_median'
	
	***************************
	*Plot variables
	***************************	
	* This code creates unique crop codes for  the tree and permanent crops (and aligns it with codes in the conversion factor file to be merged in later)
	use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_p.dta", clear
	gen condition=3 if ag_p09_1==1 | ag_p09_1==3 | ag_p09_1==.
	recode crop_code (100=49)(2=50)(3=51)(4=52)(5=53)(6=54)(7=55)(8=56)(9=57)(10=58)(11=59)(12=60)(13=61)(14=62)(15=63)(16=64)(17=65)(18=66)(19=67)(20=68)(21=48) //see crop code labels below - verified that these are correct
	tempfile tree_perm
	save `tree_perm'
	
	use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_g.dta", clear //rainy
	gen season=0 //create variable for season 
	append using "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_m.dta" //dry
	recode season(.=1)
	append using `tree_perm' // tree/perm
	replace season = 2 if season == .
		lab var season "season: 0=rainy, 1=dry, 2=tree crop"
		label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
		label values season season 
	ren plotid plot_id
	ren gardenid garden_id
	
	merge m:1 hhid using   "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave4-2019\Raw DTA Files\appended_data\hh_mod_a_filt.dta", nogen keep(1 3) keepusing(ea hh_a03)
	
	replace ea = hh_a03 if ea == ""
	
	ren ag_p03 number_trees_planted // number of trees planted during last 12 months 
*Crop Code Labels
//label define  crop_code



label define relabel /*these exist already*/ 1 "MAIZE LOCAL" 2 "MAIZE COMPOSITE/OPV" 3 "MAIZE HYBRID" 4 "MAIZE HYBRID RECYCLED" 5 "TOBACCO BURLEY" 6 "TOBACCO FLUE CURED" 7 "TOBACCO NNDF" 8 "TOBACCOSDF" 9 "TOBACCO ORIENTAL" 10 "OTHER TOBACCO (SPECIFY)" 11 "GROUNDNUT CHALIMBANA" 12 "GROUNDNUT CG7" 13 "GROUNDNUT MANIPINTA" 14 "GROUNDNUT MAWANGA" 15 "GROUNDNUT JL24" 16 "OTHER GROUNDNUT(SPECIFY)" 17 "RISE LOCAL" 18 "RISE FAYA" 19 "RISE PUSSA" 20 "RISE TCG10" 21 "RISE IET4094 (SENGA)" 22 "RISE WAMBONE" 23 "RISE KILOMBERO" 24 "RISE ITA" 25 "RISE MTUPATUPA" 26 "OTHER RICE(SPECIFY)"  28 "SWEET POTATO" 29 "IRISH [MALAWI] POTATO" 30 "WHEAT" 34 "BEANS" 35 "SOYABEAN" 36 "PIGEONPEA(NANDOLO" 37 "COTTON" 38 "SUNFLOWER" 39 "SUGAR CANE" 40 "CABBAGE" 41 "TANAPOSI" 42 "NKHWANI" 43 "THERERE/OKRA" 44 "TOMATO" 45 "ONION" 46 "PEA" 47 "PAPRIKA" 48 "OTHER (SPECIFY)"/*cleaning up these existing labels*/ 27 "GROUND BEAN (NZAMA)" 31 "FINGER MILLET (MAWERE)" 32 "SORGHUM" 33 "PEARL MILLET (MCHEWERE)" /*now creating unique codes for tree crops*/ 49 "CASSAVA" 50 "TEA" 51 "COFFEE" 52 "MANGO" 53 "ORANGE" 54 "PAWPAW/PAPAYA" 55 "BANANA" 56 "AVOCADO" 57 "GUAVA" 58 "LEMON" 59 "NAARTJE (TANGERINE)" 60 "PEACH" 61 "POZA (CUSTADE APPLE)" 62 "MASUKU (MEXICAN APPLE)" 63 "MASAU" 64 "PINEAPPLE" 65 "MACADEMIA" /*adding other specified crop codes*/ 105 "MAIZE GREEN" 203 "SWEET POTATO WHITE" 204 "SWEET POTATO ORANGE" 207 "PLANTAIN" 208 "COCOYAM (MASIMBI)" 301 "BEAN, WHITE" 302 "BEAN, BROWN" 308 "COWPEA (KHOBWE)" 405 "CHINESE CABBAGE" 409 "CUCUMBER" 410 "PUMPKIN" 1800 "FODDER TREES" 1900 "FERTILIZER TREES" 2000 "FUEL WOOD TREES", modify
	label val crop_code relabel
	ren crop_code crop_code_long
	
	gen crop_code=crop_code_long //Generic level (without detail)
	recode crop_code (1 2 3 4=1)(5 6 7 8 9 10=5)(11 12 13 14 15 16=11)(17 18 19 20 21 22 23 24 25 26=17)
	la var crop_code "Generic level crop code"
	label define relabel2 /*these exist already*/ 1 "MAIZE" 5 "TOBACCO" 11 "GROUNDNUT" 17 "RICE" 28 "SWEET POTATO" 29 "IRISH [MALAWI] POTATO" 30 "WHEAT" 34 "BEANS" 35 "SOYABEAN" 36 "PIGEONPEA(NANDOLO" 37 "COTTON" 38 "SUNFLOWER" 39 "SUGAR CANE" 40 "CABBAGE" 41 "TANAPOSI" 42 "NKHWANI" 43 "THERERE/OKRA" 44 "TOMATO" 45 "ONION" 46 "PEA" 47 "PAPRIKA" 48 "OTHER (SPECIFY)"/*cleaning up these existing labels*/ 27 "GROUND BEAN (NZAMA)" 31 "FINGER MILLET (MAWERE)" 32 "SORGHUM" 33 "PEARL MILLET (MCHEWERE)" /*now creating unique codes for tree crops*/ 49 "CASSAVA" 50 "TEA" 51 "COFFEE" 52 "MANGO" 53 "ORANGE" 54 "PAWPAW/PAPAYA" 55 "BANANA" 56 "AVOCADO" 57 "GUAVA" 58 "LEMON" 59 "NAARTJE (TANGERINE)" 60 "PEACH" 61 "POZA (CUSTADE APPLE)" 62 "MASUKU (MEXICAN APPLE)" 63 "MASAU" 64 "PINEAPPLE" 65 "MACADEMIA" /*adding other specified crop codes*/ 105 "MAIZE GREEN" 203 "SWEET POTATO WHITE" 204 "SWEET POTATO ORANGE" 207 "PLANTAIN" 208 "COCOYAM (MASIMBI)" 301 "BEAN, WHITE" 302 "BEAN, BROWN" 308 "COWPEA (KHOBWE)" 405 "CHINESE CABBAGE" 409 "CUCUMBER" 410 "PUMPKIN" 1800 "FODDER TREES" 1900 "FERTILIZER TREES" 2000 "FUEL WOOD TREES", modify
	label val crop_code relabel2
	
		la var crop_code "Generic level crop code"
		drop if crop_code ==. //4509 obs deleted //ALT 11.18.22: this is now down to 33 obs deleted// now 7,943 obs deleted CG 3.4.2024

	* Create area variables
	gen crop_area_share=ag_g03 //rainy season // TH: this indicates proportion of plot with crop, but NGA crop_area_share indicates the unit (ie stands/ridges/heaps) that area was measured in; tree file did not ask about area planted
		label var crop_area_share "Proportion of plot planted with crop"
	replace crop_area_share=ag_m03 if crop_area_share==. & ag_m03!=. //crops dry season
	
	* Convert answers to proportions
	replace crop_area_share=0.125 if crop_area_share==1 // Less than 1/4
	replace crop_area_share=0.25 if crop_area_share==2 
	replace crop_area_share=0.5 if crop_area_share==3
	replace crop_area_share=0.75 if crop_area_share==4
	replace crop_area_share=.875 if crop_area_share==5 // More than 3/4 
	replace crop_area_share=1 if ag_g02==1 | ag_m02==1 //planted on entire plot for both rainy and dry season
	
	* Merge with plot_areas
	merge m:1 hhid case_id plot_id garden_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_areas.dta", keep(1 3) nogen //CWL: 8,467 not matches 35,826 matched //ALT 11.18.22: This is down to 437 not matched from master (not worried about using b/c we can presume those plots weren't cultivated)
	
	* Convert to hectares
	gen ha_planted=crop_area_share*area_meas_hectares
	replace ha_planted=crop_area_share*area_est_hectares if ha_planted==. & area_est_hectares!=. & area_est_hectares!=0
	replace ha_planted=ag_p02a* (1/2.47105) if ag_p02b==1 & ha_planted==. & (ag_p02a!=. & ag_p02a!=0 & ag_p02b!=0 & ag_p02b!=.)
	replace ha_planted=ag_p02a*(1/10000) if ag_p02b==3 & ha_planted==. & (ag_p02a!=. & ag_p02a!=0 & ag_p02b!=0 & ag_p02b!=.)
	save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_ha_planted.dta", replace
	
	drop crop_area_share 
	
	//TH: Malawi w2 doesn't ask about area harvested, only if area harvested was less than area planted (y/n, without numerical info). We assume area planted=area harvested bc no extra info 
	//CWL: assume the logic of Malawi w2 that assumes area harvest = area planted because not extra information
	
	* Hectares Harvested:
	gen ha_harvested = ha_planted // HS: 15,520 obs ha_harvested == .
	replace ha_harvested=ha_planted * ag_g11_2 if ag_g11_2!=. & ha_planted!=. 	
	
** TIME VARIABLES (month planted, harvest, and length of time grown)
	* MONTH planted
		gen month_planted = ag_g05a // HS: "when [what month] did you plant the seeds...during the rainy season"
		replace month_planted = ag_m05a if month_planted==.
		lab var month_planted "Month of planting"
		
	* YEAR planted
		//codebook ag_m05b // YEAR
		//codebook ag_g05b // YEAR
		//drop if ag_m05b < 2018 
		//CWL:question asked about dry season in 2018/2019, dropping responses not in in this range - there are handful in 2001-2017
		//drop if ag_g05b < 2017 
		//There are  8,749 obs in 2017 - not dropping because it's larger
		//CWL-QUESTION: should we drop regardless?
		//ALT 11.18.22: All temporary crop production should be relevant to the survey period, so we should only be dropping tree crops whose production period ended before the survey target season. Those early plantings are headscratchers, though. I'm going to assume typos, although some are sugarcane, which can be grown as a perennial crop.
		//drop if ag_p06a < 2017 // "What was the last completed production period for the tree/permanent crop"
			* Drops 7,872 obs // HS: confused about why it drops years if its a month variable (even if its a factor)
		gen year_planted1 = ag_g05b // "When did you plant the seeds for [CROP] on this [PLOT] during the RAINY SEASON"
		gen year_planted2 = ag_m05b // HS. other season
		gen year_planted = year_planted1 // HS. Consolidate year_planted for both seasons
		replace year_planted= year_planted2 if year_planted==. // HS. Consolidate year_planted for both seasons
		lab var year_planted "Year of planting"
		
		
	* MONTH harvest started
		gen harvest_month_begin = ag_g12a
		replace harvest_month_begin=ag_m12a if harvest_month_begin==. & ag_m12a!=. //MGM: 0 changes made. Something seems to be going continually wrong the dry season data. Not a lot of information there. //ALT: Harvest data may not be available for many dry season plots because the survey was being conducted during the harvest period.
		lab var harvest_month_begin "Month of start of harvesting"
		
	* MONTH harvest ended
		gen harvest_month_end=ag_g12b
		replace harvest_month_end=ag_m12b if harvest_month_end==. & ag_m12b!=.
		lab var harvest_month_end "Month of end of harvesting"
		
		
	* MONTHS crop grown
		gen months_grown = harvest_month_begin - month_planted if harvest_month_begin > month_planted  // since no year info, assuming if month harvested was greater than month planted, they were in same year 
		replace months_grown = 12 - month_planted + harvest_month_begin if harvest_month_begin < month_planted // months in the first calendar year when crop planted 
		replace months_grown = 12 - month_planted if months_grown<1 // reconcile crops for which month planted is later than month harvested in the same year
		replace months_grown=. if months_grown <1 | month_planted==. | harvest_month_begin==.
		lab var months_grown "Total months crops were grown before harvest"

	//MGM 5.31.23 adding this - note for MWI team to add to their Waves too!
	//Plot workdays
	preserve
	gen days_grown = months_grown*30 
	collapse (max) days_grown, by(case_id hhid garden_id plot)
	save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_season_length.dta", replace
	restore
		
	* YEAR HARVESTED 
			*TH: survey did not ask for harvest year, see/ check assumptions for year:
		*MGM: 4.17.2023 - inferring harvest year from month_planted, year_planted, harvest_month_begin, and months_grown
		//all observations of months_grown less than or equal to 11 months. Hence, the following code:
		gen year_harvested=year_planted if harvest_month_begin>month_planted
		replace year_harvested=year_planted+1 if harvest_month_begin<month_planted
		replace year_harvested=. if year_planted!=2007 & year_planted!=2008 & year_planted!=2009 & year_planted!=2010 //choosing not to infer year_harvested from observations with obscure planting years instead of dropping observations with obscure planting years
		//lab var year_harvested "Year of harvesting
		
		
	* DATE PLANTED
		//CWL-QUESTION: do we need the date_planted?
		gen date_planted = mdy(month_planted, 1, ag_g05b) if ag_g05b!=. // where ag_g05b is year planted (rainy)
		/* replace date_planted = mdy(month_planted-12, 1, ag_g05b) if month_planted>12 & ag_g05b!=. // 0 changes bc month_planted is always < 12
		replace date_planted = mdy(month_planted-12, 1, ag_m05b) if month_planted>12 & ag_m05b!=. // 0 changes bc month_planted is always < 12 */
		replace date_planted = mdy(month_planted, 1, ag_m05b) if date_planted==. & ag_m05b!=. // if no date planted and year_planted_ds is not empty
		
		
	* DATE HARVESTED 
		* Section coded by HS/MGM 4.23; not checked
		gen date_harvested = mdy(harvest_month_begin, 1, ag_g05b) if ag_g05b==2010
		replace date_harvested = mdy(harvest_month_begin, 1, ag_m05b) if date_harvested==. & ag_m05b==2010
		replace date_harvested = mdy(harvest_month_begin, 1, ag_g05b) if month_planted<=12 & harvest_month_begin>month_planted & date_harvest==. & ag_g05b!=. //assuming if planted in 2010 and month harvested is later than planted, it was harvested in 2010
		replace date_harvested = mdy(harvest_month_begin, 1, ag_m05b) if month_planted<=12 & harvest_month_begin>month_planted & date_harvest==. & ag_m05b!=.
		replace date_harvested = mdy(harvest_month_begin, 1, ag_g05b+1) if month_planted<=12 & harvest_month_begin<month_planted & date_harvest==. & ag_g05b!=.
		replace date_harvested = mdy(harvest_month_begin, 1, ag_m05b+1) if month_planted<=12 & harvest_month_begin<month_planted & date_harvest==. & ag_m05b!=.

	* Calculate days of growth
	format date_planted %td
	format date_harvested %td
	gen days_grown=date_harvest-date_planted // 647 missing values
	
	* Calculate overlap date (of harvesting and planting)
	bys plot hhid : egen min_date_harvested = min(date_harvested)
	bys plot hhid : egen max_date_planted = max(date_planted)
	gen overlap_date = min_date_harvested - max_date_planted 

 	//ALT: Need to remember garden_id here
	* Generate crops_plot variable for number of crops per plot. 
		* This is used to fix issues around intercropping and relay cropping being reported inaccurately for our purposes.
	preserve
		gen obs=1
		replace obs=0 if ag_g13a==0 | ag_m11a==0 | ag_p09a==0  
		//obs=0 if no crops were harvested; 
		collapse (sum) crops_plot = obs, by(hhid case_id garden_id plot season)
		tempfile ncrops
		save `ncrops'
	restore
	merge m:1 hhid garden_id plot season using `ncrops', nogen /// HKS 5/10/23: 43,766 matched
		
		
	* Generating Monocropped Plot Variables (pt 1)
		bys hhid plot garden_id season: egen crops_avg = mean(crop_code) //checks for diff versions of same crop in the same plot
		gen purestand = 1 if crops_plot==1 | crops_avg == crop_code //HKS 5/3/23: 28k missing values 
		gen perm_crop=1 if ag_p0c!=. // HS 2.14.23: 35,880 missing values
		bys hhid garden_id plot: egen permax = max(perm_crop) // HS 2.14.23: 35,880 missing
			//ALT: Seems like the number of permanet crops recorded in this wave dropped off quite a bit - something maybe to follow up on later.
		
	* Checking for relay-cropping; Generally does not occur in Malawi
		bys hhid plot month_planted year_planted : gen plant_date_unique=_n
		bys hhid plot harvest_month_begin : gen harv_date_unique=_n //TH: survey does not ask year of harvest for crops
		bys hhid plot : egen plant_dates = max(plant_date_unique)
		bys hhid plot : egen harv_dates = max(harv_date_unique) 
	
		replace purestand=0 if (crops_plot>1 & (plant_dates>1 | harv_dates>1))  | (crops_plot>1 & permax==1)  
		//ALT 2.2023: At this point, roughly 30% of plots are purestand, which seems fairly reasonable given the strictness of our criteria.
		gen any_mixed=!(ag_g01==1 | ag_m01==1 | (perm_crop==1 & purestand==1)) 
		bys hhid plot : egen any_mixed_max = max(any_mixed)
		replace purestand=1 if crops_plot>1 & plant_dates==1 & harv_dates==1 & permax==0 & any_mixed_max==0 // HS 2.14.23: 0 changes
		
		replace purestand=1 if crop_code_long==crops_avg
		replace purestand=0 if purestand==.
		drop crops_plot crops_avg plant_dates harv_dates plant_date_unique harv_date_unique permax
	
	* QUANTITY HARVESTED
	ren ag_g13a quantity_harvested
	replace quantity_harvested = ag_m11a if quantity_harvested==. & ag_m11a !=.
	replace quantity_harvested = ag_p09a if quantity_harvested==. & ag_p09a !=. // Tree/Permanent crops
	
	* 07.10.23 from NGA
	ren ag_g13_1 val_harvest_est
	gen val_unit_est = val_harvest_est/quantity_harvested
	
	*** Rescaling plots 
	replace ha_planted = ha_harvest if ha_planted==. //HKS 5/3/23: 0 changes
	
	* Let's first consider that planting might be misreported but harvest is accurate
	replace ha_planted = ha_harvest if ha_planted > area_meas_hectares & ha_harvest < ha_planted & ha_harvest!=. //HKS 5/3/23: 0 changes
	gen percent_field=ha_planted/area_meas_hectares
	
	* Generating total percent of purestand and monocropped on a field
	bys hhid plot: egen total_percent = total(percent_field)
	replace percent_field = percent_field/total_percent if total_percent>1 & purestand==0
	replace percent_field = 1 if percent_field>1 & purestand==1
	replace ha_planted = percent_field*area_meas_hectares 
	replace ha_harvest = ha_planted if ha_harvest > ha_planted

	* UNIT HARVESTED
	ren ag_g13b unit // Rainy season units
	replace unit = ag_m11b if unit==. & ag_m11b !=. 
	replace unit = ag_p09b if unit==. & ag_p09b !=. // 0 changes
	lab define ag_g13b 3 "90 KG BAG" 11 "BASKET (DENGU)" 14 "PAIL (MEDIUM)" 98 "HEAP", add //TH: adding units from conversion file to merge 4/29
	
	* OTHER SPECIFIED CROPS
	ren ag_g0e_1_oth crop_code_os //this variable can provide us with a little bit more information about other specified crops in the rainy season
	replace crop_code_os=ag_m0e_oth if crop_code_os=="" & ag_m0e_oth!="" //dry - 2 real changes
	replace crop_code_os=ag_p0d_oth if crop_code_os=="" & ag_p0d_oth!="" //tree - 33 real changes
	replace crop_code_long=39 if strmatch(crop_code_os, "SUGAR CANE") //6 changes 
	replace crop_code_long=52 if strmatch(crop_code_os, "MANGO") //1 change 
	
	* OTHER SPECIFIED UNITS
	ren ag_g13b_oth unit_os
	replace unit_os=ag_m11b_oth if unit_os=="" | ag_m11b_oth!="" //dry - 284 real changes
	replace unit_os=ag_p09b_oth if unit_os=="" | ag_p09b_oth!="" //tree - 14 real changes
	replace unit=2 if strmatch(unit_os, "50Kg Bag") | strmatch(unit_os, "50kg bag") | strmatch(unit_os, "50KG BAG") // 6 changes 
	replace unit=3 if strmatch(unit_os, "90 KG BAD") | strmatch(unit_os, "90 KG BAG") | strmatch(unit_os, "90 Kg bags") | strmatch(unit_os, "90 kg Bag") | 	strmatch(unit_os, "90 kg bag") | strmatch(unit_os, "90 kg bags") | strmatch(unit_os, "90KG BAG") | strmatch(unit_os, "90KG Bag") | strmatch(unit_os, "90Kg bag") | strmatch(unit_os, "90kg bag") | strmatch(unit_os, "90kg bags") | strmatch(unit_os, "BAGS OF 90 KGS") | strmatch(unit_os, "90 KG BAG") // 216 changes 
	replace unit=4 if strmatch(unit_os, "SMALL PAIL") | strmatch(unit_os, "PAIL SMALL") //2 changes 
	replace unit=5 if strmatch(unit_os, "Large pail") | strmatch(unit_os, "Pail Large") | strmatch(unit_os, "large pail") | strmatch(unit_os, "BIG BUCKETS") | strmatch(unit_os, "BIG PAIL") //8 changes 
	replace unit=8 if strmatch(unit_os, "BUNCH") //1 change
	replace unit=9 if strmatch(unit_os, "PIECES") //2 changes
	replace unit=11 if strmatch(unit_os, "BASKET") | strmatch(unit_os, "BASKET (DENGU)") | strmatch(unit_os, "BASKET DENGU") | strmatch(unit_os, "BASKET OF NKHWANI LEAVES") | 	strmatch(unit_os, "BASKET OF VEGETABLES ONLY NOT PUMPKINS") | strmatch(unit_os, "BASKET(DENGU)") | strmatch(unit_os, "BASKETS") | strmatch(unit_os, "Basket") | strmatch(unit_os, "Basket ( dengu )") | strmatch(unit_os, "Basket ( dengu)") | strmatch(unit_os, "Basket (dengu)") | strmatch(unit_os, "DENGU") | strmatch(unit_os, "Dengu") | strmatch(unit_os, "Dengu ( basket )") | strmatch(unit_os, "LARGE BASKET") | strmatch(unit_os, "MEDIUM MTANGA") | strmatch(unit_os, "SMALL BASKET") | strmatch(unit_os, "basket") | strmatch(unit_os, "basket (dengue)") | strmatch(unit_os, "baskets") | strmatch(unit_os, "dengu") | strmatch(unit_os, "dengu(gogoda)") | strmatch(unit_os, "large basket") | strmatch(unit_os, "BASKET (UNSPECIFIED)")  | strmatch(unit_os, "BIG DENGU") | strmatch(unit_os, "BIG WEAVED BASKET (DENGU)") | strmatch(unit_os, "BIG WEAVED BASKETS") | strmatch(unit_os, "DENGU (GOGODA)") | strmatch(unit_os, "DENGU /BUSKET") | strmatch(unit_os, "DENGU LIMODZI") | strmatch(unit_os, "LARGE BASKET (DENGU)") | strmatch(unit_os, "LARGE BASKETS") | strmatch(unit_os, "SMALL DENGU") | strmatch(unit_os, "WAVED BASKET") | strmatch(unit_os, "WEAVED BASKET(DENGU)") | strmatch(unit_os, "WEAVING BASKET") | strmatch(unit_os, "BIG BUCKETS") | strmatch(unit_os, "BIG BUCKETS") | strmatch(unit_os, "BIG BUCKETS") | strmatch(unit_os, "BIG BUCKETS") | strmatch(unit_os, "BIG BUCKETS") // 292 changes 
	replace unit=12 if strmatch(unit_os, "oxcrart") //1 change 
	
	replace quantity_harvested = quantity_harvested*9 if strmatch(unit_os, "09kg bag") // 1 change 
	replace unit=1 if strmatch(unit_os, "09kg bag") //1 change 
	replace quantity_harvested = quantity_harvested*90 if strmatch(unit_os, "1 90 KG") // 1 change 
	replace unit=1 if strmatch(unit_os, "1 90 KG") //1 change 
	replace quantity_harvested = quantity_harvested*120 if strmatch(unit_os, "120 KG BAGS") | strmatch(unit_os, "120 KG BAG") | strmatch(unit_os, "120KG BAG") // 7 changes 
	replace unit=1 if strmatch(unit_os, "120 KG BAGS") | strmatch(unit_os, "120 KG BAG") | strmatch(unit_os, "120KG BAG") //7 changes 
	replace quantity_harvested = quantity_harvested*45 if strmatch(unit_os, "45kg") // 1 change 
	replace unit=1 if strmatch(unit_os, "45kg") //1 change 
	replace quantity_harvested = quantity_harvested*60 if strmatch(unit_os, "60KG") | strmatch(unit_os, "60KG BAG") | strmatch(unit_os, "60kg") // 3 changes
	replace unit=1 if strmatch(unit_os, "60KG") | strmatch(unit_os, "60KG BAG") | strmatch(unit_os, "60kg") //3 change 
	replace quantity_harvested = quantity_harvested*70 if strmatch(unit_os, "70 KG BAG") | strmatch(unit_os, "70 KG BAGS") | strmatch(unit_os, "70 KG Bags") | strmatch(unit_os, "70 KGS") | strmatch(unit_os, "70 kg bag") | strmatch(unit_os, "70 kg bags") | strmatch(unit_os, "70KG BAG") | strmatch(unit_os, "70Kg") | strmatch(unit_os, "70kg") | strmatch(unit_os, "70kg bag") | strmatch(unit_os, "70kg bags") | strmatch(unit_os, "70 KG") | strmatch(unit_os, "70 KG BAG") //78 changes 
	replace unit=1 if strmatch(unit_os, "70 KG BAG") | strmatch(unit_os, "70 KG BAGS") | strmatch(unit_os, "70 KG Bags") | strmatch(unit_os, "70 KGS") | strmatch(unit_os, "70 kg bag") | strmatch(unit_os, "70 kg bags") | strmatch(unit_os, "70KG BAG") | strmatch(unit_os, "70Kg") | strmatch(unit_os, "70kg") | strmatch(unit_os, "70kg bag") | strmatch(unit_os, "70kg bags") | strmatch(unit_os, "70 KG") | strmatch(unit_os, "70 KG BAG") //78 changes 
	replace quantity_harvested = quantity_harvested*75 if strmatch(unit_os, "75 kg bags") // 2 changes 
	replace unit=1 if strmatch(unit_os, "75 kg bags") //2 changes 
	replace quantity_harvested = quantity_harvested*80 if strmatch(unit_os, "80 kg bags") | strmatch(unit_os, "80KG BAG") // 2 changes
	replace unit=1 if strmatch(unit_os, "80 kg bags") | strmatch(unit_os, "80KG BAG") //2 changes
	replace quantity_harvested = quantity_harvested*90 if strmatch(unit_os, "90 KGS") | strmatch(unit_os, "90 kg") | strmatch(unit_os, "90KGS") | strmatch(	unit_os, "90KGs") | strmatch(unit_os, "90kg") //14 changes 
	replace unit=1 if strmatch(unit_os, "90 KGS") | strmatch(unit_os, "90 kg") | strmatch(unit_os, "90KGS") | strmatch(	unit_os, "90KGs") | strmatch(unit_os, "90kg")  //14 changes 
	replace quantity_harvested = quantity_harvested*25 if strmatch(unit_os, "bags and 25kg") | strmatch(unit_os, "bags and 25kilogram") //2 changes 
	replace unit=1 if strmatch(unit_os, "bags and 25kg") | strmatch(unit_os, "bags and 25kilogram")  //2 changes 
	replace quantity_harvested = quantity_harvested*.5 if strmatch(unit_os, "HALF OXCART") // 1 change 
	replace unit=12 if strmatch(unit_os, "HALF OXCART") //1 change 
		
	* Merge in HH module A to bring in region info 
	merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hhids.dta", nogen keep(1 3) // HKS 5/5/23: 43,766 obs matched; CG: 1/16/2024: all obs matched
	
	* Rename condition vars in master to match using file 
	replace condition=ag_g13c if condition==. // 39,982 changes 
	replace condition=ag_m11c if condition==. //3,453 changes
	replace condition=ag_p09_1 if condition==. //170 changes	
	replace condition=3 if condition==. //2,916 changes
	lab define condition 1 "S: SHELLED" 2 "U: UNSHELLED" 3 "N/A", modify 
	lab val condition condition 
	
***** CONVERSION FACTORS ***** 
//ren crop_code crop_code_long
	capture confirm file "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_cf.dta"
	if !_rc {
	merge m:1 region crop_code_long unit condition using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_cf.dta", keep(1 3) gen(cf_merge) //HS 2.27.23: 32,228 matched; 3,666 not matched, 0 matches 1/29/2024, 29,892 matched 1.30.2024, 39,476 matched 1.31.24
	// TH: no conversion data for tree crops; tree crop n=7886; unit==. n=5514; crop_code==. n=2718
	//ALT 11.18.22: Main source of unmatched is now g and kg; make sure to fill those in before converting. Outstanding after that is "Tina" under "other" category. 
} 
	else {
 di as error "Updated conversion factors file not present; harvest data will likely be incomplete"
	}

	*Multiply quantity by conversion factors to convert everything into kgs
	gen quant_harv_kg= quantity_harvested*conversion 
	
//	preserve
//	keep quant_harv_kg crop_code_long crop_code case_id plot_id season
//	save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_yield_1_31_24.dta", replace
//	restore	
	
merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_weights.dta", nogen keep (1 3) // 47,937 matched

foreach i in ea ta district region hhid {
	merge m:1 `i' crop_code_long unit using `price_unit_`i'_median', nogen keep(1 3)
	}
merge m:1 unit crop_code_long using `price_unit_country_median', nogen keep(1 3)

gen value_harvest = price_unit_hhid*quantity_harvested
gen missing_price = value_harvest == .
foreach i in region district ta ea { //decending order from largest to smallest geographical figure
replace value_harvest = quantity_harvested*price_unit_`i' if missing_price == 1 & obs_`i' > 9 & obs_`i' != . 
}
replace value_harvest = quantity_harvested * price_unit_country if value_harvest==.

	gen val_unit = value_harvest/quantity_harvested
	gen val_kg = value_harvest/quant_harv_kg 
	
	gen plotweight = ha_planted*conversion 
	gen obs=quantity_harvested>0 & quantity_harvested!=.
	
preserve
	collapse (mean) val_kg, by (hhid case_id crop_code)
	ren val_kg hh_price_mean
	lab var hh_price_mean "Average price reported for kg in the household"
	save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_crop_prices_for_wages.dta", replace
restore


//preserve
//collapse (median) val_unit_country = val_unit (sum) obs_country_unit=obs [aw=plotweight], by(crop_code unit)
//save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_crop_prices_median_country.dta", replace //This gets used for self-employment income. 
//restore
	
//AgQuery
	collapse (sum) quant_harv_kg ha_planted ha_harvest value_harvest number_trees_planted percent_field (max) months_grown, by(region district ea hhid case_id plot_id garden_id crop_code crop_code_long purestand area_meas_hectares season) // HKS 5/5/23: copied from W1, added garden_id, HHID
	bys hhid case_id plot_id garden_id: egen percent_area = sum(percent_field) // HKS 5/5/23: copied from W1, added garden_id, HHID
	bys hhid case_id plot_id garden_id: gen percent_inputs = percent_field/percent_area // HKS 5/5/23: copied from W1, added garden_id, HHID
	drop percent_area //Assumes that inputs are +/- distributed by the area planted. Probably not true for mixed tree/field crops, but reasonable for plots that are all field crops
	//Labor should be weighted by growing season length, though. 
	
	drop if crop_code==. 
merge m:1 hhid case_id plot_id garden_id season using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_decision_makers.dta",  nogen keep(1 3) keepusing(dm_gender) // 46,290 matched, 1,627 not matched

**# Bookmark #3 - check again once PDM is updated
	
	save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_all_plots.dta", replace

	
/*old code... delete?
	merge m:1 hhid crop_code unit using `value_harvest_data', keepusing(value_harvest) // HS 08.08.23: 48,481 unmatched from master - not sure why

	gen val_unit = value_harvest/quantity_harvested // HKS 08.08.23: swapped "val_harvest_est" out for "value_harvest"
	gen val_kg = value_harvest/quant_harv_kg // HKS 08.08.23: swapped "val_harvest_est" out for "value_harvest"
	
	
	gen plotweight = ha_planted*weight
	gen obs=quantity_harvested>0 & quantity_harvested!=. 
		
foreach i in ea ta district region hhid { 
preserve
	bys crop_code `i' : egen obs_`i'_kg = sum(obs)
	collapse (median) val_kg_`i'=val_kg  [aw=plotweight], by (`i' crop_code obs_`i'_kg)
	tempfile val_kg_`i'_median
	save `val_kg_`i'_median'
restore
}		
	
preserve
collapse (median) val_kg_country = val_kg (sum) obs_country_kg=obs [aw=plotweight], by(crop_code)
tempfile val_kg_country_median
save `val_kg_country_median'
restore
	
foreach i in ea ta district region hhid  {
preserve
	bys `i' crop_code unit : egen obs_`i' = sum(obs)
	collapse (median) val_unit_`i'=val_unit (sum) obs_`i'_unit=obs  [aw=plotweight], by (`i' unit crop_code)
	tempfile val_unit_`i'_median
	save `val_unit_`i'_median'
restore
	merge m:1 `i' unit crop_code using `price_unit_`i'_median', nogen keep(1 3)
	merge m:1 `i' unit crop_code using `val_unit_`i'_median', nogen keep(1 3)
	merge m:1 `i' crop_code using `val_kg_`i'_median', nogen keep(1 3)
}

preserve
collapse (median) val_unit_country = val_unit (sum) obs_country_unit=obs [aw=plotweight], by(crop_code unit)
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_crop_prices_median_country.dta", replace //This gets used for self-employment income.
restore
	
merge m:1 unit crop_code using `price_unit_country_median', nogen keep(1 3) 
merge m:1 unit crop_code using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_crop_prices_median_country.dta", nogen keep(1 3)
merge m:1 crop_code using `val_kg_country_median', nogen keep(1 3)


//We're going to prefer observed prices first
foreach i in region district ta ea {
	replace val_unit = price_unit_`i' if obs_`i'_price>9
	replace val_kg = val_kg_`i' if obs_`i'_kg >9
}
	gen val_missing = val_unit==.
	replace val_unit = price_unit_hhid if price_unit_hhid!=.
	
	
foreach i in region district ta ea {
	replace val_unit = val_unit_`i' if obs_`i'_unit > 9 & val_missing==1
} 
	replace val_unit = val_unit_hhid if val_unit_hhid!=. & val_missing==1
	replace val_kg = val_kg_hhid if val_kg_hhid!=. //Preferring household values where available.
//All that for these two lines:
	replace val_harvest_est=val_unit*quantity_harvested if val_harvest_est==.
	*replace value_harvest=val_kg*quant_harv_kg if value_harvest==. // HKS 08.08.2023: Value harvest does not exist at this point
	
	//Replacing conversions for unknown units
*replace val_unit = val_harvest_est/quantity_harvested if val_unit==. // HKS 08.08.23: I believe I had (in error) previously replaced many "value_harvest" with "val_harvest_est"; now that I've generated value_harvest, rework the code accordingly:
	drop val_unit
	gen val_unit = value_harvest/quantity_harvested
	*gen val_kg = value_harvest/quant_harv_kg */


***** CALORIC CONVERSION ***** 
// Add calories if the prerequisite caloric conversion file exists
	capture {
		confirm file `"${MWI_IHS_IHPS_W4_raw_data}/caloric_conversionfactor_crop_codes.dta"' 
	} 
	if _rc!=0 {
		display "Note: file ${MWI_IHS_IHPS_W4_raw_data}/caloric_conversionfactor_crop_codes.dta does not exist - skipping calorie calculations"		
	}
	if _rc==0{
		//ren calories_100g-edible_fraction {, cal_100g edible_p} this line of code may be needed
		gen calories=.
*		gen calories_100g=. // HKS 5/5/23: this isn't doing anything, isn't used
*		gen edible_fraction=1 // HKS 5/5/23: this isn't doing anything, isn't used; edible_portion already exists
		merge m:1 crop_code_short condition using "${MWI_IHS_IHPS_W4_raw_data}/caloric_conversionfactor_crop_codes.dta", nogen keep(1 3)
				*ren  crop_code_short crop_code
				// HS 5/5/23: 42,208 obs not matching; only 3749 matching; seems pretty extreme...
	
		// logic for units: calories / 100g * kg * 1000g/kg * edibe perc * 100 / perc * 1/1000 = cal
		replace calories = cal_100g * quant_harv_kg * edible_p / 1000
		count if missing(calories) // HKS 5/5/23: missing 44,278
	}
	
********************************************************************************
* CONVERSION FACTOR SCRIPT * - development purposes only, do not run as external user
******************************************************************************** 
*/*HARVESTED CROPS*
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_g.dta", clear 
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_m.dta" 
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_p.dta"
	
* units_os 
	ren ag_g13b_oth unit_os //rainy unit_os harvested
	replace unit_os = ag_m11b_oth if unit_os == "" & ag_m11b_oth != "" //dry unit_os harvested
	replace unit_os = ag_p09b_oth if unit_os == "" & ag_p09b_oth != "" //tree/perm unit harvested
	
	keep unit_os
	gen dummy = 1
	collapse (sum) dummy, by(unit_os)
	tempfile unit_os_harv
	save `unit_os_harv'

*SOLD CROPS*
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_i.dta", clear 
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_o.dta" 
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_q.dta"

//CONVERT BYTES TO STRINGS
tostring ag_i21b_oth, format(%19.0f) replace //was byte
tostring ag_o21b_oth, format(%19.0f) replace //was byte
tostring ag_q21b_oth, format(%19.0f) replace //was byte

* units_os0 - all buyers
	ren ag_i02b_oth unit_os0 //rainy unit_os sold all buyers
	// replace unit_os0 = ag_o02b_oth if unit_os0 == "" & ag_o02b_oth != "" //dry unit_os unit_os sold all buyers //no os variable 
	replace unit_os0= ag_q02b_oth if unit_os0 == "" & ag_q02b_oth != "" //tree/perm unit_os sold all buyers
	
* units_os1 - first largest buyer
	ren ag_i12b_oth unit_os1 //rainy unit_os sold largest buyer
	replace unit_os1 = ag_o12b_oth if unit_os1 == "" & ag_o12b_oth != "" //dry unit_os sold largest buyer
	replace unit_os1= ag_q12b_oth if unit_os1 == "" & ag_q12b_oth != "" //tree/perm unit unit_os sold largest buyer
	
* units_os2 - second largest buyer
	ren ag_i21b_oth unit_os2 //rainy unit_os sold second largest buyer
	replace unit_os2 = ag_o21b_oth if unit_os2 == "" & ag_o21b_oth != "" //dry unit_os sold second largest buyer
	replace unit_os2= ag_q21b_oth if unit_os2 == "" & ag_q21b_oth != "" //tree/perm unit_os sold second largest buyer
	
/* units_os3 - third largest buyer //no questions for W4
	ren ag_i30b_os unit_os3 //rainy unit_os sold third largest buyer
	replace unit_os3 = ag_o30b_os if unit_os3 == "" & ag_o30b_os != "" //dry unit_os sold third largest buyer
	replace unit_os3= ag_q30b_os if unit_os3 == "" & ag_q30b_os != "" //tree/perm unit_os sold third largest buyer */
	
	keep unit_os*
	gen dummya = _n //creates a unique number for each observation - required for the reshape
	reshape long unit_os, i(dummya) j(buyer)
	keep unit_os
	gen dummy = 1
	collapse (sum) dummy, by(unit_os)
	tempfile unit_os_sold
	save `unit_os_sold'
	append using `unit_os_harv'
	collapse (sum) dummy, by(unit_os)
	save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_unit_os.dta", replace*/

************************************************
*CROP EXPENSES
************************************************
/* Explanation of changes
MGM transferring notes from ALT: This section has been formatted significantly differently from previous waves and the Tanzania template file (see also NGA W3 and TZA W3-5).
Previously, inconsistent nomenclature forced the complete enumeration of variables at each step, which led to accidental omissions messing with prices.
This section is designed to reduce the amount of code needed to compute expenses and ensure everything gets included. We accomplish this by 
taking advantage of Stata's "reshape" command to take a wide-formatted file and convert it to long (see help(reshape) for more info). The resulting file has 
additional columns for expense type ("input") and whether the expense should be categorized as implicit or explicit ("exp"). This allows simple file manipulation using
collapse rather than rowtotal and can easily be converted back into our standard "wide" format using reshape. 
*/


	*********************************
	* 			LABOR				*
	*********************************
	* Crop Payments: rainy
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_d.dta", clear 
	
	ren gardenid garden_id
	ren plotid plot_id
	ren ag_d46c qty 
	ren ag_d46f crop_code 
	replace crop_code=49 if strmatch(ag_d46f_oth, "CASSAVA")
	ren ag_d46f_oth crop_name 
	ren ag_d46d unit 
	ren ag_d46d_oth unit_desc  
	replace unit=10 if strpos(unit_desc, "70 KG BAG")
	replace unit=11 if strpos(unit_desc, "90KG BAG")
	replace unit=12 if strpos(unit_desc, "5LITRE BUCKET (CHIGOBA)")
	ren ag_d46e condition
	keep hhid case_id garden_id plot_id crop_code crop_name qty unit condition
	gen season= 0
tempfile rainy_crop_payments
save `rainy_crop_payments'
				
	*Crop payments: dry
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_k.dta", clear 
	
	ren gardenid garden_id
	ren plotid plot_id
	ren ag_k46c crop_code 
	ren ag_k46d qty
	ren ag_k46e unit 
	ren ag_k46f condition 
	keep case_id hhid garden_id plot_id crop_code qty unit condition
	gen season= 1 
tempfile dry_crop_payments
save `dry_crop_payments'
	
	//Not including in-kind payments as part of wages b/c they are not disaggregated by worker gender (but including them as an explicit expense at the end of the labor section), combining dry & rainy payments here 
use `rainy_crop_payments', clear
	append using `dry_crop_payments'
	lab var season "season: 0=rainy, 1=dry, 2=tree crop"
	label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
	label values season season 
	recast str50 hhid, force
	merge m:1 case_id hhid crop_code using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_crop_prices_for_wages.dta", nogen keep (1 3) //275 matched
	recode qty hh_price_mean (.=0)
	gen val = qty*hh_price_mean
	keep case_id hhid val garden_id plot_id
	gen exp = "exp"
	merge m:1 hhid case_id plot_id garden_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_decision_makers.dta", nogen keep (1 3) keepusing(dm_gender) //25,955 matched, 63 not matched
	tempfile inkind_payments
	save `inkind_payments'
	

	*Hired rainy		
local qnums "46 47 48" 		
foreach q in `qnums' {
    use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_d.dta", clear
	ren gardenid garden_id
	
	ren plotid plot_id
	merge m:1  hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta"
	ren ag_d`q'a1 dayshiredmale
	ren ag_d`q'a2 dayshiredfemale 
	ren ag_d`q'a3 dayshiredchild 
	ren ag_d`q'b1 wagehiredmale
	ren ag_d`q'b2 wagehiredfemale
	ren ag_d`q'b3 wagehiredchild

	capture ren ta ta
	keep region district ta ea_id rural hhid case_id garden_id plot_id *hired*
	ren ea_id ea
	gen season=0 
    local suffix ""
    if `q' == 46 {
        local suffix "_all"
		gen period="all"
    }
    else if `q' == 47 {
        local suffix "_nonharvest"
		gen period="harv-nonharv"
    }
    else if `q' == 48 {
        local suffix "_harvest"
		gen period="harv-nonharv"
    }
    tempfile rainy_hired`suffix'
    save `rainy_hired`suffix'', replace
}

	*Hired dry
	//MGM: Unlike the rainy season, the survey instrument does not delineate between all, non-harvest, and harvest for hired labor during the dry season, hence no loop needed
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_k.dta", clear 
	
	merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta" , nogen
	ren plot plot_id
	ren gardenid garden_id
	ren ag_k46a1 dayshiredmale 
	ren ag_k46a2 dayshiredfemale
	ren ag_k46a3 dayshiredchild
	ren ag_k46b1 wagehiredmale
	ren ag_k46b2 wagehiredfemale
	ren ag_k46b3 wagehiredchild
	ren ta ta
	keep region district ta rural hhid case_id plot_id garden_id *hired* 
	gen season= 1
tempfile dry_hired_all
save `dry_hired_all' 

	use `rainy_hired_all'
	append using `dry_hired_all'
	lab var season "season: 0=rainy, 1=dry, 2=tree crop"
	label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
	label values season season 
	duplicates report region district ta ea hhid case_id plot_id season
	duplicates tag region district ta ea hhid case_id garden_id plot_id season, gen(dups)
	
	duplicates drop region district ta ea case_id hhid garden_id plot_id season, force
	drop dups
	reshape long dayshired wagehired, i(region district ta ea case_id hhid garden_id plot_id season) j(gender) string //fix zone state etc.
	reshape long days wage, i(region district ta ea case_id hhid garden_id plot season gender) j(labor_type) string	
	recode wage days (.=0) 
	drop if wage==0 & days==0 //127,545 observations deleted
	gen val = wage*days
	
	* fill in missing eas
	gsort hhid case_id  -ea
	replace ea = ea[_n-1] if ea == ""	

/* HKS 09.04.23, copied comment from MGM: The Malawi W4 instrument did not ask survey respondents to report number of laborers per day by laborer type. As such, we cannot say with certainty whether survey respondents reported wages paid as [per SINGLE hired laborer by laborer type (male, female, child) per day] or [per ALL hired laborers by laborer type (male, female, child) per day]. Looking at the collapses and scatterplots, it would seem that survey respondents had mixed interpretations of the question, making the value of hired labor more difficult to interpret. As such, we cannot impute the value of hired labor for observations where this is missing, hence the geographic medians section is commented out. */ 

tempfile all_hired
save `all_hired'

	*Exchange rainy
local qnums "50 52 54" 
foreach q in `qnums' {
    use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_d.dta", clear
		
	ren plotid plot_id
	ren gardenid garden_id
	merge m:1 hhid  using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", nogen
	ren ag_d`q'a daysnonhiredmale
	ren ag_d`q'b daysnonhiredfemale
	ren ag_d`q'c daysnonhiredchild
			ren ta ta
	keep region district ta ea rural case_id hhid plot_id garden_id daysnonhired*
	gen season= 0
    local suffix ""
    if `q' == 50 {
        local suffix "_all"
    }
    else if `q' == 52 {
        local suffix "_nonharvest"
    }
    else if `q' == 54 {
        local suffix "_harvest"
    }
	//duplicates drop  region district ta ea rural hhid garden_id plot_id season, force //0 duplicates deleted
	reshape long daysnonhired, i(region district ta ea rural hhid garden_id plot_id season) j(gender) string
	//reshape long days, i(region stratum district ta ea rural case_id plot_id season gender) j(labor_type) string
    tempfile rainy_exchange`suffix'
    save `rainy_exchange`suffix'', replace
}

	*Exchange dry
    use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_k.dta", clear
	ren gardenid garden_id
	ren plotid plot_id
	merge m:1 hhid  using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", nogen
	ren ag_k47a daysnonhiredmale
	ren ag_k47b daysnonhiredfemale
	ren ag_k47c daysnonhiredchild
	ren ta ta
	keep region district ta ea rural hhid garden_id plot_id daysnonhired*
	gen season= 1 
	//duplicates drop  region district ta ea rural hhid garden_id plot_id season, force //0 duplicates deleted
	reshape long daysnonhired, i(region  district ta ea rural hhid garden_id plot_id season) j(gender) string
	tempfile dry_exchange_all
    save `dry_exchange_all', replace
	append using `rainy_exchange_all'
	lab var season "season: 0=rainy, 1=dry, 2=tree crop"
	label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
	label values season season 
	reshape long days, i(region district ta ea rural hhid garden_id plot_id season gender) j(labor_type) string
	tempfile all_exchange
	save `all_exchange', replace

//creates tempfile `members' to merge with household labor later
use "${MWI_IHS_IHPS_W4_raw_data}\hh_mod_b.dta", clear
ren PID indiv
isid  hhid indiv
gen male= (hh_b03==1)
gen age=hh_b05a
lab var age "Individual age"
keep hhid case_id indiv age male
tempfile members
save `members', replace

	*Household labor, rainy and dry
local seasons 0 1 
foreach season in `seasons' {
	di "`season'"
	if `season'== 0 { 
		local qnums  "42 43 44"
		local dk d
		local ag ag_d00
	} 
	else {
		local qnums "43 44 45"
		local dk k
		local ag ag_k0a
	}
	use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_`dk'.dta", clear
    merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", nogen 
	ren ta ta
	
	forvalues k=1(1)3 {
		local q : word `k' of `qnums'
		if `k' == 1 { 
        local suffix "_planting" 
    }
    else if `k' == 2 { 
        local suffix "_nonharvest"
    }
    else if `k' == 3 { 
        local suffix "_harvest"
    }
	ren ag_`dk'`q'a1 indiv1`suffix'
    ren ag_`dk'`q'b1 weeks_worked1`suffix'
    ren ag_`dk'`q'c1 days_week1`suffix'
    ren ag_`dk'`q'd1 hours_day1`suffix'
    ren ag_`dk'`q'a2 indiv2`suffix'
    ren ag_`dk'`q'b2 weeks_worked2`suffix'
    ren ag_`dk'`q'c2 days_week2`suffix'
    ren ag_`dk'`q'd2 hours_day2`suffix'
    ren ag_`dk'`q'a3 indiv3`suffix'
    ren ag_`dk'`q'b3 weeks_worked3`suffix'
    ren ag_`dk'`q'c3 days_week3`suffix'
    ren ag_`dk'`q'd3 hours_day3`suffix'
    ren ag_`dk'`q'a4 indiv4`suffix'
    ren ag_`dk'`q'b4 weeks_worked4`suffix'
    ren ag_`dk'`q'c4 days_week4`suffix'
    ren ag_`dk'`q'd4 hours_day4`suffix'
	ren ag_`dk'`q'a5 indiv5`suffix'
    ren ag_`dk'`q'b5 weeks_worked5`suffix'
    ren ag_`dk'`q'c5 days_week5`suffix'
    ren ag_`dk'`q'd5 hours_day5`suffix'
	
	ren ag_`dk'`q'a6 indiv6`suffix'
    ren ag_`dk'`q'b6 weeks_worked6`suffix'
    ren ag_`dk'`q'c6 days_week6`suffix'
    ren ag_`dk'`q'd6 hours_day6`suffix'
	
	ren ag_`dk'`q'a7 indiv7`suffix'
    ren ag_`dk'`q'b7 weeks_worked7`suffix'
    ren ag_`dk'`q'c7 days_week7`suffix'
    ren ag_`dk'`q'd7 hours_day7`suffix'
	
	ren ag_`dk'`q'a8 indiv8`suffix'
    ren ag_`dk'`q'b8 weeks_worked8`suffix'
    ren ag_`dk'`q'c8 days_week8`suffix'
    ren ag_`dk'`q'd8 hours_day8`suffix'
	
    capture ren ag_`dk'`q'a9 indiv9`suffix'
    capture ren ag_`dk'`q'b9 weeks_worked9`suffix'
    capture ren ag_`dk'`q'c9 days_week9`suffix'
    capture ren ag_`dk'`q'd9 hours_day9`suffix'
	
	capture ren ag_`dk'`q'a10 indiv10`suffix'
    capture ren ag_`dk'`q'b10 weeks_worked10`suffix'
    capture ren ag_`dk'`q'c10 days_week10`suffix'
    capture ren ag_`dk'`q'd10 hours_day10`suffix'
	
	capture ren ag_`dk'`q'a11 indiv11`suffix'
    capture ren ag_`dk'`q'b11 weeks_worked11`suffix'
    capture ren ag_`dk'`q'c11 days_week11`suffix'
    capture ren ag_`dk'`q'd11 hours_day11`suffix'
    }
	ren gardenid garden_id
	ren plotid plot_id
	keep region district ta ea_id rural hhid garden_id plot_id indiv* weeks_worked* days_week* hours_day*
    gen season = "`season'"
	unab vars : *`suffix' 
	local stubs : subinstr local vars "_`suffix'" "", all 
	duplicates drop  region district ta ea_id rural hhid garden_id plot_id season, force
	reshape long indiv weeks_worked days_week hours_day, i(region district ta ea_id rural hhid garden_id plot_id season) j(num_suffix) string
	split num_suffix, parse(_)
	if `season'== 0 { 
		tempfile rainy
		save `rainy'
	}
	else {
		append using `rainy'
	}
}
ren ea_id ea
gen days=weeks_worked*days_week
gen hours=weeks_worked*days_week*hours_day
drop if days==. 
drop if hours==. //0 observations deleted
//rescaling fam labor to growing season duration
preserve
collapse (sum) days_rescale=days, by(region district ta ea rural hhid garden_id plot_id indiv season)
merge m:1 hhid garden_id plot_id using"${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_season_length.dta", nogen keep(1 3)
replace days_rescale = days_grown if days_rescale > days_grown
tempfile rescaled_days
save `rescaled_days'
restore

//Rescaling to season
bys hhid plot_id garden_id indiv : egen tot_days = sum(days)
gen days_prop = days/tot_days 
merge m:1 region district ta ea rural hhid garden_id plot_id indiv season using `rescaled_days'
replace days = days_rescale * days_prop if tot_days > days_grown
merge m:1 hhid indiv using `members', nogen keep (1 3)
gen gender="child" if age<15 
replace gender="male" if strmatch(gender,"") & male==1
replace gender="female" if strmatch(gender,"") & male==0
gen labor_type="family"
keep region district ta ea rural hhid garden_id plot_id season gender days labor_type
destring season, replace
lab var season "season: 0=rainy, 1=dry, 2=tree crop"
label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
label values season season
append using `all_exchange'

//MGM 7.20.23: EPAR cannot construct the value of family labor or nonhired (AKA exchange) labor MWI Waves 1, 2, 3, and 4 given issues with how the value of hired labor is constructed (e.g. we do not know how many laborers are hired and if wages are reported as aggregate or singular). Therefore, we cannot use a median value of hired labor to impute the value of family or nonhired (AKA exchange) labor.

gen val = . 
append using `all_hired'
keep region district ta ea rural case_id hhid garden_id plot_id season days val labor_type gender 
drop if val==.&days==.
capture ren plotid plot_id
merge m:1 hhid garden_id plot_id case_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender)
collapse (sum) val days, by(case_id hhid garden_id plot_id season labor_type gender dm_gender) 
	la var gender "Gender of worker"
	la var dm_gender "Plot manager gender"
	la var labor_type "Hired, exchange, or family labor"
	la var days "Number of person-days per plot" 
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_plot_labor_long.dta",replace
preserve
	collapse (sum) labor_=days, by (case_id hhid garden_id plot_id labor_type season)
	reshape wide labor_, i(case_id hhid garden_id season plot_id) j(labor_type) string
		la var labor_family "Number of family person-days spent on plot, all seasons"
		la var labor_nonhired "Number of exchange (free) person-days spent on plot, all seasons" 
		la var labor_hired "Number of hired labor person-days spent on plot, all seasons" 
	save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_plot_labor_days.dta",replace 	
//AgQuery
restore

//ALT: At this point all code below is legacy; we could cut it with some changes to how the summary stats get processed.
preserve
	gen exp="exp" if strmatch(labor_type,"hired")
	replace exp="imp" if strmatch(exp,"")
	append using `inkind_payments'
	collapse (sum) val, by(case_id hhid plot_id exp dm_gender season)
	gen input="labor"
	save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_plot_labor.dta", replace 
restore	

//Back to wide format
collapse (sum) val, by(case_id hhid garden_id plot_id labor_type season dm_gender)
ren val val_ 
reshape wide val_, i(case_id plot_id hhid garden_id season dm_gender) j(labor_type) string
ren val* val*i
gen season_fix="rainy" if season==0
replace season_fix="dry" if season==1
drop season
ren season_fix season

reshape wide val*, i(case_id hhid garden_id plot_id dm_gender) j(season) string
gen dm_gender2 = "male" if dm_gender==1
replace dm_gender2 = "female" if dm_gender==2
replace dm_gender2 = "unknown" if dm_gender==.
drop dm_gender
ren val* val*_ 
replace dm_gender2 = "unknown" if dm_gender == ""
reshape wide val*, i(case_id hhid garden_id plot_id) j(dm_gender2) string
collapse (sum) val*, by(case_id hhid)
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_cost_labor.dta", replace

*******************************************
		* LAND/PLOT RENTS *
*******************************************
* Crops Payments
	use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_b2.dta", clear
	gen season=0
	append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_i2.dta"
	gen cultivate = 0
	replace cultivate = 1 if ag_b214 == 1
	replace cultivate = 1 if ag_i214 == 1 
	ren gardenid garden_id
	gen payment_period=ag_b212
	replace payment_period=ag_i212 if payment_period==. 
	
* Paid 
	ren ag_b208a crop_code_paid
	replace crop_code_paid=ag_i208a if crop_code_paid==.
	ren ag_b208b qty_paid
	replace qty_paid=ag_i208b if qty_paid==.
	ren ag_b208c unit_paid
	replace unit_paid=ag_i208c if unit_paid==.
	ren ag_b208d condition_paid
	replace condition_paid=ag_i208d if condition_paid==.

* Owed
	ren ag_b210a crop_code_owed
	ren ag_b210b qty_owed
	ren ag_b210c unit_owed
	ren ag_b210d condition_owed

	drop if crop_code_paid==. & crop_code_owed==. //21,175 observations deleted
	drop if (unit_paid==. & crop_code_paid!=.) | (unit_owed==. & crop_code_owed!=.)  //210 observations deleted
	
	keep case_id hhid garden_id cultivate season crop_code* qty* unit* condition* payment_period
	reshape long crop_code qty unit condition, i (hhid season garden_id payment_period cultivate) j(payment_status) string
	ren crop_code crop_code_long
	drop if crop_code_long==. //59 observations deleted
	drop if qty==. //0 observations deleted
	duplicates drop hhid, force  //6 observation deleted 
	recast str50 hhid, force 
	merge m:1 case_id hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhsize.dta", keepusing (region district ta ea) keep(1 3) nogen // 44 out of 53 matched
**# Bookmark #2
	merge m:1 region crop_code_long unit condition using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_cf.dta", nogen keep (1 3) // 0 out of 53 matched
	merge m:1 case_id hhid crop_code using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_crop_prices_for_wages.dta", nogen keep (1 3) //22 out of 53 matched

gen val=qty*hh_price_mean 
drop qty unit crop_code condition hh_price_mean payment_status
keep if val!=. //22 obs deleted
tempfile plotrentbycrops
save `plotrentbycrops'

* Rainy Cash + In-Kind
	use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_b2.dta", clear
	gen cultivate = 0
	replace cultivate = 1 if ag_b214 == 1
	ren gardenid garden_id
	
	ren ag_b209a cash_rents_total
	ren ag_b209b inkind_rents_total
	ren ag_b211a cash_rents_paid
	ren ag_b211b inkind_rents_paid
	ren ag_b212 payment_period
	replace cash_rents_paid=cash_rents_total if cash_rents_paid==. & cash_rents_total!=. & payment_period==1
	ren ag_b211c cash_rents_owed
	ren ag_b211d inkind_rents_owed
	egen val = rowtotal(cash_rents_paid inkind_rents_paid cash_rents_owed inkind_rents_owed)
	gen season = 0 
	keep hhid garden_id val season cult payment_period
	tempfile rainy_land_rents
	save `rainy_land_rents', replace

* Dry Cash + In-Kind 
	use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_i2.dta", clear 
	gen cultivate = 0
		replace cultivate = 1 if ag_i214 == 1
    ren gardenid garden_id 
	ren ag_i208a cash_rents_total
	ren ag_i208b inkind_rents_total
	ren ag_i212 payment_period
	replace payment_period=0 if payment_period==3 & (strmatch(ag_i212_oth, "DIMBA SEASON ONLY") | strmatch(ag_i212_oth, "DIMBA SEASOOY") | strmatch(ag_i212_oth, "ONLY DIMBA"))
	egen val = rowtotal( cash_rents_total inkind_rents_total)
	keep hhid garden_id val cult payment_period
	gen season = 1

* Combine dry + rainy + payments-by-crop
append using `rainy_land_rents' 
append using `plotrentbycrops'
lab var season "season: 0=rainy, 1=dry, 2=tree crop"
label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
label values season season
gen input="plotrent"
gen exp="exp"

duplicates report hhid garden_id season
duplicates tag hhid garden_id season, gen(dups)
duplicates drop hhid garden_id season, force //29 duplicate entries
drop dups

gen check=1 if payment_period==2 & val>0 & val!=.
duplicates report hhid garden_id payment_period check
duplicates tag  hhid garden_id payment_period check, gen(dups)
drop if dups>0 & check==1 & season==1 
drop dups check

gen qty=0
recode val (.=0)
collapse (sum) val, by (hhid garden_id season exp input qty cultivate)
duplicates drop hhid garden_id, force //1 observation deleted 
recast str50 hhid, force 
merge 1:m hhid garden_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_areas.dta", keep (1 3) 
count if _m==1 & plot_id!="" & val!=. & val>0 
	drop if _m != 3 //724 obs deleted
	drop _m

* Calculate quantity of plot rents etc. 
replace qty = field_size if val > 0 & val! = . //1,616 changes
keep if cultivate==1 //444 observations deleted 
keep hhid garden_id plot_id case_id season input exp val qty
tempfile plotrents
save `plotrents'	


	******************************************
	* FERTILIZER, PESTICIDES, AND HERBICIDES *
	******************************************
* HH-LEVEL Plot info (mod F & mod L)
use "${MWI_IHS_IHPS_W4_raw_data}\AG_MOD_F.dta", clear
gen season = 0
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_l.dta"
replace season = 1 if season == .
lab var season "season: 0=rainy, 1=dry, 2=tree crop"
label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
label values season season
ren ag_f0c itemcode
replace itemcode = ag_l0c if itemcode == .
drop if itemcode == . //2 observations deleted
//Type of inorganic fertilizer or Herbicide (1 = 23:21:0+4S/CHITOWE, 2 =  DAP, 3 = CAN 4 = UREA, 5 = D COMPOUND 5, 6 = Other Fertilizer, 7 = INSECTICIDE, 8 = HERBICIDE, 9 = FUMIGANT 10 = Other Pesticide or Herbicide. 17 - unknown)
			
gen codefertherb = 0 if item == 0 
replace code = 1 if inlist(item, 1,2,3,4,5,6)
replace code = 2 if inlist(item, 7,9,10) 
replace code = 3 if inlist(item, 8)
		
lab var codefertherb "Code: 0 = organic fert, 1 = inorganic fert, 2 = pesticide, 3 = herbicide"
lab define codefertherb 0 "organic fert" 1 "inorganic fert" 2 "pesticide" 3 "herbicide"
lab values codefertherb codefertherb			

* For all "specify unit" variable
local qnum 07 16 26 36 38 42 
foreach q in `qnum'{
	tostring ag_f`q'b_oth, format(%19.0f) replace
	tostring ag_l`q'b_oth, format(%19.0f) replace
}
*All Source Input and Transportation Costs (Explicit)*
ren ag_f07a qtyinputexp0
replace qtyinputexp0 = ag_l07a if qtyinputexp0 ==.
ren ag_f07b unitinputexp0
replace unitinputexp0 = ag_l07b if unitinputexp0 ==.
ren ag_f09 valtransfertexp0 
replace valtransfertexp0 = ag_l09 if valtransfertexp0 == .
ren ag_f10 valinputexp0
replace valinputexp0 = ag_l10 if valinputexp0 == .

*First Source Input and Transportation Costs (Explicit)*
ren ag_f16a qtyinputexp1
replace qtyinputexp1 = ag_l16a if qtyinputexp1 ==.
ren ag_f16b unitinputexp1
replace unitinputexp1 = ag_l16b if unitinputexp1 ==. 
ren ag_f18 valtransfertexp1
replace valtransfertexp1 = ag_l18 if valtransfertexp1 == .
ren ag_f19 valinputexp1
replace valinputexp1 = ag_l19 if valinputexp1 == .

*Second Source Input and Transportation Costs (Explicit)*
ren ag_f26a qtyinputexp2
replace qtyinputexp2 = ag_l26a if qtyinputexp2 ==.
ren ag_f26b unitinputexp2
replace unitinputexp2 = ag_l26b if unitinputexp2 ==.
ren ag_f28 valtransfertexp2
replace valtransfertexp2 = ag_l28 if valtransfertexp2 == .
ren  ag_f29 valinputexp2
replace valinputexp2 = ag_l29 if valinputexp2 == .

*Third Source Input Costs (Explicit)*
ren ag_f36a qtyinputexp3  // Third Source
replace qtyinputexp3 = ag_l36a if qtyinputexp3 == .
ren ag_f36b unitinputexp3
replace unitinputexp3 = ag_l36b if unitinputexp3 == . 

*Free and Left-Over Input Costs (Implicit)*
gen itemcodeinputimp1 = itemcode
ren ag_f38a qtyinputimp1
replace qtyinputimp1 = ag_l38a if qtyinputimp1 == .
ren ag_f38b unitinputimp1
replace unitinputimp1 = ag_l38b if unitinputimp1 == . 
ren ag_f42a qtyinputimp2
replace qtyinputimp2 = ag_l42a if qtyinputimp2 == .
ren ag_f42b unitinputimp2
replace unitinputimp2 = ag_l42b if unitinputimp2== .

*Free Input Source Transportation Costs (Explicit)*
ren ag_f40 valtransfertexp3
replace valtransfertexp3 = ag_l40 if valtransfertexp3 == .

ren ag_f07b_o otherunitinputexp0
replace otherunitinputexp0=ag_l07b_o if otherunitinputexp0==""

ren ag_f16b_o otherunitinputexp1
replace otherunitinputexp1=ag_l16b_o if otherunitinputexp1==""
ren ag_f26b_o otherunitinputexp2
replace otherunitinputexp2=ag_l26b_o if otherunitinputexp2==""
ren ag_f36b_o otherunitinputexp3
replace otherunitinputexp3=ag_l36b_o if otherunitinputexp3==""
ren ag_f38b_o otherunitinputimp1
replace otherunitinputimp1=ag_l38b_o if otherunitinputimp1==""
ren ag_f42b_o otherunitinputimp2
replace otherunitinputimp2=ag_l42b_o if otherunitinputimp2==""

replace qtyinputexp1=qtyinputexp0 if (qtyinputexp0!=. & qtyinputexp1==. & qtyinputexp2==. & qtyinputexp3==.) //10,161 changes
replace unitinputexp1=unitinputexp0 if (unitinputexp0!=. & unitinputexp1==. & unitinputexp2==. & unitinputexp3==.) //10,059 changes
replace otherunitinputexp1=otherunitinputexp0 if (otherunitinputexp0!="" & otherunitinputexp1=="" & otherunitinputexp2=="" & otherunitinputexp3=="") //77 changes
replace valtransfertexp1=valtransfertexp0 if (valtransfertexp0!=. & valtransfertexp1==. & valtransfertexp2==.) //10,161 changes
replace valinputexp1=valinputexp0 if (valinputexp0!=. & valinputexp1==. & valinputexp2==.) //10,161 changes

keep qty* unit* otherunit* val* hhid itemcode codefertherb season
gen dummya = _n
unab vars : *1
local stubs : subinstr local vars "1" "", all
reshape long `stubs', i (hhid dummya itemcode codefertherb) j(entry_no)
drop entry_no
replace dummya=_n
unab vars2 : *exp
local stubs2 : subinstr local vars2 "exp" "", all
reshape long `stubs2', i(hhid dummya itemcode codefertherb) j(exp) string
replace dummya=_n
reshape long qty unit val, i(hhid exp dummya itemcode codefertherb) j(input) string
tab val if exp=="imp" & input=="transfert"
drop if strmatch(exp,"imp") & strmatch(input, "transfert")

// Converting GRAMS to KILOGRAM
replace qty = qty / 1000 if unit == 1 
// Converting 2 KG BAG to KILOGRAM
replace qty = qty * 2 if unit == 3
// Converting 3 KG BAG to KILOGRAM
replace qty = qty * 3 if unit == 4
// Converting 5 KG BAG to KILOGRAM
replace qty = qty * 5 if unit == 5
// Converting 10 KG BAG to KILOGRAM
replace qty = qty * 10 if unit == 6
// Converting 50 KG BAG to KILOGRAM
replace qty = qty * 50 if unit == 7

*CONVERTING VOLUMES TO MASS*
/*Assuming 1 BUCKET is about 20L in Malawi
Citation: Mponela, P., Villamor, G. B., Snapp, S., Tamene, L., Le, Q. B., & Borgemeister, C. (2020). The role of women empowerment and labor dependency on adoption of integrated soil fertility management in Malawi. Sustainability, 12(15), 1-11. https://doi.org/10.1111/sum.12627
*/

*ORGANIC FERTILIZER
/*Assuming bulk density of ORGANIC FERTILIZER is between 420-655 kg/m3 (midpoint 537.5kg/m3)
Citation: Khater, E. G. (2015). Some Physical and Chemical Properties of Compost. Agricultural Engineering Department, Faculty of Agriculture, Benha University, Egypt. Corresponding author: Farouk K. M. Wali, Assistant professor, Chemical technology Department, The Prince Sultan Industrial College, Saudi Arabia, Tel: +20132467034; E-mail: alsayed.khater@fagr.bu.edu.eg. Retrieved from https://www.walshmedicalmedia.com/open-access/some-physical-and-chemical-properties-of-compost-2252-5211-1000172.pdf
*/
replace qty = qty*.5375 if unit== 8 & itemcode==0 //liter
replace qty = qty/1000*.5375 if unit== 9 & itemcode==0 //milliliter
replace qty = qty*20*.5375 if unit== 10 & itemcode==0 //bucket

*CHITOWE*
/*Assuming bulk density of CHITOWE(NPK) is between 66lb/ft3 (converts to 1057.22kg/m3) based on the bulk density of YaraMila 16-16-16 by Yara North America, Inc. fertilizer available at https://www.yara.us/contentassets/280676bbae1c466799e9d22b57225584/yaramila-16-16-16-pds/
*/
replace qty = qty*1.05722 if unit== 8 & itemcode==1 //liter
replace qty = qty/1000*1.05722 if unit== 9 & itemcode==1 //milliliter
replace qty = qty*20*1.05722 if unit== 10 & itemcode==1 //bucket

*DAP*
/*Assuming bulk density of DAP is between 900-1100kg/m3 (midpoint 1000kg/m3) based on the bulk density of DAP fertlizer by Incitec Pivot Ltd. (Australia) available at https://www.incitecpivotfertilisers.com.au/~/media/Files/IPF/Documents/Fact%20Sheets/40%20Fertiliser%20Products%20Density%20and%20Sizing%20Fact%20Sheet.pdf
*/
replace qty = qty*1 if unit== 8 & itemcode==2 //liter
replace qty = qty/1000*1 if unit== 9 & itemcode==2 //milliliter
replace qty = qty*20*1 if unit== 10 & itemcode==2 //bucket

*CAN*
/*Assuming bulk density of CAN is 12.64lb/gal (converts to 1514.606kg/m3) based on the bulk density of CAN-17 by Simplot (Boise, ID) available at https://techsheets.simplot.com/Plant_Nutrients/Calcium_Ammon_Nitrate.pdf
*/
replace qty = qty*1.514606 if unit== 8 & itemcode==3 //liter
replace qty = qty/1000*1.514606 if unit== 9 & itemcode==3 //milliliter
replace qty = qty*20*1.514606 if unit== 10 & itemcode==3 //bucket

*UREA*
/*Assuming bulk density of UREA is 760kg/m3 based on the bulk density of  urea-prills by Pestell Nutrition (Canada) available at https://pestell.com/product/urea-prills/
*/
replace qty = qty*.760 if unit== 8 & itemcode==4 //liter
replace qty = qty/1000*.760 if unit== 9 & itemcode==4 //milliliter
replace qty = qty*20*.760 if unit== 10 & itemcode==4 //bucket

*D COMPOUND*
/*Assuming bulk density of D COMPOUND is approximately 1,587.30kg/m3 based on the bulk density D Compound-50kg stored in a (30cm x 50cm x 70cm) bag by E-msika (Zambia) available at www.emsika.com/product-details/54
Calculation: 50 kg stored in a (30cm x 50cm x 70cm) = 31,500cm3 (0.0315m3) bag; so 50kg/0.0315m3 or 1,587.30kg/m3
*/
replace qty = qty*1.5873 if unit== 8 & itemcode==5 //liter
replace qty = qty/1000*1.5873 if unit== 9 & itemcode==5 //milliliter
replace qty = qty*20*1.5873 if unit== 10 & itemcode==5 //bucket

*PESTICIDES AND HERBICIDES*
/*ALT: Pesticides and herbicides do not have a bulk density because they are typically sold already in liquid form, so they'd have a mass density. It depends on the concentration of the active ingredient and the presence of any adjuvants and is typically impossible to get right unless you have the specific brand name. Accordingly, EPAR currently assumes 1L=1kg, which results in a slight underestimate of herbicides and pesticides.*/
replace qty = qty*1 if unit== 8 & (codefertherb==2 | codefertherb==3) //liter
replace qty = qty/1000*1 if unit== 9 & (codefertherb==2 | codefertherb==3) //milliliter
replace qty = qty*20*1 if unit== 10 & (codefertherb==2 | codefertherb==3) //bucket

*CONVERTING WHEELBARROW AND OX-CART TO KGS*
/*Assuming 1 WHEELBARROW max load is 80 kg 
Assuming 1 OX-CART has a 800 kgs carrying capacity, though author notes that ox-carts typically carry loads far below their weight capacity, particularly for crops (where yields may not fill the cart entirely)
Citation: Wendroff, A. P. (n.d.). THE MALAWI CART: An Affordable Bicycle-Wheel Wood-Frame Handcart for Agricultural, Rural and Urban Transport Applications in Africa. Research Associate, Department of Geology, Brooklyn College / City University of New York; Director, Malawi Handcart Project. Available at: https://www.academia.edu/15078493/THE_MALAWI_CART_An_Affordable_Bicycle-Wheel_Wood-Frame_Handcart_for_Agricultural_Rural_and_Urban_Transport_Applications_in_Africa
*/
replace qty = qty*80 if unit==11
replace qty = qty*800 if unit==12

* Updating the unit for unit to "1" (to match seed code) for the relevant units after conversion
replace unit = 1 if inlist(unit, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)

tab otherunit
replace qty = 1*2 if qty==. & (strmatch(otherunit, "2 TONNE PICKUP")) // 1 change
replace qty = qty*1000 if strmatch(otherunit, "1 TON") | strmatch(otherunit, "TONS") //Assuming metric ton instead of standard conversion where 1 ton=907.185 kgs // 0 Changes
replace unit = 1 if strmatch(otherunit, "1 TON") | strmatch(otherunit, "TONS") // 0 Changes
replace qty = qty*50 if strmatch(otherunit, "50 KG BAG") // 4 changes
replace unit = 1 if strmatch(otherunit, "50 KG BAG") // 4 real changes
replace qty = qty*90 if strpos(otherunit, "90 KG") // 3 changes
replace unit = 1 if strpos(otherunit, "90 KG") // 5 real changes

label define inputunitrecode 1 "Kilogram", modify
label values unit inputunitrecode
tab unit 
drop if unit==13 //11 observations dropped

drop if (qty==. | qty==0) & strmatch(input, "input") // 1,082,366 observations deleted
drop if unit==. & strmatch(input, "input") // 42 observations deleted
drop if itemcode==. // 0 observations deleted
gen byte qty_missing = missing(qty)
gen byte val_missing = missing(val)
collapse (sum) val qty, by(hhid unit itemcode codefertherb exp input qty_missing val_missing season) 
replace qty =. if qty_missing
replace val =. if val_missing
drop qty_missing val_missing

replace input="orgfert" if codefertherb==0 & input!="transfert"
replace input="orgfert" if codefertherb==1 & input!="transfert"
replace input="pest" if codefertherb==2 & input!="transfert"
replace input="herb" if codefertherb==3 & input!="transfert"
replace qty=. if input=="transfert" //1 changes
keep if qty>0 //0 obs deleted
replace unit=1 if unit==. 
drop if input == "input" & itemc == 11 
tempfile phys_inputs
save `phys_inputs'

	*********************************
	* 			 SEED			    *
	*********************************	
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_h.dta", clear
gen season = 0
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_n.dta"
replace season = 1 if season == .
lab var season "season: 0=rainy, 1=dry, 2=tree crop"
label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
label values season season 

recast str50 hhid
ren crop_code seedcode
drop if seedc == . 

local qnum 07 16 26 36 38 42
foreach q in `qnum'{
	tostring ag_h`q'b_oth, format(%19.0f) replace
	tostring ag_n`q'b_oth, format(%19.0f) replace
}

** Filling empties from duplicative questions
* How much seed was purhcased w/o coupons etc.?
replace ag_h16a=ag_h07a if (ag_h07a!=. & ag_h16a==. & ag_h26a==. & ag_h36a==.) // 8,262 changes
replace ag_h16b=ag_h07b if (ag_h07b!=. & ag_h16b==. & ag_h26b==. & ag_h36b==.) // 8,208 changes
replace ag_h16b_oth=ag_h07b_oth if (ag_h07b_oth!="" & ag_h16b_oth=="" & ag_h26b_oth=="" & ag_h36b_oth=="") // 549 changes

*How much did you pay for transpo to acquire seed?
replace ag_h18=ag_h09 if (ag_h09!=. & ag_h18==. & ag_h28==.) // 8,262 changes

* Value of seed purchased? 
replace ag_h19=ag_h10 if (ag_h10!=. & ag_h19==. & ag_h29==.) // 8,262 changes

* Repeat for Module N
replace ag_n16a=ag_n07a if (ag_n07a!=. & ag_n16a==. & ag_n26a==. & ag_n36a==.) // 1,486 changes
replace ag_n16b=ag_n07b if (ag_n07b!=. & ag_n16b==. & ag_n26b==. & ag_n36b==.) // 1,483 changes
replace ag_n16b_oth=ag_n07b_oth if (ag_n07b_oth!="" & ag_n16b_oth=="" & ag_n26b_oth=="" & ag_n36b_oth=="") // 252 changes
replace ag_n18=ag_n09 if (ag_n09!=. & ag_n18==. & ag_n28==.) // 1,486 changes
replace ag_n19=ag_n10 if (ag_n10!=. & ag_n19==. & ag_n29==.) // 1,486 changes
*****

*First Source Seed and Transportation Costs (Explicit)*
	ren ag_h16a qtyseedexp1 
	replace qtyseedexp1 = ag_n16a if qtyseedexp1 ==.
	ren ag_h16b unitseedexp1
	replace unitseedexp1 = ag_n16b if unitseedexp1 ==. 
	ren ag_h18 valseedtransexp1 
	replace valseedtransexp1 = ag_n18 if valseedtransexp1 == .
	ren ag_h19 valseedsexp1 
	replace valseedsexp1 = ag_n19 if valseedsexp1 == .
	gen itemcodeseedexp1 = seedcode if qtyseedexp1!=. 
	
*Second Source Seed and Transportation Costs (Explicit)*
	ren ag_h26a qtyseedexp2 
	replace qtyseedexp2 = ag_n26a if qtyseedexp2 ==.
	ren ag_h26b unitseedexp2
	replace unitseedexp2 = ag_n26b if unitseedexp2 ==.
	ren ag_h28 valseedtransexp2 
	replace valseedtransexp2 = ag_n28 if valseedtransexp2 == .
	ren  ag_h29 valseedsexp2
	replace valseedsexp2 = ag_n29 if valseedsexp2 == .
	gen itemcodeseedexp2 = seedcode if qtyseedexp2!=. 

*Third Source Seed Costs (Explicit)* // Transportation Costs and Value of seed not asked about for third source on W1 instrument, hence the need to impute these costs later provided we have itemcode code and qtym
	ren ag_h36a qtyseedexp3  
	replace qtyseedexp3 = ag_n36a if qtyseedexp3 == .
	ren ag_h36b unitseedexp3
	replace unitseedexp3 = ag_n36b if unitseedexp3 == . 
	gen itemcodeseedexp3 = seedcode if qtyseedexp3!=. 

*Free and Left-Over Seed Costs (Implicit)*
ren ag_h42a qtyseedimp1 
replace qtyseedimp1 = ag_n42a if qtyseedimp1 == . 
ren ag_h42b unitseedimp1
gen itemcodeseedimp1 = seedcode if qtyseedimp1!=. 
replace unitseedimp1 = ag_n42b if unitseedimp1== .
ren ag_h38a qtyseedimp2  
replace qtyseedimp2 = ag_n38a if qtyseedimp2 == .
ren ag_h38b unitseedimp2
replace unitseedimp2 = ag_n38b if unitseedimp2 == . 
gen itemcodeseedimp2 = seedcode if qtyseedimp2!=.

*Free Source Transportation Costs (Explicit)*
ren ag_h40 valseedtransexp3 
replace valseedtransexp3 = ag_n40 if valseedtransexp3 == .

* Checking gaps in "other" unit variables
tab ag_h16b_oth 
tab ag_n16b_oth 
tab ag_h26b_oth // 1 obs "packet"
tab ag_n26b_oth 
tab ag_h36b_oth 
tab ag_n36b_oth 
tab ag_h38b_oth 
tab ag_n38b_oth
tab ag_h42b_oth
tab ag_n42b_oth

**** BACKFILL CODE, EDITED TO MEET THE NEEDS OF W4
ren ag_h16b_o otherunitseedexp1
replace otherunitseedexp1=ag_n16b_o if otherunitseedexp1==""
ren ag_h26b_o otherunitseedexp2
replace otherunitseedexp2=ag_n26b_o if otherunitseedexp2==""
ren ag_h36b_o otherunitseedexp3
replace otherunitseedexp3=ag_n36b_o if otherunitseedexp3==""
ren ag_h38b_o otherunitseedimp1
replace otherunitseedimp1=ag_n38b_o if otherunitseedimp1==""
ren ag_h42b_o otherunitseedimp2
replace otherunitseedimp2=ag_n42b_o if otherunitseedimp2==""

local suffix exp1 exp2 exp3 imp1 imp2
foreach s in `suffix' {
//CONVERT SPECIFIED UNITS TO KGS
replace qtyseed`s'=qtyseed`s'/1000 if unitseed`s'==1
replace qtyseed`s'=qtyseed`s'*2 if unitseed`s'==3
replace qtyseed`s'=qtyseed`s'*3 if unitseed`s'==4
replace qtyseed`s'=qtyseed`s'*3.7 if unitseed`s'==5
replace qtyseed`s'=qtyseed`s'*5 if unitseed`s'==6
replace qtyseed`s'=qtyseed`s'*10 if unitseed`s'==7
replace qtyseed`s'=qtyseed`s'*50 if unitseed`s'==8
recode unitseed`s' (1/8 = 1)
label define unitrecode`s' 1 "Kilogram" 4 "Pail (small)" 5 "Pail (large)" 6 "No 10 Plate" 7 "No 12 Plate" 8 "Bunch" 9 "Piece" 11 "Basket (Dengu)" 120 "Packet" 210 "Stem" 260 "Cutting", modify
label values unitseed`s' unitrecode`s'

//REPLACE UNITS WITH O/S WHERE POSSIBLE
//Malawi instruments do not have unit codes for units like "packet" or "stem" or "bundle". Converting unit codes to align with the Malawi conversion factor file (merged in later). Also, borrowing Nigeria's unit codes for units (e.g. packets) that do not have unit codes in the Malawi instrument or conversion factor file.

* KGs 
replace unitseed`s'=1 if strmatch(otherunitseed`s', "MG") 
replace qtyseed`s'=qtyseed`s'/1000000 if strmatch(otherunitseed`s', "MG") 
replace unitseed`s'=1 if strmatch(otherunitseed`s', "20 KG BAG")
replace qtyseed`s'=qtyseed`s'*20 if strmatch(otherunitseed`s', "20 KG BAG")
replace unitseed`s'=1 if strmatch(otherunitseed`s', "25 KG BAG")
replace qtyseed`s'=qtyseed`s'*25 if strmatch(otherunitseed`s', "25 KG BAG")
replace unitseed`s'=1 if strpos(otherunitseed`s', "50 KG") | strpos(otherunitseed`s', "50KG")
replace qtyseed`s'=qtyseed`s'*50 if strpos(otherunitseed`s', "50 KG") | strpos(otherunitseed`s', "50KG")
replace unitseed`s'=1 if strpos(otherunitseed`s', "70 KG") | strpos(otherunitseed`s', "70KG") 
replace qtyseed`s'=qtyseed`s'*50 if strpos(otherunitseed`s', "70 KG") | strpos(otherunitseed`s', "70KG") 
replace unitseed`s'=1 if strpos(otherunitseed`s', "90 KG") | strpos(otherunitseed`s', "90KG") 
replace qtyseed`s'=qtyseed`s'*90 if strpos(otherunitseed`s', "90 KG") | strpos(otherunitseed`s', "90KG") 
replace unitseed`s'=1 if strpos(otherunitseed`s', "100KG") | strpos(otherunitseed`s', "100 KG")  
replace qtyseed`s'=qtyseed`s'*100 if strpos(otherunitseed`s', "100KG") | strpos(otherunitseed`s', "100 KG") 
replace unitseed`s'=1 if strpos(otherunitseed`s', "100G") | strpos(otherunitseed`s', "8 GRAM")
replace qtyseed`s'=(qtyseed`s'/1000)*100 if strpos(otherunitseed`s', "100KG") 
replace qtyseed`s'=(qtyseed`s'/1000)*8 if strpos(otherunitseed`s', "8 GRAM") 

* Pails
replace unitseed`s'=4 if strpos(otherunitseed`s', "PAIL") 
replace unitseed`s'=5 if strpos(otherunitseed`s', "PAIL") & (strpos(otherunitseed`s', "BIG") | strpos(otherunitseed`s', "LARGE"))
replace qtyseed`s'=qtyseed`s'*2 if strmatch(otherunitseed`s', "2X LARGE PAIL")

* Plates
replace unitseed`s'=6 if (strpos(otherunitseed`s', "PLATE")  | strpos(otherunitseed`s', "10 PLATE") | strpos(otherunitseed`s', "10PLATE")) & !strpos(otherunitseed`s', "KG") 
replace qtyseed`s'=qtyseed`s'*2 if strmatch(otherunitseed`s', "2 NO 10 PLATES")
replace unitseed`s'=7 if strpos(otherunitseed`s', "12 PLATE")  | strpos(otherunitseed`s', "12PLATE") 

* Pieces & Bundles 
replace unitseed`s'=9 if strpos(otherunitseed`s', "PIECE") | strpos(otherunitseed`s', "PIECES") | strpos(otherunitseed`s', "STEMS") | strmatch(otherunitseed`s', "CUTTINGS") | strmatch(otherunitseed`s', "BUNDLES") | strmatch(otherunitseed`s', "MTOLO UMODZI WA BATATA") 
replace qtyseed`s'=qtyseed`s'*100 if strmatch(otherunitseed`s', "BUNDLES") | strmatch(otherunitseed`s', "MTOLO UMODZI WA BATATA")

* Dengu
replace unitseed`s'=11 if strmatch(otherunitseed`s', "DENGU") 

* Packet
replace unitseed`s'=120 if strpos(otherunitseed`s', "PACKET")
replace qtyseed`s'=qtyseed`s'*2 if strmatch(otherunitseed`s', "2 PACKETS")
}

keep item* qty* unit* val* hhid season seed
gen dummya = _n
unab vars : *1
local stubs : subinstr local vars "1" "", all
reshape long `stubs', i (hhid dummya) j(entry_no)
drop entry_no
replace dummya = _n
unab vars2 : *exp
local stubs2 : subinstr local vars2 "exp" "", all
drop if qtyseedexp==. & valseedsexp==.
reshape long `stubs2', i(hhid dummya) j(exp) string
replace dummya=_n
//seedstrans transexp labeling issue?.
reshape long qty unit val itemcode, i(hhid exp dummya) j(input) string
drop if strmatch(exp,"imp") & strmatch(input,"seedtrans")
label define unitrecode 1 "Kilogram" 4 "Pail (small)" 5 "Pail (large)" 6 "No 10 Plate" 7 "No 12 Plate" 8 "Bunch" 9 "Piece" 11 "Basket (Dengu)" 120 "Packet" 210 "Stem" 260 "Cutting", modify
label values unit unitrecode

drop if (qty==. | qty==0) & strmatch(input, "seed") // 12,132 obs deleted
drop if unit==. & strmatch(input, "seed") // 0 obs deleted 
gen byte qty_missing = missing(qty) 
gen byte val_missing = missing(val)
collapse (sum) val qty, by(hhid unit seedcode exp input qty_missing val_missing season)
replace qty =. if qty_missing
replace val =. if val_missing
drop qty_missing val_missing

ren seedcode crop_code
drop if crop_code==. & strmatch(input, "seed") // 0 obs deleted
gen condition=1 
replace condition=3 if inlist(crop_code, 5, 6, 7, 8, 10, 28, 29, 30, 31, 32, 33, 37, 39, 40, 41, 42, 43, 44, 45, 47) 
recode crop_code (1 2 3 4=1)(5 6 7 8 9 10=5)(11 12 13 14 15 16=11)(17 18 19 20 21 22 23 24 25 26=17)
rename crop_code crop_code_long
recast str50 hhid, force 
merge m:1 hhid using  "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhsize.dta", keepusing (region district ta ea) nogen keep(1 3)
//region, condition, crop_code_long 36927; unit only 12,406
merge m:1 crop_code_long unit condition region using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_cf.dta", keep (1 3) //10,848 matches 
**# Bookmark #1 check again when conversion factor is updated 


replace qty=. if input=="seedtrans" //0 changes
keep if qty>0 //0 obs deleted

//This chunk ensures that conversion factors did not get used for planted-as-seed crops where the conversion factor weights only work for planted-as-harvested crops
replace conversion =. if inlist(crop_code, 5-8, 10, 28-29, 37, 39-45, 47) // 85 real changes 

replace unit=1 if unit==. 
replace conversion = 1 if unit==1 
replace conversion = 1 if unit==9 
replace qty=qty*conversion if conversion!=.
rename crop_code itemcode
drop _m
tempfile seed
save `seed'	

*********************************************
*  	MECHANIZED TOOLS AND ANIMAL TRACTION	*
*********************************************

use "${MWI_IHS_IHPS_W4_raw_data}/HH_MOD_M.dta", clear 

rename hh_m0b itemid
gen anml = (itemid>=609 & itemid<=610) // Ox Cart, Ox Plow
gen mech = (itemid>=601 & itemid<= 608 | itemid>=611 & itemid<=612 | itemid>=613 & itemid <=625) // Hand hoe, slasher, axe, sprayer, panga knife, sickle, treadle pump, watering can, ridger, cultivator, generator, motor pump, grain mill, other, chicken house, livestock and poultry kraal, storage house, granary, barn, pig sty AND INCLUDING TRACTOR TO ALIGN WITH NIGERIA
rename hh_m14 rental_cost 
gen rental_cost_anml = rental_cost if anml==1
gen rental_cost_mech = rental_cost if mech==1
recode rental_cost_anml rental_cost_mech (.=0)

collapse (sum) rental_cost_anml rental_cost_mech, by(hhid)
lab var rental_cost_anml "Costs for renting animal traction"
lab var rental_cost_mech "Costs for renting other agricultural items" 
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_asset_rental_costs.dta", replace

ren rental_cost_* val*
reshape long val, i(hhid) j(var) string
ren var input
gen exp = "exp"
tempfile asset_rental
save `asset_rental'

*********************************************
*  	TREE/PERMANENT CROP TRANSPORATION    	*
*********************************************
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_q.dta", clear 
egen valtreetrans = rowtotal(ag_q18 ag_q27)
collapse (sum) val, by(hhid)
reshape long val, i(hhid) j(var) string
ren var input
gen exp = "exp" //Transportation is explicit
tempfile tree_transportation
save `tree_transportation' 

*********************************************
*  	TEMPORARY CROP TRANSPORATION        	*
*********************************************
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_i.dta", clear 
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_o.dta"
egen valtempcroptrans = rowtotal(ag_i18 ag_i27 ag_o18  ag_o27)
collapse (sum) val, by(hhid case_id)
reshape long val, i(hhid) j(var) string
ren var input
gen exp = "exp" //Transportation is explicit
tempfile tempcrop_transportation
save `tempcrop_transportation' 

*********************************************
*     	COMBINING AND GETTING PRICES	    *
*********************************************
use `plotrents', clear
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_cost_per_plot.dta", replace
merge m:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_weights.dta", nogen keep(1 3) keepusing(weight region district ea ta) 
merge m:1 hhid plot_id garden_id season using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_plot_areas.dta", keepusing(field_size) 
merge m:1 hhid case_id plot_id garden_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender)
gen plotweight = weight*field_size
tempfile all_plot_inputs
save `all_plot_inputs', replace

* Calculating Geographic Medians for PLOT LEVEL files
	keep if strmatch(exp,"exp") & qty!=. 
	recode val (0=.)
	gen price = val/qty
	drop if price==. 
	gen obs=1

	capture restore,not 
	foreach i in ea ta district region hhid {
	preserve
		bys `i' input : egen obs_`i' = sum(obs)
		collapse (median) price_`i'=price [aw=plotweight], by (`i' input obs_`i')
		tempfile price_`i'_median
		save `price_`i'_median'
	restore
	}

	preserve
	bys input : egen obs_country = sum(obs)
	collapse (median) price_country = price [aw=plotweight], by(input obs_country)
	tempfile price_country_median
	save `price_country_median'
	restore

	use `all_plot_inputs',clear
	foreach i in ea ta district region hhid {
		merge m:1 `i' input using `price_`i'_median', nogen keep(1 3) 
	}
		merge m:1 input  using `price_country_median', nogen keep(1 3)
		recode price_hhid (.=0)
		gen price=price_hhid
	foreach i in country region district ta ea  {
		replace price = price_`i' if obs_`i' > 9 & obs_`i'!=.
	}
	
//Default to household prices when available
replace price = price_hhid if price_hhid>0
replace qty = 0 if qty <0 //4 households reporting negative quantities of fertilizer.
recode val qty (.=0)
drop if val==0 & qty==0
replace val=qty*price if val==0

* For PLOT LEVEL data, add in plot_labor data
append using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_plot_labor.dta" // 45,846 obs where garden is empty; 9,252 obs where plot is empty, and 23,033 where dm_gender is empty (n = 70,606)
drop if garden == "" & plot_id == "" // drops 9252 obs
collapse (sum) val, by (hhid case_id plot_id garden exp input dm_gender season) 

* Save PLOT-LEVEL Crop Expenses (long)
	save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_plot_cost_inputs_long.dta",replace 

* Save PLOT-Level Crop Expenses (wide, does not currently get used in MWI W4 code)
preserve
	collapse (sum) val_=val, by(hhid case_id plot_id garden exp dm_gender season) 
	reshape wide val_, i(hhid case_id plot_id garden dm_gender season) j(exp) string
	save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_plot_cost_inputs.dta", replace 
restore

* HKS 08.21.23: Aggregate PLOT-LEVEL crop expenses data up to HH level and append to HH LEVEL data.	
preserve
use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_plot_cost_inputs_long.dta", clear
	collapse (sum) val, by(hhid case_id plot_id exp input season)
	tempfile plot_to_hh_cropexpenses
	save `plot_to_hh_cropexpenses', replace
restore

*** HH LEVEL Files: seed, asset_rental, phys_inputs
use `seed', clear
append using `asset_rental'
	append using `phys_inputs'
	append using `tree_transportation'
	append using `tempcrop_transportation'
	recast str50 hhid, force
	merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_weights.dta",nogen keep(1 3) keepusing(weight region district ea ta) // merge in hh weight & geo data 
tempfile all_HH_LEV_inputs
save `all_HH_LEV_inputs', replace
	
* Calculating Geographic Medians for HH LEVEL files
	keep if strmatch(exp,"exp") & qty!=. 
	recode val (0=.)
	drop if unit==0 //Remove things with unknown units.
	gen price = val/qty
	drop if price==. 
	gen obs=1

	* Plotweight has been changed to aw = qty*weight (where weight is population weight), as per discussion with ALT
	capture restore,not 
	foreach i in ea ta district region hhid {
	preserve
		bys `i' input unit itemcode : egen obs_`i' = sum(obs)
		collapse (median) price_`i'=price  [aw = (qty*weight)], by (`i' input unit itemcode obs_`i') 
		tempfile price_`i'_median
		save `price_`i'_median'
	restore
	}

	preserve
	bys input unit itemcode : egen obs_country = sum(obs)
	collapse (median) price_country = price  [aw = (qty*weight)], by(input unit itemcode obs_country)
	tempfile price_country_median
	save `price_country_median'
	restore

	use `all_HH_LEV_inputs',clear
	foreach i in ea ta district region hhid {
		merge m:1 `i' input unit itemcode using `price_`i'_median', nogen keep(1 3) 
	}
		merge m:1 input unit itemcode using `price_country_median', nogen keep(1 3)
		recode price_hhid (.=0)
		gen price=price_hhid
	foreach i in country region district ta ea  {
		replace price = price_`i' if obs_`i' > 9 & obs_`i'!=.
	}
	
	
//Default to household prices when available
replace price = price_hhid if price_hhid>0
replace qty = 0 if qty <0 
recode val qty (.=0)
drop if val==0 & qty==0 
replace val=qty*price if val==0
replace input = "orgfert" if itemcode==5
replace input = "inorg" if strmatch(input,"fert")

* Amend input names to match those of NGA data 
replace input = "anml" if strpos(input, "animal_tract") 
replace input = "inorg" if strpos(input, "inorg")
replace input = "seed" if strpos(input, "seed")
replace input = "mech" if strpos(input, "ag_asset") | strpos(input, "tractor") 

* Add geo variables 
   merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", nogen keepusing(ta ea district region)
   capture ren ta ta
   capture ren ea ea_id

preserve
	keep if strpos(input,"orgfert") | strpos(input,"inorg") | strpos(input,"herb") | strpos(input,"pest")
	collapse (sum) qty_=qty, by(hhid case_id ta ea district region input season) 
	reshape wide qty_, i(hhid case_id ta ea district region /*plot_id garden*/ season) j(input) string 
	//ren qty_inorg inorg_fert_rate
	ren qty_orgfert org_fert_rate
	ren qty_herb herb_rate
	ren qty_pest pest_rate
	//la var inorg_fert_rate "Qty inorganic fertilizer used (kg)"
	la var org_fert_rate "Qty organic fertilizer used (kg)"
	la var herb_rate "Qty of herbicide used (kg/L)"
	la var pest_rate "Qty of pesticide used (kg/L)"

	save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_input_quantities.dta", replace 
restore	
	
* Save HH-LEVEL Crop Expenses (long)
preserve
collapse (sum) val qty, by(hhid case_id exp input ta ea district region)
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_cost_inputs_long.dta", replace
restore

* COMBINE HH-LEVEL crop expenses (long) with PLOT level data (long) aggregated up to HH LEVEL:
use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_cost_inputs_long.dta", clear
	append using `plot_to_hh_cropexpenses'
		collapse (sum) val qty, by(hhid case_id exp input)
		replace exp = "exp" if strpos(input, "asset") |  strpos(input, "animal") | strpos(input, "tractor")
	merge m:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", nogen keepusing(ta ea district region)
	capture ren (ta ea) (ta ea_id)
	ren ea_id ea
	save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_cost_inputs_long_complete.dta", replace

********************************************************************************
* MONOCROPPED PLOTS * 
********************************************************************************
use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_all_plots.dta", clear
	keep if purestand==1 
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_monocrop_plots.dta" , replace

//Setting things up for AgQuery first
use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_all_plots.dta",clear
keep if purestand == 1 
	merge m:1  hhid case_id garden_id plot_id using  "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender)
	ren ha_planted monocrop_ha
	ren quant_harv_kg kgs_harv_mono
	ren value_harvest val_harv_mono
	collapse (sum) *mono*, by(hhid case_id garden_id plot_id crop_code dm_gender)
	
	forvalues k=1(1)$nb_topcrops  {		
preserve	
	local c : word `k' of $topcrop_area
	local cn : word `k' of $topcropname_area
	local cn_full : word `k' of $topcropname_area_full
	count if crop_code==`c'
	if `r(N)'!=0 {
	keep if crop_code==`c'			
	ren monocrop_ha `cn'_monocrop_ha
	count if `cn'_monocrop_ha!=0
	if `r(N)'!=0 {
	drop if `cn'_monocrop_ha==0 		
	ren kgs_harv_mono kgs_harv_mono_`cn'
	ren val_harv_mono val_harv_mono_`cn'
	gen `cn'_monocrop=1
	la var `cn'_monocrop "HH grows `cn_full' on a monocropped plot"
	save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_`cn'_monocrop.dta", replace	
	
	
	foreach i in `cn'_monocrop_ha kgs_harv_mono_`cn' val_harv_mono_`cn' `cn'_monocrop { 
		gen `i'_male = `i' if dm_gender==1
		gen `i'_female = `i' if dm_gender==2
		gen `i'_mixed = `i' if dm_gender==3
	}
	
	la var `cn'_monocrop_ha "Total `cn' monocrop hectares - Household"
	la var `cn'_monocrop "Household has at least one `cn' monocrop"
	la var kgs_harv_mono_`cn' "Total kilograms of `cn' harvested - Household"
	la var val_harv_mono_`cn' "Value of harvested `cn' (Kwacha)"
	foreach g in male female /*mixed */{		
		la var `cn'_monocrop_ha_`g' "Total `cn' monocrop hectares on `g' managed plots - Household"
		la var kgs_harv_mono_`cn'_`g' "Total kilograms of `cn' harvested on `g' managed plots - Household"
		la var val_harv_mono_`cn'_`g' "Total value of `cn' harvested on `g' managed plots - Household"
	}
		collapse (sum) *monocrop* kgs_harv* val_harv*, by(hhid case_id)
	save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_`cn'_monocrop_hh_area.dta", replace
	}
	}
restore
}

use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_plot_cost_inputs_long.dta", clear 
merge m:1 hhid case_id garden_id plot_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender)
collapse (sum) val, by(hhid case_id garden_id plot_id dm_gender input)
levelsof input, clean l(input_names)
	ren val val_
	reshape wide val_, i(hhid case_id garden_id plot_id dm_gender) j(input) string
	gen dm_gender2 = "male" if dm_gender==1
	replace dm_gender2 = "female" if dm_gender==2
	replace dm_gender2 = "mixed" if dm_gender==3 
	replace dm_gender2 = "unknown" if dm_gender==. 
	drop dm_gender
	
	foreach cn in $topcropname_area {
preserve
capture confirm file "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_`cn'_monocrop.dta"
	if !_rc {
	ren val* val*_`cn'_
	reshape wide val*, i(hhid case_id garden_id plot_id) j(dm_gender2) string
	merge 1:1 hhid case_id garden_id plot_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_`cn'_monocrop.dta", nogen keep(3)
	count
	if(r(N) > 0){
	collapse (sum) val*, by(hhid case_id)
	foreach i in `input_names' {
		egen val_`i'_`cn'_hh = rowtotal(val_`i'_`cn'_male val_`i'_`cn'_female /*val_`i'_`cn'_mixed*/)
	}
	save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_inputs_`cn'.dta", replace
	}
	}
restore
}	

************************
*TLU (Tropical Livestock Units) // CG 1.25.24 updated, revisions requested, revised
************************
use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_r1.dta", clear
gen tlu=0.5 if (ag_r0a==301|ag_r0a==302|ag_r0a==303|ag_r0a==304 |ag_r0a==3304) //calf, steer/heifer, cow, bull, ox
replace tlu=0.3 if (ag_r0a==3305) // donkey/mule/horse
replace tlu=0.1 if (ag_r0a==307|ag_r0a==308) //goat, sheep
replace tlu=0.2 if (ag_r0a==309) // pig
replace tlu=0.01 if (ag_r0a==3310 | ag_r0a==311 | ag_r0a==313 | ag_r0a==3314 | ag_r0a==315 | ag_r0a==315) //chicken-layer/chicken-broiler, local-hen, local-cock, turkey/guinea fowl, duck
lab var tlu "Tropical Livestock Unit coefficient"
ren tlu tlu_coefficient

*Owned
ren ag_r0a lvstckid
gen cattle=inrange(lvstckid,301,304) //calf-bull/ox
gen smallrum=inlist(lvstckid,307,308, 3314) //goat, sheep, rabbit, guinea
gen poultry=inlist(lvstckid, 315, 3314)
gen equines=inlist(lvstckid, 3305) // donkey/mule/horse combined
gen other_ls=inlist(lvstckid, 318, 319) //donkey/horse, other
gen cows=inrange(lvstckid, 303, 303)
gen chickens=inlist(lvstckid, 3310, 313, 311) 

ren ag_r07 nb_ls_1yearago
gen nb_cattle_1yearago=nb_ls_1yearago if cattle==1 
gen nb_smallrum_1yearago=nb_ls_1yearago if smallrum==1 
gen nb_poultry_1yearago=nb_ls_1yearago if poultry==1 
gen nb_equines_1yearago=nb_ls_1yearago if equines==1 
gen nb_other_ls_1yearago=nb_ls_1yearago if other_ls==1 
gen nb_cows_1yearago=nb_ls_1yearago if cows==1 
gen nb_chickens_1yearago=nb_ls_1yearago if chickens==1 
ren ag_r02 nb_ls_today
gen nb_cattle_today=nb_ls_today if cattle==1 
gen nb_smallrum_today=nb_ls_today if smallrum==1 
gen nb_poultry_today=nb_ls_today if poultry==1 
gen nb_equines_today=nb_ls_today if equines==1 
gen nb_other_ls_today=nb_ls_today if other_ls==1  
gen nb_cows_today=nb_ls_today if cows==1 
gen nb_chickens_today=nb_ls_today if chickens==1 
gen tlu_1yearago = nb_ls_1yearago * tlu_coefficient
gen tlu_today = nb_ls_today * tlu_coefficient
rename ag_r17 income_ls_sales 
rename ag_r16 nb_ls_sold

recode tlu_* nb_* (.=0)
collapse (sum) tlu_* nb_*  , by (case_id hhid)
lab var nb_cattle_1yearago "Number of cattle owned as of 12 months ago"
lab var nb_smallrum_1yearago "Number of small ruminant owned as of 12 months ago"
lab var nb_poultry_1yearago "Number of poultry as of 12 months ago"
lab var nb_equines_1yearago "Number of equines as of 12 months ago"
lab var nb_other_ls_1yearago "Number of other livestock (dog, donkey, and other) owned as of 12 months ago"
lab var nb_cows_1yearago "Number of cows owned as of 12 months ago"
lab var nb_chickens_1yearago "Number of chickens owned as of 12 months ago"
lab var nb_cattle_today "Number of cattle owned as of the time of survey"
lab var nb_smallrum_today "Number of small ruminant owned as of the time of survey"
lab var nb_poultry_today "Number of poultry as of the time of survey"
lab var nb_equines_today "Number of equines as of the time of survey"
lab var nb_other_ls_today "Number of other livestock (dog, donkey, and other) owned as of the time of survey"
lab var nb_cows_today "Number of cows owned as of the time of survey"
lab var nb_chickens_today "Number of chickens owned as of the time of survey"
lab var tlu_1yearago "Tropical Livestock Units as of 12 months ago"
lab var tlu_today "Tropical Livestock Units as of the time of survey"
lab var nb_ls_1yearago  "Number of livestock owned as of 12 months ago"
lab var nb_ls_1yearago  "Number of livestock owned as of 12 months ago"
lab var nb_ls_today "Number of livestock owned as of today"
drop tlu_coefficient
drop if case_id==""
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_TLU_Coefficients.dta", replace

************************
*GROSS CROP REVENUE // CG complete 2.29.24, will need update
************************
* Three things we are trying to accomplish with GROSS CROP REVENUE
* 1. Total value of all crop sales by hhid (summed up over all crops)
* 2. Total value of post harvest losses by hhid (summed up over all crops)
* 3. Amount sold (kgs) of unique crops by hhid

use "${MWI_IHS_IHPS_W4_raw_data}\AG_MOD_Q.dta", clear
	ren crop_code crop_code_long
	recode crop_code_long (100=49)(2=50)(3=51)(4=52)(5=53)(6=54)(7=55)(8=56)(9=57)(10=58)(11=59)(12=60)(13=61)(14=62)(15=63)(16=64)(17=65)(18=1800)(19=1900)(20=2000)(21=48)
	tempfile tree_perm
	save `tree_perm'

use "${MWI_IHS_IHPS_W4_raw_data}\AG_MOD_I.dta", clear
append using "${MWI_IHS_IHPS_W4_raw_data}\AG_MOD_O.dta"
rename crop_code crop_code_long
append using `tree_perm'

* Creating a value variable for value of crop sold
rename ag_i03 value
replace value = ag_o03 if  value==. & ag_o03!=.
replace value = ag_q03 if value==. & ag_q03!=.
recode value (.=0)

ren ag_i02a qty
replace qty = ag_o02a if qty==. & ag_o02a!=. 
replace qty=ag_q02a if qty==. & ag_o02a!=. 
gen unit=ag_i02b
replace unit= ag_o02b if unit==.
replace qty=ag_q02b if qty==. 
gen unit_os = ag_i02b_oth
replace unit_os= ag_q02b_oth if unit_os==""

replace qty =ag_i12a if qty==. & ag_i12a!=. //0 changes
replace unit=ag_i12b if unit==. & ag_i12b!=.
replace value= ag_i11 if value==. & ag_i11!=. 

*SS: I checked rainy, dry, tree/perm data for data on other specified crops and there are no fields that capture other specified crops - skipping the step of backfilling crop_code_long with data from other specified crops because of this.

* SS: This sections pulls data from other specified units and matches them with existing unit codes
*UNIT_OS code coming soon from AT and Micah

*Crop Code Labels
label define L0C /*these exist already*/ 1 "MAIZE LOCAL" 2 "MAIZE COMPOSITE/OPV" 3 "MAIZE HYBRID" 4 "MAIZE HYBRID RECYCLED" 5 "TOBACCO BURLEY" 6 "TOBACCO FLUE CURED" 7 "TOBACCO NNDF" 8 "TOBACCOSDF" 9 "TOBACCO ORIENTAL" 10 "OTHER TOBACCO (SPECIFY)" 11 "GROUNDNUT CHALIMBANA" 12 "GROUNDNUT CG7" 13 "GROUNDNUT MANIPINTA" 14 "GROUNDNUT MAWANGA" 15 "GROUNDNUT JL24" 16 "OTHER GROUNDNUT(SPECIFY)" 17 "RISE LOCAL" 18 "RISE FAYA" 19 "RISE PUSSA" 20 "RISE TCG10" 21 "RISE IET4094 (SENGA)" 22 "RISE WAMBONE" 23 "RISE KILOMBERO" 24 "RISE ITA" 25 "RISE MTUPATUPA" 26 "OTHER RICE(SPECIFY)"  28 "SWEET POTATO" 29 "IRISH [MALAWI] POTATO" 30 "WHEAT" 34 "BEANS" 35 "SOYABEAN" 36 "PIGEONPEA(NANDOLO" 37 "COTTON" 38 "SUNFLOWER" 39 "SUGAR CANE" 40 "CABBAGE" 41 "TANAPOSI" 42 "NKHWANI" 43 "THERERE/OKRA" 44 "TOMATO" 45 "ONION" 46 "PEA" 47 "PAPRIKA" 48 "OTHER (SPECIFY)"/*cleaning up these existing labels*/ 27 "GROUND BEAN (NZAMA)" 31 "FINGER MILLET (MAWERE)" 32 "SORGHUM" 33 "PEARL MILLET (MCHEWERE)" /*now creating unique codes for tree crops*/ 49 "CASSAVA" 50 "TEA" 51 "COFFEE" 52 "MANGO" 53 "ORANGE" 54 "PAWPAW/PAPAYA" 55 "BANANA" 56 "AVOCADO" 57 "GUAVA" 58 "LEMON" 59 "NAARTJE (TANGERINE)" 60 "PEACH" 61 "POZA (CUSTADE APPLE)" 62 "MASUKU (MEXICAN APPLE)" 63 "MASAU" 64 "PINEAPPLE" 65 "MACADEMIA" /*adding other specified crop codes*/ 105 "MAIZE GREEN" 203 "SWEET POTATO WHITE" 204 "SWEET POTATO ORANGE" 207 "PLANTAIN" 208 "COCOYAM (MASIMBI)" 301 "BEAN, WHITE" 302 "BEAN, BROWN" 308 "COWPEA (KHOBWE)" 405 "CHINESE CABBAGE" 409 "CUCUMBER" 410 "PUMPKIN" 1800 "FODDER TREES" 1900 "FERTILIZER TREES" 2000 "FUEL WOOD TREES", modify
label val crop_code_long L0C

*Unit Labels
label define unit_label 1 "Kilogram" 2 "50 kg Bag" 3 "90 kg Bag" 4 "Pail (small)" 5 "Pail (large)" 6 "No. 10 Plate" 7 "No. 12 Plate" 8 "Bunch" 9 "Piece" 10 "Bale" 11 "Basket" 12 "Ox-Cart" 13 "Other (specify)" 14 "Pail (medium)" 15 "Heap" 16 "Cup" 21 "Basin" 80 "Bunch (small)" 81 "Bunch (large)" 90 "Piece (small)" 91 "Piece (large)" 150 "Heap (small)" 151 "Heap (large)", modify
label val unit unit_label

ren ag_i02c condition 
replace condition= ag_o02c if condition==.
replace condition=3 if condition==.
tostring hhid, format(%18.0f) replace
recast str50 hhid, force 
merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", nogen keepusing(region district ta rural ea weight) keep(1 3)
***We merge Crop Sold Conversion Factor at the crop-unit-regional level***
merge m:1 region crop_code_long unit condition using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_cf.dta", gen(cf_merge) keep (1 3) //9,752 matched,  35,939 unmatched because raw data donot report any unit or value for the remaining observations; there's not much we can do to make more matches here 

***We merge Crop Sold Conversion Factor at the crop-unit-national level***
 
*We create Quantity Sold (kg using standard  conversion factor table for each crop- unit and region). 
replace conversion=conversion if region!=. //  We merge the national standard conversion factor for those hhid with missing regional info. 
gen kgs_sold = qty*conversion 
collapse (sum) value kgs_sold, by (hhid crop_code)
lab var value "Value of sales of this crop"
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_cropsales_value.dta", replace

//SS Question: Do we want 0s in the final data? For example, if a hh didn't sell any maize, do we still want to keep that data for 

use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_all_plots.dta", clear

collapse (sum) value_harvest quant_harv_kg, by (hhid case_id crop_code) // Update: SW We start using the standarized version of value harvested and kg harvested
merge 1:1 hhid crop_code using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_cropsales_value.dta"
replace value_harvest = value if value>value_harvest & value_!=. /* In a few cases, sales value reported exceeds the estimated value of crop harvest */
ren value value_crop_sales 
recode  value_harvest value_crop_sales  (.=0)
collapse (sum) value_harvest value_crop_sales, by (hhid case_id crop_code)
ren value_harvest value_crop_production
lab var value_crop_production "Gross value of crop production, summed over main and short season"
lab var value_crop_sales "Value of crops sold so far, summed over main and short season"
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_crop_values_production.dta", replace

collapse (sum) value_crop_production value_crop_sales, by (hhid)
lab var value_crop_production "Gross value of crop production for this household"
lab var value_crop_sales "Value of crops sold so far"
gen proportion_cropvalue_sold = value_crop_sales / value_crop_production
lab var proportion_cropvalue_sold "Proportion of crop value produced that has been sold"
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_crop_production.dta", replace

*Crops lost post-harvest
use "${MWI_IHS_IHPS_W4_raw_data}\AG_MOD_I.dta", clear
append using "${MWI_IHS_IHPS_W4_raw_data}\AG_MOD_O.dta"
drop if crop_code==. //302 observations deleted 
rename ag_i36d percent_lost
replace percent_lost = ag_o36d if percent_lost==. & ag_o36d!=.
replace percent_lost = 100 if percent_lost > 100 & percent_lost!=. 
tostring hhid, format(%18.0f) replace
merge m:1 hhid crop_code using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_crop_values_production.dta", nogen keep(1 3)
gen value_lost = value_crop_production * (percent_lost/100)
recode value_lost (.=0)
collapse (sum) value_lost, by (hhid)
rename value_lost crop_value_lost
lab var crop_value_lost "Value of crop production that had been lost by the time of survey"
recast str50 hhid, force 
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_crop_losses.dta", replace

****************************************************************************
*LIVESTOCK INCOME - CG complete 1.25.24
****************************************************************************
*Expenses
//can't do disaggregated expenses (no lrum or animal expenses)
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_r2.dta", clear
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_r1.dta"
rename ag_r26 cost_fodder_livestock       /* VAP: MW4 has no separate cost_water_livestock */
rename ag_r27 cost_vaccines_livestock     /* Includes medicines */
rename ag_r28 cost_othervet_livestock     /* VAP: TZ didn't have this. Includes dipping, deworming, AI */
gen cost_medical_livestock = cost_vaccines_livestock + cost_othervet_livestock /* VAP: Combining the two categories for later. */
rename ag_r25 cost_hired_labor_livestock 
rename ag_r29 cost_input_livestock        /* VAP: TZ didn't have this. Includes housing equipment, feeding utensils */
recode cost_fodder_livestock cost_vaccines_livestock cost_othervet_livestock cost_medical_livestock cost_hired_labor_livestock cost_input_livestock(.=0)

preserve
	keep if inlist(ag_r0a, 301, 302, 303, 304, 3304) // VAP: Livestock code
	collapse (sum) cost_fodder_livestock cost_vaccines_livestock cost_othervet_livestock cost_hired_labor_livestock cost_input_livestock, by (hhid case_id)
	egen cost_lrum = rowtotal (cost_fodder_livestock cost_vaccines_livestock cost_othervet_livestock cost_hired_labor_livestock cost_input_livestock)
	keep hhid case_id cost_lrum
	lab var cost_lrum "Livestock expenses for large ruminants"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_lrum_expenses", replace
restore 

preserve 
	rename ag_r0a livestock_code
	gen species = (inlist(livestock_code, 301,302,303,304,3304)) + 2*(inlist(livestock_code,307,308)) + 3*(livestock_code==309) + 4*(livestock_code==3305) + 5*(inlist(livestock_code, 311,313,315,319,3310,3314))
	recode species (0=.)
	la def species 1 "Large ruminants (calf, steer/heifer, cow, bull, ox)" 2 "Small ruminants (sheep, goats)" 3 "Pigs" 4 "Equine (horses, donkeys)" 5 "Poultry"
	la val species species

	collapse (sum) cost_medical_livestock, by (hhid case_id species) 
	rename cost_medical_livestock ls_exp_med
		foreach i in ls_exp_med{
			gen `i'_lrum = `i' if species==1
			gen `i'_srum = `i' if species==2
			gen `i'_pigs = `i' if species==3
			gen `i'_equine = `i' if species==4
			gen `i'_poultry = `i' if species==5
		}
	
collapse (firstnm) *lrum *srum *pigs *equine *poultry, by(hhid case_id)

	foreach i in ls_exp_med{
		gen `i' = .
	}
	la var ls_exp_med "Cost for vaccines and veterinary treatment for livestock"
	
	foreach i in ls_exp_med{
		local l`i' : var lab `i'
		lab var `i'_lrum "`l`i'' - large ruminants"
		lab var `i'_srum "`l`i'' - small ruminants"
		lab var `i'_pigs "`l`i'' - pigs"
		lab var `i'_equine "`l`i'' - equine"
		lab var `i'_poultry "`l`i'' - poultry"
	}
	drop ls_exp_med
	save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_expenses_animal", replace
restore 

collapse (sum) cost_fodder_livestock cost_vaccines_livestock cost_othervet_livestock  cost_hired_labor_livestock cost_input_livestock, by (hhid case_id)
lab var cost_fodder_livestock "Cost for fodder for <livestock>"
lab var cost_vaccines_livestock "Cost for vaccines and veterinary treatment for <livestock>"
lab var cost_othervet_livestock "Cost for other veterinary treatments for <livestock> (incl. dipping, deworming, AI)"
*lab var cost_medical_livestock "Cost for all veterinary services (total vaccine plus othervet)"
lab var cost_hired_labor_livestock "Cost for hired labor for <livestock>"
lab var cost_input_livestock "Cost for livestock inputs (incl. housing, equipment, feeding utensils)"
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_livestock_expenses.dta", replace

*Livestock products 
* Milk
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_s.dta", clear
rename ag_s0a livestock_code
keep if livestock_code==401
rename ag_s02 no_of_months_milk // VAP: During the last 12 months, for how many months did your household produce any [PRODUCT]?
rename ag_s03a qty_milk_per_month // VAP: During these months, what was the average quantity of [PRODUCT] produced PER MONTH?. 
gen milk_liters_produced = no_of_months_milk * qty_milk_per_month if ag_s03b==1 // VAP: Only including liters, not including 2 obsns in "buckets". 
lab var milk_liters_produced "Liters of milk produced in past 12 months"

gen liters_sold_12m = ag_s05a if ag_s05b==1 // VAP: Keeping only units in liters
rename ag_s06 earnings_milk_year
gen price_per_liter = earnings_milk_year/liters_sold_12m if liters_sold_12m > 0
gen price_per_unit = price_per_liter // RH: why do we need per liter and per unit if the same?
gen quantity_produced = milk_liters_produced
recode price_per_liter price_per_unit (0=.) //RH Question: is turning 0s to missing on purpose? Or is this backwards? 
keep hhid case_id livestock_code milk_liters_produced price_per_liter price_per_unit quantity_produced earnings_milk_year //why do we need both per liter and per unit if the same?
lab var price_per_liter "Price of milk per liter sold"
lab var price_per_unit "Price of milk per unit sold" 
lab var quantity_produced "Quantity of milk produced"
lab var earnings_milk_year "Total earnings of sale of milk produced"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products_milk", replace

* Other livestock products  // VAP: Includes milk, eggs, meat, hides/skins and manure. No honey in MW2. TZ does not have meat and manure. - RH complete 7/29
use "${MWI_IHS_IHPS_W4_raw_data}\AG_MOD_S.dta", clear
rename ag_s0a livestock_code
rename ag_s02 months_produced
rename ag_s03a quantity_month
rename ag_s03b quantity_month_unit

drop if livestock_code == 401 //RH edit. Removing milk from "other" dta, will be added back in for all livestock products file
replace quantity_month = round(quantity_month/0.06) if livestock_code==402 & quantity_month_unit==2 // VAP: converting obsns in kgs to pieces for eggs 
// using MW IHS Food Conversion factors.pdf. Cannot convert ox-cart & ltrs. 
replace quantity_month_unit = 3 if livestock_code== 402 & quantity_month_unit==2
replace quantity_month_unit =. if livestock_code==402 & quantity_month_unit!=3        // VAP: chicken eggs, pieces
replace quantity_month_unit =. if livestock_code== 403 & quantity_month_unit!=3      // guinea fowl eggs, pieces
replace quantity_month = quantity_month*1.5 if livestock_code==404 & quantity_month_unit==3 // VAP: converting pieces to kgs for meat, 
// using conversion for chicken. Cannot convert ltrs & buckets.  
replace quantity_month_unit = 2 if livestock_code== 404 & quantity_month_unit==3
replace quantity_month_unit =. if livestock_code==404 & quantity_month_unit!=2     // VAP: now, only keeping kgs for meat
replace quantity_month_unit =. if livestock_code== 406 & quantity_month_unit!=3   // VAP: skin and hide, pieces. Not converting kg and bucket.
replace quantity_month_unit =. if livestock_code== 407 & quantity_month_unit!=2 // VAP: manure, using only obsns in kgs. 
// This is a bigger problem, as there are many obsns in bucket, wheelbarrow & ox-cart but no conversion factors.
recode months_produced quantity_month (.=0) 
gen quantity_produced = months_produced * quantity_month // Units are liters for milk, pieces for eggs & skin, kg for meat and manure. 
lab var quantity_produced "Quantity of this product produced in past year"

rename ag_s05a sales_quantity
rename ag_s05b sales_unit
*replace sales_unit =. if livestock_code==401 & sales_unit!=1 // milk, liters only
replace sales_unit =. if livestock_code==402 & sales_unit!=3  // chicken eggs, pieces only
replace sales_unit =. if livestock_code== 403 & sales_unit!=3   // guinea fowl eggs, pieces only
replace sales_quantity = sales_quantity*1.5 if livestock_code==404 & sales_unit==3 // VAP: converting obsns in pieces to kgs for meat. Using conversion for chicken. 
replace sales_unit = 2 if livestock_code== 404 & sales_unit==3 // VAP: kgs for meat
replace sales_unit =. if livestock_code== 406 & sales_unit!=3   // VAP: pieces for skin and hide, not converting kg.
replace sales_unit =. if livestock_code== 407 & quantity_month_unit!=2  // VAP: kgs for manure, not converting liters(1 obsn), bucket, wheelbarrow & oxcart

rename ag_s06 earnings_sales
recode sales_quantity months_produced quantity_month earnings_sales (.=0)
gen price_per_unit = earnings_sales / sales_quantity
keep hhid case_id livestock_code quantity_produced price_per_unit earnings_sales

label define livestock_code_label 402 "Chicken Eggs" 403 "Guinea Fowl Eggs" 404 "Meat" 406 "Skin/Hide" 407 "Manure" 408 "Other" //RH - added "other" lbl to 408, removed 401 "Milk"
label values livestock_code livestock_code_label
bys livestock_code: sum price_per_unit
gen price_per_unit_hh = price_per_unit
lab var price_per_unit "Price per unit sold"
lab var price_per_unit_hh "Price per unit sold at household level"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products_other", replace

*All Livestock Products
use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products_milk", clear
append using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products_other"
recode price_per_unit (0=.)
merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta" //no stratum in hhids
drop if _merge==2
drop _merge
replace price_per_unit = . if price_per_unit == 0 
lab var price_per_unit "Price per unit sold"
lab var quantity_produced "Quantity of product produced"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products", replace

* EA Level
use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products", clear
keep if price_per_unit !=. 
gen observation = 1
bys region district ea ta livestock_code: egen obs_ea = count(observation)
collapse (median) price_per_unit [aw=weight], by (region district ea ta livestock_code obs_ea)
rename price_per_unit price_median_ea
lab var price_median_ea "Median price per unit for this livestock product in the ea"
lab var obs_ea "Number of sales observations for this livestock product in the ea"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products_prices_ea.dta", replace

*No ward data available 

* ta Level
use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys region district ea ta livestock_code: egen obs_ta = count(observation)
collapse (median) price_per_unit [aw=weight], by (region district ea ta livestock_code obs_ta)
rename price_per_unit price_median_ta
lab var price_median_ta "Median price per unit for this livestock product in the ta"
lab var obs_ta "Number of sales observations for this livestock product in the ta"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products_prices_ta.dta", replace 

//updated above 
* District Level
use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys region district livestock_code: egen obs_district = count(observation)
collapse (median) price_per_unit [aw=weight], by (region district livestock_code obs_district)
rename price_per_unit price_median_district
lab var price_median_district "Median price per unit for this livestock product in the district"
lab var obs_district "Number of sales observations for this livestock product in the district"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products_prices_district.dta", replace

* Region Level
use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys region livestock_code: egen obs_region = count(observation)
collapse (median) price_per_unit [aw=weight], by (region livestock_code obs_region)
rename price_per_unit price_median_region
lab var price_median_region "Median price per unit for this livestock product in the region"
lab var obs_region "Number of sales observations for this livestock product in the region"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products_prices_region.dta", replace

* Country Level
use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys livestock_code: egen obs_country = count(observation)
collapse (median) price_per_unit [aw=weight], by (livestock_code obs_country)
rename price_per_unit price_median_country
lab var price_median_country "Median price per unit for this livestock product in the country"
lab var obs_country "Number of sales observations for this livestock product in the country"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products_prices_country.dta", replace

use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products", clear
merge m:1 region district ea ta livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products_prices_ea.dta", nogen
merge m:1 region district ea ta livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products_prices_ta.dta", nogen
merge m:1 region district livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products_prices_district.dta", nogen
merge m:1 region livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products_prices_region.dta", nogen
merge m:1 livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_products_prices_country.dta", nogen
replace price_per_unit = price_median_ea if price_per_unit==. & obs_ea >= 10
replace price_per_unit = price_median_ta if price_per_unit==. & obs_ta >= 10
replace price_per_unit = price_median_district if price_per_unit==. & obs_district >= 10 
replace price_per_unit = price_median_region if price_per_unit==. & obs_region >= 10 
replace price_per_unit = price_median_country if price_per_unit==.
lab var price_per_unit "Price per unit of this livestock product, with missing values imputed using local median values" 

gen value_milk_produced = milk_liters_produced * price_per_unit 
gen value_eggs_produced = quantity_produced * price_per_unit if livestock_code==402|livestock_code==403
gen value_other_produced = quantity_produced * price_per_unit if livestock_code== 404|livestock_code==406|livestock_code==407|livestock_code==408
egen sales_livestock_products = rowtotal(earnings_sales earnings_milk_year)		
collapse (sum) value_milk_produced value_eggs_produced value_other_produced sales_livestock_products, by (hhid case_id)

*First, constructing total value
egen value_livestock_products = rowtotal(value_milk_produced value_eggs_produced value_other_produced)
lab var value_livestock_products "value of livestock prodcuts produced (milk, eggs, other)"
*Now, the share
gen share_livestock_prod_sold = sales_livestock_products/value_livestock_products
replace share_livestock_prod_sold = 1 if share_livestock_prod_sold>1 & share_livestock_prod_sold!=.
lab var share_livestock_prod_sold "Percent of production of livestock products that is sold" 
lab var value_milk_produced "Value of milk produced"
lab var value_eggs_produced "Value of eggs produced"
lab var value_other_produced "Value of skins, meat and manure produced"
recode value_milk_produced value_eggs_produced value_other_produced (0=.)
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hh_livestock_products", replace

* Manure (Dung in TZ)
use "${MWI_IHS_IHPS_W4_raw_data}\AG_MOD_S.dta", clear
rename ag_s0a livestock_code
rename ag_s06 earnings_sales
gen sales_manure=earnings_sales if livestock_code==407 
recode sales_manure (.=0)
collapse (sum) sales_manure, by (hhid case_id)
lab var sales_manure "Value of manure sold" 
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_manure.dta", replace 

*Sales (live animals) //w4 has no slaughter questions
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_r1.dta", clear
rename ag_r0a livestock_code
rename ag_r17 income_live_sales     // total value of sales of [livestock] live animals last 12m -- RH note, w3 label doesn't include "during last 12m"
rename ag_r16 number_sold          // # animals sold alive last 12 m
*rename ag_r19 number_slaughtered  // # animals slaughtered last 12 m - Not available in w4
/* VAP: no slaughter questions in w4
rename lf02_32 number_slaughtered_sold  // # of slaughtered animals sold
replace number_slaughtered = number_slaughtered_sold if number_slaughtered < number_slaughtered_sold  
rename lf02_33 income_slaughtered // # total value of sales of slaughtered animals last 12m
*/
rename ag_r11 value_livestock_purchases // tot. value of purchase of live animals last 12m
recode income_live_sales number_sold /*number_slaughtered*/ /*number_slaughtered_sold income_slaughtered*/ value_livestock_purchases (.=0)
gen price_per_animal = income_live_sales / number_sold
lab var price_per_animal "Price of live animals sold"
recode price_per_animal (0=.) 
merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta"
drop if _merge==2
drop _merge
keep hhid case_id weight region district ta ea livestock_code number_sold income_live_sales /*number_slaughtered*/ /*number_slaughtered_sold income_slaughtered*/ price_per_animal value_livestock_purchases
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hh_livestock_sales", replace // RH complete - no slaughter questions in w4

*Implicit prices 
		
* EA Level
use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region district ta ea livestock_code: egen obs_ea = count(observation)
collapse (median) price_per_animal [aw=weight], by (region district ta ea livestock_code obs_ea)
rename price_per_animal price_median_ea
lab var price_median_ea "Median price per unit for this livestock in the ea"
lab var obs_ea "Number of sales observations for this livestock in the ea"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_ea.dta", replace 

* ta Level
use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region district ea ta livestock_code: egen obs_ta = count(observation)
collapse (median) price_per_animal [aw=weight], by (region district ea ta livestock_code obs_ta)
rename price_per_animal price_median_ta
lab var price_median_ta "Median price per unit for this livestock in the ta"
lab var obs_ta "Number of sales observations for this livestock in the ta"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_ta.dta", replace 

* District Level
use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region district livestock_code: egen obs_district = count(observation)
collapse (median) price_per_animal [aw=weight], by (region district livestock_code obs_district)
rename price_per_animal price_median_district
lab var price_median_district "Median price per unit for this livestock in the district"
lab var obs_district "Number of sales observations for this livestock in the district"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_district.dta", replace

* Region Level
use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region livestock_code: egen obs_region = count(observation)
collapse (median) price_per_animal [aw=weight], by (region livestock_code obs_region)
rename price_per_animal price_median_region
lab var price_median_region "Median price per unit for this livestock in the region"
lab var obs_region "Number of sales observations for this livestock in the region"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_region.dta", replace

* Country Level
use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys livestock_code: egen obs_country = count(observation)
collapse (median) price_per_animal [aw=weight], by (livestock_code obs_country)
rename price_per_animal price_median_country
lab var price_median_country "Median price per unit for this livestock in the country"
lab var obs_country "Number of sales observations for this livestock in the country"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_country.dta", replace 

*no ward data available for W4

use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hh_livestock_sales", clear
merge m:1 region district ea ta livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_ea.dta", nogen
merge m:1 region district ea ta livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_ta.dta", nogen
merge m:1 region district livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_district.dta", nogen
merge m:1 region livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_region.dta", nogen
merge m:1 livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_country.dta", nogen
replace price_per_animal = price_median_ea if price_per_animal==. & obs_ea >= 10
replace price_per_animal = price_median_ta if price_per_animal==. & obs_ta >= 10
replace price_per_animal = price_median_district if price_per_animal==. & obs_district >= 10
replace price_per_animal = price_median_region if price_per_animal==. & obs_region >= 10
replace price_per_animal = price_median_country if price_per_animal==. 
lab var price_per_animal "Price per animal sold, imputed with local median prices if household did not sell"
gen value_lvstck_sold = price_per_animal * number_sold
*no slaughter questions in w4

collapse (sum) /*value_livestock_sales*/ value_livestock_purchases value_lvstck_sold /*value_slaughtered*/, by (hhid case_id)
drop if hhid==""
*lab var value_livestock_sales "Value of livestock sold (live and slaughtered)"
lab var value_livestock_purchases "Value of livestock purchases"
*lab var value_slaughtered "Value of livestock slaughtered (with slaughtered livestock that weren't sold valued at local median prices for live animal sales)"
lab var value_lvstck_sold "Value of livestock sold live" 
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_sales", replace 

*TLU (Tropical Livestock Units)
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_r1.dta", clear
rename ag_r0a livestock_code 
gen tlu_coefficient=0.5 if (livestock_code==301|livestock_code==302|livestock_code==303|livestock_code==304|livestock_code==3304) // calf, steer/heifer, cow, bull, ox
replace tlu_coefficient=0.1 if (livestock_code==307|livestock_code==308) //goats, sheep
replace tlu_coefficient=0.2 if (livestock_code==309) // pigs
replace tlu_coefficient=0.01 if (livestock_code==311|livestock_code==313|livestock_code==315|livestock_code==319|livestock_code==3310|livestock_code==3314) // local hen, cock, duck, dove/pigeon, chicken layer/broiler, turkey/guinea fowl
replace tlu_coefficient=0.3 if (livestock_code==3305) // donkey/mule/horse
lab var tlu_coefficient "Tropical Livestock Unit coefficient"
rename ag_r07 number_1yearago
rename ag_r02 number_today_total
rename ag_r03 number_today_exotic
gen number_today_indigenous = number_today_total - number_today_exotic
recode number_today_total number_today_indigenous number_today_exotic (.=0)
*gen number_today = number_today_indigenous + number_today_exotic // already exists (number_today_total)
gen tlu_1yearago = number_1yearago * tlu_coefficient
gen tlu_today = number_today_total * tlu_coefficient
rename ag_r17 income_live_sales 
rename ag_r16 number_sold
rename ag_r21b lost_disease // VAP: Includes lost to injury in MW2
*rename lf02_22 lost_injury 
rename ag_r19 lost_stolen // # of livestock lost or stolen in last 12m
egen mean_12months = rowmean(number_today_total number_1yearago)
egen animals_lost12months = rowtotal(lost_disease lost_stolen)	
gen share_imp_herd_cows = number_today_exotic/(number_today_total) if livestock_code==303 // VAP: only cows, not including calves, steer/heifer, ox and bull
gen species = (inlist(livestock_code,301,302,202,204,3304)) + 2*(inlist(livestock_code,307,308)) + 3*(livestock_code==309) + 4*(livestock_code==3305) + 5*(inlist(livestock_code,311,313,315,319,3310,3314))
recode species (0=.)
la def species 1 "Large ruminants (calves, steer/heifer, cows, bulls, oxen)" 2 "Small ruminants (sheep, goats)" 3 "Pigs" 4 "Equine (horses, donkeys, mules)" 5 "Poultry"
la val species species

preserve
	*Now to household level
	*First, generating these values by species
	collapse (firstnm) share_imp_herd_cows (sum) number_today_total number_1yearago animals_lost12months lost_disease /*ihs*/ number_today_exotic lvstck_holding=number_today_total, by(hhid case_id species)
	egen mean_12months = rowmean(number_today_total number_1yearago)
	gen any_imp_herd = number_today_exotic!=0 if number_today_total!=. & number_today_total!=0
	
foreach i in animals_lost12months mean_12months any_imp_herd lvstck_holding lost_disease /*ihs*/{
		gen `i'_lrum = `i' if species==1
		gen `i'_srum = `i' if species==2
		gen `i'_pigs = `i' if species==3
		gen `i'_equine = `i' if species==4
		gen `i'_poultry = `i' if species==5
	}

	*Now we can collapse to household (taking firstnm because these variables are only defined once per household)
	collapse (sum) number_today_total number_today_exotic (firstnm) *lrum *srum *pigs *equine *poultry share_imp_herd_cows, by(hhid case_id)
	*Overall any improved herd
	gen any_imp_herd = number_today_exotic!=0 if number_today_total!=0
	drop number_today_exotic number_today_total
	
	foreach i in lvstck_holding animals_lost12months mean_12months lost_disease /*ihs*/{
		gen `i' = .
	}
	la var lvstck_holding "Total number of livestock holdings (# of animals)"
	la var any_imp_herd "At least one improved animal in herd"
	la var share_imp_herd_cows "Share of improved animals in total herd - Cows only"
	lab var animals_lost12months  "Total number of livestock  lost in last 12 months"
	lab var  mean_12months  "Average number of livestock  today and 1  year ago"
	lab var lost_disease "Total number of livestock lost to disease or injury" //ihs
	
	foreach i in any_imp_herd lvstck_holding animals_lost12months mean_12months lost_disease /*ihs*/{
		local l`i' : var lab `i'
		lab var `i'_lrum "`l`i'' - large ruminants"
		lab var `i'_srum "`l`i'' - small ruminants"
		lab var `i'_pigs "`l`i'' - pigs"
		lab var `i'_equine "`l`i'' - equine"
		lab var `i'_poultry "`l`i'' - poultry"
	}	
	la var any_imp_herd "At least one improved animal in herd - all animals" 
	*Now dropping these missing variables, which I only used to construct the labels above
	
	*Total livestock holding for large ruminants, small ruminants, and poultry
	gen lvstck_holding_all = lvstck_holding_lrum + lvstck_holding_srum + lvstck_holding_poultry
	la var lvstck_holding_all "Total number of livestock holdings (# of animals) - large ruminants, small ruminants, poultry"
	
	*any improved large ruminants, small ruminants, or poultry
	gen any_imp_herd_all = 0 if any_imp_herd_lrum==0 | any_imp_herd_srum==0 | any_imp_herd_poultry==0
	replace any_imp_herd_all = 1 if  any_imp_herd_lrum==1 | any_imp_herd_srum==1 | any_imp_herd_poultry==1
	lab var any_imp_herd_all "1=hh has any improved lrum, srum, or poultry"
	
	recode lvstck_holding* (.=0)
	drop lvstck_holding animals_lost12months mean_12months lost_disease /*ihs*/
	save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_herd_characteristics", replace
restore
	
gen price_per_animal = income_live_sales / number_sold
merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta"
drop if _merge==2
drop _merge
merge m:1 region district ta ea livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_ea.dta", nogen
merge m:1 region district ta ea livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_ta.dta", nogen
merge m:1 region district livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_district.dta", nogen
merge m:1 region livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_region.dta", nogen
merge m:1 livestock_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_prices_country.dta", nogen		
recode price_per_animal (0=.)
replace price_per_animal = price_median_ea if price_per_animal==. & obs_ea >= 10
replace price_per_animal = price_median_ta if price_per_animal==. & obs_ta >= 10
replace price_per_animal = price_median_district if price_per_animal==. & obs_district >= 10
replace price_per_animal = price_median_region if price_per_animal==. & obs_region >= 10
replace price_per_animal = price_median_country if price_per_animal==. 
lab var price_per_animal "Price per animal sold, imputed with local median prices if household did not sell"
gen value_1yearago = number_1yearago * price_per_animal
gen value_today = number_today_total * price_per_animal
collapse (sum) tlu_1yearago tlu_today value_1yearago value_today, by (hhid case_id)
lab var tlu_1yearago "Tropical Livestock Units as of 12 months ago"
lab var tlu_today "Tropical Livestock Units as of the time of survey"
gen lvstck_holding_tlu = tlu_today
lab var lvstck_holding_tlu "Total HH livestock holdings, TLU"  
lab var value_1yearago "Value of livestock holdings from one year ago"
lab var value_today "Value of livestock holdings today"
drop if hhid==""
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_TLU.dta", replace

*Livestock income
use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_sales", clear
merge 1:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hh_livestock_products", nogen
merge 1:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_manure.dta", nogen
merge 1:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_expenses", nogen
merge 1:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_TLU.dta", nogen

gen livestock_income = value_lvstck_sold + /*value_slaughtered*/ - value_livestock_purchases /*
*/ + (value_milk_produced + value_eggs_produced + value_other_produced + sales_manure) /*
*/ - (cost_hired_labor_livestock + cost_fodder_livestock + cost_vaccines_livestock + cost_othervet_livestock + cost_input_livestock)

lab var livestock_income "Net livestock income"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_income.dta", replace

****************************************************************************
*FISH INCOME - Checked, under review CG 2.12.2024
****************************************************************************
*Fishing expenses  
//Method of calculating ft and pt weeks and days consistent with ag module indicators for rainy/dry seasons
use "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_c.dta", clear
append using "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_g.dta"

rename fs_c01a weeks_ft_fishing_high // FT weeks, high season
replace weeks_ft_fishing_high= fs_g01a if weeks_ft_fishing_high==. // FT weeks, low season
rename fs_c02a weeks_pt_fishing_high // PT weeks, high season
replace weeks_pt_fishing_high= fs_g02a if weeks_pt_fishing_high==. // PT weeks, low season
gen weeks_fishing = weeks_ft_fishing_high + weeks_pt_fishing_high

rename fs_c01b days_ft_fishing_high // FT, days, high season
replace days_ft_fishing_high= fs_g01b if days_ft_fishing_high==. // FT days, low season
rename fs_c02b days_pt_fishing_high // PT days, high season
replace days_pt_fishing_high= fs_g02b if days_pt_fishing_high==. // PT days, low season
gen days_per_week = days_ft_fishing_high + days_pt_fishing_high

recode weeks_fishing days_per_week (.=0)
 
collapse (max) weeks_fishing days_per_week, by (hhid case_id) 
keep hhid weeks_fishing days_per_week
lab var weeks_fishing "Weeks spent working as a fisherman (maximum observed across individuals in household)"
lab var days_per_week "Days per week spent working as a fisherman (maximum observed across individuals in household)"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_weeks_fishing.dta", replace


* Fisheries Input
use "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_d1.dta", clear // FS MOD D (HIGH season) Q1-6
	append using "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_d2.dta"  // FS (HIGH season) MOD D Q7-13
	append using "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_d3.dta" // FS (HIGH season) MOD D Q14-24
append using "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_h1.dta" // FS (LOW season) MOD H Q1-6
	append using "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_h2.dta" // FS (LOW season) MOD H Q7-13
	append using "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_h3.dta" // FS (LOW season) MOD H Q14-24
merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_weeks_fishing.dta"
rename weeks_fishing weeks
rename fs_d13 fuel_costs_week
replace fuel_costs_week = fs_h13 if fuel_costs_week==.
rename fs_d12 rental_costs_fishing // VAP: Boat/Engine rental.
replace rental_costs_fishing=fs_h12 if rental_costs_fishing==.
rename fs_d06 gear_rent // HKS 6.29.23: not in W2; adding in bc available 
replace gear_rent=fs_h06 if gear_rent==.
rename fs_d10 purchase_costs_fishing // VAP: Boat/Engine purchase. Purchase cost is additional in MW2, TZ code does not have this. 
replace purchase_costs_fishing=fs_h10 if purchase_costs_fishing==. 
rename fs_d04 purchase_gear_cost // HKS 6.29.23: not in W2; adding in bc available 
replace purchase_gear_cost = fs_h04 if purchase_gear_cost ==.
recode weeks fuel_costs_week rental_costs_fishing  purchase_costs_fishing(.=0)
gen cost_fuel = fuel_costs_week * weeks
preserve
 
collapse (sum) cost_fuel rental_costs_fishing, by (hhid case_id)
lab var cost_fuel "Costs for fuel over the past year"
lab var rental_costs_fishing "Costs for other fishing expenses over the past year"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_fishing_expenses_1.dta", replace // VAP: Not including hired labor costs, keeping consistent with TZ. Can add this for MW if needed. 
restore

* Other fishing costs  
rename fs_d24a total_cost_high // total other costs in high season, only 6 obsns. 
	replace total_cost_high=fs_h24a if total_cost_high==.
rename fs_d24b unit
	replace unit=fs_h24b if unit==. 
gen cost_paid = total_cost_high if unit== 2  // season
	replace cost_paid = total_cost_high * weeks if unit==1 // weeks
	 
collapse (sum) cost_paid, by (hhid case_id) // HKS 6/29/23; there are very few hh with additional expense here (4/1209 obs)
lab var cost_paid "Other costs paid for fishing activities"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_fishing_expenses_2.dta", replace

* Fish Prices
use "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_e1.dta", clear
append using "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_i1.dta"
rename fs_e02 fish_code 
replace fish_code=fs_i02 if fish_code==. 
recode fish_code (12=11) // recoding "aggregate" from low season to "other"
rename fs_e06a fish_quantity_year // high season
replace fish_quantity_year=fs_i06a if fish_quantity_year==. // low season
rename fs_e06b fish_quantity_unit
replace fish_quantity_unit=fs_i06b if fish_quantity_unit==.
rename fs_e08b unit  // piece, dozen/bundle, kg, small basket, large basket
replace unit=fs_e04b if unit==. 
replace unit=fs_e08h if unit==. 
replace unit=fs_e11b if unit==. 
replace unit=fs_e11g if unit==. 
replace unit=fs_i04b if unit==. //118 changes made
replace unit=fs_i08b if unit==.
replace unit=fs_i08h if unit==.
replace unit=fs_i11b if unit==. 
replace unit=fs_i11g if unit==.  

gen price_per_unit = fs_e08d // VAP: This is already avg. price per packaging unit. Did not divide by avg. qty sold per week similar to TZ, seems to be an error?
replace price_per_unit = fs_i08d if price_per_unit==.
merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", nogen keep(1 3)
recode price_per_unit (0=.) 
collapse (median) price_per_unit [aw=weight], by (fish_code unit)
rename price_per_unit price_per_unit_median
replace price_per_unit_median = . if fish_code==11
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_fish_prices.dta", replace

* Value of fish harvest & sales 
use "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_e1.dta", clear
append using "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_i1.dta"

rename fs_e02 fish_code 
replace fish_code=fs_i02 if fish_code==. 
recode fish_code (12=11) // recoding "aggregate" from low season to "other"
rename fs_e06a fish_quantity_year // high season
replace fish_quantity_year=fs_i06a if fish_quantity_year==. // low season
rename fs_e06b unit  // piece, dozen/bundle, kg, small basket, large basket
merge m:1 fish_code unit using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_fish_prices.dta",  nogen keep(1 3)
rename fs_e08a quantity_1 // "How much [fish species] did your hh sell?"
replace quantity_1=fs_i08a if quantity_1==.
rename fs_e08b unit_1	// "Identify type of packaging.."
replace unit_1=fs_i08b if unit_1==.
gen price_unit_1 = fs_e08d // not divided by qty unlike TZ, not sure about the logic of dividing here. // "Identify form of processing for..."
replace price_unit_1=fs_i08d if price_unit_1==.
rename fs_e08g quantity_2 // "How much [fish species] did your hh sell?"
replace quantity_2=fs_i08g if quantity_2==.
rename fs_e08h unit_2 // form of packaging
replace unit_2= fs_i08h if unit_2==.
gen price_unit_2=fs_e08j // not divided by qty unlike TZ. // form of processing
replace price_unit_2=fs_i08j if price_unit_2==.

recode quantity_1 quantity_2 fish_quantity_year (.=0)
gen income_fish_sales = (quantity_1 * price_unit_1) + (quantity_2 * price_unit_2)
gen value_fish_harvest = (fish_quantity_year * price_unit_1) if unit==unit_1 
replace value_fish_harvest = (fish_quantity_year * price_per_unit_median) if value_fish_harvest==.
 
collapse (sum) value_fish_harvest income_fish_sales, by (hhid case_id)
recode value_fish_harvest income_fish_sales (.=0)
lab var value_fish_harvest "Value of fish harvest (including what is sold), with values imputed using a national median for fish-unit-prices"
lab var income_fish_sales "Value of fish sales"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_fish_income.dta", replace

*Fish trading
use "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_c.dta", clear
append using "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_g.dta"
drop case_id
merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", keep (1 3)
 
ren PID indiv
rename fs_c04a weeks_fish_trading 
replace weeks_fish_trading=fs_g04a if weeks_fish_trading==.
recode weeks_fish_trading (.=0)
collapse (max) weeks_fish_trading, by (hhid case_id)
//keep hhid case_id indiv weeks_fish_trading case_id ea_id 
lab var weeks_fish_trading "Weeks spent working as a fish trader (maximum observed across individuals in household)"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_weeks_fish_trading.dta", replace

use "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_f1.dta", clear
//append using "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_f2.dta"
append using "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_j1.dta"
//append using "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_j2.dta"

rename fs_f02a quant_fish_purchased_1
replace quant_fish_purchased_1= fs_j02a if quant_fish_purchased_1==.
rename fs_f02f price_fish_purchased_1 // avg price per packaging unit
replace price_fish_purchased_1= fs_j02f if price_fish_purchased_1==.
rename fs_f02h quant_fish_purchased_2
replace quant_fish_purchased_2= fs_j02h if quant_fish_purchased_2==. 
rename fs_f02m price_fish_purchased_2 // avg price per packaging unit
replace price_fish_purchased_2= fs_j02m if price_fish_purchased_2==.
rename fs_f03a quant_fish_sold_1
replace quant_fish_sold_1=fs_j03a if quant_fish_sold_1==.
rename fs_f03f price_fish_sold_1
replace price_fish_sold_1=fs_j03f if price_fish_sold_1==.
rename fs_f03h quant_fish_sold_2
replace quant_fish_sold_2=fs_j03g if quant_fish_sold_2==.
rename fs_f03m price_fish_sold_2
replace price_fish_sold_2=fs_j03l if price_fish_sold_2==.
/* VAP: Had added other costs here, but commenting out to be consistent with TZ. 
rename fs_f05 other_costs_fishtrading // VAP: Hired labor, transport, packaging, ice, tax in MW2, not in TZ.
replace other_costs_fishtrading=fs_j05 if other_costs_fishtrading==. 
*/
recode quant_fish_purchased_1 price_fish_purchased_1 quant_fish_purchased_2 price_fish_purchased_2 quant_fish_sold_1 price_fish_sold_1 quant_fish_sold_2 price_fish_sold_2 /*other_costs_fishtrading*/(.=0)

gen weekly_fishtrade_costs = (quant_fish_purchased_1 * price_fish_purchased_1) + (quant_fish_purchased_2 * price_fish_purchased_2) /*+ other_costs_fishtrading*/
gen weekly_fishtrade_revenue = (quant_fish_sold_1 * price_fish_sold_1) + (quant_fish_sold_2 * price_fish_sold_2)
gen weekly_fishtrade_profit = weekly_fishtrade_revenue - weekly_fishtrade_costs
 
collapse (sum) weekly_fishtrade_profit, by (hhid case_id)
lab var weekly_fishtrade_profit "Average weekly profits from fish trading (sales minus purchases), summed across individuals"
keep hhid weekly_fishtrade_profit case_id
//drop case_id
//merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", keep (1 3)
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_fish_trading_revenues.dta", replace   


use "${MWI_IHS_IHPS_W4_raw_data}\fs_mod_f2.dta", clear
drop case_id
merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", keep (1 3)
rename fs_f05 weekly_costs_for_fish_trading // VAP: Other costs: Hired labor, transport, packaging, ice, tax in MW2.
//	replace weekly_costs_for_fish_trading=fs_j05 if weekly_costs_for_fish_trading==.
recode weekly_costs_for_fish_trading (.=0)
 
collapse (sum) weekly_costs_for_fish_trading, by (hhid case_id)
lab var weekly_costs_for_fish_trading "Weekly costs associated with fish trading, in addition to purchase of fish"
keep hhid case_id weekly_costs_for_fish_trading 
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_fish_trading_other_costs.dta", replace

use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_weeks_fish_trading.dta", clear
merge m:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_fish_trading_revenues.dta" 
drop _merge
merge m:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_fish_trading_other_costs.dta"
drop _merge
replace weekly_fishtrade_profit = weekly_fishtrade_profit - weekly_costs_for_fish_trading
gen fish_trading_income = (weeks_fish_trading * weekly_fishtrade_profit)
lab var fish_trading_income "Estimated net household earnings from fish trading over previous 12 months"
keep hhid case_id fish_trading_income 
replace case_id = hhid if case_id == ""
drop if fish_trading_income ==.
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_fish_trading_income.dta", replace

//hhid and case_id do not uniquely identify, tried AT & MM methods //collapse across wild caught fish and aquaculture or species of fish 


************
*SELF-EMPLOYMENT INCOME - complete, under review CG 12.6.2023
************
use "${MWI_IHS_IHPS_W4_raw_data}\HH_MOD_N2.dta", clear
rename hh_n40 last_months_profit 
gen self_employed_yesno = .
replace self_employed_yesno = 1 if last_months_profit !=.
replace self_employed_yesno = 0 if last_months_profit == .
*DYA.2.9.2022 Collapse this at the household level
collapse (max) self_employed_yesno (sum) last_months_profit, by(hhid case_id)
drop if self != 1
ren last_months self_employ_income
recast str50 hhid, force 
*lab var self_employed_yesno "1=Household has at least one member with self-employment income"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_self_employment_income.dta", replace  

* VAP: Cannot compute hh. enterprise profit correctly, variable (hh_n40) asks only for last month of operation, not an average.
* VAP: Cannot compute ag byproduct profits as MW4 does not have by-product prices and costs. 

********************************************************************************
*WAGE INCOME*
********************************************************************************
//notes for read me: occupation codes not in dta file for w3, see BID "Occupation Codes", pg 36
*Non-Ag Wage Income
use "${MWI_IHS_IHPS_W4_raw_data}\HH_MOD_E.dta", clear
rename hh_e06_4 wage_yesno // MW2: In last 12m,  work as an employee for a wage, salary, commission, or any payment in kind: incl. paid apprenticeship, domestic work or paid farm work, excluding ganyu
rename hh_e22 number_months  //MW2:# of months worked at main wage job in last 12m. 
rename hh_e23 number_weeks  // MW2:# of weeks/month worked at main wage job in last 12m. 
rename hh_e24 number_hours  // MW2:# of hours/week worked at main wage job in last 12m. 
rename hh_e25 most_recent_payment // amount of last payment
replace most_recent_payment=. if inlist(hh_e19b,62 63 64) // VAP: main wage job 
replace hh_e26a=. if hh_e26a >=1500
replace most_recent_payment = most_recent_payment/hh_e26a //annual payment 

**** 
* VAP: For MW2, above codes are in .dta. 62:Agriculture and animal husbandry worker; 63: Forestry workers; 64: Fishermen, hunters and related workers   
* For TZ: taSCO codes from TZ Basic Info Document http://siteresources.worldbank.org/INTLSMS/Resources/3358986-1233781970982/5800988-1286190918867/TZNPS_2014_2015_BID_06_27_2017.pdf
	* 921: Agricultural, Forestry, and Fishery Labourers
	* 611: Farmers and Crop Skilled Workers
	* 612: Animal Producers and Skilled Workers
	* 613: Forestry and Related Skilled Workers
	* 614: Fishery Workers, Hunters, and Trappers
	* 621: Subsistence Agricultural, Forestry, Fishery, and Related Workers
***
rename hh_e26b payment_period // What period of time did this payment cover?
rename hh_e27 most_recent_payment_other // What is the value of those (apart from salary) payments? 
replace most_recent_payment_other =. if inlist(hh_e19b,62,63,64) // code of main wage job 
rename hh_e28b payment_period_other // Over what time interval?
rename hh_e32 secondary_wage_yesno // In last 12m, employment in second wage job outside own hh, incl. casual/part-time labour, for a wage, salary, commission or any payment in kind, excluding ganyu
rename hh_e39 secwage_most_recent_payment // amount of last payment
replace secwage_most_recent_payment = . if hh_e33_code== 62 // code of secondary wage job; 
rename hh_e40b secwage_payment_period // What period of time did this payment cover?
rename hh_e41 secwage_recent_payment_other //  value of in-kind payments
rename hh_e42b secwage_payment_period_other // Over what time interval?
rename hh_e38_1 secwage_hours_pastweek // In the last 7 days, how many hours did you work in this job?
gen annual_salary_cash=.
replace annual_salary_cash = (number_months*most_recent_payment) if payment_period==5  // month
replace annual_salary_cash = (number_months*number_weeks*most_recent_payment) if payment_period== 4 // week
replace annual_salary_cash = (number_months*number_weeks*(number_hours/8)*most_recent_payment) if payment_period==3  // day
gen wage_salary_other=.
replace wage_salary_other = (number_months*most_recent_payment_other) if payment_period_other==5 // month
replace wage_salary_other = (number_months*number_weeks*most_recent_payment_other) if payment_period_other==4 //week
replace wage_salary_other = (number_months*number_weeks*(number_hours/8)*most_recent_payment_other) if payment_period_other==3 //day
recode annual_salary_cash wage_salary_other (.=0)
gen annual_salary = annual_salary_cash + wage_salary_other
tab secwage_payment_period
collapse (sum) annual_salary, by (hhid case_id)
lab var annual_salary "Estimated annual earnings from non-agricultural wage employment over previous 12 months"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_wage_income.dta", replace

*Ag Wage Income
use "${MWI_IHS_IHPS_W4_raw_data}\HH_MOD_E.dta", clear
rename hh_e06_4 wage_yesno 
rename hh_e22 number_months
rename hh_e23 number_weeks
rename hh_e24 number_hours 
rename hh_e25 most_recent_payment
gen agwage = 1 if inlist(hh_e19b,62,63,64) // 62: Agriculture and animal husbandry worker; 63: Forestry workers; 64: Fishermen, hunters and related workers 
gen secagwage = 1 if inlist(hh_e33_code, 62,63,64) // 62: Agriculture and animal husbandry worker; 63: Forestry workers; 64: Fishermen, hunters and related workers
replace most_recent_payment = . if agwage!=1
rename hh_e26b payment_period // What period of time did this payment cover?
rename hh_e27 most_recent_payment_other // What is the value of those (apart from salary) payments? 
replace most_recent_payment_other =. if agwage!=1 
rename hh_e28b payment_period_other // Over what time interval?
rename hh_e32 secondary_wage_yesno // In last 12m, employment in second wage job outside own hh, incl. casual/part-time labour, for a wage, salary, commission or any payment in kind, excluding ganyu
rename hh_e39 secwage_most_recent_payment // amount of last payment
replace secwage_most_recent_payment = . if secagwage!=1  // code of secondary wage job
rename hh_e40b secwage_payment_period // What period of time did this payment cover?
rename hh_e41 secwage_recent_payment_other //  value of in-kind payments
rename hh_e42b secwage_payment_period_other // Over what time interval?
rename hh_e38_1 secwage_hours_pastweek // In the last 7 days, how many hours did you work in this job?

gen annual_salary_cash=.
replace annual_salary_cash = (number_months*most_recent_payment) if payment_period==5  // month
replace annual_salary_cash = (number_months*number_weeks*most_recent_payment) if payment_period== 4 // week
replace annual_salary_cash = (number_months*number_weeks*(number_hours/8)*most_recent_payment) if payment_period==3  // day
gen wage_salary_other=.
replace wage_salary_other = (number_months*most_recent_payment_other) if payment_period_other==5 // month
replace wage_salary_other = (number_months*number_weeks*most_recent_payment_other) if payment_period_other==4 //week

replace wage_salary_other = (number_months*number_weeks*(number_hours/8)*most_recent_payment_other) if payment_period_other==3 //day
recode annual_salary_cash wage_salary_other (.=0)
gen annual_salary = annual_salary_cash + wage_salary_other
collapse (sum) annual_salary, by (hhid case_id)
rename annual_salary annual_salary_agwage
lab var annual_salary_agwage "Annual earnings from agricultural wage"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_agwage_income.dta", replace  // 0 annual earnings, 3907 obsns


********************************************************************************
*OTHER INCOME * - CG checked/complete 2.15/2024
********************************************************************************
*Other income
*use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hh_crop_prices.dta", clear
*keep if crop_code==1 // keeping only maize for later
*save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hh_maize_prices.dta", replace

use "${MWI_IHS_IHPS_W4_raw_data}\HH_MOD_P.dta", clear
append using "${MWI_IHS_IHPS_W4_raw_data}\HH_MOD_R.dta" 
append using "${MWI_IHS_IHPS_W4_raw_data}\HH_MOD_O.dta"

/*ren hh_p03_3 cash_received //amount in cash received from monetary gift from abroad
ren hh_p03_2 cash_received_unit //currency
ren s6q8a inkind_received
ren s6q8b inkind_received_unit
local vars cash_received inkind_received*/

*merge m:1 HHID using "R:\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave3-2016\temp\Malawi_IHS_LSMS_ISA_W3_hh_maize_prices.dta"  // VAP: need maize prices for calculating cash value of free maize 
*merge m:1 y2_hhid using "${MLW_W2_created_data}\Malawi_IHS_LSMS_ISA_W2_hh_maize_prices.dta"  // VAP: need maize prices for calculating cash value of free maize 
rename hh_p0a income_source
ren hh_p01 received_income
ren hh_p02 amount_income
gen rental_income=amount_income if received_income==1 & inlist(income_source, 106, 107, 108, 109) // non-ag land rental, house/apt rental, shope/store rental, vehicle rental
gen pension_investment_income=amount_income if received_income==1 &  income_source==105| income_source==104 | income_source==116 // pension & savings/interest/investment income+ private pension
gen asset_sale_income=amount_income if received_income==1 &  inlist(income_source, 110,111,112) // real estate sales, non-ag hh asset sale income, hh ag/fish asset sale income
gen other_income=amount_income if received_income==1 &  inlist(income_source, 113, 114, 115) // inheritance, lottery, other income
rename hh_r0a prog_code

gen assistance_cash_yesno= hh_r02a!=0 & hh_r02a!=. if inlist(prog_code, 1031, 104,108,1091,111,112) // Cash from MASAF, Non-MASAF pub. works,
*inputs-for-work, sec. level scholarships, tert. level. scholarships, dir. Cash Tr. from govt, DCT other
gen assistance_food= hh_r02b!=0 & hh_r02b!=.  if inlist(prog_code, 101, 102, 1032, 105, 107) //  
gen assistance_otherinkind_yesno=hh_r02b!=0 & hh_r02b!=. if inlist(prog_code,104, 106, 112, 113) // 

rename hh_o14 cash_remittance 
rename hh_o17 in_kind_remittance 
recode rental_income pension_investment_income asset_sale_income other_income assistance_cash assistance_food /*assistance_inkind cash_received inkind_gifts_received*/  cash_remittance in_kind_remittance (.=0)
gen remittance_income = /*cash_received + inkind_gifts_received +*/ cash_remittance + in_kind_remittance
*gen assistance_income = assistance_cash + assistance_food + assistance_inkind
lab var rental_income "Estimated income from rentals of buildings, land, vehicles over previous 12 months"
lab var pension_investment_income "Estimated income from a pension AND INTEREST/INVESTMENT/INTEREST over previous 12 months"
lab var other_income "Estimated income from inheritance, lottery/gambling and ANY OTHER source over previous 12 months"
lab var asset_sale_income "Estimated income from household asset and real estate sales over previous 12 months"
lab var remittance_income "Estimated income from remittances over previous 12 months"
*lab var assistance_income "Estimated income from food aid, food-for-work, cash transfers etc. over previous 12 months"

gen remittance_income_yesno = remittance_income!=0 & remittance_income!=. //FN: creating dummy for remittance
gen rental_income_yesno= rental_income!=0 & rental_income!=.

gen pension_investment_income_yesno= pension_investment_income!=0 & pension_investment_income!=.
gen asset_sale_income_yesno= asset_sale_income!=0 & asset_sale_income!=.
gen other_income_yesno= other_income!=0 & other_income!=.
collapse (max) *_yesno  (sum) remittance_income rental_income pension_investment_income asset_sale_income other_income, by(hhid case_id)
recode *_yesno *_income (.=0)
egen any_other_income_yesno=rowmax(rental_income_yesno pension_investment_income_yesno asset_sale_income_yesno other_income_yesno)

lab var remittance_income_yesno "1=Household received some remittances (cash or in-kind)"
lab var any_other_income_yesno "1=Household received some other non-farm income (rental, asset sales, pension, others)"
lab var rental_income_yesno "1=Household received some income from properties rental"
lab var asset_sale_income_yesno "1=Household received some income from the sale of assets"
lab var pension_investment_income_yesno "1=Household received some income from pension"
lab var other_income_yesno "1=Household received some other non-farm income"

lab var rental_income "Estimated income from rentals of buildings, land, vehicles over previous 12 months"
lab var pension_investment_income "Estimated income from a pension AND INTEREST/INVESTMENT/INTEREST over previous 12 months"
lab var other_income "Estimated income from inheritance, lottery/gambling and ANY OTHER source over previous 12 months"
lab var asset_sale_income "Estimated income from household asset and real estate sales over previous 12 months"
lab var remittance_income "Estimated income from remittances over previous 12 months"
*lab var assistance_income "Estimated income from food aid, food-for-work, cash transfers etc. over previous 12 months"

lab var assistance_cash_yesno "1=Household received some cash assistance"
lab var assistance_otherinkind_yesno "1=Household received some inkind assistance"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_other_income.dta", replace


*Land rental
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_b2.dta", clear // *VAP: The below code calculates only agricultural land rental income, per TZ guideline code 
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_i2.dta"
rename ag_b217a land_rental_cash_rainy_recd // how much did you receive from renting out this garden in the rainy season
rename ag_b217b land_rental_inkind_rainy_recd // how much did you receive from renting out this garden in the rainy season (in kind)
*rename ag_d19c land_rental_cash_rainy_owed
*rename ag_d19d land_rental_inkind_rainy_owed
rename ag_i217a land_rental_cash_dry_recd // how much did you receive from renting out this garden in the dry season
rename ag_i217b land_rental_inkind_dry_recd // how much did you receive from renting out this garden in the dry season
*rename ag_k20c land_rental_cash_dry_owed
*rename ag_k20d land_rental_inkind_dry_owed
recode land_rental_cash_rainy_recd land_rental_inkind_rainy_recd /*land_rental_cash_rainy_owed land_rental_inkind_rainy_owed*/ land_rental_cash_dry_recd land_rental_inkind_dry_recd /*land_rental_cash_dry_owed land_rental_inkind_dry_owed */ (.=0)
gen land_rental_income_rainyseason= land_rental_cash_rainy_recd + land_rental_inkind_rainy_recd //+ land_rental_cash_rainy_owed + land_rental_inkind_rainy_owed
gen land_rental_income_dryseason= land_rental_cash_dry_recd + land_rental_inkind_dry_recd //+ land_rental_cash_dry_owed + land_rental_inkind_dry_owed 
gen land_rental_income = land_rental_income_rainyseason + land_rental_income_dryseason
collapse (sum) land_rental_income, by (hhid case_id)
lab var land_rental_income "Estimated income from renting out land over previous 12 months"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_land_rental_income.dta", replace

********************************************************************************
*OFF FARM HOURS - CG 2.12.2024 complete
********************************************************************************
/* OLD CODE
use "${MWI_IHS_IHPS_W4_raw_data}\HH_MOD_E.dta", clear
gen primary_hours = hh_e24 if !inlist(hh_e19b, 62, 63, 64, 71) & hh_e19b!=. 
*VAP: Excluding agr. & animal husban dry workers, forestry workers, fishermen & hunters, miners & quarrymen per TZ. 
gen secondary_hours = hh_e38 if hh_e33_code!=21 & hh_e33_code!=.  
* VAP: Excluding ag & animal husbandry. Confirm use of occup. 
gen ownbiz_hours =  hh_e08 + hh_e09 // VAP: TZ used # of hrs as unpaid family worker on non-farm hh. biz. 
* VAP: For MW2, I am using "How many hours in the last seven days did you run or do any kind of non-agricultural or non-fishing 
* household business, big or small, for yourself?" &
* "How many hours in the last seven days did you help in any of the household's non-agricultural or non-fishing household businesses, if any"?
egen off_farm_hours = rowtotal(primary_hours secondary_hours ownbiz_hours)
gen off_farm_any_count = off_farm_hours!=0
gen member_count = 1
collapse (sum) off_farm_hours off_farm_any_count member_count, by(hhid case_id)
la var member_count "Number of HH members age 5 or above"
la var off_farm_any_count "Number of HH members with positive off-farm hours"
la var off_farm_hours "Total household off-farm hours"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_off_farm_hours.dta", replace */

*aligning section to TZA & NGA, looks like MWI is using old code after doing Household Variables related to Off-Farm Hours 
use "${MWI_IHS_IHPS_W4_raw_data}\HH_MOD_E.dta", clear
//e24_1 hours at main job, trade or business connected e20
//need any job codes that aren't related to the farm: not 60,61,62,63,64

gen  hrs_main_wage_off_farm=hh_e24_1 if (hh_e20b!=61 | hh_e20b!=62 | hh_e20b!=63 | hh_e20b!=64 | hh_e20b!=.) //W4 instrument does not have the labels of hh_e20b, used W1's labels as reference, farm related labels are 60-64, TZA included codes for "Crop and animal production; Forestry and logging; Fishing and aquaculture; W4 Notes: hh_e21_2 1 to 3 is agriculture (exclude mining)" CG 3.13.24
gen  hrs_sec_wage_off_farm= hh_e38_1 if (hh_e34_code!=61 | hh_e34_code!=62 | hh_e34_code!=63 | hh_e34_code!=64 | hh_e34_code!=.)	//same as above for hh_e34_code
egen hrs_wage_off_farm= rowtotal(hrs_main_wage_off_farm hrs_sec_wage_off_farm) 

gen  hrs_main_wage_on_farm=hh_e24_1 if (hh_e20b==61 | hh_e20b==62 | hh_e20b==63 | hh_e20b==64 | hh_e20b!=.)	 
gen  hrs_sec_wage_on_farm= hh_e38_1 if (hh_e34_code==61 | hh_e34_code==62 | hh_e34_code==63 | hh_e34_code==64 | hh_e34_code!=.)	 
egen hrs_wage_on_farm= rowtotal(hrs_main_wage_on_farm hrs_sec_wage_on_farm) 
drop *main* *sec*
ren  hh_e52_1 hrs_unpaid_off_farm //ganyu labor section available but does not ask hours over the past 7 days, same with other unpaid labor over the last 12 months sections CG 3.13.24 

recode hh_e06 hh_e05 (.=0) //hh_e06 (collecting firewood) hh_e05 (collecting water)
replace hh_e06 = 0 if hh_e06 > 24 //data entry mistake, there are 2 obs for 45 and 25 hours, more than 1 day, replacing them with 0 CG 3.13.24
replace hh_e05 = 0 if hh_e05 > 24
gen  hrs_domest_fire_fuel=(hh_e06+hh_e05)*7 //need to multiply by 7 since questions ask how many hours were spent collecting water/wood yesterday CG 3.13.24
ren  hh_e07a hrs_ag_activ
egen hrs_off_farm=rowtotal(hrs_wage_off_farm)
egen hrs_on_farm=rowtotal(hrs_ag_activ hrs_wage_on_farm)
egen hrs_domest_all=rowtotal(hrs_domest_fire_fuel)
egen hrs_other_all=rowtotal(hrs_unpaid_off_farm)
gen hrs_self_off_farm=.
foreach v of varlist hrs_* {
	local l`v'=subinstr("`v'", "hrs", "nworker",.)
	gen  `l`v''=`v'!=.
} 
gen member_count = 1
collapse (sum) nworker_* hrs_*  member_count, by(hhid case_id)
la var member_count "Number of HH members age 5 or above"
la var hrs_unpaid_off_farm  "Total household hours - unpaid activities"
la var hrs_ag_activ "Total household hours - agricultural activities"
la var hrs_wage_off_farm "Total household hours - wage off-farm"
la var hrs_wage_on_farm  "Total household hours - wage on-farm"
la var hrs_domest_fire_fuel  "Total household hours - collecting fuel and making fire and collecting water" 
la var hrs_off_farm  "Total household hours - work off-farm"
la var hrs_on_farm  "Total household hours - work on-farm"
la var hrs_domest_all  "Total household hours - domestic activities"
la var hrs_other_all "Total household hours - other activities"
la var hrs_self_off_farm  "Total household hours - self-employment off-farm"
la var nworker_unpaid_off_farm  "Number of HH members with positve hours - unpaid activities"
la var nworker_ag_activ "Number of HH members with positve hours - agricultural activities"
la var nworker_wage_off_farm "Number of HH members with positve hours - wage off-farm"
la var nworker_wage_on_farm  "Number of HH members with positve hours - wage on-farm"
la var nworker_domest_fire_fuel  "Number of HH members with positve hours - collecting fuel and making fire"
la var nworker_off_farm  "Number of HH members with positve hours - work off-farm"
la var nworker_on_farm  "Number of HH members with positve hours - work on-farm"
la var nworker_domest_all  "Number of HH members with positve hours - domestic activities"
la var nworker_other_all "Number of HH members with positve hours - other activities"
la var nworker_self_off_farm  "Number of HH members with positve hours - self-employment off-farm"
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_off_farm_hours.dta", replace


********************************************************************************
*FARM SIZE / LAND SIZE - Complete & Pending Review CG 1.12.2024 
********************************************************************************
//missing necessary dry raw data for ag_mod_k

***Determining whether crops were grown on a plot
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_g.dta", clear
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_m.dta"
ren plotid plot_id
ren gardenid garden_id
drop if plot_id==""
drop if crop_code==. 
gen crop_grown = 1 
collapse (max) crop_grown, by(hhid case_id garden_id plot_id)
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_crops_grown.dta", replace


use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_k.dta", clear
ren plotid plot_id
ren gardenid garden_id
tempfile ag_mod_k_13_numeric //comparing this to MWI W2, W4 does not have a variable for ag_k13 but this still runs/creates a tempfile. is that okay? 
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_ag_mod_k_13_temp.dta", replace  // VAP:Renaming plot ids, to work with Module D and K together.

use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_d.dta", clear
ren gardenid garden_id
ren plotid plot_id
append using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_ag_mod_k_13_temp.dta"
gen cultivated = (ag_d14==1) // | ag_k15==1) question is in instrument but missing from raw data CG 1.5.2024 // VAP: cultivated plots in rainy or dry seasons
collapse (max) cultivated, by (hhid plot_id garden_id case_id)
lab var cultivated "1= Parcel was cultivated in this data set"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_parcels_cultivated.dta", replace

use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_parcels_cultivated.dta", clear
merge 1:1 hhid plot_id garden_id case_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_areas.dta",
drop if _merge==2
keep if cultivated==1

replace area_acres_meas=. if area_acres_meas<0 
replace area_acres_meas = area_acres_est if area_acres_meas==. 
collapse (sum) area_acres_meas, by (hhid case_id)
rename area_acres_meas farm_area
replace farm_area = farm_area * (1/2.47105) /* Convert to hectares */
lab var farm_area "Land size (denominator for land productivitiy), in hectares" 
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_land_size.dta", replace


* All agricultural land
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_d.dta", clear
ren plotid plot_id
ren gardenid garden_id
append using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_ag_mod_k_13_temp.dta"
drop if plot_id==""
merge m:1 hhid case_id garden_id plot_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_crops_grown.dta", nogen
// 747 matched, 25,267 not matched 
gen rented_out = (ag_d14==2) // rented out (2), missing dry raw data for ag_k15
//gen cultivated_dry = (ag_k15==1)
//bys y2_hhid plot_id: egen plot_cult_dry = max(cultivated_dry)
//replace rented_out = 0 if plot_cult_dry==1 // VAP: From TZ:If cultivated in short season, not considered rented out in long season.
drop if rented_out==1 & crop_grown!=1
//237 obs dropped
gen agland = (ag_d14==1 | ag_d14==4) // cultivated (1) and fallow (4), missing dry raw data for ag_k15
drop if agland!=1 & crop_grown==.
//185 obs dropped
collapse (max) agland, by (hhid case_id garden_id plot_id)
lab var agland "1= Parcel was used for crop cultivation or left fallow in this past year (forestland and other uses excluded)"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_parcels_agland.dta", replace

use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_d.dta", clear
ren plotid plot_id
ren gardenid garden_id
append using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_ag_mod_k_13_temp.dta"
drop if plot_id==""
gen rented_out = (ag_d14==2 | ag_d14==3) // | ag_k15==2 | ag_k15==3) //rented out (2), gave out for free (3)
//gen cultivated_dry = (ag_k15==1)
//bys y2_hhid plot_id: egen plot_cult_dry = max(cultivated_dry)
//replace rented_out = 0 if plot_cult_dry==1 // If cultivated in dry season, not considered rented out in rainy season.
drop if rented_out==1
gen plot_held = 1
collapse (max) plot_held, by (hhid case_id garden_id plot_id)
lab var plot_held "1= Parcel was NOT rented out in the main season"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_parcels_held.dta", replace

use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_parcels_held.dta", clear
merge 1:1 hhid case_id garden_id plot_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_areas.dta"
drop if _merge==2
replace area_acres_meas=. if area_acres_meas<0
replace area_acres_meas = area_acres_est if area_acres_meas==. 
collapse (sum) area_acres_meas, by (hhid case_id/* garden_id plot_id*/)
//replace case_id = hhid if case_id == ""
rename area_acres_meas land_size
lab var land_size "Land size in hectares, including all plots listed by the household except those rented out" 
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_land_size_all.dta", replace

use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_areas.dta", clear
merge 1:1 hhid case_id plot_id garden_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_parcels_agland.dta", nogen
keep if agland==1
collapse (sum) field_size, by (hhid case_id)
ren field_size farm_size_agland
lab var farm_size_agland "Land size in hectares, including all plots cultivated, fallow, or pastureland"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_farmsize_all_agland.dta", replace


*Total land holding including cultivated and rented out
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_d.dta", clear
ren plotid plot_id
ren gardenid garden_id
append using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_ag_mod_k_13_temp.dta"
drop if plot_id==""
merge m:1 hhid case_id garden_id plot_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_areas.dta", nogen keep(1 3)
replace area_acres_meas=. if area_acres_meas<0
replace area_acres_meas = area_acres_est if area_acres_meas==. 
replace area_acres_meas = area_acres_est if area_acres_meas==0 & (area_acres_est>0 & area_acres_est!=.)	
collapse (max) area_acres_meas, by(hhid case_id garden_id plot_id)
rename area_acres_meas land_size_total
collapse (sum) land_size_total, by(hhid case_id)
replace case_id = hhid if case_id == ""
replace land_size_total = land_size_total * (1/2.47105) /* Convert to hectares */
lab var land_size_total "Total land size in hectares, including rented in and rented out plots"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_land_size_total.dta", replace

//try to eliminate season collapse sum of farm area by, collapse max on plot garden hhid case, collapse sum on household caseid 


********************************************************************************
*FARM LABOR - COMPLETE 2.14.2024 CG
********************************************************************************
** Family labor
* Rainy Season
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_d.dta", clear
rename ag_d47a2 landprep_women  // # of days women hired for land preparation, planting, ridging, weeding and fertilizing
rename ag_d47a1 landprep_men   // # of days men hired for land preparation, planting, ridging, weeding and fertilizing
rename ag_d47a3 landprep_child // # of days children hired for land preparation, planting, ridging, weeding and fertilizing 
rename ag_d48a1 harvest_men    // # of days men hired for harvesting
rename ag_d48a2 harvest_women // # of days women hired for harvesting
rename ag_d48a3 harvest_child // # of days children hired for harvesting
recode landprep_women landprep_men landprep_child harvest_men harvest_women harvest_child (.=0)
egen days_hired_rainyseason = rowtotal(landprep_women landprep_men landprep_child harvest_men harvest_women harvest_child) 
recode ag_d42c1 ag_d42c2 ag_d42c3 ag_d42c4(.=0)  // # of days per week spent by hh.members (upto 4) in land prep/planting
egen days_flab_landprep = rowtotal(ag_d42c1 ag_d42c2 ag_d42c3 ag_d42c4)
recode ag_d43c1 ag_d43c2 ag_d43c3 ag_d43c4 (.=0) // # of days per week spent by hh.members (upto 4) in weeding, fertilizing and/or any other non-harvest activity
egen days_flab_weeding = rowtotal(ag_d43c1 ag_d43c2 ag_d43c3 ag_d43c4)
recode ag_d44c1 ag_d44c2 ag_d44c3 ag_d44c4 (.=0) // # of days per week spent by hh.members (upto 4) in harvesting
egen days_flab_harvest = rowtotal(ag_d44c1 ag_d44c2 ag_d44c3 ag_d44c4)
gen days_famlabor_rainyseason = days_flab_landprep + days_flab_weeding + days_flab_harvest
ren plotid plot_id
ren gardenid garden_id
collapse (sum) days_hired_rainyseason days_famlabor_rainyseason, by (hhid case_id plot_id garden_id)
lab var days_hired_rainyseason  "Workdays for hired labor (crops) in rainy season"
lab var days_famlabor_rainyseason  "Workdays for family labor (crops) in rainy season"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_farmlabor_rainyseason.dta", replace

* Dry Season
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_k.dta", clear
rename ag_k47a no_days_men_all
rename ag_k47b no_days_women_all 
rename ag_k47c no_days_chldrn_all 
recode no_days_men_all no_days_women_all no_days_chldrn_all(.=0)
egen days_hired_dryseason = rowtotal(no_days_men_all no_days_women_all no_days_chldrn_all) 
recode ag_k43c1 ag_k43c2 ag_k43c3 ag_k43c4(.=0) // # of days per week spent by hh.members (upto 4) in land prep/planting
egen days_flab_landprep = rowtotal(ag_k43c1 ag_k43c2 ag_k43c3 ag_k43c4)
recode ag_k44c1 ag_k44c2 ag_k44c3 ag_k44c4 (.=0) // # of days per week spent by hh.members (upto 4) in weeding, fertilizing and/or any other non-harvest activity
egen days_flab_weeding = rowtotal(ag_k44c1 ag_k44c2 ag_k44c3 ag_k44c4)
recode ag_k45c1 ag_k45c2 ag_k45c3 ag_k45c4(.=0) // # of days per week spent by hh.members (upto 4) in harvesting
egen days_flab_harvest = rowtotal(ag_k45c1 ag_k45c2 ag_k45c3 ag_k45c4)
gen days_famlabor_dryseason = days_flab_landprep + days_flab_weeding + days_flab_harvest
ren plotid plot_id
ren gardenid garden_id
collapse (sum) days_hired_dryseason days_famlabor_dryseason, by (hhid case_id plot_id garden_id)
lab var days_hired_dryseason  "Workdays for hired labor (crops) in dry season"
lab var days_famlabor_dryseason  "Workdays for family labor (crops) in dry season"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_farmlabor_dryseason.dta", replace


*Hired Labor
use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_farmlabor_rainyseason.dta", clear
merge 1:1 hhid case_id plot_id garden_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_farmlabor_dryseason.dta"
drop _merge
recode days*  (.=0)
collapse (sum) days*, by(hhid case_id plot_id garden_id)
egen labor_hired =rowtotal(days_hired_rainyseason days_hired_dryseason)
egen labor_family=rowtotal(days_famlabor_rainyseason  days_famlabor_dryseason)
egen labor_total = rowtotal(days_hired_rainyseason days_famlabor_rainyseason days_hired_dryseason days_famlabor_dryseason)
lab var labor_total "Total labor days (family, hired, or other) allocated to the farm"
lab var labor_hired "Total labor days (hired) allocated to the farm"
lab var labor_family "Total labor days (family) allocated to the farm"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_family_hired_labor.dta", replace
collapse (sum) labor_*, by(hhid case_id)
lab var labor_total "Total labor days (family, hired, or other) allocated to the farm"
lab var labor_hired "Total labor days (hired) allocated to the farm"
lab var labor_family "Total labor days (family) allocated to the farm"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_family_hired_labor.dta", replace

********************************************************************************
*VACCINE USAGE - RH complete 8/3, rerun after confirming gender_merge - CG updated 1/5/2024, complete 2/29/2024 
********************************************************************************
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_r1.dta", clear
gen vac_animal=ag_r22>0
* MW4: How many of your[Livestock] are currently vaccinated? 
* TZ: Did you vaccinate your[ANIMAL] in the past 12 months? 
replace vac_animal = 0 if ag_r22==0  
replace vac_animal = . if ag_r22==. // VAP: 4092 observations on a hh-animal level
*Disagregating vaccine usage by animal type 
rename ag_r0a livestock_code
gen species = (inlist(livestock_code, 301,302,303,304,3304)) + 2*(inlist(livestock_code,307,308)) + 3*(livestock_code==309) + 4*(livestock_code==3305) + 5*(inlist(livestock_code, 311,313,315,319,3310,3314))
recode species (0=.)
la def species 1 "Large ruminants (calf, steer/heifer, cow, bull, ox)" 2 "Small ruminants (sheep, goats)" 3 "Pigs" 4 "Equine (horses, donkeys)" 5 "Poultry"
la val species species
*A loop to create species variables
foreach i in vac_animal {
	gen `i'_lrum = `i' if species==1
	gen `i'_srum = `i' if species==2
	gen `i'_pigs = `i' if species==3
	gen `i'_equine = `i' if species==4
	gen `i'_poultry = `i' if species==5
}
collapse (max) vac_animal*, by (hhid case_id)
// VAP: After collapsing, the data is on hh level, vac_animal now has only 1883 observations
lab var vac_animal "1=Household has an animal vaccinated"
	foreach i in vac_animal {
		local l`i' : var lab `i'
		lab var `i'_lrum "`l`i'' - large ruminants"
		lab var `i'_srum "`l`i'' - small ruminants"
		lab var `i'_pigs "`l`i'' - pigs"
		lab var `i'_equine "`l`i'' - equine"
		lab var `i'_poultry "`l`i'' - poultry"
	}
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_vaccine.dta", replace

use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_r1.dta", clear
gen all_vac_animal=ag_r22>0
* MW4: How many of your[Livestock] are currently vaccinated? 
* TZ: Did you vaccinate your[ANIMAL] in the past 12 months? 
replace all_vac_animal = 0 if ag_r22==0  
replace all_vac_animal = . if ag_r22==. // VAP: 4092 observations on a hh-animal level
keep hhid ag_r06a ag_r06b all_vac_animal
ren ag_r06a farmerid1
ren ag_r06b farmerid2
gen t=1
gen patid=sum(t)
reshape long farmerid, i(patid) j(idnum)
drop t patid

/*
tempfile farmer1
save `farmer1'
//restore
preserve
keep hhid ag_r06b all_vac_animal
ren ag_r06b farmerid
tempfile farmer2
save `farmer2'
restore
*/

collapse (max) all_vac_animal , by(hhid farmerid)
gen indiv=farmerid
drop if indiv==. 
merge 1:1 hhid indiv using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_gender_merge.dta", nogen 
lab var all_vac_animal "1 = Individual farmer (livestock keeper) uses vaccines" 
gen livestock_keeper=1 if farmerid!=.
recode livestock_keeper (.=0)
lab var livestock_keeper "1=Indvidual is listed as a livestock keeper (at least one type of livestock)" 
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_farmer_vaccine.dta", replace	

********************************************************************************
*ANIMAL HEALTH - DISEASES - CG checked/updated/complete 12.4.2023
********************************************************************************
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_r1.dta", clear
gen disease_animal = 1 if ag_r20==1 // Answered "yes" for "Did livestock suffer from any disease in last 12m?"
replace disease_animal = . if (ag_r20==.) 
gen disease_ASF = ag_r21a==1  //  African swine fever
gen disease_amapl = ag_r21a==2 // Amaplasmosis
gen disease_bruc = ag_r21a== 7 // Brucelosis
gen disease_mange = ag_r21a==18 // Mange
gen disease_NC= ag_r21a==20 // New Castle disease
gen disease_spox= ag_r21a==22 // Small pox
gen disease_other = inrange(ag_r21a, 3, 6) | inrange(ag_r21a, 8, 17) | ag_r21a==21 | ag_r21a > 22 //ALT: adding "other" category to capture rarer diseases. Either useful or useless b/c every household had something in that category
rename ag_r0a livestock_code
gen species = (inlist(livestock_code,301,302,303,304, 3304)) + 2*(inlist(livestock_code,307,308)) + 3*(livestock_code==309) + 4*(livestock_code==3305) + 5*(inlist(livestock_code,3310,311,313,3314,315)) + 6*(inlist(livestock_code,318,319))
recode species (0=.)
la def species 1 "Large ruminants (cows, buffalos)" 2 "Small ruminants (sheep, goats)" 3 "Pigs" 4 "Equine (horses, donkeys)" 5 "Poultry" 6 "Other"
la val species species
*A loop to create species variables
foreach i in disease_animal disease_ASF disease_amapl disease_bruc disease_mange disease_NC disease_spox disease_other{
	gen `i'_lrum = `i' if species==1
	gen `i'_srum = `i' if species==2
	gen `i'_pigs = `i' if species==3
	gen `i'_equine = `i' if species==4
	gen `i'_poultry = `i' if species==5
	gen `i'_other = `i' if species==6
}
collapse (max) disease_*, by (hhid case_id)
lab var disease_animal "1= Household experienced veterinary disease"
lab var disease_ASF "1= Household experienced African Swine Fever"
lab var disease_amapl"1= Household experienced amaplasmosis disease"
lab var disease_bruc"1= Household experienced brucelosis"
lab var disease_mange "1= Household experienced mange disease"
lab var disease_NC "1= Household experienced New Castle disease"
lab var disease_spox "1= Household experienced small pox"
lab var disease_other "1=Household experienced another disease"
	foreach i in disease_animal disease_ASF disease_amapl disease_bruc disease_mange disease_NC disease_spox disease_other{
		local l`i' : var lab `i'
		lab var `i'_lrum "`l`i'' in large ruminants"
		lab var `i'_srum "`l`i'' in small ruminants"
		lab var `i'_pigs "`l`i'' in pigs"
		lab var `i'_equine "`l`i'' in equine"
		lab var `i'_poultry "`l`i'' in poultry"
		lab var `i'_other "`l`i'' in other"
	}

save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_livestock_diseases.dta", replace
		
********************************************************************************
*LIVESTOCK WATER, FEEDING, AND HOUSING - Cannot replicate for MWI
********************************************************************************
* Cannot replicate this section as MW4 Qs. does not ask about livestock water, feeding, housing.


********************************************************************************
*PLOT MANAGERS - updated 2.15.2024 CG
********************************************************************************
//This section combines all the variables that we're interested in at manager level
//(inorganic fertilizer, improved seed) into a single operation.
//Doing improved seed and agrochemicals at the same time.

use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_d.dta", clear
append using "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_k.dta"
ren gardenid garden_id
ren plotid plot_id
ren ag_d20a crop_code
replace crop_code = ag_d20b if crop_code == . & ag_d20b != .
replace crop_code = ag_k21a if crop_code == . & ag_k21a != .
replace crop_code = ag_k21b if crop_code == . & ag_k21b != .
drop if crop_code == .
gen use_imprv_seed = 1 if crop_code == 2 | crop_code == 12 | crop_code == 18 | crop_code == 21 | crop_code == 23 | crop_code == 25 // MAIZE COMPOSITE/OPV | GROUNDNUT CG7 | RISE FAYA | RISE IET4094 (SENGA) | RISE KILOMBERO | RISE MTUPATUPA
recode use_imprv_seed .=0
gen use_hybrid_seed = 1 if crop_code == 3 | crop_code == 4 | crop_code == 15 | crop_code == 19 | crop_code == 20 // MAIZE HYBRID | MAIZE HYBRID RECYCLED | GROUNDNUT JL24 | RISE PUSSA | RISE TCG10 
recode use_hybrid_seed .=0
collapse (max) use_imprv_seed use_hybrid_seed, by(hhid case_id plot_id garden_id crop_code)
tempfile imprv_hybr_seed
save `imprv_hybr_seed'

use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_d.dta", clear
ren plotid plot_id
ren gardenid garden_id
append using "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_k.dta"
ren ag_d01 pid
replace pid = ag_k02 if pid == . & ag_k02 != .
keep hhid case_id plot_id garden_id pid
ren pid indiv
drop if plot_id == ""
merge m:1 hhid case_id indiv using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_gender_merge.dta", nogen keep(1 3) // 17,688 matched / 5,573 not matched
tempfile personids
save `personids'

**# Bookmark #3

use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_input_quantities.dta", clear
foreach i in /*inorg_fert*/ org_fert pest herb {
	recode `i'_rate (.=0)
	replace `i'_rate=1 if `i'_rate >0 
	ren `i'_rate use_`i'
}

/*  We cannot run this section because ag_mod_f and ag_mod_l ["other inputs" rainy and dry -- base of input_quantities.dta -- do not report at plot level] 
collapse (max) use_*, by(case_id hhid) //XXX can't collapse by plot_id because input_quantities doesn't carry plot_id (unlike NGA W3)
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_all_plots.dta", nogen keep(1 3) keepusing(crop_code)
collapse (max) use*, by(hhid case_id plot_id crop_code)
merge 1:1 case_id plot_id crop_code using `imprv_hybr_seed', nogen
recode use* (.=0)

preserve
keep case_id plot_id crop_code use_imprv_seed use_hybrid_seed
ren use_imprv_seed imprv_seed_
ren use_hybrid_seed hybrid_seed_
gen hybrid_seed_ = .
collapse (max) imprv_seed_ hybrid_seed_. by(case_id crop_code)
merge m:1 crop_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_cropname_table.dta", nogen keep(3)
drop crop_code
reshape wide imprv_seed_ hybrid_seed_, i(case_id) j(crop_name) string
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_imprvseed_crop.dta", replace
restore

merge m:m case_id plot_id using `personids', nogen keep(1 3)
*/

//if we figure out how to use the commented-out section above (fertilizer, pesticide, herbicide), skip next two lines
use `imprv_hybr_seed', clear
merge m:m case_id plot_id using `personids', nogen keep(1 3) // 23,037 matched, 2,737 not matched

preserve
ren use_imprv_seed all_imprv_seed_
ren use_hybrid_seed all_hybrid_seed_
collapse (max) all*, by(hhid case_id indiv female crop_code)
merge m:1 crop_code using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_cropname_table.dta", nogen keep(3) // all matched 
drop crop_code
gen farmer_ = 1
reshape wide all_imprv_seed_ all_hybrid_seed_ farmer_, i(hhid case_id indiv female) j(crop_name) string
recode farmer_* (.=0)
ren farmer_* *_farmer
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_farmer_improved_hybrid_seed_use.dta", replace
restore

collapse (max) use_*, by(hhid case_id indiv female)
gen all_imprv_seed_use = use_imprv_seed
gen all_hybrid_seed_Use = use_hybrid_seed

preserve
collapse (max) use_imprv_seed use_hybrid_seed, by(hhid case_id)
la var use_imprv_seed "1 = household uses improved seed for at least one crop"
la var use_hybrid_seed "1 = household uses hybrid seed for at least one crop"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_input_use.dta", replace
restore

/* We cannot run this section due to ag_mod_l and ag_mod_f issue (same as above)
preserve
ren use_inorg_fert all_use_inorg_fert
	lab var all_use_inorg_fert "1 = Individual farmer (plot manager) uses inorganic fertilizer"
	gen farm_manager=1 if indiv!=.
	recode farm_manager (.=0)
	lab var farm_manager "1=Indvidual is listed as a manager for at least one plot" 
	save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_farmer_fert_use.dta", replace //This is currently used for AgQuery.
restore
*/

********************************************************************************
*REACHED BY AG EXTENSION - RH complete 8/26/21, not checked, checked 2.15.2024 CG
********************************************************************************
//code below matches old code in Nigeria W3 but it looks like MWI has only a few questions related to the topic, W1 kept this code as well
use "${MWI_IHS_IHPS_W4_raw_data}/AG_MOD_T1.dta", clear
ren ag_t01 receive_advice
ren ag_t02 sourceids

**Government Extension
gen advice_gov = (sourceid==1|sourceid==3 & receive_advice==1) // govt ag extension & govt. fishery extension. 
**NGO
gen advice_ngo = (sourceid==4 & receive_advice==1)
**Cooperative/ Farmer Association
gen advice_coop = (sourceid==5 & receive_advice==1) // ag coop/farmers association
**Large Scale Farmer
gen advice_farmer =(sourceid== 10 & receive_advice==1) // lead farmers
**Radio/TV
gen advice_electronicmedia = (sourceid==12|sourceid==15|sourceid==16 & receive_advice==1) // electronic media:Radio -- MWI w4 has additional electronic media sources (phone/SMS, other electronic media (TV,etc))
**Publication
gen advice_pub = (sourceid==13 & receive_advice==1) // handouts, flyers
**Neighbor
gen advice_neigh = (sourceid==11 & receive_advice==1) // Other farmers: neighbors, relatives
** Farmer Field Days
gen advice_ffd = (sourceid==7 & receive_advice==1)
** Village Ag Extension Meeting
gen advice_village = (sourceid==8 & receive_advice==1)
** Ag Ext. Course
gen advice_course= (sourceid==9 & receive_advice==1)
** Private Ag. Extension 
gen advice_pvt= (sourceid==2 & receive_advice==1)
**Other
gen advice_other = (sourceid== 14 & receive_advice==1)

**advice on prices from extension
*Five new variables  ext_reach_all, ext_reach_public, ext_reach_private, ext_reach_unspecified, ext_reach_ict  // QUESTION - ffd and course in unspecified?
gen ext_reach_public=(advice_gov==1)
gen ext_reach_private=(advice_ngo==1 | advice_coop==1 | advice_pvt) //advice_pvt new addition
gen ext_reach_unspecified=(advice_neigh==1 | advice_pub==1 | advice_other==1 | advice_farmer==1 | advice_ffd==1 | advice_course==1 | advice_village==1) //RH - Re: VAP's check request - Farmer field days and courses incl. here - seems correct since we don't know who put those on, but flagging
gen ext_reach_ict=(advice_electronicmedia==1)
gen ext_reach_all=(ext_reach_public==1 | ext_reach_private==1 | ext_reach_unspecified==1 | ext_reach_ict==1)

collapse (max) ext_reach_* , by (hhid case_id)
lab var ext_reach_all "1 = Household reached by extension services - all sources"
lab var ext_reach_public "1 = Household reached by extension services - public sources"
lab var ext_reach_private "1 = Household reached by extension services - private sources"
lab var ext_reach_unspecified "1 = Household reached by extension services - unspecified sources"
lab var ext_reach_ict "1 = Household reached by extension services through ICT"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_any_ext.dta", replace

********************************************************************************
* MOBILE PHONE OWNERSHIP * - CG checked & updated 11.20.2023
********************************************************************************
use "${MWI_IHS_IHPS_W4_raw_data}\HH_MOD_F.dta", clear
//recode missing to 0 in hh_g301 (0 mobile owned if missing)
recode hh_f34 (.=0)
ren hh_f34 hh_number_mobile_owned
//recode hh_number_mobile_owned (.=0) // no changes
gen mobile_owned = 1 if hh_number_mobile_owned>0 
recode mobile_owned (.=0) // recode missing to 0
collapse (max) mobile_owned, by(hhid)
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_mobile_own.dta", replace 
	
********************************************************************************
*USE OF FORMAL FINANCIAL SERVICES - RH complete 8/10/21, CG completed revisions 12.11.23
********************************************************************************
use "${MWI_IHS_IHPS_W4_raw_data}\HH_MOD_F.dta", clear
append using "${MWI_IHS_IHPS_W4_raw_data}\HH_MOD_S1.dta"
gen borrow_bank=hh_s04==10 | hh_s04==13 // bank, village bank 
replace borrow_bank=1 if strmatch(hh_s04_oth, "BANK (COMMERCIAL)") | strmatch(hh_s04_oth,"LOAN INSTITUTION,") | strmatch(hh_s04_oth, "LENDING INSTITUTION")
gen borrow_micro=hh_s04==7|hh_s04==8|hh_s04==9 //MARDEF (group lending, development fund), MRFC (finance comp), SACCO (co-ops)
replace borrow_micro=1 if strmatch(hh_s04_oth, "NASFARM")
replace borrow_micro=1 if strmatch(hh_s04_oth, "ALLIANCE ONE") | strmatch(hh_s04_oth,"FICA") | strmatch(hh_s04_oth,"MICROFINANCE INSTITUTIONS") | strmatch(hh_s04_oth,"JTI")
replace borrow_micro=1 if strmatch(hh_s04_oth, "AGRIC COOPERATIVE") | strmatch(hh_s04_oth,"COMSIP")
gen borrow_relig=hh_s04==6 // religious institution
replace borrow_relig=1 if strmatch(hh_s04_oth, "RELIGIOUS") | strmatch(hh_s04_oth,"CHURCH") | strmatch(hh_s04_oth,"CHURCH ELDER") | strmatch(hh_s04_oth,"CHURCH MEMBER")
gen borrow_other_fin=hh_s04==12
replace borrow_other_fin=1 if strmatch(hh_s04_oth, "GOVERNMENT") | strmatch(hh_s04_oth,"MALAWI GOVERNMENT")
gen borrow_neigh=hh_s04==2  //neighbor
gen borrow_employer=hh_s04==5 //employer
replace borrow_employer=1 if strmatch(hh_s04_oth, "CO-WORKER") | strmatch(hh_s04_oth,"WORK PLACE") //employer
gen borrow_ngo=hh_s04==11 //NGO
gen borrow_informal=1 if hh_s04==1 | hh_s04==3 | hh_s04==4 | hh_s04==11 | hh_s04==12 | hh_s04==5 | hh_s04==12 
replace borrow_informal=1 if strmatch(hh_s04_oth, "RELATIVES GROUP") //relative
replace borrow_informal=1 if strmatch(hh_s04_oth, "COMPANY") | strmatch(hh_s04_oth,"COMMERCIAL SHOP") | strmatch(hh_s04_oth,"BUSINESS PERSON") | strmatch(hh_s04_oth,"PRIVATE INDIVIDUAL") | strmatch(hh_s04_oth,"CHIPANI CHAKUMALIRO") //local grocer/merchant
replace borrow_informal=1 if strmatch(hh_s04_oth,"MONEY LENDER") | strmatch(hh_s04_oth, "MICHAEL LOAN") | strmatch(hh_s04_oth,"VISION FUND,") | strmatch(hh_s04_oth,"VISSION FUND,") //money lender
replace borrow_informal=1 if strmatch(hh_s04_oth, "AFRO DEALER") | strmatch(hh_s04_oth,"COUNCILLOR")| strmatch(hh_s04_oth,"DYERATU") | strmatch(hh_s04_oth,"MACOLOLONI") | strmatch(hh_s04_oth,"MACRON") | strmatch(hh_s04_oth,"WOMEN GROUP") | strmatch(hh_s04_oth,"KITCHEN TOP UP GROUP") | strmatch(hh_s04_oth,"KIM GROUP") | strmatch(hh_s04_oth,"ASSOCIATION") |strmatch(hh_s04_oth, "FRIEND") | strmatch(hh_s04_oth,"LANDLORD") | strmatch(hh_s04_oth,"FOOTBALL CLUB") //informal other
replace borrow_informal = 0 if ! (strmatch(hh_s04_oth, "AFRO DEALER") | strmatch(hh_s04_oth, "COUNCILLOR") | strmatch(hh_s04_oth, "DYERATU") | strmatch(hh_s04_oth, "MACOLOLONI") | strmatch(hh_s04_oth, "MACRON") | strmatch(hh_s04_oth, "WOMEN GROUP") | strmatch(hh_s04_oth, "KITCHEN TOP UP GROUP") | strmatch(hh_s04_oth, "KIM GROUP") | strmatch(hh_s04_oth, "ASSOCIATION") | strmatch(hh_s04_oth, "FRIEND") | strmatch(hh_s04_oth,"LANDLORD") | strmatch(hh_s04_oth,"FOOTBALL CLUB"))
gen use_bank_acount=hh_f48==1 
gen use_fin_serv_bank = use_bank_acount==1
gen use_fin_serv_credit= borrow_bank==1 | borrow_other_fin==1
gen use_fin_serv_others= borrow_other_fin==1
gen use_fin_serv_all=use_fin_serv_bank==1 | use_fin_serv_credit==1 |  use_fin_serv_others==1  
recode use_fin_serv* (.=0)
collapse (max) use_fin_serv_*, by (hhid case_id)
lab var use_fin_serv_all "1= Household uses formal financial services - all types"
lab var use_fin_serv_bank "1= Household uses formal financial services - bank account"
lab var use_fin_serv_credit "1= Household uses formal financial services - credit"
lab var use_fin_serv_others "1= Household uses formal financial services - others"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_fin_serv.dta", replace	

*******************************************************************************
*MILK PRODUCTIVITY - RH complete 8/10/21 - not checked, checked 2.15.2024
********************************************************************************
//RH: only cow milk in MWI, not including large ruminant variables
*Total production
use "${MWI_IHS_IHPS_W4_raw_data}\AG_MOD_S.dta", clear
rename ag_s0a product_code
keep if product_code==401
rename ag_s02 months_milked 
rename ag_s03a liters_month 
gen milk_liters_produced = months_milked * liters_month if ag_s03b==1 // VAP: Only including liters, not including 2 obsns in "buckets". 
lab var milk_liters_produced "Liters of milk produced in past 12 months"

lab var months_milked "Average months milked in last year (household)"
drop if milk_liters_produced==.
keep hhid case_id product_code months_milked liters_month milk_liters_produced
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_milk_animals.dta", replace

********************************************************************************
*EGG PRODUCTIVITY - RH complete, not checked, checked CG 2.15.2024
********************************************************************************
use "${MWI_IHS_IHPS_W4_raw_data}\AG_MOD_R1.dta", clear
rename ag_r0a lvstckid
gen poultry_owned = ag_r02 if inlist(lvstckid, 311, 313, 315, 318, 319, 3310, 3314) // local hen, local cock, duck, other, dove/pigeon, chicken layer/chicken-broiler and turkey/guinea fowl - RH include other?
collapse (sum) poultry_owned, by(hhid case_id)
tempfile eggs_animals_hh 
save `eggs_animals_hh'

use "${MWI_IHS_IHPS_W4_raw_data}\AG_MOD_S.dta", clear
rename ag_s0a product_code
keep if product_code==402 | product_code==403
rename ag_s02 eggs_months // # of months in past year that hh. produced eggs
rename ag_s03a eggs_per_month  // avg. qty of eggs per month in past year
rename ag_s03b quantity_month_unit
replace quantity_month = round(quantity_month/0.06) if product_code==402 & quantity_month_unit==2 // VAP: converting obsns in kgs to pieces for eggs 
// using MW IHS Food Conversion factors.pdf. Cannot convert ox-cart & ltrs for eggs 
replace quantity_month_unit = 3 if product_code== 402 & quantity_month_unit==2    
replace quantity_month_unit =. if product_code==402 & quantity_month_unit!=3        // VAP: chicken eggs, pieces
replace quantity_month_unit =. if product_code== 403 & quantity_month_unit!=3      // guinea fowl eggs, pieces
recode eggs_months eggs_per_month (.=0)
collapse (sum) eggs_per_month (max) eggs_months, by (hhid case_id) // VAP: Collapsing chicken & guinea fowl eggs
gen eggs_total_year = eggs_months* eggs_per_month // Units are pieces for eggs 
merge 1:1 hhid using  `eggs_animals_hh', nogen keep(1 3)			
keep hhid case_id eggs_months eggs_per_month eggs_total_year poultry_owned 

lab var eggs_months "Number of months eggs were produced (household)"
lab var eggs_per_month "Number of eggs that were produced per month (household)"
lab var eggs_total_year "Total number of eggs that was p roduced in a year (household)"
lab var poultry_owned "Total number of poultry owned (household)"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_eggs_animals.dta", replace

********************************************************************************
* CROP PRODUCTION COSTS PER HECTARE - CG 11/17/2024 Updated, recheck when gender merge is updated
********************************************************************************
/* need to fix this merge 
use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_all_plots.dta", clear
collapse (sum) ha_planted ha_harvest, by(hhid case_id plot_id garden_id season purestand area_meas_hectares)
reshape long ha_, i(hhid case_id plot_id garden_id purestand season area_meas_hectares) j(area_type) string
tempfile plot_areas
save `plot_areas'

use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_plot_cost_inputs_long.dta", clear
collapse (sum) cost_=val, by(hhid case_id plot_id  garden_id dm_gender season exp)
reshape wide cost_, i(hhid case_id plot_id garden_id season dm_gender) j(exp) string
recode cost_exp cost_imp (.=0)
gen cost_total=cost_imp+cost_exp
drop cost_imp
//replace case_id = hhid if case_id == "" 
merge 1:m hhid case_id plot_id garden_id season using `plot_areas', nogen keep(3)
//duplicate plots where season is included 
gen cost_exp_ha_ = cost_exp/ha_ 
gen cost_total_ha_ = cost_total/ha_
collapse (mean) cost*ha_ [aw=area_meas_hectares], by(hhid case_id plot_id dm_gender area_type)
gen dm_gender2 = "male"
replace dm_gender2 = "female" if dm_gender==2
replace dm_gender2 = "mixed" if dm_gender==3 
replace dm_gender2 = "unknown" if dm_gender==.
drop dm_gender
replace area_type = "harvested" if strmatch(area_type,"harvest")
reshape wide cost*_, i(hhid case_id plot_id dm_gender2) j(area_type) string
ren cost* cost*_
reshape wide cost*, i(hhid case_id plot_id) j(dm_gender2) string
foreach i in male female mixed unknown {
	foreach j in planted harvested {
		la var cost_exp_ha_`j'_`i' "Explicit cost per hectare by area `j', `i'-managed plots"
		la var cost_total_ha_`j'_`i' "Total cost per hectare by area `j', `i'-managed plots"
	}
}
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_cropcosts.dta", replace*/


********************************************************************************
*RATE OF FERTILIZER APPLICATION *CWL complete 10/5/22, CG updated/checked 3.8.24
********************************************************************************
*no inorganic fertilizer 
use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_all_plots.dta", clear
collapse (sum) ha_planted, by(hhid case_id season dm_gender region)
merge m:1 hhid season region using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_input_quantities.dta", nogen keep(1 3)
gen dm_gender2 = "male" if dm_gender==1
replace dm_gender2 = "female" if dm_gender==2
replace dm_gender2 = "mixed" if dm_gender==3 //no dm gender mixed 
replace dm_gender2 = "unknown" if dm_gender==.
drop dm_gender
ren ha_planted ha_planted_
//ren inorg_fert_rate fert_inorg_kg_ 
ren org_fert_rate fert_org_kg_ 
ren pest_rate pest_kg_
ren herb_rate herb_kg_
reshape wide ha_planted_ /*fert_inorg_kg_*/ fert_org_kg_ pest_kg_ herb_kg_, i(hhid season) j(dm_gender2) string
collapse (sum) *male /**mixed */*unknown, by(hhid case_id)
recode ha_planted* (0=.)
foreach i in ha_planted /*fert_inorg_kg*/ fert_org_kg pest_kg herb_kg {
	egen `i' = rowtotal(`i'_*)
}

merge m:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_weights.dta", keep (1 3) nogen
_pctile ha_planted [aw=weight]  if ha_planted!=0 , p($wins_lower_thres $wins_upper_thres)
foreach x of varlist ha_planted ha_planted_male ha_planted_female /*ha_planted_mixed*/ ha_planted_unknown{	
		replace `x' =r(r1) if `x' < r(r1)   & `x' !=. &  `x' !=0 
		replace `x' = r(r2) if  `x' > r(r2) & `x' !=.    
}
//lab var fert_inorg_kg "Inorganic fertilizer (kgs) for household"
lab var fert_org_kg "Organic fertilizer (kgs) for household" 
lab var pest_kg "Pesticide (kgs) for household"
lab var herb_kg "Herbicide (kgs) for household"
lab var ha_planted "Area planted (ha), all crops, for household"

foreach i in male female mixed unknown {
//lab var fert_inorg_kg_`i' "Inorganic fertilizer (kgs) for `i'-managed plots"
lab var fert_org_kg_`i' "Organic fertilizer (kgs) for `i'-managed plots" 
lab var pest_kg_`i' "Pesticide (kgs) for `i'-managed plots"
lab var herb_kg_`i' "Herbicide (kgs) for `i'-managed plots"
lab var ha_planted_`i' "Area planted (ha), all crops, `i'-managed plots"
}
save  "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_fertilizer_application.dta", replace

/*
* Note: references TZA NPS W5. 
use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_d.dta", clear //rainy
gen dry=0 //create variable for season
append using "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_k.dta" //dry
recode dry(.=1)
lab var dry "season: 0=rainy, 1=dry"
label define dry 0 "rainy" 1 "dry"
label values dry dry 
ren plotid plot_id
ren gardenid garden_id


// organic fertilizer - rainy (_r) and dry (_d)
rename ag_d36 org_fert_use_r
rename ag_d37a org_fert_qty_r
rename ag_d37b org_fert_unit_r
rename ag_k37 org_fert_use_d
rename ag_k38a org_fert_qty_d
rename ag_k38b org_fert_unit_d // units include: KILOGRAM, BUCKET, WHEELBARROW, OX CART, OTHER. Could not find unit conversion for fertilizer.
// Only use KILOGRAM unit for organic fertilizer 

gen fert_org_kg_r = .
replace fert_org_kg_r = org_fert_qty_r if org_fert_use_r==1 & org_fert_unit_r==2 & org_fert_qty_r !=. // 1932 changes made
gen fert_org_kg_d = .
replace fert_org_kg_d = org_fert_qty_d if org_fert_use_d==1 & org_fert_unit_d==2 & org_fert_qty_d !=. //373 changes made

// inorganic fertilizer - rainy and dry
rename ag_d38 inorg_fert_use_r
rename ag_k39 inorg_fert_use_d

gen fert_inorg_kg_r = .
gen fert_inorg_kg_d = .

// Unit conversion for inorganic fertilizer
foreach i in ag_d39c ag_d39i ag_k40c ag_k40h {
	gen `i'_conversion = .
	replace `i'_conversion = 0.001 if `i'==1 //GRAM
	replace `i'_conversion = 1 if `i'==2 //KG
	replace `i'_conversion = 2 if `i'==3 //2 KG BAG
	replace `i'_conversion = 3 if `i'==4 // 3 KG BAG
	replace `i'_conversion = 5 if `i'==5 // 5 KG BAG
	replace `i'_conversion = 10 if `i'==6 // 10 KG BAG
	replace `i'_conversion = 50 if `i'==7 // 50 KG BAG
}

//0kg if no fertilizer used
replace fert_inorg_kg_r = 0 if inorg_fert_use_r==2 //11,166 changes
replace fert_inorg_kg_d = 0 if inorg_fert_use_d==2 //1,311 changes
//count if inorg_fert_use_r !=. & inorg_fert_use_r!=0 //22,532
//count if inorg_fert_use_r !=. & inorg_fert_use_r!=0 //22,532
//count if inorg_fert_use_d !=. & inorg_fert_use_d!=0 //2,676

//rainy - first application
replace fert_inorg_kg_r = ag_d39b * ag_d39c * ag_d39c_conversion if inorg_fert_use_r==1
// add second application
replace fert_inorg_kg_r = fert_inorg_kg_r + ag_d39h * ag_d39i * ag_d39i_conversion if ag_d39h !=. & ag_d39i !=. 

//dry - first application
replace fert_inorg_kg_d = ag_k40b * ag_k40c * ag_k40c_conversion if inorg_fert_use_d==1  
// add second application
replace fert_inorg_kg_d = fert_inorg_kg_d + ag_k40g * ag_k40h *ag_k40h_conversion if ag_k40g !=. & ag_k40h!=.  

keep hhid case_id plot_id garden_id fert_org_kg_r fert_inorg_kg_r fert_org_kg_d fert_inorg_kg_d

/*
count if fert_inorg_kg_r ==. & fert_inorg_kg_d==. //909
count if fert_inorg_kg_r !=. & fert_inorg_kg_d==. //22,443
count if fert_inorg_kg_r ==. & fert_inorg_kg_d!=. //2,666
// Note: majority only use inorganic fertilizer in rainy season? at least not missing
*/

merge m:1 hhid case_id plot_id garden_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender) // 14,418 matched, 11,600 not matched

collapse (sum) fert*, by(hhid case_id dm_gender)

// combine rainy and dry
gen fert_org_kg = fert_org_kg_r + fert_org_kg_d
gen fert_inorg_kg = fert_inorg_kg_r + fert_inorg_kg_d 
drop fert_org_kg_r fert_org_kg_d
drop fert_inorg_kg_r fert_inorg_kg_d

gen dm_gender2="male" if dm_gender==1
replace dm_gender2="female" if dm_gender==2
replace dm_gender2 = "mixed" if dm_gender==3
drop if missing(dm_gender2)
drop dm_gender


ren fert_*_kg fert_*_kg_

reshape wide fert*_, i(hhid case_id) j(dm_gender2) string
//merge 1:1 y5_hhid using "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_hhids.dta", keep (1 3) nogen
gen fert_org_kg = fert_org_kg_male+fert_org_kg_female+fert_org_kg_mixed
gen fert_inorg_kg = fert_inorg_kg_male+fert_inorg_kg_female+fert_inorg_kg_mixed
/*use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_land.dta", clear
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_fert_lrs.dta"
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_fert_srs.dta"
collapse (sum) ha_planted* fert_org_kg* fert_inorg_kg*, by(y4_hhid)
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta", keep (1 3) nogen
*/
lab var fert_inorg_kg "Inorganic fertilizer (kgs) for household"
lab var fert_org_kg "Organic fertilizer (kgs) for household"
lab var fert_inorg_kg_male "Quantity of fertilizer applied (kgs) (male-managed plots)"
lab var fert_inorg_kg_female "Quantity of fertilizer applied (kgs) (female-managed plots)"
lab var fert_inorg_kg_mixed "Quantity of fertilizer applied (kgs) (mixed-managed plots)"

save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_fertilizer_application.dta", replace*/

********************************************************************************
*USE OF INORGANIC FERTILIZER - DELETE
********************************************************************************
/* use "${MWI_IHS_IHPS_W4_raw_data}/AG_MOD_D.dta", clear
append using "${MWI_IHS_IHPS_W4_raw_data}/AG_MOD_K.dta" 
gen all_use_inorg_fert=.
replace all_use_inorg_fert=0 if ag_d38==2| ag_k39==2
replace all_use_inorg_fert=1 if ag_d38==1| ag_k39==1
recode all_use_inorg_fert (.=0)
lab var all_use_inorg_fert "1 = Household uses inorganic fertilizer"

keep hhid ag_d01 ag_d01_2a ag_d01_2b ag_k02 ag_k02_2a ag_k02_2b all_use_inorg_fert
ren ag_d01 farmerid1
replace farmerid1= ag_k02 if farmerid1==.
ren ag_d01_2a farmerid2
replace farmerid2= ag_k02_2a if farmerid2==.
ren ag_d01_2b farmerid3
replace farmerid2= ag_k02_2b if farmerid3==.	

//reshape long
gen t = 1
gen patid = sum(t)

reshape long farmerid, i(patid) j(decisionmakerid)
drop t patid

collapse (max) all_use_inorg_fert , by(hhid farmerid)
gen indiv=farmerid
drop if indiv==.
merge 1:1 hhid indiv using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_gender_merge.dta", nogen

lab var all_use_inorg_fert "1 = Individual farmer (plot manager) uses inorganic fertilizer"
gen farm_manager=1 if farmerid!=.
recode farm_manager (.=0)
lab var farm_manager "1=Individual is listed as a manager for at least one plot" 
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_farmer_fert_use.dta", replace	*/

********************************************************************************
*USE OF IMPROVED SEED - CG updated/under review 11.29.2023       
********************************************************************************
use "${MWI_IHS_IHPS_W4_raw_data}/AG_MOD_G.dta", clear
gen short=0
append using "${MWI_IHS_IHPS_W4_raw_data}/AG_MOD_M.dta" 
recode short (.=1)
ren gardenid garden_id
ren plotid plot_id
gen imprv_seed_use= ag_g0f==2 | ag_m0f==2 | ag_m0f==3
collapse (max) imprv_seed_use, by(hhid case_id plot_id garden_id crop_code short)
tempfile imprv_seed
save `imprv_seed' //Will use this in a minute
collapse (max) imprv_seed_use, by(hhid case_id crop_code) //AgQuery
*Use of seed by crop
forvalues k=1/$nb_topcrops {
	local c : word `k' of $topcrop_area
	local cn : word `k' of $topcropname_area
	gen imprv_seed_`cn'=imprv_seed_use if crop_code==`c'
	gen hybrid_seed_`cn'=.
}
collapse (max) imprv_seed_* hybrid_seed_*, by(hhid case_id)
lab var imprv_seed_use "1 = Household uses improved seed"
foreach v in $topcropname_area {
	lab var imprv_seed_`v' "1= Household uses improved `v' seed"
	lab var hybrid_seed_`v' "1= Household uses improved `v' seed"
}
*Replacing permanent crop seed information with missing because this section does not ask about permanent crops 
replace imprv_seed_cassav = .
//replace imprv_seed_banana = . //banana is no longer a top crop
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_improvedseed_use.dta", replace

use "${MWI_IHS_IHPS_W4_raw_data}/AG_MOD_D.dta", clear 
gen short=0
append using "${MWI_IHS_IHPS_W4_raw_data}/AG_MOD_K.dta" 
recode short (.=1)
ren plotid plot_id
ren gardenid garden_id
merge 1:m hhid case_id plot_id garden_id short using `imprv_seed', nogen
ren ag_d01 dm1
ren ag_d01_2a dm2
ren ag_d01_2b dm3 
ren ag_k02 dm0
ren ag_k02_2a dm0_2a
ren ag_k02_2b dm0_2b
keep hhid plot_id crop_code dm* imprv*
gen dummy=_n
reshape long dm, i(hhid plot_id crop_code imprv_seed_use dummy) j(idno)
drop idno
drop if dm==. //90,231 obs deleted 
collapse (max) imprv_seed_use, by(hhid crop_code dm)
ren dm indiv 
//To go to "wide" format:
egen cropmatch = anymatch(crop_code), values($topcrop_area)
keep if cropmatch==1
drop cropmatch
ren imprv_seed_use all_imprv_seed_
gen all_hybrid_seed_ = .
gen farmer_ = 1 //indiv update
gen cropname=""
forvalues k=1/$nb_topcrops {
	local c : word `k' of $topcrop_area
	local cn : word `k' of $topcropname_area
	replace cropname = "`cn'" if crop_code==`c'
}
drop crop_code
bys hhid indiv : egen all_imprv_seed_use = max(all_imprv_seed_)
reshape wide all_imprv_seed_ all_hybrid_seed_ farmer_, i(hhid all_imprv_seed_use indiv) j(cropname) string //indiv update
forvalues k=1/$nb_topcrops {
	local c : word `k' of $topcrop_area
	local cn : word `k' of $topcropname_area
	capture confirm var all_imprv_seed_`cn' //Checks for missing topcrops
	if _rc!=0 { 
		gen all_imprv_seed_`cn'=.
		gen all_hybrid_seed_`cn'=.
		gen `cn'_farmer=0
	}
}
gen all_hybrid_seed_use=.
ren farmer_* *_farmer 
drop if indiv==.
recode all_imprv_seed_* *_farmer (.=0) 
merge m:1 hhid indiv using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_gender_merge.dta", nogen //10,635 matched, 57,457 not matched
lab var all_imprv_seed_use "1 = Individual farmer (plot manager) uses improved seeds"
forvalues k=1/$nb_topcrops {
	local v : word `k' of $topcropname_area
	local vn : word `k' of $topcropname_area_full
	lab var all_imprv_seed_`v' "1 = Individual farmer (plot manager) uses improved seeds - `vn'"
	lab var all_hybrid_seed_`v' "1 = Individual farmer (plot manager) uses hybrid seeds - `vn'"
	lab var `v'_farmer "1 = Individual farmer (plot manager) grows `vn'"
}
gen farm_manager=1 if indiv!=.
recode farm_manager (.=0)
lab var farm_manager "1=Indvidual is listed as a manager for at least one plot" 
*Replacing permanent crop seed information with missing because this section does not ask about permanent crops
replace all_imprv_seed_cassav = . 
//replace all_imprv_seed_banana = . 
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_farmer_improvedseed_use.dta", replace

//if individual uses any improved seed on any plot


********************************************************************************
*WOMEN'S DIET QUALITY	
******************************************************************************** 
*Women's diet quality: proportion of women consuming nutrient-rich foods (%)
*Information not available


********************************************************************************
*HOUSEHOLD'S DIET DIVERSITY SCORE -- CWL done, CG checked 2.22.2024	
******************************************************************************** 
* Malawi LSMS 4 does not report individual consumption but instead household level consumption of various food items.
* Thus, only the proportion of household eating nutritious food can be estimated
use "${MWI_IHS_IHPS_W4_raw_data}/HH_MOD_G1.dta" , clear
* recode food items to map HDDS food categories
rename hh_g02 itemcode
recode itemcode 	(101/116 118 835 				=1	"CEREALS" )  //// 
					(201/208    					=2	"WHITE ROOTS,TUBERS AND OTHER STARCHES"	)  ////
					(491/413     	 				=3	"VEGETABLES"	)  ////	
					(601/610     					=4	"FRUITS"	)  ////	
					(504/512 522 824/825			=5	"MEAT"	)  ////					
					(501 823						=6	"EGGS"	)  ////
					(826 5021/5123					=7  "FISH") ///
					(401/413    					=8	"LEGUMES, NUTS AND SEEDS") ///
					(701/708						=9	"MILK AND MILK PRODUCTS")  ////
					(803   					        =10	"OILS AND FATS"	)  ////
					(801/802 815/817 827     		=11	"SWEETS"	)  //// 
					(810/814 901/915                =14 "SPICES, CONDIMENTS, BEVERAGES"	)  ////
					,generate(Diet_ID)		
gen adiet_yes=(hh_g01==1)
ta Diet_ID   
** Now, collapse to food group level; household consumes a food group if it consumes at least one item
collapse (max) adiet_yes, by(hhid case_id Diet_ID) 
label define YesNo 1 "Yes" 0 "No"
label val adiet_yes YesNo
* Now, estimate the number of food groups eaten by each household
collapse (sum) adiet_yes, by(hhid case_id)
ren adiet_yes number_foodgroup 
sum number_foodgroup 
local cut_off1=6
local cut_off2=round(r(mean))
gen household_diet_cut_off1=(number_foodgroup>=`cut_off1')
gen household_diet_cut_off2=(number_foodgroup>=`cut_off2')
lab var household_diet_cut_off1 "1= houseold consumed at least `cut_off1' of the 12 food groups last week" 
lab var household_diet_cut_off2 "1= houseold consumed at least `cut_off2' of the 12 food groups last week" 
label var number_foodgroup "Number of food groups individual consumed last week HDDS"
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_household_diet.dta", replace

********************************************************************************
*WOMEN'S CONTROL OVER INCOME -- CG complete 2.28.2024
******************************************************************************** 
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_d.dta", clear
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_k.dta"
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_g.dta"
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_m.dta"
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_r1.dta"

* Control over Crop production income
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_i.dta"  // control over crop sale earnings rainy season
// append using "${Malawi_IHPS_W2_appended_data}\Agriculture\ag_mod_ba_13.dta" // control over crop sale earnings rainy season
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_o.dta" // control over crop sale earnings dry season
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_p.dta" 

append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_q.dta"  // control over permanent crop sale earnings 

append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_r1.dta"
* Control over Livestock production income
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_s.dta" // control over livestock product sale earnings
* Control over wage income
append using "${MWI_IHS_IHPS_W4_raw_data}\hh_mod_e.dta" // control over salary payment, allowances/gratuities, ganyu labor earnings 
* Control over business income
append using "${MWI_IHS_IHPS_W4_raw_data}\hh_mod_n2.dta" // household enterprise ownership
* Control over program assistance 
append using "${MWI_IHS_IHPS_W4_raw_data}\hh_mod_r.dta"
* Control over other income 
append using "${MWI_IHS_IHPS_W4_raw_data}\hh_mod_p.dta"
* Control over remittances
append using "${MWI_IHS_IHPS_W4_raw_data}\hh_mod_o.dta"
ren gardenid garden_id
ren plotid plot_id
gen type_decision="" 
gen controller_income1=. 
gen controller_income2=.

/* No question in MW4
* control of harvest from permanent crops
replace type_decision="control_permharvest" if  !inlist( ag6a_08_1, .,0,99) |  !inlist( ag6a_08_2, .,0,99) 
replace controller_income1=ag6a_08_1 if !inlist( ag6a_08_1, .,0,99)  
replace controller_income2=ag6a_08_2 if !inlist( ag6a_08_2, .,0,99)
replace type_decision="control_permharvest" if  !inlist( ag6b_08_1, .,0,99) |  !inlist( ag6b_08_2, .,0,99) 
replace controller_income1=ag6b_08_1 if !inlist( ag6b_08_1, .,0,99)  
replace controller_income2=ag6b_08_2 if !inlist( ag6b_08_2, .,0,99)
*/

* control of harvest from annual crops
replace type_decision="control_annualharvest" if  !inlist( ag_g14a, .,0,99) |  !inlist( ag_g14b, .,0,99) 
replace controller_income1=ag_g14a if !inlist( ag_g14a, .,0,99)  
replace controller_income2=ag_g14b if !inlist( ag_g14b, .,0,99)
replace type_decision="control_annualharvest" if  !inlist( ag_m13a, .,0,99) |  !inlist( ag_m13b, .,0,99) 
replace controller_income1=ag_m13a if !inlist( ag_m13a, .,0,99)  
replace controller_income2= ag_m13b if !inlist( ag_m13b, .,0,99)

* control annualsales
replace type_decision="control_annualsales" if  !inlist( ag_i14a, .,0,99) |  !inlist( ag_i14b, .,0,99) 
replace controller_income1=ag_i14a if !inlist(ag_i14a, .,0,99)  
replace controller_income2=ag_i14b if !inlist(ag_i14b, .,0,99)
replace type_decision="control_annualsales" if  !inlist(ag_o14a, .,0,99) |  !inlist( ag_o14b, .,0,99) 
replace controller_income1=ag_o14a if !inlist( ag_o14a, .,0,99)  
replace controller_income2=ag_o14b if !inlist( ag_o14b, .,0,99)

* append who controls earning from sale to customer 2 
preserve
replace type_decision="control_annualsales" if  !inlist( ag_i23a, .,0,99) |  !inlist( ag_i23b, .,0,99) 
replace controller_income1=ag_i23a if !inlist( ag_i23a, .,0,99)  
replace controller_income2=ag_i23b if !inlist( ag_i23b, .,0,99)
**No data for W4
/*replace type_decision="control_annualsales" if  !inlist( ag_o23a, .,0,99) |  !inlist( ag_o23b, .,0,99) 
replace controller_income1=ag_o23a if !inlist( ag_o23a, .,0,99)  
replace controller_income2=ag_o23b if !inlist( ag_o23b, .,0,99)
keep if !inlist( ag_i23a, .,0,99) |  !inlist( ag_i23b, .,0,99)  | !inlist( ag_o23a, .,0,99) |  !inlist( ag_o23b, .,0,99) */
keep hhid plot_id garden_id type_decision controller_income1 controller_income2
tempfile saletocustomer2
save `saletocustomer2'
restore
append using `saletocustomer2'

* control_permsales
replace type_decision="control_permsales" if  !inlist( ag_q14a, .,0,99) |  !inlist( ag_q14b, .,0,99) 
replace controller_income1=ag_q14a if !inlist( ag_q14a, .,0,99)  
replace controller_income2=ag_q14b if !inlist( ag_q14b, .,0,99)
replace type_decision="control_permsales" if  !inlist( ag_q23a, .,0,99) |  !inlist( ag_q23b, .,0,99) 
replace controller_income1=ag_q23a if !inlist( ag_q23a, .,0,99)  
replace controller_income2=ag_q23b if !inlist( ag_q23b, .,0,99)

* livestock_sales (products- milk, eggs, meat) 
replace type_decision="control_livestocksales" if  !inlist( ag_s07a, .,0,99) |  !inlist( ag_s07b, .,0,99) 
replace controller_income1=ag_s07a if !inlist( ag_s07a, .,0,99)  
replace controller_income2=ag_s07b if !inlist( ag_s07b, .,0,99)

* Fish production income 
*No information available in MW4

* Business income 
* W4 did not ask directly about of who controls Business Income. We are making the assumption that whoever owns the business might have some sort of control over the income generated by the business. We don't think that the business manager have control of the business income. If they do, they are probably listed as owner
* control_businessincome
replace type_decision="control_businessincome" if  !inlist( hh_n12a, .,0,99) |  !inlist( hh_n12b, .,0,99) 
replace controller_income1=hh_n12a if !inlist( hh_n12a, .,0,99)  
replace controller_income2=hh_n12b if !inlist( hh_n12b, .,0,99)

** --- Wage income --- **
* W4 has questions on control over salary payments & allowances/gratuities in main + secondary job & ganyu earnings

* control_salary
replace type_decision="control_salary" if  !inlist( hh_e26_1a, .,0,99) |  !inlist( hh_e26_1b, .,0,99) // main wage job
replace controller_income1=hh_e26_1a if !inlist( hh_e26_1a , .,0,99)  
replace controller_income2=hh_e26_1b if !inlist( hh_e26_1b, .,0,99)
* append who controls salary earnings from secondary job
preserve
replace type_decision="control_salary" if  !inlist(hh_e40_1a , .,0,99) |  !inlist(hh_e40_1b, .,0,99) 
replace controller_income1=hh_e40_1a if !inlist( hh_e40_1a , .,0,99)  
replace controller_income2=hh_e40_1b if !inlist( hh_e40_1b, .,0,99)
keep if !inlist( hh_e40_1a, .,0,99) |  !inlist( hh_e40_1b, .,0,99)  
keep hhid plot_id garden_id type_decision controller_income1 controller_income2
tempfile wages2
save `wages2'
restore
append using `wages2'

* control_allowances
replace type_decision="control_allowances" if  !inlist(hh_e28_1a , .,0,99) |  !inlist(hh_e28_1b , .,0,99) 
replace controller_income1=hh_e28_1a if !inlist(hh_e28_1a , .,0,99)  
replace controller_income2=hh_e28_1b if !inlist(hh_e28_1b , .,0,99)
* append who controls  allowance/gratuity earnings from secondary job
preserve
replace type_decision="control_allowances" if  !inlist(hh_e42_1a , .,0,99) |  !inlist(hh_e42_1b , .,0,99) 
replace controller_income1=hh_e42_1a if !inlist( hh_e42_1a, .,0,99)  
replace controller_income2= hh_e42_1b if !inlist( , .,0,99)
keep if !inlist( hh_e42_1a, .,0,99) |  !inlist(hh_e42_1b , .,0,99) 
keep hhid plot_id garden_id type_decision controller_income1 controller_income2
tempfile allowances2
save `allowances2'
restore
append using `allowances2'

* control_ganyu
destring hh_e59_1a, replace
destring hh_e59_1b, replace
replace type_decision="control_ganyu" if !inlist(hh_e59_1a, .,0,99) | !inlist(hh_e59_1b, .,0,99) 
replace controller_income1=hh_e59_1a if !inlist( hh_e59_1a, .,0,99)  
replace controller_income2=hh_e59_1b if !inlist( hh_e59_1b, .,0,99)

* control_remittance
replace type_decision="control_remittance" if  !inlist( hh_o14_1a, .,0,99) |  !inlist( hh_o14_1b, .,0,99) 
replace controller_income1=hh_o14_1a if !inlist( hh_o14_1a, .,0,99)  
replace controller_income2=hh_o14_1b if !inlist( hh_o14_1b, .,0,99)
* append who controls in-kind remittances
preserve
replace type_decision="control_remittance" if  !inlist( hh_o18a, .,0,99) |  !inlist( hh_o18b, .,0,99) 
replace controller_income1=hh_o18a if !inlist( hh_o18a, .,0,99)  
replace controller_income2=hh_o18b if !inlist( hh_o18b, .,0,99)
keep if  !inlist( hh_o18a, .,0,99) |  !inlist( hh_o18b, .,0,99) 
keep hhid case_id plot_id garden_id type_decision controller_income1 controller_income2
tempfile control_remittance2
save `control_remittance2'
restore
append using `control_remittance2'

* control_assistance income
replace type_decision="control_assistance" if  !inlist( hh_r05a, .,0,99) |  !inlist( hh_r05b, .,0,99) 
replace controller_income1=hh_r05a if !inlist( hh_r05a, .,0,99)  
replace controller_income2=hh_r05b if !inlist( hh_r05b, .,0,99)

* control_other income 
replace type_decision="control_otherincome" if  !inlist(hh_p04a , .,0,99) |  !inlist(hh_p04b , .,0,99) 
replace controller_income1=hh_p04a if !inlist(hh_p04a , .,0,99)  
replace controller_income2=hh_p04b if !inlist(hh_p04b , .,0,99) 

keep hhid case_id plot_id garden_id type_decision controller_income1 controller_income2

preserve
keep hhid case_id plot_id garden_id type_decision controller_income2
drop if controller_income2==.
ren controller_income2 controller_income
tempfile controller_income2
save `controller_income2'
restore
keep hhid case_id plot_id garden_id type_decision controller_income1
drop if controller_income1==.
ren controller_income1 controller_income
append using `controller_income2'
 
* create group


gen control_cropincome=1 if  type_decision=="control_annualharvest" ///
							| type_decision=="control_annualsales" ///
							| type_decision=="control_permsales" ///
						
recode 	control_cropincome (.=0)		
							
gen control_livestockincome=1 if  type_decision=="control_livestocksales" 												
recode 	control_livestockincome (.=0)

gen control_farmincome=1 if  control_cropincome==1 | control_livestockincome==1							
recode 	control_farmincome (.=0)		
							
gen control_businessincome=1 if  type_decision=="control_businessincome" 
recode 	control_businessincome (.=0)

gen control_salaryincome=1 if type_decision=="control_salary"| type_decision=="control_allowances"| type_decision=="control_ganyu"						 
																					
gen control_nonfarmincome=1 if  type_decision=="control_remittance" 
							  | type_decision=="control_assistance"
							  | type_decision=="control_otherincome" 
							  | control_salaryincome== 1 
							  | control_businessincome== 1 
recode 	control_nonfarmincome (.=0)
																		
collapse (max) control_* , by(hhid case_id controller_income )  //any decision
gen control_all_income=1 if  control_farmincome== 1 | control_nonfarmincome==1
recode 	control_all_income (.=0)															
ren controller_income indiv
*	Now merge with member characteristics
recast str50 hhid, force
merge 1:m hhid case_id indiv  using  "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_person_ids.dta", nogen keep (3) // 23,186  matched

recode control_* (.=0)
lab var control_cropincome "1=individual has control over crop income"
lab var control_livestockincome "1=individual has control over livestock income"
lab var control_farmincome "1=individual has control over farm (crop or livestock) income"
lab var control_businessincome "1=individual has control over business income"
lab var control_salaryincome "1= individual has control over salary income"
lab var control_nonfarmincome "1=individual has control over non-farm (business, salary, assistance, remittances or other income) income"
lab var control_all_income "1=individual has control over at least one type of income"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_control_income.dta", replace

********************************************************************************
*WOMEN'S AG DECISION-MAKING	// Complete CG 2.28.2024
******************************************************************************** 
*	Code as 1 if a woman is listed as one of the decision-makers for at least 2 plots, crops, or livestock activities; 
*	can report on % of women who make decisions, taking total number of women HH members as denominator
*	In most cases, MWI LSMS 4 lists the first TWO decision makers.
*	Indicator may be biased downward if some women would participate in decisions but are not listed among the first two
* first append all files related to agricultural activities with income in who participate in the decision making

use  "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_d.dta", clear
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_k.dta" 
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_g.dta"
append using  "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_m.dta"
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_i.dta"
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_i2.dta"
append using  "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_o.dta"
append using  "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_b2.dta"
append using  "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_p.dta"
append using  "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_q.dta"
append using  "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_r1.dta"
gen type_decision="" 
gen decision_maker1=.
gen decision_maker2=.
gen decision_maker3=.
gen decision_maker4=. 
ren gardenid garden_id
ren plotid plot_id

* planting_input - Makes decision about plot Rainy Season
*Decisions concerning the timing of cropping activities, crop choice and input use on the [PLOT]
replace type_decision="planting_input" if !inlist(ag_d01, .,0,99) | !inlist(ag_d01_2a, .,0,99) | !inlist(ag_d01_2b, .,0,99)
replace decision_maker1=ag_d01 if !inlist(ag_d01, .,0,99, 98) & ag_d01 !=.
replace decision_maker2=ag_d01_2a if !inlist(ag_d01_2a, .,0,99, 98) & ag_d01_2a !=.
replace decision_maker3=ag_d01_2b if !inlist(ag_d01_2b, .,0,99, 98) & ag_d01_2b!=.

* Makes decision about plot dry Season
replace type_decision="planting_input" if !inlist(ag_k02, .,0,99) | !inlist(ag_k02_2a, .,0,99) | !inlist(ag_k02_2b, .,0,99)
replace decision_maker1=ag_k02 if !inlist(ag_k02, .,0,99, 98) & ag_k02!=.
replace decision_maker2=ag_k02_2a if !inlist(ag_k02_2a, .,0,99, 98) & ag_k02_2a!=. 
replace decision_maker3=ag_k02_2b if !inlist(ag_k02_2b, .,0,99, 98) & ag_k02_2b!=.

* append who make decision about (owner garden) rainy
// data about plot ownership missing in W4, switching to garden - ag_b213
preserve
replace type_decision="planting_input" if !inlist(ag_b213__0, .,0,99) | !inlist(ag_b213__1, .,0,99)
replace decision_maker1=ag_b213__0 if !inlist(ag_b213__0, .,0,99, 98) 
replace decision_maker2=ag_b213__1 if !inlist(ag_b213__1, .,0,99, 98) 

* append who make decision about (owner garden) dry
// data about plot ownership missing in W4, changed for garden ownership - ag_i213
replace type_decision="planting_input" if !inlist(ag_i213a, .,0,99) | !inlist(ag_i213b, .,0,99)
replace decision_maker1=ag_i213a if !inlist(ag_i213a, .,0,99, 98) 
replace decision_maker2=ag_i213b if !inlist(ag_i213b, .,0,99, 98) 

keep if !inlist(ag_b213__0, .,0,99) | !inlist(ag_b213__1, .,0,99) | !inlist(ag_i213a, .,0,99)| !inlist(ag_i213b, .,0,99)

keep hhid case_id type_decision decision_maker*
tempfile planting_input1
save `planting_input1'
restore
append using `planting_input1' 
 
*Decisions concerning harvested crop Rainy
replace type_decision="harvest"  if !inlist(ag_g14a, .,0,99) | !inlist(ag_g14b, .,0,99)
replace decision_maker1=ag_g14a if  !inlist( ag_g14a, .,0,99, 98)
replace decision_maker2=ag_g14b if  !inlist( ag_g14b, .,0,99, 98)

*Decisions concerning harvested crop Dry 
replace type_decision="harvest" if !inlist(ag_m13a, .,0,99) | !inlist(ag_m13b, .,0,99) 
replace decision_maker1=ag_m13a if !inlist( ag_m13a, .,0,99, 98)
replace decision_maker2=ag_m13b if !inlist( ag_m13b, .,0,99, 98)

*Livestock owners
replace type_decision="livestockowners" if !inlist(ag_r05a, .,0,99) | !inlist(ag_r05b, .,0,99)
replace decision_maker1=ag_r05a if !inlist(ag_r05a, .,0,99) 
replace decision_maker2=ag_r05b if !inlist(ag_r05b, .,0,99) 

/*data about negotiating missing in W4
/*replace type_decision="sales_annualcrop" if !inlist(ag_i12_1a, .,0,99) | !inlist(ag_i12_1b, .,0,99)
replace decision_maker1=ag_i12_1a if !inlist(ag_i12_1a, .,0,99) 
replace decision_maker2=ag_i21_1a if !inlist(ag_i12_1b, .,0,99) 

replace type_decision="sales_annualcrop" if !inlist(ag_i21_1a, .,0,99) | !inlist(ag_i21_1b, .,0,99)
replace decision_maker1=ag_i21_1a if !inlist(ag_i21_1a, .,0,99) 
replace decision_maker2=ag_i21_1b if !inlist(ag_i21_1b, .,0,99)

* append who make negotiate sale to customer 2
preserve
replace type_decision="sales_annualcrop" if !inlist(ag_o12_1a, .,0,99) | !inlist(ag_o12_1b, .,0,99)
replace decision_maker1=ag_o12_1a if !inlist(ag_o12_1a, .,0,99) 
replace decision_maker2=ag_o21_1a if !inlist(ag_o12_1b, .,0,99) 

replace type_decision="sales_annualcrop" if !inlist(ag_o21_1a, .,0,99) | !inlist(ag_o21_1b, .,0,99)
replace decision_maker1=ag_o21_1a if !inlist(ag_o21_1a, .,0,99) 
replace decision_maker2=ag_o21_1b if !inlist(ag_o21_1b, .,0,99)
keep if !inlist(ag_o12_1a, .,0,99) | !inlist(ag_o12_1b, .,0,99) | !inlist(ag_o21_1a, .,0,99) | !inlist(ag_o21_1b, .,0,99)*/ 

keep hhid type_decision decision_maker* 
tempfile sales_annualcrop2
save `sales_annualcrop2'
append using `sales_annualcrop2' */

keep hhid case_id type_decision decision_maker1 decision_maker2 decision_maker3 decision_maker4 
preserve
keep hhid case_id type_decision decision_maker2
drop if decision_maker2==.
ren decision_maker2 decision_maker
tempfile decision_maker2
save `decision_maker2'
restore
preserve
keep hhid case_id type_decision decision_maker3
drop if decision_maker3==.
ren decision_maker3 decision_maker
tempfile decision_maker3
save `decision_maker3'
restore
preserve
keep hhid case_id type_decision decision_maker4
drop if decision_maker4==.
ren decision_maker4 decision_maker
tempfile decision_maker4
save `decision_maker4'
restore

keep hhid type_decision decision_maker1
drop if decision_maker1==.
ren decision_maker1 decision_maker
append using `decision_maker2'
append using `decision_maker3'
append using `decision_maker4'
* number of time appears as decision maker
bysort hhid decision_maker : egen nb_decision_participation=count(decision_maker)
drop if nb_decision_participation==1
gen make_decision_crop=1 if  type_decision=="planting_input" ///
							| type_decision=="harvest" ///
							/*| type_decision=="sales_annualcrop" ///
							| type_decision=="sales_processcrop"*/
recode 	make_decision_crop (.=0)
gen make_decision_livestock=1 if  type_decision=="livestockowners"   
recode 	make_decision_livestock (.=0)
gen make_decision_ag=1 if make_decision_crop==1 | make_decision_livestock==1
recode 	make_decision_ag (.=0)
collapse (max) make_decision_* , by(hhid case_id decision_maker )  //any decision
ren decision_maker indiv 
* Now merge with member characteristics
recast str50 hhid, force
merge 1:m hhid case_id indiv  using  "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_person_ids.dta", nogen // 4,576 matched
* 1 member ID in decision files not in member list
recode make_decision_* (.=0)
lab var make_decision_crop "1=invidual makes decision about crop production activities"
lab var make_decision_livestock "1=invidual makes decision about livestock production activities"
lab var make_decision_ag "1=invidual makes decision about agricultural (crop or livestock) production activities"

save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_make_ag_decision.dta", replace

********************************************************************************
*WOMEN'S ASSET OWNERSHIP CG complete 2.28.24
******************************************************************************** 
* Code as 1 if a woman is sole or joint owner of any specified productive asset; 
* can report on % of women who own, taking total number of women HH members as denominator
* MWI W4 asked to list the first TWO owners.
* Indicator may be biased downward if some women would have been not listed among the two the first 2 asset-owners can also claim ownership of some assets

*First, append all files with information on asset ownership
use "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_b2.dta", clear //rainy
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_i2.dta" //dry
append using "${MWI_IHS_IHPS_W4_raw_data}\ag_mod_r1.dta"
gen type_asset=""
gen asset_owner1=.
gen asset_owner2=.
gen asset_owner3=.
gen asset_owner4=.

* Ownership of land.
// data missing about title/ownership doc in W4, used "who owns this garden"
replace type_asset="landowners" if  !inlist( ag_b213__0, .,0,99) |  !inlist( ag_b213__1, .,0,99)
replace asset_owner1=ag_b213__0 if !inlist(ag_b213__0, .,0,99)  
replace asset_owner2=ag_b213__1 if !inlist( ag_b213__1, .,0,99)


replace type_asset="landowners" if  !inlist( ag_i213a, .,0,99) |  !inlist( ag_i213b, .,0,99) 
replace asset_owner1= ag_i213a if !inlist(  ag_i213a, .,0,99)  
replace asset_owner2= ag_i213b if !inlist(  ag_i213b, .,0,99)
preserve

/* no data on who in HH can decide whether to sell the garden in W4 
replace type_asset="landowners" if  !inlist( ag_b204_6a__0, .,0,99) |  !inlist( ag_b204_6a__1, .,0,99) |  !inlist( ag_b204_6a__2, .,0,99) |  !inlist( ag_b204_6a__3, .,0,99) 
replace asset_owner1=ag_b204_6a__0 if !inlist(ag_b204_6a__0, .,0,99)
replace asset_owner2=ag_b204_6a__1 if !inlist( ag_b204_6a__1, .,0,99)
replace asset_owner3=ag_b204_6a__2 if !inlist( ag_b204_6a__2, .,0,99)
replace asset_owner4=ag_b204_6a__3 if !inlist( ag_b204_6a__3, .,0,99) 

replace type_asset="landowners" if  !inlist( ag_i204_6a_1, .,0,99) |  !inlist( ag_i204_6a_2, .,0,99) |  !inlist( ag_i204_6a_3, .,0,99) |  !inlist( ag_i204_6a_4, .,0,99) 
replace asset_owner1=ag_i204_6a_1 if !inlist(ag_i204_6a_1, .,0,99)
replace asset_owner2=ag_i204_6a_2 if !inlist( ag_i204_6a_2, .,0,99)
replace asset_owner3=ag_i204_6a_3 if !inlist( ag_i204_6a_3, .,0,99)
replace asset_owner4=ag_i204_6a_4 if !inlist( ag_i204_6a_4, .,0,99) */
keep hhid case_id type_asset asset_owner*
tempfile land2
save `land2'
restore
append using `land2'

*non-poultry livestock (keeps/manages)
replace type_asset="livestockowners" if  !inlist( ag_r05a, .,0,99) |  !inlist( ag_r05b, .,0,99)  
replace asset_owner1=ag_r05a if !inlist( ag_r05a, .,0,99)  
replace asset_owner2=ag_r05b if !inlist( ag_r05b, .,0,99)

* non-farm equipment,  large durables/appliances, mobile phone
// Module M: FARM IMPLEMENTS, MACHINERY, AND STRUCTURES - does not report who in the household own them
// No ownership information regarding non-farm equipment,  large durables/appliances, mobile phone

keep hhid case_id type_asset asset_owner1 asset_owner2 asset_owner3 asset_owner4

preserve
keep hhid case_id type_asset asset_owner2
drop if asset_owner2==.
ren asset_owner2 asset_owner
tempfile asset_owner2
save `asset_owner2'
restore

preserve
keep hhid case_id type_asset asset_owner3
drop if asset_owner3==.
ren asset_owner3 asset_owner
tempfile asset_owner3
save `asset_owner3'
restore

preserve
keep hhid case_id type_asset asset_owner4
drop if asset_owner4==.
ren asset_owner4 asset_owner
tempfile asset_owner4
save `asset_owner4'
restore

keep hhid case_id type_asset asset_owner1
drop if asset_owner1==.
ren asset_owner1 asset_owner
append using `asset_owner2'
append using `asset_owner3'
append using `asset_owner4'
gen own_asset=1 
collapse (max) own_asset, by (hhid case_id asset_owner)
ren asset_owner indiv

* Now merge with member characteristics
recast str50 hhid, force 
merge 1:m hhid indiv  using  "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_person_ids.dta", nogen 
recode own_asset (.=0)
lab var own_asset "1=invidual owns an assets (land or livestock)"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_ownasset.dta", replace

********************************************************************************
*AGRICULTURAL WAGES  *CWL complete 9/27/2022 - not checked, CG complete 2.29.2024
********************************************************************************
**# Bookmark #1
/* The Malawi W4 instrument did not ask survey respondents to report number of laborers per day by laborer type.
*All preprocessing done in ag expenses
use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_plot_labor_long.dta", clear
keep if strmatch(labor_type,"hired") & (strmatch(gender,"male") | strmatch(gender,"female"))
collapse (sum) wage_paid_aglabor_=val hired_=number, by(hhid gender)
reshape wide wage_paid_aglabor_ hired_, i(hhid) j(gender) string
egen wage_paid_aglabor = rowtotal(wage*)
egen hired_all = rowtotal(hired*)
lab var wage_paid_aglabor "Daily agricultural wage paid for hired labor (local currency)"
lab var wage_paid_aglabor_female "Daily agricultural wage paid for hired labor - female workers(local currency)"
lab var wage_paid_aglabor_male "Daily agricultural wage paid for hired labor - male workers (local currency)"
lab var hired_all "Total hired labor (number of persons)"
lab var hired_female "Total hired labor (number of persons) -female workers"
lab var hired_male "Total hired labor (number of persons) -male workers"
//keep hhid wage_paid_aglabor wage_paid_aglabor_female wage_paid_aglabor_male //Why did we get number of persons only to drop it at the end?
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_ag_wage.dta", replace */


*Hired labor: Module D of Agriculture Survey
use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_d.dta", clear // Rainy season

/* CWL Note: ag_d46* and ag_d47* look identical in label and instrument - one hypothesis 
is that d46 is for non-panel households and d47 is for panel households where panel households are
involved in multiple waves of the survey. calculating both for comparison
but only including 47 following MWI W3 ag expenses code. 
*/

//Calculating for non-panel households
// CWL: ag_46*1 is labeled "...any non-harvest activity" but instrument says "any and all types of activities" without specifying harvest or non-harvest. 
rename ag_d46a1 no_days_men_npanel // non harvest activities: land preparation, planting, ridging, weeding, fertilizing
rename ag_d46b1 avg_dlywg_men_npanel		// men daily wage 
rename ag_d46a2 no_days_women_npanel
rename ag_d46b2 avg_dlywg_women_npanel
rename ag_d46a3 no_days_chldrn_npanel
rename ag_d46b3 avg_dlywg_chldrn_npanel
recode no_days_men_npanel avg_dlywg_men_npanel no_days_women_npanel avg_dlywg_women_npanel no_days_chldrn_npanel avg_dlywg_chldrn_npanel (.=0)

gen tot_wg_men_npanel = no_days_men_npanel*avg_dlywg_men_npanel 			//wages: rainy season male 
gen tot_wg_women_npanel = no_days_women_npanel*avg_dlywg_women_npanel 		//wages: rainy season female 
gen tot_wg_chldrn_npanel = no_days_chldrn_npanel*avg_dlywg_chldrn_npanel 	//wages: rainy season children 

rename ag_d47a1 no_days_men_nharv 		// non harvest activities: land preparation, planting, ridging, weeding, fertilizing
rename ag_d47b1 avg_dlywg_men_nharv		// men daily wage 
rename ag_d47a2 no_days_women_nharv
rename ag_d47b2 avg_dlywg_women_nharv
rename ag_d47a3 no_days_chldrn_nharv
rename ag_d47b3 avg_dlywg_chldrn_nharv
recode no_days_men_nharv avg_dlywg_men_nharv no_days_women_nharv avg_dlywg_women_nharv no_days_chldrn_nharv avg_dlywg_chldrn_nharv (.=0)

rename ag_d48a1 no_days_men_harv 		// Harvesting wages
rename ag_d48b1 avg_dlywg_men_harv
rename ag_d48a2 no_days_women_harv
rename ag_d48b2 avg_dlywg_women_harv
rename ag_d48a3 no_days_chldrn_harv
rename ag_d48b3 avg_dlywg_chldrn_harv
recode no_days_men_harv avg_dlywg_men_harv no_days_women_harv avg_dlywg_women_harv no_days_chldrn_harv avg_dlywg_chldrn_harv (.=0)

gen tot_wg_men_nharv = no_days_men_nharv*avg_dlywg_men_nharv 			//wages: rainy season male non-harvest activities 
gen tot_wg_women_nharv = no_days_women_nharv*avg_dlywg_women_nharv 		//wages: rainy season female non-harvest activities
gen tot_wg_chldrn_nharv = no_days_chldrn_nharv*avg_dlywg_chldrn_nharv 	//wages: rainy season children non-harvest activities
gen tot_wg_men_harv = no_days_men_harv*avg_dlywg_men_harv 				//wages: rainy season male harvest activities 
gen tot_wg_women_harv = no_days_women_harv*avg_dlywg_women_harv 		//wages: rainy season female harvest activities
gen tot_wg_chldrn_harv = no_days_chldrn_harv*avg_dlywg_chldrn_harv 		//wages: rainy season children harvest activities

*TOtaL WAGES PAID IN RAINY SEASON (add them all up)
gen wages_paid_rainy = tot_wg_men_nharv + tot_wg_women_nharv + tot_wg_chldrn_nharv + tot_wg_men_harv + tot_wg_women_harv + tot_wg_chldrn_harv //This does not include in-kind payments, which are separate in Qs [D50-D53]. 
gen wages_paid_rainy_npanel = tot_wg_men_npanel + tot_wg_women_npanel + tot_wg_chldrn_npanel 

collapse (sum) wages_paid_rainy wages_paid_rainy_npanel, by (hhid case_id) 

//Compare panel and non-panel households - unclear what the relationship is here given most the households that have wages_paid_rainy have two figured for panel and nonpanel which are different numbers. 
count if missing(wages_paid_rainy) //0 missing
count if missing(wages_paid_rainy_npanel) // 0 missing
count if wages_paid_rainy==0 & wages_paid_rainy_npanel==0 //6630
count if wages_paid_rainy !=0 & wages_paid_rainy_npanel !=0 //1390
count if wages_paid_rainy !=0 & wages_paid_rainy_npanel !=0 & wages_paid_rainy !=wages_paid_rainy_npanel //902
count if wages_paid_rainy !=0 & wages_paid_rainy_npanel !=0 & wages_paid_rainy>wages_paid_rainy_npanel //386
drop wages_paid_rainy_npanel
// CWL: we will keep only wages_paid_rainy and non non-panel following W3 for now.

label variable wages_paid_rainy "Wages paid for hired labor in rainy season"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_wages_rainyseason.dta", replace

use "${MWI_IHS_IHPS_W4_raw_data}/ag_mod_k.dta", clear 		// For dry season: All types of activities, no split between harvest and non-harvest like rainy. Check dta: survey says all activites but dta reads for all non-harvest acitivites.  
rename ag_k46a1 no_days_men_all
rename ag_k46b1 avg_dlywg_men_all
rename ag_k46a2 no_days_women_all
rename ag_k46b2 avg_dlywg_women_all
rename ag_k46a3 no_days_chldrn_all
rename ag_k46b3 avg_dlywg_chldrn_all
recode no_days_men_all avg_dlywg_men_all no_days_women_all avg_dlywg_women_all no_days_chldrn_all avg_dlywg_chldrn_all (.=0)

gen tot_wg_men_all = no_days_men_all*avg_dlywg_men_all 			//wages: dry season male
gen tot_wg_women_all = no_days_women_all*avg_dlywg_women_all 	//wages: dry season female 
gen tot_wg_chldrn_all = no_days_chldrn_all*avg_dlywg_chldrn_all //wages:  dry season children 

gen wages_paid_dry = tot_wg_men_all + tot_wg_women_all + tot_wg_chldrn_all //This does not include in-kind payments, which are separate in Qs. 

collapse (sum) wages_paid_dry, by (hhid case_id) 
lab var wages_paid_dry  "Wages paid for hired labor in rainyseason"
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_wages_dryseason.dta", replace

// get wages paid at a household level by adding up wages paid in dry and rainy season 
use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_wages_rainyseason.dta", clear
merge 1:1 hhid using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_wages_dryseason.dta", nogen
gen total_wages_paid = wages_paid_rainy if wages_paid_dry==.
replace total_wages_paid = wages_paid_dry if wages_paid_rainy==.
replace total_wages_paid = wages_paid_rainy if wages_paid_dry!=. & wages_paid_rainy!=.
count if missing(total_wages_paid) // no missing wages paid
label variable wages_paid_rainy "Wages paid for hired labor in rainy season"
label variable wages_paid_dry "Wages paid for hired labor in dry season"
*missing end to this
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_ag_wage.dta", replace

********************************************************************************
*CROP YIELDS - COMPLETE CG 3.4.2024
********************************************************************************
use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_all_plots.dta", clear
gen number_trees_planted_banana = number_trees_planted if crop_code == 55
recode crop_code (52 53 54 56 57 58 59 60 61 62 63 64=100) // recode to "other fruit":  mango, orange, papaya, avocado, guava, lemon, tangerine, peach, poza, masuku, masau, pineapple
*global topcropname_area "maize rice wheat sorgum pmill cowpea grdnt beans yam swtptt cassav banana cotton sunflr pigpea" global topcrop_area "11 12 16 13 14 32 43 31 24 22 21 71 50 41 34"
gen number_trees_planted_other_fruit = number_trees_planted if crop_code == 100
gen number_trees_planted_cassava = number_trees_planted if crop_code == 49
gen number_trees_planted_tea = number_trees_planted if crop_code == 50
gen number_trees_planted_coffee = number_trees_planted if crop_code == 51 
recode number_trees_planted_banana number_trees_planted_other_fruit number_trees_planted_cassava number_trees_planted_tea number_trees_planted_coffee (.=0)
collapse (sum) number_trees_planted*, by(hhid case_id)
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_trees.dta", replace

use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_all_plots.dta", clear
//Legacy stuff- agquery gets handled above.
collapse (sum) area_harv_=ha_harvest area_plan_=ha_planted harvest_=quant_harv_kg, by(hhid case_id dm_gender purestand crop_code)
drop if purestand == .
gen mixed = "inter" if purestand==0
replace mixed="pure" if purestand==1
gen dm_gender2="male"
replace dm_gender2="female" if dm_gender==2
replace dm_gender2="mixed" if dm_gender==3
drop dm_gender purestand
duplicates tag hhid dm_gender2 crop_code mixed, gen(dups) // temporary measure while we work on plot_decision_makers
drop if dups > 0 // temporary measure while we work on plot_decision_makers
drop dups
reshape wide harvest_ area_harv_ area_plan_, i(hhid case_id dm_gender2 crop_code) j(mixed) string
ren area* area*_
ren harvest* harvest*_
reshape wide harvest* area*, i(hhid case_id crop_code) j(dm_gender2) string
foreach i in harvest area_plan area_harv {
	egen `i' = rowtotal (`i'_*)
	foreach j in inter pure {
		egen `i'_`j' = rowtotal(`i'_`j'_*) 
	}
	foreach k in male female mixed {
		egen `i'_`k' = rowtotal(`i'_*_`k')
	}
	
}
tempfile areas_sans_hh
save `areas_sans_hh'
**# Bookmark #2

use "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hhids.dta", clear
merge 1:m hhid using `areas_sans_hh', keep(1 3) nogen
drop ea stratum weight district ta rural region

save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_crop_area_plan.dta", replace // temporary measure while we work on plot_decision_makers

*Total planted and harvested area summed accross all plots, crops, and seasons.
preserve
	collapse (sum) all_area_harvested=area_harv all_area_planted=area_plan, by(hhid case_id)
	replace all_area_harvested=all_area_planted if all_area_harvested>all_area_planted & all_area_harvested!=.
	save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_area_planted_harvested_allcrops.dta", replace
restore
keep if inlist(crop_code, $comma_topcrop_area)
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_crop_harvest_area_yield.dta", replace

*Yield at the household level
use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_crop_harvest_area_yield.dta", clear
//ren crop_code_long crop_code
*Value of crop production
merge m:1 crop_code using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_cropname_table.dta", nogen keep(1 3)
merge m:1 hhid case_id crop_code using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_crop_values_production.dta", nogen keep(1 3)
ren value_crop_production value_harv_
ren value_crop_sales value_sold_
foreach i in harvest area {
	ren `i'* `i'*_
}
gen total_planted_area_ = area_plan_
gen total_harv_area_ = area_harv_ 
gen kgs_harvest_ = harvest_
drop crop_code
unab vars : *_
reshape wide `vars', i(hhid case_id) j(crop_name) string 
merge m:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_trees.dta"
collapse (sum) harvest* area_harv*  area_plan* total_planted_area* total_harv_area* kgs_harvest*   value_harv* value_sold* number_trees_planted*  , by(hhid case_id) 
recode harvest*   area_harv* area_plan* kgs_harvest* total_planted_area* total_harv_area*    value_harv* value_sold* (0=.)
egen kgs_harvest = rowtotal(kgs_harvest_*)
la var kgs_harvest "Quantity harvested of all crops (kgs) (household) (summed accross all seasons)" 

*ren variables
foreach p of global topcropname_area {
	lab var value_harv_`p' "Value harvested of `p' (Naira) (household)" 
	lab var value_sold_`p' "Value sold of `p' (Naira) (household)" 
	lab var kgs_harvest_`p'  "Quantity harvested of `p' (kgs) (household) (summed accross all seasons)" 
	lab var total_harv_area_`p'  "Total area harvested of `p' (ha) (household) (summed accross all seasons)" 
	lab var total_planted_area_`p'  "Total area planted of `p' (ha) (household) (summed accross all seasons)" 
	lab var harvest_`p' "Quantity harvested of `p' (kgs) (household)" 
	lab var harvest_male_`p' "Quantity harvested of `p' (kgs) (male-managed plots)" 
	lab var harvest_female_`p' "Quantity harvested of `p' (kgs) (female-managed plots)" 
	lab var harvest_mixed_`p' "Quantity harvested of `p' (kgs) (mixed-managed plots)"
	lab var harvest_pure_`p' "Quantity harvested of `p' (kgs) - purestand (household)"
	lab var harvest_pure_male_`p'  "Quantity harvested of `p' (kgs) - purestand (male-managed plots)"
	lab var harvest_pure_female_`p'  "Quantity harvested of `p' (kgs) - purestand (female-managed plots)"
	lab var harvest_pure_mixed_`p'  "Quantity harvested of `p' (kgs) - purestand (mixed-managed plots)"
	lab var harvest_inter_`p' "Quantity harvested of `p' (kgs) - intercrop (household)"
	lab var harvest_inter_male_`p' "Quantity harvested of `p' (kgs) - intercrop (male-managed plots)" 
	lab var harvest_inter_female_`p' "Quantity harvested of `p' (kgs) - intercrop (female-managed plots)"
	lab var harvest_inter_mixed_`p' "Quantity harvested  of `p' (kgs) - intercrop (mixed-managed plots)" //ALT: Redundant?
	lab var area_harv_`p' "Area harvested of `p' (ha) (household)" 
	lab var area_harv_male_`p' "Area harvested of `p' (ha) (male-managed plots)" 
	lab var area_harv_female_`p' "Area harvested of `p' (ha) (female-managed plots)" 
	lab var area_harv_mixed_`p' "Area harvested of `p' (ha) (mixed-managed plots)"
	lab var area_harv_pure_`p' "Area harvested of `p' (ha) - purestand (household)"
	lab var area_harv_pure_male_`p'  "Area harvested of `p' (ha) - purestand (male-managed plots)"
	lab var area_harv_pure_female_`p'  "Area harvested of `p' (ha) - purestand (female-managed plots)"
	lab var area_harv_pure_mixed_`p'  "Area harvested of `p' (ha) - purestand (mixed-managed plots)"
	lab var area_harv_inter_`p' "Area harvested of `p' (ha) - intercrop (household)"
	lab var area_harv_inter_male_`p' "Area harvested of `p' (ha) - intercrop (male-managed plots)" 
	lab var area_harv_inter_female_`p' "Area harvested of `p' (ha) - intercrop (female-managed plots)"
	lab var area_harv_inter_mixed_`p' "Area harvested  of `p' (ha) - intercrop (mixed-managed plots)"
	lab var area_plan_`p' "Area planted of `p' (ha) (household)" 
	lab var area_plan_male_`p' "Area planted of `p' (ha) (male-managed plots)" 
	lab var area_plan_female_`p' "Area planted of `p' (ha) (female-managed plots)" 
	lab var area_plan_mixed_`p' "Area planted of `p' (ha) (mixed-managed plots)"
	lab var area_plan_pure_`p' "Area planted of `p' (ha) - purestand (household)"
	lab var area_plan_pure_male_`p'  "Area planted of `p' (ha) - purestand (male-managed plots)"
	lab var area_plan_pure_female_`p'  "Area planted of `p' (ha) - purestand (female-managed plots)"
	lab var area_plan_pure_mixed_`p'  "Area planted of `p' (ha) - purestand (mixed-managed plots)"
	lab var area_plan_inter_`p' "Area planted of `p' (ha) - intercrop (household)"
	lab var area_plan_inter_male_`p' "Area planted of `p' (ha) - intercrop (male-managed plots)" 
	lab var area_plan_inter_female_`p' "Area planted of `p' (ha) - intercrop (female-managed plots)"
	lab var area_plan_inter_mixed_`p' "Area planted  of `p' (ha) - intercrop (mixed-managed plots)"
}

foreach p of global topcropname_area {
	gen grew_`p'=(total_harv_area_`p'!=. & total_harv_area_`p'!=.0 ) | (total_planted_area_`p'!=. & total_planted_area_`p'!=.0)
	lab var grew_`p' "1=Household grew `p'" 
	gen harvested_`p'= (total_harv_area_`p'!=. & total_harv_area_`p'!=.0 )
	lab var harvested_`p' "1= Household harvested `p'"
}
//replace grew_banana =1 if  number_trees_planted_banana!=0 & number_trees_planted_banana!=. 
replace grew_cassav =1 if number_trees_planted_cassava!=0 & number_trees_planted_cassava!=. 
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_yield_hh_crop_level.dta", replace

***************************************************************************
*SHANNON DIVERSITY INDEX - CG complete 3/1/2024
***************************************************************************
*Area planted
*Bringing in area planted for LRS
use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_crop_area_plan.dta", clear
/*gen area_plan = area_plan_pure_hh + area_plan_inter_hh
foreach i in male female mixed { 
	egen area_plan_`i' = rowtotal(area_plan_*_`i')
}*/

*Some households have crop observations, but the area planted=0. These are permanent crops. Right now they are not included in the SDI unless they are the only crop on the plot, but we could include them by estimating an area based on the number of trees planted
drop if area_plan==0
*generating area planted of each crop as a proportion of the total area
preserve 
collapse (sum) area_plan_hh=area_plan area_plan_female_hh=area_plan_female area_plan_male_hh=area_plan_male area_plan_mixed_hh=area_plan_mixed, by(hhid case_id)
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_crop_area_plan_shannon.dta", replace
restore
merge m:1 hhid using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_crop_area_plan_shannon.dta", nogen		//all matched
recode area_plan_female area_plan_male area_plan_female_hh area_plan_male_hh area_plan_mixed area_plan_mixed_hh (0=.)
gen prop_plan = area_plan/area_plan_hh
gen prop_plan_female=area_plan_female/area_plan_female_hh
gen prop_plan_male=area_plan_male/area_plan_male_hh
gen prop_plan_mixed=area_plan_mixed/area_plan_mixed_hh
gen sdi_crop = prop_plan*ln(prop_plan)
gen sdi_crop_female = prop_plan_female*ln(prop_plan_female)
gen sdi_crop_male = prop_plan_male*ln(prop_plan_male)
gen sdi_crop_mixed = prop_plan_mixed*ln(prop_plan_mixed)
*tagging those that are missing all values
bysort hhid (sdi_crop_female) : gen allmissing_female = mi(sdi_crop_female[1])
bysort hhid (sdi_crop_male) : gen allmissing_male = mi(sdi_crop_male[1])
bysort hhid (sdi_crop_mixed) : gen allmissing_mixed = mi(sdi_crop_mixed[1])
*Generating number of crops per household
bysort hhid crop_code : gen nvals_tot = _n==1
gen nvals_female = nvals_tot if area_plan_female!=0 & area_plan_female!=.
gen nvals_male = nvals_tot if area_plan_male!=0 & area_plan_male!=. 
gen nvals_mixed = nvals_tot if area_plan_mixed!=0 & area_plan_mixed!=.
collapse (sum) sdi=sdi_crop sdi_female=sdi_crop_female sdi_male=sdi_crop_male sdi_mixed=sdi_crop_mixed num_crops_hh=nvals_tot num_crops_female=nvals_female num_crops_male=nvals_male num_crops_mixed=nvals_mixed (max) allmissing_female allmissing_male allmissing_mixed, by(hhid case_id)
la var sdi "Shannon diversity index"
la var sdi_female "Shannon diversity index on female managed plots"
la var sdi_male "Shannon diversity index on male managed plots"
la var sdi_mixed "Shannon diversity index on mixed managed plots"
replace sdi_female=. if allmissing_female==1
replace sdi_male=. if allmissing_male==1
replace sdi_mixed=. if allmissing_mixed==1
gen encs = exp(-sdi)
gen encs_female = exp(-sdi_female)
gen encs_male = exp(-sdi_male)
gen encs_mixed = exp(-sdi_mixed)
la var encs "Effective number of crop species per household"
la var encs_female "Effective number of crop species on female managed plots per household"
la var encs_male "Effective number of crop species on male managed plots per household"
la var encs_mixed "Effective number of crop species on mixed managed plots per household"

la var num_crops_hh "Number of crops grown by the household"
la var num_crops_female "Number of crops grown on female managed plots" 
la var num_crops_male "Number of crops grown on male managed plots"
la var num_crops_mixed "Number of crops grown on mixed managed plots"
gen multiple_crops = (num_crops_hh>1 & num_crops_hh!=.)
la var multiple_crops "Household grows more than one crop"
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_shannon_diversity_index.dta", replace

********************************************************************************
*CONSUMPTION -- RH complete 10/25/21, CG checked/updated/complete 11.28.2023
******************************************************************************** 
use "${MWI_IHS_IHPS_W4_raw_data}/ihs5_consumption_aggregate.dta", clear // RH - renamed dta file for consumption aggregate
ren expagg total_cons // using real consumption-adjusted for region price disparities -- this is nominal (but other option was per capita vs hh-level). 

gen peraeq_cons = (total_cons / adulteq)
gen percapita_cons = (total_cons / hhsize)
gen daily_peraeq_cons = peraeq_cons/365 
gen daily_percap_cons = percapita_cons/365
lab var total_cons "Total HH consumption"
lab var peraeq_cons "Consumption per adult equivalent"
lab var percapita_cons "Consumption per capita"
lab var daily_peraeq_cons "Daily consumption per adult equivalent"
lab var daily_percap_cons "Daily consumption per capita" 
keep case_id hhid total_cons peraeq_cons percapita_cons daily_peraeq_cons daily_percap_cons adulteq
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_consumption.dta", replace

********************************************************************************
*HOUSEHOLD FOOD PROVISION* -- RH complete (7/15/21); CG checked/updated/complete 11.28.2023
********************************************************************************
use "${MWI_IHS_IHPS_W4_raw_data}\HH_MOD_H.dta", clear

foreach i in a b c d e f g h i j k l m n o p q r s t u v w x y{
	gen food_insecurity_`i' = (hh_h05`i'!="")
}

egen months_food_insec = rowtotal(food_insecurity_*) 
* replacing those that report over 12 months
replace months_food_insec = 12 if months_food_insec>12
keep hhid case_id months_food_insec
lab var months_food_insec "Number of months of inadequate food provision"
save "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_food_insecurity.dta", replace						
			
***************************************************************************
*HOUSEHOLD ASSETS* - RH complete 8/24/21; CG checked/updated/complete 11.28.2023
***************************************************************************
use "${MWI_IHS_IHPS_W4_raw_data}\HH_MOD_L.dta", clear
ren hh_l05 value_today
ren hh_l04 age_item
ren hh_l03 number_items_owned
gen value_assets = value_today*number_items_owned
collapse (sum) value_assets, by(hhid case_id)
la var value_assets "Value of household assets"
save "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hh_assets.dta", replace 

	
********************************************************************************
*HOUSEHOLD VARIABLES
********************************************************************************
//setting up empty variable list: create these with a value of missing and then recode all of these to missing at the end of the HH section (some may be recoded to 0 in this section)
global empty_vars ""
use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hhids.dta", clear
merge 1:1 hhid using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_adulteq.dta", nogen keep(1 3)
*Gross crop income 
merge 1:1 hhid using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_crop_production.dta", nogen
* Production by group and type of crop
merge 1:1 hhid using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_crop_losses.dta", nogen
recode value_crop_production crop_value_lost (.=0)

*Production by group and type of crops //CG 3.28.24: file does not exist, wasn't needed in Crop Yields
//merge 1:1 hhid using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_crop_values_production_grouped.dta", nogen 
//merge 1:1 hhid using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_crop_values_production_type_crop.dta", nogen 
//recode value_pro* value_sal* (.=0)
//merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_cost_inputs.dta", nogen
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_yield_hh_crop_level.dta", nogen
ren ea ea_id

*Crop costs //does not exist 
//Merge in summarized crop costs:
//gen crop_production_expenses = cost_expli_hh
//gen crop_income = value_crop_production - crop_production_expenses - crop_value_lost
//lab var crop_production_expenses "Crop production expenditures (explicit)"
//lab var crop_income "Net crop revenue (value of production minus crop expenses)"


*Top crop costs by area planted
foreach c in $topcropname_area {
	//merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_land_rental_costs_`c'.dta", nogen //CG 3.28.24: no land rental costs by top crops available
	capture confirm file "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_inputs_`c'.dta" 
	if _rc==0 { 
	merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_inputs_`c'.dta", nogen //All expenses are in here now.
	merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_`c'_monocrop_hh_area.dta", nogen
	}
}

/* ALT: This stuff all got handled in the expenses file. Crops and expenses are both disaggregated by season to start, so the allocatable expenses are already divided properly.
*top crop costs that are only present in short season
foreach c in $topcropname_short{
	merge 1:1 y5_hhid using "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_wages_shortseason_`c'.dta", nogen
}
*costs that only include annual crops (seed costs and mainseason wages)
foreach c in $topcropname_annual {
	merge 1:1 y5_hhid using "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_seed_costs_`c'.dta", nogen
	merge 1:1 y5_hhid using "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_wages_mainseason_`c'.dta", nogen
}
*/
/*OUT DYA.10.30.2020*/
//ALT 07.23.21: Do we need to hang onto individual expense identities here? We could save some time and effort if we just collapse down the long file by implicit/explicit expense type.
*generate missing vars to run code that collapses all costs
/*ALT: This  shouldn't be hard coded because it's subject to change - adding in a procedural method instead.
global missing_vars wages_paid_short_sunflr wages_paid_short_pigpea wages_paid_short_wheat wages_paid_short_pmill cost_seed_cassav cost_seed_banana wages_paid_main_cassav wages_paid_main_banana
foreach v in $missing_vars{
	gen `v' = . 
	foreach i in male female mixed{
		gen `v'_`i' = .
	}
}
*/

//ALT 07.23.21: easier solution; see monocropped plot sections
*top crop costs by area planted
foreach c in $topcropname_area {
	capture confirm file "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_inputs_`c'.dta"
	if _rc==0 {
	merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_inputs_`c'.dta", nogen
	merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_`c'_monocrop_hh_area.dta", nogen
	}
}

global empty_crops ""

foreach c in $topcropname_area {
	//ALT 07.23.21: Because variable names are similar, we can use wildcards to collapse and avoid mentioning missing variables by name.
capture confirm var `c'_monocrop //Check to make sure this isn't empty.
if !_rc {
	egen `c'_exp = rowtotal(val_*_`c'_hh) //Only explicit costs for right now; add "exp" and "imp" tag to variables to disaggregate in future 
	lab var `c'_exp "Crop production costs(explicit)-Monocrop `c' plots only"
	la var `c'_monocrop_ha "Total `c' monocrop hectares planted - Household"		
	*disaggregate by gender of plot manager
	foreach i in male female mixed{
		egen `c'_exp_`i' = rowtotal(val_*_`c'_`i')
		local l`c'_exp : var lab `c'_exp
		la var `c'_exp_`i' "`l`c'_exp' - `i' managed plots"
	}
	replace `c'_exp = . if `c'_monocrop_ha==.			// set to missing if the household does not have any monocropped plots
	foreach i in male female mixed{
		replace `c'_exp_`i' = . if `c'_monocrop_ha_`i'==.
			}
	}
	else {
		global empty_crops $empty_crops `c'
	}
		
}

*Land rights - no formalized land rights in W4
//merge 1:1 hhid using  "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_land_rights_hh.dta", nogen
//la var formal_land_rights_hh "Household has documentation of land rights (at least one plot)"

*Livestock income //data not available for dung
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_livestock_sales", nogen
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_hh_livestock_products", nogen
//merge 1:1 hhid using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_dung.dta", nogen //CG 3.28.24: does not exist 
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}\MWI_IHS_IHPS_W4_manure.dta", nogen //CG 3.28.24: added this 
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_livestock_expenses", nogen
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_TLU.dta", nogen
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_herd_characteristics", nogen
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_TLU_Coefficients.dta", nogen
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_livestock_expenses_animal.dta", nogen 

recode /*value_slaughtered*/ value_lvstck_sold value_livestock_purchases value_milk_produced value_eggs_produced value_other_produced /*sales_dung*/ sales_manure cost_hired_labor_livestock cost_fodder_livestock cost_vaccines_livestock /*cost_water_livestock*/ (.=0) 
gen livestock_income = /*value_slaughtered +*/ value_lvstck_sold - value_livestock_purchases + (value_milk_produced + value_eggs_produced + value_other_produced + /*sales_dung +*/ sales_manure) - (cost_hired_labor_livestock + cost_fodder_livestock + cost_vaccines_livestock /*+ cost_water_livestock*/)
lab var livestock_income "Net livestock income"
gen livestock_expenses = cost_hired_labor_livestock + cost_fodder_livestock + cost_vaccines_livestock /*+ cost_water_livestock*/ 
ren cost_vaccines_livestock ls_exp_vac  
drop value_livestock_purchases value_other_produced /*sales_dung*/ sales_manure cost_hired_labor_livestock cost_fodder_livestock /*cost_water_livestock*/
lab var sales_livestock_products "Value of sales of livestock products"
lab var value_livestock_products "Value of livestock products"
lab var livestock_expenses "Total livestock expenses"

*Fish income
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_fish_income.dta", nogen
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_fishing_expenses_1.dta", nogen
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_fishing_expenses_2.dta", nogen
gen fishing_income = value_fish_harvest - cost_fuel - rental_costs_fishing - cost_paid
lab var fishing_income "Net fish income"
drop cost_fuel rental_costs_fishing cost_paid

*Self-employment income
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_self_employment_income.dta", nogen
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_fish_trading_income.dta", nogen 
//merge 1:1 hhid using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_agproducts_profits.dta", nogen //CG 3.28.24: file does not exist 

egen self_employment_income = rowtotal(/*annual_selfemp_profit*/ fish_trading_income /*byproduct_profits*/) //CG 3.28.24: annual_selfemp_profit does not exist, W4 only asks for last months profit
lab var self_employment_income "Income from self-employment" 
drop /*annual_selfemp_profit*/ fish_trading_income /*byproduct_profits*/ 

*Wage income
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_wage_income.dta", nogen
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_agwage_income.dta", nogen
recode annual_salary annual_salary_agwage(.=0)
ren annual_salary nonagwage_income
ren annual_salary_agwage agwage_income

*Off-farm hours
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_off_farm_hours.dta", nogen

*Other income
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_other_income.dta", nogen
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_land_rental_income.dta", nogen

egen transfers_income = rowtotal (/*pension_income*/ remittance_income /*assistance_income*/)
lab var transfers_income "Income from transfers including pension, remittances, and assisances)"
egen all_other_income = rowtotal (rental_income other_income  land_rental_income)
lab var all_other_income "Income from all other revenue"
drop /*pension_income*/ remittance_income /*assistance_income*/ rental_income other_income land_rental_income

*Farm size
merge 1:1 hhid case_id using  "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_land_size.dta", nogen
merge 1:1 hhid case_id using  "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_land_size_all.dta", nogen 
merge 1:1 hhid case_id using  "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_farmsize_all_agland.dta", nogen
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_land_size_total.dta", nogen 

recode land_size (.=0)

*Add farm size categories
recode farm_size_agland (.=0)
gen  farm_size_0_0=farm_size_agland==0
gen  farm_size_0_1=farm_size_agland>0 & farm_size_agland<=1
gen  farm_size_1_2=farm_size_agland>1 & farm_size_agland<=2
gen  farm_size_2_4=farm_size_agland>2 & farm_size_agland<=4
gen  farm_size_4_more=farm_size_agland>4
lab var farm_size_0_0 "1=Household has no farm"
lab var farm_size_0_1 "1=Household farm size > 0 Ha and <=1 Ha"
lab var farm_size_1_2 "1=Household farm size > 1 Ha and <=2 Ha"
lab var farm_size_2_4 "1=Household farm size > 2 Ha and <=4 Ha"
lab var farm_size_4_more "1=Household farm size > 4 Ha" 

*Labor
//ALT: Missing if W4 data are not present 
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_family_hired_labor.dta", nogen 
capture confirm file "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_days_famlabor.dta" 
if _rc global empty_vars $empty_vars labor_family

*Household size
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hhsize.dta", nogen

*Rates of vaccine usage, improved seeds, etc.
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_vaccine.dta", nogen
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_input_use.dta", nogen //CG 3.28.24: check this to see if it includes seeds, it does include seeds
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_improvedseed_use.dta", nogen 
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_any_ext.dta", nogen
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_fin_serv.dta", nogen

recode use_fin_serv* ext_reach* /*use_inorg_fert*/ imprv_seed_use vac_animal (.=0)
replace vac_animal=. if tlu_today==0
//replace use_inorg_fert=. if farm_area==0 | farm_area==. //CG 3.28.24: no use_inorg_fert, need to fix inorg fert sections and come back to this
recode ext_reach* (0 1=.) if (value_crop_production==0 & livestock_income==0 & farm_area==0 & tlu_today==0)
recode ext_reach* (0 1=.) if farm_area==.
replace imprv_seed_use=. if farm_area==.
global empty_vars $empty_vars imprv_seed_cassav imprv_seed_banana hybrid_seed_*

*Milk productivity
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_milk_animals.dta", nogen
ren milk_liters_produced liters_milk_produced
//gen liters_milk_produced=liters_per_largeruminant * milk_animals //CG 3.28.24: not necessary, this variable was created in original data file
lab var liters_milk_produced "Total quantity (liters) of milk per year" 
//drop liters_per_largeruminant
//gen liters_per_cow = . 
//gen liters_per_buffalo = . 

*Dairy costs 
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_lrum_expenses", nogen 
//gen avg_cost_lrum = cost_lrum/mean_12months_lrum //do not have data for the mean_12months_lrum
//lab var avg_cost_lrum "Average cost per large ruminant"
//gen costs_dairy = avg_cost_lrum*milk_animals 
//gen costs_dairy_percow = avg_cost_lrum
//gen costs_dairy_percow=. 
//drop avg_cost_lrum cost_lrum
//lab var costs_dairy "Dairy production cost (explicit)"
//lab var costs_dairy_percow "Dairy production cost (explicit) per cow"
//gen share_imp_dairy = . 

*Egg productivity
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_eggs_animals.dta", nogen

gen egg_poultry_year = . 
global empty_vars $empty_vars *liters_per_cow *liters_per_buffalo *costs_dairy_percow* share_imp_dairy *egg_poultry_year

*Costs of crop production per hectare
//merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_cropcosts.dta", nogen //CG 3.28.24: ISSUES MERGING - collapse down to household if organized by season 

*Rate of fertilizer application 
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_fertilizer_application.dta", nogen
*Agricultural wage rate
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_ag_wage.dta", nogen
*Crop yields 
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_yield_hh_crop_level.dta", nogen
*Total area planted and harvested accross all crops, plots, and seasons
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_area_planted_harvested_allcrops.dta", nogen
*Household diet
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_household_diet.dta", nogen
*Consumption
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_consumption.dta", nogen
*Household assets
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hh_assets.dta", nogen

*Food insecurity
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_food_insecurity.dta", nogen

gen hhs_little = . 
gen hhs_moderate = . 
gen hhs_severe = . 
gen hhs_total = . 
global empty_vars $empty_vars hhs_* 

*Distance to agrodealer // cannot construct 
gen dist_agrodealer = . 
global empty_vars $empty_vars *dist_agrodealer
 
*Livestock health
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_livestock_diseases.dta", nogen

*livestock feeding, water, and housing
//merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_livestock_feed_water_house.dta", nogen //CG 3.28.24: does not exist 
 
*Shannon diversity index
merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_shannon_diversity_index.dta", nogen

*Farm Production 
recode value_crop_production  value_livestock_products /*value_slaughtered */value_lvstck_sold (.=0)
gen value_farm_production = value_crop_production + value_livestock_products + /*value_slaughtered */value_lvstck_sold
lab var value_farm_production "Total value of farm production (crops + livestock products)"
gen value_farm_prod_sold = value_crop_sales + sales_livestock_products /*+ value_livestock_sales*/ 
lab var value_farm_prod_sold "Total value of farm production that is sold" 
//replace value_farm_prod_sold = 0 if value_farm_prod_sold==. & value_farm_production!=. //CG 3.28.24: these variables do not exist

*Agricultural households
recode value_crop_production livestock_income farm_area tlu_today (.=0)
gen ag_hh = (value_crop_production!=0 /*| crop_income!=0 */| livestock_income!=0 | farm_area!=0 | tlu_today!=0)
lab var ag_hh "1= Household has some land cultivated, some livestock, some crop income, or some livestock income"

*households engaged in egg production 
gen egg_hh = (value_eggs_produced>0 & value_eggs_produced!=.) 
lab var egg_hh "1=Household engaged in egg production"

*household engaged in dairy production
gen dairy_hh = (value_milk_produced>0 & value_milk_produced!=.)
lab var dairy_hh "1= Household engaged in dairy production" 

*Household engage in ag activities including working in paid ag jobs
gen agactivities_hh =ag_hh==1 | (agwage_income!=0 & agwage_income!=.)
lab var agactivities_hh "1=Household has some land cultivated, livestock, crop income, livestock income, or ag wage income"

*Creating crop household and livestock household
gen crop_hh = (value_crop_production!=0  | farm_area!=0)
lab var crop_hh "1= Household has some land cultivated or some crop income"
gen livestock_hh = (livestock_income!=0 | tlu_today!=0)
lab  var livestock_hh "1= Household has some livestock or some livestock income"
//gen fishing_income=0 //ALT 07.23.21: Do not have this for this wave. CG 3.8.24: this variable exists, lines not needed
//recode fishing_income (.=0)
gen fishing_hh = (fishing_income!=0)
lab  var fishing_hh "1= Household has some fishing income"

****getting correct subpopulations***** 
*Recoding missings to 0 for households growing crops
recode grew* (.=0)
*all rural households growing specific crops 
forvalues k=1(1)$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode value_harv_`cn' value_sold_`cn' kgs_harvest_`cn' total_planted_area_`cn' total_harv_area_`cn' `cn'_exp (.=0) if grew_`cn'==1
	recode value_harv_`cn' value_sold_`cn' kgs_harvest_`cn' total_planted_area_`cn' total_harv_area_`cn' `cn'_exp (nonmissing=.) if grew_`cn'==0
}

*all rural households engaged in livestcok production of a given species //data not available
/*foreach i in lrum srum poultry{
	recode lost_disease_`i' ls_exp_vac_`i' disease_animal_`i' feed_grazing_`i' water_source_nat_`i' water_source_const_`i' water_source_cover_`i' lvstck_housed_`i' (nonmissing=.) if lvstck_holding_`i'==0
	recode lost_disease_`i' ls_exp_vac_`i' disease_animal_`i' feed_grazing_`i' water_source_nat_`i' water_source_const_`i' water_source_cover_`i' lvstck_housed_`i'(.=0) if lvstck_holding_`i'==1	
}*/

*TZA has separate land rental section, I have a small land rental section in Other Income, create Land Rental section? otherwise no cost_exp 
*households engaged in crop production
recode /*cost_expli_hh*/ value_crop_production value_crop_sales labor_hired labor_family farm_size_agland all_area_harvested all_area_planted  encs num_crops_hh multiple_crops (.=0) if crop_hh==1
recode /*cost_expli_hh*/ value_crop_production value_crop_sales labor_hired labor_family farm_size_agland all_area_harvested all_area_planted  encs num_crops_hh multiple_crops (nonmissing=.) if crop_hh==0

*all rural households engaged in livestock production 
recode animals_lost12months* mean_12months* livestock_expenses disease_animal /*feed_grazing water_source_nat water_source_const water_source_cover lvstck_housed */(.=0) if livestock_hh==1
recode animals_lost12months* mean_12months* livestock_expenses disease_animal /*feed_grazing water_source_nat water_source_const water_source_cover lvstck_housed */(nonmissing=.) if livestock_hh==0	

**# Bookmark #4 3.13.24 	
*all rural households 
recode /*DYA.10.26.2020*/ hrs_ag_activ hrs_wage_off_farm hrs_wage_on_farm hrs_unpaid_off_farm hrs_domest_fire_fuel hrs_off_farm hrs_on_farm hrs_domest_all hrs_other_all hrs_self_off_farm /*crop_income */livestock_income self_employment_income nonagwage_income agwage_income fishing_income transfers_income all_other_income value_assets (.=0)

*all rural households engaged in dairy production
recode costs_dairy liters_milk_produced value_milk_produced (.=0) if dairy_hh==1 		
recode costs_dairy liters_milk_produced value_milk_produced (nonmissing=.) if dairy_hh==0		

*all rural households eith egg-producing animals
recode eggs_total_year value_eggs_produced (.=0) if egg_hh==1
recode eggs_total_year value_eggs_produced (nonmissing=.) if egg_hh==0

global gender "female male mixed" //ALT 08.04.21
*Variables winsorized at the top 1% only 
global wins_var_top1 /*
*/ value_crop_production value_crop_sales value_harv* value_sold* kgs_harv* /*kgs_harv_mono*/ total_planted_area* total_harv_area* /*
*/ labor_hired labor_family /*
*/ animals_lost12months mean_12months lost_disease* /*			
*/ liters_milk_produced costs_dairy /*	
*/ eggs_total_year value_eggs_produced value_milk_produced /*
*/ hrs_ag_activ hrs_wage_off_farm hrs_wage_on_farm hrs_unpaid_off_farm hrs_domest_fire_fuel hrs_off_farm hrs_on_farm hrs_domest_all hrs_other_all hrs_self_off_farm  crop_production_expenses value_assets cost_expli_hh /*
*/ livestock_expenses ls_exp_vac* sales_livestock_products value_livestock_products value_livestock_sales /*
*/ value_farm_production value_farm_prod_sold  value_pro* value_sal*

gen wage_paid_aglabor_mixed=. //create this just to make the loop work and delete after
foreach v of varlist $wins_var_top1 {
	_pctile `v' [aw=weight] , p($wins_upper_thres)  
	gen w_`v'=`v'
	replace  w_`v' = r(r1) if  w_`v' > r(r1) &  w_`v'!=.
	local l`v' : var lab `v'
	lab var  w_`v'  "`l`v'' - Winzorized top 1%"
}

*Variables winsorized at the top 1% only - for variables disaggregated by the gender of the plot manager
global wins_var_top1_gender=""
foreach v in $topcropname_area {
	global wins_var_top1_gender $wins_var_top1_gender `v'_exp
}
gen cost_total = cost_total_hh
gen cost_expli = cost_expli_hh //ALT 08.04.21: Kludge til I get names fully consistent
global wins_var_top1_gender $wins_var_top1_gender cost_total cost_expli fert_inorg_kg wage_paid_aglabor

foreach v of varlist $wins_var_top1_gender {
	_pctile `v' [aw=weight] , p($wins_upper_thres)  
	gen w_`v'=`v'
	replace  w_`v' = r(r1) if  w_`v' > r(r1) &  w_`v'!=.
	local l`v' : var lab `v'
	lab var  w_`v'  "`l`v'' - Winzorized top 1%"
	
	*some variables are disaggreated by gender of plot manager. For these variables, we use the top 1% percentile to winsorize gender-disagregated variables
	foreach g of global gender {
		gen w_`v'_`g'=`v'_`g'
		replace  w_`v'_`g' = r(r1) if w_`v'_`g' > r(r1) & w_`v'_`g'!=.
		local l`v'_`g' : var lab `v'_`g'
		lab var  w_`v'_`g'  "`l`v'_`g'' - Winzorized top 1%"
	}
}

drop *wage_paid_aglabor_mixed
egen w_labor_total=rowtotal(w_labor_hired w_labor_family)
local llabor_total : var lab labor_total 
lab var w_labor_total "`labor_total' - Winzorized top 1%"

*Variables winsorized both at the top 1% and bottom 1% 
global wins_var_top1_bott1  /* 
*/ farm_area farm_size_agland all_area_harvested all_area_planted ha_planted /*
*/ crop_income livestock_income fishing_income self_employment_income nonagwage_income agwage_income transfers_income all_other_income total_cons percapita_cons daily_percap_cons peraeq_cons daily_peraeq_cons /* 
*/ *_monocrop_ha* dist_agrodealer land_size_total

foreach v of varlist $wins_var_top1_bott1 {
	_pctile `v' [aw=weight] , p($wins_lower_thres $wins_upper_thres) 
	gen w_`v'=`v'
	replace w_`v'= r(r1) if w_`v' < r(r1) & w_`v'!=. & w_`v'!=0  /* we want to keep actual zeros */
	replace w_`v'= r(r2) if  w_`v' > r(r2)  & w_`v'!=.		
	local l`v' : var lab `v'
	lab var  w_`v'  "`l`v'' - Winzorized top and bottom 1%"
	*some variables  are disaggreated by gender of plot manager. For these variables, we use the top and bottom 1% percentile to winsorize gender-disagregated variables
	if "`v'"=="ha_planted" {
		foreach g of global gender {
			gen w_`v'_`g'=`v'_`g'
			replace w_`v'_`g'= r(r1) if w_`v'_`g' < r(r1) & w_`v'_`g'!=. & w_`v'_`g'!=0  /* we want to keep actual zeros */
			replace w_`v'_`g'= r(r2) if  w_`v'_`g' > r(r2)  & w_`v'_`g'!=.		
			local l`v'_`g' : var lab `v'_`g'
			lab var  w_`v'_`g'  "`l`v'_`g'' - Winzorized top and bottom 1%"		
		}		
	}
}

*Winsorizing variables that go into yield at the top and bottom 5% //IHS 10.2.19
global allyield male female mixed inter inter_male inter_female inter_mixed pure  pure_male pure_female pure_mixed
global wins_var_top1_bott1_2 area_harv  area_plan harvest //ALT 08.04.21: Breaking here. To do: figure out where area_harv comes from.
foreach v of global wins_var_top1_bott1_2 {
	foreach c of global topcropname_area {
		_pctile `v'_`c'  [aw=weight] , p(1 99)
		gen w_`v'_`c'=`v'_`c'
		replace w_`v'_`c' = r(r1) if w_`v'_`c' < r(r1)   &  w_`v'_`c'!=0 
		replace w_`v'_`c' = r(r2) if (w_`v'_`c' > r(r2) & w_`v'_`c' !=.)  		
		local l`v'_`c'  : var lab `v'_`c'
		lab var  w_`v'_`c' "`l`v'_`c'' - Winzorized top and bottom 5%"	
		* now use pctile from area for all to trim gender/inter/pure area
		foreach g of global allyield {
			gen w_`v'_`g'_`c'=`v'_`g'_`c'
			replace w_`v'_`g'_`c' = r(r1) if w_`v'_`g'_`c' < r(r1) &  w_`v'_`g'_`c'!=0 
			replace w_`v'_`g'_`c' = r(r2) if (w_`v'_`g'_`c' > r(r2) & w_`v'_`g'_`c' !=.)  	
			local l`v'_`g'_`c'  : var lab `v'_`g'_`c'
			lab var  w_`v'_`g'_`c' "`l`v'_`g'_`c'' - Winzorized top and bottom 5%"
			
		}
	}
}

*Estimate variables that are ratios then winsorize top 1% and bottom 1% of the ratios (do not replace 0 by the percentitles)
*generate yield and weights for yields  using winsorized values 
*Yield by Area Planted
foreach c of global topcropname_area {
	gen yield_pl_`c'=w_harvest_`c'/w_area_plan_`c'
	lab var  yield_pl_`c' "Yield by area planted of `c' (kgs/ha) (household)" 
	gen ar_pl_wgt_`c' =  weight*w_area_plan_`c'		
	lab var ar_pl_wgt_`c' "Planted area-adjusted weight for `c' (household)"
	foreach g of global allyield  {
		gen yield_pl_`g'_`c'=w_harvest_`g'_`c'/w_area_plan_`g'_`c'
		lab var  yield_pl_`g'_`c'  "Yield  by area planted of `c' -  (kgs/ha) (`g')" 
		gen ar_pl_wgt_`g'_`c' =  weight*w_area_plan_`g'_`c'
		lab var ar_pl_wgt_`g'_`c' "Harvested area-adjusted weight for `c' (`g')"
	}
}
 
 *Yield by Area Harvested
foreach c of global topcropname_area {
	gen yield_hv_`c'=w_harvest_`c'/w_area_harv_`c'
	lab var  yield_hv_`c' "Yield by area harvested of `c' (kgs/ha) (household)" 
	gen ar_h_wgt_`c' =  weight*w_area_harv_`c'
	lab var ar_h_wgt_`c' "Harvested area-adjusted weight for `c' (household)"
	foreach g of global allyield  {
		gen yield_hv_`g'_`c'=w_harvest_`g'_`c'/w_area_harv_`g'_`c'
		lab var  yield_hv_`g'_`c'  "Yield by area harvested of `c' -  (kgs/ha) (`g')" 
		gen ar_h_wgt_`g'_`c' =  weight*w_area_harv_`g'_`c'
		lab var ar_h_wgt_`g'_`c' "Harvested area-adjusted weight for `c' (`g')"
	}
}

*generate inorg_fert_rate, costs_total_ha, and costs_explicit_ha using winsorized values
gen inorg_fert_rate=w_fert_inorg_kg/w_ha_planted
gen cost_total_ha = w_cost_total / w_ha_planted
gen cost_expli_ha = w_cost_expli / w_ha_planted 

foreach g of global gender {
	gen inorg_fert_rate_`g'=w_fert_inorg_kg_`g'/ w_ha_planted_`g'
	gen cost_total_ha_`g'=w_cost_total_`g'/ w_ha_planted_`g' 
	gen cost_expli_ha_`g'=w_cost_expli_`g'/ w_ha_planted_`g' 		
}
lab var inorg_fert_rate "Rate of fertilizer application (kgs/ha) (household level)"
lab var inorg_fert_rate_male "Rate of fertilizer application (kgs/ha) (male-managed crops)"
lab var inorg_fert_rate_female "Rate of fertilizer application (kgs/ha) (female-managed crops)"
lab var inorg_fert_rate_mixed "Rate of fertilizer application (kgs/ha) (mixed-managed crops)"
lab var cost_total_ha "Explicit + implicit costs (per ha) of crop production costs that can be disaggregated at the plot manager level"
lab var cost_total_ha_male "Explicit + implicit costs (per ha) of crop production (male-managed plots)"
lab var cost_total_ha_female "Explicit + implicit costs (per ha) of crop production (female-managed plots)"
lab var cost_total_ha_mixed "Explicit + implicit costs (per ha) of crop production (mixed-managed plots)"
lab var cost_expli_ha "Explicit costs (per ha) of crop production costs that can be disaggregated at the plot manager level"
lab var cost_expli_ha_male "Explicit costs (per ha) of crop production (male-managed plots)"
lab var cost_expli_ha_female "Explicit costs (per ha) of crop production (female-managed plots)"
lab var cost_expli_ha_mixed "Explicit costs (per ha) of crop production (mixed-managed plots)"

*mortality rate
global animal_species lrum srum pigs equine  poultry 
foreach s of global animal_species {
	gen mortality_rate_`s' = animals_lost_agseas_`s'/mean_agseas_`s'
	lab var mortality_rate_`s' "Mortality rate - `s'"
}

*generating top crop expenses using winsoried values (monocropped)
foreach c in $topcropname_area{		
	gen `c'_exp_ha =w_`c'_exp /w_`c'_monocrop_ha
	la var `c'_exp_ha "Costs per hectare - Monocropped `c' plots"
	foreach  g of global gender{
		gen `c'_exp_ha_`g' =w_`c'_exp_`g'/w_`c'_monocrop_ha
		la var `c'_exp_ha_`g' "Costs per hectare - Monocropped `c' `g' managed plots"		
	}
}

/*DYA.10.26.2020*/ 
*Hours per capita using winsorized version off_farm_hours 
foreach x in ag_activ wage_off_farm wage_on_farm unpaid_off_farm domest_fire_fuel off_farm on_farm domest_all other_all {
	local l`v':var label hrs_`x'
	gen hrs_`x'_pc_all = hrs_`x'/member_count
	lab var hrs_`x'_pc_all "Per capital (all) `l`v''"
	gen hrs_`x'_pc_any = hrs_`x'/nworker_`x'
    lab var hrs_`x'_pc_any "Per capital (only worker) `l`v''"
}
 
*generating total crop production costs per hectare
gen cost_expli_hh_ha = w_cost_expli_hh / w_ha_planted
lab var cost_expli_hh_ha "Explicit costs (per ha) of crop production (household level)"

*land and labor productivity
gen land_productivity = w_value_crop_production/w_farm_area
gen labor_productivity = w_value_crop_production/w_labor_total 
lab var land_productivity "Land productivity (value production per ha cultivated)"
lab var labor_productivity "Labor productivity (value production per labor-day)"   

*milk productivity
gen liters_per_largeruminant= .
la var liters_per_largeruminant "Average quantity (liters) per year (household)"
global empty_vars $empty_vars liters_per_largeruminant		

*crop value sold
gen w_proportion_cropvalue_sold = w_value_crop_sales /  w_value_crop_production
replace w_proportion_cropvalue_sold = 1 if w_proportion_cropvalue_sold > 1 & w_proportion_cropvalue_sold != .
lab var w_proportion_cropvalue_sold "Proportion of crop value produced (winsorized) that has been sold"

*livestock value sold 
gen w_share_livestock_prod_sold = w_sales_livestock_products / w_value_livestock_products
replace w_share_livestock_prod_sold = 1 if w_share_livestock_prod_sold>1 & w_share_livestock_prod_sold!=.
lab var w_share_livestock_prod_sold "Percent of production of livestock products (winsorized) that is sold"

*Propotion of farm production sold
gen w_prop_farm_prod_sold = w_value_farm_prod_sold / w_value_farm_production
replace w_prop_farm_prod_sold = 1 if w_prop_farm_prod_sold>1 & w_prop_farm_prod_sold!=.
lab var w_prop_farm_prod_sold "Proportion of farm production (winsorized) that has been sold"

*unit cost of production
*all top crops
foreach c in $topcropname_area{
	gen `c'_exp_kg = w_`c'_exp /w_kgs_harv_mono_`c' 
	la var `c'_exp_kg "Costs per kg - Monocropped `c' plots"
	foreach g of global gender {
		gen `c'_exp_kg_`g'=w_`c'_exp_`g'/ w_kgs_harv_mono_`c'_`g' 
		la var `c'_exp_kg_`g' "Costs per kg - Monocropped `c' `g' managed plots"		 
	}
}

*dairy
gen cost_per_lit_milk = costs_dairy/w_liters_milk_produced
la var cost_per_lit_milk "Dairy production cost per liter"
global empty_vars $empty_vars cost_per_lit_milk

*****getting correct subpopulations***
*all rural housseholds engaged in crop production 
recode inorg_fert_rate cost_total_ha cost_expli_ha cost_expli_hh_ha land_productivity labor_productivity (.=0) if crop_hh==1
recode inorg_fert_rate cost_total_ha cost_expli_ha cost_expli_hh_ha land_productivity labor_productivity (nonmissing=.) if crop_hh==0
*all rural households engaged in livestcok production of a given species
foreach i in lrum srum poultry{
	recode mortality_rate_`i' (nonmissing=.) if lvstck_holding_`i'==0
	recode mortality_rate_`i' (.=0) if lvstck_holding_`i'==1	
}
*all rural households 
recode /*DYA.10.26.2020*/ hrs_*_pc_all (.=0)  
*households engaged in monocropped production of specific crops
forvalues k=1/$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode `cn'_exp `cn'_exp_ha `cn'_exp_kg (.=0) if `cn'_monocrop==1
	recode `cn'_exp `cn'_exp_ha `cn'_exp_kg (nonmissing=.) if `cn'_monocrop==0
}
*all rural households growing specific crops 
forvalues k=1(1)$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode yield_pl_`cn' (.=0) if grew_`cn'==1 
	recode yield_pl_`cn' (nonmissing=.) if grew_`cn'==0 
}
*all rural households harvesting specific crops 
forvalues k=1(1)$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode yield_hv_`cn' (.=0) if harvested_`cn'==1 
	recode yield_hv_`cn' (nonmissing=.) if harvested_`cn'==0 
}

*households growing specific crops that have also purestand plots of that crop 
forvalues k=1(1)$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode yield_pl_pure_`cn' (.=0) if grew_`cn'==1 & w_area_plan_pure_`cn'!=. 
	recode yield_pl_pure_`cn' (nonmissing=.) if grew_`cn'==0 | w_area_plan_pure_`cn'==.  
}
*all rural households harvesting specific crops (in the long rainy season) that also have purestand plots 
forvalues k=1(1)$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode yield_hv_pure_`cn' (.=0) if harvested_`cn'==1 & w_area_plan_pure_`cn'!=. 
	recode yield_hv_pure_`cn' (nonmissing=.) if harvested_`cn'==0 | w_area_plan_pure_`cn'==.  
}

*households engaged in dairy production  
recode costs_dairy_percow cost_per_lit_milk (.=0) if dairy_hh==1				
recode costs_dairy_percow cost_per_lit_milk (nonmissing=.) if dairy_hh==0		

*now winsorize ratios only at top 1% 
global wins_var_ratios_top1 inorg_fert_rate cost_total_ha cost_expli_ha cost_expli_hh_ha /*		
*/ land_productivity labor_productivity /*
*/ mortality_rate* liters_per_largeruminant liters_per_cow liters_per_buffalo egg_poultry_year costs_dairy_percow /*
*/ /*DYA.10.26.2020*/  hrs_*_pc_all hrs_*_pc_any cost_per_lit_milk 

foreach v of varlist $wins_var_ratios_top1 {
	_pctile `v' [aw=weight] , p($wins_upper_thres)  
	gen w_`v'=`v'
	replace  w_`v' = r(r1) if  w_`v' > r(r1) &  w_`v'!=.
	local l`v' : var lab `v'
	lab var  w_`v'  "`l`v'' - Winzorized top 1%"
	*some variables  are disaggreated by gender of plot manager. For these variables, we use the top 1% percentile to winsorize gender-disagregated variables
	if "`v'" =="inorg_fert_rate" | "`v'" =="cost_total_ha"  | "`v'" =="cost_expli_ha" {
		foreach g of global gender {
			gen w_`v'_`g'=`v'_`g'
			replace  w_`v'_`g' = r(r1) if w_`v'_`g' > r(r1) & w_`v'_`g'!=.
			local l`v'_`g' : var lab `v'_`g'
			lab var  w_`v'_`g'  "`l`v'_`g'' - Winzorized top 1%"
		}	
	}
}

*winsorizing top crop ratios
foreach v of global topcropname_area {
	*first winsorizing costs per hectare
	_pctile `v'_exp_ha [aw=weight] , p($wins_upper_thres)  
	gen w_`v'_exp_ha=`v'_exp_ha
	replace  w_`v'_exp_ha = r(r1) if  w_`v'_exp_ha > r(r1) &  w_`v'_exp_ha!=.
	local l`v'_exp_ha : var lab `v'_exp_ha
	lab var  w_`v'_exp_ha  "`l`v'_exp_ha - Winzorized top 1%"
		*now by gender using the same method as above
		foreach g of global gender {
		gen w_`v'_exp_ha_`g'= `v'_exp_ha_`g'
		replace w_`v'_exp_ha_`g' = r(r1) if w_`v'_exp_ha_`g' > r(r1) & w_`v'_exp_ha_`g'!=.
		local l`v'_exp_ha_`g' : var lab `v'_exp_ha_`g'
		lab var w_`v'_exp_ha_`g' "`l`v'_exp_ha_`g'' - winsorized top 1%"
	}
	*winsorizing cost per kilogram
	_pctile `v'_exp_kg [aw=weight] , p($wins_upper_thres)  
	gen w_`v'_exp_kg=`v'_exp_kg
	replace  w_`v'_exp_kg = r(r1) if  w_`v'_exp_kg > r(r1) &  w_`v'_exp_kg!=.
	local l`v'_exp_kg : var lab `v'_exp_kg
	lab var  w_`v'_exp_kg  "`l`v'_exp_kg' - Winzorized top 1%"
		*now by gender using the same method as above
		foreach g of global gender {
		gen w_`v'_exp_kg_`g'= `v'_exp_kg_`g'
		replace w_`v'_exp_kg_`g' = r(r1) if w_`v'_exp_kg_`g' > r(r1) & w_`v'_exp_kg_`g'!=.
		local l`v'_exp_kg_`g' : var lab `v'_exp_kg_`g'
		lab var w_`v'_exp_kg_`g' "`l`v'_exp_kg_`g'' - winsorized top 1%"
	}
}

*now winsorize ratio only at top 1% - yield 
foreach c of global topcropname_area {
	foreach i in yield_pl yield_hv{
		_pctile `i'_`c' [aw=weight] ,  p(95)  //IHS WINSORIZING YIELD FOR NIGERIA AT 5 PERCENT. 
		gen w_`i'_`c'=`i'_`c'
		replace  w_`i'_`c' = r(r1) if  w_`i'_`c' > r(r1) &  w_`i'_`c'!=.
		local w_`i'_`c' : var lab `i'_`c'
		lab var  w_`i'_`c'  "`w_`i'_`c'' - Winzorized top 5%"
		foreach g of global allyield  {
			gen w_`i'_`g'_`c'= `i'_`g'_`c'
			replace  w_`i'_`g'_`c' = r(r1) if  w_`i'_`g'_`c' > r(r1) &  w_`i'_`g'_`c'!=.
			local w_`i'_`g'_`c' : var lab `i'_`g'_`c'
			lab var  w_`i'_`g'_`c'  "`w_`i'_`g'_`c'' - Winzorized top 5%"
		}
	}
}
 
 ***DYA 12.06.19 Because of the use of odd area units in Nigeria, we have many tiny plots. We are reporting yield when area_plan>0.1ha
foreach c of global topcropname_area {
	replace w_yield_pl_`c'=. if w_area_plan_`c'<0.05
	replace w_yield_hv_`c'=. if w_area_plan_`c'<0.05
	foreach g of global allyield  {
		replace w_yield_pl_`g'_`c'=. if w_area_plan_`c'<0.05
		replace w_yield_hv_`g'_`c'=. if w_area_plan_`c'<0.05	
	}
}

*Create final income variables using un_winzorized and un_winzorized values
egen total_income = rowtotal(crop_income livestock_income fishing_income self_employment_income nonagwage_income agwage_income transfers_income all_other_income)
egen nonfarm_income = rowtotal(fishing_income self_employment_income nonagwage_income transfers_income all_other_income)
egen farm_income = rowtotal(crop_income livestock_income agwage_income)
lab var  nonfarm_income "Nonfarm income (excludes ag wages)"
gen percapita_income = total_income/hh_members
lab var total_income "Total household income"
lab var percapita_income "Household incom per hh member per year"
lab var farm_income "Farm income"
egen w_total_income = rowtotal(w_crop_income w_livestock_income w_fishing_income w_self_employment_income w_nonagwage_income w_agwage_income w_transfers_income w_all_other_income)
egen w_nonfarm_income = rowtotal(w_fishing_income w_self_employment_income w_nonagwage_income w_transfers_income w_all_other_income)
egen w_farm_income = rowtotal(w_crop_income w_livestock_income w_agwage_income)
lab var  w_nonfarm_income "Nonfarm income (excludes ag wages) - Winzorized top 1%"
lab var w_farm_income "Farm income - Winzorized top 1%"
gen w_percapita_income = w_total_income/hh_members
lab var w_total_income "Total household income - Winzorized top 1%"
lab var w_percapita_income "Household income per hh member per year - Winzorized top 1%"
global income_vars crop livestock fishing self_employment nonagwage agwage transfers all_other
foreach p of global income_vars {
	gen `p'_income_s = `p'_income
	replace `p'_income_s = 0 if `p'_income_s < 0
	gen w_`p'_income_s = w_`p'_income
	replace w_`p'_income_s = 0 if w_`p'_income_s < 0 
}
egen w_total_income_s = rowtotal(w_crop_income_s w_livestock_income_s w_fishing_income_s w_self_employment_income_s w_nonagwage_income_s w_agwage_income_s  w_transfers_income_s w_all_other_income_s)
foreach p of global income_vars {
	gen w_share_`p' = w_`p'_income_s / w_total_income_s
	lab var w_share_`p' "Share of household (winsorized) income from `p'_income"
}
egen w_nonfarm_income_s = rowtotal(w_fishing_income_s w_self_employment_income_s w_nonagwage_income_s w_transfers_income_s w_all_other_income_s)
gen w_share_nonfarm = w_nonfarm_income_s / w_total_income_s
lab var w_share_nonfarm "Share of household income (winsorized) from nonfarm sources"
foreach p of global income_vars {
	drop `p'_income_s  w_`p'_income_s 
}
drop w_total_income_s w_nonfarm_income_s

***getting correct subpopulations
*all rural households 
//note that consumption indicators are not included because there is missing consumption data and we do not consider 0 values for consumption to be valid
//ALT 08.16.21: Kludge for imprv seed use - for consistency, it should really be use_imprv_seed 
recode w_total_income w_percapita_income w_crop_income w_livestock_income w_fishing_income w_nonagwage_income w_agwage_income w_self_employment_income w_transfers_income w_all_other_income /*
*/ w_share_crop w_share_livestock w_share_fishing w_share_nonagwage w_share_agwage w_share_self_employment w_share_transfers w_share_all_other w_share_nonfarm /*
*/ use_fin_serv* use_inorg_fert imprv_seed_use /*
*/ formal_land_rights_hh *_hrs_*_pc_all  months_food_insec w_value_assets /*
*/ lvstck_holding_tlu lvstck_holding_all lvstck_holding_lrum lvstck_holding_srum lvstck_holding_poultry (.=0) if rural==1 
 
 
*all rural households engaged in livestock production
recode vac_animal w_share_livestock_prod_sold livestock_expenses w_ls_exp_vac (. = 0) if livestock_hh==1 
recode vac_animal w_share_livestock_prod_sold livestock_expenses w_ls_exp_vac (nonmissing = .) if livestock_hh==0 

*all rural households engaged in livestcok production of a given species
foreach i in lrum srum poultry{
	recode vac_animal_`i' any_imp_herd_`i' w_lost_disease_`i' w_ls_exp_vac_`i' (nonmissing=.) if lvstck_holding_`i'==0
	recode vac_animal_`i' any_imp_herd_`i' w_lost_disease_`i' w_ls_exp_vac_`i' (.=0) if lvstck_holding_`i'==1	
}

*households engaged in crop production
recode w_proportion_cropvalue_sold w_farm_size_agland w_labor_family w_labor_hired /*
*/ imprv_seed_use use_inorg_fert w_labor_productivity w_land_productivity /*
*/ w_inorg_fert_rate w_cost_expli_hh w_cost_expli_hh_ha w_cost_expli_ha w_cost_total_ha /*
*/ w_value_crop_production w_value_crop_sales w_all_area_planted w_all_area_harvested (.=0) if crop_hh==1
recode w_proportion_cropvalue_sold w_farm_size_agland w_labor_family w_labor_hired /*
*/ imprv_seed_use use_inorg_fert w_labor_productivity w_land_productivity /*
*/ w_inorg_fert_rate w_cost_expli_hh w_cost_expli_hh_ha w_cost_expli_ha w_cost_total_ha /*
*/ w_value_crop_production w_value_crop_sales w_all_area_planted w_all_area_harvested (nonmissing= . ) if crop_hh==0
		
*hh engaged in crop or livestock production
recode ext_reach* (.=0) if (crop_hh==1 | livestock_hh==1)
recode ext_reach* (nonmissing=.) if crop_hh==0 & livestock_hh==0

*all rural households growing specific crops 
forvalues k=1(1)$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode imprv_seed_`cn' hybrid_seed_`cn' w_yield_pl_`cn' /*
	*/ w_value_harv_`cn' w_value_sold_`cn' w_kgs_harvest_`cn' w_total_planted_area_`cn' w_total_harv_area_`cn' (.=0) if grew_`cn'==1
	recode imprv_seed_`cn' hybrid_seed_`cn' w_yield_pl_`cn' /*
	*/ w_value_harv_`cn' w_value_sold_`cn' w_kgs_harvest_`cn' w_total_planted_area_`cn' w_total_harv_area_`cn' (nonmissing=.) if grew_`cn'==0
}
*all rural households that harvested specific crops
forvalues k=1(1)$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode w_yield_hv_`cn' (.=0) if harvested_`cn'==1
	recode w_yield_hv_`cn' (nonmissing=.) if harvested_`cn'==0
}

*households engaged in monocropped production of specific crops
forvalues k=1/$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode w_`cn'_exp w_`cn'_exp_ha w_`cn'_exp_kg (.=0) if `cn'_monocrop==1
	recode w_`cn'_exp w_`cn'_exp_ha w_`cn'_exp_kg (nonmissing=.) if `cn'_monocrop==0
}

*all rural households engaged in dairy production
recode costs_dairy liters_milk_produced value_milk_produced (.=0) if dairy_hh==1 					
recode costs_dairy liters_milk_produced value_milk_produced (nonmissing=.) if dairy_hh==0			
*all rural households eith egg-producing animals
recode w_eggs_total_year value_eggs_produced (.=0) if egg_hh==1
recode w_eggs_total_year value_eggs_produced (nonmissing=.) if egg_hh==0
  
*Identify smallholder farmers (RULIS definition)
global small_farmer_vars land_size tlu_today total_income 
foreach p of global small_farmer_vars {
	gen `p'_aghh = `p' if ag_hh==1
	_pctile `p'_aghh  [aw=weight] , p(40) 
	gen small_`p' = (`p' <= r(r1))
	replace small_`p' = . if ag_hh!=1
}
gen small_farm_household = (small_land_size==1 & small_tlu_today==1 & small_total_income==1)
replace small_farm_household = . if ag_hh != 1
sum small_farm_household if ag_hh==1 
drop land_size_aghh small_land_size tlu_today_aghh small_tlu_today total_income_aghh small_total_income   
lab var small_farm_household "1= HH is in bottom 40th percentiles of land size, TLU, and total revenue"

*create different weights 
gen w_labor_weight=weight*w_labor_total
lab var w_labor_weight "labor-adjusted household weights"
gen w_land_weight=weight*w_farm_area
lab var w_land_weight "land-adjusted household weights"
gen w_aglabor_weight_all=w_labor_hired*weight
lab var w_aglabor_weight_all "Hired labor-adjusted household weights"
gen w_aglabor_weight_female=. // cannot create in this instrument  
lab var w_aglabor_weight_female "Hired labor-adjusted household weights -female workers"
gen w_aglabor_weight_male=. // cannot create in this instrument 
lab var w_aglabor_weight_male "Hired labor-adjusted household weights -male workers"
gen weight_milk=. //cannot create in this instrument
gen weight_egg=. //cannot create in this instrument
*generate area weights for monocropped plots
foreach cn in $topcropname_area {
	gen ar_pl_mono_wgt_`cn'_all = weight*`cn'_monocrop_ha
	gen kgs_harv_wgt_`cn'_all = weight*kgs_harv_mono_`cn'
	foreach g in male female mixed {
		gen ar_pl_mono_wgt_`cn'_`g' = weight*`cn'_monocrop_ha_`g'
		gen kgs_harv_wgt_`cn'_`g' = weight*kgs_harv_mono_`cn'_`g'
	}
}
gen w_ha_planted_all = ha_planted 
foreach  g in all female male mixed {
	gen area_weight_`g'=weight*w_ha_planted_`g'
}
gen w_ha_planted_weight=w_ha_planted_all*weight
drop w_ha_planted_all
gen individual_weight=hh_members*weight
gen adulteq_weight=adulteq*weight

*Rural poverty headcount ratio
*First, we convert $1.90/day to local currency in 2011 using https://data.worldbank.org/indicator/PA.NUS.PRVT.PP?end=2011&locations=TZ&start=1990
	// 1.90 * 79.531 = 151.1089  
*NOTE: this is using the "Private Consumption, PPP" conversion factor because that's what we have been using. 
* This can be changed this to the "GDP, PPP" if we change the rest of the conversion factors.
*The global poverty line of $1.90/day is set by the World Bank
*http://www.worldbank.org/en/topic/poverty/brief/global-poverty-line-faq
*Second, we inflate the local currency to the year that this survey was carried out using the CPI inflation rate using https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2017&locations=TZ&start=2003
	// 1+(134.925 - 110.84)/110.84 = 1.6587243	
	// 151.1089* 1.6587243 = 250.648 N
*NOTE: if the survey was carried out over multiple years we use the last year
*This is the poverty line at the local currency in the year the survey was carried out
gen poverty_under_1_9 = (daily_percap_cons<250.648)		 
la var poverty_under_1_9 "Household has a percapita conumption of under $1.90 in 2011 $ PPP)"
*average consumption expenditure of the bottom 40% of the rural consumption expenditure distribution
*First, generating variable that reports the individuals in the bottom 40% of rural consumption expenditures
*By per capita consumption
_pctile w_daily_percap_cons [aw=individual_weight] if rural==1, p(40)
gen bottom_40_percap = 0
replace bottom_40_percap = 1 if r(r1) > w_daily_percap_cons & rural==1

*By peraeq consumption
_pctile w_daily_peraeq_cons [aw=adulteq_weight] if rural==1, p(40)
gen bottom_40_peraeq = 0
replace bottom_40_peraeq = 1 if r(r1) > w_daily_peraeq_cons & rural==1

****Currency Conversion Factors***
gen ccf_loc = 1 
lab var ccf_loc "currency conversion factor - 2016 $MWK"
gen ccf_usd = 1/$MWI_IHS_IHPS_W4_exchange_rate 
lab var ccf_usd "currency conversion factor - 2016 $USD"
gen ccf_1ppp = 1/ $MWI_IHS_IHPS_W4_cons_ppp_dollar
lab var ccf_1ppp "currency conversion factor - 2016 $Private Consumption PPP"
gen ccf_2ppp = 1/ $MWI_IHS_IHPS_W4_gdp_ppp_dollar
lab var ccf_2ppp "currency conversion factor - 2017 $GDP PPP"

*generating clusterid and strataid
gen clusterid=ea
gen strataid=state

*dropping unnecessary varables
drop *_inter_*

*create missing crop variables (no cowpea or yam)
foreach x of varlist *maize* {
	foreach c in wheat beans {
		gen `x'_xx = .
		ren *maize*_xx *`c'*
	}
}

global empty_vars $empty_vars *wheat* *beans* 

*Recode to missing any variables that cannot be created in this instrument
*replace empty vars with missing
foreach v of varlist $empty_vars { 
	replace `v' = .
}

// Removing intermediate variables to get below 5,000 vars
keep hhid case_id fhh clusterid strataid *weight* *wgt* zone state lga ea rural farm_size* *total_income* /*
*/ *percapita_income* *percapita_cons* *daily_percap_cons* *peraeq_cons* *daily_peraeq_cons* /*
*/ *income* *share* *proportion_cropvalue_sold *farm_size_agland hh_members adulteq *labor_family *labor_hired use_inorg_fert vac_* /*
*/ feed* water* lvstck_housed* ext_* use_fin_* lvstck_holding* *mortality_rate* *lost_disease* disease* any_imp* formal_land_rights_hh /*
*/ *livestock_expenses* *ls_exp_vac* *prop_farm_prod_sold *hrs_*   months_food_insec *value_assets* hhs_* *dist_agrodealer /*
*/ encs* num_crops_* multiple_crops* imprv_seed_* hybrid_seed_* *labor_total *farm_area *labor_productivity* *land_productivity* /*
*/ *wage_paid_aglabor* *labor_hired ar_h_wgt_* *yield_hv_* ar_pl_wgt_* *yield_pl_* *liters_per_* milk_animals poultry_owned *costs_dairy* *cost_per_lit* /*
*/ *egg_poultry_year* *inorg_fert_rate* *ha_planted* *cost_expli_hh* *cost_expli_ha* *monocrop_ha* *kgs_harv_mono* *cost_total_ha* /*
*/ *_exp* poverty_under_1_9 *value_crop_production* *value_harv* *value_crop_sales* *value_sold* *kgs_harvest* *total_planted_area* *total_harv_area* /*
*/ *all_area_* grew_* agactivities_hh ag_hh crop_hh livestock_hh fishing_hh *_milk_produced* *eggs_total_year *value_eggs_produced* /*
*/ *value_livestock_products* *value_livestock_sales* *total_cons* nb_cattle_today nb_poultry_today bottom_40_percap bottom_40_peraeq /*
*/ ccf_loc ccf_usd ccf_1ppp ccf_2ppp *sales_livestock_products area_plan* area_harv*  *value_pro* *value_sal*

/* in progress CG 4.5.24
//////////Identifier Variables ////////
*Add variables and ren household id so dta file can be appended with dta files from other instruments
gen hhid_panel = hhid 
lab var hhid_panel "panel hh identifier" 
gen case_cross = case_id
lab var case_cross "cross-sectional hh identifier"
//add case_id here?
gen geography = "Malawi"
la var geography "Location of survey"
gen survey = "LSMS-ISA"
la var survey "Survey type (LSMS or AgDev)"
gen year = "2019-20"
la var year "Year survey was carried out"
gen instrument = 10
la var instrument "Wave and location of survey"
label define instrument 1 "Tanzania NPS Wave 1" 2 "Tanzania NPS Wave 2" 3 "Tanzania NPS Wave 3" 4 "Tanzania NPS Wave 4" /*
	*/ 5 "Ethiopia ESS Wave 1" 6 "Ethiopia ESS Wave 2" 7 "Ethiopia ESS Wave 3" /*
	*/ 8 "Nigeria GHS Wave 1" 9 "Nigeria GHS Wave 2" 10 "Nigeria GHS Wave 3" /*
	*/ 11 "Tanzania TBS AgDev (Lake Zone)" 12 "Tanzania TBS AgDev (Northern Zone)" 13 "Tanzania TBS AgDev (Southern Zone)" /*
	*/ 14 "Ethiopia ACC Baseline" /*
	*/ 15 "India RMS Baseline (Bihar)" 16 "India RMS Baseline (Odisha)" 17 "India RMS Baseline (Uttar Pradesh)" 18 "India RMS Baseline (West Bengal)" /*
	*/ 19 "Nigeria NIBAS AgDev (Nassarawa)" 20 "Nigeria NIBAS AgDev (Benue)" 21 "Nigeria NIBAS AgDev (Kaduna)" /*
	*/ 22 "Nigeria NIBAS AgDev (Niger)" 23 "Nigeria NIBAS AgDev (Kano)" 24 "Nigeria NIBAS AgDev (Katsina)" 
label values instrument instrument	*/
saveold "${MWI_IHS_IHPS_W4_final_data}/MWI_IHS_IHPS_W4_household_variables.dta", replace 

********************************************************************************
*INDIVIDUAL LEVEL VARIABLES     
********************************************************************************		
use "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_person_ids.dta", clear
merge 1:1 hhid case_id indiv using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_control_income.dta", nogen  keep(1 3)
merge 1:1 hhid case_id indiv using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_make_ag_decision.dta", nogen  keep(1 3)
merge 1:1 hhid case_id indiv using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_ownasset.dta", nogen  keep(1 3)
merge m:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hhsize.dta", nogen keep (1 3) 
//merge 1:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_farmer_fert_use.dta", nogen  keep(1 3) // section not available
merge 1:1 hhid case_id indiv using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_farmer_improvedseed_use.dta", nogen  keep(1 3)
merge 1:1 hhid case_id indiv using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_farmer_vaccine.dta", nogen  keep(1 3)
merge m:1 hhid case_id using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_hhids.dta", nogen keep (1 3)

*Land rights - data not available
//merge 1:1 hhid case_id indiv using "${MWI_IHS_IHPS_W4_created_data}/MWI_IHS_IHPS_W4_land_rights_ind.dta", nogen
//recode formal_land_rights_f (.=0) if female==1	
//la var formal_land_rights_f "Individual has documentation of land rights (at least one plot) - Women only"

*getting correct subpopulations (women aged 18 or above in rural households)
recode control_all_income make_decision_ag own_asset /*formal_land_rights_f */(.=0) if female==1 
recode control_all_income make_decision_ag own_asset /*formal_land_rights_f */(nonmissing=.) if female==0

*merge in hh variable to determine ag household
preserve
use "${MWI_IHS_IHPS_W4_final_data}/MWI_IHS_IHPS_W4_household_variables.dta", clear
keep hhid ag_hh
tempfile ag_hh
save `ag_hh'
restore
merge m:1 hhid using `ag_hh', nogen keep (1 3)

replace   make_decision_ag =. if ag_hh==0

* NA in NG_LSMS-ISA
gen women_diet=.
gen  number_foodgroup=.
foreach c in wheat beans {
	gen all_imprv_seed_`c' = .
	gen all_hybrid_seed_`c' = .
	gen `c'_farmer = .
}

*Set improved seed adoption to missing if household is not growing crop
foreach v in $topcropname_area {
	replace all_imprv_seed_`v' =. if `v'_farmer==0 | `v'_farmer==.
	recode all_imprv_seed_`v' (.=0) if `v'_farmer==1
	replace all_hybrid_seed_`v' =. if  `v'_farmer==0 | `v'_farmer==.
	recode all_hybrid_seed_`v' (.=0) if `v'_farmer==1
	gen female_imprv_seed_`v'=all_imprv_seed_`v' if female==1
	gen male_imprv_seed_`v'=all_imprv_seed_`v' if female==0
	gen female_hybrid_seed_`v'=all_hybrid_seed_`v' if female==1
	gen male_hybrid_seed_`v'=all_hybrid_seed_`v' if female==0
}
/*
*generate missings
foreach g in all male female{
	foreach c in wheat beans{
	gen `g'_imprv_seed_`c' = .
	gen `g'_hybrid_seed_`c' = .
	}
}
*/
//gen female_use_inorg_fert=all_use_inorg_fert if female==1
//gen male_use_inorg_fert=all_use_inorg_fert if female==0 //need to fix inorg fert sections 
//lab var male_use_inorg_fert "1 = Individual male farmers (plot manager) uses inorganic fertilizer"
//lab var female_use_inorg_fert "1 = Individual female farmers (plot manager) uses inorganic fertilizer"
gen female_imprv_seed_use=all_imprv_seed_use if female==1
gen male_imprv_seed_use=all_imprv_seed_use if female==0
lab var male_imprv_seed_use "1 = Individual male farmer (plot manager) uses improved seeds" 
lab var female_imprv_seed_use "1 = Individual female farmer (plot manager) uses improved seeds"

gen female_vac_animal=all_vac_animal if female==1
gen male_vac_animal=all_vac_animal if female==0
lab var male_vac_animal "1 = Individual male farmers (livestock keeper) uses vaccines"
lab var female_vac_animal "1 = Individual female farmers (livestock keeper) uses vaccines"


*replace empty vars with missing 
global empty_vars *hybrid_seed* women_diet number_foodgroup
foreach v of varlist $empty_vars { 
	replace `v' = .
}

/* in progress CG 4.5.24
//////////Identifier Variables ////////
*Add variables and ren household id so dta file can be appended with dta files from other instruments
gen hhid_panel = hhid 
lab var hhid_panel "panel hh identifier" 
ren indiv indid
gen geography = "Malawi"
gen survey = "LSMS-ISA"
gen year = "2019-20"
gen instrument = 10
capture label define instrument 1 "Tanzania NPS Wave 1" 2 "Tanzania NPS Wave 2" 3 "Tanzania NPS Wave 3" 4 "Tanzania NPS Wave 4" /*
	*/ 5 "Ethiopia ESS Wave 1" 6 "Ethiopia ESS Wave 2" 7 "Ethiopia ESS Wave 3" /*
	*/ 8 "Nigeria GHS Wave 1" 9 "Nigeria GHS Wave 2" 10 "Nigeria GHS Wave 3" /*
	*/ 11 "Tanzania TBS AgDev (Lake Zone)" 12 "Tanzania TBS AgDev (Northern Zone)" 13 "Tanzania TBS AgDev (Southern Zone)" /*
	*/ 14 "Ethiopia ACC Baseline" /*
	*/ 15 "India RMS Baseline (Bihar)" 16 "India RMS Baseline (Odisha)" 17 "India RMS Baseline (Uttar Pradesh)" 18 "India RMS Baseline (West Bengal)" /*
	*/ 19 "Nigeria NIBAS AgDev (Nassarawa)" 20 "Nigeria NIBAS AgDev (Benue)" 21 "Nigeria NIBAS AgDev (Kaduna)" /*
	*/ 22 "Nigeria NIBAS AgDev (Niger)" 23 "Nigeria NIBAS AgDev (Kano)" 24 "Nigeria NIBAS AgDev (Katsina)" 
label values instrument instrument	
gen strataid=state
gen clusterid=ea */
saveold "${MWI_IHS_IHPS_W4_final_data}/MWI_IHS_IHPS_W4_individual_variables.dta", replace

********************************************************************************
*PLOT LEVEL VARIABLES     
********************************************************************************	
/*
*GENDER PRODUCTIVITY GAP (PLOT LEVEL)
/*use "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_plot_cropvalue.dta", clear
merge 1:1 y5_hhid plot_id using "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_plot_areas.dta", keep (1 3) nogen
merge 1:1 y5_hhid plot_id  using  "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_plot_decision_makers.dta", keep (1 3) nogen
merge m:1 y5_hhid using "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_hhids.dta", keep (1 3) nogen
merge 1:1 y5_hhid plot_id using "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_plot_family_hired_labor.dta", keep (1 3) nogen*/
//ALT 07.26.21: Updated to match new file structure
use "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_all_plots.dta", clear
collapse (sum) plot_value_harvest=value_harvest, by(dm_gender y5_hhid plot_id field_size)
merge 1:1 y5_hhid plot_id using "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_plot_family_hired_labor.dta", keep (1 3) nogen
merge m:1 y5_hhid using "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_hhids.dta", keep (1 3) nogen //ALT 07.26.21: Note to include this in the all_plots file.
/*DYA.12.2.2020*/ gen hhid=y5_hhid
/*DYA.12.2.2020*/ merge m:1 hhid using "${Tanzania_NPS_W5_final_data}/Tanzania_NPS_W5_household_variables.dta", nogen keep (1 3) keepusing(ag_hh fhh farm_size_agland)
/*DYA.12.2.2020*/ recode farm_size_agland (.=0) 
/*DYA.12.2.2020*/ gen rural_ssp=(farm_size_agland<=4 & farm_size_agland!=0) & rural==1 
/*ALT.07.26.2021 gen labor_total=.*/ //We don't have this because family labor is missing.
//replace area_meas_hectares=area_est_hectares if area_meas_hectares==.
ren field_size area_meas_hectares
//keep if cultivated==1
global winsorize_vars area_meas_hectares  labor_total  
foreach p of global winsorize_vars { 
	gen w_`p' =`p'
	local l`p' : var lab `p'
	_pctile w_`p'   [aw=weight] if w_`p'!=0 , p($wins_lower_thres $wins_upper_thres)    
	replace w_`p' = r(r1) if w_`p' < r(r1)  & w_`p'!=. & w_`p'!=0
	replace w_`p' = r(r2) if w_`p' > r(r2)  & w_`p'!=.
	lab var w_`p' "`l`p'' - Winsorized top and bottom 1%"
}
_pctile plot_value_harvest  [aw=weight] , p($wins_upper_thres) 
gen w_plot_value_harvest=plot_value_harvest
replace w_plot_value_harvest = r(r1) if w_plot_value_harvest > r(r1) & w_plot_value_harvest != . 
lab var w_plot_value_harvest "Value of crop harvest on this plot - Winsorized top 1%"
gen plot_productivity = w_plot_value_harvest/ w_area_meas_hectares
lab var plot_productivity "Plot productivity Value production/hectare"
gen plot_labor_prod = w_plot_value_harvest/w_labor_total  	
lab var plot_labor_prod "Plot labor productivity (value production/labor-day)"
gen plot_weight=w_area_meas_hectares*weight 
lab var plot_weight "Weight for plots (weighted by plot area)"
foreach v of varlist  plot_productivity  plot_labor_prod {
	_pctile `v' [aw=plot_weight] , p($wins_upper_thres) 
	gen w_`v'=`v'
	replace  w_`v' = r(r1) if  w_`v' > r(r1) &  w_`v'!=.
	local l`v' : var lab `v'
	lab var  w_`v'  "`l`v'' - Winzorized top 1%"
}	
	
global monetary_val plot_value_harvest plot_productivity plot_labor_prod 
foreach p of varlist $monetary_val {
	gen `p'_1ppp = (1+$Tanzania_NPS_W5_inflation) * `p' / $Tanzania_NPS_W5_cons_ppp_dollar 
	gen `p'_2ppp = (1+$Tanzania_NPS_W5_inflation) * `p' / $Tanzania_NPS_W5_gdp_ppp_dollar 
	gen `p'_usd = (1+$Tanzania_NPS_W5_inflation) * `p' / $Tanzania_NPS_W5_exchange_rate
	gen `p'_loc = (1+$Tanzania_NPS_W5_inflation) * `p' 
	local l`p' : var lab `p' 
	lab var `p'_1ppp "`l`p'' (2016 $ Private Consumption PPP)"
	lab var `p'_2ppp "`l`p'' (2016 $ GDP PPP)"
	lab var `p'_usd "`l`p'' (2016 $ USD)"
	lab var `p'_loc "`l`p'' (2016 TSH)"  
	lab var `p' "`l`p'' (TSH)"  
	gen w_`p'_1ppp = (1+$Tanzania_NPS_W5_inflation) * w_`p' / $Tanzania_NPS_W5_cons_ppp_dollar 
	gen w_`p'_2ppp = (1+$Tanzania_NPS_W5_inflation) * w_`p' / $Tanzania_NPS_W5_gdp_ppp_dollar 
	gen w_`p'_usd = (1+$Tanzania_NPS_W5_inflation) * w_`p' / $Tanzania_NPS_W5_exchange_rate 
	gen w_`p'_loc = (1+$Tanzania_NPS_W5_inflation) * w_`p' 
	local lw_`p' : var lab w_`p'
	lab var w_`p'_1ppp "`lw_`p'' (2016 $ Private Consumption PPP)"
	lab var w_`p'_2ppp "`lw_`p'' (2016 $ GDP PPP)"
	lab var w_`p'_usd "`lw_`p'' (2016 $ USD)"
	lab var w_`p'_loc "`lw_`p'' (2016 TSH)"
	lab var w_`p' "`lw_`p'' (TSH)"  
}

*We are reporting two variants of gender-gap
* mean difference in log productivitity without and with controls (plot size and region/state)
* both can be obtained using a simple regression.
* use clustered standards errors
qui svyset clusterid [pweight=plot_weight], strata(strataid) singleunit(centered) // get standard errors of the mean
* SIMPLE MEAN DIFFERENCE
gen male_dummy=dm_gender==1  if  dm_gender!=3 & dm_gender!=. //generate dummy equals to 1 if plot managed by male only and 0 if managed by female only


*** With winsorized variables
gen lplot_productivity_usd=ln(w_plot_productivity_usd) 
gen larea_meas_hectares=ln(w_area_meas_hectares)

/*
*** With non-winsorized variables //BT 12.04.2020 - Estimates do not change substantively 
gen lplot_productivity_usd=ln(plot_productivity_usd) 
gen larea_meas_hectares=ln(area_meas_hectares)

*/

*Gender-gap 1a 
svy, subpop(  if rural==1 ): reg  lplot_productivity_usd male_dummy 
matrix b1a=e(b)
gen gender_prod_gap1a=100*el(b1a,1,1)
sum gender_prod_gap1a
lab var gender_prod_gap1a "Gender productivity gap (%) - regression in logs with no controls"
matrix V1a=e(V)
gen segender_prod_gap1a= 100*sqrt(el(V1a,1,1)) 
sum segender_prod_gap1a
lab var segender_prod_gap1a "SE Gender productivity gap (%) - regression in logs with no controls"

*Gender-gap 1b
svy, subpop(  if rural==1 ): reg  lplot_productivity_usd male_dummy larea_meas_hectares i.region
matrix b1b=e(b)
gen gender_prod_gap1b=100*el(b1b,1,1)
sum gender_prod_gap1b
lab var gender_prod_gap1b "Gender productivity gap (%) - regression in logs with controls"
matrix V1b=e(V)
gen segender_prod_gap1b= 100*sqrt(el(V1b,1,1)) 
sum segender_prod_gap1b
lab var segender_prod_gap1b "SE Gender productivity gap (%) - regression in logs with controls"
lab var lplot_productivity_usd "Log Value of crop production per hectare"

/*DYA.12.2.2020 - Begin*/ 
*SSP
svy, subpop(  if rural==1 & rural_ssp==1): reg  lplot_productivity_usd male_dummy larea_meas_hectares i.region
matrix b1b=e(b)
gen gender_prod_gap1b_ssp=100*el(b1b,1,1)
sum gender_prod_gap1b_ssp
lab var gender_prod_gap1b_ssp "Gender productivity gap (%) - regression in logs with controls - SSP"
matrix V1b=e(V)
gen segender_prod_gap1b_ssp= 100*sqrt(el(V1b,1,1)) 
sum segender_prod_gap1b_ssp
lab var segender_prod_gap1b_ssp "SE Gender productivity gap (%) - regression in logs with controls - SSP"


*LS_SSP
svy, subpop(  if rural==1 & rural_ssp==0): reg  lplot_productivity_usd male_dummy larea_meas_hectares i.region
matrix b1b=e(b)
gen gender_prod_gap1b_lsp=100*el(b1b,1,1)
sum gender_prod_gap1b_lsp
lab var gender_prod_gap1b_lsp "Gender productivity gap (%) - regression in logs with controls - LSP"
matrix V1b=e(V)
gen segender_prod_gap1b_lsp= 100*sqrt(el(V1b,1,1)) 
sum segender_prod_gap1b_lsp
lab var segender_prod_gap1b_lsp "SE Gender productivity gap (%) - regression in logs with controls - LSP"
/*DYA.12.2.2020 - End*/ 

/// *BT 12.3.2020

* creating shares of plot managers by gender or mixed
tab dm_gender if rural_ssp==1, generate(manager_gender_ssp)

	rename manager_gender_ssp1 manager_male_ssp
	rename manager_gender_ssp2 manager_female_ssp
	rename manager_gender_ssp3 manager_mixed_ssp

	label variable manager_male_ssp "Male only decision-maker - ssp"
	label variable manager_female_ssp "Female only decision-maker - ssp"
	label variable manager_mixed_ssp "Mixed gender decision-maker - ssp"

tab dm_gender if rural_ssp==0, generate(manager_gender_lsp)

	rename manager_gender_lsp1 manager_male_lsp
	rename manager_gender_lsp2 manager_female_lsp
	rename manager_gender_lsp3 manager_mixed_lsp

	label variable manager_male_lsp "Male only decision-maker - lsp"
	label variable  manager_female_lsp "Female only decision-maker - lsp"
	label variable manager_mixed_lsp "Mixed gender decision-maker - lsp"

global gen_gaps gender_prod_gap1b segender_prod_gap1b gender_prod_gap1b_ssp segender_prod_gap1b_ssp gender_prod_gap1b_lsp segender_prod_gap1b_lsp manager_male* manager_female* manager_mixed*

* preserving variable labels
foreach v of var $gen_gaps {
	local l`v' : variable label `v'
	if `"`l`v''"' == "" {
local l`v' "`v'"
	}
 }

 
preserve
collapse (mean) $gen_gaps

* adding back in variable labels
foreach v of var * {
label var `v' "`l`v''"
}
 
xpose, varname clear
order _varname v1

rename v1 TNZ_wave5 
save   "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_gendergap.dta", replace
*save   "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_gendergap_nowin.dta", replace
restore

foreach i in 1ppp 2ppp loc{
	gen w_plot_productivity_all_`i'=w_plot_productivity_`i'
	gen w_plot_productivity_female_`i'=w_plot_productivity_`i' if dm_gender==2
	gen w_plot_productivity_male_`i'=w_plot_productivity_`i' if dm_gender==1
	gen w_plot_productivity_mixed_`i'=w_plot_productivity_`i' if dm_gender==3
	}

foreach i in 1ppp 2ppp loc{
	gen w_plot_labor_prod_all_`i'=w_plot_labor_prod_`i'
	gen w_plot_labor_prod_female_`i'=w_plot_labor_prod_`i' if dm_gender==2
	gen w_plot_labor_prod_male_`i'=w_plot_labor_prod_`i' if dm_gender==1
	gen w_plot_labor_prod_mixed_`i'=w_plot_labor_prod_`i' if dm_gender==3
}

gen plot_labor_weight= w_labor_total*weight

//////////Identifier Variables ////////
*Add variables and ren household id so dta file can be appended with dta files from other instruments
*ren y5_hhid hhid
gen geography = "Tanzania"
gen survey = "LSMS-ISA"
gen year = "2018-19"
gen instrument = 26
capture label define instrument 1 "Tanzania NPS Wave 1" 2 "Tanzania NPS Wave 2" 3 "Tanzania NPS Wave 3" 4 "Tanzania NPS Wave 4" /* This is in here twice because sometimes we don't run the whole file - anyone trying to run the whole thing through, though, will get an error here because the label is already defined. Capture just eats the error and keeps moving.
	*/ 5 "Ethiopia ESS Wave 1" 6 "Ethiopia ESS Wave 2" 7 "Ethiopia ESS Wave 3" /*
	*/ 8 "Nigeria GHS Wave 1" 9 "Nigeria GHS Wave 2" 10 "Nigeria GHS Wave 3" /*
	*/ 11 "Tanzania TBS AgDev (Lake Zone)" 12 "Tanzania TBS AgDev (Northern Zone)" 13 "Tanzania TBS AgDev (Southern Zone)" /*
	*/ 14 "Ethiopia ACC Baseline" /*
	*/ 15 "India RMS Baseline (Bihar)" 16 "India RMS Baseline (Odisha)" 17 "India RMS Baseline (Uttar Pradesh)" 18 "India RMS Baseline (West Bengal)" /*
	*/ 19 "Nigeria NIBAS AgDev (Nassarawa)" 20 "Nigeria NIBAS AgDev (Benue)" 21 "Nigeria NIBAS AgDev (Kaduna)" /*
	*/ 22 "Nigeria NIBAS AgDev (Niger)" 23 "Nigeria NIBAS AgDev (Kano)" 24 "Nigeria NIBAS AgDev (Katsina)"  25 "Nigeria GHS Wave 4" /*
	*/ 26 "Tanzania NPS Wave 5"
	
label values instrument instrument	
saveold "${Tanzania_NPS_W5_final_data}/Tanzania_NPS_W5_field_plot_variables.dta", replace */

********************************************************************************
*SUMMARY STATISTICS   
********************************************************************************	
