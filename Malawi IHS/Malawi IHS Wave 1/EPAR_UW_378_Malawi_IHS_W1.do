/*
-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title/Purpose 	: This do.file was developed by the Evans School Policy Analysis & Research Group (EPAR) 
				  for the construction of a set of agricultural development indicators 
				  using the Malawi National Panel Survey (IHS3) LSMS-ISA Wave 1 (2010-2011)
*Author(s)		: Didier Alia, Pierre Biscaye, David Coomes, Kelsey Figone, Melissa Howlett, Jack Knauer, Josh Merfeld,  Micah McFeely,
				  Isabella Sun, Chelsea Sweeney, Emma Weaver, Ayala Wineman, 
				  C. Leigh Anderson, & Travis Reynolds

*Acknowledgments: We acknowledge the helpful contributions of members of the World Bank's LSMS-ISA team, the FAO's RuLIS team, IFPRI, IRRI, 
				  and the Bill & Melinda Gates Foundation Agricultural Development Data and Policy team in discussing indicator construction decisions. 
				  All coding errors remain ours alone.
*Date			: 26 July, 2023

----------------------------------------------------------------------------------------------------------------------------------------------------*/


*Data source
*-----------
*The Malawi National Panel Survey was collected by the National Statistical Office in Zomba 
*and the World Bank's Living Standards Measurement Study - Integrated Surveys on Agriculture(LSMS - ISA)
*The data were collected over the period March 2010 - March 2011.
*All the raw data, questionnaires, and basic information documents are available for downloading free of charge at the following link
*http://microdata.worldbank.org/index.php/catalog/1003

*Throughout the do-file, we sometimes use the shorthand LSMS to refer to the Malawi National Panel Survey.

*Summary of Executing the Master do.file
*-----------
*This Master do.file constructs selected indicators using the Malawi IHS3 (MWI LSMS) data set.
*Using data files from within the "378 - LSMS Burkina Faso, Malawi, Uganda" folder within the "data" folder, 
*the do.file first constructs common and intermediate variables, saving dta files when appropriate 
*in \\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave1-2010-11\outputs 
*These variables are then brought together at the household, plot, or individual level, saving dta files at each level when available 
*in the folder "Tanzania TNPS - LSMS-ISA - Wave 4 (2014-15)" within the "Final Dta files" folder. //KEF 9.27.21 Update this with new file path 

*The processed files include all households, individuals, and plots in the sample.
*Toward the end of the do.file, a block of code estimates summary statistics (mean, standard error of the mean, minimum, first quartile, median, third quartile, maximum) 
*of final indicators, restricted to the rural households only, disaggregated by gender of head of household or plot manager.
*The results are outputted in the excel file "Tanzania_NPS_LSMS_ISA_W4_summary_stats.xlsx" in the "Tanzania TNPS - LSMS-ISA - Wave 4 (2014-15)" within the "Final Dta files" folder. //KEF 9.27.21 Update this with new file path 
*It is possible to modify the condition  "if rural==1" in the portion of code following the heading "SUMMARY StaTISTICS" to generate all summary statistics for a different sub_population.

 
/*
OUTLINE OF THE DO.FILE
Below are the list of the main files created by running this Master do.file

*INTERMEDIATE FILES					MAIN FILES CREATED
*-------------------------------------------------------------------------------------
*HOUSEHOLD IDS						Malawi_IHS_W1_hhids.dta
*INDIVIDUAL IDS						Malawi_IHS_W1_person_ids.dta
*HOUSEHOLD SIZE						Malawi_IHS_W1_hhsize.dta
*PARCEL AREAS						Malawi_IHS_W1_plot_areas.dta
*PLOT-CROP DECISION MAKERS			Malawi_IHS_W1_plot_decision_makers.dta
*TLU (Tropical Livestock Units)		Malawi_IHS_W1_TLU_Coefficients.dta

*GROSS CROP REVENUE					Malawi_IHS_W1_tempcrop_harvest.dta
									Malawi_IHS_W1_tempcrop_sales.dta
									Malawi_IHS_W1_permcrop_harvest.dta
									Malawi_IHS_W1_permcrop_sales.dta
									Malawi_IHS_W1_hh_crop_production.dta
									Malawi_IHS_W1_plot_cropvalue.dta
									Malawi_IHS_W1_parcel_cropvalue.dta
									Malawi_IHS_W1_crop_residues.dta
									Malawi_IHS_W1_hh_crop_prices.dta
									Malawi_IHS_W1_crop_losses.dta
*CROP EXPENSES						Malawi_IHS_W1_wages_mainseason.dta
									Malawi_IHS_W1_wages_shortseason.dta
									
									Malawi_IHS_W1_fertilizer_costs.dta
									Malawi_IHS_W1_seed_costs.dta
									Malawi_IHS_W1_land_rental_costs.dta
									Malawi_IHS_W1_asset_rental_costs.dta
									Malawi_IHS_W1_transportation_cropsales.dta
									
*CROP INCOME						Malawi_IHS_W1_crop_income.dta
									
*LIVESTOCK INCOME					Malawi_IHS_W1_livestock_products.dta
									Malawi_IHS_W1_livestock_expenses.dta
									Malawi_IHS_W1_hh_livestock_products.dta
									Malawi_IHS_W1_livestock_sales.dta
									Malawi_IHS_W1_TLU.dta
									Malawi_IHS_W1_livestock_income.dta

*FISH INCOME						Malawi_IHS_W1_fishing_expenses_1.dta
									Malawi_IHS_W1_fishing_expenses_2.dta
									Malawi_IHS_W1_fish_income.dta
																	
*SELF-EMPLOYMENT INCOME				Malawi_IHS_W1_self_employment_income.dta
									Malawi_IHS_W1_agproducts_profits.dta
									Malawi_IHS_W1_fish_trading_revenue.dta
									Malawi_IHS_W1_fish_trading_other_costs.dta
									Malawi_IHS_W1_fish_trading_income.dta
									
*WAGE INCOME						Malawi_IHS_W1_wage_income.dta
									Malawi_IHS_W1_agwage_income.dta
*OTHER INCOME						Malawi_IHS_W1_other_income.dta
									Malawi_IHS_W1_land_rental_income.dta

*FARM SIZE / LAND SIZE				Malawi_IHS_W1_land_size.dta
									Malawi_IHS_W1_farmsize_all_agland.dta
									Malawi_IHS_W1_land_size_all.dta
*FARM LABOR							Malawi_IHS_W1_farmlabor_mainseason.dta
									Malawi_IHS_W1_farmlabor_shortseason.dta
									Malawi_IHS_W1_family_hired_labor.dta
*VACCINE USAGE						Malawi_IHS_W1_vaccine.dta
*USE OF INORGANIC FERTILIZER		Malawi_IHS_W1_fert_use.dta
*USE OF IMPROVED SEED				Malawi_IHS_W1_improvedseed_use.dta

*REACHED BY AG EXTENSION			Malawi_IHS_W1_any_ext.dta
*USE OF FORMAL FINANACIAL SERVICES	Malawi_IHS_W1_fin_serv.dta
*GENDER PRODUCTIVITY GAP 			Malawi_IHS_W1_gender_productivity_gap.dta
*MILK PRODUCTIVITY					Malawi_IHS_W1_milk_animals.dta
*EGG PRODUCTIVITY					Malawi_IHS_W1_eggs_animals.dta

*CROP PRODUCTION COSTS PER HECtaRE	Malawi_IHS_W1_hh_cost_land.dta
									Malawi_IHS_W1_hh_cost_inputs_lrs.dta
									Malawi_IHS_W1_hh_cost_inputs_srs.dta
									Malawi_IHS_W1_hh_cost_seed_lrs.dta
									Malawi_IHS_W1_hh_cost_seed_srs.dta		
									Malawi_IHS_W1_cropcosts_perha.dta

*RATE OF FERTILIZER APPLICATION		Malawi_IHS_W1_fertilizer_application.dta
*HOUSEHOLD'S DIET DIVERSITY SCORE	Malawi_IHS_W1_household_diet.dta
*WOMEN'S CONTROL OVER INCOME		Malawi_IHS_W1_control_income.dta
*WOMEN'S AG DECISION-MAKING			Malawi_IHS_W1_make_ag_decision.dta
*WOMEN'S ASSET OWNERSHIP			Malawi_IHS_W1_ownasset.dta
*AGRICULTURAL WAGES					Malawi_IHS_W1_ag_wage.dta
*CROP YIELDS						Malawi_IHS_W1_yield_hh_crop_level.dta

*FINAL FILES						MAIN FILES CREATED
*-------------------------------------------------------------------------------------
*HOUSEHOLD VARIABLES				Malawi_IHS_W1_household_variables.dta
*INDIVIDUAL-LEVEL VARIABLES			Malawi_IHS_W1_individual_variables.dta	
*PLOT-LEVEL VARIABLES				Malawi_IHS_W1_gender_productivity_gap.dta
*SUMMARY STATISTICS					Malawi_IHS_W1_summary_stats.xlsx
*/


clear
set more off

clear matrix	
clear mata	
set maxvar 8000		

//set directories
*These paths correspond to the folders where the raw data files are located and where the created data and final data will be stored.
*These paths correspond to the folders where the raw data files are located and where the created data and final data will be stored.
global Malawi_IHS_W1_raw_data "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave1-2010-11\raw_data"
global Malawi_IHS_W1_created_data "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave1-2010-11\created_data"
global Malawi_IHS_W1_final_data "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave1-2010-11\outputs"

*MGM.4.13.2023 Re-scaling survey weights to match population estimates
*https://databank.worldbank.org/source/world-development-indicators#
//population data from 2010, the last year in which data were collected for this wave
global Malawi_IHS_W1_pop_tot 14718422
global Malawi_IHS_W1_pop_rur 12430590
global Malawi_IHS_W1_pop_urb 2287832

********************************************************************************
* EXCHANGE RATE AND INFLATION FOR CONVERSION IN USD *
********************************************************************************

//MGM 5.5.23: entire section updated
global MWI_IHS_W1 730.27		//https://data.worldbank.org/indicator/PA.NUS.FCRF?end=2017&locations=MW&start=2011
global MWI_IHS_W1_gdp_ppp_dollar 251.07    //https://data.worldbank.org/indicator/PA.NUS.PPP?end=2017&locations=MW&start=2011
global MWI_IHS_W1_cons_ppp_dollar 241.93	 //https://data.worldbank.org/indicator/PA.NUS.PRVT.PP?end=2017&locations=MW&start=2011
global MWI_IHS_W1_inflation 0.29394474 // CPI Survey Year 2010/CPI of Poverty Line Baseline Year 2017=100/340.2 //https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2017&locations=MW&start=2009

global MWI_IHS_W1_poverty_threshold (1.90*78.77*100/107.6) //see calculation and sources below
//WB's previous (PPP) poverty threshold is $1.90. 
//Multiplied by 2011 PPP conversion factor of 78.77 //https://data.worldbank.org/indicator/PA.NUS.PRVT.PP?end=2017&locations=MW&start=2009
//Multiplied by CPI in 2010 of 100 //https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2017&locations=MW&start=2009
//Divided by CPI in 2011 of 107.6 //https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2017&locations=MW&start=2009
global MWI_IHS_W1_poverty_ifpri (109797*100/340.2/365) //see calculation and sources below
//MWI government set national poverty line to MWK109,797 in January 2017 values //https://massp.ifpri.info/files/2019/05/IFPRI_KeyFacts_Poverty_Final.pdf
//Multiplied by CPI in 2010 of 100 //https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2017&locations=MW&start=2009
//Divided by CPI in 2017 of 340.2 //https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2017&locations=MW&start=2009
//Divide  by # of days in year (365) to get daily amount
global MWI_IHS_W1_poverty_215 (2.15* $MWI_IHS_W1_inflation * $MWI_IHS_W1_cons_ppp_dollar)  //WB's new (PPP) poverty threshold of $2.15 multiplied by globals
 
********************************************************************************
* THRESHOLDS FOR WINSORIZATION *
********************************************************************************
global wins_lower_thres 1    						//  Threshold for winzorization at the bottom of the distribution of continous variables
global wins_upper_thres 99							//  Threshold for winzorization at the top of the distribution of continous variables


********************************************************************************
* GLOBALS OF PRIORITY CROPS *
********************************************************************************
*Enter the 12 priority crops here (maize, rice, wheat, sorghum, pearl millet (or just millet if not disaggregated), cowpea, groundnut, common bean, yam, sweet potato, cassava, banana)
*plus any crop in the top ten crops by area planted that is not already included in the priority crops - limit to 6 letters or they will be too long!
*For consistency, add the 12 priority crops in order first, then the additional top ten crops

global topcropname_area "maize rice wheat sorgum pmill cowpea grdnt beans yam swtptt cassav banana cotton sunflr pigpea"
global topcrop_area "11 12 16 13 14 32 43 31 24 22 21 71 50 41 34"
global comma_topcrop_area "11, 12, 16, 13, 14, 32, 43, 31, 24, 22, 21, 71, 50, 41, 34"
global nb_topcrops : list sizeof global(topcropname_area) // Gets the current length of the global macro list "topcropname_area" 
display "$nb_topcrops"
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
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_cropname_table.dta", replace //This gets used to generate the monocrop files.


********************************************************************************
* HOUSEHOLD IDS *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_a_filt.dta", clear
rename hh_a01 district
rename hh_a02 ta 
rename ea_id ea
rename hh_wgt weight
gen rural = (reside==2)
ren reside stratum
gen region = . 
replace region=1 if inrange(district, 101, 107)
replace region=2 if inrange(district, 201, 210)
replace region=3 if inrange(district, 301, 315)
lab var region "1=North, 2=Central, 3=South"
lab var rural "1=Household lives in a rural area"
keep case_id stratum district ta ea rural region weight 
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta", replace
//MGM: This dataset includes case_id as a unique identifier, along with its location identifiers (i.e. rural, ea, etc.).

********************************************************************************
* WEIGHTS * 
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_a_filt.dta", clear
rename hh_a01 district
rename hh_a02 ta
rename ea_id ea
rename hh_wgt weight
gen rural = (reside==2)
ren reside stratum
gen region = . 
replace region=1 if inrange(district, 101, 107)
replace region=2 if inrange(district, 201, 210)
replace region=3 if inrange(district, 301, 315)
lab var region "1=North, 2=Central, 3=South"
lab var rural "1=Household lives in a rural area"
keep case_id region stratum district ta ea rural weight  
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_weights.dta", replace

********************************************************************************
* INDIVIDUAL IDS *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_b.dta", clear
keep case_id hh_b01 hh_b03 hh_b04 hh_b05a
gen female= (hh_b03==2)
lab var female "1= Individual is female"
gen age=hh_b05a
lab var age "Individual age"
gen hh_head= (hh_b04==1)
lab var hh_head "1= individual is household head"
drop hh_b03 hh_b04 hh_b05a
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_person_ids.dta", replace
//KF: This dataset uniquely identifies each individual by their hhid and id code, as well as other individual identifiers (gender, age).

//MGM: This rescales the weights to match the population better (original weights underestimate total population and overestimate rural population)
********************************************************************************
* HOUSEHOLD SIZE *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_b.dta", clear
gen hh_members = 1
rename hh_b04 relhead 
rename hh_b03 gender
gen fhh = (relhead==1 & gender==2)
collapse (sum) hh_members (max) fhh, by (case_id)
lab var hh_members "Number of household members"
lab var fhh "1= Female-headed household"

/*//MGM 4.13.2023: checking population numbers
merge 1:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_weights.dta", nogen
gen population=weight*hh_members
tabstat population, by(case_id) stat(sum)
*/

merge 1:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta", nogen keep(2 3)
total hh_members [pweight=weight]
matrix temp =e(b)
gen weight_pop_tot=weight*${Malawi_IHS_W1_pop_tot}/el(temp,1,1)
total hh_members [pweight=weight_pop_tot]
lab var weight_pop_tot "Survey weight - adjusted to match total population"
*Adjust to match total population but also rural and urban
total hh_members [pweight=weight] if rural==1
matrix temp =e(b)
gen weight_pop_rur=weight*${Malawi_IHS_W1_pop_rur}/el(temp,1,1) if rural==1
total hh_members [pweight=weight_pop_tot]  if rural==1

total hh_members [pweight=weight] if rural==0
matrix temp =e(b)
gen weight_pop_urb=weight*${Malawi_IHS_W1_pop_urb}/el(temp,1,1) if rural==0
total hh_members [pweight=weight_pop_urb]  if rural==0

egen weight_pop_rururb=rowtotal(weight_pop_rur weight_pop_urb)
total hh_members [pweight=weight_pop_rururb]  
lab var weight_pop_rururb "Survey weight - adjusted to match rural and urban population"
drop weight_pop_rur weight_pop_urb
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhsize.dta", replace

********************************************************************************
* GPS COORDINATES *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Geovariables\HH_level\householdgeovariables.dta", clear
merge 1:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta", nogen keep(3) 
ren lat_modified latitude
ren lon_modified longitude
keep case_id latitude longitude
gen GPS_level = "hhid"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_LSMS_ISA_hh_coords.dta", replace

********************************************************************************
* PLOT AREAS *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_c.dta", clear
gen season=0 //rainy
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_j.dta", gen(dry)
replace season=1 if season==.
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_p.dta", gen(perm)
replace season=3 if season==.
ren ag_c00 plot_id
replace plot_id=ag_j00 if plot_id==""
replace plot_id=ag_p0b if plot_id==""

* Counting acreage
gen area_acres_est = ag_c04a if ag_c04b == 1 										//Self-report in acres - rainy season 
replace area_acres_est = (ag_c04a*2.47105) if ag_c04b == 2 & area_acres_est ==.		//Self-report in hectares
replace area_acres_est = (ag_c04a*0.000247105) if ag_c04b == 3 & area_acres_est ==.	//Self-report in square meters
replace area_acres_est = ag_j05a if ag_j05b==1 & area_acres_est==.					//Replace with dry season measures if rainy season is not available
replace area_acres_est = (ag_j05a*2.47105) if ag_j05b == 2 & area_acres_est ==.		//Self-report in hectares
replace area_acres_est = (ag_j05a*0.000247105) if ag_j05b == 3 & area_acres_est ==.	//Self-report in square meters
replace area_acres_est = ag_p02a if ag_p02b==1 & area_acres_est==.					//Permanent crops in acres
replace area_acres_est = (ag_p02a*2.47105) if ag_p02b == 2 & area_acres_est ==.		//Permanent crops in hectares
replace area_acres_est = (ag_p02a*0.000247105) if ag_p02b == 3 & area_acres_est ==. //Permanent crops in square meters

* GPS MEASURE
gen area_acres_meas = ag_c04c														//GPS measure - rainy
replace area_acres_meas = ag_j05c if area_acres_meas==. 							//GPS measure - replace with dry if no rainy season measure
//replace area_acres_meas = ag_p02c if area_acres_meas == . // MGM 8.3.2023: there is not measurement for perm crops //GPS measure - permanent crops
* SAK NOTE 20190910: Should also keep if area_acres_meas is not missing (not 
* your mistake, it was that way in Tanzania because there wasn't a difference)
keep if area_acres_est !=. /*SAK START*/ | area_acres_meas !=. /*SAK END*/			//Keep if acreage or GPS measure info is available

* Copied from MWI W4 on 8.3.2023
gen field_size= (area_acres_est* (1/2.47105))
replace field_size = (area_acres_meas* (1/2.47105))  if field_size==. & area_acres_meas!=. 
keep case_id plot_id season area_acres_est area_acres_meas field_size 			
*collapse (sum) area_acres_est area_acres_meas, by (case_id plot_id)
gen gps_meas = area_acres_meas!=. //  Copied from MWI W2 on 5/23/23 
lab var gps_meas "Plot was measured with GPS, 1=Yes" // Copied from MWI W2 on 5/23/23 

lab var area_acres_meas "Plot are in acres (GPSd)"
lab var area_acres_est "Plot area in acres (estimated)"
gen area_est_hectares=area_acres_est* (1/2.47105)  
gen area_meas_hectares= area_acres_meas* (1/2.47105)
lab var area_meas_hectares "Plot are in hectares (GPSd)"
lab var area_est_hectares "Plot area in hectares (estimated)"

save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_areas.dta", replace

********************************************************************************
* PLOT DECISION MAKERS *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_b.dta", clear
ren hh_b01 personid			// personid is the roster number, combination of HHID and personid are unique id for this wave
gen female=hh_b03==2 
gen age=hh_b05a
gen head = hh_b04==1 //if hh_b04!=. 
keep personid female age case_id head
lab var female "1=Individual is a female"
lab var age "Individual age"
lab var head "1=Individual is the head of household"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_gender_merge.dta", replace

**MMH 5.20.19: check with Emma that this fix is okay
/*use "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_k.dta", clear
rename ag_k0a plotid
save "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_k.dta", replace*/ //ALT 10.21.19: This change got written to the raw data file and is in all the code below that references ag_mod_k


use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_d.dta", clear
rename ag_d00 plotid
drop if plotid=="" //275 observations deleted
gen cultivated = ag_d14==1
replace cultivated = 1 if cultivated==0 & ag_d20a!=. //Assumes that if a crop was grown, plot was cultivated. Prevents some records from going unmatched below.
gen dry=0
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_k.dta"
replace dry=1 if dry==.
replace plotid=ag_k0a if plotid==""
drop if plotid=="" //8,813 observations deleted
//drop if ag_d14==. & ag_k15==. //Not necessary because we already have this below
duplicates drop case_id plotid dry, force //Drops 1 duplicate
replace cultivated = 1 if ag_k15==1
replace cultivated = 0 if ag_k15!=1 & cultivated==. //ALT - have to add this because all cultivated values for ag mod k got added as missing 
replace cultivated = 1 if ag_k21a!=. & cultivated==0
drop if cultivated == 0 //329 observations deleted

*Gender/age variables 
//ALT 10.21.19 - Major changes to this section: ag_d02 -> ag_d01 (d01 is pid of the decisionmaker, d02 is pid of respondent)
gen personid = ag_d01 
replace personid =ag_k02 if personid==. & ag_k02!=. //MMH 5.20.19: check with Emma about 79 not matched //ALT 10.21.19 - in these cases, respondent ID is missing
merge m:1 case_id personid using  "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_gender_merge.dta", gen(dm1_merge) keep(1 3)		//Dropping unmatched from using ALT 10.22.19 - 44 from master not in hh rosters.
*First decision-maker variables //MMH 5.20.19: only one decision-maker in this wave (compared to up to three in other tools)
gen dm1_female = female
drop female personid
gen dm_gender = 1 if (dm1_female==0)  
replace dm_gender = 2 if (dm1_female==1)
la def dm_gender 1 "Male" 2 "Female" 
la val dm_gender dm_gender
lab var  dm_gender "Gender of plot manager/decision maker"

*Replacing observations without gender of plot manager with gender of HOH
merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhsize.dta", nogen 								
replace dm_gender = 1 if fhh==0 & dm_gender==.
replace dm_gender = 2 if fhh==1 & dm_gender==.
ren plotid plot_id 
drop if  plot_id==""
keep case_id plot_id case_id dm_gender dry cultivated  
lab var cultivated "1=Plot has been cultivated"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_decision_makers.dta", replace

/*
********************************************************************************
* SINGLE PLOT DECISION MAKER *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_b.dta", clear  //No plot or garden id in this dta
gen personid=pid
drop if personid=="" //0 observations deleted, all observations have unique identifiers

gen female=hh_b03==2
gen head = hh_b04==1 if hh_b04!=.
keep female hhid head personid
lab var female "1=Individual is a female"
lab var head "1=Individual is the head of household"
save "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_gender_merge.dta", replace

//First creating rainy season. Cleaning plotid for merge
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_d.dta", clear 	//Rainy season
drop if ag_d14==. 
gen cultivated = 1 if ag_d14==1
ren ag_d00 plotid
drop if plotid==""	
save "${Malawi_IHS_W1_created_data}/MLW_IHS_LSMS_ISA_W1_rainy_season_plot_manager.dta", replace 

//cleaning dry season
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_k.dta", clear 	//Dry season
drop if plotid=="" //2,164 observations deleted
save "${Malawi_IHS_W1_created_data}/MLW_IHS_LSMS_ISA_W1_dry_season_plot_manager.dta", replace

//MGM 1.9.23: replicated from W4 from ALT 03.04.22, not sure if this commented out section is needed
//merging dry and rainy
//merge 1:1 hhid plotid using "${Malawi_IHS_W1_created_data}/MLW_IHS_LSMS_ISA_W1_rainy_season_plot_manager.dta" 
append using "${Malawi_IHS_W1_created_data}/MLW_IHS_LSMS_ISA_W1_rainy_season_plot_manager.dta"
recode cultivated (.=0) //1,635 changes made


*Gender/age variables - decision makers
/*MGM: W4 used personid instead of decisionmakerid. Next section requires a merge where the using dataset has personid. These variables are different forms with different information, therefore I created decisionmakerid */
gen decisionmakerid = ag_d01 // refers to the decision-maker concerning crops, not respondent id
replace decisionmakerid = ag_k02 if decisionmakerid==. &  ag_k02!=.	// ag_k02 is "Who in the household makes the decisions concerning crops to be planted..." 1,186 obs missing both plot decision maker info

/*no personid in master
*what to do about missing from ag_d02 (respondent number)?
tostring hhid, gen(strhhid)
tostring ag_d02, gen(strag_d02)
gen personid = strhhid + "0" + strag_d02

merge m:1 hhid personid using "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_gender_merge.dta", gen(dm1_merge) keep (1 3)
*/
*/

********************************************************************************
* CROP UNIT CONVERSION FACTORS *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\IHS Agricultural Conversion Factor Database.dta", clear
ren crop_code crop_code_full
save "${Malawi_IHS_W1_created_data}\MLW_W1_cf.dta", replace

********************************************************************************
* CALORIC CONVERSION *
********************************************************************************
/*MGM: 2.6.23 MWI W4 as reference. There is no caloric_conversionfactor raw data file for W1. Codes are the same across waves. Copied the raw data file from W4 into the created data folder for W1.*/
/* MGM: 2.26.23  Creating a modified data file for IHS Conversion factors to help merge and populate more observations with calories
@Didier-many observations in all plots have N/A for condition on crops like Maize (and all crops in general). To help populate observations with calorie information, are you okay if we replace the conversion information for crops like Maize with the conversion for UNSHELLED? This would be a conservative estimate regarding edible portion.*/
	
	capture confirm file "${Malawi_IHS_W1_raw_data}/IHS Agricultural Conversion Factor Database.dta"
	if !_rc {
	use "${Malawi_IHS_W1_raw_data}/IHS Agricultural Conversion Factor Database.dta", clear
	//creating cassava and populating with sweet potato conversion values
	drop if crop_code!=28
	replace crop_code=49 if crop_code==28
	replace condition=. if crop_code==49
	save "${Malawi_IHS_W1_created_data}/Cassava Addition IHS Agricultural Conversion Factor Database.dta", replace
	
	//to populate N/A observations
	use "${Malawi_IHS_W1_raw_data}/IHS Agricultural Conversion Factor Database.dta", clear
	drop if condition==1 | condition==3
	replace condition=3
	label define condition 3 "N/A"
	save "${Malawi_IHS_W1_created_data}/Primary Amended IHS Agricultural Conversion Factor Database.dta", replace
	
	//to populate . observations
	use "${Malawi_IHS_W1_raw_data}/IHS Agricultural Conversion Factor Database.dta", clear
	drop if condition==1 | condition==3
	replace condition=. if condition==2
	save "${Malawi_IHS_W1_created_data}/Secondary Amended IHS Agricultural Conversion Factor Database.dta", replace
	
	//Appending with original IHS dataset
	use "${Malawi_IHS_W1_raw_data}/IHS Agricultural Conversion Factor Database.dta", clear
	append using "${Malawi_IHS_W1_created_data}/Primary Amended IHS Agricultural Conversion Factor Database.dta"
	append using "${Malawi_IHS_W1_created_data}/Secondary Amended IHS Agricultural Conversion Factor Database.dta"
	append using "${Malawi_IHS_W1_created_data}/Cassava Addition IHS Agricultural Conversion Factor Database.dta"
	label define condition 3 "N/A", modify
	label define crop_code 49 "CASSAVA", modify
	save "${Malawi_IHS_W1_created_data}/Final Amended IHS Agricultural Conversion Factor Database.dta", replace
}

//ALT: Temp
use "${Malawi_IHS_W1_created_data}/Final Amended IHS Agricultural Conversion Factor Database.dta", clear
recode crop_code (1 2 3 4=1)(5 6 7 8 9 10=5)(11 12 13 14 15 16=11)(17 18 19 20 21 22 23 24 25 26=17)
collapse (firstnm) conversion, by(region crop_code unit condition shell_unshelled)
ren crop_code crop_code_short
save "${Malawi_IHS_W1_created_data}/Final Amended IHS Agricultural Conversion Factor Database.dta", replace
//end alt temp


	else {
	di as error "IHS Agricultural Conversion Factor Database.dta not present; caloric conversion will likely be incomplete"
	}
	
	
	capture confirm file "${Malawi_IHS_W1_created_data}/caloric_conversionfactor.dta"
	if !_rc {
	use "${Malawi_IHS_W1_created_data}/caloric_conversionfactor.dta", clear
	
	/*ALT: It's important to note that the file contains some redundancies (e.g., we don't need maize flour because we know the caloric value of the grain; white and orange sweet potato are identical, etc. etc.)
	So we need a step to drop the irrelevant entries. */
	//Also there's no way tea and coffee are just tea/coffee
	//Also, data issue: no crop code is indicative of green maize (i.e., sweet corn); I'm assuming this means cultivation information is not tracked for that crop
	//Calories for wheat flour are slightly higher than for raw wheat berries.
	drop if inlist(item_code, 101, 102, 103, 105, 202, 204, 206, 207, 301, 305, 405, 813, 820, 822, 901, 902) | cal_100g == .

	
	local item_name item_name
	foreach var of varlist item_name{
		gen item_name_upper=upper(`var')
	}
	
	gen crop_code = .
	count if missing(crop_code) //106 missing
	
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
	replace crop_code=46 if strpos(item_name_upper, "PEA") // first to account for PEArl millet and pigeonPEA
	replace crop_code=33 if strpos(item_name_upper, "PEARL MILLET") | strpos(item_name_upper, "MCHEWERE")
	replace crop_code=35 if strpos(item_name_upper, "SOYABEAN")
	replace crop_code=36 if strpos(item_name_upper, "PIGEONPEA")| strpos(item_name_upper, "NANDOLO") | strpos(item_name_upper, "PIGEON PEA")
	replace crop_code=38 if strpos(item_name_upper, "SUNFLOWER")
	replace crop_code=39 if strpos(item_name_upper, "SUGAR CANE")
	replace crop_code=40 if strpos(item_name_upper, "CABBAGE")
	replace crop_code=41 if strpos(item_name_upper, "TANAPOSI")
	replace crop_code=42 if strpos(item_name_upper, "NKHWANI")
	replace crop_code=43 if strpos(item_name_upper, "OKRA")
	replace crop_code=44 if strpos(item_name_upper, "TOMATO")
	replace crop_code=45 if strpos(item_name_upper, "ONION")
	replace crop_code=47 if strpos(item_name_upper, "PAPRIKA")

	count if missing(crop_code) //87 missing
	
	// food from tree/permanent crop master list
	replace crop_code=49 if strpos(item_name_upper,"CASSAVA") 
	replace crop_code=50 if strpos(item_name_upper,"TEA")
	replace crop_code=51 if strpos(item_name_upper,"COFFEE") 
	replace crop_code=52 if strpos(item_name_upper,"MANGO")
	replace crop_code=53 if strpos(item_name_upper,"ORANGE")
	replace crop_code=54 if strpos(item_name_upper,"PAWPAW")| strpos(item_name_upper, "PAPAYA")
	replace crop_code=55 if strpos(item_name_upper,"BANANA")
	
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
	
	/*MGM: 2/26/23 consider adding parts of this section later in ALL PLOTS
	// Extra step for maize: maize grain (104) is same as shelled (removed from cob) maize
	// Use shelled/unshelled  ratio in unit conversion file
	//ALT: m:m should be a 1:m merge because duplicates indicate a problem. 
	gen unit = 1 //kg
	gen region = 1 //region doesn't matter for our purposes but will help reduce redundant entries after merge.
	merge 1:m crop_code unit region using "${Malawi_IHS_W1_raw_data}/IHS Agricultural Conversion Factor Database.dta", nogen keepusing(condition shell_unshelled) keep(1 3) //MGM: 11 matched, 21 not matched
	//replace edible_p = shell_unshelled * edible_p if shell_unshelled !=. & item_code==104
	
	// Extra step for groundnut: single item with edible portion that implies that value is for unshelled
	// If it's shelled, assume edible portion is 100
	replace edible_p = 100 if strpos(item_name,"Groundnut") & strpos(item_name, "Shelled")
	
	//ALT: you need to keep condition to successfully merge this with the crop harvest data
	//Note to double check and make sure that you don't need to fill in the missing condition codes.
	keep item_name crop_code cal_100g edible_p condition
	
	// Assume shelled if edible portion is 100
	replace condition=1 if edible_p==100
	*/
	
	// More matches using crop_code_short
	ren crop_code crop_code_short
	save "${Malawi_IHS_W1_created_data}/caloric_conversionfactor_crop_codes.dta", replace 
	}
	else {
	di as error "Updated conversion factor file not present; caloric conversion will likely be incomplete"
	}


********************************************************************************
* ALL PLOTS * 
********************************************************************************
/*W2, W3, and W4 as references*/

	*********************************
	* 		   CROP VALUES          *
	*********************************
		
//Nonstandard unit values (kg values in plot variables section)
	use "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_i.dta", clear
	gen season=0 //rainy season
	append using "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_o.dta"
	recode season (.=1) //dry season
	append using "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_q.dta"
	recode season(.=2) //tree or permanent crop; season 0= rainy, 1= dry, 2= perm
	lab var season "season: 0=rainy, 1=dry, 2=tree crop"
	label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
	label values season season
	keep if ag_i01==1 | ag_o01==1 | ag_q01==1 //keeping only if sold crops harvested
	ren ag_i02a sold_qty //rainy: total sold
	replace sold_qty = ag_o02a if sold_qty ==. & ag_o02a!=. //dry
	replace sold_qty = ag_q02a if sold_qty ==. & ag_q02a!=. //tree/permanent
	ren ag_i02b unit
	replace unit = ag_o02b if unit ==. & ag_o02b!=.
	replace unit = ag_q02b if unit ==. & ag_q02b!=.
	ren ag_i03 sold_value
	replace sold_value=ag_o03 if sold_value==. & ag_o03!=.
	replace sold_value=ag_q03 if sold_value==. & ag_q03!=.
	
	ren ag_i0b crop_code /*MGM: what does this note mean from TH: crop codes for temp and perm are different and have overlapping numbers*/
	replace crop_code =ag_o0b if crop_code ==. & ag_o0b!=.
	
	gen crop_code_perm=ag_q0b //MGM from TH: recode perm crop codes to have unique numbers from temp crop codes
	//labelbook 
	/*checked to see that crop codes align*/
	recode crop_code_perm (1=49)(2=50)(3=51)(4=52)(5=53)(6=54)(7=55)(8=56)(9=57)(10=58)(11=59)(12=60)(13=61)(14=62)(15=63)(16=64)(17=65)(18=66)(19=67)(39=68) //MM: Tree codes 19 & 39 were unlabeled in the original file, might be a mistake?
	la var crop_code_perm "Unique crop codes for trees/ permanent crops"
	label define crop_code_perm 49 "CASSAVA" 50 "TEA" 51 "COFFEE" 52 "MANGO" 53 "ORANGE" 54 "PAWPAW/PAPAYA" 55 "BANANA" 56 "AVOCADO" 57 "GUAVA" 58 "LEMON" 59 "NAARTJE (TANGERINE)" 60 "PEACH" 61 "POZA (CUSTARD APPLE)" 62 "MASUKU (MEXICAN APPLE)" 63 "MASAU" 64 "PINEAPPLE" 65 "MACADEMIA" 66 "OTHER (SPECIFY)" 67 "N/A" 68 "N/A" 
//MM: labeling 67 & 68 as N/A as tree codes 19 & 39 were unlabeled in the original file
	label val crop_code_perm crop_code_perm

	replace crop_code = crop_code_perm if crop_code==. & crop_code_perm!=. //MGM: applying tree codes to crop codes
	
	label define AG_M0B 49 "CASSAVA" 50 "TEA" 51 "COFFEE" 52 "MANGO" 53 "ORANGE" 54 "PAWPAW/PAPAYA" 55 "BANANA" 56 "AVOCADO" 57 "GUAVA" 58 "LEMON" 59 "NAARTJE (TANGERINE)" 60 "PEACH" 61 "POZA (CUSTARD APPLE)" 62 "MASUKU (MEXICAN APPLE)" 63 "MASAU" 64 "PINEAPPLE" 65 "MACADEMIA" 66 "OTHER (SPECIFY)" 67 "N/A" 68 "N/A", add
	
	keep case_id crop_code sold_qty unit sold_value
	
	merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_weights.dta", nogen keepusing(region stratum district ta ea rural weight)
	//MGM: 1,896 matched, 2,033 not matched

	keep case_id sold_qty unit sold_value crop_code region stratum district ta ea rural weight
	gen price_unit = sold_value/sold_qty // 2,034 missing values; n = 1895
	//MGM: why is this different from above? One observation didn't work
	lab var price_unit "Average sold value per crop unit"
	gen obs=price_unit!=.
	
	merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta", nogen keep(1 3)	
	
	*create a value for the price of each crop at different levels
	foreach i in region district ta ea case_id {
	preserve
	bys `i' crop_code unit : egen obs_`i'_price = sum(obs) 
	collapse (median) price_unit_`i'=price_unit [aw=weight], by (`i' crop_code unit obs_`i'_price) 
	tempfile price_unit_`i'_median
	save `price_unit_`i'_median'
	restore
	}
	
	collapse (median) price_unit_country = price_unit (sum) obs_country_price=obs [aw=weight], by(crop_code unit)
	tempfile price_unit_country_median
	save `price_unit_country_median'

	*********************************
	* 		 PLOT VARIABLES    		*
	*********************************
	use "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_g.dta", clear //rainy
	gen season=0 //create variable for season 
	append using "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_m.dta" //dry
	recode season(.=1)
	append using "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_p.dta" // tree/perm 
	ren ag_g0d crop_code
	ren ag_g0b plot_id
	replace plot_id=ag_m0b if plot_id==""
	replace plot_id=ag_p0b if plot_id==""
	ren ag_p03 number_trees_planted // number of trees planted during last 12 months 
	recode season (.=2)
	lab var season "season: 0=rainy, 1=dry, 2=tree crop"
	label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
	label values season season
	gen crop_code_perm=ag_p0d //MGM: tree crop codes overlap with crop crop codes. Recoded to have unique numbers.
	recode crop_code_perm (1=49)(2=50)(3=51)(4=52)(5=53)(6=54)(7=55)(8=56)(9=57)(10=58)(11=59)(12=60)(13=61)(14=62)(15=63)(16=64)(17=65)(18=66)
	la var crop_code_perm "Unique crop codes for trees/ permanent crops"
	label define crop_code_perm 49 "CASSAVA" 50 "TEA" 51 "COFFEE" 52 "MANGO" 53 "ORANGE" 54 "PAWPAW/PAPAYA" 55 "BANANA" 56 "AVOCADO" 57 "GUAVA" 58 "LEMON" 59 "NAARTJE (TANGERINE)" 60 "PEACH" 61 "POZA (CUSTARD APPLE)" 62 "MASUKU (MEXICAN APPLE)" 63 "MASAU" 64 "PINEAPPLE" 65 "MACADEMIA" 66 "OTHER (SPECIFY)" 
	replace crop_code=crop_code_perm if crop_code==. & crop_code_perm!=.
	/*ALT 06.28.23: updated label name */ label define L0C 49 "CASSAVA" 50 "TEA" 51 "COFFEE" 52 "MANGO" 53 "ORANGE" 54 "PAWPAW/PAPAYA" 55 "BANANA" 56 "AVOCADO" 57 "GUAVA" 58 "LEMON" 59 "NAARTJE (TANGERINE)" 60 "PEACH" 61 "POZA (CUSTARD APPLE)" 62 "MASUKU (MEXICAN APPLE)" 63 "MASAU" 64 "PINEAPPLE" 65 "MACADEMIA" 66 "FODDER TREES" 67 "FERTILIZER TREES" 68 "FUEL WOOD TREES" 69 "OTHER (SPECIFY)"  1800 "FODDER TREES" 1900 "FERTILIZER TREES" 2000 "FUEL WOOD TREES", add
	/*ALT 06.28 relocate up from line 908 for labels*/ replace crop_code = ag_m0d if crop_code==.
	label val crop_code L0C
	
	//ALT: Can delete, what's up with the 4.6 k obs that are being dropped?
	**consolidate crop codes (into the lowest number of the crop category)
	//MGM: 4.17.23 commented out drop command. Why should we get rid of this? What this comment intended crop_code_short referenced later in all plots. Should I change names?
	gen crop_code_short=crop_code //Generic level (without detail)
	recode crop_code_short (1 2 3 4=1)(5 6 7 8 9 10=5)(11 12 13 14 15 16=11)(17 18 19 20 21 22 23 24 25 26=17)
	la var crop_code_short "Generic level crop code"
	la def L0C 1 "Maize" 5 "Tobacco" 11 "Groundnut" 17 "Rice", modify
	la val crop_code_short L0C
	//la val crop_code_short crop_complete  //ALT: holdover code?
	//label define crop_complete 1 "Maize" 5 "Tobacco" 11 "Groundnut" 17 "Rice", modify
	//drop if crop_code_short==.
	drop if crop_code==.
	*Create area variables
	gen crop_area_share=ag_g03 //rainy season TH: this indicates proportion of plot with crop, but NGA area_unit indicates the unit (ie stands/ridges/heaps) that area was measured in; tree file did not ask about area planted
	//CWL: "Approximately how much of the PLOT is under CROP?" for crops rainy season
	label var crop_area_share "Proportion of plot planted with crop"
	replace crop_area_share=ag_m03 if crop_area_share==. & ag_m03!=. //crops dry season MGM: no real changes made. The 55 observations with data were dropped above.
	
	//converting answers to proportions
	replace crop_area_share=0.125 if crop_area_share==1 // Less than 1/4
	replace crop_area_share=0.25 if crop_area_share==2 
	replace crop_area_share=0.5 if crop_area_share==3
	replace crop_area_share=0.75 if crop_area_share==4
	replace crop_area_share=.875 if crop_area_share==5 // More than 3/4 
	replace crop_area_share=1 if ag_g02==1 | ag_m02==1 //planted on entire plot for both rainy and dry season
	merge m:1 case_id plot_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_areas.dta", keep(1 3) nogen
	gen ha_planted=crop_area_share*area_meas_hectares
	
	replace ha_planted=crop_area_share*area_est_hectares if ha_planted==. & area_est_hectares!=. & area_est_hectares!=0
	//MGM: convert area to hectares.
	//ag_p02b is unit: 1-acre 2-hectare 3-sq meter 4-other but no observations in units other than acres
	replace ha_planted=ag_p02a* (1/2.47105) if ag_p02b==1 & ha_planted==. & (ag_p02a!=. & ag_p02a!=0 & ag_p02b!=0 & ag_p02b!=.)
	replace ha_planted=ag_p02a*(1/10000) if ag_p02b==3 & ha_planted==. & (ag_p02a!=. & ag_p02a!=0 & ag_p02b!=0 & ag_p02b!=.) //MGM: no real changes made. There are no observations in units other than acres. Is this command necessary?
	
	tempfile ha_planted
	save `ha_planted'

	//MGM-QUESTION (same comment as TH in W2): The NGA w3 survey asks "what area of the plot is covered by trees" while the Malawi w4 survey (same as w2) asks "what is the area of the plantation" (for trees, not tree crop specific; area + unit), how can we consolidate these under one indicator/ should we?
	drop crop_area_share
	
	//MGM: Malawi w1 doesn't ask about area harvested, only if area harvested was less than area planted (y/n, without numerical info). We assume area planted=area harvested bc no extra info. However, there are no observations for this variable (ag_m09). Why?
	gen ha_harvested=ha_planted 
	//MGM: the below line of code was in Malawi W4 but there is no equivalent variable for W1. Commenting out for now.
	//replace ha_harvested=ha_planted * ag_g11_2 if ag_g11_2!=. & ha_planted!=. 

	
	*Create time variables (month planted, harvest, and length of time grown)
	
	*month planted
	gen month_planted = ag_g05a
	replace month_planted = ag_m05a if month_planted==.
	lab var month_planted "Month of planting"
	
	*year planted
	//codebook ag_m05b
	//codebook ag_g05b
	//drop if ag_m05b < 2018 
	//CWL:question asked about dry season in 2018/2019, dropping responses not in in this range - there are handful in 2001-2017
	//drop if ag_g05b < 2017 
	//There are  8,749 obs in 2017 - not dropping because it's larger
	//CWL-QUESTION: should we drop regardless?
	//ALT 11.18.22: All temporary crop production should be relevant to the survey period, so we should only be dropping tree crops whose production period ended before the survey target season. Those early plantings are headscratchers, though. I'm going to assume typos, although some are sugarcane, which can be grown as a perennial crop.
	//drop if ag_p06a < 2017 //MGM 1/5/23: why is this line of code here? this variable is months not years therefore thousands of observations are dropped. W4 may need to be corrected.
	gen year_planted1 = ag_g05b
	gen year_planted2 = ag_m05b //MGM: no observations
	gen year_planted = year_planted1
	replace year_planted= year_planted2 if year_planted==. //no changes made as no observations for year_planted2
	lab var year_planted "Year of planting"
	
	*month harvest started
	gen harvest_month_begin = ag_g12a
	replace harvest_month_begin=ag_m12a if harvest_month_begin==. & ag_m12a!=. //MGM: 0 changes made. Something seems to be going continually wrong the dry season data. Not a lot of information there.
	lab var harvest_month_begin "Month of start of harvesting"
	
	*month harvest ended
	gen harvest_month_end=ag_g12b
	replace harvest_month_end=ag_m12b if harvest_month_end==. & ag_m12b!=.
	lab var harvest_month_end "Month of end of harvesting"
	
	*months crop grown
	gen months_grown = harvest_month_begin - month_planted if harvest_month_begin > month_planted  // since no year info, assuming if month harvested was greater than month planted, they were in same year 
	replace months_grown = 12 - month_planted + harvest_month_begin if harvest_month_begin < month_planted // 5,749 real changes made; months in the first calendar year when crop planted
	replace months_grown = 12 - month_planted if months_grown<1 // reconcile crops for which month planted is later than month harvested in the same year
	replace months_grown=. if months_grown <1 | month_planted==. | harvest_month_begin==. // 0 changes made
	replace months_grown=. if year_planted!=2007 & year_planted!=2008 & year_planted!=2009 & year_planted!=2010 //choosing not to months_grown from observations with obscure planting years instead of dropping observations with obscure planting years
	lab var months_grown "Total months crops were grown before harvest"

	//MGM 5.31.23 adding this - note for MWI team to add to their Waves too!
	//Plot workdays
	preserve
	gen days_grown = months_grown*30 
	collapse (max) days_grown, by(case_id plot_id)
	save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_season_length.dta", replace
	restore
	
	*MGM: 4.17.2023 - inferring harvest year from month_planted, year_planted, harvest_month_begin, and months_grown
	//tab months_grown
	//all observations of months_grown less than or equal to 11 months. Hence, the following code:
	gen year_harvested=year_planted if harvest_month_begin>month_planted
	replace year_harvested=year_planted+1 if harvest_month_begin<month_planted
	replace year_harvested=. if year_planted!=2007 & year_planted!=2008 & year_planted!=2009 & year_planted!=2010 ////choosing not to infer year_harvested from observations with obscure planting years instead of dropping observations with obscure planting years
	//lab var year_harvested "Year of harvesting"

	
	//MGM-QUESTION: do we need the date_planted?
	gen date_planted = mdy(month_planted, 1, ag_g05b) if ag_g05b!=. //1,847 missing values
	replace date_planted = mdy(month_planted-12, 1, ag_g05b) if month_planted>12 & ag_g05b!=. //0 real changes
	replace date_planted = mdy(month_planted-12, 1, ag_m05b) if month_planted>12 & ag_m05b!=. //0 real changes
	replace date_planted = mdy(month_planted, 1, ag_m05b) if date_planted==. & ag_m05b!=. //0 real changes
	*MGM: survey did not ask for harvest year, check assumptions for year:
	/*come back to this after looking at Andrew handout of timeline*/
	gen date_harvested = mdy(harvest_month_begin, 1, ag_g05b) if ag_g05b==2010
	replace date_harvested = mdy(harvest_month_begin, 1, ag_m05b) if date_harvested==. & ag_m05b==2010
	replace date_harvested = mdy(harvest_month_begin, 1, ag_g05b) if month_planted<=12 & harvest_month_begin>month_planted & date_harvest==. & ag_g05b!=. //assuming if planted in 2010 and month harvested is later than planted, it was harvested in 2010
	replace date_harvested = mdy(harvest_month_begin, 1, ag_m05b) if month_planted<=12 & harvest_month_begin>month_planted & date_harvest==. & ag_m05b!=.
	replace date_harvested = mdy(harvest_month_begin, 1, ag_g05b+1) if month_planted<=12 & harvest_month_begin<month_planted & date_harvest==. & ag_g05b!=.
	replace date_harvested = mdy(harvest_month_begin, 1, ag_m05b+1) if month_planted<=12 & harvest_month_begin<month_planted & date_harvest==. & ag_m05b!=.
	
	format date_planted %td
	format date_harvested %td
	gen days_grown=date_harvest-date_planted
	
	bys plot_id case_id : egen min_date_harvested = min(date_harvested)
	bys plot_id case_id : egen max_date_planted = max(date_planted)
	gen overlap_date = min_date_harvested - max_date_planted
	
	*Generate crops_plot variable for number of crops per plot. This is used to fix issues around intercropping and relay cropping being reported inaccurately for our purposes.
	preserve
		gen obs=1
		replace obs=0 if ag_g13a==0 | ag_m11a==0 | ag_p09a==0  //333 real changes made; would have been 0 if no crops were harvested
		collapse(sum)crops_plot=obs, by(case_id plot_id season) //MGM: gardenid is not a variable for W1; should it  be?
		//br if crops_plot>1
		tempfile ncrops
		save `ncrops'
	restore
	
	merge m:1 case_id plot_id season using `ncrops', nogen //MGM: no gardenid variable for W1
	
	gen contradict_mono = 1 if (ag_g01==1 | ag_m01==1) & crops_plot >1
	gen contradict_inter = 1 if (ag_g01==2 | ag_m01==2) & crops_plot ==1 
	replace contradict_inter = . if ag_g01==1 | ag_m01==1 
	
	//TH: lost crop in Nigeria = entire plot lost: purpose is to check replanted plot/monocrop, Malawi doesn't ask about entire lost plot so no need to calculate lost crop or relay plants (unique plant and harvest dates)
	//CWL: same for MWI W4
	//MGM: same for MWI W1
		
	//gen lost_crop= inlist(ag_g11a,1,3,4,5,6,11,12) | inlist(ag_g11b,1,3,4,5,6,11,12) | inlist(ag_m10a,1,3,4,5,6,11,12) | inlist(ag_m10b,1,3,4,5,6,11,12) | inlist(ag_p08a,1,3,4,5,6,11,12) | inlist(ag_p08b,1,3,4,5,6,11,12) crop was partially lost b/c of drought, fire, insects, animals, crop theft, irregular rains, flooding, or other specified reasons
	//bys hhid plot_id: egen max_lost = max(lost_crop) 	
	
		*Generating monocropped plot variables (Part 1)
		bys case_id plot_id season: egen crops_avg= mean(crop_code_short) //checks for diff versions of same crop in the same plot
		gen purestand=1 if crops_plot==1 | crops_avg == crop_code_short //3,299 missing values
		gen perm_crop=1 if crop_code!=. //36394 missing values; MGM 1/5/23: this is the same number of missing values as W4. Why would this occur?
		bys case_id plot_id: egen permax = max(perm_crop) //no gardenid for W1

		bys case_id plot_id month_planted year_planted : gen plant_date_unique=_n
		bys case_id plot_id harvest_month_begin : gen harv_date_unique=_n //MGM: survey does not ask year of harvest for crops
		bys case_id plot_id : egen plant_dates = max(plant_date_unique)
		bys case_id plot_id : egen harv_dates = max(harv_date_unique) 

	replace purestand=0 if (crops_plot>1 & (plant_dates>1 | harv_dates>1))  | (crops_plot>1 & permax==1)  //3,393 real changes
	gen any_mixed=!(ag_g01==1 | ag_m01==1 | (perm_crop==1 & purestand==1)) 
	bys case_id plot_id : egen any_mixed_max = max(any_mixed)
	replace purestand=1 if crops_plot>1 & plant_dates==1 & harv_dates==1 & permax==0 & any_mixed_max==0 //0 replacements
	*gen relay=1 if crops_plot>1 & crops_plot>1 & plant_dates==1 & harv_dates==1 & permax==0 & any_mixed_max==0 
	//MGM: no need to calc relay bc Malawi does not ask about complete crop loss on a plot	
	
	replace purestand=1 if crop_code==crops_avg //28 real changes
	replace purestand=0 if purestand==. //51 real changes
	drop crops_plot crops_avg plant_dates harv_dates plant_date_unique harv_date_unique permax
	
	//rescaling plots 
	replace ha_planted = ha_harvest if ha_planted==. //0 changes
	//Let's first consider that planting might be misreported but harvest is accurate
	replace ha_planted = ha_harvest if ha_planted > area_meas_hectares & ha_harvest < ha_planted & ha_harvest!=. //0 changes
	gen percent_field=ha_planted/area_meas_hectares //5,471 missing values generated
*Generating total percent of purestand and monocropped on a field
	bys case_id plot_id: egen total_percent = total(percent_field)
	
	replace percent_field = percent_field/total_percent if total_percent>1 & purestand==0
	replace percent_field = 1 if percent_field>1 & purestand==1
	
	replace ha_planted = percent_field*area_meas_hectares
	replace ha_harvest = ha_planted if ha_harvest > ha_planted
	
	//ALT INSERTION
	*renaming unit code for merge
	gen unit = .
	replace unit = ag_g13b 
	replace unit = ag_g09b if unit == .
	replace unit = ag_m11b if unit == . 
	replace unit = ag_p09b if unit == .
	//END ALT Insertion
	
	/*ren ag_g13b unit
	replace unit = ag_m11b if unit==. & ag_m11b !=. //0 changes because dry season
	replace unit = ag_p09b if unit==. & ag_p09b !=. //1,406 changes
	lab define unit 3 "90 KG BAG" 11 "BASKET (DENGU)" 14 "PAIL (MEDIUM)" 98 "HEAP", add //MGM: adding units from conversion file to merge !!! this was ag_g13b before but I changed it to unit to see if it makes a difference in calories
	*/
	ren ag_g13a quantity_harvested
	replace quantity_harvested = ag_m11a if quantity_harvested==. & ag_m11a !=. //0 changes dry season
	replace quantity_harvested = ag_p09a if quantity_harvested==. & ag_p09a !=. //1,476 changes
	
	//merging in HH module A to bring in region info 
	//drop _merge
	merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta", nogen keep(1 3) //33,610 matched MGM: 3.29.23 changed this to a created data set instead of "${Malawi_IHS_W1_raw_data}\Household\hh_mod_a_filt.dta". New WB data download changed hhid to case_id - updating code accordingly. The created data set offers regional info and renamed case_id to hhid
	
	*renaming condition vars in master to match using file 
	gen condition=ag_g09c
	lab define condition 1 "S: SHELLED" 2 "U: UNSHELLED" 3 "N/A", modify
	lab val condition condition
	replace condition = ag_g13c if condition==. & ag_g13c !=. //23,525 reach changes
	replace condition = ag_m11c if condition==. & ag_m11c !=. //0 real changes made, no observations for ag_m11c
	
	gen unit_fix = strpos(ag_g13b_os, "70 KGS") | strpos(ag_g13b_os, "1 TON")
	replace quantity_harvested = quantity_harvested * 70 if strpos(ag_g13b_os, "70 KGS") //2 real changes
	replace quantity_harvested = quantity_harvested * 1000 if strpos(ag_g13b_os, "1 TON") //3 real changes
	replace unit = 1 if unit_fix==1 //5 real changes
	drop unit_fix

	capture {
		confirm file `"${Malawi_IHS_W1_created_data}/Final Amended IHS Agricultural Conversion Factor Database.dta"'
	} 
	if !_rc {
	merge m:1 region crop_code_short unit condition using "${Malawi_IHS_W1_created_data}/Final Amended IHS Agricultural Conversion Factor Database.dta", keep(1 3) gen(cf_merge) 
} 
else {
 di as error "Updated conversion factors file not present; harvest data will likely be incomplete"
}

//ALT: Multiply by shelled/unshelled cf for unshelled units
	replace conversion = 1 if unit == 1 & conversion==. //232 changes
	replace conversion = 1*shell_unshelled if unit == 1 & conversion==. & condition==2 //0 changes
	replace conversion = 50 if unit==2 & conversion==. & condition //452 changes
	replace conversion = 50*shell_unshelled if unit==2 & conversion==. & condition==2 //0 changes
	replace conversion = 90 if unit==3 & conversion==. //43 changes
	replace conversion = 90*shell_unshelled if unit==3 & conversion==. & condition==2 //0 changes
	gen quant_harv_kg= quantity_harvested*conversion
	
	preserve
	keep quant_harv_kg crop_code crop_code_short case_id plot_id season
	save "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_yield_1_6_23.dta", replace
	restore	

//ALT This should use the geographic medians.
merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_weights.dta", nogen //33,610 matched, 2,011 not matched

foreach i in region district ta ea case_id {
	merge m:1 `i' crop_code unit using `price_unit_`i'_median', nogen keep(1 3)
	}
merge m:1 unit crop_code using `price_unit_country_median', nogen keep(1 3)
//Using giving household price priority; take hhid out if results are looking weird
gen value_harvest = price_unit_case_id * quant_harv_kg 
gen missing_price = value_harvest == .
foreach i in region district ta ea { //decending order from largest to smallest geographical figure
replace value_harvest = quant_harv_kg * price_unit_`i' if missing_price == 1 & obs_`i' > 9 & obs_`i' != . 
}
replace value_harvest = quant_harv_kg * price_unit_country if value_harvest==.

	//gen value_harvest = price_unit_country * quant_harv_kg 
	gen val_unit = value_harvest/quantity_harvested
	gen val_kg = value_harvest/quant_harv_kg
	//merge m:1 HHID using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_weights.dta", nogen keep(1 3)
	gen plotweight = ha_planted*conversion
	gen obs=quantity_harvested>0 & quantity_harvested!=.

preserve
	collapse (mean) val_unit, by (case_id crop_code unit)
	ren val_unit hh_price_mean
	lab var hh_price_mean "Average price reported for this crop-unit in the household"
	save "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_hh_crop_prices_for_wages.dta", replace
restore
preserve
collapse (median) val_unit_country = val_unit (sum) obs_country_unit=obs [aw=plotweight], by(crop_code unit)
save "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_crop_prices_median_country.dta", replace //This gets used for self-employment income.
restore	

//MGM 7.7.2023 no still-to-harvest value on MWI W1 instrument so not including this subsection

	
	*********************************
	*   ADDING CALORIC CONVERSION	*
	*********************************
	capture {
		confirm file `"${Malawi_IHS_W1_created_data}/caloric_conversionfactor_crop_codes.dta"'
	} 
	if _rc!=0 {
		display "Note: file ${Malawi_IHS_W1_created_data}/caloric_conversionfactor_crop_codes.dta does not exist - skipping calorie calculations"		
	}
	if _rc==0{
		merge m:1 crop_code_short using "${Malawi_IHS_W1_created_data}/caloric_conversionfactor_crop_codes.dta", nogen keep(1 3)
	
		// logic for units: calories / 100g * kg * 1000g/kg * edibe perc * 100 / perc * 1/1000 = cal
		gen calories = cal_100g * quant_harv_kg * edible_p / .1 
		count if missing(calories) //3,575 then 3,567 missing then 2,939 missing (pea fix) then 2,757 (cassava populated with sweet potato)
		//unit is blank on 352 observations - nothing we can do there; quantity_harvested only blank on 16 observations; 2,433 due to conversion being blank - likely because IHS Agri Conversion file has many . in conversion
	}	

//AgQuery
	collapse (sum) quant_harv_kg ha_planted ha_harvest number_trees_planted percent_field calories (max) months_grown, by(region district ea case_id plot_id crop_code_short purestand area_meas_hectares season)
	bys case_id plot_id : egen percent_area = sum(percent_field)
	bys case_id plot_id : gen percent_inputs = percent_field/percent_area
	drop percent_area //Assumes that inputs are +/- distributed by the area planted. Probably not true for mixed tree/field crops, but reasonable for plots that are all field crops
	//Labor should be weighted by growing season length, though. 

	//MGM: 2/6/23 @ALT I don't think W1 has garden_id - this chunk ins't running because observations are not uniquely identified. Any suggestions?
	//merge m:1 hhid plot_id case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_decision_makers.dta",  nogen keep(1 3) keepusing(dm_gender)
	
	save "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_all_plots.dta", replace

********************************************************************************
* MONOCROPPED PLOTS *
********************************************************************************
/*
//Setting things up for AgQuery first
use "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_all_plots.dta", clear
	keep if purestand==1 //& relay!=1 //MWI does not distinguish relay crops
	ren crop_code_master cropcode
	//merge 1:1 case_id plot_id using "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_plot_cost_inputs.dta", nogen keep(1 3)
	/*Easy way, starting from previous line
	merge 1:1 case_id plot_id using "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_plot_cost_inputs_wide.dta", nogen keep(1 3) //If we want to keep identities of all inputs
	merge m:1 cropcode using "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_cropname_table.dta", nogen keep(3) //Filter down to crops we have names for.
	local listvars = "firstvar-lastvar" //Note to look this up
	foreach i in `listvars' {
		ren `i' `i'_
	}
	gen grew_ = 1 //Only plots where <cropname> was grown are here
	reshape wide *_, i(case_id cropcode) j(cropname)
	recode grew_* (.=0)
	//ALT note that the nomenclature here will be different than is standard in these files, but this is quicker and, I think, easier than the way we currently do it (one file to merge in at the end instead of several). I'm not using these files for agquery.
*/

use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_decision_makers.dta", clear
use "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_all_plots.dta", clear
	keep if purestand==1 //& relay!=1 //MWI does not distinguish relay crops
	merge m:1 case_id plot_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender) //4,838 observations not matched, 13,972 matched - MGM thinking this may be an issue in the plot decision makers file because ~13,000 observations are currently being dropped at one point
	ren crop_code_master cropcode //MGM 7.9.2023 there is no crop_code_master just crop_code_short, is this the variable I want to use? Should I change the name in ALL PLOTS?
	ren ha_planted monocrop_ha
	ren quant_harv_kg kgs_harv_mono
	ren value_harvest val_harv_mono //MGM 7.9.2023 there is no value_harvest - maybe this needs to be added to ALL PLOTS?
	
	//MGM 7.9.2023 I added a subsection to priority crops globals -is this correct?
	forvalues k=1(1)$nb_topcrops  {		
preserve	
	local c : word `k' of $topcrop_area
	local cn : word `k' of $topcropname_area
	local cn_full : word `k' of $topcropname_area_full
	keep if cropcode==`c'			
	ren monocrop_ha `cn'_monocrop_ha
	drop if `cn'_monocrop_ha==0 		
	ren kgs_harv_mono kgs_harv_mono_`cn'
	ren val_harv_mono val_harv_mono_`cn'
	gen `cn'_monocrop=1
	la var `cn'_monocrop "HH grows `cn_full' on a monocropped plot"
	save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_`cn'_monocrop.dta", replace

save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_monocrop_plots.dta", replace
	
		foreach i in `cn'_monocrop_ha kgs_harv_mono_`cn' val_harv_mono_`cn' { 
		gen `i'_male = `i' if dm_gender==1
		gen `i'_female = `i' if dm_gender==2
		gen `i'_mixed = `i' if dm_gender==3 //MGM MWI may not be creating dm_gender==3 for mixed right now. Do we want to add this?
	}
	
	la var `cn'_monocrop_ha "Total `cn' monocrop hectares - Household"
	la var `cn'_monocrop "Household has at least one `cn' monocrop"
	la var kgs_harv_mono_`cn' "Total kilograms of `cn' harvested - Household"
	la var val_harv_mono_`cn' "Value of harvested `cn' (Kwacha)"
	foreach g in male female mixed {		
		la var `cn'_monocrop_ha_`g' "Total `cn' monocrop hectares on `g' managed plots - Household"
		la var kgs_harv_mono_`cn'_`g' "Total kilograms of `cn' harvested on `g' managed plots - Household"
		la var val_harv_mono_`cn'_`g' "Total value of `cn' harvested on `g' managed plots - Household"
	}
	collapse (sum) *monocrop* kgs_harv* val_harv*, by(case_id)
	save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_`cn'_monocrop_hh_area.dta", replace
restore
}

use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_cost_inputs_long.dta", clear
foreach cn in $topcropname_area {
preserve
	keep if strmatch(exp, "exp")
	drop exp
	levelsof input, clean l(input_names)
	ren val val_
	reshape wide val_, i(case_id plot_id dm_gender) j(input) string
	ren val* val*_`cn'_
	gen dm_gender2 = "male" if dm_gender==1
	replace dm_gender2 = "female" if dm_gender==2
	replace dm_gender2 = "mixed" if dm_gender==3
	drop dm_gender
	reshape wide val*, i(case_id plot_id) j(dm_gender2) string
	merge 1:1 case_id plot_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_`cn'_monocrop.dta", nogen keep(3)
	collapse (sum) val*, by(case_id)
	foreach i in `input_names' {
		egen val_`i'_`cn'_hh = rowtotal(val_`i'_`cn'_male val_`i'_`cn'_female val_`i'_`cn'_mixed)
	}
	//To do: labels
	save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_inputs_`cn'.dta", replace
restore
}
*/
********************************************************************************
* TLU (Tropical Livestock Units) *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_r1.dta", clear
gen tlu_coefficient=0.5 if (ag_r0a==301|ag_r0a==302|ag_r0a==303|ag_r0a==304|ag_r0a==306)
replace tlu_coefficient=0.1 if (ag_r0a==307|ag_r0a==308)
replace tlu_coefficient=0.2 if (ag_r0a==309)
replace tlu_coefficient=0.01 if (ag_r0a==310|ag_r0a==311|ag_r0a==312|ag_r0a==313|ag_r0a==314|ag_r0a==315|ag_r0a==316)
replace tlu_coefficient=0.3 if (ag_r0a==305) 
lab var tlu_coefficient "Tropical Livestock Unit coefficient"

*Owned
gen cattle=inrange(ag_r0a,301,304)
gen smallrum=inlist(ag_r0a,307,308,309)
gen poultry=inrange(ag_r0a,310,316)
gen other_ls=inlist(ag_r0a,305,306)
gen cows=inrange(ag_r0a,303,303)
gen chickens=inrange(ag_r0a,310,313) //MMH 6.8.19: included chicken layer (310), local hen (311), chicken broiler (312), local cock (313)
ren ag_r07 nb_ls_1yearago
gen nb_cattle_1yearago=nb_ls_1yearago if cattle==1 
gen nb_smallrum_1yearago=nb_ls_1yearago if smallrum==1 
gen nb_poultry_1yearago=nb_ls_1yearago if poultry==1 
gen nb_other_ls_1yearago=nb_ls_1yearago if other_ls==1 
gen nb_cows_1yearago=nb_ls_1yearago if cows==1 
gen nb_chickens_1yearago=nb_ls_1yearago if chickens==1 
ren ag_r02 nb_ls_today
gen nb_cattle_today=nb_ls_today if cattle==1 
gen nb_smallrum_today=nb_ls_today if smallrum==1 
gen nb_poultry_today=nb_ls_today if poultry==1 
gen nb_other_ls_today=nb_ls_today if other_ls==1  
gen nb_cows_today=nb_ls_today if cows==1 
gen nb_chickens_today=nb_ls_today if chickens==1 
gen tlu_1yearago = nb_ls_1yearago * tlu_coefficient
gen tlu_today = nb_ls_today * tlu_coefficient
rename ag_r17 income_live_sales 
rename ag_r16 number_sold 
*Lots of things are valued in between here, but it isn't a complete story.
*So livestock holdings will be valued using observed sales prices.
ren ag_r0a livestock_code
recode tlu_* nb_* (.=0)
collapse (sum) tlu_* nb_*  , by (case_id)
lab var nb_cattle_1yearago "Number of cattle owned as of 12 months ago"
lab var nb_smallrum_1yearago "Number of small ruminant owned as of 12 months ago"
lab var nb_poultry_1yearago "Number of cattle poultry as of 12 months ago"
lab var nb_other_ls_1yearago "Number of other livestock (dog, donkey, and other) owned as of 12 months ago"
lab var nb_cows_1yearago "Number of cows owned as of 12 months ago"
lab var nb_chickens_1yearago "Number of chickens owned as of 12 months ago"
lab var nb_cattle_today "Number of cattle owned as of the time of survey"
lab var nb_smallrum_today "Number of small ruminant owned as of the time of survey"
lab var nb_poultry_today "Number of cattle poultry as of the time of survey"
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
save "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_TLU_Coefficients.dta", replace

/*MGM 5.1.23 commenting out for now, not running
********************************************************************************
* GROSS CROP REVENUE *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_g.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_m.dta", gen(dry)
gen crop_code=.
replace crop_code=1 if ag_g0d == 1 | ag_g0d == 2 | ag_g0d == 3 | ag_g0d == 4 | ag_m0d == 1 | ag_m0d == 2 | ag_m0d == 3 | ag_m0d == 4 
replace crop_code=2 if ag_g0d == 5 | ag_g0d == 6 | ag_g0d == 7 | ag_g0d == 8 | ag_g0d == 9 | ag_g0d == 10 | ag_m0d == 6
replace crop_code=3 if ag_g0d == 11 | ag_g0d == 12 | ag_g0d == 13 | ag_g0d == 14 | ag_g0d == 15 | ag_g0d == 16 
replace crop_code=4 if ag_g0d == 17 | ag_g0d == 18 | ag_g0d == 19 | ag_g0d == 20 | ag_g0d == 21 | ag_g0d == 22 | ag_g0d == 23 | ag_g0d == 25 | ag_g0d == 26 | ag_m0d == 17 | ag_m0d == 19 | ag_m0d == 20 | ag_m0d == 21 | ag_m0d == 23
replace crop_code=5 if ag_g0d == 27
replace crop_code=6 if ag_g0d == 28 | ag_m0d == 28
replace crop_code=7 if ag_g0d == 29 | ag_m0d == 29
replace crop_code=8 if ag_g0d == 30 | ag_m0d == 30
replace crop_code=9 if ag_g0d == 31
replace crop_code=10 if ag_g0d == 32
replace crop_code=11 if ag_g0d == 33
replace crop_code=12 if ag_g0d == 34 | ag_m0d == 34
replace crop_code=13 if ag_g0d == 35
replace crop_code=14 if ag_g0d == 36 | ag_m0d == 36
replace crop_code=15 if ag_g0d == 37
replace crop_code=16 if ag_g0d == 38
replace crop_code=17 if ag_g0d == 39 | ag_m0d == 39
replace crop_code=18 if ag_m0d == 40
replace crop_code=19 if ag_g0d == 41 | ag_m0d == 41
replace crop_code=20 if ag_g0d == 42 | ag_m0d == 42
replace crop_code=21 if ag_g0d == 43 | ag_m0d == 43
replace crop_code=22 if ag_g0d == 44 | ag_m0d == 44
replace crop_code=23 if ag_g0d == 45 | ag_m0d == 45
replace crop_code=24 if ag_g0d == 46 | ag_m0d == 46 //MMH 5.21.19: Not treating "peas" as "cowpeas" 
replace crop_code=25 if ag_g0d == 47 | ag_m0d == 47
replace crop_code=26 if ag_g0d == 48 | ag_m0d == 48
la def crop_code 1 "Maize" 2 "Tobacco" 3 "Groundnut" 4 "Rice" 5 "Ground Bean" 6 "Sweet Potato" 7 "Irish (Malawi) Potato" 8 "Wheat" 9 "Finger Millet" 10 "Sorghum" 11 "Pearl Millet" 12 "Beans" 13 "Soyabean" 14 "Pigeon Pea" /*
*/ 15 "Cotton" 16 "Sunflower" 17 "Sugar Cane" 18 "Cabbage" 19 "Tanaposi" 20 "Nkhwani" 21 "Okra" 22 "Tomato" 23 "Onion" 24 "Pea" 25 "Paprika" 26 "Other"
la val crop_code crop_code
lab var crop_code "Crop Code" 

*Rename variables so they match in merged files
ren ag_g0b plot_id
ren ag_g0d crop_code_full
replace crop_code_full = ag_m0d if crop_code_full==.
ren ag_g13b unit 
replace unit = ag_g09b if unit==. 
replace unit = ag_m11b if unit==.
ren ag_g13c condition
replace condition = ag_g09c if condition==. 
replace condition = ag_m11c if condition==.

*Merge in region from hhids file and conversion factors
merge m:1 case_id using  "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta", nogen keep(1 3)	
merge m:1 region crop_code_full unit condition using  "${Malawi_IHS_W1_created_data}/MLW_W1_cf.dta"

*Temporary crops (both seasons)
gen harvest_yesno=.
replace harvest_yesno = 1 if ag_g13a > 0 & ag_g13a !=. 
replace harvest_yesno = 2 if ag_g13a == 0
gen kgs_harvest = ag_g13a*conversion if crop_code==`c'
replace kgs_harvest = ag_m11a*conversion if crop_code==`c' & kgs_harvest==.
//rename ag4a_29 value_harvest							MMH 6.10.19: not possible to construct value_harvest, used value_sold below instead
//replace value_harvest = ag4b_29 if value_harvest==.
replace kgs_harvest = 0 if harvest_yesno==2
//replace value_harvest = 0 if harvest_yesno==2
collapse (sum) kgs_harvest /*value_harvest*/, by (case_id crop_code plot_id)
lab var kgs_harvest "Kgs harvested of this crop, summed over main and short season"
//lab var value_harvest "Value harvested of this crop, summed over main and short season"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_tempcrop_harvest.dta", replace

use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_i.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_o.dta", gen(dry)
gen crop_code=.
replace crop_code=1 if ag_i0b == 1 | ag_i0b == 2 | ag_i0b == 3 | ag_i0b == 4 | ag_o0b == 1 | ag_o0b == 2 | ag_o0b == 3 | ag_o0b == 4 
replace crop_code=2 if ag_i0b == 5 | ag_i0b == 6 | ag_i0b == 7 | ag_i0b == 8 | ag_i0b == 9 | ag_i0b == 10 | ag_o0b == 5 | ag_o0b == 6 | ag_o0b == 7 | ag_o0b == 8 | ag_o0b == 9 | ag_o0b == 10
replace crop_code=3 if ag_i0b == 11 | ag_i0b == 12 | ag_i0b == 13 | ag_i0b == 14 | ag_i0b == 15 | ag_i0b == 16 | ag_o0b == 11 | ag_o0b == 12 | ag_o0b == 13 | ag_o0b == 14 | ag_o0b == 15 | ag_o0b == 16 
replace crop_code=4 if ag_i0b == 17 | ag_i0b == 18 | ag_i0b == 19 | ag_i0b == 20 | ag_i0b == 21 | ag_i0b == 22 | ag_i0b == 23 | ag_i0b == 25 | ag_i0b == 26 | ag_o0b == 17 | ag_o0b == 18 | ag_o0b == 19/*
*/ | ag_o0b == 20 | ag_o0b == 21 | ag_o0b == 22 | ag_o0b == 23 | ag_o0b == 25 | ag_o0b == 26
replace crop_code=5 if ag_i0b == 27 | ag_o0b == 27
replace crop_code=6 if ag_i0b == 28 | ag_o0b == 28
replace crop_code=7 if ag_i0b == 29 | ag_o0b == 29
replace crop_code=8 if ag_i0b == 30 | ag_o0b == 30
replace crop_code=9 if ag_i0b == 31 | ag_o0b == 31
replace crop_code=10 if ag_i0b == 32 | ag_o0b == 32
replace crop_code=11 if ag_i0b == 33 | ag_o0b == 33
replace crop_code=12 if ag_i0b == 34 | ag_o0b == 34
replace crop_code=13 if ag_i0b == 35 | ag_o0b == 35
replace crop_code=14 if ag_i0b == 36 | ag_o0b == 36
replace crop_code=15 if ag_i0b == 37 | ag_o0b == 37
replace crop_code=16 if ag_i0b == 38 | ag_o0b == 38
replace crop_code=17 if ag_i0b == 39 | ag_o0b == 39
replace crop_code=18 if ag_i0b == 40 | ag_o0b == 40
replace crop_code=19 if ag_i0b == 41 | ag_o0b == 41
replace crop_code=20 if ag_i0b == 42 | ag_o0b == 42
replace crop_code=21 if ag_i0b == 43 | ag_o0b == 43
replace crop_code=22 if ag_i0b == 44 | ag_o0b == 44
replace crop_code=23 if ag_i0b == 45 | ag_o0b == 45
replace crop_code=24 if ag_i0b == 46 | ag_o0b == 46 //MMH 5.21.19: Not treating "peas" as "cowpeas" 
replace crop_code=25 if ag_i0b == 47 | ag_o0b == 47
replace crop_code=26 if ag_i0b == 48 | ag_o0b == 48
la def crop_code 1 "Maize" 2 "Tobacco" 3 "Groundnut" 4 "Rice" 5 "Ground Bean" 6 "Sweet Potato" 7 "Irish (Malawi) Potato" 8 "Wheat" 9 "Finger Millet" 10 "Sorghum" 11 "Pearl Millet" 12 "Beans" 13 "Soyabean" 14 "Pigeon Pea" /*
*/ 15 "Cotton" 16 "Sunflower" 17 "Sugar Cane" 18 "Cabbage" 19 "Tanaposi" 20 "Nkhwani" 21 "Okra" 22 "Tomato" 23 "Onion" 24 "Pea" 25 "Paprika" 26 "Other"
la val crop_code crop_code
lab var crop_code "Crop Code" 

*Rename variables so they match in merged files
ren ag_i0b crop_code_full
replace crop_code_full = ag_o0b if crop_code_full==.
ren ag_i02b unit 
replace unit = ag_o02b if unit==. 
ren ag_i02c condition
replace condition = ag_o02c if condition==.

*Merge in region from hhids file and conversion factors
merge m:1 case_id using  "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta", nogen keep(1 3)	
merge m:1 region crop_code_full unit condition using  "${Malawi_IHS_W1_created_data}\MLW_W1_cf.dta"

*Temporary crop sales 
drop if crop_code_full==.
rename ag_i01 sell_yesno
replace sell_yesno = ag_o01 if sell_yesno==.
**# Bookmark #1
gen quantity_sold = ag_i02a*conversion                            //ALT 10.14.19 - Module i = rainy season crop sales / module o = dry season crop sales
replace quantity_sold = ag_o02a*conversion if quantity_sold==.
rename ag_i03 value_sold
replace value_sold = ag_o03 if value_sold==.
keep if sell_yesno==1
collapse (sum) quantity_sold value_sold, by (case_id crop_code)
lab var quantity_sold "Kgs sold of this crop, summed over main and short season"
lab var value_sold "Value sold of this crop, summed over main and short season"
gen price_kg = value_sold / quantity_sold
lab var price_kg "Price per kg sold"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_tempcrop_sales.dta", replace

*Permanent and tree crops
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_p.dta", clear
drop if ag_p0b==""
rename ag_p0d crop_code
replace crop_code = 100 if crop_code == 1 //MMH 6.20.19: renamed crop code labels because overlapping with temporary crop codes
replace crop_code = 200 if crop_code == 2
replace crop_code = 300 if crop_code == 3
replace crop_code = 400 if crop_code == 4
replace crop_code = 500 if crop_code == 5
replace crop_code = 600 if crop_code == 6
replace crop_code = 700 if crop_code == 7
replace crop_code = 800 if crop_code == 8
replace crop_code = 900 if crop_code == 9
replace crop_code = 1000 if crop_code == 10
replace crop_code = 1100 if crop_code == 11
replace crop_code = 1200 if crop_code == 12
replace crop_code = 1300 if crop_code == 13
replace crop_code = 1400 if crop_code == 14
replace crop_code = 1500 if crop_code == 15
replace crop_code = 1600 if crop_code == 16
replace crop_code = 1700 if crop_code == 17
replace crop_code = 1800 if crop_code == 18
la def crop_code 100 "Cassava" 200 "Tea" 300 "Coffee" 400 "Mango" 500 "Orange" 600 "Papaya" 700 "Banana" 800 "Avocado" 900 "Guava" 1000 "Lemon" 1100 "Tangerine" 1200 "Peach" 1300 "Custade Apple (Poza)" 1400 "Mexican Apple (Masuku)" /*
*/ 1500 "Masau" 1600 "Pineapple" 1700 "Macademia" 1800 "Other" 

gen kgs_harvest = ag_p09a/**conversion */ //MMH 6.10.19: no permanent and tree crop conversion file, checked with Ayala and she doesn't have either (see 6/11/2019 email with Emma, Anu, Veda, Didier etc for her ideas of how to proceed)
rename ag_p0b plot_id
collapse (sum) kgs_harvest, by (case_id crop_code plot_id)
lab var kgs_harvest "Kgs harvested of this crop, summed over main and short season"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_permcrop_harvest.dta", replace

use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_q.dta", clear
drop if ag_q0b==.
rename ag_q0b crop_code
replace crop_code = 100 if crop_code == 1 //MMH 6.20.19: renamed crop code labels because overlapping with temporary crop codes
replace crop_code = 200 if crop_code == 2
replace crop_code = 300 if crop_code == 3
replace crop_code = 400 if crop_code == 4
replace crop_code = 500 if crop_code == 5
replace crop_code = 600 if crop_code == 6
replace crop_code = 700 if crop_code == 7
replace crop_code = 800 if crop_code == 8
replace crop_code = 900 if crop_code == 9
replace crop_code = 1000 if crop_code == 10
replace crop_code = 1100 if crop_code == 11
replace crop_code = 1200 if crop_code == 12
replace crop_code = 1300 if crop_code == 13
replace crop_code = 1400 if crop_code == 14
replace crop_code = 1500 if crop_code == 15
replace crop_code = 1600 if crop_code == 16
replace crop_code = 1700 if crop_code == 17
replace crop_code = 1800 if crop_code == 18
la def crop_code 100 "Cassava" 200 "Tea" 300 "Coffee" 400 "Mango" 500 "Orange" 600 "Papaya" 700 "Banana" 800 "Avocado" 900 "Guava" 1000 "Lemon" 1100 "Tangerine" 1200 "Peach" 1300 "Custade Apple (Poza)" 1400 "Mexican Apple (Masuku)" /*
*/ 1500 "Masau" 1600 "Pineapple" 1700 "Macademia" 1800 "Other" 

rename ag_q01 sell_yesno
gen quantity_sold = ag_q02a/**conversion */ //MMH 6.10.19: no permanent and tree crop conversion file, checked with Ayala and she doesn't have either (see 6/11/2019 email with Emma, Anu, Veda, Didier etc for her ideas of how to proceed)
rename ag_q03 value_sold
keep if sell_yesno==1
recode quantity_sold value_sold (.=0)
collapse (sum) quantity_sold value_sold, by (case_id crop_code)
lab var quantity_sold "Kgs sold of this crop, summed over main and short season"
lab var value_sold "Value sold of this crop, summed over main and short season"
gen price_kg = value_sold / quantity_sold
lab var price_kg "Price per kg sold"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_permcrop_sales.dta", replace

*Prices of permanent and tree crops need to be imputed from sales.
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_permcrop_sales.dta", clear
append using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_tempcrop_sales.dta"
recode price_kg (0=.)
merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta"
drop if _merge==2
drop _merge
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_sales.dta", replace

use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_sales.dta", clear
gen observation = 1
bys region district ta ea crop_code: egen obs_ea = count(observation)

collapse (median) price_kg [aw=weight], by (region district ta ea crop_code obs_ea)
rename price_kg price_kg_median_ea
lab var price_kg_median_ea "Median price per kg for this crop in the enumeration area"
lab var obs_ea "Number of sales observations for this crop in the enumeration area"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_ea.dta", replace
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_sales.dta", clear
gen observation = 1
bys region district ta crop_code: egen obs_ta = count(observation)
collapse (median) price_kg [aw=weight], by (region district ta crop_code obs_ta)
rename price_kg price_kg_median_ta
lab var price_kg_median_ta "Median price per kg for this crop in the ta"
lab var obs_ta "Number of sales observations for this crop in the ta"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_ta.dta", replace
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_sales.dta", clear
gen observation = 1
bys region district crop_code: egen obs_district = count(observation) 
collapse (median) price_kg [aw=weight], by (region district crop_code obs_district)
rename price_kg price_kg_median_district
lab var price_kg_median_district "Median price per kg for this crop in the district"
lab var obs_district "Number of sales observations for this crop in the district"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_district.dta", replace
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_sales.dta", clear
gen observation = 1
bys region crop_code: egen obs_region = count(observation)
collapse (median) price_kg [aw=weight], by (region crop_code obs_region)
rename price_kg price_kg_median_region
lab var price_kg_median_region "Median price per kg for this crop in the region"
lab var obs_region "Number of sales observations for this crop in the region"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_region.dta", replace
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_sales.dta", clear
gen observation = 1
bys crop_code: egen obs_country = count(observation)
collapse (median) price_kg [aw=weight], by (crop_code obs_country)
rename price_kg price_kg_median_country
lab var price_kg_median_country "Median price per kg for this crop in the country"
lab var obs_country "Number of sales observations for this crop in the country"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_country.dta", replace

*Pull prices into harvest estimates
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_tempcrop_harvest.dta", clear
append using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_permcrop_harvest.dta"
merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta"
drop if _merge==2
drop _merge
merge m:1 hhid crop_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_sales.dta"   
drop _merge
merge m:1 region district ta ea crop_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_ea.dta"
drop _merge
merge m:1 region district ta crop_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_ta.dta"
drop _merge
merge m:1 region district crop_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_district.dta"
drop _merge
merge m:1 region crop_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_region.dta"
drop _merge
merge m:1 crop_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_country.dta"
drop _merge
gen price_kg_hh = price_kg
lab var price_kg_hh "Price per kg, with missing values imputed using local median values"
replace price_kg = price_kg_median_ea if price_kg==. & obs_ea >= 10 & crop_code!=26 & crop_code!=1800 /* Don't impute prices for "other" permanent or temporary crops */
replace price_kg = price_kg_median_ta if price_kg==. & obs_ta >= 10 & crop_code!=26 & crop_code!=1800 
replace price_kg = price_kg_median_district if price_kg==. & obs_district >= 10 & crop_code!=26 & crop_code!=1800
replace price_kg = price_kg_median_region if price_kg==. & obs_region >= 10 & crop_code!=26 & crop_code!=1800
replace price_kg = price_kg_median_country if price_kg==. & crop_code!=26 & crop_code!=1800
lab var price_kg "Price per kg, with missing values imputed using local median values"

//MMH 6.21.19: Following Emma's comment from Uganda W1
//EFW 5.2.19 Since we don't have value harvest for this instrument computing value harvest as price_kg * kgs_harvest for everything. This is what was done in Ethiopia baseline
gen value_harvest_imputed = kgs_harvest * price_kg_hh if price_kg_hh!=.  //MMH 6.21.19 This instrument doesn't ask about value harvest, just value sold. 
replace value_harvest_imputed = kgs_harvest * price_kg if value_harvest_imputed==.
replace value_harvest_imputed = 0 if value_harvest_imputed==.
lab var value_harvest_imputed "Imputed value of crop production"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_values_tempfile.dta", replace 

preserve 		
recode  value_harvest_imputed value_sold kgs_harvest quantity_sold (.=0)
collapse (sum) value_harvest_imputed value_sold kgs_harvest quantity_sold , by (case_id crop_code)
ren value_harvest_imputed value_crop_production
lab var value_crop_production "Gross value of crop production, summed over main and short season"
rename value_sold value_crop_sales
lab var value_crop_sales "Value of crops sold so far, summed over main and short season"
lab var kgs_harvest "Kgs harvested of this crop, summed over main and short season"
ren quantity_sold kgs_sold
lab var kgs_sold "Kgs sold of this crop, summed over main and short season"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_crop_values_production.dta", replace
restore
*The file above will be used is the estimation intermediate variables : Gross value of crop production, Total value of crop sold, Total quantity harvested,  

collapse (sum) value_harvest_imputed value_sold, by (case_id)
replace value_harvest_imputed = value_sold if value_sold>value_harvest_imputed & value_sold!=. & value_harvest_imputed!=. /* In a few cases, the kgs sold exceeds the kgs harvested */
rename value_harvest_imputed value_crop_production
lab var value_crop_production "Gross value of crop production for this household"
*This is estimated using household value estimated for temporary crop production plus observed sales prices for permanent/tree crops.
*Prices are imputed using local median values when there are no sales.
rename value_sold value_crop_sales
lab var value_crop_sales "Value of crops sold so far"
gen proportion_cropvalue_sold = value_crop_sales / value_crop_production
lab var proportion_cropvalue_sold "Proportion of crop value produced that has been sold"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_crop_production.dta", replace
 
*Plot value of crop production
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_values_tempfile.dta", clear
collapse (sum) value_harvest_imputed, by (case_id plot_id)
rename value_harvest_imputed plot_value_harvest
lab var plot_value_harvest "Value of crop harvest on this plot"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_cropvalue.dta", replace

*Crop residues (captured only in Tanzania) 		//MMH 6.21.19: Malawi W1 doesn't ask about crop residues

*Crop values for inputs in agricultural product processing (self-employment)
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_tempcrop_harvest.dta", clear
append using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_permcrop_harvest.dta"
merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta", nogen keep(1 3)
merge m:1 case_id crop_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_sales.dta", nogen
merge m:1 region district ta ea crop_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_ea.dta", nogen
merge m:1 region district ta crop_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_ta.dta", nogen
merge m:1 region district crop_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_district.dta", nogen
merge m:1 region crop_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_region.dta", nogen
merge m:1 crop_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crop_prices_country.dta", nogen
replace price_kg = price_kg_median_ea if price_kg==. & obs_ea >= 10 & crop_code!=998 /* Don't impute prices for "other" crops */
replace price_kg = price_kg_median_ta if price_kg==. & obs_ta >= 10 & crop_code!=998
replace price_kg = price_kg_median_district if price_kg==. & obs_district >= 10 & crop_code!=998
replace price_kg = price_kg_median_region if price_kg==. & obs_region >= 10 & crop_code!=998
replace price_kg = price_kg_median_country if price_kg==. & crop_code!=998 
lab var price_kg "Price per kg, with missing values imputed using local median values"

gen value_harvest_imputed = kgs_harvest * price_kg if price_kg!=.  //MMH 6.21.19 This instrument doesn't ask about value harvest, just value sold. 
replace value_harvest_imputed = kgs_harvest * price_kg if value_harvest_imputed==.
replace value_harvest_imputed = 0 if value_harvest_imputed==.
keep case_id crop_code price_kg 
duplicates drop
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_crop_prices.dta", replace

*Crops lost post-harvest - MMH 7.19.19: can't construct for Malawi because no Q about value of lost crop (only about qty)
/*use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_p.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_q.dta"
drop if ag_p0d==.
rename ag_p0d crop_code
rename ag7a_16 value_lost
replace value_lost = ag7b_16 if value_lost==.
replace value_lost = ag5a_32 if value_lost==.
replace value_lost = ag5b_32 if value_lost==.
recode value_lost (.=0)
collapse (sum) value_lost, by (y4_hhid crop_code)
merge 1:1 y4_hhid crop_code using "${TZA_W4_created_data}\Tanzania_NPS_LSMS_ISA_W4_hh_crop_values_production.dta"
drop if _merge==2
replace value_lost = value_crop_production if value_lost > value_crop_production
collapse (sum) value_lost, by (y4_hhid)
rename value_lost crop_value_lost
lab var crop_value_lost "Value of crop production that had been lost by the time of survey"
save "${TZA_W4_created_data}\Tanzania_NPS_LSMS_ISA_W4_crop_losses.dta", replace*/

**MMH 8.2.2019: Finished up through here but nothing above has been checked yet. The next coder should begin by checking what I've done so far and then start with Crop Expenses. 

**ALT 10.11.2019: Starting on crop expenses by grabbing code from TZ wave 4
**Also 10.11.2019: Start of IHS priority indicators
*/

********************************************************************************
* CROP EXPENSES *
********************************************************************************
//MGM: 03.16.23: NGA W3 is reference code
//New file structure for crop expenses created by ALT 05.07.21 (transformed into what we need for the rest of the code to run using reshape wide) | hhid | plotid | dm_gender | season | labor type | worker gender | days worked | price of labor | value of labor |
//This cuts down 400+ lines into ~100 lines and saves repetition of labor variables elsewhere.
//ALT 05.07.21: Now new module for all crop expenses.

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
	*Crop payments rainy
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_d.dta", clear 
	ren ag_d00 plot_id
	ren ea_id ea
	ren ag_d46g crop_code
	ren ag_d46h qty
	ren ag_d46i unit
	ren ag_d46j condition
	keep case_id plot_id ea crop_code qty unit condition
	gen season="rainy"
tempfile rainy_crop_payments
save `rainy_crop_payments'
	
	*Crop payments dry
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_k.dta", clear 
	ren ag_k0a plot_id
	ren ea_id ea
	ren ag_k46g crop_code
	ren ag_k46h qty
	ren ag_k46i unit
	ren ag_k46j condition
	keep case_id plot_id ea crop_code qty unit condition
	gen season="dry"
tempfile dry_crop_payments
save `dry_crop_payments'

//Not including in-kind payments as part of wages b/c they are not disaggregated by worker gender (but including them as an explicit expense at the end of the labor section)
	use `rainy_crop_payments'
	append using `dry_crop_payments'
	merge m:1 case_id crop_code unit using "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_hh_crop_prices_for_wages.dta", nogen keep (1 3) //316 matched; hh_price_mean in using data set seems high
	recode qty hh_price_mean (.=0)
	gen val = qty*hh_price_mean
	keep case_id val plot_id
	gen exp = "exp"
	merge m:1 plot_id case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_decision_makers.dta", nogen keep (1 3) keepusing(dm_gender)
	tempfile inkind_payments
	save `inkind_payments'

	*Hired rainy
/*MGM 6.16.23 This code creates three temporary files for exchange labor in the rainy season: rainy_hired_all, rainy_hired_nonharvest, and rainy_hired_harvest. Will append nonharvest and harvest to compare to all.*/
local qnums "46 47 48" //qnums refer to question numbers on instrument
foreach q in `qnums' {
    use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_d.dta", clear
	ren ag_d00 plot_id
    ren ea_id ea
	merge m:1 case_id ea using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta", nogen
	ren ag_d`q'a dayshiredmale
	ren ag_d`q'c dayshiredfemale
	ren ag_d`q'e dayshiredchild
	ren ag_d`q'b wagehiredmale
	ren ag_d`q'd wagehiredfemale
	ren ag_d`q'f wagehiredchild
	keep region stratum district ta ea rural case_id plot_id *hired*
	gen season="rainy"
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

/*
//MGM 6.16.23 EXPERIMENTAL CODE
	use `rainy_hired_all', clear
	append using `rainy_hired_nonharvest'
	append using `rainy_hired_harvest'
	preserve
	collapse (mean) dayshired* wagehired*, by (period)
	restore
	preserve
	collapse (min) dayshired* wagehired*, by (period)
	restore
	preserve
	collapse (max) dayshired* wagehired*, by (period)
	restore
	
	/*MGM 6.30.23 EXPLORE IF DAILY WAGES ARE REPORTED PER PERSON OR PER ALL LABORERS*/
	scatter wagehiredchild dayshiredchild, title("Hired Child Labor - Days and Wage") msize(.5pt) xtitle("Days") ytitle("Wage")
	scatter wagehiredfemale dayshiredfemale, title("Hired Female Labor - Days and Wage") msize(.5pt) xtitle("Days") ytitle("Wage")
	scatter wagehiredmale dayshiredmale, title("Hired Male Labor - Days and Wage") msize(.5pt) xtitle("Days") ytitle("Wage")
	/*MGM 7.10.23 The Malawi W1 instrument did not ask survey respondents to report number of laborers per day by laborer type. As such, we cannot say with certainty whether survey respondents reported wages paid as [per SINGLE hired laborer by laborer type (male, female, child) per day] or [per ALL hired laborers by laborer type (male, female, child) per day]. Looking at the collapses and scatterplots, it would seem that survey respondents had mixed interpretations of the question, making the value of hired labor more difficult to interpret.*/
	
	/*MGM 6.16.23 EXPERIMENTAL CODE TO COMPARE ALL TO NONHARVEST+HARVEST*/
	gen tot_wage_male=dayshiredmale*wagehiredmale
	gen tot_wage_female=dayshiredfemale*wagehiredfemale
	gen tot_wage_child=dayshiredchild*wagehiredchild
	collapse (sum) tot_wage* wagehired* dayshired*, by (period)
	gen daily_wage_male = tot_wage_male/dayshiredmale
	gen daily_wage_female = tot_wage_female/dayshiredfemale
	gen daily_wage_child = tot_wage_child/dayshiredchild
	restore
	preserve
	collapse (sum) dayshired* wagehired*, by (period gender)
	restore
*/

	*Hired dry
	//MGM: Unlike the rainy season, the survey instrument does not delineate between all, non-harvest, and harvest for hired labor during the dry season, hence no loop needed
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_k.dta", clear 
	ren ag_k0a plot_id
	ren ea_id ea
	merge m:1 case_id ea using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta", nogen
	ren ag_k46a dayshiredmale
	ren ag_k46c dayshiredfemale
	ren ag_k46e dayshiredchild
	ren ag_k46b wagehiredmale
	ren ag_k46d wagehiredfemale
	ren ag_k46f wagehiredchild
	keep region stratum district ta ea rural case_id plot_id *hired* 
	gen season="dry"
tempfile dry_hired_all
save `dry_hired_all' 

	use `rainy_hired_all'
	append using `dry_hired_all'
//duplicates report region stratum district ta ea case_id plot_id season
//duplicates tag region stratum district ta ea case_id plot_id season, gen(dups)
//br if dups>0
* HKS: Duplicates dropped here (8 obs) are apparently repeat entries for W1.

	duplicates drop region stratum district ta ea case_id plot_id season, force
	reshape long dayshired wagehired, i(region stratum district ta ea case_id plot_id season) j(gender) string //fix zone state etc.
	reshape long days wage, i(region stratum district ta ea case_id plot_id gender season) j(labor_type) string
	recode wage days /*number inkind*/ (.=0) //no number on MWI
	drop if wage==0 & days==0 /*& number==0 & inkind==0*/ //105,990 observations deleted
	//replace wage = wage/number //ALT 08.16.21: The question is "How much did you pay in total per day to the hired <laborers>." For getting median wages for implicit values, we need the wage/person/day //MGM 5.31.23 given that there is no number is this command necessary?
	gen val = wage*days
	/*MGM 7.10.23 The Malawi W1 instrument did not ask survey respondents to report number of laborers per day by laborer type. As such, we cannot say with certainty whether survey respondents reported wages paid as [per SINGLE hired laborer by laborer type (male, female, child) per day] or [per ALL hired laborers by laborer type (male, female, child) per day]. Looking at the collapses and scatterplots, it would seem that survey respondents had mixed interpretations of the question, making the value of hired labor more difficult to interpret.*/
	
	merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_weights.dta", nogen keep (1 3) keepusing(weight)
	merge m:1 case_id plot_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_areas.dta", nogen keep (1 3) keepusing(area_meas_hectares)
	gen plotweight=weight*area_meas_hectares //MGM 5.31.23 NGA W3 uses field_size. Is area_meas_hectares the equivalent variable instead of area_est_hectares?
	recode wage (0=.) //180 changes made
	gen obs=wage!=.

	*Median wages
foreach i in region stratum district ta ea rural case_id {
preserve
	bys `i' season gender : egen obs_`i' = sum(obs)
	collapse (median) wage_`i'=wage [aw=plotweight], by (`i' season gender obs_`i')
	tempfile wage_`i'_median
	save `wage_`i'_median'
restore
}
preserve
collapse (median) wage_country = wage (sum) obs_country=obs [aw=plotweight], by(season gender)
tempfile wage_country_median
save `wage_country_median'
restore

drop obs plotweight wage 
tempfile all_hired
save `all_hired'

	*Exchange rainy
/*MGM 5.31.23 This code creates three temporary files for exchange labor in the rainy season: rainy_exchange_all, rainy_exchange_nonharvest, and rainy_exchange_harvest. Will append nonharvest and harvest to compare to all.*/
local qnums "50 52 54" //question numbers
foreach q in `qnums' {
    use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_d.dta", clear
	ren ag_d00 plot_id
    ren ea_id ea
	merge m:1 case_id ea using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta", nogen
	ren ag_d`q'a daysnonhiredmale
	ren ag_d`q'b daysnonhiredfemale
	ren ag_d`q'c daysnonhiredchild
	keep region stratum district ta ea rural case_id plot_id daysnonhired*
	gen season="rainy"
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
	duplicates drop  region stratum district ta ea rural case_id plot_id season, force //1 duplicate deleted
	reshape long daysnonhired, i(region stratum district ta ea rural case_id plot_id season) j(gender) string
	//reshape long days, i(region stratum district ta ea rural case_id plot_id season gender) j(labor_type) string
    tempfile rainy_exchange`suffix'
    save `rainy_exchange`suffix'', replace
}

//MGM 6.13.23 EXPERIMENTAL CODE - spent some time looking at whether nonharvest+harvest roughly equates to all
//use `rainy_exchange_all', clear
//append using `rainy_exchange_nonharvest'
//append using `rainy_exchange_harvest'
	
	*Exchange dry
    use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_k.dta", clear
	ren ag_k0a plot_id
    ren ea_id ea
	merge m:1 case_id ea using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta", nogen
	ren ag_k47a daysnonhiredmale
	ren ag_k47b daysnonhiredfemale
	ren ag_k47c daysnonhiredchild
	keep region stratum district ta ea rural case_id plot_id daysnonhired*
	gen season="dry"
	duplicates drop  region stratum district ta ea rural case_id plot_id season, force //3 duplicates deleted
	reshape long daysnonhired, i(region stratum district ta ea rural case_id plot_id season) j(gender) string
	tempfile dry_exchange_all //MGM 6.13.23: Question for @ALT - survey instrument only asks about non-harvest activities. Can this suffice for all? Guessing there is no harvest in dry season anyway.
    save `dry_exchange_all', replace
	append using `rainy_exchange_all'
	reshape long days, i(region stratum district ta ea rural case_id plot_id season gender) j(labor_type) string
	tempfile all_exchange
	save `all_exchange', replace

//creates tempfile `members' to merge with household labor later
use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_b.dta", clear
ren hh_b01 pid
isid case_id pid
gen male= (hh_b03==1) //MGM 6.13.23: Question for @ALT - reference created male variable. Should we create female instead? Seems more consistent with what we have already done.
gen age=hh_b05a
lab var age "Individual age"
keep case_id pid age male
tempfile members
save `members', replace

	*Household labor, rainy and dry
local seasons rainy dry
foreach season in `seasons' {
	di "`season'"
	if "`season'"=="rainy" {
		local qnums  "42 43 44" //refers to question numbers
		local dk d //refers to module d
		local ag ag_d00
	} 
	else {
		local qnums "43 44 45" //question numbers differ for module k than d
		local dk k //refers to module k
		local ag ag_k0a
	}
	use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_`dk'.dta", clear
	ren `ag' plot_id
    ren ea_id ea
    merge m:1 case_id ea using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta", nogen //merges in household info
	
	forvalues k=1(1)3 {
		local q : word `k' of `qnums'
		if `k' == 1 { //where 1 refers to the first value in qnums, question 42 - planting
        local suffix "_planting" 
    }
    else if `k' == 2 { //where 2 refers to the second value in qnums, question 43 - nonharvest
        local suffix "_nonharvest"
    }
    else if `k' == 3 { //where 3 refers to the third value in qnums, question 44 - harvest
        local suffix "_harvest"
    }
	ren ag_`dk'`q'a pid1`suffix'
    ren ag_`dk'`q'b weeks_worked1`suffix'
    ren ag_`dk'`q'c days_week1`suffix'
    ren ag_`dk'`q'd hours_day1`suffix'
    ren ag_`dk'`q'e pid2`suffix'
    ren ag_`dk'`q'f weeks_worked2`suffix'
    ren ag_`dk'`q'g days_week2`suffix'
    ren ag_`dk'`q'h hours_day2`suffix'
    ren ag_`dk'`q'i pid3`suffix'
    ren ag_`dk'`q'j weeks_worked3`suffix'
    ren ag_`dk'`q'k days_week3`suffix'
    ren ag_`dk'`q'l hours_day3`suffix'
    ren ag_`dk'`q'm pid4`suffix'
    ren ag_`dk'`q'n weeks_worked4`suffix'
    ren ag_`dk'`q'o days_week4`suffix'
    ren ag_`dk'`q'p hours_day4`suffix'
    }
	keep region stratum district ta ea rural case_id plot_id pid* weeks_worked* days_week* hours_day*
    gen season = "`season'"
	unab vars : *`suffix' //this line generates a list of all the variables that end in suffix 
	local stubs : subinstr local vars "_`suffix'" "", all //this line removes `suffix' from the end of all of the variables that currently end in suffix
	duplicates drop  region stratum district ta ea rural case_id plot_id season, force //one duplicate entry
	reshape long pid weeks_worked days_week hours_day, i(region stratum district ta ea rural case_id plot_id season) j(num_suffix) string //reshaping double-wide data (planting, nonharvest, harvest, along with persons 1-4)
	split num_suffix, parse(_) //need additional command to break up num_suffix into two variables
	//MGM 6.13.2023: Question for @ALT - What should I rename num_suffix1 and num_suffix2? Come back to clean this up.
	if "`season'"=="rainy" {
		tempfile rainy
		save `rainy'
	}
	else {
		append using `rainy'
	}
}
gen days=weeks_worked*days_week
gen hours=weeks_worked*days_week*hours_day
drop if days==. //MGM 6.13.23: Question for @ALT - 307,522 observations deleted, roughly 3x model NGA W3 code though NGA W3 does not have rainy and dry. Is this okay?
drop if hours==. //75 observations deleted
//rescaling fam labor to growing season duration
preserve
collapse (sum) days_rescale=days, by(region stratum district ta ea rural case_id plot_id pid)
merge m:1 case_id plot_id using"${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_season_length.dta", nogen keep(1 3)
replace days_rescale = days_grown if days_rescale > days_grown
tempfile rescaled_days
save `rescaled_days'
restore
//Rescaling to season
bys case_id plot_id pid : egen tot_days = sum(days)
gen days_prop = days/tot_days 
merge m:1 region stratum district ta ea rural case_id plot_id pid using `rescaled_days'
replace days = days_rescale * days_prop if tot_days > days_grown
merge m:1 case_id pid using `members', nogen keep (1 3)
gen gender="child" if age<15 //MGM: age <16 on reference code, age <15 on MWI W1 survey instrument
replace gender="male" if strmatch(gender,"") & male==1
replace gender="female" if strmatch(gender,"") & male==0
gen labor_type="family"
keep region stratum district ta ea rural case_id plot_id season gender days labor_type
append using `all_exchange'
foreach i in region stratum district ta ea rural case_id {
	merge m:1 `i' gender season using `wage_`i'_median', nogen keep(1 3) 
}
	merge m:1 gender season using `wage_country_median', nogen keep(1 3)
	
	gen wage=wage_case_id
gen missing_wage = wage == .						
foreach i in region stratum district ta ea rural {
	replace wage = wage_`i' if obs_`i' > 9  & missing_wage==1
}
	
//gen val = wage*days //where val reflects total wage expenses for ONE laborer across the season
gen val = . //MGM 7.20.23: EPAR cannot construct the value of family labor or nonhired (AKA exchange) labor MWI Waves 1, 2, 3, and 4 given issues with how the value of hired labor is constructed (e.g. we do not know how many laborers are hired and if wages are reported as aggregate or singular). Therefore, we cannot use a median value of hired labor to impute the value of family or nonhired (AKA exchange) labor.
append using `all_hired'
keep region stratum district ta ea rural case_id plot_id season days val labor_type gender //MGM: number does not exist for MWI W1
drop if val==.&days==.
merge m:1 plot_id case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender)
collapse (sum) val days, by(case_id plot_id season labor_type gender dm_gender) //MGM:number does not exist for MWI W1
	la var gender "Gender of worker"
	la var dm_gender "Plot manager gender"
	la var labor_type "Hired, exchange, or family labor"
	la var days "Number of person-days per plot" 
	//la var val "Total value of labor (enter currency here)"//MGM 6.13.23: Getting an invalid syntax error. 
save "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_plot_labor_long.dta",replace
preserve
	collapse (sum) labor_=days, by (case_id plot_id labor_type)
	reshape wide labor_, i(case_id plot_id) j(labor_type) string
		la var labor_family "Number of family person-days spent on plot, all seasons"
		la var labor_nonhired "Number of exchange (free) person-days spent on plot, all seasons" //MGM 6.20.23: Question for @ALT - this label feels misleading given we lack # of workers. Do we consider changing the label?
		la var labor_hired "Number of hired labor person-days spent on plot, all seasons" //MGM 6.20.23: Question for @ALT this label - feels misleading given we lack # of workers. Do we consider changing the label?
	save "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_plot_labor_days.dta",replace 

//AgQuery
restore
//ALT: At this point all code below is legacy; we could cut it with some changes to how the summary stats get processed.
preserve
	gen exp="exp" if strmatch(labor_type,"hired")
	replace exp="imp" if strmatch(exp,"")
	append using `inkind_payments'
	collapse (sum) val, by(case_id plot_id exp dm_gender)
	gen input="labor"
	save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_labor.dta", replace //this gets used below.
restore	
//Back to wide format

/*MGM 6.30.23: ALT requested summary stats
preserve
replace days=. if days==0
collapse (min) min_days = days (max) max_days=days (mean) mean_days=days, by(gender labor_type)
restore
*/

collapse (sum) val, by(case_id plot_id season labor_type dm_gender)
ren val val_ 
reshape wide val_, i(case_id plot_id season dm_gender) j(labor_type) string
ren val* val*_
reshape wide val*, i(case_id plot_id dm_gender) j(season) string
gen dm_gender2 = "male" if dm_gender==1
replace dm_gender2 = "female" if dm_gender==2
replace dm_gender2 = "unknown" if dm_gender==. //MGM 6.13.23 - Question for @ALT. NGA W3 reference said replace dm_gender2="mixed" if dm_gender==3 but dm_gender does not have a 3 option, only blanks. Changed to unknown and for blanks right now. Can fix plot decision makers if needed, but MWI W1 does not currently create a mixed option
drop dm_gender
ren val* val*_ //MGM 6.20.23 Question for @ALT again, val variable is misleading and inconsistent across labor types. Needs resolution.
reshape wide val*, i(case_id plot_id) j(dm_gender2) string
collapse (sum) val*, by(case_id)
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_cost_labor.dta", replace


	******************************************************
	* CHEMICALS, FERTILIZER, LAND, ANIMALS, AND MACHINES *
	******************************************************
	*********************************
	* 			 SEED			    *
	*********************************
	use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_h.dta", clear
gen season = 1
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_n.dta"
replace season = 2 if season == .
ren ag_h0b seedcode
replace seedcode=ag_n0c if seedcode == .
gen itemcodeseedsimp1 = seedcode
ren ag_h42a qtyseedsimp1 //Quantity Left
replace qtyseedsimp1 = ag_n42a if qtyseedsimp1 == .
ren ag_h42b unitseedsimp1
replace unitseedsimp1 = ag_n42b if unitseedsimp1== . // adding Dry Season
gen itemcodeseedsimp2 = seedcode
ren ag_h38a qtyseedsimp2  // Free seeds
replace qtyseedsimp2 = ag_n38a if qtyseedsimp2 == .
ren ag_h38b unitseedsimp2
replace unitseedsimp2 = ag_n38b if unitseedsimp2 == . // adding Dry Season
gen itemcodeseedsimp3 = seedcode
ren ag_h36a qtyseedsimp3  // Third Source
replace qtyseedsimp3 = ag_n36a if qtyseedsimp3 == .
ren ag_h36b unitseedsimp3
replace unitseedsimp3 = ag_n36b if unitseedsimp3 == . // adding Dry Season
gen itemcodeseedsexp1 = seedcode
ren ag_h16a qtyseedsexp1
replace qtyseedsexp1 = ag_n16a if qtyseedsexp1 ==.
ren ag_h16b unitseedsexp1
replace unitseedsexp1 = ag_n16b if unitseedsexp1 ==.
ren ag_h18 valseedtransexp1 //all transportation is explicit
replace valseedtransexp1 = ag_n18 if valseedtransexp1 == .
ren ag_h19 valseedsexp1
replace valseedsexp1 = ag_n19 if valseedsexp1 == .
gen itemcodeseedsexp2 = seedcode
ren ag_h26a qtyseedsexp2
replace qtyseedsexp2 = ag_n26a if qtyseedsexp2 ==.
ren ag_h26b unitseedsexp2
replace unitseedsexp2 = ag_n26b if unitseedsexp2 ==.
ren ag_h28 valseedtransexp2 //all transportation is explicit
replace valseedtransexp2 = ag_n28 if valseedtransexp2 == .
ren  ag_h29 valseedsexp2
replace valseedsexp2 = ag_n29 if valseedsexp2 == .

keep item* qty* unit* val* case_id 
gen dummya=1
gen dummyb=sum(dummya) //dummy id for duplicates
drop dummya
unab vars : *1
local stubs : subinstr local vars "1" "", all
reshape long `stubs', i (case_id dummyb) j(entry_no)
drop entry_no
gen dummyc=sum(dummyb)
drop dummyb
unab vars2 : *exp
local stubs2 : subinstr local vars2 "exp" "", all
drop if qtyseedsexp==. & valseedsexp==.
reshape long `stubs2', i(case_id dummyc) j(exp) string
gen dummyd = sum(dummyc)
drop dummyc
reshape long qty unit val itemcode, i(case_id  exp dummyd) j(input) string
drop if strmatch(exp,"imp") & strmatch(input,"seedtrans") //No implicit transportation costs
recode itemcode (1/4 = 1) (5/7 10 = 2) (11/16 = 3) (17/23 25/26 = 4) (27 = 5) (28 = 6) (29 = 7) (31 = 8) (32 = 9) (33 = 10) (34 = 11) (35 = 12) (36 = 13) (37 = 14) (38 = 15) (39 = 16) (40 = 17) (41 = 18) (42 = 19) (43 = 20) (44 = 21) (45 = 22) (46 = 23) (47 = 24) (48 = 25)
collapse (sum) val qty, by(case_id unit itemcode exp input )
ren itemcode crop_code
ren unit unit_cd
drop if crop_code==. & strmatch(input,"seeds")
replace unit_cd = 31 if unit_cd==32 //Both large mudu, not sure where the surplus unit code came from.
rename crop_code crop_code_full 
rename unit_cd unit 
gen condition =1 
merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhsize.dta", keepusing (region) nogen 
merge m:1 crop_code_full unit condition region using "${Malawi_IHS_W1_created_data}\MLW_W1_cf.dta", nogen keep (1 3)
ren unit unit_cd
//The problem is that not all of these are seeds (see w4) and so some of the conversions are probably off.
replace conversion = 10 if crop_code==1020 & inrange(unit_cd,160,162) //10 stems per bundle, regardless of size
replace conversion = 1 if inrange(unit_cd,80,82) | (unit_cd==1 & conversion==.) //pieces //why there are kgs not converted at this point is beyond my ken. 
gen unit=1 if inlist(unit_cd,160,161,162,80,81,82) //pieces
replace unit=2 if unit==. //Weight, meaningless for transportation
replace unit=0 if conversion==. //useless for price calculations
replace qty=qty*conversion if conversion!=.
ren crop_code itemcode
recode val (.=0)
collapse (sum) val qty, by(case_id exp input itemcode unit) //Eventually, quantity won't matter for things we don't have units for.

	*********************************
	* 		LAND/PLOT RENTS			*
	*********************************

use "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_all_plots.dta",clear
collapse (sum) ha_planted, by(case_id plot_id season) //no y2_hhid for W1
tempfile planted_area
save `planted_area' 

//MGM 8.3.2023: @ALT why are we not valuing rents from other sources like crop values? See questions 8-10 on the survey instrument
* Rainy
	use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_d.dta", clear // MGM 8.3.2023 @ALT reference uses ag_mod_i2 but W1 does not have this b/c not at the garden level. HKS also only grabs question ag_i029a and b which asks how much did you pay the owner for the use of [GARDEN]? Why not ag_i0211
	gen cultivate = 0
		replace cultivate = 1 if ag_d14 == 1
	ren ag_d00 plot_id
	ren ag_d11a cash_rents_paid
	ren ag_d11b inkind_rents_paid
	ren ag_d11c cash_rents_owed
	ren ag_d11d inkind_rents_owed
	egen valplotrentexp = rowtotal(cash_rents_paid inkind_rents_paid cash_rents_owed inkind_rents_owed)
	gen season = 0 //"Rainy"
	keep case_id plot_id valplotrentexp season cult
	tempfile rainy_land_rents
	save `rainy_land_rents', replace

* Dry
	use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_k.dta", clear // MGM 8.3.2023 @ALT reference uses ag_mod_k_13 but W1 does not have this - should I filter out panel households or do we want all?
	gen cultivate = 0
		replace cultivate = 1 if ag_k15 == 1
    ren ag_k0a plot_id
    ren ag_k12a cash_rents_paid
	ren ag_k12b inkind_rents_paid
	ren ag_k12c cash_rents_owed
	ren ag_k12d inkind_rents_owed
	egen valplotrentexp = rowtotal(cash_rents_paid inkind_rents_paid cash_rents_owed inkind_rents_owed)	
	keep case_id plot_id valplotrentexp cult
	gen season = 1 //"Dry"

* Combine dry + rainy
append using `rainy_land_rents'

duplicates report case_id plot_id season
duplicates tag case_id plot_id season, gen(dups)
br if dups>0
duplicates drop case_id plot_id season, force //four duplicate entries

* Merge in plot areas & planted areas at plot-hhid-caseid level
merge m:1  plot_id case_id season using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_areas.dta", keep(1 3) // MGM 8.3.23 master dataset has 9,088 observations therefore 9,210 unmatched from master! Should I go back to all plots and figure out why there are so many missing plot_ids
	* HKS 5/11/23: I think these are gonna be useless to us then for calculating plot rents, so let's drop for now (ALT, is that ok?)
	drop if _m != 3 // 9,9210 observations deleted MGM 8.3.2023: is it okay to drop these?
	drop _m

merge m:1  plot_id case_id season using `planted_area' 
	// MGM 8.3.2023:  23,054 obs matched
		// 583 from master where ha_planted == . , which implies that observations where there was no planting (i.e. perhaps not cultivated this season) were dropped in creating all_plots
		// 5,996 obs using either because HHID is blank, or treecrop (i.e. where gardenid or plotid contain T or TG OR season == 2), or mismatch in season according to plotid, or ha_planted == 0
		keep if _m == 3 
		drop _m
		* Just checked to confirm, there is no available plot rent info for permanent/tree crops

/*
	bysort case_id: egen denom = sum(area_meas_hectares) // HKS: why isn't this doing what I want it to do? get sanity check from Seb or Andrew
	gen plotshare = area_meas_hectares/denom
	drop denom
	gen plotrent = plotshare*val_plotrent
	replace val_plotrent = plotrent
		drop plotrent plotshare
*/
	
	
	* HKS 5.11.23: Note that field_size is calculated using land conversion factors, which do not currently exist in MWI LSMS data; may require future literature searching to incorporate this code; For now, we skip the land conversion factors section as a whole (will need to work in sometime, refer to NGA W3). In the meantime, substitute area_meas_hectares in for field_size (as per ALT instruction) 
	* HKS 5.23.23: in MWI_W2 and other waves, field_size is caclulated without land conversion factors, just in plot_areas.dta code; this has since been copied in; re-replacing "area_meas_hecatres" with "field_size"
	
	
* Calculate quantity of plot rents etc. 
gen qtyplotrentexp = field_size if valplotrentexp > 0 & valplotrentexp! = .
	replace qtyplotrentexp = ha_planted if qtyplotrentexp==. & valplotrentexp>0 & valplotrentexp!=. // HKS: 0 changes, confirms that ha_planted was constructed using area_meas_hectares
gen qtyplotrentimp = field_size if qtyplotrentexp==. // HKS 5.11.2023: this was probably useful in NGA but so long as we don't have real land conversion factors to create field_size, this basically is just creating a second variable to hold the same info
	replace qtyplotrent_imp = ha_planted if qtyplotrentimp==. & qtyplotrentexp==.
keep if cultivate==1 //No need for uncultivated plots - drops 54 obs
keep case_id season plot_id valplotrent* qty_plotrent* 

* Reshape (HKS 5.11.23: Note that NGA reshaped using zone, lga, ea, etc. which is not currently in these data; not sure if we need to merge it in later)
reshape long val qty, i(case_id season plot_id) j(input) string
gen unit=1 //dummy var
gen itemcode=1 //dummy var
tempfile plotrents
save `plotrents'	
****************************    FERTILIZER   *********************************** 
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_f.dta", clear

gen season = 1

append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_l.dta"

replace season = 2 if season == .
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_d.dta"

ren ag_f0c inputid // identification codes 101 = Organic
//MGM 6.19.23 what about others specified? N=6
ren ag_d39a codefertherb //Type of inorganic fertilizer or Herbicide (1 = 23:21:0+4S/CHITOWE, 2 =  DAP, 3 = CAN 4 = UREA, 5 = D COMPOUND 5, 6 = Other Fertilizer, 7 = INSECTICIDE, 8 = HERBICIDE, 9 = FUMIGANT
// 10 = Other Pesticide or Herbicide. 17 - unknown) this can be used for purchased and non-purchased amounts

ren ag_f07a qtyfert //quantity of purchased inorganic or organic  fertilizer used first source
replace qtyfert = ag_l07a if qtyfert == . //add dry season 2 (Dimba)
ren ag_f07b unitfert // units first source
replace unitfert = ag_l07b if unitfert == . //add dry season 2 (Dimba)
ren ag_f10 valfert // value of purchased inorganic fertilizer or organic fertilizer used first source
replace valfert = ag_l10 if valfert == . //add dry season 2 (Dimba)

//MGM 6.19.23 Can this chunk be deleted? Ask HKS/ALT
//Numbers for all the sources included above 
/*ren ag_f26a qtyfertsecondsource //quantity of purchased inorganic fertilizer  or organic fertilizer used second source
replace qtyfertsecondsource = ag_l26a if qtyfertsecondsource == . //add dry season 2 (Dimba)
ren ag_f26b unitfertsecondsource // units first source
replace unitfertsecondsource = ag_l26b if unitfertsecondsource == . //add dry season 2 (Dimba)
ren ag_f29 valfert // value of purchased inorganic fertilizer or organic fertilizer used second source
replace valfertsecondsource = ag_l29 if valfertsecondsource == . //add dry season 2 (Dimba)*/ 

*************************    INORGANIC FERTILIZER   **************************** 
gen itemcodefertexp1 = codefertherb if codefertherb >= 1 & codefertherb <=6
gen qtyfertexp1 = qtyfert if codefertherb >= 1 & codefertherb <=6 
gen unitfertexp1 = unitfert if codefertherb >= 1 & codefertherb <=6
gen valfertexp1 =  valfert if codefertherb >= 1 & codefertherb <=6

//gen qtyferttotal1 = qtyferttotal if codefertherb >= 1 & codefertherb <=6
//gen qtyfertimp1 =  qtyferttotal1 - (qtyfertexp1 + qtyfertexp2)

*************************    ORGANIC FERTILIZER   ****************************** 

gen itemcodefertexp2=18 if inputid == 101 // adding 0 as a temporary label for organic 
gen qtyfertexp2 = qtyfert if inputid == 101
gen unitfertexp2 = unitfert if inputid == 101
gen valfertexp2 =  valfert if inputid == 101

//gen qtyferttotal2 = qtyferttotal if inputid == 101
//gen qtyfertimp2 =  qtyferttotal2 - (qtyfertexp3 + qtyfertexp4)


gen itemcodefertimp1 = codefertherb
ren ag_f42a  qtyfertimp3   // Quantity Left
ren ag_f42b  unitfertimp3

ren ag_f09 valtransfertexp1 //All transportation costs are explicit


*************************  PESTICIDES/HERBICIDES   *****************************
gen itemcodeherbimp1 = codefertherb
gen qtyherbexp3 = qtyfert if codefertherb >= 7 & codefertherb <=10
gen unitherbexp3 = unitfert if codefertherb >= 7 & codefertherb <=10
gen valherbexp3=  valfert if codefertherb >= 7 & codefertherb <=10
gen qtyherbexp6 = qtyfert if codefertherb >= 7& codefertherb <=10
gen unitherbexp6 = unitfert if codefertherb >= 7 & codefertherb <=10
gen valherbexp6=  valfert if codefertherb >= 7 & codefertherb <=10
 
drop qtyfert unitfert valfert qtyfert unitfert valfert

keep item* qty* unit* val*  case_id season
gen dummya=1
gen dummyb=sum(dummya) //dummy id for duplicates
drop dummya
unab vars : *2
local stubs : subinstr local vars "2" "", all
reshape long `stubs', i(case_id dummyb season) j(entry_no)
drop entry_no
unab vars2 : *exp
local stubs2 : subinstr local vars2 "exp" "", all
//drop if (itemcodefertexp==.) | (unitfertimp==. & unitfertexp==.)
//gen dummyc=sum(dummyb)
//drop dummyb
//reshape long `stubs2', i(hhid season dummyc) j(exp) string
//gen dummyd = sum(dummyc)
//drop dummyc
reshape long qty unit val itemcode, i(case_id season *exp dummyd) j(input) string
recode qty val (.=0)
/* replace qty=qty/1000 if unit==2 & qty/1000 >=1 //Catching typos.
replace unit=1 if unit==2
replace qty=qty/100 if unit==4 & qty/100 >=1
replace unit=3 if unit==4 */
collapse (sum) qty* val*, by(case_id season exp input unit itemcode)
tempfile phys_inputs
save `phys_inputs'



********************************************************************************
* LIVESTOCK INCOME *
********************************************************************************
//ALT 10.18.19: This is almost VAP code verbatim. I made few changes (see comments)
*Expenses
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_r1.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_r2.dta"
rename ag_r28 cost_fodder_livestock       /* VAP: MW2 has no separate cost_water_livestock */
rename ag_r29 cost_vaccines_livestock     /* Includes medicines */
rename ag_r30 cost_othervet_livestock     /* VAP: TZ didn't have this. Includes dipping, deworming, AI */
gen cost_medical_livestock = cost_vaccines_livestock + cost_othervet_livestock /* VAP: Combining the two categories for later. */
rename ag_r27 cost_hired_labor_livestock 
rename ag_r31 cost_input_livestock        /* VAP: TZ didn't have this. Includes housing equipment, feeding utensils */
recode cost_fodder_livestock cost_vaccines_livestock cost_othervet_livestock cost_medical_livestock cost_hired_labor_livestock cost_input_livestock(.=0)

preserve
	keep if inlist(ag_r0a, 301, 302, 303, 304, 3304) // VAP: Livestock code
	collapse (sum) cost_fodder_livestock cost_vaccines_livestock cost_othervet_livestock cost_hired_labor_livestock cost_input_livestock, by (case_id)
	egen cost_lrum = rowtotal (cost_fodder_livestock cost_vaccines_livestock cost_othervet_livestock cost_hired_labor_livestock cost_input_livestock)
	keep case_id cost_lrum
	lab var cost_lrum "Livestock expenses for large ruminants"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_lrum_expenses", replace
restore 

preserve 
	rename ag_r0a livestock_code
	gen species = (inlist(livestock_code, 301,302,303,304,3304)) + 2*(inlist(livestock_code,307,308)) + 3*(livestock_code==309) + 4*(livestock_code==3305) + 5*(inlist(livestock_code, 311,313,315,319,3310,3314))
	recode species (0=.)
	la def species 1 "Large ruminants (calf, steer/heifer, cow, bull, ox)" 2 "Small ruminants (sheep, goats)" 3 "Pigs" 4 "Equine (horses, donkeys)" 5 "Poultry"
	la val species species

	collapse (sum) cost_medical_livestock, by (case_id species) 
	rename cost_medical_livestock ls_exp_med
		foreach i in ls_exp_med{
			gen `i'_lrum = `i' if species==1
			gen `i'_srum = `i' if species==2
			gen `i'_pigs = `i' if species==3
			gen `i'_equine = `i' if species==4
			gen `i'_poultry = `i' if species==5
		}
	
collapse (firstnm) *lrum *srum *pigs *equine *poultry, by(case_id)

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
	save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_expenses_animal", replace
restore 
 
collapse (sum) cost_fodder_livestock cost_vaccines_livestock cost_othervet_livestock cost_medical_livestock cost_hired_labor_livestock cost_input_livestock, by (case_id)
lab var cost_fodder_livestock "Cost for fodder for livestock"
lab var cost_vaccines_livestock "Cost for vaccines for livestock"
lab var cost_othervet_livestock "Cost for other veterinary treatment for livestock"
lab var cost_medical_livestock "Cost for vaccines, medicines and other veterinary treatment for livestock"
lab var cost_hired_labor_livestock
lab var cost_input_livestock "Cost for inputs for livestock"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_expenses", replace

*Livestock products 
* Milk
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_s.dta", clear
rename ag_s0a product_code
keep if product_code==401
rename ag_s02 no_of_months_milk // VAP: During the last 12 months, for how many months did your household produce any [PRODUCT]?
rename ag_s03a qty_milk_per_month // VAP: During these months, what was the average quantity of [PRODUCT] produced PER MONTH?. 
gen milk_liters_produced = no_of_months_milk * qty_milk_per_month if ag_s03b==1 // ALT/VAP: Only including liters, not including 5 obs in kg, piece, and other 
lab var milk_liters_produced "Liters of milk produced in past 12 months"

gen liters_sold_12m = ag_s05a if ag_s05b==1 // VAP: Keeping only units in liters
rename ag_s06 earnings_milk_year
gen price_per_liter = earnings_milk_year/liters_sold_12m if liters_sold_12m > 0
gen price_per_unit = price_per_liter
gen quantity_produced = milk_liters_produced
recode price_per_liter price_per_unit (0=.) 
keep case_id product_code milk_liters_produced price_per_liter price_per_unit quantity_produced earnings_milk_year 
lab var price_per_liter "Price of milk per liter sold"
lab var price_per_unit "Price of milk per unit sold" 
lab var quantity_produced "Quantity of milk produced"
lab var earnings_milk_year "Total earnings of sale of milk produced"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products_milk", replace

* Other livestock products  // VAP: Includes milk, eggs, meat, hides/skins and manure. No honey in MW2 but yes honey in MW1. TZ does not have meat and manure. From os column, combine chicken, chicken meat, dove, pigeon into meat. 5 obs duck eggs dropped.
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_s.dta", clear
rename ag_s0a livestock_code
rename ag_s02 months_produced
rename ag_s03a quantity_month
rename ag_s03b quantity_month_unit

replace livestock_code = 404 if strmatch(ag_s0a_os, "CHICKEN") | strmatch(ag_s0a_os, "CHICKEN MEAT") | strmatch(ag_s0a_os, "DOVE") | strmatch(ag_s0a_os, "PIGEON")
replace quantity_month_unit =. if livestock_code==401 & quantity_month_unit!=1     // milk, keeping only liters. 
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
// This is a bigger problem, as there are many obsns in bucket, wheelbarrow & ox-cart but no conversion factors. ALT - Ditto for W1
recode months_produced quantity_month (.=0)
gen quantity_produced = months_produced * quantity_month // Units are liters for milk, pieces for eggs & skin, kg for meat and manure.
lab var quantity_produced "Quantity of this product produced in past year"

rename ag_s05a sales_quantity
rename ag_s05b sales_unit
replace sales_unit =. if livestock_code==401 & sales_unit!=1 // milk, liters only
replace sales_unit =. if livestock_code==402 & sales_unit!=3  // chicken eggs, pieces only
replace sales_unit =. if livestock_code== 403 & sales_unit!=3   // guinea fowl eggs, pieces only
replace sales_quantity = sales_quantity*1.5 if livestock_code==404 & sales_unit==3 // VAP: converting obsns in pieces to kgs for meat. Using conversion for chicken. 
replace sales_unit = 2 if livestock_code== 404 & sales_unit==3 // VAP: kgs for meat
replace sales_unit =. if livestock_code== 406 & sales_unit!=3   // VAP: pieces for skin and hide, not converting kg (1 obsn).
replace sales_unit =. if livestock_code== 407 & quantity_month_unit!=2  // VAP: kgs for manure, not converting liters(1 obsn), bucket, wheelbarrow & oxcart (2 obsns each)

rename ag_s06 earnings_sales
recode sales_quantity months_produced quantity_month earnings_sales (.=0)
gen price_per_unit = earnings_sales / sales_quantity
keep case_id livestock_code quantity_produced price_per_unit earnings_sales

label define livestock_code_label 401 "Milk" 402 "Chicken Eggs" 403 "Guinea Fowl Eggs" 404 "Meat" 406 "Skin/Hide" 407 "Manure"
label values livestock_code livestock_code_label
bys livestock_code: sum price_per_unit
gen price_per_unit_hh = price_per_unit
lab var price_per_unit "Price of milk per unit sold"
lab var price_per_unit_hh "Price of milk per unit sold at household level"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products_other", replace

use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products_milk", clear
append using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products_other"
recode price_per_unit (0=.)
merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta"
drop if _merge==2
drop _merge
replace price_per_unit = . if price_per_unit == 0 
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products", replace

* EA Level
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products", clear
keep if price_per_unit !=. 
gen observation = 1
bys region district ta ea livestock_code: egen obs_ea = count(observation)
collapse (median) price_per_unit [aw=weight], by (region district ta ea livestock_code obs_ea)
rename price_per_unit price_median_ea
lab var price_median_ea "Median price per unit for this livestock product in the ea"
lab var obs_ea "Number of sales observations for this livestock product in the ea"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products_prices_ea.dta", replace

* ta Level
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys region district ta livestock_code: egen obs_ta = count(observation)
collapse (median) price_per_unit [aw=weight], by (region district ta livestock_code obs_ta)
rename price_per_unit price_median_ta
lab var price_median_ta "Median price per unit for this livestock product in the ta"
lab var obs_ta "Number of sales observations for this livestock product in the ta"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products_prices_ta.dta", replace

* District Level
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys region district livestock_code: egen obs_district = count(observation)
collapse (median) price_per_unit [aw=weight], by (region district livestock_code obs_district)
rename price_per_unit price_median_district
lab var price_median_district "Median price per unit for this livestock product in the district"
lab var obs_district "Number of sales observations for this livestock product in the district"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products_prices_district.dta", replace

* Region Level
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys region livestock_code: egen obs_region = count(observation)
collapse (median) price_per_unit [aw=weight], by (region livestock_code obs_region)
rename price_per_unit price_median_region
lab var price_median_region "Median price per unit for this livestock product in the region"
lab var obs_region "Number of sales observations for this livestock product in the region"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products_prices_region.dta", replace

* Country Level
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys livestock_code: egen obs_country = count(observation)
collapse (median) price_per_unit [aw=weight], by (livestock_code obs_country)
rename price_per_unit price_median_country
lab var price_median_country "Median price per unit for this livestock product in the country"
lab var obs_country "Number of sales observations for this livestock product in the country"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products_prices_country.dta", replace

use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products", clear
merge m:1 region district ta ea livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products_prices_ea.dta"
drop _merge
merge m:1 region district ta livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products_prices_ta.dta"
drop _merge
merge m:1 region district livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products_prices_district.dta"
drop _merge
merge m:1 region livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products_prices_region.dta"
drop _merge
merge m:1 livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_products_prices_country.dta"
drop _merge
replace price_per_unit = price_median_ea if price_per_unit==. & obs_ea >= 10
replace price_per_unit = price_median_ta if price_per_unit==. & obs_ta >= 10
replace price_per_unit = price_median_district if price_per_unit==. & obs_district >= 10 
replace price_per_unit = price_median_region if price_per_unit==. & obs_region >= 10 
replace price_per_unit = price_median_country if price_per_unit==.
lab var price_per_unit "Price per unit of this livestock product, with missing values imputed using local median values"

gen value_milk_produced = milk_liters_produced * price_per_unit 
gen value_eggs_produced = quantity_produced * price_per_unit if livestock_code==402|livestock_code==403
gen value_other_produced = quantity_produced * price_per_unit if livestock_code== 404|livestock_code==406|livestock_code==407
egen sales_livestock_products = rowtotal(earnings_sales earnings_milk_year)		
collapse (sum) value_milk_produced value_eggs_produced value_other_produced sales_livestock_products, by (case_id)

*First, constructing total value
egen value_livestock_products = rowtotal(value_milk_produced value_eggs_produced value_other_produced)
lab var value_livestock_products "value of livesotck prodcuts produced (milk, eggs, other)"
*Now, the share
gen share_livestock_prod_sold = sales_livestock_products/value_livestock_products
replace share_livestock_prod_sold = 1 if share_livestock_prod_sold>1 & share_livestock_prod_sold!=.
lab var share_livestock_prod_sold "Percent of production of livestock products that is sold" 
lab var value_milk_produced "Value of milk produced"
lab var value_eggs_produced "Value of eggs produced"
lab var value_other_produced "Value of skins, meat and manure produced"
recode value_milk_produced value_eggs_produced value_other_produced (0=.)
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_livestock_products", replace
 
* Manure (Dung in TZ)
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_s.dta", clear
rename ag_s0a livestock_code
rename ag_s06 earnings_sales
gen sales_manure=earnings_sales if livestock_code==407 
recode sales_manure (.=0)
collapse (sum) sales_manure, by (case_id)
lab var sales_manure "Value of manure sold" 
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_manure.dta", replace

*Sales (live animals)
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_r1.dta", clear
rename ag_r0a livestock_code
rename ag_r17 income_live_sales     // total value of sales of [livestock] live animals last 12m
rename ag_r16 number_sold          // # animals sold alive last 12 m
rename ag_r19 number_slaughtered  // # animals slaughtered last 12 m 
/* VAP: not available in MW2
rename lf02_32 number_slaughtered_sold  // # of slaughtered animals sold
replace number_slaughtered = number_slaughtered_sold if number_slaughtered < number_slaughtered_sold  
rename lf02_33 income_slaughtered // # total value of sales of slaughtered animals last 12m
*/
rename ag_r11 value_livestock_purchases // tot. value of purchase of live animals last 12m
recode income_live_sales number_sold number_slaughtered /*number_slaughtered_sold income_slaughtered*/ value_livestock_purchases (.=0)
gen price_per_animal = income_live_sales / number_sold
lab var price_per_animal "Price of live animals sold"
recode price_per_animal (0=.) 
merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta"
drop if _merge==2
drop _merge
keep case_id weight region district ta ea livestock_code number_sold income_live_sales number_slaughtered /*number_slaughtered_sold income_slaughtered*/ price_per_animal value_livestock_purchases
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_livestock_sales", replace

*Implicit prices  // VAP: MW2 does not have value of slaughtered livestock
* EA Level
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region district ta ea livestock_code: egen obs_ea = count(observation)
collapse (median) price_per_animal [aw=weight], by (region district ta ea livestock_code obs_ea)
rename price_per_animal price_median_ea
lab var price_median_ea "Median price per unit for this livestock in the ea"
lab var obs_ea "Number of sales observations for this livestock in the ea"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_ea.dta", replace

* ta Level
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region district ta livestock_code: egen obs_ta = count(observation)
collapse (median) price_per_animal [aw=weight], by (region district ta livestock_code obs_ta)
rename price_per_animal price_median_ta
lab var price_median_ta "Median price per unit for this livestock in the ta"
lab var obs_ta "Number of sales observations for this livestock in the ta"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_ta.dta", replace

* District Level
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region district livestock_code: egen obs_district = count(observation)
collapse (median) price_per_animal [aw=weight], by (region district livestock_code obs_district)
rename price_per_animal price_median_district
lab var price_median_district "Median price per unit for this livestock in the district"
lab var obs_district "Number of sales observations for this livestock in the district"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_district.dta", replace

* Region Level
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region livestock_code: egen obs_region = count(observation)
collapse (median) price_per_animal [aw=weight], by (region livestock_code obs_region)
rename price_per_animal price_median_region
lab var price_median_region "Median price per unit for this livestock in the region"
lab var obs_region "Number of sales observations for this livestock in the region"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_region.dta", replace

* Country Level
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys livestock_code: egen obs_country = count(observation)
collapse (median) price_per_animal [aw=weight], by (livestock_code obs_country)
rename price_per_animal price_median_country
lab var price_median_country "Median price per unit for this livestock in the country"
lab var obs_country "Number of sales observations for this livestock in the country"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_country.dta", replace

use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_livestock_sales", clear
merge m:1 region district ta ea livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_ea.dta"
drop _merge
merge m:1 region district ta livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_ta.dta"
drop _merge
merge m:1 region district livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_district.dta"
drop _merge
merge m:1 region livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_region.dta"
drop _merge
merge m:1 livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_country.dta"
drop _merge
replace price_per_animal = price_median_ea if price_per_animal==. & obs_ea >= 10
replace price_per_animal = price_median_ta if price_per_animal==. & obs_ta >= 10
replace price_per_animal = price_median_district if price_per_animal==. & obs_district >= 10
replace price_per_animal = price_median_region if price_per_animal==. & obs_region >= 10
replace price_per_animal = price_median_country if price_per_animal==. 
lab var price_per_animal "Price per animal sold, imputed with local median prices if household did not sell"
gen value_lvstck_sold = price_per_animal * number_sold // VAP: This mean value differs from mean of ag_r17: total value of [livestock]sales last 12m
gen value_slaughtered = price_per_animal * number_slaughtered

/* VAP: Not available for MW2
gen value_slaughtered_sold = price_per_animal * number_slaughtered_sold 
*gen value_slaughtered_sold = income_slaughtered 
replace value_slaughtered_sold = income_slaughtered if (value_slaughtered_sold < income_slaughtered) & number_slaughtered!=0 /* Replace value of slaughtered animals with income from slaughtered-sales if the latter is larger */
replace value_slaughtered = value_slaughtered_sold if (value_slaughtered_sold > value_slaughtered) & (number_slaughtered > number_slaughtered_sold) //replace value of slaughtered with value of slaughtered sold if value sold is larger
*gen value_livestock_sales = value_lvstck_sold  + value_slaughtered_sold 
*/

collapse (sum) /*value_livestock_sales*/ value_livestock_purchases value_lvstck_sold /*value_slaughtered*/, by (case_id)
drop if case_id==""
*lab var value_livestock_sales "Value of livestock sold (live and slaughtered)"
lab var value_livestock_purchases "Value of livestock purchases"
*lab var value_slaughtered "Value of livestock slaughtered (with slaughtered livestock that weren't sold valued at local median prices for live animal sales)"
lab var value_lvstck_sold "Value of livestock sold live" 
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_sales", replace

*TLU (Tropical Livestock Units)
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_r1.dta", clear
rename ag_r0a lvstckid
gen tlu_coefficient=0.5 if (lvstckid==301|lvstckid==302|lvstckid==303|lvstckid==304|lvstckid==3304) // calf, steer/heifer, cow, bull, ox
replace tlu_coefficient=0.1 if (lvstckid==307|lvstckid==308) //goats, sheep
replace tlu_coefficient=0.2 if (lvstckid==309) // pigs
replace tlu_coefficient=0.01 if (lvstckid==311|lvstckid==313|lvstckid==315|lvstckid==319|lvstckid==3310|lvstckid==3314) // local hen, cock, duck, dove/pigeon, chicken layer/broiler, turkey/guinea fowl
replace tlu_coefficient=0.3 if (lvstckid==3305) // donkey/mule/horse
lab var tlu_coefficient "Tropical Livestock Unit coefficient"

rename lvstckid livestock_code
rename ag_r07 number_1yearago
rename ag_r02 number_today_total
rename ag_r03 number_today_exotic
gen number_today_indigenous = number_today_total - number_today_exotic
recode number_today_total number_today_indigenous number_today_exotic (.=0)
*gen number_today = number_today_indigenous + number_today_exotic
gen tlu_1yearago = number_1yearago * tlu_coefficient
gen tlu_today = number_today_total * tlu_coefficient
rename ag_r17 income_live_sales 
rename ag_r16 number_sold 

rename ag_r23b lost_disease_1 // ALT: Two columns in MW1
rename ag_r23d lost_disease_2
gen lost_disease = lost_disease_1+lost_disease_2
*rename lf02_22 lost_injury 
rename ag_r15 lost_stolen // # of livestock lost or stolen in last 12m
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
	collapse (firstnm) share_imp_herd_cows (sum) number_today_total number_1yearago animals_lost12months lost_disease /*ihs*/ number_today_exotic lvstck_holding=number_today_total, by(case_id species)
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
	collapse (sum) number_today_total number_today_exotic (firstnm) *lrum *srum *pigs *equine *poultry share_imp_herd_cows, by(case_id)
	
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
	save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_herd_characteristics", replace
restore

gen price_per_animal = income_live_sales / number_sold
merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta"
drop if _merge==2
drop _merge
merge m:1 region district ta ea livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_ea.dta"
drop _merge
merge m:1 region district ta livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_ta.dta"
drop _merge
merge m:1 region district livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_district.dta"
drop _merge
merge m:1 region livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_region.dta"
drop _merge
merge m:1 livestock_code using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_prices_country.dta"
drop _merge 
recode price_per_animal (0=.)
replace price_per_animal = price_median_ea if price_per_animal==. & obs_ea >= 10
replace price_per_animal = price_median_ta if price_per_animal==. & obs_ta >= 10
replace price_per_animal = price_median_district if price_per_animal==. & obs_district >= 10
replace price_per_animal = price_median_region if price_per_animal==. & obs_region >= 10
replace price_per_animal = price_median_country if price_per_animal==. 
lab var price_per_animal "Price per animal sold, imputed with local median prices if household did not sell"
gen value_1yearago = number_1yearago * price_per_animal
gen value_today = number_today_total * price_per_animal
collapse (sum) tlu_1yearago tlu_today value_1yearago value_today, by (case_id)
lab var tlu_1yearago "Tropical Livestock Units as of 12 months ago"
lab var tlu_today "Tropical Livestock Units as of the time of survey"
gen lvstck_holding_tlu = tlu_today
lab var lvstck_holding_tlu "Total HH livestock holdings, TLU"  
lab var value_1yearago "Value of livestock holdings from one year ago"
lab var value_today "Value of livestock holdings today"
drop if case_id==""
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_TLU.dta", replace

*Livestock income
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_sales", clear
merge 1:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_livestock_products"
drop _merge
merge 1:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_manure.dta"
drop _merge
merge 1:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_expenses"
drop _merge
merge 1:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_TLU.dta"
drop _merge

gen livestock_income = value_lvstck_sold + /*value_slaughtered*/ - value_livestock_purchases /*
*/ + (value_milk_produced + value_eggs_produced + value_other_produced + sales_manure) /*
*/ - (cost_hired_labor_livestock + cost_fodder_livestock + cost_vaccines_livestock + cost_othervet_livestock + cost_input_livestock)

lab var livestock_income "Net livestock income"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_income.dta", replace

********************************************************************************
* FISH INCOME *
********************************************************************************
*Fishing expenses  
/*VAP: Method of calculating ft and pt weeks and days consistent with ag module indicators for rainy/dry seasons*/
use "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_c.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_g.dta"
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
collapse (max) weeks_fishing days_per_week, by (case_id) 
keep case_id weeks_fishing days_per_week
lab var weeks_fishing "Weeks spent working as a fisherman (maximum observed across individuals in household)"
lab var days_per_week "Days per week spent working as a fisherman (maximum observed across individuals in household)"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_weeks_fishing.dta", replace

use "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_d1.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_h2.dta"
merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_weeks_fishing.dta"
rename weeks_fishing weeks
*rename fs_d13 fuel_costs_week //ALT 10.18.19 Not in this questionnaire. Using h13 only.
ren fs_h13 fuel_costs_week
rename fs_h12 rental_costs_fishing_boat // VAP: Boat/Engine rental. //ALT: Changed from d12
// Relevant and in the MW2 Qs., but missing in .dta files. //ALT: Present in MW1
// fs_d6: "How much did your hh. pay to rent [gear] for use in last high season?" 
//replace rental_costs_fishing=fs_h12 if rental_costs_fishing==.
rename fs_d06 rental_costs_fishing_gear
gen rental_costs_fishing = rental_costs_fishing_boat + rental_costs_fishing_gear
rename fs_h10 purchase_costs_fishing_boat // VAP: Boat/Engine purchase. Purchase cost is additional in MW2, TZ code does not have this. 
// Also relevant but missing in .dta files. 
// fs_d4: "If you or any member of your household engaged in fishing had to purchase a [FISHING GEAR], how much would you have //AT: Present in MW1
// paid during the last HIGH fishing season?
rename fs_d04 purchase_costs_fishing_gear
gen purchase_costs_fishing = purchase_costs_fishing_boat + purchase_costs_fishing_gear

recode weeks fuel_costs_week rental_costs_fishing purchase_costs_fishing(.=0)
gen cost_fuel = fuel_costs_week * weeks
collapse (sum) cost_fuel rental_costs_fishing, by (case_id)
lab var cost_fuel "Costs for fuel over the past year"
lab var rental_costs_fishing "Costs for other fishing expenses over the past year"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_fishing_expenses_1.dta", replace // VAP: Not including hired labor costs, keeping consistent with TZ. Can add this for MW if needed. //ALT: I just left this as-is

/* //ALT: No mod d4 in MW1
* Other fishing costs  
use "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_d4.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_h4.dta"
merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_weeks_fishing"
rename fs_d24a total_cost_high // total other costs in high season, only 6 obsns. 
replace total_cost_high=fs_h24a if total_cost_high==.
rename fs_d24b unit
replace unit=fs_h24b if unit==. 
gen cost_paid = total_cost_high if unit== 2  // season
replace cost_paid = total_cost_high * weeks_fishing if unit==1 // weeks
collapse (sum) cost_paid, by (case_id)
lab var cost_paid "Other costs paid for fishing activities"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_fishing_expenses_2.dta", replace
*/

*TODO: Other needs to get disaggregated

* Fish Prices
use "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_e1.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_i1.dta"
rename fs_e02 fish_code 
replace fish_code=fs_i02 if fish_code==. 
recode fish_code (12=11) // recoding "aggregate" from low season to "other"
rename fs_e06a fish_quantity_year // high season - in W1, omits two obs that had fresh and sun-dried entries
replace fish_quantity_year=fs_i06a if fish_quantity_year==. // low season
rename fs_e06b fish_quantity_unit
replace fish_quantity_unit=fs_i06b if fish_quantity_unit==.
rename fs_e08b unit  // piece, dozen/bundle, kg, small basket, large basket //Assuming "small pail" and "10 liter pail" under unit-other are the same. Otherwise:
//replace unit = 9 if strmatch(fs_e0b_os, "SMALL PAIL")
//replace unit = 10 if strmatch(fs_e0b_os, "10*")
gen price_per_unit = fs_e08d // VAP: This is already avg. price per packaging unit. Did not divide by avg. qty sold per week similar to TZ, seems to be an error?
replace price_per_unit = fs_i08d if price_per_unit==.
merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hhids.dta"
drop if _merge==2
drop _merge
recode price_per_unit (0=.) 
collapse (median) price_per_unit [aw=weight], by (fish_code unit)
rename price_per_unit price_per_unit_median
replace price_per_unit_median = . if fish_code==11
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_fish_prices.dta", replace

* Value of fish harvest & sales 
use "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_e1.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_i1.dta"
rename fs_e02 fish_code 
replace fish_code=fs_i02 if fish_code==. 
recode fish_code (12=11) // recoding "aggregate" from low season to "other"
rename fs_e06a fish_quantity_year // high season
replace fish_quantity_year=fs_i06a if fish_quantity_year==. // low season
rename fs_e06b unit  // piece, dozen/bundle, kg, small basket, large basket
merge m:1 fish_code unit using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_fish_prices.dta"
drop if _merge==2
drop _merge
rename fs_e08a quantity_1
replace quantity_1=fs_i08a if quantity_1==.
rename fs_e08b unit_1
replace unit_1=fs_i08b if unit_1==.
gen price_unit_1 = fs_e08d // not divided by qty unlike TZ, not sure about the logic of dividing here. 
replace price_unit_1=fs_i08d if price_unit_1==.
rename fs_e08e quantity_2
replace quantity_2=fs_i08e if quantity_2==.
rename fs_e08f unit_2 
replace unit_2= fs_i08f if unit_2==.
gen price_unit_2=fs_e08h // not divided by qty unlike TZ.
replace price_unit_2=fs_i08h if price_unit_2==.
replace price_unit_1 = price_per_unit_median if price_unit_1==. //Replace w/ median value if unit_1 value is missing
//Fish price code failed to generate a per-piece price for utaka even though some households sold that fish in those units
recode quantity_1 quantity_2 fish_quantity_year price_unit_2 (.=0) //need to include price_unit_2 or income calculation will fail
gen income_fish_sales = (quantity_1 * price_unit_1) + (quantity_2 * price_unit_2)
gen value_fish_harvest = (fish_quantity_year * price_unit_1) if unit==unit_1 
replace value_fish_harvest = (fish_quantity_year * price_per_unit_median) if value_fish_harvest==.
collapse (sum) value_fish_harvest income_fish_sales, by (case_id)
recode value_fish_harvest income_fish_sales (.=0)
lab var value_fish_harvest "Value of fish harvest (including what is sold), with values imputed using a national median for fish-unit-prices"
lab var income_fish_sales "Value of fish sales"
//Need some sort of SOP for when value_harvest > 0 but income = 0 due to missing information
//Also these numbers look like garbage because there's a small dataset and it looks like only some of the prices were recorded
//per piece. Others look like they are totals. 
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_fish_income.dta", replace


********************************************************************************
* SELF-EMPLOYMENT INCOME *
********************************************************************************
*Self-employment income //FN: creating dummy for self-employment, assuming that if hh_n40 = . then hh was not engaged in self-employment 
use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_n2.dta", clear
rename hh_n40 last_months_profit
gen self_employed_yesno = .
replace self_employed_yesno = 1 if last_months_profit !=.
replace self_employed_yesno = 0 if last_months_profit == .
*DYA.2.9.2022 Collapse this at the household level
collapse (max) self_employed_yesno (sum) last_months_profit, by(case_id)
lab var self_employed_yesno "1=Household has at least one member with self-employment income"
drop if self != 1
ren last_months_profit self_employ_income
lab var self_employ_income "self employment income in previous month"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_self_employment.dta", replace

* VAP: Cannot compute hh. enterprise profit correctly, variable (hh_n40) asks only for last month of operation, not an average.*
* ALT: Ditto for W1
/*use "${TZA_W4_raw_data}\Household\hh_sec_n.dta", clear
rename hh_n19 months_activ
rename hh_n20 monthly_profit
gen annual_selfemp_profit = monthly_profit * months_activ
recode annual_selfemp_profit (.=0)
collapse (sum) annual_selfemp_profit, by (y4_hhid)
lab var annual_selfemp_profit "Estimated annual net profit from self-employment over previous 12 months"
save "${TZA_W4_created_data}\Tanzania_NPS_LSMS_ISA_W4_self_employment_income.dta", replace
*/

* VAP: Cannot compute ag byproduct profits as MW2 does not have by-product prices and costs. 
* ALT: Ditto
/*
* Processed crops
use "${TZA_W4_raw_data}\Agriculture\ag_sec_10.dta", clear
rename zaoname crop_name
rename ag10_06 byproduct_sold_yesno
rename ag10_07_1 byproduct_quantity
rename ag10_07_2 byproduct_unit
rename ag10_08 kgs_used_in_byproduct 
rename ag10_11 byproduct_price_received
rename ag10_13 other_expenses_yesno
rename ag10_14 byproduct_other_costs
merge m:1 y4_hhid crop_code using "${TZA_W4_created_data}\Tanzania_NPS_LSMS_ISA_W4_hh_crop_prices.dta"
drop _merge
recode byproduct_quantity kgs_used_in_byproduct byproduct_other_costs (.=0)
gen byproduct_sales = byproduct_quantity * byproduct_price_received
gen byproduct_crop_cost = kgs_used_in_byproduct * price_kg
gen byproduct_profits = byproduct_sales - (byproduct_crop_cost + byproduct_other_costs)
collapse (sum) byproduct_profits, by (y4_hhid)
lab var byproduct_profits "Net profit from sales of agricultural processed products or byproducts"
save "${TZA_W4_created_data}\Tanzania_NPS_LSMS_ISA_W4_agproducts_profits.dta", replace
*/

*Fish trading
use "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_c.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_g.dta"
rename fs_c04a weeks_fish_trading 
replace weeks_fish_trading=fs_g04a if weeks_fish_trading==.
recode weeks_fish_trading (.=0)
collapse (max) weeks_fish_trading, by (case_id) 
keep case_id weeks_fish_trading
lab var weeks_fish_trading "Weeks spent working as a fish trader (maximum observed across individuals in household)"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_weeks_fish_trading.dta", replace

use "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_f1.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_f2.dta"
append using "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_j1.dta"
append using "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_j2.dta"
rename fs_f02a quant_fish_purchased_1
replace quant_fish_purchased_1= fs_j02a if quant_fish_purchased_1==.
rename fs_f02d price_fish_purchased_1
replace price_fish_purchased_1= fs_j02d if price_fish_purchased_1==.
rename fs_f02e quant_fish_purchased_2
replace quant_fish_purchased_2= fs_j02e if quant_fish_purchased_2==.
rename fs_f02h price_fish_purchased_2
replace price_fish_purchased_2= fs_j02h if price_fish_purchased_2==.
rename fs_f03a quant_fish_sold_1
replace quant_fish_sold_1=fs_j03a if quant_fish_sold_1==.
rename fs_f03d price_fish_sold_1
replace price_fish_sold_1=fs_j03d if price_fish_sold_1==.
rename fs_f03e quant_fish_sold_2
replace quant_fish_sold_2=fs_j03e if quant_fish_sold_2==.
rename fs_f03h price_fish_sold_2
replace price_fish_sold_2=fs_j03h if price_fish_sold_2==.
/* VAP: Had added other costs here, but commenting out to be consistent with TZ. 
rename fs_f05 other_costs_fishtrading // VAP: Hired labor, transport, packaging, ice, tax in MW2, not in TZ.
replace other_costs_fishtrading=fs_j05 if other_costs_fishtrading==. 
*/
recode quant_fish_purchased_1 price_fish_purchased_1 quant_fish_purchased_2 price_fish_purchased_2 /*
*/ quant_fish_sold_1 price_fish_sold_1 quant_fish_sold_2 price_fish_sold_2 /*other_costs_fishtrading*/(.=0)

gen weekly_fishtrade_costs = (quant_fish_purchased_1 * price_fish_purchased_1) + (quant_fish_purchased_2 * price_fish_purchased_2) /*+ other_costs_fishtrading*/
gen weekly_fishtrade_revenue = (quant_fish_sold_1 * price_fish_sold_1) + (quant_fish_sold_2 * price_fish_sold_2)
gen weekly_fishtrade_profit = weekly_fishtrade_revenue - weekly_fishtrade_costs
collapse (sum) weekly_fishtrade_profit, by (case_id)
lab var weekly_fishtrade_profit "Average weekly profits from fish trading (sales minus purchases), summed across individuals"
keep case_id weekly_fishtrade_profit
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_fish_trading_revenues.dta", replace   

use "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_f2.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Fisheries\fs_mod_j2.dta"
rename fs_f05 weekly_costs_for_fish_trading // VAP: Other costs: Hired labor, transport, packaging, ice, tax in MW2.
replace weekly_costs_for_fish_trading=fs_j05 if weekly_costs_for_fish_trading==.
recode weekly_costs_for_fish_trading (.=0)
collapse (sum) weekly_costs_for_fish_trading, by (case_id)
lab var weekly_costs_for_fish_trading "Weekly costs associated with fish trading, in addition to purchase of fish"
keep case_id weekly_costs_for_fish_trading
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_fish_trading_other_costs.dta", replace

use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_weeks_fish_trading.dta", clear
merge 1:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_fish_trading_revenues.dta" 
drop _merge
merge 1:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_fish_trading_other_costs.dta"
drop _merge
replace weekly_fishtrade_profit = weekly_fishtrade_profit - weekly_costs_for_fish_trading
gen fish_trading_income = (weeks_fish_trading * weekly_fishtrade_profit)
lab var fish_trading_income "Estimated net household earnings from fish trading over previous 12 months"
keep case_id fish_trading_income
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_fish_trading_income.dta", replace

//ALT 10.18.19: I didn't really modify this code from MW2. The results are still 
//messy due to the underlying data rather than coding errors. I think the sample
//size is a little to small to effectively deal with outliers.

********************************************************************************
* NON-AG WAGE INCOME *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_e.dta", clear
rename hh_e18 wage_yesno // MW2: In last 12m,  work as an employee for a wage, salary, commission, or any payment in kind: incl. paid apprenticeship, domestic work or paid farm work, excluding ganyu
rename hh_e22 number_months  //MW2:# of months worked at main wage job in last 12m. 
rename hh_e23 number_weeks  // MW2:# of weeks/month worked at main wage job in last 12m. 
rename hh_e24 number_hours  // MW2:# of hours/week worked at main wage job in last 12m. 
rename hh_e25 most_recent_payment // amount of last payment

replace most_recent_payment=. if inlist(hh_e19b,62 63 64) // VAP: main wage job //ALT: Not sure what this line is for
**** 
* VAP: For MW2, above codes are in .dta. 62:Agriculture and animal husbandry worker; 63: Forestry workers; 64: Fishermen, hunters and related workers   
* For TZ: TASCO codes from TZ Basic Info Document http://siteresources.worldbank.org/INTLSMS/Resources/3358986-1233781970982/5800988-1286190918867/TZNPS_2014_2015_BID_06_27_2017.pdf
	* 921: Agricultural, Forestry, and Fishery Labourers
	* 611: Farmers and Crop Skilled Workers
	* 612: Animal Producers and Skilled Workers
	* 613: Forestry and Related Skilled Workers
	* 614: Fishery Workers, Hunters, and Trappers
	* 621: Subsistence Agricultural, Forestry, Fishery, and Related Workers
//ALT: So why do we take these out? Also, why not include 61?
***
rename hh_e26b payment_period // What period of time did this payment cover?
rename hh_e27 most_recent_payment_other // What is the value of those (apart from salary) payments? 
replace most_recent_payment_other =. if inlist(hh_e19b,62,63,64) // code of main wage job 
rename hh_e28b payment_period_other // Over what time interval?
rename hh_e32 secondary_wage_yesno // In last 12m, employment in second wage job outside own hh, incl. casual/part-time labour, for a wage, salary, commission or any payment in kind, excluding ganyu
rename hh_e39 secwage_most_recent_payment // amount of last payment
replace secwage_most_recent_payment = . if hh_e33b== 62  // code of secondary wage job
rename hh_e40b secwage_payment_period // What period of time did this payment cover?
rename hh_e41 secwage_recent_payment_other //  value of in-kind payments
rename hh_e42b secwage_payment_period_other // Over what time interval?
rename hh_e38 secwage_hours_pastweek // What was the average hours per week?
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
//tab secwage_payment_period ??
collapse (sum) annual_salary, by (case_id)
lab var annual_salary "Annual earnings from non-agricultural wage"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_wage_income.dta", replace

//ALT 10.18.19 - Pretty similar between W1 and W2, so most of this code is unaltered

********************************************************************************
* AG WAGE INCOME *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_e.dta", clear
rename hh_e18 wage_yesno // MW2: last 12m,  work as an employee for a wage, salary, commission, or any payment in kind: incl. paid apprenticeship, domestic work or paid farm work, excluding ganyu
* TZ: last 12m, work as an unpaid apprentice OR employee for a wage, salary, commission or any payment in kind; incl. paid apprenticeship, domestic work or paid farm work 
rename hh_e22 number_months  //MW2:# of months worked at main wage job in last 12m. TZ: During the last 12 months, for how many months did [NAME] work in this job?
rename hh_e23 number_weeks  // MW2:# of weeks/month worked at main wage job in last 12m. TZ: During the last 12 months, how many weeks per month did [NAME] usually work in this job?
rename hh_e24 number_hours  // MW2:# of hours/week worked at main wage job in last 12m. TZ: During the last 12 months, how many hours per week did [NAME] usually work in this job?
rename hh_e25 most_recent_payment // amount of last payment
gen agwage = 1 if inlist(hh_e19b,62,63,64) // 62: Agriculture and animal husbandry worker; 63: Forestry workers; 64: Fishermen, hunters and related workers
gen secagwage = 1 if hh_e33b==62 //62: Agriculture and animal husbandry worker
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
rename hh_e38 secwage_hours_pastweek // Avg hours per week

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
collapse (sum) annual_salary, by (case_id)
rename annual_salary annual_salary_agwage
lab var annual_salary_agwage "Annual earnings from agricultural wage"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_agwage_income.dta", replace 

//ALT 10.18.19 - No major changes

********************************************************************************
* OTHER INCOME *
********************************************************************************
use "${Malawi_IHS_W1_created_data}/Malawi_IHS_W1_hh_crop_prices_for_wages.dta", clear
keep if crop_code==1 //instrument measures food assistance in maize
keep if unit==1 //instrument measures food assistance in kgs of maize
ren hh_price_mean price_kg
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_maize_prices.dta", replace

use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_p.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Household\hh_mod_r.dta"
append using "${Malawi_IHS_W1_raw_data}\Household\hh_mod_o.dta"
merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_maize_prices.dta"  // VAP: need maize prices for calculating cash value of free maize //MGM 7.7.23 this is not working because the using data set has 469 duplicates. See chunk of code at beginning of section.
rename hh_p0a income_source
rename hh_p02 amount_income
ren hh_p01 received_income
gen rental_income=amount_income if received_income==1 & inlist(income_source, 106, 107, 108, 109) // non-ag land rental, house/apt rental, shope/store rental, vehicle rental
gen pension_investment_income=amount_income if received_income==1 &  income_source==105| income_source==104 | income_source==116 // pension & savings/interest/investment income+ private pension
gen asset_sale_income=amount_income if received_income==1 &  inlist(income_source, 110,111,112) // real estate sales, non-ag hh asset sale income, hh ag/fish asset sale income
gen other_income=amount_income if received_income==1 &  inlist(income_source, 113, 114, 115) // inheritance, lottery, other income
rename hh_r0a prog_code
gen assistance_cash= hh_r02a if inlist(prog_code, 104,108,111,112) // Cash from MASAF, Non-MASAF pub. works,
*inputs-for-work, sec. level scholarships, tert. level. scholarships, dir. Cash Tr. from govt, DCT other
gen assistance_food= hh_r02b if inlist(prog_code, 102, 103) // Cash value of in-kind assistance from free food and Food for work. 
replace assistance_food=hh_r02c*price_kg if prog_code==101 & crop_code==1 // cash value of free maize, imputed from hh. median prices. 
gen assistance_inkind=hh_r02b if inlist(prog_code, 104, 108, 111, 112) // cash value of in-kind assistance from MASAF //ALT 10.18.19 - Commenting this out because it's identical to assistance_cash in MW1
* inputs-for-work, scholarships (sec. & tert.), direct cash transfers (govt & other)
gen cash_received=1 if income_source== 101 // Cash transfers/gifts from indivs. 
gen inkind_gifts_received=1 if inlist(income_source, 102,103) // Food & In-kind transfers/gifts from indivs.
rename hh_o14 cash_remittance // VAP: Module O in MW2
rename hh_o17 in_kind_remittance // VAP: Module O in MW2 //ALT - ditto
recode rental_income pension_investment_income asset_sale_income other_income assistance_cash assistance_food assistance_inkind cash_received inkind_gifts_received cash_remittance in_kind_remittance (.=0)

gen remittance_income = cash_received + inkind_gifts_received + cash_remittance + in_kind_remittance
gen assistance_income = assistance_cash + assistance_food + assistance_inkind
collapse (sum) rental_income pension_investment_income asset_sale_income other_income remittance_income assistance_income, by (case_id)
lab var rental_income "Estimated income from rentals of buildings, land, vehicles over previous 12 months"
lab var pension_investment_income "Estimated income from a pension AND INTEREST/INVESTMENT/INTEREST over previous 12 months"
lab var other_income "Estimated income from inheritance, lottery/gambling and ANY OTHER source over previous 12 months"
lab var asset_sale_income "Estimated income from household asset and real estate sales over previous 12 months"
lab var remittance_income "Estimated income from remittances over previous 12 months"
lab var assistance_income "Estimated income from food aid, food-for-work, cash transfers etc. over previous 12 months"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_other_income.dta", replace


use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_d.dta", clear // *VAP: The below code calculates only agricultural land rental income, per TZ guideline code 
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_k.dta"
rename ag_d19a land_rental_cash_rainy_recd 
rename ag_d19b land_rental_inkind_rainy_recd
rename ag_d19c land_rental_cash_rainy_owed
rename ag_d19d land_rental_inkind_rainy_owed
rename ag_k20a land_rental_cash_dry_recd 
rename ag_k20b land_rental_inkind_dry_recd
rename ag_k20c land_rental_cash_dry_owed
rename ag_k20d land_rental_inkind_dry_owed
recode land_rental_cash_rainy_recd land_rental_inkind_rainy_recd land_rental_cash_rainy_owed land_rental_inkind_rainy_owed land_rental_cash_dry_recd land_rental_inkind_dry_recd land_rental_cash_dry_owed land_rental_inkind_dry_owed (.=0)
gen land_rental_income_rainyseason= land_rental_cash_rainy_recd + land_rental_inkind_rainy_recd + land_rental_cash_rainy_owed + land_rental_inkind_rainy_owed
gen land_rental_income_dryseason= land_rental_cash_dry_recd + land_rental_inkind_dry_recd + land_rental_cash_dry_owed + land_rental_inkind_dry_owed 
gen land_rental_income = land_rental_income_rainyseason + land_rental_income_dryseason
collapse (sum) land_rental_income, by (case_id)
lab var land_rental_income "Estimated income from renting out land over previous 12 months"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_land_rental_income.dta", replace //ALT: only 13 non-0 obs in MW1


********************************************************************************
* FARM SIZE / LAND SIZE *
********************************************************************************

***Determining whether crops were grown on a plot
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_g.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_m.dta"
ren ag_g0b plot_id
drop if plot_id==""
drop if ag_g0d==. // crop code
gen crop_grown = 1 
collapse (max) crop_grown, by(case_id plot_id)
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crops_grown.dta", replace
***

use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_k.dta", clear
rename plotid plot_id
tempfile ag_mod_k_numeric
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_ag_mod_k_temp.dta", replace  // VAP:Renaming plot ids, to work with Module D and K together.
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_d.dta", clear
rename ag_d00 plot_id
append using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_ag_mod_k_temp.dta"
gen cultivated = (ag_d14==1 | ag_k15==1) // VAP: cultivated plots in rainy or dry seasons
collapse (max) cultivated, by (case_id plot_id)
lab var cultivated "1= Parcel was cultivated in this data set"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_parcels_cultivated.dta", replace

use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_parcels_cultivated.dta", clear
merge 1:1 case_id plot_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_areas.dta",
drop if _merge==2
keep if cultivated==1
replace area_acres_meas=. if area_acres_meas<0 
replace area_acres_meas = area_acres_est if area_acres_meas==. 
collapse (sum) area_acres_meas, by (case_id)
rename area_acres_meas farm_area
replace farm_area = farm_area * (1/2.47105) /* Convert to hectares */ 
lab var farm_area "Land size (denominator for land productivitiy), in hectares" 
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_land_size.dta", replace

* All agricultural land
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_d.dta", clear
rename ag_d00 plot_id
append using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_ag_mod_k_temp.dta"
drop if plot_id==""
merge m:1 case_id plot_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_crops_grown.dta", nogen
// ALT: VAP tracks match rates in this section, so here they are for MW1 
* 6370 matched
*618 not matched from master
*21 not matched from using
gen rented_out = (ag_d14==2 |ag_k15==2)
gen cultivated_dry = (ag_k15==1)
bys case_id plot_id: egen plot_cult_dry = max(cultivated_dry)
replace rented_out = 0 if plot_cult_dry==1 // VAP: From TZ:If cultivated in short season, not considered rented out in long season.
// TZ code commented out the below:
* drop if rented_out==1
* 62 obs dropped
//
drop if rented_out==1 & crop_grown!=1
* ALT: 16 obs dropped
gen agland = (ag_d14==1 | ag_d14==4 |ag_k15==1 | ag_k15==4) // All cultivated AND fallow plots, forests/woodlot & pasture is captured within "other" (can't be separated out)
// TZ code commented out the below:
*keep if agland==1
*4,360 obs dropped 
//DMC adding 6.25.19 
drop if agland!=1 & crop_grown==.
* ALT: 171 obs dropped
collapse (max) agland, by (case_id plot_id)
lab var agland "1= Parcel was used for crop cultivation or left fallow in this past year (forestland and other uses excluded)" //This label is too long and gets truncated
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_parcels_agland.dta", replace

use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_parcels_agland.dta", clear
merge 1:1 case_id plot_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_areas.dta"
*42 not matched from master
drop if _merge==2
replace area_acres_meas=. if area_acres_meas<0
replace area_acres_meas = area_acres_est if area_acres_meas==. 
replace area_acres_meas = area_acres_est if area_acres_meas==0 & (area_acres_est>0 & area_acres_est!=.)		
collapse (sum) area_acres_meas, by (case_id)
rename area_acres_meas farm_size_agland
replace farm_size_agland = farm_size_agland * (1/2.47105) /* Convert to hectares */
lab var farm_size_agland "Land size in hectares, including all plots cultivated or left fallow" 
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_farmsize_all_agland.dta", replace


use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_d.dta", clear
append using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_ag_mod_k_temp.dta"
drop if plot_id=="" //Drops a lot of obs
gen rented_out = (ag_d14==2 | ag_d14==3 | ag_k15==2 | ag_k15==3) // ALT/VAP: rented out (2) & gave out for free (3)
gen cultivated_dry = (ag_k15==1)
bys case_id plot_id: egen plot_cult_dry = max(cultivated_dry)
replace rented_out = 0 if plot_cult_dry==1 // If cultivated in dry season, not considered rented out in rainy season.
drop if rented_out==1
gen plot_held = 1
collapse (max) plot_held, by (case_id plot_id)
lab var plot_held "1= Parcel was NOT rented out in the main season"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_parcels_held.dta", replace

use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_parcels_held.dta", clear
merge 1:1 case_id plot_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_areas.dta"
drop if _merge==2
replace area_acres_meas=. if area_acres_meas<0
replace area_acres_meas = area_acres_est if area_acres_meas==. 
collapse (sum) area_acres_meas, by (case_id)
rename area_acres_meas land_size
lab var land_size "Land size in hectares, including all plots listed by the household except those rented out" 
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_land_size_all.dta", replace

*Total land holding including cultivated and rented out
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_d.dta", clear
rename ag_d00 plot_id
append using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_ag_mod_k_temp.dta"
drop if plot_id==""
merge m:1 case_id plot_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_areas.dta", nogen keep(1 3)
replace area_acres_meas=. if area_acres_meas<0
replace area_acres_meas = area_acres_est if area_acres_meas==. 
replace area_acres_meas = area_acres_est if area_acres_meas==0 & (area_acres_est>0 & area_acres_est!=.)	
collapse (max) area_acres_meas, by(case_id plot_id)
rename area_acres_meas land_size_total
collapse (sum) land_size_total, by(case_id)
replace land_size_total = land_size_total * (1/2.47105) /* Convert to hectares */
lab var land_size_total "Total land size in hectares, including rented in and rented out plots"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_land_size_total.dta", replace

//ALT 10.18.19: This code runs with only minor changes, but I'm not sure if this is doing the thing it's supposed to be doing. We start with ~7k plots and end with 2.6k

********************************************************************************
* OFF-FARM HOURS *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_e.dta", clear
gen primary_hours = hh_e24 if !inlist(hh_e19b, 62, 63, 64, 71) & hh_e19b!=. 
*VAP: Excluding agr. & animal husbandry workers, forestry workers, fishermen & hunters, miners & quarrymen per TZ. 
gen secondary_hours = hh_e38 if hh_e33b!=21 & hh_e33b!=.  
* VAP: Excluding ag & animal husbandry. Confirm use of occup. code variabe hh_e33b
gen ownbiz_hours =  hh_e08 + hh_e09 // VAP: TZ used # of hrs as unpaid family worker on non-farm hh. biz. 
* VAP: For MW2, I am using "How many hours in the last seven days did you run or do any kind of non-agricultural or non-fishing 
* household business, big or small, for yourself?" &
* "How many hours in the last seven days did you help in any of the household's non-agricultural or non-fishing household businesses, if any"?
//ALT: Ditto for MW1
egen off_farm_hours = rowtotal(primary_hours secondary_hours ownbiz_hours)
gen off_farm_any_count = off_farm_hours!=0
gen member_count = 1
collapse (sum) off_farm_hours off_farm_any_count member_count, by(case_id)
la var member_count "Number of HH members age 5 or above"
la var off_farm_any_count "Number of HH members with positive off-farm hours"
la var off_farm_hours "Total household off-farm hours"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_off_farm_hours.dta", replace

//ALT 10.18.19: This estimates hours per week. Do we want that?

********************************************************************************
* FARM LABOR *
********************************************************************************
** Family labor
* Rainy Season
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_d.dta", clear
rename ag_d47c landprep_women  // # of days women hired for land preparation, planting, ridging, weeding and fertilizing
rename ag_d47a landprep_men   // # of days men hired for land preparation, planting, ridging, weeding and fertilizing
rename ag_d47e landprep_child // # of days children hired for land preparation, planting, ridging, weeding and fertilizing 
rename ag_d48a harvest_men    // # of days men hired for harvesting
rename ag_d48c harvest_women // # of days women hired for harvesting
rename ag_d48e harvest_child // # of days children hired for harvesting
recode landprep_women landprep_men landprep_child harvest_men harvest_women harvest_child (.=0)
egen days_hired_rainyseason = rowtotal(landprep_women landprep_men landprep_child harvest_men harvest_women harvest_child) 
recode ag_d42c ag_d42g ag_d42k ag_d42o(.=0)  // # of days per week spent by hh.members (upto 4) in land prep/planting
egen days_flab_landprep = rowtotal(ag_d42c ag_d42g ag_d42k ag_d42o)
recode ag_d43c ag_d43g ag_d43k ag_d43o (.=0) // # of days per week spent by hh.members (upto 4) in weeding, fertilizing and/or any other non-harvest activity
egen days_flab_weeding = rowtotal(ag_d43c ag_d43g ag_d43k ag_d43o)
recode ag_d44c ag_d44g ag_d44k ag_d44o (.=0) // # of days per week spent by hh.members (upto 4) in harvesting
egen days_flab_harvest = rowtotal(ag_d44c ag_d44g ag_d44k ag_d44o)
gen days_famlabor_rainyseason = days_flab_landprep + days_flab_weeding + days_flab_harvest
ren ag_d00 plot_id
collapse (sum) days_hired_rainyseason days_famlabor_rainyseason, by (case_id plot_id)
lab var days_hired_rainyseason  "Workdays for hired labor (crops) in rainy season"
lab var days_famlabor_rainyseason  "Workdays for family labor (crops) in rainy season"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_farmlabor_rainyseason.dta", replace

* Dry Season
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_k.dta", clear
rename ag_k46a no_days_men_all
rename ag_k46c no_days_women_all 
rename ag_k46e no_days_chldrn_all 
recode no_days_men_all no_days_women_all no_days_chldrn_all(.=0)
egen days_hired_dryseason = rowtotal(no_days_men_all no_days_women_all no_days_chldrn_all) 
recode ag_k43c ag_k43g ag_k43k ag_k43o(.=0) // # of days per week spent by hh.members (upto 4) in land prep/planting
egen days_flab_landprep = rowtotal(ag_k43c ag_k43g ag_k43k ag_k43o)
recode ag_k44c ag_k44g ag_k44k ag_k44o (.=0) // # of days per week spent by hh.members (upto 4) in weeding, fertilizing and/or any other non-harvest activity
egen days_flab_weeding = rowtotal(ag_k44c ag_k44g ag_k44k ag_k44o)
recode ag_k45c ag_k45g ag_k45k ag_k45o(.=0) // # of days per week spent by hh.members (upto 4) in harvesting
egen days_flab_harvest = rowtotal(ag_k45c ag_k45g ag_k45k ag_k45o)
gen days_famlabor_dryseason = days_flab_landprep + days_flab_weeding + days_flab_harvest
ren plotid plot_id
collapse (sum) days_hired_dryseason days_famlabor_dryseason, by (case_id plot_id)
lab var days_hired_dryseason  "Workdays for hired labor (crops) in dry season"
lab var days_famlabor_dryseason  "Workdays for family labor (crops) in dry season"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_farmlabor_dryseason.dta", replace


*Hired Labor
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_farmlabor_rainyseason.dta", clear
merge 1:1 case_id plot_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_farmlabor_dryseason.dta"
drop _merge
recode days*  (.=0)
collapse (sum) days*, by(case_id plot_id)
egen labor_hired =rowtotal(days_hired_rainyseason days_hired_dryseason)
egen labor_family=rowtotal(days_famlabor_rainyseason  days_famlabor_dryseason)
egen labor_total = rowtotal(days_hired_rainyseason days_famlabor_rainyseason days_hired_dryseason days_famlabor_dryseason)
lab var labor_total "Total labor days (family, hired, or other) allocated to the farm"
lab var labor_hired "Total labor days (hired) allocated to the farm"
lab var labor_family "Total labor days (family) allocated to the farm"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_family_hired_labor.dta", replace
collapse (sum) labor_*, by(case_id)
lab var labor_total "Total labor days (family, hired, or other) allocated to the farm"
lab var labor_hired "Total labor days (hired) allocated to the farm"
lab var labor_family "Total labor days (family) allocated to the farm"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_family_hired_labor.dta", replace

//ALT 10.18.19 - No major modifications

********************************************************************************
* VACCINE USAGE *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_r1.dta", clear
gen vac_animal=ag_r24>0
* MW2: How many of your[Livestock] are currently vaccinated? 
* TZ: Did you vaccinate your[ANIMAL] in the past 12 months? 
replace vac_animal = 0 if ag_r24==0  
replace vac_animal = . if ag_r24==. // VAP: 4092 observations on a hh-animal level

*Disagregating vaccine usage by animal type 
rename ag_r0a livestock_code
gen species = (inlist(livestock_code, 301,302,303,304)) + 2*(inlist(livestock_code,307,308)) + 3*(livestock_code==309) + 4*(inlist(livestock_code,305, 306)) + 5*(inlist(livestock_code, 310,311,312,313,314,315,316))
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

collapse (max) vac_animal*, by (case_id)
// ALT/VAP: After collapsing, the data is on hh level, vac_animal now has 2666 obs
lab var vac_animal "1=Household has an animal vaccinated"
	foreach i in vac_animal {
		local l`i' : var lab `i'
		lab var `i'_lrum "`l`i'' - large ruminants"
		lab var `i'_srum "`l`i'' - small ruminants"
		lab var `i'_pigs "`l`i'' - pigs"
		lab var `i'_equine "`l`i'' - equine"
		lab var `i'_poultry "`l`i'' - poultry"
	}
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_vaccine.dta", replace

use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_r1.dta", clear
gen all_vac_animal=ag_r24>0
* MW2: How many of your[Livestock] are currently vaccinated? 
* TZ: Did you vaccinate your[ANIMAL] in the past 12 months? 
replace all_vac_animal = 0 if ag_r24==0  
replace all_vac_animal = . if ag_r24==.
keep case_id ag_r06a ag_r06b all_vac_animal
ren ag_r06a farmerid1
ren ag_r06b farmerid2
gen t=1
gen patid=sum(t)
reshape long farmerid, i(patid) j(idnum)
drop t patid

/*
preserve 
ren ag_r06a farmerid // ID1: who is resp. for keeping [ANIMAL]
tempfile farmer1
save `farmer1'
restore
preserve 
ren ag_r06b farmerid // ID2: who is resp. for keeping [ANIMAL]
tempfile farmer2
save `farmer2'
restore

use   `farmer1', replace
append using  `farmer2'
*/

collapse (max) all_vac_animal , by(case_id farmerid)
gen personid=farmerid
drop if personid==.
merge 1:1 case_id personid using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_gender_merge.dta", nogen
lab var all_vac_animal "1 = Individual farmer (livestock keeper) uses vaccines"
ren personid indidy2
gen livestock_keeper=1 if farmerid!=.
recode livestock_keeper (.=0)
lab var livestock_keeper "1=Indvidual is listed as a livestock keeper (at least one type of livestock)" 
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_farmer_vaccine.dta", replace


********************************************************************************
* ANIMAL HEALTH - DISEASES *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_r1.dta", clear
gen disease_animal = 1 if ag_r22==1 // Answered "yes" for "Did livestock suffer from any disease in last 12m?"
//replace disease_animal = 0 if inlist(ag_r22,0,2,3,4,6,9) // VAP: 2=No disease, other category numbers are unnamed, dropping these. //ALT: Only y/n in MW1
replace disease_animal = . if (ag_r22==.) 
* VAP: TZ main diseases: FMD, lumpy skin, brucelosis, CCPP, BQ. MW2 has different main diseases. 
* ALT: Keeping the same ones for MW1
gen disease_ASF = ag_r23a==14  //  African swine fever
gen disease_amapl = ag_r23a==22 // Amaplasmosis
gen disease_bruc = ag_r23a== 1 // Brucelosis
gen disease_mange = ag_r23a==20 // Mange
gen disease_NC= ag_r23a==10 // New Castle disease
gen disease_spox= ag_r23a==11 // Small pox
gen disease_other = inrange(ag_r23a, 2, 9) | inrange(ag_r23a, 12, 13) | inrange(ag_r23a,15,19) | ag_r23a==21 | ag_r23a > 22 //ALT: adding "other" category to capture rarer diseases. Either useful or useless b/c every household had something in that category

rename ag_r0a livestock_code
gen species = (inlist(livestock_code, 301,302,303,304)) + 2*(inlist(livestock_code,307,308)) + 3*(livestock_code==309) + 4*(inlist(livestock_code,305, 306)) + 5*(inlist(livestock_code, 310,311,312,313,314,315,316))
recode species (0=.)
la def species 1 "Large ruminants (cows, buffalos)" 2 "Small ruminants (sheep, goats)" 3 "Pigs" 4 "Equine (horses, donkeys)" 5 "Poultry"
la val species species

*A loop to create species variables
foreach i in disease_animal disease_ASF disease_amapl disease_bruc disease_mange disease_NC disease_spox disease_other{
	gen `i'_lrum = `i' if species==1
	gen `i'_srum = `i' if species==2
	gen `i'_pigs = `i' if species==3
	gen `i'_equine = `i' if species==4
	gen `i'_poultry = `i' if species==5
}

collapse (max) disease_*, by (case_id)
lab var disease_animal "1= Household has animal that suffered from disease"
lab var disease_ASF "1= Household has animal that suffered from African Swine Fever"
lab var disease_amapl"1= Household has animal that suffered from amaplasmosis disease"
lab var disease_bruc"1= Household has animal that suffered from brucelosis"
lab var disease_mange "1= Household has animal that suffered from mange disease"
lab var disease_NC "1= Household has animal that suffered from New Castle disease"
lab var disease_spox "1= Household has animal that suffered from small pox"
lab var disease_other "1=Household has animal that had another disease"

	foreach i in disease_animal disease_ASF disease_amapl disease_bruc disease_mange disease_NC disease_spox disease_other{
		local l`i' : var lab `i'
		lab var `i'_lrum "`l`i'' - large ruminants"
		lab var `i'_srum "`l`i'' - small ruminants"
		lab var `i'_pigs "`l`i'' - pigs"
		lab var `i'_equine "`l`i'' - equine"
		lab var `i'_poultry "`l`i'' - poultry"
	}

save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_livestock_diseases.dta", replace

********************************************************************************
* LIVESTOCK WATER, FEEDING, AND HOUSING *
********************************************************************************
*Skipped in MW2 b/c no qs. MW1 has questions about feed and other inputs,
*but nothing about water/housing. Omitting this section - ALT 10.21.19

********************************************************************************
* USE OF INORGANIC FERTILIZER *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_d.dta", clear
append using "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_k.dta" 
gen use_inorg_fert=.
replace use_inorg_fert=0 if ag_d38==2| ag_k39==2
replace use_inorg_fert=1 if ag_d38==1| ag_k39==1
recode use_inorg_fert (.=0)
collapse (max) use_inorg_fert, by (case_id)
lab var use_inorg_fert "1 = Household uses inorganic fertilizer"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_fert_use.dta", replace

*Fertilizer use by farmers (a farmer is an individual listed as plot manager)
use "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_d.dta", clear
append using "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_k.dta" 
gen all_use_inorg_fert=(ag_d38==1 | ag_k39==1)

ren ag_d01 farmerid
replace farmerid= ag_k02 if farmerid==.
//No secondary/tertiary managers in MW1
/*ren ag_d01_2a farmerid2
replace farmerid= ag_k02_2a if farmerid2==.
ren ag_d01_2b farmerid3
replace farmerid= ag_k02_2b if farmerid3==.	

gen t = 1
gen patid = sum(t)

reshape long farmerid, i(patid) j(decisionmakerid)
drop t patid
*/
//As above, this code is a clunky way of merging everything into a single column. I'm using reshape long - ALT 10.21.19
/*preserve
keep case_id ag_d01 ag_k02 all_use_inorg_fert // VAP: primary decisionmaker for plot
ren ag_d01 farmerid 
replace farmerid= ag_k02 if farmerid==.
tempfile farmer1
save `farmer1'
restore
preserve
keep case_id ag_d01_2a ag_k02_2a  all_use_inorg_fert // VAP: other plot decisiomaker #1
ren ag_d01_2a farmerid
replace farmerid= ag_k02_2a if farmerid==.
tempfile farmer2
save `farmer2'
restore
preserve
keep case_id ag_d01_2b ag_k02_2b all_use_inorg_fert // VAP: other plot decisiomaker #2
ren ag_d01_2b farmerid
replace farmerid= ag_k02_2b if farmerid==.		
tempfile farmer3
save `farmer3'
restore

use   `farmer1', replace
append using  `farmer2'
append using  `farmer3'*/


collapse (max) all_use_inorg_fert , by(case_id farmerid)
gen personid=farmerid
drop if personid==.
merge 1:1 case_id personid using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_gender_merge.dta", nogen

lab var all_use_inorg_fert "1 = Individual farmer (plot manager) uses inorganic fertilizer"
ren personid indidy2
gen farm_manager=1 if farmerid!=.
recode farm_manager (.=0)
lab var farm_manager "1=Individual is listed as a manager for at least one plot" 
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_farmer_fert_use.dta", replace

********************************************************************************
* FERTILIZER APPLICATION RATE *
********************************************************************************
//Shelved pending agreement on conversion
use "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_d.dta", clear
append using "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_k.dta" 

********************************************************************************
* USE OF IMPROVED SEED *
********************************************************************************
/* ALT 10.21.19 - MW2 does not distinguish between traditional/improved
In MW1, the enumerator lists the variety, so it might be possible to do this
section for some crops. */

********************************************************************************
* REACHED BY AG EXTENSION *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_t1.dta", clear
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
gen advice_electronicmedia = (sourceid==12 & receive_advice==1) // electronic media:TV/Radio
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
*Five new variables  ext_reach_all, ext_reach_public, ext_reach_private, ext_reach_unspecified, ext_reach_ict  // VAP: Added new variables to categories based on MW2 data, please check. 
gen ext_reach_public=(advice_gov==1)
gen ext_reach_private=(advice_ngo==1 | advice_coop==1 | advice_pvt)
gen ext_reach_unspecified=(advice_neigh==1 | advice_pub==1 | advice_other==1 | advice_farmer==1 | advice_ffd==1 | advice_course==1 | advice_village==1)
gen ext_reach_ict=(advice_electronicmedia==1)
gen ext_reach_all=(ext_reach_public==1 | ext_reach_private==1 | ext_reach_unspecified==1 | ext_reach_ict==1)

collapse (max) ext_reach_* , by (case_id)
lab var ext_reach_all "1 = Household reached by extension services - all sources"
lab var ext_reach_public "1 = Household reached by extension services - public sources"
lab var ext_reach_private "1 = Household reached by extension services - private sources"
lab var ext_reach_unspecified "1 = Household reached by extension services - unspecified sources"
lab var ext_reach_ict "1 = Household reached by extension services through ICT"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_any_ext.dta", replace

//ALT 10.21.19: Similar between W1 and W2. I did not change VAP's code for this section.

********************************************************************************
* USE OF FORMAL FINANCIAL SERVICES *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_f.dta", clear
append using "${Malawi_IHS_W1_raw_data}\Household\hh_mod_s1.dta"
gen borrow_bank= hh_s04==10 // VAP: Code source of loan. No microfinance or mortgage loan in Malawi W2 unlike TZ. 
gen borrow_relative=hh_s04==1 // NA in TZ
gen borrow_moneylender=hh_s04==4 // NA in TZ
gen borrow_grocer=hh_s04==3 // local grocery/merchant
gen borrow_relig=hh_s04==6 // religious institution
gen borrow_other_fin=hh_s04==7|hh_s04==8|hh_s04==9 // VAP: MARDEF, MRFC, SACCO
gen borrow_neigh=hh_s04==2
gen borrow_employer=hh_s04==5
gen borrow_ngo=hh_s04==11
gen borrow_other=hh_s04==12

// gen use_bank_acount=hh_f52==1 ALT: Not in MW1
// VAP: No MM for MW2.  
// gen use_MM=hh_q01_1==1 | hh_q01_2==1 | hh_q01_3==1 | hh_q01_4==1 // use any MM services - MPESA ZPESA AIRTEL TIGO PESA. 
//gen use_fin_serv_bank= use_bank_acount==1
gen use_fin_serv_credit= borrow_bank==1  | borrow_other_fin==1 // VAP: Include religious institution in this definition? No mortgage.  
// VAP: No digital and insurance in MW2
// gen use_fin_serv_insur= borrow_insurance==1
// gen use_fin_serv_digital=use_MM==1
gen use_fin_serv_others= borrow_other_fin==1
gen use_fin_serv_all=/*use_fin_serv_bank==1 |*/ use_fin_serv_credit==1 |  use_fin_serv_others==1 /*use_fin_serv_insur==1 | use_fin_serv_digital==1 */ 
recode use_fin_serv* (.=0)

collapse (max) use_fin_serv_*, by (case_id)
lab var use_fin_serv_all "1= Household uses formal financial services - all types"
//lab var use_fin_serv_bank "1= Household uses formal financial services - bank accout"
lab var use_fin_serv_credit "1= Household uses formal financial services - credit"
// lab var use_fin_serv_insur "1= Household uses formal financial services - insurance"
// lab var use_fin_serv_digital "1= Household uses formal financial services - digital"
lab var use_fin_serv_others "1= Household uses formal financial services - others"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_fin_serv.dta", replace


********************************************************************************
* MILK PRODUCTIVITY *
********************************************************************************
*Total production
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_s.dta", clear
rename ag_s0a product_code
keep if product_code==401
rename ag_s02 months_milked // VAP: During the last 12 months, for how many months did your household produce any [PRODUCT]?
rename ag_s03a qty_milk_per_month // VAP: During these months, what was the average quantity of [PRODUCT] produced PER MONTH?. 
gen milk_liters_produced = months_milked * qty_milk_per_month if ag_s03b==1 // Liters only, omits kg (1), piece (3), other (1)
lab var milk_liters_produced "Liters of milk produced in past 12 months"

* lab var milk_animals "Number of large ruminants that was milk (household)": Not available in MW2 
lab var months_milked "Average months milked in last year (household)"
*lab var liters_per_largeruminant "average quantity (liters) per year (household)"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_milk_animals.dta", replace


********************************************************************************
* EGG PRODUCTIVITY *
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_r1.dta", clear
rename ag_r0a livestock_code
gen poultry_owned = ag_r02 if inlist(livestock_code, 310,311,312,313,314,315,316) // For MW2: local hen, local cock, duck, other, dove/pigeon, chicken layer/chicken-broiler and turkey/guinea fowl
collapse (sum) poultry_owned, by(case_id)
tempfile eggs_animals_hh 
save `eggs_animals_hh'

use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_s.dta", clear
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
collapse (sum) eggs_per_month (max) eggs_months, by (case_id) // VAP: Collapsing chicken & guinea fowl eggs
gen eggs_total_year = eggs_months* eggs_per_month // Units are pieces for eggs 
merge 1:1 case_id using  `eggs_animals_hh', nogen keep(1 3)			
keep case_id eggs_months eggs_per_month eggs_total_year poultry_owned 

lab var eggs_months "Number of months eggs were produced (household)"
lab var eggs_per_month "Number of eggs that were produced per month (household)"
lab var eggs_total_year "Total number of eggs that was produced in a year (household)"
lab var poultry_owned "Total number of poultry owned (household)"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_eggs_animals.dta", replace


//ALT 09.19.22: This should get removed following changeover to new crops code.
********************************************************************************
* LAND RENTAL *
********************************************************************************
//This area issue - no region var
* Rainy Season *
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_c.dta", clear		
rename ag_c00 plot_id
gen area_acres_est = ag_c04a if ag_c04b == 1
replace area_acres_est = (ag_c04a*2.47105) if ag_c04b == 2 & area_acres_est ==.  // ha to acres
replace area_acres_est = (ag_c04a*0.000247105) if ag_c04b == 3 & area_acres_est ==. // m-sq to acres
gen area_acres_meas = ag_c04c
keep if area_acres_est !=.
gen area_est_hectares=area_acres_est* (1/2.47105)  // farmer estimated
gen area_meas_hectares= area_acres_meas* (1/2.47105) // GPS area
keep case_id plot_id area_est_hectares area_meas_hectares
lab var area_meas_hectares "Plot area in hectares (GPSd)"
lab var area_est_hectares "Plot area in hectares (estimated)"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_area_rainyseason.dta", replace


*Getting plot rental rate
use "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_d.dta", clear
rename ag_d00 plot_id

duplicates drop plot_id case_id, force //ALT: 1 duplicate record 
merge 1:1 plot_id case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_area_rainyseason.dta", nogen		
drop if plot_id=="" 
gen cultivated = ag_d14==1 | ag_d20a!=0
gen dry = 0 //ALT: Needed to sort out dry season duplicates. 
merge m:1 case_id plot_id dry using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_decision_makers.dta", nogen keep (1 3) //ALT: Before code fix in dm_gender, 719 obs from master not matched; now: 122

gen rental_cost_land_cshpd = ag_d11a //rainy season, cash already paid
gen rental_cost_land_kindpd = ag_d11b //rainy season, in-kind already paid
gen rental_cost_land_cshfut = ag_d11c //rainy season, future cash payment owed
gen rental_cost_land_kindfut = ag_d11d //rainy season,in-kind payment owed
recode rental_cost_land_cshpd rental_cost_land_kindpd rental_cost_land_cshfut rental_cost_land_kindfut (.=0)
gen plot_rental_rate = rental_cost_land_cshpd + rental_cost_land_kindpd + rental_cost_land_cshfut + rental_cost_land_kindfut
recode plot_rental_rate (0=.) 
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_rent_nomiss_rainyseason.dta", replace //471 obs

preserve
	gen value_rented_land_male = plot_rental_rate if dm_gender==1
	gen value_rented_land_female = plot_rental_rate if dm_gender==2
	// gen value_rented_land_mixed = plot_rental_rate if dm_gender==3
	collapse (sum) value_rented_land_* value_rented_land = plot_rental_rate, by(case_id) //478 hhs with data
	lab var value_rented_land_male "Value of rented land (male-managed plot)
	lab var value_rented_land_female "Value of rented land (female-managed plot)
	// lab var value_rented_land_mixed "Value of rented land (mixed-managed plot)"
	save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_rental_rate_rainyseason.dta", replace
restore
 
gen ha_rental_rate_hh = plot_rental_rate/area_meas_hectares
preserve
	keep if plot_rental_rate!=. & plot_rental_rate!=0			
	collapse (sum) plot_rental_rate area_meas_hectares, by(case_id)		
	gen ha_rental_hh_rs = plot_rental_rate/area_meas_hectares	//400 entries w/ data here			
	keep ha_rental_hh_rs case_id
	lab var ha_rental_hh_rs "Area of rented plot during the rainy season"
	save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_rental_rate_hhid_rainyseason.dta", replace
restore

*Merging in geographic variables
merge m:1 case_id using "${Malawi_IHS_W1_raw_data}\Household\hh_mod_a_filt.dta", nogen assert(2 3) keep(3)
rename hh_a02 ta
rename ea_id ea
rename hh_a01 district	
gen region = . 
replace region = 1 if stratum == 1 | stratum == 2
replace region = 2 if stratum == 3 | stratum == 4
replace region = 3 if stratum == 5 | stratum == 6
*Geographic medians
bys region district ta ea: egen ha_rental_count_ea = count(ha_rental_rate_hh) // region, district, ta, ea (TZ had ward & village instead of ta & EA)
bys region district ta ea: egen ha_rental_rate_ea = median(ha_rental_rate_hh)

bys region district ta: egen ha_rental_count_ta = count(ha_rental_rate_hh)
bys region district ta: egen ha_rental_rate_ta = median(ha_rental_rate_hh)

bys region district: egen ha_rental_count_dist = count(ha_rental_rate_hh)
bys region district: egen ha_rental_rate_dist = median(ha_rental_rate_hh)

bys region: egen ha_rental_count_reg = count(ha_rental_rate_hh)
bys region: egen ha_rental_rate_reg = median(ha_rental_rate_hh)

egen ha_rental_rate_nat = median(ha_rental_rate_hh)
*Now, getting median rental rate at the lowest level of aggregation with at least ten observations
gen ha_rental_rate = ha_rental_rate_ea if ha_rental_count_ea>=10		
replace ha_rental_rate = ha_rental_rate_ta if ha_rental_count_ta>=10 & ha_rental_rate==.	
replace ha_rental_rate = ha_rental_rate_dist if ha_rental_count_dist>=10 & ha_rental_rate==.	
replace ha_rental_rate = ha_rental_rate_reg if ha_rental_count_reg>=10 & ha_rental_rate==.		
replace ha_rental_rate = ha_rental_rate_nat if ha_rental_rate==.				
collapse (firstnm) ha_rental_rate, by(region district ta ea)
lab var ha_rental_rate "Land rental rate per ha"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_rental_rate_rainyseason.dta", replace


* Dry Season *  
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_j.dta", clear
		
rename ag_j00 plot_id
gen area_acres_est = ag_j05a if ag_j05b == 1
replace area_acres_est = (ag_j05a*0.000247105) if ag_j05b == 3 & area_acres_est ==. // m-sq to acres
gen area_acres_meas = ag_j05c
keep if area_acres_est !=.
gen area_est_hectares=area_acres_est* (1/2.47105)  // farmer estimated
gen area_meas_hectares= area_acres_meas* (1/2.47105) // GPS area
keep case_id plot_id area_est_hectares area_meas_hectares
lab var area_meas_hectares "Plot area in hectares (GPSd)"
lab var area_est_hectares "Plot area in hectares (estimated)"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_area_dryseason.dta", replace

*Getting plot rental rate 
use "${Malawi_IHS_W1_raw_data}/Agriculture/ag_mod_k.dta", clear
rename plotid plot_id
drop if plot_id=="" 
gen cultivated = ag_k15==1
gen dry = 1
merge m:1 case_id plot_id dry using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_decision_makers.dta", nogen keep (1 3) //1217 uncultivated plots in master not matched
duplicates drop case_id plot_id, force //ALT: 3 duplicate records
merge 1:1 plot_id case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_area_dryseason.dta", nogen //1167 from master not matched (uncultivated)

gen rental_cost_land_cshpd = ag_k12a //dry season, cash already paid
gen rental_cost_land_kindpd = ag_k12b //dry season, in-kind already paid
gen rental_cost_land_cshfut = ag_k12c //dry season, future cash payment owed
gen rental_cost_land_kindfut = ag_k12d //dry season,in-kind payment owed
recode rental_cost_land_cshpd rental_cost_land_kindpd rental_cost_land_cshfut rental_cost_land_kindfut (.=0)
gen plot_rental_rate = rental_cost_land_cshpd + rental_cost_land_kindpd + rental_cost_land_cshfut + rental_cost_land_kindfut
recode plot_rental_rate (0=.) 
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_rent_nomiss_dryseason.dta", replace

preserve
	gen value_rented_land_male = plot_rental_rate if dm_gender==1
	gen value_rented_land_female = plot_rental_rate if dm_gender==2
	// gen value_rented_land_mixed = plot_rental_rate if dm_gender==3
	collapse (sum) value_rented_land_* value_rented_land = plot_rental_rate, by(case_id)
	lab var value_rented_land_male "Value of rented land (male-managed plot)"
	lab var value_rented_land_female "Value of rented land (female-managed plot)"
	// lab var value_rented_land_mixed "Value of rented land (mixed-managed plot)"
	save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_rental_rate_dryseason.dta", replace
restore
 
gen ha_rental_rate_hh = plot_rental_rate/area_meas_hectares
preserve
	keep if plot_rental_rate!=. & plot_rental_rate!=0			
	collapse (sum) plot_rental_rate area_meas_hectares, by(case_id)		
	gen ha_rental_hh_ds = plot_rental_rate/area_meas_hectares				
	keep ha_rental_hh_ds case_id
	lab var ha_rental_hh_ds "Area of rented plot during the dry season"
	save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_rental_rate_hhid_dryseason.dta", replace
restore

*Merging in geographic variables
merge m:1 case_id using "${Malawi_IHS_W1_raw_data}\Household\hh_mod_a_filt.dta", nogen assert(2 3) keep(3)
rename hh_a02 ta
rename hh_a01 district
rename ea_id ea
gen region = . 
replace region = 1 if stratum == 1 | stratum == 2
replace region = 2 if stratum == 3 | stratum == 4
replace region = 3 if stratum == 5 | stratum == 6

*Geographic medians
bys region district ta ea: egen ha_rental_count_ea = count(ha_rental_rate_hh) // region, district, ta, ea (TZ had ward & village instead of ta & EA)
bys region district ta ea: egen ha_rental_rate_ea = median(ha_rental_rate_hh)

bys region district ta: egen ha_rental_count_ta = count(ha_rental_rate_hh)
bys region district ta: egen ha_rental_rate_ta = median(ha_rental_rate_hh)

bys district: egen ha_rental_count_dist = count(ha_rental_rate_hh)
bys district: egen ha_rental_rate_dist = median(ha_rental_rate_hh)

bys region: egen ha_rental_count_reg = count(ha_rental_rate_hh)
bys region: egen ha_rental_rate_reg = median(ha_rental_rate_hh)

egen ha_rental_rate_nat = median(ha_rental_rate_hh)
*Now, getting median rental rate at the lowest level of aggregation with at least ten observations
gen ha_rental_rate = ha_rental_rate_ea if ha_rental_count_ea>=10		
replace ha_rental_rate = ha_rental_rate_ta if ha_rental_count_ta>=10 & ha_rental_rate==.	
replace ha_rental_rate = ha_rental_rate_dist if ha_rental_count_dist>=10 & ha_rental_rate==.	
replace ha_rental_rate = ha_rental_rate_reg if ha_rental_count_reg>=10 & ha_rental_rate==.		
replace ha_rental_rate = ha_rental_rate_nat if ha_rental_rate==.				
collapse (firstnm) ha_rental_rate, by(region district ta ea)
lab var ha_rental_rate "Land rental rate per ha in dry season"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_rental_rate_dryseason.dta", replace

*Now getting total ha of all plots that were cultivated at least once 
use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_rent_nomiss_rainyseason.dta", clear
append using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_rent_nomiss_dryseason.dta"
collapse (max) cultivated area_meas_hectares, by(case_id plot_id)		// collapsing down to household-plot level
gen ha_cultivated_plots = area_meas_hectares if cultivate==1			// non-missing only if plot was cultivated in at least one season
collapse (sum) ha_cultivated_plots, by(case_id)				// total ha of all plots that were cultivated in at least one season
lab var ha_cultivated_plots "Area of cultivated plots (ha)"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_cultivated_plots_ha.dta", replace

use "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_rental_rate_rainyseason.dta", clear
append using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_rental_rate_dryseason.dta"
collapse (sum) value_rented_land*, by(case_id)		// total over BOTH seasons (total spent on rent over course of entire year)
lab var value_rented_land "Value of rented land (household expenditures)"
lab var value_rented_land_male "Value of rented land (household expenditures - male-managed plots)"
lab var value_rented_land_female "Value of rented land (household expenditures - female-managed plots)"
// lab var value_rented_land_mixed "Value of rented land (household expenditures - mixed-managed plots)"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_rental_rate.dta", replace

*Now getting area planted 
*  Rainy Season *
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_g.dta", clear
drop if ag_g0b==""
ren ag_g0b plot_id
merge m:1 case_id plot_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_rent_nomiss_rainyseason.dta", nogen keep(1 3) //ALT: 24 not matched from master

*First rescaling
gen percent_plot = 1 if ag_g01==1 // VAP: "Was crop planted in entire area of plot" (ag_g02) ALT: Lots of missing responses in ag_g02, replaced with ag_g01: Pure stand or mixed stand?
replace percent_plot = 0.125*(ag_g03==1) + 0.25*(ag_g03==2) + 0.5*(ag_g03==3) + 0.75*(ag_g03==4) + 0.875*(ag_g03==5) if ag_g02==2 // VAP: Created 2 new categories for < 1/4 & >3/4. "Approx how much of plot was planted with [crop]"
bys case_id plot_id: egen total_percent_plot = total(percent_plot)		

replace percent_plot = percent_plot*(1/total_percent_plot) if total_percent_plot>1 & total_percent_plot!=.	
replace total_percent_plot = 1 if total_percent_plot>1 & total_percent_plot!=.

*Merging in total plot area from previous module  // VAP: BUG - problem with unique identifier in using dataset? line 3114
merge m:1 plot_id case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_plot_area_rainyseason", nogen keep(3) //ALT 10.21.19 - I removed assert(2 3) b/c 24 entries are in mod g but not mod c		
gen ha_planted = percent_plot*area_meas_hectares
gen ha_planted_male = ha_planted if dm_gender==1
gen ha_planted_female = ha_planted if dm_gender==2
//gen ha_planted_mixed = ha_planted if dm_gender==3

*Merging in geographic variables 
merge m:1 case_id using "${Malawi_IHS_W1_raw_data}\Household\hh_mod_a_filt.dta", nogen assert(2 3) keep(3)
rename hh_a01 district
rename hh_a02 ta
rename ea_id ea
*Now merging in aggregate rental costs
merge m:1 district ta ea using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_rental_rate_rainyseason", nogen assert(2 3) keep(3) //ALT: removed region because it's not necessary for merge and not present in the master without being constructed.
*Now merging in rental costs of individual plots
merge m:1 case_id plot_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_rent_nomiss_rainyseason.dta", nogen keep(1 3)
*Now merging in household rental rate
merge m:1 case_id using "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_rental_rate_hhid_rainyseason.dta", nogen keep(1 3) //ALT only 928 matches
gen value_owned_land = ha_planted*ha_rental_rate if plot_rental_rate==0 | plot_rental_rate==.		
replace value_owned_land = ha_planted*ha_rental_hh_rs if ha_rental_hh_rs!=0 & ha_rental_hh_rs!=. & (plot_rental_rate==0 | plot_rental_rate==.)		
*Now creating gender value 
gen value_owned_land_male = ha_planted*ha_rental_rate if (plot_rental_rate==0 | plot_rental_rate==.) & dm_gender==1
replace value_owned_land_male = ha_planted*ha_rental_hh_rs if ha_rental_hh_rs!=0 & ha_rental_hh_rs!=. & (plot_rental_rate==0 | plot_rental_rate==.) & dm_gender==1
*Female
gen value_owned_land_female = ha_planted*ha_rental_rate if (plot_rental_rate==0 | plot_rental_rate==.) & dm_gender==2
replace value_owned_land_female = ha_planted*ha_rental_hh_rs if ha_rental_hh_rs!=0 & ha_rental_hh_rs!=. & (plot_rental_rate==0 | plot_rental_rate==.) & dm_gender==2

*Mixed
*gen value_owned_land_mixed = ha_planted*ha_rental_rate if (ag3a_33==0 | ag3a_33==.) & dm_gender==3
*replace value_owned_land_mixed = ha_planted*ha_rental_hh_lrs if ha_rental_hh_lrs!=0 & ha_rental_hh_lrs!=. & (ag3a_33==0 | ag3a_33==.) & dm_gender==3
collapse (sum) value_owned_land* ha_planted*, by(case_id plot_id)			// summing ha_planted across crops on same plot

lab var value_owned_land "Value of owned land that was cultivated (household)"
lab var value_owned_land_male "Value of owned land (male-managed)"
lab var value_owned_land_female "Value of owned land (female-managed)"
*lab var value_owned_land_mixed "Value of owned land (mixed-managed)"
lab var ha_planted "Area planted (household)"
lab var ha_planted_male "Area planted (male-managed)"
lab var ha_planted_female "Area planted (female-managed)"
*lab var ha_planted_mixed "Area planted (mixed-managed)"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_cost_land_rainyseason.dta", replace //ALT: Check to make sure these merges are working properly - lots of all 0 rows in end data.


********************************************************************************
* RATE OF FERTILIZER APPLICATION * - MGM WIP 10.20.22
********************************************************************************
*MGM 10.20.22: references MWI W4 - Some variables between W1 and W4 are inconsistent


use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_d.dta", clear //rainy
gen dry=0 //create variable for season
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_k.dta" //dry
recode dry(.=1)
lab var dry "season: 0=rainy, 1=dry"
label define dry 0 "rainy" 1 "dry"
label values dry dry

// organic fertilizer - rainy (_r) and dry (_d)
rename ag_d36 org_fert_use_r
rename ag_d37a org_fert_qty_r
rename ag_d37b org_fert_unit_r
rename ag_k37 org_fert_use_d
rename ag_k38a org_fert_qty_d
rename ag_k38b org_fert_unit_d // units include: KILOGRAM, BUCKET, WHEELBARROW, OX CART, OTHER. Could not find unit conversion for fertilizer.
// Only use KILOGRAM unit for organic fertilizer 

gen fert_org_kg_r = .
replace fert_org_kg_r = org_fert_qty_r if org_fert_use_r==1 & org_fert_unit_r==2 & org_fert_qty_r !=. //204 changes made
gen fert_org_kg_d = .
replace fert_org_kg_d = org_fert_qty_d if org_fert_use_d==1 & org_fert_unit_d==2 & org_fert_qty_d !=. //459 changes made

// inorganic fertilizer - rainy and dry
rename ag_d38 inorg_fert_use_r
rename ag_k39 inorg_fert_use_d

gen fert_inorg_kg_r = .
gen fert_inorg_kg_d = .

// Unit conversion for inorganic fertilizer
foreach i in ag_d39c ag_d39h ag_k40c ag_k40h {
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
replace fert_inorg_kg_r = 0 if inorg_fert_use_r==2 //2,127 changes made
replace fert_inorg_kg_d = 0 if inorg_fert_use_d==2 //1,971 changes made
//count if inorg_fert_use_r !=. & inorg_fert_use_r!=0 //5,339
//count if inorg_fert_use_d !=. & inorg_fert_use_d!=0 //3,555

//rainy - first application
replace fert_inorg_kg_r = ag_d39b * ag_d39c * ag_d39c_conversion if inorg_fert_use_r==1
// add second application
replace fert_inorg_kg_r = fert_inorg_kg_r + ag_d39g * ag_d39h * ag_d39h_conversion if ag_d39g !=. & ag_d39h !=. 

//dry - first application
replace fert_inorg_kg_d = ag_k40b * ag_k40c * ag_k40c_conversion if inorg_fert_use_d==1  
// add second application
replace fert_inorg_kg_d = fert_inorg_kg_d + ag_k40g * ag_k40h *ag_k40h_conversion if ag_k40g !=. & ag_k40h!=.  

/*NOTE: THE REST OF THIS SECTION (RATE OF FERT APP) MAY DEPEND ON ALL CROPS CODE AND SINGLE PLOT DECISION MAKER CODE- 10.20.22 - SUBJECT TO CHANGES
hhid was stylized as HHID on MW W4
var gardenid has not yet been generated for MW W1
*/
keep case_id case_id plotid fert_org_kg_r fert_inorg_kg_r fert_org_kg_d fert_inorg_kg_d

/*Note: counts are significantly different than MW W4
count if fert_inorg_kg_r ==. & fert_inorg_kg_d==. //3,511
count if fert_inorg_kg_r !=. & fert_inorg_kg_d==. //5,307
count if fert_inorg_kg_r ==. & fert_inorg_kg_d!=. //395
*/

//Note: using data set does not yet exist
//merge m:1 case_id case_id plotid using 


********************************************************************************
* WOMEN'S DIET QUALITY *
********************************************************************************
*Women's diet quality: proportion of women consuming nutrient-rich foods (%)
*Information not available


********************************************************************************
* HOUSEHOLDS DIET DIVERSITY SCORE *
********************************************************************************
* Malawi LSMS 2 does not report individual consumption but instead household level consumption of various food items.
* Thus, only the proportion of households eating nutritious food can be estimated
use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_g1.dta" , clear
ren hh_g02 itemcode
* recode food items to map HDDS food categories //ALT: Including prepared foods in their respective categories
recode itemcode 	(101/117 820 					=1	"CEREALS" )  //// VAP: Also includes biscuits, buns, scones //ALT: Added cooked maize from vendor
					(201/209 821 828				=2	"WHITE ROOTS,TUBERS AND OTHER STARCHES"	)  ////Including chips and samosas
					(401/414 	 					=3	"VEGETABLES"	)  ////	
					(601/610						=4	"FRUITS"	)  ////	
					(504/512 515 824 825 826		=5	"MEAT"	)  ////	VAP: 512: Tinned meat or fish, included in meat				
					(501 823					    =6	"EGGS"	)  ////
					(502/503 513/514				=7  "FISH") ///
					(301/310						=8	"LEGUMES, NUTS AND SEEDS") ///
					(701/709						=9	"MILK AND MILK PRODUCTS")  ////
					(803  							=10	"OILS AND FATS"	)  ////
					(801 802 815/817 827			=11	"SWEETS"	)  //// Including sugar in sweets, oils are 803, ignoring one other (cassava leaves) in 804. Also including 827 - doughnuts
					(901/916  810/814 818			=14 "SPICES, CONDIMENTS, BEVERAGES"	)  ////
					,generate(Diet_ID)
					
gen adiet_yes=(hh_g01==1)
//ALT 10.23.19: Where do we put 3k "restaurant meals" (829)?
ta Diet_ID   
** Now, collapse to food group level; household consumes a food group if it consumes at least one item
collapse (max) adiet_yes, by(case_id Diet_ID) 
label define YesNo 1 "Yes" 0 "No"
label val adiet_yes YesNo
* Now, estimate the number of food groups eaten by each individual
collapse (sum) adiet_yes, by(case_id )
ren adiet_yes number_foodgroup 
sum number_foodgroup 
local cut_off1=6
local cut_off2=round(r(mean))
gen household_diet_cut_off1=(number_foodgroup>=`cut_off1')
gen household_diet_cut_off2=(number_foodgroup>=`cut_off2')
lab var household_diet_cut_off1 "1= household consumed at least `cut_off1' of the 12 food groups last week" 
lab var household_diet_cut_off2 "1= household consumed at least `cut_off2' of the 12 food groups last week" 
label var number_foodgroup "Number of food groups individual consumed last week HDDS"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_household_diet.dta", replace
 
/*
********************************************************************************
* WOMEN'S CONTROL OVER INCOME *
********************************************************************************
*Code as 1 if a woman is listed as one of the decision-makers for at least 1 income-related area; 
*can report on % of women who make decisions, taking total number of women HH members as denominator
*In most cases, MW LSMS 2 lists the first TWO decision makers.
*Indicator may be biased downward if some women would participate in decisions about the use of income
*but are not listed among the first two
 
/*

** Decision-making areas
*	Control over crop production income
*	Control over livestock production income
*	Control over fish production income
*	Control over farm (all) production income
*	Control over wage income
*	Control over business income
*	Control over nonfarm (all) income
*	Control over (all) income
		
VAP: TZ-4 and MW-2 both also include 
	* Control over remittance income
	* Control over income from [program] assistance (social safety nets)

VAP: Added the following to the indicator construction for MW2
	* Control over other income (cash & in-kind transfers from individuals, pension, rental, asset sale, lottery, inheritance)	

ALT: Major changes in this section; the binary "did <personid> receive <income> seems to be missing from MW2 but is present in MW1"
	Cannot include remittance income because it isn't detailed enough
	
	*/

* First append all files with information on who control various types of income
* Control over Crop production income
use "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_i.dta", clear  // control over crop sale earnings rainy season
// append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_ba.dta" // control over crop sale earnings rainy season
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_o.dta" // control over crop sale earnings dry season
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_q.dta" // control over permanent crop sale earnings 
* Control over Livestock production income
append using "${Malawi_IHS_W1_raw_data}\Agriculture\ag_mod_s.dta" // control over livestock product sale earnings
* Control over wage income
append using "${Malawi_IHS_W1_raw_data}\Household\hh_mod_e.dta" // control over salary payment, allowances/gratuities, ganyu labor earnings 
* Control over business income
append using "${Malawi_IHS_W1_raw_data}\Household\hh_mod_n2.dta" // household enterprise ownership
* Control over program assistance 
append using "${Malawi_IHS_W1_raw_data}\Household\hh_mod_r.dta"
* Control over other income 
append using "${Malawi_IHS_W1_raw_data}\Household\hh_mod_p.dta"
* Control over remittances
append using "${Malawi_IHS_W1_raw_data}\Household\hh_mod_o.dta"


gen type_decision="" 
gen controller_income1=. 
gen controller_income2=.

/* No question in MW1/MW2
control of harvest from annual crops
replace type_decision="control_annualharvest" if  !inlist( ag4a_30_1, .,0,99) |  !inlist( ag4a_30_2, .,0,99) 
replace controller_income1=ag4a_30_1 if !inlist( ag4a_30_1, .,0,99)  
replace controller_income2=ag4a_30_2 if !inlist( ag4a_30_2, .,0,99)
replace type_decision="control_annualharvest" if  !inlist( ag4b_30_1, .,0,99) |  !inlist( ag4b_30_2, .,0,99) 
replace controller_income1=ag4b_30_1 if !inlist( ag4b_30_1, .,0,99)  
replace controller_income2=ag4b_30_2 if !inlist( ag4b_30_2, .,0,99)

* control of harvest from permanent crops
replace type_decision="control_permharvest" if  !inlist( ag6a_08_1, .,0,99) |  !inlist( ag6a_08_2, .,0,99) 
replace controller_income1=ag6a_08_1 if !inlist( ag6a_08_1, .,0,99)  
replace controller_income2=ag6a_08_2 if !inlist( ag6a_08_2, .,0,99)
replace type_decision="control_permharvest" if  !inlist( ag6b_08_1, .,0,99) |  !inlist( ag6b_08_2, .,0,99) 
replace controller_income1=ag6b_08_1 if !inlist( ag6b_08_1, .,0,99)  
replace controller_income2=ag6b_08_2 if !inlist( ag6b_08_2, .,0,99)
*/


// 
* control_annualsales
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
replace type_decision="control_annualsales" if  !inlist( ag_o23a, .,0,99) |  !inlist( ag_o23b, .,0,99) 
replace controller_income1=ag_o23a if !inlist( ag_o23a, .,0,99)  
replace controller_income2=ag_o23b if !inlist( ag_o23b, .,0,99)
keep if !inlist( ag_i23a, .,0,99) |  !inlist( ag_i23b, .,0,99)  | !inlist( ag_o23a, .,0,99) |  !inlist( ag_o23b, .,0,99) 
keep hhid type_decision controller_income1 controller_income2
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

/* No question in MW2
* control_processedsales
replace type_decision="control_processedsales" if  !inlist( ag10_10_1, .,0,99) |  !inlist( ag10_10_2, .,0,99) 
replace controller_income1=ag10_10_1 if !inlist( ag10_10_1, .,0,99)  
replace controller_income2=ag10_10_2 if !inlist( ag10_10_2, .,0,99)
*/

* livestock_sales (products) 
replace type_decision="control_livestocksales" if  !inlist( ag_s07a, .,0,99) |  !inlist( ag_s07b, .,0,99) 
replace controller_income1=ag_s07a if !inlist( ag_s07a, .,0,99)  
replace controller_income2=ag_s07b if !inlist( ag_s07b, .,0,99)

/* No questions in MW2 
append who controls earning from livestock_sales (slaughtered)
preserve
replace type_decision="control_livestocksales" if  !inlist( lf02_35_1, .,0,99) |  !inlist( lf02_35_2, .,0,99) 
replace controller_income1=lf02_35_1 if !inlist( lf02_35_1, .,0,99)  
replace controller_income2=lf02_35_2 if !inlist( lf02_35_2, .,0,99)
keep if  !inlist( lf02_35_1, .,0,99) |  !inlist( lf02_35_2, .,0,99) 
keep y4_hhid type_decision controller_income1 controller_income2
tempfile control_livestocksales2
save `control_livestocksales2'
restore
append using `control_livestocksales2'
 
* control milk_sales
replace type_decision="control_milksales" if  !inlist( lf06_13_1, .,0,99) |  !inlist( lf06_13_2, .,0,99) 
replace controller_income1=lf06_13_1 if !inlist( lf06_13_1, .,0,99)  
replace controller_income2=lf06_13_2 if !inlist( lf06_13_2, .,0,99)

* control control_otherlivestock_sales
replace type_decision="control_otherlivestock_sales" if  !inlist( lf08_08_1, .,0,99) |  !inlist( lf08_08_2, .,0,99) 
replace controller_income1=lf08_08_1 if !inlist( lf08_08_1, .,0,99)  
replace controller_income2=lf08_08_2 if !inlist( lf08_08_2, .,0,99)

*/

* Fish production income 
*No information available in MW2

* Business income 
* Malawi LSMS 2 did not ask directly about of who controls Business Income
* We are making the assumption that whoever owns the business might have some sort of control over the income generated by the business.
* We don't think that the business manager have control of the business income. If she does, she is probably listed as owner
* control_businessincome
replace type_decision="control_businessincome" if  !inlist( hh_n12a, .,0,99) |  !inlist( hh_n12b, .,0,99) 
replace controller_income1=hh_n12a if !inlist( hh_n12a, .,0,99)  
replace controller_income2=hh_n12b if !inlist( hh_n12b, .,0,99)

** --- Wage income --- * 
* Malawi 2 has questions on control over salary payments & allowances/gratuities in main + secondary job & ganyu earnings

* control_salary  //These don't work the same in MW1; it asks if "you" earned income, so there's only one column for controller
replace type_decision="control_salary" if  hh_e18==1 //|  !inlist( hh_e26_1b, .,0,99) // main wage job
replace controller_income1=hh_e01 if hh_e18==1  //There are two id cols, id_code and hh_e01; a few are different, most are not
//replace controller_income2=hh_e26_1b if !inlist( hh_e26_1b, .,0,99)

* append who controls salary earnings from secondary job
preserve
replace type_decision="control_salary" if  hh_e32==1 //|  !inlist(hh_e40_1b, .,0,99) 
replace controller_income1=hh_e01 if hh_e32==1
//replace controller_income2=hh_e40_1b if !inlist( hh_e40_1b, .,0,99)
keep if hh_e32==1 //|  !inlist( hh_e40_1b, .,0,99)  
keep case_id type_decision controller_income1 controller_income2
tempfile wages2
save `wages2'
restore
append using `wages2'

* control_allowances
replace type_decision="control_allowances" if  hh_e27!=. & hh_e27>0 //|  !inlist(hh_e28_1b , .,0,99) 
replace controller_income1=hh_e01 if hh_e27!=. & hh_e27>0 
//replace controller_income2=hh_e28_1b if !inlist(hh_e28_1b , .,0,99)
* append who controls  allowance/gratuity earnings from secondary job
preserve
replace type_decision="control_allowances" if  hh_e41!=. & hh_e41>0 //|  !inlist(hh_e42_1b , .,0,99) 
replace controller_income1=hh_e01 if hh_e41!=. & hh_e41>0  
//replace controller_income2= hh_e42_1b if !inlist( , .,0,99)
keep if hh_e41!=. & hh_e41>0 // |  !inlist(hh_e42_1b , .,0,99)  
keep case_id type_decision controller_income1 controller_income2
tempfile allowances2
save `allowances2'
restore
append using `allowances2'

* control_ganyu
replace type_decision="control_ganyu" if  (hh_e55==1) //|  !inlist(hh_e59_1b , .,0,99) 
replace controller_income1= hh_e01 if (hh_e55==1)  
//replace controller_income2= hh_e59_1b if !inlist( hh_e59_1b, .,0,99)

/* * control_remittance ALT: MW1 doesn't really answer this question, it just asks for respondent ID
replace type_decision="control_remittance" if  !inlist( hh_o14_1a, .,0,99) |  !inlist( hh_o14_1b, .,0,99) 
replace controller_income1=hh_o14_1a if !inlist( hh_o14_1a, .,0,99)  
replace controller_income2=hh_o14_1b if !inlist( hh_o14_1b, .,0,99)
* append who controls in-kind remittances
preserve
replace type_decision="control_remittance" if  !inlist( hh_o18a, .,0,99) |  !inlist( hh_o18b, .,0,99) 
replace controller_income1=hh_o18a if !inlist( hh_o18a, .,0,99)  
replace controller_income2=hh_o18b if !inlist( hh_o18b, .,0,99)
keep if  !inlist( hh_o18a, .,0,99) |  !inlist( hh_o18b, .,0,99) 
keep case_id type_decision controller_income1 controller_income2
tempfile control_remittance2
save `control_remittance2'
restore
append using `control_remittance2'
*/

* control_assistance income
replace type_decision="control_assistance" if hh_r01==1 //!inlist( hh_r05a, .,0,99) |  !inlist( hh_r05b, .,0,99) 
replace controller_income1=hh_r05a if hh_r01==1  
replace controller_income2=hh_r05b if hh_r01==1

* control_other income 
replace type_decision="control_otherincome" if  hh_p01==1
replace controller_income1=hh_p04a if hh_p01==1 
replace controller_income2=hh_p04b if hh_p01==1

keep case_id type_decision controller_income1 controller_income2
 
preserve
keep case_id type_decision controller_income2
drop if controller_income2==.
ren controller_income2 controller_income
tempfile controller_income2
save `controller_income2'
restore
keep case_id type_decision controller_income1
drop if controller_income1==.
ren controller_income1 controller_income
append using `controller_income2'
 
* create group
gen control_cropincome=1 if  type_decision=="control_annualsales" | type_decision=="control_permsales" 
recode 	control_cropincome (.=0)		
							
gen control_livestockincome=1 if  type_decision=="control_livestocksales" 												
recode 	control_livestockincome (.=0)

gen control_farmincome=1 if  control_cropincome==1 | control_livestockincome==1							
recode 	control_farmincome (.=0)		
							
gen control_businessincome=1 if  type_decision=="control_businessincome" 
recode 	control_businessincome (.=0)

gen control_salaryincome=1 if type_decision=="control_salary"| type_decision=="control_allowances"| type_decision=="control_ganyu"						 
																					
gen control_nonfarmincome=1 if  type_decision=="control_assistance" ///ALT 10.23.19: Removed remittance from this part b/c unconstructable for MW1
							  | type_decision=="control_otherincome" /// VAP: additional in MW2
							  | control_salaryincome== 1 /// VAP: additional in MW2
							  | control_businessincome== 1 
recode 	control_nonfarmincome (.=0)
																		
collapse (max) control_* , by(case_id controller_income )  //any decision
gen control_all_income=1 if  control_farmincome== 1 | control_nonfarmincome==1 //This is literally everyone in the dataset right now
recode 	control_all_income (.=0)															
ren controller_income hh_b01 //person_ids.dta uses this as the personid
*	Now merge with member characteristics
merge 1:1 case_id hh_b01  using  "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_person_ids.dta", nogen keep (3) // 5182/5218  matched
rename hh_b01 personid

recode control_* (.=0)
lab var control_cropincome "1=individual has control over crop income"
lab var control_livestockincome "1=individual has control over livestock income"
lab var control_farmincome "1=individual has control over farm (crop or livestock) income"
lab var control_businessincome "1=individual has control over business income"
lab var control_salaryincome "1= individual has control over salary income"
lab var control_nonfarmincome "1=individual has control over non-farm (business, salary, assistance, remittances or other income) income"
lab var control_all_income "1=individual has control over at least one type of income"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_control_income.dta", replace

********************************************************************************
*HOUSEHOLD ASSETS*
********************************************************************************
use "${Malawi_IHS_W1_raw_data}\Household\hh_mod_l.dta", clear
*ren hh_m03 price_purch  // VAP: purchse price not available in MW2s
ren hh_l05 value_today
ren hh_l04 age_item
ren hh_l03 num_items
/*
dropping items that don't report prices
drop if itemcode==413 | itemcode==414 | itemcode==416 | itemcode==424 | itemcode==436 | itemcode==440
*/
collapse (sum) value_assets=value_today, by(case_id)
la var value_assets "Value of household assets"
save "${Malawi_IHS_W1_created_data}\Malawi_IHS_W1_hh_assets.dta", replace 

//ALT: End of VAP code. Didn't really touch this section.
