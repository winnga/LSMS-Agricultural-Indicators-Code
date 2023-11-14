/*
-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title/Purpose 	: This do.file was developed by the Evans School Policy Analysis & Research Group (EPAR) 
				  for the construction of a set of agricultural development indicators 
				  using the Malawi National Panel Survey (IHS) LSMS-ISA Wave 2 (2013)
*Author(s)		: Didier Alia, Pierre Biscaye, David Coomes, Melissa Howlett, Jack Knauer, Josh Merfeld,  
				  Vedavati Patwardhan, Isabella Sun, Chelsea Sweeney, Emma Weaver, Ayala Wineman, 
				  C. Leigh Anderson, &  Travis Reynolds

*Acknowledgments: We acknowledge the helpful contributions of members of the World Bank's LSMS-ISA team, the FAO's RuLIS team, IFPRI, IRRI, 
				  and the Bill & Melinda Gates Foundation Agricultural Development Data and Policy team in discussing indicator construction decisions. 
				  All coding errors remain ours alone.
*Date			: 30 September 2019

----------------------------------------------------------------------------------------------------------------------------------------------------*/


*Data source
*-----------
*The Malawi National Panel Survey was collected by the National Statistical Office in Zomba 
*and the World Bank's Living Standards Measurement Study - Integrated Surveys on Agriculture(LSMS - ISA)
*The data were collected over the period April-October 2013. 
*All the raw data, questionnaires, and basic information documents are available for downloading free of charge at the following link
*http://microdata.worldbank.org/index.php/catalog/1003

*Throughout the do-file, we sometimes use the shorthand LSMS to refer to the Malawi National Panel Survey.

*Summary of Executing the Master do.file
*-----------
*This Master do.file constructs selected indicators using the Malawi LSMS data set.
*Using data files from within the "378 - LSMS Burkina Faso, Malawi, Uganda" folder within the "raw_data" folder, 
*the do.file first constructs common and intermediate variables, saving dta files when appropriate 
*in R:\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave2-2013\created_data
*These variables are then brought together at the household, plot, or individual level, saving dta files at each level when available 
*in the folder "Tanzania TNPS - LSMS-ISA - Wave 4 (2014-15)" within the "Final DTA files" folder. // VAP 5.21.19 Update this with new file path

*The processed files include all households, individuals, and plots in the sample.
*Toward the end of the do.file, a block of code estimates summary statistics (mean, standard error of the mean, minimum, first quartile, median, third quartile, maximum) 
*of final indicators, restricted to the rural households only, disaggregated by gender of head of household or plot manager.
*The results are outputed in the excel file "Tanzania_NPS_LSMS_ISA_W4_summary_stats.xlsx" in the "Tanzania TNPS - LSMS-ISA - Wave 4 (2014-15)" within the "Final DTA files" folder. // VAP 5.21.19 Update this with new file path 
*It is possible to modify the condition  "if rural==1" in the portion of code following the heading "SUMMARY STATISTICS" to generate all summary statistics for a different sub_population.

 
/*
OUTLINE OF THE DO.FILE
Below are the list of the main files created by running this Master do.file

*INTERMEDIATE FILES					MAIN FILES CREATED
*-------------------------------------------------------------------------------------
*HOUSEHOLD IDS						Malawi_IHPS_W2_hhids.dta
*INDIVIDUAL IDS						Malawi_IHPS_W2_person_ids.dta
*HOUSEHOLD SIZE						Malawi_IHPS_W2_hhsize.dta
*PARCEL AREAS						Malawi_IHPS_W2_plot_areas.dta
*PLOT-CROP DECISION MAKERS			Malawi_IHPS_W2_plot_decision_makers.dta

*MONOCROPPED PLOTS					Malawi_IHPS_W2_[CROP]_monocrop_hh_area.dta

*TLU (Tropical Livestock Units)		Malawi_IHPS_W2_TLU_Coefficients.dta

*GROSS CROP REVENUE					Malawi_IHPS_W2_tempcrop_harvest.dta
									Malawi_IHPS_W2_tempcrop_sales.dta
									Malawi_IHPS_W2_permcrop_harvest.dta
									Malawi_IHPS_W2_permcrop_sales.dta
									Malawi_IHPS_W2_hh_crop_production.dta
									Malawi_IHPS_W2_plot_cropvalue.dta
									Malawi_IHPS_W2_hh_crop_prices.dta  
									// VAP: Cannot replicate "crop_losses.dta & crop_residues.dta"
									
*CROP EXPENSES						Malawi_IHPS_W2_wages_rainyseason.dta
									Malawi_IHPS_W2_wages_dryseason.dta
									Malawi_IHPS_W2_fertilizer_costs.dta
									Malawi_IHPS_W2_seed_costs.dta
									Malawi_IHPS_W2_land_rental_costs.dta
									Malawi_IHPS_W2_asset_rental_costs.dta
									Malawi_IHPS_W2_transportation_cropsales.dta // VAP: Check code.
									
*CROP INCOME						Malawi_IHPS_W2_crop_income.dta
									
*LIVESTOCK INCOME					Malawi_IHPS_W2_livestock_products.dta
									Malawi_IHPS_W2_livestock_expenses.dta
									Malawi_IHPS_W2_manure.dta
									Malawi_IHPS_W2_livestock_sales.dta
									Malawi_IHPS_W2_TLU.dta
									Malawi_IHPS_W2_livestock_income.dta

*FISH INCOME						Malawi_IHPS_W2_fishing_expenses_1.dta
									Malawi_IHPS_W2_fishing_expenses_2.dta
									Malawi_IHPS_W2_fish_income.dta
																	

*SELF-EMPLOYMENT INCOME	           	Malawi_IHPS_W2_fish_trading_revenue.dta  
									// VAP: Cannot replicate "self_employment_income.dta & agproducts_profits.dta"
									Malawi_IHPS_W2_fish_trading_other_costs.dta
									Malawi_IHPS_W2_fish_trading_income.dta
									
*WAGE INCOME						Malawi_IHPS_W2_wage_income.dta
									Malawi_IHPS_W2_agwage_income.dta
									
*OTHER INCOME						Malawi_IHPS_W2_other_income.dta
									Malawi_IHPS_W2_land_rental_income.dta

*FARM SIZE / LAND SIZE				Malawi_IHPS_W2_land_size.dta
									Malawi_IHPS_W2_farmsize_all_agland.dta
									Malawi_IHPS_W2_land_size_all.dta
									Malawi_IHPS_W2_land_size_total.dta
									
*OFF-FARM HOURS						Malawi_IHPS_W2_off_farm_hours.dta									
									
*FARM LABOR							Malawi_IHPS_W2_farmlabor_rainyseason.dta
									Malawi_IHPS_W2_farmlabor_dryseason.dta
									Malawi_IHPS_W2_family_hired_labor.dta
									
*VACCINE USAGE						Malawi_IHPS_W2_vaccine.dta
									Malawi_IHPS_W2_farmer_vaccine.dta											

*ANIMAL HEALTH						Malawi_IHPS_W2_livestock_diseases.dta 
									// VAP: Cannot replicate "livestock_feed_water_house.dta"
																	
*USE OF INORGANIC FERTILIZER		Malawi_IHPS_W2_fert_use.dta	
									Malawi_IHPS_W2_farmer_fert_use.dta

*USE OF IMPROVED SEED				// VAP: Cannot replicate "improvedseed_use.dta" 
									// VAP: Cannot replicate "farmer_improvedseed_use.dta"

*REACHED BY AG EXTENSION			Malawi_IHPS_W2_any_ext.dta

*MOBILE OWNERSHIP                   Malawi_IHPS_W2_mobile_own.dta

*USE OF FORMAL FINANCIAL SERVICES	Malawi_IHPS_W2_fin_serv.dta

*MILK PRODUCTIVITY					Malawi_IHPS_W2_milk_animals.dta

*EGG PRODUCTIVITY					Malawi_IHPS_W2_eggs_animals.dta

*CROP PRODUCTION COSTS PER HECTARE	Malawi_IHPS_W2_hh_rental_rate.dta
									Malawi_IHPS_W2_hh_cost_land.dta
/// ** VAP: Skipped from here to HDDS
									Malawi_IHPS_W2_hh_cost_inputs_lrs.dta
									Malawi_IHPS_W2_hh_cost_inputs_srs.dta
									Malawi_IHPS_W2_hh_cost_seed_lrs.dta
									Malawi_IHPS_W2_hh_cost_seed_srs.dta		
									Malawi_IHPS_W2_cropcosts_perha.dta
									
*AGRICULTURAL WAGES					Malawi_IHPS_W2_ag_wage.dta   

*RATE OF FERTILIZER APPLICATION		Malawi_IHPS_W2_fertilizer_application.dta 
/// 

*HOUSEHOLD'S DIET DIVERSITY SCORE	Malawi_IHPS_W2_household_diet.dta

*WOMEN'S CONTROL OVER INCOME		Malawi_IHPS_W2_control_income.dta

/// ** VAP: Skipped from here to Household Assets
*WOMEN'S AG DECISION-MAKING			Malawi_IHPS_W2_make_ag_decision.dta
*WOMEN'S ASSET OWNERSHIP			Malawi_IHPS_W2_ownasset.dta

*CROP YIELDS						Malawi_IHPS_W2_yield_hh_crop_level.dta
*SHANNON DIVERSITY INDEX			Malawi_IHPS_W2_shannon_diversity_index.dta
*CONSUMPTION						Malawi_IHPS_W2_consumption.dta
*HOUSEHOLD FOOD PROVISION			Malawi_IHPS_W2_food_insecurity.dta
///

*HOUSEHOLD ASSETS					Malawi_IHPS_W2_hh_assets.dta

*FINAL FILES						MAIN FILES CREATED
*-------------------------------------------------------------------------------------
*HOUSEHOLD VARIABLES				Malawi_IHPS_W2_household_variables.dta
*INDIVIDUAL-LEVEL VARIABLES			Malawi_IHPS_W2_individual_variables.dta	
*PLOT-LEVEL VARIABLES				Malawi_IHPS_W2_gender_productivity_gap.dta
*SUMMARY STATISTICS					Malawi_IHPS_W2_summary_stats.xlsx
*/

* VAP: The reference file used for Malawi Wave 2 code creation & replication is W4_EPAR_UW_335_Tanzania_TNPS_MASTER_7.8.19.do [Tanzania TNPS - LSMS-ISA - Wave 4 (2014-15)]

clear	
set more off

clear matrix	
clear mata	
set maxvar 8000	
ssc install findname // need this user-written ado file for some commands to work

*Set location of raw data and output 
global directory "   "

// set directories
* These paths correspond to the folders where the raw data files are located and where the created data and final data will be stored.
global Malawi_IHPS_W2_raw_data 			"\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave2-2013\raw_data"
global Malawi_IHPS_W2_created_data 		"\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave2-2013\created_data\TempFiles" 
global Malawi_IHPS_W2_final_data  		"\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Working Files\378 - LSMS Burkina Faso, Malawi, Uganda\malawi-wave2-2013\outputs"


************************
*EXCHANGE RATE AND INFLATION FOR CONVERSION IN USD IDS
************************
global Malawi_IHPS_W2_exchange_rate 730.27		 // https://data.worldbank.org/indicator/PA.NUS.FCRF?end=2017&locations=MW&start=2011
global Malawi_IHPS_W2_gdp_ppp_dollar 251.07     // https://data.worldbank.org/indicator/PA.NUS.PPP?end=2017&locations=MW&start=2011
global Malawi_IHPS_W2_cons_ppp_dollar 241.93	 // https://data.worldbank.org/indicator/PA.NUS.PRVT.PP?end=2017&locations=MW&start=2011
global Malawi_IHPS_W2_inflation .48825393  //CPI_SURVEY_YEAR/CPI_2017 - > CPI_2013/CPI_2017 ->  166.1245533/340.2421245 from https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2017&locations=MW&start=2009 //The data were collected over the period 2011 to 2012 (therefore we use 2012 the latest year)

global MWI_IHS_W2_poverty_threshold (1.90*78.77*166.1/107.6) //see calculation and sources below
//WB's previous (PPP) poverty threshold is $1.90. 
//Multiplied by 2011 PPP conversion factor of 78.77 //https://data.worldbank.org/indicator/PA.NUS.PRVT.PP?end=2017&locations=MW&start=2009
//Multiplied by CPI in 2013 of 166.1 //https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2017&locations=MW&start=2009
//Divided by CPI in 2011 of 107.6 //https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2017&locations=MW&start=2009
global MWI_IHS_W2_poverty_ifpri (109797*166.12/340.2/365) //see calculation and sources below
//MWI government set national poverty line to MWK109,797 in January 2017 values //https://massp.ifpri.info/files/2019/05/IFPRI_KeyFacts_Poverty_Final.pdf
//Multiplied by CPI in 2013 of 166.12 //https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2017&locations=MW&start=2009
//Divided by CPI in 2017 of 340.2 //https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2017&locations=MW&start=2009
//Divide  by # of days in year (365) to get daily amount
global MWI_IHS_W2_poverty_215 (2.15* $MWI_IHS_W2_inflation * $MWI_IHS_W2_cons_ppp_dollar)  //WB's new (PPP) poverty threshold of $2.15 multiplied by globals
 

************************
*POPULATION
************************

global Malawi_IHPS_W2_pop_tot 16024775
global Malawi_IHPS_W2_pop_rur 13466259
global Malawi_IHPS_W2_pop_urb 2558516

********************************************************************************
*THRESHOLDS FOR WINSORIZATION
********************************************************************************
global wins_lower_thres 1    						//  Threshold for winzorization at the bottom of the distribution of continous variables
global wins_upper_thres 99							//  Threshold for winzorization at the top of the distribution of continous variables

********************************************************************************
*GLOBALS OF PRIORITY CROPS 
********************************************************************************
// BMGF 12 priority crops //
* maize, rice, wheat, sorghum, pearl millet (or just millet if not disaggregated), cowpea, groundnut, common bean, yam, sweet potato, cassava, banana
** NOTE: Malawi has a Rainy Season and Dry Season - no long/short seasons like TZ**

// List of crops for this instrument - rainy and dry season and *=BMGF priority; (crop code)//
/*
							Rainy Season	Dry Season 
maize* (1) 						*				*
tobacco							*               *
groundnut* (11)					*
rice* (17)						*				
ground bean 					*				*
sweet potato* (28) 				*				*
irish potato					*				*
finger millet					*
sorghum* (32)					*               *
peral millet* (33)				*
beans* (34)						*				*
soyabean						*
pigeon pea						*               *
cotton							*
sunflower						*
sugar cane						*               *
cabbage                         *               *
tanaposi						*				*
nkhwani							*				*
okra							*				*
tomato							*               *
peas							*				*
onion							*				*
paprika                         *               *
other							*				*
*/

**Enter the 12 BMGF priority crops here, plus any crop in the top ten (by area) that is not already included in the priority crops - limit to 6 letters or they will be too long!
**For consistency, add the 12 priority crops in order first, then the additional top ten crops */
*Determined by the top 12 crops by area cultivated for MWI W2 (see All Plots)
global topcropname_area "maize tobacc grdnt pigpea nkhwni beans sorgum soybn rice cotton swtptt pmill"
global topcrop_area "1 5 11 36 42 34 32 35 17 37 28 33" //corresponding numeric crop codes
global comma_topcrop_area "1, 5, 11, 36, 42, 34, 32, 35, 17, 37, 28, 33"
global nb_topcrops : list sizeof global(topcropname_area) // Gets the current length of the global macro list "topcropname_area" 
//display "$nb_topcrops"
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
 save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_cropname_table.dta", replace



************************
*HOUSEHOLD IDS
************************
use "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_a_filt_13.dta", clear
rename hh_a10a ta
rename hh_wgt weight
rename region region
lab var region "1=North, 2=Central, 3=South"
gen rural = (reside==2)
lab var rural "1=Household lives in a rural area"
keep occ y2_hhid region stratum district ta ea rural weight 
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta", replace

********************************************************************************
* WEIGHTS *
********************************************************************************
use "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_a_filt_13.dta", clear
rename hh_a10a ta
rename hh_wgt weight
rename region region
lab var region "1=North, 2=Central, 3=South"
gen rural = (reside==2)
lab var rural "1=Household lives in a rural area"
keep occ y2_hhid region stratum district ta ea rural weight 
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_weights.dta", replace


************************
*INDIVIDUAL IDS
************************
use "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_b_13.dta", clear
ren PID indiv 
destring indiv, replace 
replace indiv= mod(indiv, 100) 
keep indiv y2_hhid hh_b01 hh_b03 hh_b04 hh_b05a
sort y2_hhid indiv
quietly by y2_hhid indiv:  gen dup = cond(_N==1,0,_n)
drop if dup==2 
drop dup
gen female=hh_b03==2 
lab var female "1= individual is female"
gen age=hh_b05a
lab var age "Indivdual age"
gen hh_head=hh_b04==1 
lab var hh_head "1= individual is household head"
drop hh_b03 hh_b04 hh_b05a
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_person_ids.dta", replace

************************
*HOUSEHOLD SIZE 
************************
use "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_b_13.dta", clear
gen hh_members = 1
rename hh_b04 relhead 
rename hh_b03 gender
gen fhh = (relhead==1 & gender==2)
collapse (sum) hh_members (max) fhh, by (y2_hhid)
lab var hh_members "Number of household members"
lab var fhh "1= Female-headed household"

//Rescaling the weights to match the population better
merge 1:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta", nogen keep(2 3)
total hh_members [pweight=weight]
matrix temp =e(b)
gen weight_pop_tot=weight*${Malawi_IHPS_W2_pop_tot}/el(temp,1,1)
total hh_members [pweight=weight_pop_tot]
lab var weight_pop_tot "Survey weight - adjusted to match total population"

*Adjust to match total population but also rural and urban
total hh_members [pweight=weight] if rural==1
matrix temp =e(b)
gen weight_pop_rur=weight*${Malawi_IHPS_W2_pop_rur}/el(temp,1,1) if rural==1
total hh_members [pweight=weight_pop_tot]  if rural==1

total hh_members [pweight=weight] if rural==0
matrix temp =e(b)
gen weight_pop_urb=weight*${Malawi_IHPS_W2_pop_urb}/el(temp,1,1) if rural==0
total hh_members [pweight=weight_pop_urb]  if rural==0

egen weight_pop_rururb=rowtotal(weight_pop_rur weight_pop_urb)
total hh_members [pweight=weight_pop_rururb]  
lab var weight_pop_rururb "Survey weight - adjusted to match rural and urban population"
drop weight_pop_rur weight_pop_urb
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhsize.dta", replace


********************************************************************************
*GPS COORDINATES *
********************************************************************************
use "${Malawi_IHPS_W2_raw_data}\Geovariables\HouseholdGeovariables_IHPS_13.dta", clear
merge 1:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta", nogen keep(3) 
ren LAT_DD_MOD latitude
ren LON_DD_MOD longitude
keep y2_hhid latitude longitude
gen GPS_level = "hhid"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_coords.dta", replace

************************
*PLOT AREAS
************************

use "${Malawi_IHPS_W2_raw_data}\Agriculture\AG_MOD_P_13.dta", clear
gen season=2 //perm
ren ag_p00 plot_id
ren ag_p0c crop_code
ren ag_p02a area
ren ag_p02b unit

drop if plot_id=="" //1,791 observations dropped
keep if strpos(plot_id, "T") & plot_id!="" 
collapse (max) area, by(y2_hhid plot_id crop_code season unit)
collapse (sum) area, by(y2_hhid plot_id season unit)
replace area=. if area==0 
drop if area==. & unit==.
gen area_acres_est = area if unit==1 											//Permanent crops in acres
replace area_acres_est = (area*2.47105) if unit == 2 & area_acres_est ==.		//Permanent crops in hectares
replace area_acres_est = (area*0.000247105) if unit == 3 & area_acres_est ==.	//Permanent crops in square meters
keep y2_hhid plot_id season area_acres_est
tempfile ag_perm
save `ag_perm'


use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_c_13.dta", clear
gen season=0 //rainy
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_j_13.dta", gen(dry)
replace season=1 if season==. //dry
ren ag_c00 plot_id
replace plot_id=ag_j00 if plot_id=="" //971 real changes

* Counting acreage
gen area_acres_est = ag_c04a if ag_c04b == 1 										//Self-report in acres - rainy season 
replace area_acres_est = (ag_c04a*2.47105) if ag_c04b == 2 & area_acres_est ==.		//Self-report in hectares
replace area_acres_est = (ag_c04a*0.000247105) if ag_c04b == 3 & area_acres_est ==.	//Self-report in square meters
replace area_acres_est = ag_j05a if ag_j05b==1 										//Replace with dry season measures if rainy season is not available
replace area_acres_est = (ag_j05a*2.47105) if ag_j05b == 2 & area_acres_est ==.		//Self-report in hectares
replace area_acres_est = (ag_j05a*0.000247105) if ag_j05b == 3 & area_acres_est ==.	//Self-report in square meters

* GPS MEASURE
gen area_acres_meas = ag_c04c														//GPS measure - rainy
replace area_acres_meas = ag_j05c if area_acres_meas==. 							//GPS measure - replace with dry if no rainy season measure

append using `ag_perm'
lab var season "season: 0=rainy, 1=dry, 2=tree crop"
label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
label values season season

gen field_size= (area_acres_est* (1/2.47105))
replace field_size = (area_acres_meas* (1/2.47105))  if field_size==. & area_acres_meas!=. 

keep if area_acres_est !=. | area_acres_meas !=. //2,6000 obs deleted - Keep if acreage or GPS measure info is available
keep y2_hhid plot_id season area_acres_est area_acres_meas field_size 			
gen gps_meas = area_acres_meas!=. 
lab var gps_meas "Plot was measured with GPS, 1=Yes"

lab var area_acres_meas "Plot are in acres (GPSd)"
lab var area_acres_est "Plot area in acres (estimated)"
gen area_est_hectares=area_acres_est* (1/2.47105)  
gen area_meas_hectares= area_acres_meas* (1/2.47105)
lab var area_meas_hectares "Plot are in hectares (GPSd)"
lab var area_est_hectares "Plot area in hectares (estimated)"

save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_areas.dta", replace

************************
*PLOT DECISION MAKERS 
************************
use "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_b_13.dta", clear
ren hh_b01 indiv			// indiv is the roster number, combination of y2_hhid and indiv are unique id for this wave
drop if indiv==.
gen female=hh_b03==2 
gen age=hh_b05a
gen head = hh_b04==1 //if hh_b04!=.
keep indiv female age y2_hhid head
lab var female "1=Individual is a female"
lab var age "Individual age"
lab var head "1=Individual is the head of household"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_gender_merge.dta", replace


use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_p_13.dta", clear
ren ag_p00 plot_id
keep if strpos(plot_id, "T") //R and D plots have been reported in previous modules
gen season=2
ren ag_p0c crop_code_perm

keep y2_hhid plot_id crop_code_perm season
duplicates tag y2_hhid crop_code_perm, gen(dups)
preserve
keep if dups > 0
keep y2_hhid plot_id season
duplicates drop
tempfile dm_p_hoh
save `dm_p_hoh' //reserve the multiple instances of similar crops for use in another recipe
restore
drop if dups>0 //restricting observations to those where a unique crop is grown on only one plot
drop dups
tempfile one_plot_per_crop
save `one_plot_per_crop'

use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_q_13.dta", clear
drop if ag_q01==2 //drop if no crop was sold.
ren ag_q14a indiv1 
ren ag_q14b indiv2 
ren ag_q0b crop_code_perm
duplicates drop y2_hhid crop_code_perm indiv1 indiv2, force
merge 1:1 y2_hhid crop_code_perm using `one_plot_per_crop', keep (3) nogen
keep y2_hhid plot_id indi*
gen season=2
tempfile dm_p
save `dm_p'


use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_d_13.dta", clear
rename ag_d00 plot_id
drop if plot_id=="" //158 observations deleted
gen season =0
ren ag_d01 indiv1 //manager
ren ag_d04a indiv2 //owner
keep y2_hhid plot_id  indiv*
duplicates drop
tempfile dm_r
save `dm_r'

use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_k_13.dta", clear
rename ag_k00 plot_id
drop if plot_id==""
gen season=1
gen indiv1 =ag_k02 //manager
gen indiv2=ag_k05a //owner
keep y2_hhid plot_id indiv*
duplicates drop
append using `dm_r'
append using `dm_p'
replace indiv1=indiv2 if indiv1==.
drop indiv2
ren indiv1 indiv
preserve
bys y2_hhid plot_id : egen mindiv = min(indiv)
keep if mindiv==.
duplicates drop
append using `dm_p_hoh'
merge m:m y2_hhid using  "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_gender_merge.dta",  keep(1 3) nogen		
keep if head==1 //989 observations deleted)
tempfile hoh_plots
save `hoh_plots'
restore
drop if indiv==.
merge m:1 y2_hhid indiv using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_gender_merge.dta", keep (1 3) nogen
append using `hoh_plots'
preserve
duplicates drop y2_hhid plot_id season female, force
duplicates tag y2_hhid plot_id season, g(dups)
gen dm_gender = 1 if female==0
replace dm_gender = 2 if female==1
replace dm_gender = 3 if dups > 0
keep y2_hhid plot_id season dm_gender
duplicates drop
restore
//w/o season - note no difference
duplicates drop y2_hhid plot_id female, force
duplicates tag y2_hhid plot_id, g(dups)
gen dm_gender = 1 if female==0
replace dm_gender = 2 if female==1
replace dm_gender = 3 if dups > 0
keep y2_hhid plot_id dm_gender
duplicates drop

keep y2_hhid plot_id dm_gender
drop if dm_gender==.
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_decision_makers.dta", replace

********************************************************************************
* FORMALIZED LAND RIGHTS *
********************************************************************************
**# Bookmark #1

use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear
gen season=0
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_k_13.dta"
replace season=1 if season==.
lab var season "season: 0=rainy, 1=dry, 2=tree crop"
label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
label values season season

gen formal_land_rights=1 if ag_d03_1 == 1
replace formal_land_rights=1 if ag_d03>1 & ag_d03<6 & formal_land_rights==.
replace formal_land_rights=1 if ag_k04>1 & ag_k04<6 & formal_land_rights==.
replace formal_land_rights=0 if ag_d03>5 & formal_land_rights==.
replace formal_land_rights=0 if ag_k04>5 & formal_land_rights==.

//Primary Land Owner
gen indiv=ag_d04a
replace indiv=ag_k05a if ag_k05a!=. & indiv==.
merge m:1 y2_hhid indiv using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_person_ids.dta", keep (1 3) nogen 
ren indiv primary_land_owner
ren female primary_land_owner_female
drop age hh_head

//Secondary Land Owner
gen indiv=ag_d04b
replace indiv=ag_k05b if ag_k05b!=. & indiv==.
merge m:1 y2_hhid indiv using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_person_ids.dta", keep (1 3) nogen
ren indiv secondary_land_owner
ren female secondary_land_owner_female
drop age hh_head

gen formal_land_rights_f=1 if formal_land_rights==1 & (primary_land_owner_female==1 | secondary_land_owner_female==1)
preserve
collapse (max) formal_land_rights_f, by(y2_hhid) 
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_land_rights_ind.dta", replace
restore
collapse (max) formal_land_rights_hh=formal_land_rights, by(y2_hhid)
keep y2_hhid formal_land_rights_hh
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_land_rights_hh.dta", replace

************************
*CROP UNIT CONVERSION FACTORS
************************
use "${Malawi_IHPS_W2_raw_data}/IHS.Agricultural.Conversion.Factor.Database.dta", clear //ALT 11.06.23: Returning this to the original name in the raw data.
ren crop_code crop_code_full
save "${Malawi_IHPS_W2_created_data}/Malawi_W2_cf.dta", replace

************************
* Caloric conversions
************************
	use "${Malawi_IHPS_W2_raw_data}/caloric_conversionfactor.dta", clear //ALT: 11.06.23: Note that this idn't in the original W2 raw data and must included in the github repo.
	drop if inlist(item_code, 101, 102, 103, 105, 202, 204, 206, 207, 301, 305, 405, 813, 820, 822, 901, 902) | cal_100g == .
	local item_name item_name
	foreach var of varlist item_name{
		gen item_name_upper=upper(`var')
	}
	
	gen crop_code = .
	count if missing(crop_code) //142 missing
	
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

	count if missing(crop_code) //104 missing
	
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
	
	count if missing(crop_code) //76 missing
	drop if crop_code == . 
	
	
	gen unit = 1 //kg
	gen region = 1
	merge 1:m crop_code unit region using "${Malawi_IHPS_W2_raw_data}/Agricultural Conversion Factor Database.dta", nogen keepusing(condition shell_unshelled) keep(1 3)
	replace edible_p = shell_unshelled * edible_p if shell_unshelled !=. & item_code==104
	
	// Extra step for groundnut: single item with edible portion that implies that value is for unshelled
	// If it's shelled, assume edible portion is 100
	replace edible_p = 100 if strpos(item_name,"Groundnut") & strpos(item_name, "Shelled")

	keep item_name crop_code cal_100g edible_p condition
	
	// Assume shelled if edible portion is 100
	replace condition=1 if edible_p==100
	
	// More matches using crop_code_short

	save "${Malawi_IHPS_W2_raw_data}/caloric_conversionfactor_crop_codes.dta", replace




********************************************************************************
*ALL PLOTS - TK Updated 2/1/24
********************************************************************************
/*Inputs to this section: 
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
	*Crop Values
	***************************
	
//Nonstandard unit values (kg values in plot variables section)
	use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_i_13.dta", clear
	gen season=0 //rainy season
	append using "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_o_13.dta"
	recode season (.=1) //dry season
	append using "${Malawi_IHPS_W2_raw_data}/Agriculture/AG_MOD_Q_13.dta"
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
	
	ren ag_i0b crop_code_long
	replace crop_code_long =ag_o0b if crop_code_long ==. & ag_o0b!=.
	
	gen crop_code_perm=ag_q0b 
	recode crop_code_perm (1=49)(2=50)(3=51)(4=52)(5=53)(6=54)(7=55)(8=56)(9=57)(10=58)(11=59)(12=60)(13=61)(14=62)(15=63)(16=64)(17=65)(18=48) 
	la var crop_code_perm "Unique crop codes for trees/ permanent crops"
	
	replace crop_code_long=crop_code_perm if crop_code_long==. & crop_code_perm!=. //TK: applying tree codes to crop codes
	label define relabel 1 "MAIZE LOCAL" 2 "MAIZE COMPOSITE/OPV" 3 "MAIZE HYBRID" 4 "MAIZE HYBRID RECYCLED" 5 "TOBACCO BURLEY" 6 "TOBACCO FLUE CURED" 7 "TOBACCO NNDF" 8 "TOBACCOSDF" 9 "TOBACCO ORIENTAL" 10 "OTHER TOBACCO (SPECIFY)" 11 "GROUNDNUT CHALIMBANA" 12 "GROUNDNUT CG7" 13 "GROUNDNUT MANIPINTA" 14 "GROUNDNUT MAWANGA" 15 "GROUNDNUT JL24" 16 "OTHER GROUNDNUT(SPECIFY)" 17 "RISE LOCAL" 18 "RISE FAYA" 19 "RISE PUSSA" 20 "RISE TCG10" 21 "RISE IET4094 (SENGA)" 22 "RISE WAMBONE" 23 "RISE KILOMBERO" 24 "RISE ITA" 25 "RISE MTUPATUPA" 26 "OTHER RICE(SPECIFY)"  28 "SWEET POTATO" 29 "IRISH [MALAWI] POTATO" 30 "WHEAT" 34 "BEANS" 35 "SOYABEAN" 36 "PIGEONPEA(NANDOLO" 37 "COTTON" 38 "SUNFLOWER" 39 "SUGAR CANE" 40 "CABBAGE" 41 "TANAPOSI" 42 "NKHWANI" 43 "THERERE/OKRA" 44 "TOMATO" 45 "ONION" 46 "PEA" 47 "PAPRIKA" 48 "OTHER (SPECIFY)" /*cleaning up these existing labels*/ 27 "GROUND BEAN (NZAMA)" 31 "FINGER MILLET (MAWERE)" 32 "SORGHUM" 33 "PEARL MILLET (MCHEWERE)" /*now creating unique codes for tree crops*/ 49 "CASSAVA" 50 "TEA" 51 "COFFEE" 52 "MANGO" 53 "ORANGE" 54 "PAWPAW/PAPAYA" 55 "BANANA" 56 "AVOCADO" 57 "GUAVA" 58 "LEMON" 59 "NAARTJE (TANGERINE)" 60 "PEACH" 61 "POZA (CUSTADE APPLE)" 62 "MASUKU (MEXICAN APPLE)" 63 "MASAU" 64 "PINEAPPLE" 65 "MACADEMIA" /*adding other specified crop codes*/ 105 "MAIZE GREEN" 203 "SWEET POTATO WHITE" 204 "SWEET POTATO ORANGE" 207 "PLANTAIN" 208 "COCOYAM (MASIMBI)" 301 "BEAN, WHITE" 302 "BEAN, BROWN" 308 "COWPEA (KHOBWE)" 405 "CHINESE CABBAGE" 409 "CUCUMBER" 410 "PUMPKIN" 1800 "FODDER TREES" 1900 "FERTILIZER TREES" 2000 "FUEL WOOD TREES", modify
	label val crop_code_long relabel 
		
	
	keep occ y2_hhid qx_type interview_status sold_qty unit sold_value crop_code_long
		
	merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_weights.dta", nogen keepusing(region stratum district ta ea rural weight) //not matched 781, matched 16,673 
	gen price_unit = sold_value/sold_qty //14,640 missing values; n=17,454
	lab var price_unit "Average sold value per crop unit"
	gen obs=price_unit!=.
	
	*create a value for the price of each crop at different levels
	foreach i in region district ta ea y2_hhid{
	preserve
	bys `i' crop_code_long unit : egen obs_`i'_price = sum(obs) 
	collapse (median) price_unit_`i'=price_unit [aw=weight], by (`i' unit crop_code_long obs_`i'_price) 
	tempfile price_unit_`i'_median
	save `price_unit_`i'_median'
	restore
	}
	collapse (median) price_unit_country = price_unit (sum) obs_country_price=obs [aw=weight], by(crop_code_long unit)
	tempfile price_unit_country_median
	save `price_unit_country_median'
	
	
		
	***************************
	*Plot variables
	***************************	
	// TK 1/29/24 - Integrated updated conversion factor file
	use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_g_13.dta", clear //rainy
	gen season=0 //create variable for season 
	append using "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_m_13.dta" //dry
	recode season(.=1)
	ren ag_g0b crop_code_long
	replace crop_code_long =ag_m0c if crop_code_long==. & ag_m0c!=.
	ren ag_g00 plot_id 
	replace plot_id=ag_m00 if plot_id==""
	append using "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_p_13.dta"
	replace plot_id=ag_p00 if plot_id=="" 
	replace ag_p03=. if ag_p03==999
	ren ag_p03 number_trees_planted
	recode season (.=2)
	lab var season "season: 0=rainy, 1=dry, 2=tree crop"
	label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
	label values season season
	gen crop_code_perm=ag_p0c //tree crop codes overlap with crop crop codes, recoded  here to have unique numbers
	recode crop_code_perm (1=49)(2=50)(3=51)(4=52)(5=53)(6=54)(7=55)(8=56)(9=57)(10=58)(11=59)(12=60)(13=61)(14=62)(15=63)(16=64)(17=65)(18=48)
	la var crop_code_perm "Unique crop codes for trees/ permanent crops"

	replace crop_code_long=crop_code_perm if crop_code_long==. & crop_code_perm!=. //TK: applying tree codes to crop codes
	label define relabel 1 "MAIZE LOCAL" 2 "MAIZE COMPOSITE/OPV" 3 "MAIZE HYBRID" 4 "MAIZE HYBRID RECYCLED" 5 "TOBACCO BURLEY" 6 "TOBACCO FLUE CURED" 7 "TOBACCO NNDF" 8 "TOBACCOSDF" 9 "TOBACCO ORIENTAL" 10 "OTHER TOBACCO (SPECIFY)" 11 "GROUNDNUT CHALIMBANA" 12 "GROUNDNUT CG7" 13 "GROUNDNUT MANIPINTA" 14 "GROUNDNUT MAWANGA" 15 "GROUNDNUT JL24" 16 "OTHER GROUNDNUT(SPECIFY)" 17 "RISE LOCAL" 18 "RISE FAYA" 19 "RISE PUSSA" 20 "RISE TCG10" 21 "RISE IET4094 (SENGA)" 22 "RISE WAMBONE" 23 "RISE KILOMBERO" 24 "RISE ITA" 25 "RISE MTUPATUPA" 26 "OTHER RICE(SPECIFY)"  28 "SWEET POTATO" 29 "IRISH [MALAWI] POTATO" 30 "WHEAT" 34 "BEANS" 35 "SOYABEAN" 36 "PIGEONPEA(NANDOLO" 37 "COTTON" 38 "SUNFLOWER" 39 "SUGAR CANE" 40 "CABBAGE" 41 "TANAPOSI" 42 "NKHWANI" 43 "THERERE/OKRA" 44 "TOMATO" 45 "ONION" 46 "PEA" 47 "PAPRIKA" 48 "OTHER (SPECIFY)" /*cleaning up these existing labels*/ 27 "GROUND BEAN (NZAMA)" 31 "FINGER MILLET (MAWERE)" 32 "SORGHUM" 33 "PEARL MILLET (MCHEWERE)" /*now creating unique codes for tree crops*/ 49 "CASSAVA" 50 "TEA" 51 "COFFEE" 52 "MANGO" 53 "ORANGE" 54 "PAWPAW/PAPAYA" 55 "BANANA" 56 "AVOCADO" 57 "GUAVA" 58 "LEMON" 59 "NAARTJE (TANGERINE)" 60 "PEACH" 61 "POZA (CUSTADE APPLE)" 62 "MASUKU (MEXICAN APPLE)" 63 "MASAU" 64 "PINEAPPLE" 65 "MACADEMIA" /*adding other specified crop codes*/ 105 "MAIZE GREEN" 203 "SWEET POTATO WHITE" 204 "SWEET POTATO ORANGE" 207 "PLANTAIN" 208 "COCOYAM (MASIMBI)" 301 "BEAN, WHITE" 302 "BEAN, BROWN" 308 "COWPEA (KHOBWE)" 405 "CHINESE CABBAGE" 409 "CUCUMBER" 410 "PUMPKIN" 1800 "FODDER TREES" 1900 "FERTILIZER TREES" 2000 "FUEL WOOD TREES", modify
	label val crop_code_long relabel 
	
	la var crop_code_long "Unconsolidated crop crops"
**consolidate crop codes (into the lowest number of the crop category)
	gen crop_code = crop_code_long //Generic level (without detail)
	recode crop_code (1 2 3 4=1)(5 6 7 8 9 10=5)(11 12 13 14 15 16=11)(17 18 19 20 21 22 23 24 25 26=17) //1-4=maize ; 5-10=tobacco; 11-16=groundnut; 17-26=rice
	la var crop_code "Generic level crop code"
	label define relabel2  1 "MAIZE" 5 "TOBACCO" 11 "GROUNDNUT" 17 "RICE" 28 "SWEET POTATO" 29 "IRISH [MALAWI] POTATO" 30 "WHEAT" 34 "BEANS" 35 "SOYABEAN" 36 "PIGEONPEA(NANDOLO" 37 "COTTON" 38 "SUNFLOWER" 39 "SUGAR CANE" 40 "CABBAGE" 41 "TANAPOSI" 42 "NKHWANI" 43 "THERERE/OKRA" 44 "TOMATO" 45 "ONION" 46 "PEA" 47 "PAPRIKA" 48 "OTHER (SPECIFY)"/*cleaning up these existing labels*/ 27 "GROUND BEAN (NZAMA)" 31 "FINGER MILLET (MAWERE)" 32 "SORGHUM" 33 "PEARL MILLET (MCHEWERE)" /*now creating unique codes for tree crops*/ 49 "CASSAVA" 50 "TEA" 51 "COFFEE" 52 "MANGO" 53 "ORANGE" 54 "PAWPAW/PAPAYA" 55 "BANANA" 56 "AVOCADO" 57 "GUAVA" 58 "LEMON" 59 "NAARTJE (TANGERINE)" 60 "PEACH" 61 "POZA (CUSTADE APPLE)" 62 "MASUKU (MEXICAN APPLE)" 63 "MASAU" 64 "PINEAPPLE" 65 "MACADEMIA" /*adding other specified crop codes*/ 105 "MAIZE GREEN" 203 "SWEET POTATO WHITE" 204 "SWEET POTATO ORANGE" 207 "PLANTAIN" 208 "COCOYAM (MASIMBI)" 301 "BEAN, WHITE" 302 "BEAN, BROWN" 308 "COWPEA (KHOBWE)" 405 "CHINESE CABBAGE" 409 "CUCUMBER" 410 "PUMPKIN" 1800 "FODDER TREES" 1900 "FERTILIZER TREES" 2000 "FUEL WOOD TREES", modify
la val crop_code relabel2	
	drop if crop_code==. //4,509 observations deleted

	*Create area variables 		
	gen crop_area_share=ag_g03 //rainy season TH: this indicates proportion of plot with crop, but NGA area_unit indicates the unit (ie stands/ridges/heaps) that area was measured in; tree file did not ask about area planted
	label var crop_area_share "Proportion of plot planted with crop"
	replace crop_area_share=ag_m03 if crop_area_share==. & ag_m03!=.
	replace crop_area_share=0.125 if crop_area_share==1 //converting answers to proportions
	replace crop_area_share=0.25 if crop_area_share==2 
	replace crop_area_share=0.5 if crop_area_share==3
	replace crop_area_share=0.75 if crop_area_share==4
	replace crop_area_share=.875 if crop_area_share==5
	replace crop_area_share=1 if ag_g02==1 | ag_m02==1
	replace crop_area_share=1 if (ag_g01==1 | ag_m01==1) & crop_area_share==.
	merge m:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_areas.dta" 
	gen ha_planted=crop_area_share*area_meas_hectares
	replace ha_planted=crop_area_share*area_est_hectares if ha_planted==. & area_est_hectares!=. & area_est_hectares!=0
	
	tempfile ha_planted
	save `ha_planted'
		
	drop crop_area_share
	gen ha_harvested=ha_planted 
	
	*Create time variables (month planted, harvest, and length of time grown)
	
	*month planted
	gen month_planted = ag_g05a
	replace month_planted = ag_m05a if month_planted==.
	lab var month_planted "Month of planting"
	
	*year planted
	replace ag_m05b=2011 if ag_m05b==1
	replace ag_m05b=2012 if ag_m05b==2
	drop if ag_m05b==7|ag_m05b==8 |ag_m05b==2007 |ag_m05b==2011 //TH:question asked about dry season in 2013, dropping responses not in 2013
	replace ag_g05b=2012 if ag_g05b==12 //TH:recoding year for recognizable typos and dropping others
	replace ag_g05b=2012 if ag_g05b==2
	replace ag_g05b=2011 if ag_g05b==1
	replace ag_g05b=2012 if ag_g05b==202
	drop if (ag_g05b ==4 |ag_g05b ==20 |ag_g05b ==2005|ag_g05b ==2011) //TH:question asked about rainy in 2012/2013 only, dropping responses not in 2012/13
	gen year_planted1 = ag_g05b
	gen year_planted2 = ag_m05b //dry season 2013, 19 obs from 2012
	gen year_planted = year_planted1
	replace year_planted= year_planted2 if year_planted==.
	lab var year_planted "Year of planting"
	
	*month harvest started
	gen harvest_month_begin = ag_g12a
	replace harvest_month_begin=ag_m12a if harvest_month_begin==. & ag_m12a!=. //MGM: 0 changes made. Something seems to be going continually wrong the dry season data. Not a lot of information there.
	lab var harvest_month_begin "Month of start of harvesting"
	
	*month harvest ended
	gen harvest_month_end=ag_g12b
	replace harvest_month_end=ag_m12b if harvest_month_end==. & ag_m12b!=.
	lab var harvest_month_end "Month of end of harvesting"
	
	*Inferring harvest year from month_planted, year_planted, harvest_month_begin, and months_grown, needs to be be integrated onto main MWI W2 code
	//all observations of months_grown less than or equal to 11 months. Hence, the following code:
	gen year_harvested=year_planted if harvest_month_begin>month_planted
	replace year_harvested=year_planted+1 if harvest_month_begin<month_planted
	//lab var year_harvested "Year of harvesting
	
	*months crop grown
	gen months_grown = harvest_month_begin - month_planted if harvest_month_begin > month_planted  // since no year info, assuming if month harvested was greater than month planted, they were in same year 
	replace months_grown = 12 - month_planted + harvest_month_begin if harvest_month_begin < month_planted // months in the first calendar year when crop planted 
	replace months_grown = 12 - month_planted if months_grown<1 // reconcile crops for which month planted is later than month harvested in the same year
	replace months_grown=. if months_grown <1 | month_planted==. | harvest_month_begin==.
	lab var months_grown "Total months crops were grown before harvest"
	
	preserve
	gen days_grown = months_grown*30 
	collapse (max) days_grown, by(y2_hhid plot_id)
	save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_plot_season_length.dta", replace
	restore

	preserve
		gen obs=1
		replace obs=0 if ag_g09a==0 | ag_m11a==0 | ag_p09a==0  //obs=0 if no crops were harvested 
		collapse(sum)crops_plot=obs, by(y2_hhid plot_id season)
		//br if crops_plot>1
		tempfile ncrops
		save `ncrops'
	restore
	
		merge m:1 y2_hhid plot_id season using `ncrops', nogen
		
		gen contradict_mono = 1 if (ag_g01==1 | ag_m01==1) & crops_plot >1 //49 plots reported >1 crop but list as monocrop; tree crops did not ask about mono/mix cropping
		gen contradict_inter = 1 if (ag_g01==2 | ag_m01==2) & crops_plot ==1 
		replace contradict_inter = . if ag_g01==1 | ag_m01==1 //958 plots reported 1 crop but list as intercrop; tree crops did not ask about mono/mix cropping
		
		*Generating monocropped plot variables (Part 1)
		bys y2_hhid plot_id season: egen crops_avg= mean(crop_code) //checks for diff versions of same crop in the same plot
		gen purestand=1 if crops_plot==1 //7930 missing values
		gen perm_crop=1 if ag_p0c!=. //11515 missing values
		bys y2_hhid plot_id : egen permax = max(perm_crop) //all perm crop has max of 1
		
		*Generating mixed stand plot variables (Part 2)
	gen any_mixed=!(ag_g01==1 | ag_m01==1 | (perm_crop==1 & purestand==1)) //TH: 384 where purestand == any_mixed 4/20/22
	bys y2_hhid plot_id : egen any_mixed_max = max(any_mixed) 
	
	replace purestand=1 if crop_code == crops_avg
	replace purestand=0 if purestand ==. //assumes null values are just 0
	drop crops_plot crops_avg permax
	
	
	*Generating total percent of purestand and monocropped on a field
	gen percent_field=ha_planted/field_size 
	
	bys y2_hhid plot_id: egen total_percent = total(percent_field)
	
	preserve
	gen overplanted = total_percent > 1
	duplicates drop y2_hhid plot_id, force
	collapse (mean) overplanted, by(purestand)
	tabstat overplanted, by(purestand)
	restore
	
	//about 64% of plots have a total intercropped sum greater than 1
	//about 2% of plots have a total monocropped sum greater than 1
	
	*Dealing with crops which have monocropping larger than plot size or monocropping that fills plot size and still has intercropping to add
	replace percent_field = percent_field/total_percent if total_percent > 1 & purestand == 0
	replace percent_field=1 if percent_field>1 & purestand==1 //6016 changes made, total increased from 7012 to 12906
	replace ha_planted = percent_field*field_size
	
	*renaming unit code for merge
	ren ag_g09b unit 
	replace unit = ag_m11b if unit==. & ag_m11b!=.
	replace unit = ag_p09b if unit==. & ag_p09b!=.

	ren ag_g09a quantity_harvested
	replace quantity_harvested = ag_m11a if quantity_harvested==. & ag_m11a!=.
	replace quantity_harvested = ag_p09a if quantity_harvested==. & ag_p09a!=.
	
	*renaming crop_code to match name in using file
	//ren crop_code crop_code_long
	
	*renaming condition vars in master to match using file 
// 	ren ag_g09c condition
// 	lab val condition condition
// 	replace condition = ag_m11c if quantity_harvested==. & ag_m11c!=. 
	
	*merging in region from hhids file and conversion factors 
	//drop _merge
	merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta", nogen keep(1 3) //14229 matched
	
	
gen condition=ag_g09c
	lab define condition 1 "S: SHELLED" 2 "U: UNSHELLED" 3 "N/A", modify
	lab val condition condition
	replace condition = ag_g13c if condition==. & ag_g13c !=. //3,147  changes
	replace condition = ag_m11c if condition==. & ag_m11c !=. //173 real changes made, no observations for ag_m11c
	replace condition=3 if condition==. & crop_code!=. & unit!=. // conversion factor file is designed to create more merges provided recoding blank conditions to n/a
	
	
	
capture {
		confirm file `"${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_cf.dta"'
	} 
	if !_rc {
merge m:1 region crop_code_long unit condition using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_cf.dta", keep(1 3) gen(cf_merge) //Old : 8360 not matched from master, 5869 matched old ;  New: 5,980 from master Not Matched,  8,195 Matched
} 
else {
 di as error "Updated conversion factors file not present; harvest data will likely be incomplete"
}
	

gen quant_harv_kg= quantity_harvested*conversion //5,932 missing 
	
// preserve
// keep quant_harv_kg crop_code_long crop_code y2_hhid plot_id season
// save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_yield_1_6_23.dta", replace
// restore	
	
merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_weights.dta", nogen keep(1 3)

foreach i in region district ta ea y2_hhid {
	merge m:1 `i' crop_code_long unit using `price_unit_`i'_median', nogen keep(1 3)
	}
merge m:1 unit crop_code_long using `price_unit_country_median', nogen keep(1 3)

gen value_harvest = price_unit_y2_hhid * quantity_harvested
gen missing_price = value_harvest == .
foreach i in region district ta ea { //decending order from largest to smallest geographical figure
replace value_harvest = quantity_harvested * price_unit_`i' if missing_price == 1 & obs_`i' > 9 & obs_`i' != . 
}
replace value_harvest = quantity_harvested * price_unit_country if value_harvest==.

	gen val_unit = value_harvest/quantity_harvested
	gen val_kg = value_harvest/quant_harv_kg 
	
	gen plotweight = ha_planted*conversion 
	gen obs=quantity_harvested>0 & quantity_harvested!=.

preserve
	collapse (mean) val_kg, by (y2_hhid crop_code_long)
	ren val_kg hh_price_mean
	lab var hh_price_mean "Average price reported for kg in the household"
	save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_hh_crop_prices_for_wages.dta", replace
restore

// preserve
// collapse (median) val_unit_country = val_unit (sum) obs_country_unit=obs [aw=plotweight], by(crop_code unit)
// save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_crop_prices_median_country.dta", replace 
// restore	
	************************
	* Adding Caloric conversion
	************************
	// Add calories if the prerequisite caloric conversion file exists
	capture {
		confirm file `"${Malawi_IHPS_W2_created_data}/caloric_conversionfactor_crop_codes.dta"'
	} 
	if _rc!=0 {
		display "Note: file ${Malawi_IHPS_W2_created_data}/caloric_conversionfactor_crop_codes.dta does not exist - skipping calorie calculations"		
	}
	if _rc==0{
		merge m:1 crop_code using "${Malawi_IHPS_W2_created_data}/caloric_conversionfactor_crop_codes.dta", nogen keep(1 3)
	

		gen calories = cal_100g * quant_harv_kg * edible_p / .1 
		count if missing(calories)
	}	

//AgQuery
	collapse (sum) quant_harv_kg value_harvest ha_planted ha_harvest number_trees_planted percent_field (max) months_grown, by(region stratum district ea rural y2_hhid plot_id crop_code crop_code_long purestand area_meas_hectares season)
	bys y2_hhid plot_id : egen percent_area = sum(percent_field)
	bys y2_hhid plot_id : gen percent_inputs = percent_field/percent_area //1216 missing
	drop percent_area //Assumes that inputs are +/- distributed by the area planted. Probably not true for mixed tree/field crops, but reasonable for plots that are all field crops
	//Labor should be weighted by growing season length, though. 
	
	drop if crop_code==. 
	merge m:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender)
	save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_all_plots.dta",replace

	
		/* CODE USED TO DETERMINE THE TOP CROPS
	use "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_all_plots.dta", clear
	merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_hhsize.dta"
	gen area= ha_planted*weight 
	collapse (sum) area, by (crop_code)*/
	
************************
*TLU (Tropical Livestock Units)
************************
use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_r1_13.dta", clear
gen tlu_coefficient=0.5 if (ag_r0a==304|ag_r0a==303|ag_r0a==302|ag_r0a==301) // bull, cow, steer & heifer, calf 
replace tlu_coefficient=0.1 if (ag_r0a==307|ag_r0a==308) // goat, sheep
replace tlu_coefficient=0.2 if (ag_r0a==309) // pig
replace tlu_coefficient=0.01 if (ag_r0a==311|ag_r0a==313|ag_r0a==315|ag_r0a==318|ag_r0a==319|ag_r0a==3310|ag_r0a==3314|ag_r0a==315) //chicken, duck, other poultry, hare in TZ. For MW2: local hen, local cock, duck, other, dove/pigeon, chicken layer/chicken-broiler and turkey/guinea fowl
lab var tlu_coefficient "Tropical Livestock Unit coefficient"

*Livestock categories
gen cattle=inrange(ag_r0a,301,304) // calf and bull for MW2. Included bull and female calf under cattle
gen smallrum=inlist(ag_r0a,307,309) // sheep, goat
gen poultry=inlist(ag_r0a,311,313,315, 319,3310,3314)  // chicken, duck, poultry, hare in TZ. For MW2: local hen, local cock, duck, dove/pigeon, chicken layer/chicken-broiler and turkey/guinea fowl
gen other_ls=ag_r0a==318 | 3305 | 3304 // includes other, donkey/horse, ox
gen cows=ag_r0a==303
gen chickens= ag_r0a==313 | 311 | 3310 | 3314 // includes local cock (313), local hen (311),  chicken layer and broiler(3310), and turkey (3314)
ren ag_r0a livestock_code

*Number of livestock owned at present
ren ag_r02 nb_ls_today
gen nb_cattle_today=nb_ls_today if cattle==1
gen nb_smallrum_today=nb_ls_today if smallrum==1
gen nb_poultry_today=nb_ls_today if poultry==1
gen nb_other_ls_today=nb_ls_today if other==1
gen nb_cows_today=nb_ls_today if cows==1
gen nb_chickens_today=nb_ls_today if chickens==1
gen tlu_today = nb_ls_today * tlu_coefficient

lab var nb_cattle_today "Number of cattle owned as of the time of survey"
lab var nb_smallrum_today "Number of small ruminant owned as of the time of survey"
lab var nb_poultry_today "Number of cattle poultry as of the time of survey"
lab var nb_other_ls_today "Number of other livestock (horse, donkey, and other) owned as of the time of survey"
lab var nb_cows_today "Number of cows owned as of the time of survey"
lab var nb_chickens_today "Number of chickens owned as of the time of survey"
lab var tlu_today "Tropical Livestock Units as of the time of survey"
lab var nb_ls_today "Number of livestock owned as of today"

*Number of livestock owned 1 year ago
gen nb_cattle_1yearago = ag_r07 if cattle==1
gen nb_smallrum_1yearago=ag_r07 if smallrum==1
gen nb_poultry_1yearago=ag_r07 if poultry==1
gen nb_other_1yearago=ag_r07 if other==1
gen nb_cows_1yearago=ag_r07 if cows==1
gen nb_chickens_1yearago=ag_r07 if chickens==1
gen tlu_1yearago = ag_r07 * tlu_coefficient
ren ag_r07 nb_ls_1yearago 

lab var nb_cattle_1yearago "Number of cattle owned as of 12 months ago"
lab var nb_smallrum_1yearago "Number of small ruminant owned as of 12 months ago"
lab var nb_poultry_1yearago "Number of cattle poultry as of 12 months ago"
lab var nb_other_1yearago "Number of other livestock (horse, donkey, and other) owned as of 12 months ago"
lab var nb_cows_1yearago "Number of cows owned as of 12 months ago"
lab var nb_chickens_1yearago "Number of chickens owned as of 12 months ago"
lab var nb_ls_1yearago "Number of livestock owned 12 months ago"

recode tlu_* nb_* (.=0)
collapse (sum) tlu_* nb_*  , by (y2_hhid)
drop tlu_coefficient
save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_TLU_Coefficients.dta", replace


************************
*GROSS CROP REVENUE
************************
//
// use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_g_13.dta", clear
// append using "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_m_13.dta", gen(dry)
// gen crop_code=.
// replace crop_code=1 if ag_g0b == 1 | ag_g0b  == 2 | ag_g0b == 3 | ag_g0b  == 4 | ag_m0c == 1 | ag_m0c== 2 | ag_m0c == 3 | ag_m0c== 4 // maize
// replace crop_code=2 if ag_g0b == 5 | ag_g0b == 6 | ag_g0b== 7 | ag_g0b == 10 | ag_m0c == 6 //tobacco
// replace crop_code=3 if ag_g0b == 11 | ag_g0b == 12 | ag_g0b == 13 |ag_g0b == 14 | ag_g0b == 15 | ag_g0b == 16  //groundnut
// replace crop_code=4 if ag_g0b == 17 | ag_g0b == 18 | ag_g0b == 19 | ag_g0b == 20 | ag_g0b == 21 | ag_g0b == 22 | ag_g0b == 23 | ag_g0b == 25 | ag_g0b == 26 | ag_g0b == 27| ag_m0c == 18 | ag_m0c == 20 | ag_m0c == 21 | ag_m0c == 23 | ag_m0c == 25 | ag_m0c == 26 //rice
// replace crop_code=5 if ag_g0b == 27 |ag_m0c == 27 //groundbean
// replace crop_code=6 if ag_g0b == 28 | ag_m0c == 28 //sweet potato
// replace crop_code=7 if ag_g0b == 29 | ag_m0c == 29 //Irish (Malawi) potato
// replace crop_code=8 if ag_g0b == 31  //finger millet
// replace crop_code=9 if ag_g0b == 32 | ag_m0c == 32 //sorghum
// replace crop_code=10 if ag_g0b == 33 //pearl millet
// replace crop_code=11 if ag_g0b == 34 |ag_m0c == 34 //beans
// replace crop_code=12 if ag_g0b == 35 //soyabean
// replace crop_code=13 if ag_g0b == 36 |ag_m0c == 36 //pigeonpea
// replace crop_code=14 if ag_g0b == 37 //cotton
// replace crop_code=15 if ag_g0b == 38 //sunflower
// replace crop_code=16 if ag_g0b == 39 |ag_m0c == 39  //sugarcane
// replace crop_code=17 if ag_g0b == 40 | ag_m0c == 40 //cabbage
// replace crop_code=18 if ag_g0b == 41 | ag_m0c == 41 //tanaposi
// replace crop_code=19 if ag_g0b == 42 | ag_m0c == 42 //nkhwani
// replace crop_code=20 if ag_g0b == 43 | ag_m0c == 43 //okra
// replace crop_code=21 if ag_g0b == 44 | ag_m0c == 44 //tomato
// replace crop_code=22 if ag_g0b == 45 | ag_m0c == 45 //onion
// replace crop_code=23 if ag_g0b == 46 | ag_m0c == 46 //pea
// replace crop_code=24 if ag_g0b == 47 | ag_m0c == 47 // paprika 
// replace crop_code=25 if ag_g0b == 48 | ag_m0c == 48 //other
// la def crop_code 1 "Maize" 2 "Tobacco" 3 "Groundnut" 4 "Rice" 5 "Ground Bean" 6 "Sweet Potato" 7 "Irish (Malawi) Potato" 8"Finger Millet" 9 "Sorghum" 10 "Pearl Millet" 11 "Beans" 12 "Soyabean" 13 "Pigeon Pea" /*
// */ 14 "Cotton" 15 "Sunflower" 16 "Sugar Cane" 17 "Cabbage" 18 "Tanaposi" 19 "Nkhwani" 20 "Okra" 21 "Tomato" 22 "Onion" 23 "Pea" 24 "Paprika" 25 "Other"
// la val crop_code crop_code
// lab var crop_code "Crop Code"
//
// *Rename variables so they match in merged files
// ren ag_g00 plot_id
// ren ag_g0b crop_code_full
// replace crop_code_full = ag_m0c if crop_code_full==.
// ren ag_g13b unit 
// replace unit = ag_g09b if unit==. 
// replace unit = ag_m11b if unit==.
// ren ag_g13c condition
// replace condition = ag_g09c if condition==. 
// replace condition = ag_m11c if condition==.
//
// *Merge in region from hhids file and conversion factors
// merge m:1 y2_hhid using  "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta", nogen keep(1 3)	
// merge m:1 region crop_code_full unit condition using  "${Malawi_IHPS_W2_created_data}/Malawi_W2_cf.dta"
//
// *Temporary crops (both seasons)
// gen harvest_yesno=.
// replace harvest_yesno = 1 if ag_g13a > 0 & ag_g13a !=. 
// replace harvest_yesno = 2 if ag_g13a == 0
// gen kgs_harvest = ag_g13a*conversion if crop_code== `c' 
// replace kgs_harvest = ag_m11a*conversion if crop_code==`c' & kgs_harvest==.
// replace kgs_harvest = 0 if harvest_yesno==2
//
// collapse (sum) kgs_harvest /*value_harvest*/, by (y2_hhid crop_code plot_id)
// lab var kgs_harvest "Kgs harvested of this crop, summed over main and short season"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_tempcrop_harvest.dta", replace
//
//
// *Value of harvest by quantity sold - in Module I of Malawi LSMS W2 (no value of harvest question)
// use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_i_13.dta", clear
// append using "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_o_13.dta", gen(dry)
//
// gen crop_code=.
// replace crop_code=1 if ag_i0b == 1 | ag_i0b == 2 | ag_i0b == 3 | ag_i0b == 4 | ag_o0b == 1 | ag_o0b == 2 | ag_o0b == 3 | ag_o0b == 4 //maize
// replace crop_code=2 if ag_i0b == 5 | ag_i0b == 6 | ag_i0b == 7 | ag_i0b == 10 //tobacco
// replace crop_code=3 if ag_i0b == 11 | ag_i0b == 12 | ag_i0b == 13 | ag_i0b == 14 | ag_i0b == 15 | ag_i0b == 16 // groundnut
// replace crop_code=4 if ag_i0b == 17 | ag_i0b == 18 | ag_i0b == 19 | ag_i0b == 20 | ag_i0b == 21 | ag_i0b == 22 | ag_i0b == 23 | ag_i0b == 25 | ag_i0b == 26 | ag_o0b == 18 | ag_o0b == 20 | ag_o0b == 21/*
// */ | ag_o0b == 23 | ag_o0b == 25 | ag_o0b == 26 // rice  
// replace crop_code=5 if ag_i0b == 27 // ground bean
// replace crop_code=6 if ag_i0b == 28 | ag_o0b == 28 //sweet potato
// replace crop_code=7 if ag_i0b == 29 | ag_o0b == 29 // Irish potato
// replace crop_code=9 if ag_i0b == 31 // finger millet
// replace crop_code=10 if ag_i0b == 32 | ag_o0b == 32 // sorghum
// replace crop_code=11 if ag_i0b == 33 // pearl millet
// replace crop_code=12 if ag_i0b == 34 | ag_o0b == 34 //beans
// replace crop_code=13 if ag_i0b == 35 | ag_o0b == 35 // soyabean
// replace crop_code=14 if ag_i0b == 36 | ag_o0b == 36 // pigeonpea
// replace crop_code=15 if ag_i0b == 37 // cotton
// replace crop_code=16 if ag_i0b == 38 // sunflower
// replace crop_code=17 if ag_i0b == 39 | ag_o0b == 39 // sugarcane
// replace crop_code=18 if ag_i0b == 40 | ag_o0b == 40 // cabbage
// replace crop_code=19 if ag_i0b == 41 | ag_o0b == 41 // tanaposi
// replace crop_code=20 if ag_i0b == 42 | ag_o0b == 42 // nkhwani
// replace crop_code=21 if ag_i0b == 43 | ag_o0b == 43 // okra
// replace crop_code=22 if ag_i0b == 44 | ag_o0b == 44 // tomato
// replace crop_code=23 if ag_i0b == 45 | ag_o0b == 45 // onion
// replace crop_code=24 if ag_i0b == 46 | ag_o0b == 46 // pea
// replace crop_code=25 if ag_i0b == 47 | ag_o0b == 47 // paprika
// replace crop_code=26 if ag_i0b == 48 | ag_o0b == 48 // other
// la def crop_code 1 "Maize" 2 "Tobacco" 3 "Groundnut" 4 "Rice" 5 "Ground Bean" 6 "Sweet Potato" 7 "Irish (Malawi) Potato" 8 "Finger Millet" 9 "Sorghum" 10 "Pearl Millet" 11 "Beans" 12 "Soyabean" 13 "Pigeon Pea" /*
// */ 14 "Cotton" 15 "Sunflower" 16 "Sugar Cane" 17 "Cabbage" 18 "Tanaposi" 19 "Nkhwani" 20 "Okra" 21 "Tomato" 22 "Onion" 23 "Pea" 24 "Paprika" 25 "Other"
// la val crop_code crop_code
// lab var crop_code "Crop Code" 
//
// *Rename variables so they match in merged files
// ren ag_i0b crop_code_full
// replace crop_code_full = ag_o0b if crop_code_full==.
// ren ag_i02b unit 
// replace unit = ag_o02b if unit==. 
// ren ag_i02c condition
// replace condition = ag_o02c if condition==.
//
// *Merge in region from hhids file and conversion factors
// merge m:1 y2_hhid using  "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta", nogen keep(1 3)	
// merge m:1 region crop_code_full unit condition using  "${Malawi_IHPS_W2_created_data}/Malawi_W2_cf.dta"
//
// *Temporary crop sales 
// drop if crop_code_full==.
// rename ag_i01 sell_yesno
// replace sell_yesno = ag_o01 if sell_yesno==.
// gen quantity_sold = ag_i02a*conversion 
// replace quantity_sold = ag_o02a*conversion if quantity_sold==.
// rename ag_i03 value_sold
// replace value_sold = ag_o03 if value_sold==.
// keep if sell_yesno==1
// collapse (sum) quantity_sold value_sold, by (y2_hhid crop_code)
// lab var quantity_sold "Kgs sold of this crop, summed over rainy and dry season"
// lab var value_sold "Value sold of this crop, summed over rainy and dry season"
// gen price_kg = value_sold / quantity_sold
// lab var price_kg "Price per kg sold"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_tempcrop_sales.dta", replace
//
// *Permanent and tree crops //VAP: Need to discuss conversion
// use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_p_13.dta", clear // rainy season
// drop if ag_p02b==.
// rename ag_p0c crop_code
// rename ag_p00 plotid
// replace crop_code = 100 if crop_code == 1 //renamed crop code labels as they overlap with temporary crop codes
// replace crop_code = 200 if crop_code == 2
// replace crop_code = 300 if crop_code == 3
// replace crop_code = 400 if crop_code == 4
// replace crop_code = 500 if crop_code == 5
// replace crop_code = 600 if crop_code == 6
// replace crop_code = 700 if crop_code == 7
// replace crop_code = 800 if crop_code == 8
// replace crop_code = 900 if crop_code == 9
// replace crop_code = 1000 if crop_code == 10
// replace crop_code = 1100 if crop_code == 11
// replace crop_code = 1200 if crop_code == 12
// replace crop_code = 1300 if crop_code == 13
// replace crop_code = 1400 if crop_code == 14
// replace crop_code = 1500 if crop_code == 15
// replace crop_code = 1600 if crop_code == 16
// replace crop_code = 1700 if crop_code == 17
// replace crop_code = 1800 if crop_code == 18
// la def crop_code 100 "Cassava" 200 "Tea" 300 "Mango" 400 "Orange" 500"Papaya"  600 "Banana" 700 "Avocado" 800 "Guava" 900 "Lemon" 1000 "Tangerine" 1100 "Peach" 1200 "Custade Apple (Poza)" 1300 "Mexican Apple (Masuku)" /*
// */ 1400 "Masau" 1500 "Pineapple" 1700 "Other" 
//
// *Rename to match conversion file
// ren ag_p09b unit	
//
//
// * Using conversion file from MW W3, reference is resources PDF provided by World Bank -  missing crops include peach, poza, cassava, and masuku 
// merge m:1 y2_hhid using  "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta", nogen keep(1 3)		
// merge m:1 region crop_code unit using  "${Malawi_IHPS_W2_raw_data}/Conversion_factors_perm.dta"					 
//
// gen kgs_harvest = ag_p09a*Conversion		// VAP: MW W3 file is  missing conversion codes for some units, e.g. "basket"
// collapse (sum) kgs_harvest, by (y2_hhid crop_code plotid)
// lab var kgs_harvest "Kgs harvested of this crop, summed over wet and dry season"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_permcrop_harvest.dta", replace
//
//
// use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_q_13.dta", clear //Dry season 
// ren ag_q0b crop_code
// drop if crop_code==.
// replace crop_code = 100 if crop_code == 1 // cassava VAP: renamed crop code labels as overlap with temporary crop codes. q=867 - use Zambia code 
// replace crop_code = 200 if crop_code == 2 // tea
// replace crop_code = 300 if crop_code == 3 // coffee
// replace crop_code = 400 if crop_code == 4 // mango
// replace crop_code = 500 if crop_code == 5 //orange
// replace crop_code = 600 if crop_code == 6 // papaya
// replace crop_code = 700 if crop_code == 7 // banana
// replace crop_code = 800 if crop_code == 8 // avocado
// replace crop_code = 900 if crop_code == 9  // guava
// replace crop_code = 1000 if crop_code == 10  //lemon
// replace crop_code = 1100 if crop_code == 11  // tangerine
// replace crop_code = 1200 if crop_code == 12  // peach - q=38 - use orange conversion
// replace crop_code = 1300 if crop_code == 13  //poza - - q=25 - use tangerine conversion 
// replace crop_code = 1400 if crop_code == 14  //masuku
// replace crop_code = 1500 if crop_code == 15  //masau
// replace crop_code = 1600 if crop_code == 16  //pineapple
// replace crop_code = 1700 if crop_code == 17  //macademia
// replace crop_code = 1800 if crop_code == 18  //other
// la def crop_code 100 "Cassava" 200 "Tea" 300 "Coffee" 400 "Mango" 500 "Orange" 600 "Papaya" 700 "Banana" 800 "Avocado" 900 "Guava" 1000 "Lemon" 1100 "Tangerine" 1200 "Peach" 1300 "Custade Apple (Poza)" 1400 "Mexican Apple (Masuku)" /*
// */ 1500 "Masau" 1600 "Pineapple" 1700 "Macademia" 1800 "Other" 
//
// *Rename to match conversion file
// ren ag_q02b unit
//
// *Using conversion file from MW W3, refer resources PDF provided by World Bank 
// //Note: Peach, Poza, Cassava, and Masuku do not have conversion codes in Malawi reference doc. Using following conversions from MW W3 for each of these crops:
// 	/*Peach = Orange, Poza = Tangerine, Masuku = Tangerine,  and Cassava =  "Raw cassava" conversion from Zambia LSMS; use raw because most cassava is sold raw in Malawi (http://citeseerx.ist.psu.edu
// 		/viewdoc/download?doi=10.1.1.480.7549&rep=rep1&type=pdf*/
// 	*Ox-cart also does not have a conversion, instead use the conversion factor for "extra large wheelbarrow" from Nigeria (https://microdata.worldbank.org/index.php/catalog/1002/datafile/F75/V1961)
// merge m:1 y2_hhid using  "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta", nogen keep(1 3)		
// merge m:1 region crop_code unit using  "${Malawi_IHPS_W2_raw_data}/Conversion_factors_perm.dta"					
//
// rename ag_q01 sell_yesno
// gen quantity_sold = ag_q02a*Conversion			
// replace quantity_sold = ag_q02a*1 if unit==1	//If quantity is measured in kg multiply by 1 to get KG quantity_sold (don't have this variable in conversion file)
// rename ag_q03 value_sold
// keep if sell_yesno==1
// recode quantity_sold value_sold (.=0)
// collapse (sum) quantity_sold value_sold, by (y2_hhid crop_code)
// lab var quantity_sold "Kgs sold of this crop, summed over rainy and dry season"
// lab var value_sold "Value sold of this crop, summed over rainy and dry season"
// gen price_kg = value_sold / quantity_sold
// lab var price_kg "Price per kg sold"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_permcrop_sales.dta", replace
//
// *Prices of permanent and tree crops need to be imputed from sales
// use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_permcrop_sales.dta", clear
// append using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_tempcrop_sales.dta"
// recode price_kg (0=.)
// merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta"
// drop if _merge==2
// drop _merge
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_sales.dta", replace
//
// use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_sales.dta", clear	 //Measure by EA 
// gen observation = 1
// bys region district ea crop_code: egen obs_ea = count(observation)			
// collapse (median) price_kg [aw=weight], by (region district ta ea crop_code obs_ea)
// rename price_kg price_kg_median_ea
// lab var price_kg_median_ea "Median price per kg for this crop in the enumeration area"
// lab var obs_ea "Number of sales observations for this crop in the enumeration area"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_ea.dta", replace 
//
// use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_sales.dta", clear // Measure by ta
// gen observation = 1
// bys region district ta crop_code: egen obs_ta = count(observation)
// collapse (median) price_kg [aw=weight], by (region district ta crop_code obs_ta)
// rename price_kg price_kg_median_ta
// lab var price_kg_median_ta "Median price per kg for this crop in the ta"
// lab var obs_ta "Number of sales observations for this crop in the ta"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_TA.dta", replace
//
//
// use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_sales.dta", clear //Measure by District 
// gen observation = 1
// bys region district crop_code: egen obs_district = count(observation) 
// collapse (median) price_kg [aw=weight], by (region district crop_code obs_district)
// rename price_kg price_kg_median_district
// lab var price_kg_median_district "Median price per kg for this crop in the district"
// lab var obs_district "Number of sales observations for this crop in the district"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_district.dta", replace
//
// use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_sales.dta", clear	//Measure by Region
// gen observation = 1
// bys crop_code: egen obs_region = count(observation)
// collapse (median) price_kg [aw=weight], by (region crop_code obs_region)
// rename price_kg price_kg_median_region
// lab var price_kg_median_region "Median price per kg for this crop in the region"
// lab var obs_region "Number of sales observations for this crop in the region"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_region.dta", replace
//
//
// use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_sales.dta", clear	//Now by country
// gen observation = 1
// bys crop_code: egen obs_country = count(observation)
// collapse (median) price_kg [aw=weight], by (crop_code obs_country)
// rename price_kg price_kg_median_country
// lab var price_kg_median_country "Median price per kg for this crop in the country"
// lab var obs_country "Number of sales observations for this crop in the country"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_country.dta", replace
//
// *Pull prices into harvest estimates
// use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_tempcrop_harvest.dta", clear
// append using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_permcrop_harvest.dta"
// merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta"
// drop if _merge==2
// drop _merge
// merge m:1 y2_hhid crop_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_sales.dta"   
// drop _merge
// merge m:1 region district ta ea crop_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_ea.dta"
// drop _merge
// merge m:1 region district ta crop_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_ta.dta"
// drop _merge
// merge m:1 region district crop_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_district.dta"
// drop _merge
// merge m:1 region crop_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_region.dta"
// drop _merge
// merge m:1 crop_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_country.dta"
// drop _merge
// gen price_kg_hh = price_kg
// lab var price_kg_hh "Price per kg, with missing values imputed using local median values"
// replace price_kg = price_kg_median_ea if price_kg==. & obs_ea >= 10 & crop_code!=25 & crop_code!=1800 
// replace price_kg = price_kg_median_ta if price_kg==. & obs_ta >= 10 & crop_code!=25 & crop_code!=1800 
// replace price_kg = price_kg_median_district if price_kg==. & obs_district >= 10 & crop_code!=25 & crop_code!=1800
// replace price_kg = price_kg_median_region if price_kg==. & obs_region >= 10 & crop_code!=25 & crop_code!=1800
// replace price_kg = price_kg_median_country if price_kg==. & crop_code!=25 & crop_code!=1800
// lab var price_kg "Price per kg, with missing values imputed using local median values"
//
// //VAP: Following MMH 6.21.19 (Malawi W1): This instrument doesn't ask about value harvest, just value sold, EFW 05.02.2019 (Uganda W1): Since we don't have value harvest for this instrument computing value harvest as price_kg * kgs_harvest for everything. This is what was done in Ethiopia baseline
// gen value_harvest_imputed = kgs_harvest * price_kg_hh if price_kg_hh!=. 
// replace value_harvest_imputed = kgs_harvest * price_kg if value_harvest_imputed==.
// replace value_harvest_imputed = 0 if value_harvest_imputed==.
// lab var value_harvest_imputed "Imputed value of crop production"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_values_tempfile.dta", replace 
//
// preserve 		
// recode  value_harvest_imputed value_sold kgs_harvest quantity_sold (.=0)
// collapse (sum) value_harvest_imputed value_sold kgs_harvest quantity_sold , by (y2_hhid crop_code)
// ren value_harvest_imputed value_crop_production
// lab var value_crop_production "Gross value of crop production, summed over rainy and dry season"
// rename value_sold value_crop_sales
// lab var value_crop_sales "Value of crops sold so far, summed over rainy and dry season"
// lab var kgs_harvest "Kgs harvested of this crop, summed over rainy and dry  season"
// ren quantity_sold kgs_sold
// lab var kgs_sold "Kgs sold of this crop, summed over rainy and dry season"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_crop_values_production.dta", replace
// restore
// *The file above will be used is the estimation intermediate variables : Gross value of crop production, Total value of crop sold, Total quantity harvested.  
//
// collapse (sum) value_harvest_imputed value_sold, by (y2_hhid)
// replace value_harvest_imputed = value_sold if value_sold>value_harvest_imputed & value_sold!=. & value_harvest_imputed!=. /* In a few cases, the kgs sold exceeds the kgs harvested */
// rename value_harvest_imputed value_crop_production
// lab var value_crop_production "Gross value of crop production for this household"
// *This is estimated using household value estimated for temporary crop production plus observed sales prices for permanent/tree crops.
// *Prices are imputed using local median values when there are no sales.
// rename value_sold value_crop_sales
// lab var value_crop_sales "Value of crops sold so far"
// gen proportion_cropvalue_sold = value_crop_sales / value_crop_production
// lab var proportion_cropvalue_sold "Proportion of crop value produced that has been sold"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_crop_production.dta", replace
//
// *Plot value of crop production
// use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_values_tempfile.dta", clear
// collapse (sum) value_harvest_imputed, by (y2_hhid plot_id)
// rename value_harvest_imputed plot_value_harvest
// lab var plot_value_harvest "Value of crop harvest on this plot"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_cropvalue.dta", replace
//
// *Crop residues (captured only in Tanzania) 		// VAP 08/20/2019: Malawi W2 doesn't ask about crop residues
//
// *Crop values for inputs in agricultural product processing (self-employment)
// use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_tempcrop_harvest.dta", clear
// append using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_permcrop_harvest.dta"
// merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta", nogen keep(1 3)
// merge m:1 y2_hhid crop_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_sales.dta", nogen
// merge m:1 region district ta ea crop_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_ea.dta", nogen
// merge m:1 region district ta crop_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_ta.dta", nogen
// merge m:1 region district crop_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_district.dta", nogen
// merge m:1 region crop_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_region.dta", nogen
// merge m:1 crop_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_prices_country.dta", nogen
// replace price_kg = price_kg_median_ea if price_kg==. & obs_ea >= 10 & crop_code!= 1800/* Don't impute prices for "other" crops. VAP: Check code 1800 for other */ 
// replace price_kg = price_kg_median_ta if price_kg==. & obs_ta >= 10 & crop_code!=1800
// replace price_kg = price_kg_median_district if price_kg==. & obs_district >= 10 & crop_code!=1800
// replace price_kg = price_kg_median_region if price_kg==. & obs_region >= 10 & crop_code!=1800
// replace price_kg = price_kg_median_country if price_kg==. & crop_code!=1800 
// lab var price_kg "Price per kg, with missing values imputed using local median values"
//
// gen value_harvest_imputed = kgs_harvest * price_kg if price_kg!=.  //MW W2 doesn't ask about value harvest, just value sold. 
// replace value_harvest_imputed = kgs_harvest * price_kg if value_harvest_imputed==.
// replace value_harvest_imputed = 0 if value_harvest_imputed==.
// keep y2_hhid crop_code price_kg 
// duplicates drop
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_crop_prices.dta", replace 
//

************************
*GROSS CROP REVENUE 
************************
* Three things we are trying to accomplish with GROSS CROP REVENUE
* 1. Total value of all crop sales by hhid (summed up over all crops)
* 2. Total value of post harvest losses by hhid (summed up over all crops)
* 3. Amount sold (kgs) of unique crops by hhid
**# Bookmark #2
use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_q_13.dta", clear
// append using "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_m_13.dta", gen(dry)
	ren ag_q0b crop_code_long
	recode crop_code_long (100=49)(2=50)(3=51)(4=52)(5=53)(6=54)(7=55)(8=56)(9=57)(10=58)(11=59)(12=60)(13=61)(14=62)(15=63)(16=64)(17=65)(18=1800)(19=1900)(20=2000)(21=48)
	tempfile tree_perm
	save `tree_perm'

use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_i_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_o_13.dta"
rename ag_i0b crop_code_long
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

ren ag_i02c condition 
replace condition= ag_o02c if condition==.
replace condition=3 if condition==. 
merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta", nogen keepusing(region district ta rural ea weight) keep(1 3)
***We merge Crop Sold Conversion Factor at the crop-unit-regional level***
merge m:1 region crop_code_long unit condition using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_cf.dta", gen(cf_merge) keep (1 3) //6,643 matched,  24,916 unmatched because raw data donot report any unit or value for the remaining observations; there's not much we can do to make more matches here 

***We merge Crop Sold Conversion Factor at the crop-unit-national level***
 
*We create Quantity Sold (kg using standard  conversion factor table for each crop- unit and region). 
replace conversion=conversion if region!=. //  We merge the national standard conversion factor for those hhid with missing regional info. 
gen kgs_sold = qty*conversion 
collapse (sum) value kgs_sold (first) crop_code_long, by (y2_hhid crop_code)
drop if crop_code ==.
lab var value "Value of sales of this crop"
save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_cropsales_value.dta", replace

//SS Question: Do we want 0s in the final data? For example, if a hh didn't sell any maize, do we still want to keep that data for 

use "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_all_plots.dta", clear

collapse (sum) value_harvest (first) crop_code_long, by (y2_hhid crop_code) // Update: SW We start using the standarized version of value harvested and kg harvested
merge 1:1 y2_hhid crop_code using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_cropsales_value.dta"
replace value_harvest = value if value>value_harvest & value_!=. /* In a few cases, sales value reported exceeds the estimated value of crop harvest */
ren value value_crop_sales 
recode  value_harvest value_crop_sales  (.=0)
collapse (sum) value_harvest value_crop_sales (first) crop_code_long, by (y2_hhid crop_code)
drop if crop_code ==.
ren value_harvest value_crop_production
lab var value_crop_production "Gross value of crop production, summed over main and short season"
lab var value_crop_sales "Value of crops sold so far, summed over main and short season"
save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_hh_crop_values_production.dta", replace

collapse (sum) value_crop_production value_crop_sales, by (y2_hhid)
lab var value_crop_production "Gross value of crop production for this household"
lab var value_crop_sales "Value of crops sold so far"
gen proportion_cropvalue_sold = value_crop_sales / value_crop_production
lab var proportion_cropvalue_sold "Proportion of crop value produced that has been sold"
save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_hh_crop_production.dta", replace

*Crops lost post-harvest
use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_i_13.dta", clear
ren ag_i0b crop_code_long

append using "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_o_13.dta"
replace crop_code_long = ag_o0b if crop_code_long==.
drop if crop_code==. //302 observations deleted 
rename ag_i36d percent_lost
replace percent_lost = ag_o36d if percent_lost==. & ag_o36d!=.
replace percent_lost = 100 if percent_lost > 100 & percent_lost!=. 

merge m:1 y2_hhid crop_code_long using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_hh_crop_values_production.dta", nogen keep(1 3)
gen value_lost = value_crop_production * (percent_lost/100)
recode value_lost (.=0)
collapse (sum) value_lost, by (y2_hhid)
rename value_lost crop_value_lost
lab var crop_value_lost "Value of crop production that had been lost by the time of survey"
save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_crop_losses.dta", replace


************************
*CROP EXPENSES
************************
**# Bookmark #1


	*********************************
	* 			LABOR				*
	*********************************
	
* Crop Payments rainy
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear 
	ren ag_d00 plot_id
preserve
	ren ag_d47g crop_code
	ren ag_d47h qty
	ren ag_d47i unit
	ren ag_d47j condition
	keep y2_hhid plot_id crop_code qty unit condition
	gen season=0
tempfile rainynonharvest_crop_payments
save `rainynonharvest_crop_payments'
restore 

	ren ag_d48g crop_code
	ren ag_d48h qty
	ren ag_d48i unit
	ren ag_d48j condition
	keep y2_hhid plot_id crop_code qty unit condition
	gen season=0
tempfile rainyharvest_crop_payments
save `rainyharvest_crop_payments'

use `rainynonharvest_crop_payments'
append using `rainyharvest_crop_payments'

tempfile rainy_crop_payments
save `rainy_crop_payments'
	
	*Crop payments dry
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_k_13.dta", clear 
	ren ag_k00 plot_id
	ren ag_k46g crop_code
	ren ag_k46h qty
	ren ag_k46i unit
	ren ag_k46j condition
	keep y2_hhid plot_id crop_code qty unit condition
	
	gen season=1
tempfile dry_crop_payments
save `dry_crop_payments'

	use `rainy_crop_payments'
	append using `dry_crop_payments'
	lab var season "season: 0=rainy, 1=dry, 2=tree crop"
	label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
	label values season season
	
	merge m:1 y2_hhid crop_code using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_hh_crop_prices_for_wages.dta", nogen keep (1 3) //316 matched; hh_price_mean in using data set seems high
	recode qty hh_price_mean (.=0)
	gen val = qty*hh_price_mean
	keep y2_hhid val plot_id
	gen exp = "exp"
	merge m:1 plot_id y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_decision_makers.dta", nogen keep (1 3) keepusing(dm_gender)
	tempfile inkind_payments
	save `inkind_payments'
	
	*Hired rainy
	
	local qnums "47 48" //qnums refer to question numbers on instrument
foreach q in `qnums' {
    use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear
	ren ag_d00 plot_id
	merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta", nogen
	ren ag_d`q'a dayshiredmale
	ren ag_d`q'c dayshiredfemale
	ren ag_d`q'e dayshiredchild
	ren ag_d`q'b wagehiredmale
	ren ag_d`q'd wagehiredfemale
	ren ag_d`q'f wagehiredchild
	keep y2_hhid plot_id region stratum district ta ea rural plot_id *hired*
	gen season=0
    local suffix ""
    if `q' == 47 {
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

use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_k_13.dta", clear 
rename ag_k00 plot_id
merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta", nogen 
rename ag_k46a dayshiredmale
rename ag_k46b wagehiredmale
rename ag_k46c dayshiredfemale
rename ag_k46d wagehiredfemale
rename ag_k46e dayshiredchild
rename ag_k46f wagehiredchild
keep y2_hhid plot_id region stratum district ta ea rural plot_id *hired*
gen season=1
tempfile dry_hired_all
save `dry_hired_all'

use `rainy_hired_nonharvest'
append using `rainy_hired_harvest'
append using `dry_hired_all'

lab var season "season: 0=rainy, 1=dry, 2=tree crop"
label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
label values season season

duplicates report y2_hhid region stratum district ta ea plot_id season
duplicates tag y2_hhid region stratum district ta ea plot_id season, gen(dups)


duplicates drop y2_hhid region stratum district ta ea plot_id season, force // we need to  drop duplicates so reshape can run
reshape long dayshired wagehired, i(y2_hhid region stratum district ta ea plot_id season) j(gender) string
reshape long days wage, i(y2_hhid region stratum district ta ea plot_id season gender) j(labor_type) string
recode days wage (.=0)
drop if wage==0 & days==0 /*& inkind==0*/
gen val = days*wage // instrument did not report number of laborers per day
	
tempfile all_hired
save `all_hired'
	
******************************  FAMILY LABOR   *********************************

//Family labor
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear
merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_hhids.dta", nogen keep(1 3)
ren ag_d00 plot_id
rename ag_d42a pid1
rename ag_d42b weeks_worked1
rename ag_d42c days_week1
rename ag_d42d hours_day1
rename ag_d42e pid2
rename ag_d42f weeks_worked2
rename ag_d42g days_week2
rename ag_d42h hours_day2
rename ag_d42i pid3
rename ag_d42j weeks_worked3
rename ag_d42k days_week3
rename ag_d42l hours_day3
rename ag_d42m pid4
rename ag_d42n weeks_worked4
rename ag_d42o days_week4
rename ag_d42p hours_day4

preserve
keep pid* weeks_worked* days_week*  hours_day* occ y2_hhid ea stratum rural region district ta plot_id 
gen season=0
duplicates drop occ y2_hhid ea stratum rural region district ta plot_id season, force
reshape long pid weeks_worked days_week hours_day, i(occ y2_hhid ea stratum rural region district ta plot_id season) j(colid) string
tempfile prep_planting_family
save `prep_planting_family'
restore

rename ag_d43a pid5
rename ag_d43b weeks_worked5
rename ag_d43c days_week5
rename ag_d43d hours_day5
rename ag_d43e pid6
rename ag_d43f weeks_worked6
rename ag_d43g days_week6
rename ag_d43h hours_day6
rename ag_d43i pid7
rename ag_d43j weeks_worked7
rename ag_d43k days_week7
rename ag_d43l hours_day7
rename ag_d43m pid8
rename ag_d43n weeks_worked8
rename ag_d43o days_week8
rename ag_d43p hours_day8

preserve
keep occ y2_hhid ea stratum rural region district ta plot_id pid* weeks_worked* days_week*  hours_day*
gen season=0
duplicates drop occ y2_hhid ea stratum region district ta plot_id season, force
reshape long pid weeks_worked days_week hours_day, i(occ y2_hhid ea stratum rural region district ta plot_id season) j(colid) string
tempfile mid_family
save `mid_family'
restore

rename ag_d44a pid9
rename ag_d44b weeks_worked9
rename ag_d44c days_week9
rename ag_d44d hours_day9
rename ag_d44e pid10
rename ag_d44f weeks_worked10
rename ag_d44g days_week10
rename ag_d44h hours_day10
rename ag_d44i pid11
rename ag_d44j weeks_worked11
rename ag_d44k days_week11
rename ag_d44l hours_day11
rename ag_d44m pid12
rename ag_d44n weeks_worked12
rename ag_d44o days_week12
rename ag_d44p hours_day12

preserve
keep occ y2_hhid ea stratum rural region district ta plot_id pid* weeks_worked* days_week* hours_day*
gen season=0
duplicates drop occ y2_hhid ea stratum rural region district ta plot_id season, force
reshape long pid weeks_worked days_week hours_day, i(occ y2_hhid ea stratum rural region district ta plot_id season) j(colid) string
tempfile harvest_family
save `harvest_family'
restore

	drop pid* weeks_worked* days_week* hours_day*
	ren ag_d52a daysnonhiredmale
	ren ag_d52b daysnonhiredfemale
	ren ag_d52c daysnonhiredchild
preserve
	keep occ y2_hhid ea stratum rural region district ta plot_id daysnonhired* 
	gen season=0
	duplicates drop occ y2_hhid ea stratum rural region district ta plot_id season, force
	reshape long daysnonhired, i(occ y2_hhid ea stratum rural region district ta plot_id season) j(gender) string
	reshape long days, i(occ y2_hhid ea stratum rural region district ta plot_id gender) j(labor_type) string
	tempfile nonharvest_exchange
	save `nonharvest_exchange'
restore
	drop days*
	ren ag_d54a daysnonhiredmale
	ren ag_d54b daysnonhiredfemale
	ren ag_d54c daysnonhiredchild
	gen season=0
	duplicates drop occ y2_hhid ea stratum rural region district ta plot_id season, force
	reshape long daysnonhired, i(occ y2_hhid ea stratum rural region district ta plot_id season) j(gender) string
	reshape long days, i(occ y2_hhid ea stratum rural region district ta plot_id gender) j(labor_type) string
	append using `nonharvest_exchange'
	lab var season "season: 0=rainy, 1=dry, 2=tree crop"
	label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
	label values season season
tempfile all_exchange_rainy
save `all_exchange_rainy'


use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_k_13.dta", clear
merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_hhids.dta", nogen keep(1 3)
rename ag_k00 plot_id
rename ag_k43a pid13
rename ag_k43b weeks_worked13
rename ag_k43c days_week13
rename ag_k43d hours_day13
rename ag_k43e pid14
rename ag_k43f weeks_worked14
rename ag_k43g days_week14
rename ag_k43h hours_day14
rename ag_k43i pid15
rename ag_k43j weeks_worked15
rename ag_k43k days_week15
rename ag_k43l hours_day15
rename ag_k43m pid16
rename ag_k43n weeks_worked16
rename ag_k43o days_week16
rename ag_k43p hours_day16


preserve
gen season=1
duplicates drop occ y2_hhid ea stratum rural region district ta plot_id season, force
reshape long pid weeks_worked days_week hours_day, i(occ y2_hhid ea stratum rural region district ta plot_id season) j(colid) string
tempfile prep_planting_family
save `prep_planting_family'
restore

rename ag_k44a pid17
rename ag_k44b weeks_worked17
rename ag_k44c days_week17
rename ag_k44d hours_day17
rename ag_k44e pid18
rename ag_k44f weeks_worked18
rename ag_k44g days_week18
rename ag_k44h hours_day18
rename ag_k44i pid19
rename ag_k44j weeks_worked19
rename ag_k44k days_week19
rename ag_k44l hours_day19
rename ag_k44m pid20
rename ag_k44n weeks_worked20
rename ag_k44o days_week20
rename ag_k44p hours_day20
preserve
keep occ y2_hhid ea stratum region rural district ta plot_id pid* weeks_worked* days_week* hours_day*
gen season=1
duplicates drop occ y2_hhid ea stratum rural region district ta plot_id season, force
reshape long pid weeks_worked days_week hours_day, i(occ y2_hhid ea stratum rural region district ta plot_id season) j(colid) string
tempfile mid_family
save `mid_family'
restore

rename ag_k45a pid21
rename ag_k45b weeks_worked21
rename ag_k45c days_week21
rename ag_k45d hours_day21
rename ag_k45e pid22
rename ag_k45f weeks_worked22
rename ag_k45g days_week22
rename ag_k45h hours_day22
rename ag_k45i pid23
rename ag_k45j weeks_worked23
rename ag_k45k days_week23
rename ag_k45l hours_day23
rename ag_k45m pid24  
rename ag_k45n weeks_worked24
rename ag_k45o days_week24
rename ag_k45p hours_day24

preserve
keep occ y2_hhid ea stratum rural region district ta plot_id pid* weeks_worked* days_week* hours_day*
gen season=1
duplicates drop occ y2_hhid ea stratum rural region district ta plot_id season, force
reshape long pid weeks_worked days_week hours_day, i(occ y2_hhid ea stratum rural region district ta plot_id season) j(colid) string
tempfile harvest_family
save `harvest_family'
restore

//exchange labor, note no planting data
	drop pid* weeks_worked* days_week* hours_day*
	ren ag_k47a daysnonhiredmale
	ren ag_k47b daysnonhiredfemale
	ren ag_k47c daysnonhiredchild
	keep occ y2_hhid ea stratum rural region district ta plot_id daysnonhired* 
	gen season=1
	reshape long daysnonhired, i(occ y2_hhid ea stratum rural region district ta plot_id season) j(gender) string
	reshape long days, i(occ y2_hhid ea stratum rural region district ta plot_id gender) j(labor_type) string
tempfile all_exchange_dry
save `all_exchange_dry'

use "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_b_13.dta", clear
ren  hh_b01 pid
isid y2_hhid pid	
gen male = hh_b03 ==1
//gen malehead = hh_b03 if hh_b04 == 1
gen age = hh_b05a
lab var age "Individual age"
keep y2_hhid pid age male //malehead
tempfile members
save `members', replace

use `prep_planting_family',clear
append using `mid_family'
append using `harvest_family'

gen days=weeks_worked*days_week
gen hours=weeks_worked*days_week*hours_day
drop if days==.
drop if hours==. 

preserve
collapse (sum) days_rescale=days, by(ea stratum region district ta rural y2_hhid plot_id pid season)
merge m:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_season_length.dta", nogen keep(1 3)
replace days_rescale = days_grown if days_rescale > days_grown
tempfile rescaled_days
save `rescaled_days'
restore

//Rescaling to season
bys y2_hhid plot_id pid : egen tot_days = sum(days)
gen days_prop = days/tot_days 
merge m:1 y2_hhid ea stratum region district rural ta plot_id pid season using `rescaled_days'
replace days = days_rescale * days_prop if tot_days > days_grown
merge m:1 y2_hhid pid using `members', nogen keep (1 3)
gen gender="child" if age<15 //MGM: age <16 on reference code, age <15 on MWI W1 survey instrument
replace gender="male" if strmatch(gender,"") & male==1
replace gender="female" if strmatch(gender,"") & male==0
gen labor_type="family"
keep y2_hhid ea stratum region rural district ta plot_id season gender days labor_type
lab var season "season: 0=rainy, 1=dry, 2=tree crop"
label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
label values season season
append using `all_exchange_rainy'
append using `all_exchange_dry'


gen val = .
append using `all_hired'
keep occ y2_hhid ea stratum rural region district ta plot_id season days val labor_type gender
drop if val==.&days==.
merge m:1 plot_id y2_hhid using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_plot_decision_makers", nogen keep(1 3) keepusing(dm_gender)

collapse (sum) val days, by(y2_hhid plot_id season labor_type gender dm_gender) 
	la var gender "Gender of worker"
	la var dm_gender "Plot manager gender"
	la var labor_type "Hired, exchange, or family labor"
	la var days "Number of person-days per plot"
save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_plot_labor_long.dta",replace
preserve
	collapse (sum) labor_=days, by (y2_hhid plot_id labor_type season)
	reshape wide labor_, i(y2_hhid plot_id) j(labor_type) string
		la var labor_family "Number of family person-days spent on plot, all seasons"
		la var labor_nonhired "Number of exchange (free) person-days spent on plot, all seasons"
		la var labor_hired "Number of hired labor person-days spent on plot, all seasons"
	save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_plot_labor_days.dta",replace
	
//AgQuery
restore
preserve
	gen exp="exp" if strmatch(labor_type,"hired")
	replace exp="imp" if strmatch(exp,"")
	append using `inkind_payments'
	collapse (sum) val, by(y2_hhid plot_id exp dm_gender season)
	gen input="labor"
	save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_plot_labor.dta", replace //this gets used below.
restore	

//And now we go back to wide
collapse (sum) val, by(y2_hhid plot_id season labor_type dm_gender)
ren val val_ 
reshape wide val_, i(y2_hhid plot_id season dm_gender) j(labor_type) string
ren val* val*_
gen season_fix="rainy" if season==0
replace season_fix="dry" if season==1
drop season
ren season_fix season
reshape wide val*, i(y2_hhid plot_id dm_gender) j(season) string
gen dm_gender2 = "male" if dm_gender==1
replace dm_gender2 = "female" if dm_gender==2
replace dm_gender2 = "unknown" if dm_gender==. 
drop dm_gender
ren val* val*_
drop if dm_gender2 == "" // 1,916 observations dropped
reshape wide val*, i(y2_hhid plot_id) j(dm_gender2) string
collapse (sum) val*, by(y2_hhid)
save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_hh_cost_labor.dta", replace


	*********************************
	* 		LAND/PLOT RENTS			*
	********************************* 

use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear
gen season = 0 //"rainy"
	
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_k_13.dta"
	
replace season=1 if season==.
	
gen cultivate = 0
replace cultivate = 1 if ag_d14 == 1
replace cultivate = 1 if ag_k15 == 1
	
ren ag_d00 plot_id
	
replace plot_id=ag_k00 if plot_id==""
	
gen payment_period=ag_d12
replace payment_period=ag_k13 if payment_period==.
	
* Owed
ren ag_d10a crop_code_owed
replace crop_code_owed=ag_k11a if crop_code_owed==.
ren ag_d10b qty_owed
replace qty_owed=ag_k11b if qty_owed==.
ren ag_d10c unit_owed
replace unit_owed=ag_k11c if unit_owed==.
ren ag_d10d condition_owed
replace condition_owed=ag_k11d if condition_owed==.
	
drop if crop_code_owed==. //9,831 observations dropped 
drop if unit_owed==. & crop_code_owed!=.  //28 observations dropped
	
keep y2_hhid plot_id cultivate season crop_code* qty* unit* condition* payment_period
reshape long crop_code qty unit condition, i (y2_hhid season plot_id payment_period cultivate) j(payment_status) string

ren crop_code crop_code_long
drop if crop_code_long==. // 0 dropped
drop if qty==. //0 dropped

merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhsize.dta", keepusing (region district ta ea) keep(1 3) nogen
merge m:1 region crop_code_long unit condition using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_cf.dta", keep (1 3) 
merge m:1 y2_hhid crop_code_long using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_hh_crop_prices_for_wages.dta", nogen keep (1 3)
	
gen val=qty*hh_price_mean
drop qty unit crop_code_long condition hh_price_mean payment_status
keep if val!=. //9 obs deleted
tempfile plotrentbycrops
save `plotrentbycrops'
	
	
* Rainy Cash + In-Kind

use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear

gen cultivate = 0
replace cultivate = 1 if ag_d14 == 1
ren ag_d00 plot_id
ren ag_d11a cash_rents_paid
ren ag_d11b inkind_rents_paid
ren ag_d11c cash_rents_owed
ren ag_d11d inkind_rents_owed
ren ag_d12 payment_period
egen val = rowtotal(cash_rents_paid inkind_rents_paid cash_rents_owed inkind_rents_owed)
gen season = 0 //"Rainy"
keep y2_hhid plot_id val season cult payment_period
tempfile rainy_land_rents
save `rainy_land_rents', replace
	
* Dry Cash + In-Kind

use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_k_13.dta", clear	
gen cultivate = 0
replace cultivate = 1 if ag_k15 == 1
ren ag_k00 plot_id
ren ag_k12a cash_rents_paid
ren ag_k12b inkind_rents_paid
ren ag_k13 payment_period
ren ag_k12c cash_rents_owed
ren ag_k12d inkind_rents_owed
egen val = rowtotal(cash_rents_paid inkind_rents_paid cash_rents_owed inkind_rents_owed)	
keep y2_hhid plot_id val cult payment_period
gen season = 1 //"Dry"

* Combine dry + rainy + payments-by-crop
append using `rainy_land_rents'
append using `plotrentbycrops'
lab var season "season: 0=rainy, 1=dry, 2=tree crop"
label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"	
label values season season
gen input="plotrent"
gen exp="exp"

duplicates report y2_hhid plot_id season
duplicates tag y2_hhid plot_id season, gen(dups)
duplicates drop y2_hhid plot_id season, force // 5 duplicate entries
drop dups

//This identifies and deletes duplicate observations across season modules where an annual payment is recorded twice
gen check=1 if payment_period==2 & val>0 & val!=.
duplicates report y2_hhid plot_id payment_period check
duplicates tag y2_hhid plot_id payment_period check, gen(dups)
drop if dups>0 & check==1 & season==1 
drop dups check

gen qty=0
recode val (.=0)
collapse (sum) val, by (y2_hhid plot_id season exp input qty cultivate)

merge m:1  plot_id y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_areas.dta",  keep(1 3) 
count if _m==1 & plot_id!="" & val!=. & val>0 
	drop if _m != 3 //2,597  obs deleted
	drop _m
	

* Calculate quantity of plot rents etc. 
replace qty = field_size if val > 0 & val! = . //636 changes
keep if cultivate==1 //1,312 observations deleted - no need for uncultivated plots 
keep y2_hhid plot_id season input exp val qty
tempfile plotrents
save `plotrents'	
	
	

************************    FERTILIZER   ****************************** 
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_f_13.dta", clear

gen season = 0

append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_l_13.dta"

replace season = 1 if season == .

label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"

label values season season

ren ag_f0b codefertherb // TK 31/7/23  101 - Organic Fertilizer,  102 to 105 = Inorganic Fertilizer, 106 to 109 = Herbicide/ Pesticides   data missing in input code so used  input id instead.  
replace codefertherb = ag_l0b if codefertherb==. 

ren ag_f0d itemcode  // Type of inorganic fertilizer or Herbicide (1 = 23:21:0+4S/CHITOWE, 2 =  DAP, 3 = CAN 4 = UREA, 5 = D COMPOUND 5, 6 = Other Fertilizer, 7 = INSECTICIDE, 8 = HERBICIDE, 9 = FUMIGANT
// 10 = Other Pesticide or Herbicide. 17 - unknown)
replace ag_f00b = ag_l00b if ag_f00b==""
replace itemcode = ag_l0d if itemcode==.
replace itemcode=3 if ag_f0c=="CAN"
replace itemcode=1 if ag_f0c=="CHITOWE"
replace itemcode=4 if ag_f0c=="UREA"
replace itemcode=0 if codefertherb==101 

replace codefertherb = 0 if item == 0 // organic fertilizers
		replace code = 1 if inlist(item, 1,2,3,4,5,6) // inorganic fertilizers
		replace code = 2 if inlist(item, 7,9,10) // pesticide 
		replace code = 3 if inlist(item, 8) // herbicide
		
lab var codefertherb "Code: 0 = organic fert, 1 = inorganic fert, 2 = pesticide, 3 = herbicide"
lab define codefertherb 0 "organic fert" 1 "inorganic fert" 2 "pesticide" 3 "herbicide"
lab values codefertherb codefertherb	

*First Source Input and Transportation Costs (Explicit)*
ren ag_f16a qtyinputexp1
replace qtyinputexp1 = ag_l16a if qtyinputexp1 ==.
ren ag_f16b unitinputexp1
replace unitinputexp1 = ag_l16b if unitinputexp1 ==. //adding dry season
ren ag_f18 valtransfertexp1 //all transportation is explicit
replace valtransfertexp1 = ag_l18 if valtransfertexp1 == .
ren ag_f19 valinputexp1
replace valinputexp1 = ag_l19 if valinputexp1 == .

*Second Source Input and Transportation Costs (Explicit)*
ren ag_f26a qtyinputexp2
replace qtyinputexp2 = ag_l26a if qtyinputexp2 ==.
ren ag_f26b unitinputexp2
replace unitinputexp2 = ag_l26b if unitinputexp2 ==. //adding dry season
ren ag_f28 valtransfertexp2 //all transportation is explicit
replace valtransfertexp2 = ag_l28 if valtransfertexp2 == .
ren  ag_f29 valinputexp2
replace valinputexp2 = ag_l29 if valinputexp2 == .

*Third Source Input Costs (Explicit)* // Transportation Costs and Value of input not asked about for third source on W2 instrument, hence the need to impute these costs later provided we have itemcode code and qtym
ren ag_f36a qtyinputexp3  // Third Source
replace qtyinputexp3 = ag_l36a if qtyinputexp3 == .
ren ag_f36b unitinputexp3
replace unitinputexp3 = ag_l36b if unitinputexp3 == . //adding dry season

*Free and Left-Over Input Costs (Implicit)*
gen itemcodeinputimp1 = itemcode
ren ag_f38a qtyinputimp1  // Free input
replace qtyinputimp1 = ag_l38a if qtyinputimp1 == .
ren ag_f38b unitinputimp1
replace unitinputimp1 = ag_l38b if unitinputimp1 == . //adding dry season
ren ag_f42a qtyinputimp2 //Quantity input left
replace qtyinputimp2 = ag_l42a if qtyinputimp2 == .
ren ag_f42b unitinputimp2
replace unitinputimp2 = ag_l42b if unitinputimp2== . //adding dry season

*Free Input Source Transportation Costs (Explicit)*
ren ag_f40 valtransfertexp3 //all transportation is explicit
replace valtransfertexp3 = ag_l40 if valtransfertexp3 == .


keep qty* unit* val* y2_hhid itemcode codefertherb season
gen dummya = _n
unab vars : *1
local stubs : subinstr local vars "1" "", all
reshape long `stubs', i (y2_hhid dummya itemcode codefertherb) j(entry_no)
drop entry_no
replace dummya=_n
unab vars2 : *exp
local stubs2 : subinstr local vars2 "exp" "", all
reshape long `stubs2', i(y2_hhid dummya itemcode codefertherb) j(exp) string
replace dummya=_n
reshape long qty unit val, i(y2_hhid exp dummya itemcode codefertherb) j(input) string
tab val if exp=="imp" & input=="transfert"
drop if strmatch(exp,"imp") & strmatch(input, "transfert") //No implicit transportation costs


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

* Updating the unit for unit to "1" (to match SEEDS code) for the relevant units after conversion
replace unit = 1 if inlist(unit, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)


label define inputunitrecode 1 "Kilogram", modify
label values unit inputunitrecode
drop if (qty==. | qty==0) & strmatch(input, "input") //224,658  obs deleted 
drop if unit==. & strmatch(input, "input") 
drop if itemcode==.
gen byte qty_missing = missing(qty) //only relevant to transfert
gen byte val_missing = missing(val)
collapse (sum) val qty, by(y2_hhid unit itemcode codefertherb exp input qty_missing val_missing season)
replace qty =. if qty_missing
replace val =. if val_missing
drop qty_missing val_missing

//ENTER CODE HERE THAT CHANGES INPUT TO INORGFERT, ORGFERT, HERB, PEST BASED ON ITEM CODE
replace input="orgfert" if codefertherb==0 & input!="transfert"
replace input="inorg" if codefertherb==1 & input!="transfert"
replace input="pest" if codefertherb==2 & input!="transfert"
replace input="herb" if codefertherb==3 & input!="transfert"
drop if strmatch(input, "input")
replace qty=. if input=="transfert" //1 changes
keep if qty>0 //0 obs deleted
replace unit=1 if unit==. //Weight, meaningless for transportation 
tempfile phys_inputs
save `phys_inputs'


	*********************************
	* 			 SEED			    *
	*********************************	

use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_h_13.dta", clear

gen season = 0

append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_n_13.dta"

replace season = 1 if season == .
lab var season "season: 0=rainy, 1=dry, 2=tree crop"
label define season 0 "rainy" 1 "dry" 2 "tree or permanent crop"
label values season season

ren ag_h0c seedcode
replace seedcode=ag_n0c if seedcode == .
drop if seedcode==. //9,425 observations deleted MGM 8.23.23 @ALT is that okay that I am dropping these? There are no data for these observations
* EXPLICIT Costs: Seeds bought & Transpo costs:
	* First source
	ren ag_h16a qtyseedsexp1 // qty seeds purchased w/o coupons
	replace qtyseedsexp1 = ag_n16a if qtyseedsexp1 ==.
	ren ag_h16b unitseedsexp1
	replace unitseedsexp1 = ag_n16b if unitseedsexp1 ==. //adding dry season
	ren ag_h18 valseedtransexp1 // all transportation costs are explicit
	replace valseedtransexp1 = ag_n18 if valseedtransexp1 == .
	ren ag_h19 valseedsexp1 // value of seed purchased
	replace valseedsexp1 = ag_n19 if valseedsexp1 == .
	gen itemcodeseedsexp1 = seedcode if qtyseedsexp1!=. // hks 09.04.23: this line doesn't exist in MWI W1

	* Second source
	ren ag_h26a qtyseedsexp2 // qty purchased w/o coupons
	replace qtyseedsexp2 = ag_n26a if qtyseedsexp2 ==.
	ren ag_h26b unitseedsexp2
	replace unitseedsexp2 = ag_n26b if unitseedsexp2 ==.
	ren ag_h28 valseedtransexp2 //all transportation is explicit
	replace valseedtransexp2 = ag_n28 if valseedtransexp2 == .
	ren  ag_h29 valseedsexp2 // value of seed purchased
	replace valseedsexp2 = ag_n29 if valseedsexp2 == .
	gen itemcodeseedsexp2 = seedcode if qtyseedsexp2!=. // hks 09.04.23: this line doesn't exist in MWI W1

	* Third Source // Transportation Costs and Value of Seeds not asked about for third source on W4 instrument, hence the need to impute these costs later provided we have itemcode code and qtym
	ren ag_h36a qtyseedsexp3  // Third Source - qty purchased
	replace qtyseedsexp3 = ag_n36a if qtyseedsexp3 == .
	ren ag_h36b unitseedsexp3
	replace unitseedsexp3 = ag_n36b if unitseedsexp3 == . // adding Dry Season
	gen itemcodeseedsexp3 = seedcode if qtyseedsexp3!=. // hks 09.04.23: this line doesn't exist in MWI W1

* IMPLICIT COSTS: Free and Left Over Value:
ren ag_h42a qtyseedsimp1 // Left over seeds
replace qtyseedsimp1 = ag_n42a if qtyseedsimp1 == . 
ren ag_h42b unitseedsimp1
gen itemcodeseedsimp1 = seedcode if qtyseedsimp1!=. //Adding this to reduce the number of empties after the reshape. 
replace unitseedsimp1 = ag_n42b if unitseedsimp1== . // adding Dry Season

ren ag_h38a qtyseedsimp2  // Free seeds
replace qtyseedsimp2 = ag_n38a if qtyseedsimp2 == .
ren ag_h38b unitseedsimp2
replace unitseedsimp2 = ag_n38b if unitseedsimp2 == . // adding Dry Season
gen itemcodeseedsimp2 = seedcode if qtyseedsimp2!=.

* Free Source Transportation Costs (Explicit):
ren ag_h40 valseedtransexp3 //all transportation is explicit
replace valseedtransexp3 = ag_n40 if valseedtransexp3 == .


local suffix exp1 exp2 exp3 imp1 imp2
foreach s in `suffix' {
//CONVERT SPECIFIED UNITS TO KGS
replace qtyseeds`s'=qtyseeds`s'/1000 if unitseeds`s'==1
replace qtyseeds`s'=qtyseeds`s'*2 if unitseeds`s'==3
replace qtyseeds`s'=qtyseeds`s'*3 if unitseeds`s'==4
replace qtyseeds`s'=qtyseeds`s'*3.7 if unitseeds`s'==5
replace qtyseeds`s'=qtyseeds`s'*5 if unitseeds`s'==6
replace qtyseeds`s'=qtyseeds`s'*10 if unitseeds`s'==7
replace qtyseeds`s'=qtyseeds`s'*50 if unitseeds`s'==8
recode unitseeds`s' (1/8 = 1) //see below for redefining variable labels
label define unitrecode`s' 1 "Kilogram" 4 "Pail (small)" 5 "Pail (large)" 6 "No 10 Plate" 7 "No 12 Plate" 8 "Bunch" 9 "Piece" 11 "Basket (Dengu)" 120 "Packet" 210 "Stem" 260 "Cutting", modify
label values unitseeds`s' unitrecode`s'
}

keep item* qty* unit* val* y2_hhid /*ALT*/ season seed
gen dummya = _n
unab vars : *1
local stubs : subinstr local vars "1" "", all
reshape long `stubs', i (y2_hhid dummya) j(entry_no)
drop entry_no
replace dummya = _n
unab vars2 : *exp
local stubs2 : subinstr local vars2 "exp" "", all
drop if qtyseedsexp==. & valseedsexp==.
reshape long `stubs2', i(y2_hhid dummya) j(exp) string
replace dummya=_n
reshape long qty unit val itemcode, i(y2_hhid exp dummya) j(input) string
drop if strmatch(exp,"imp") & strmatch(input,"seedtrans") //No implicit transportation costs
//ALT: Crop recode not necessary for seed expenses.


label define unitrecode 1 "Kilogram" 4 "Pail (small)" 5 "Pail (large)" 6 "No 10 Plate" 7 "No 12 Plate" 8 "Bunch" 9 "Piece" 11 "Basket (Dengu)" 120 "Packet" 210 "Stem" 260 "Cutting", modify
label values unit unitrecode

drop if (qty==. | qty==0) & strmatch(input, "seeds") 
drop if unit==. & strmatch(input, "seeds")
gen byte qty_missing = missing(qty) //only relevant to seedtrans
gen byte val_missing = missing(val)
collapse (sum) val qty, by(y2_hhid unit seedcode exp input qty_missing val_missing season)
replace qty =. if qty_missing
replace val =. if val_missing
drop qty_missing val_missing

ren seedcode crop_code_long
drop if crop_code_long==. & strmatch(input, "seeds")
gen condition=1 
replace condition=3 if inlist(crop_code, 5, 6, 7, 28, 29, 30, 31, 32, 33, 37, 39, 40, 41, 42, 43, 44, 45, 47) 

merge m:1 y2_hhid using  "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhsize.dta", keepusing (region district ta ea) nogen keep(1 3) 

merge m:1 region crop_code_long unit condition using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_cf.dta", keep (1 3) 
// old :  2,394 New:  2,445

replace qty=. if input=="seedtrans" //0 changes, seedtrans must already have blanks for qty on all observations
keep if qty>0 //0 obs deleted

//This chunk ensures that conversion factors did not get used for planted-as-seed crops where the conversion factor weights only work for planted-as-harvested crops
replace conversion =. if inlist(crop_code, 5-8, 10, 28-29, 37, 39-45, 47) //

replace unit=1 if unit==. //Weight, meaningless for transportation 
replace conversion = 1 if unit==1 //conversion factor converts everything in kgs so if kg is the unit, cf is 1
replace conversion = 1 if unit==9 //if unit is piece, we use conversion factor of 1 but maintain unit name as "piece"/unitcode #9
replace qty=qty*conversion if conversion!=.
rename crop_code itemcode
drop _m
tempfile seeds
save `seeds'

*********************************************
*  	MECHANIZED TOOLS AND ANIMAL TRACTION	*
*********************************************
use "${Malawi_IHPS_W2_raw_data}/household/HH_MOD_M_13.dta", clear // reported at the household level
rename hh_m0b itemid
gen animal_traction = (itemid>=609 & itemid<=610) // Ox Plough, Ox Cart
gen ag_asset = (itemid>=601 & itemid<= 608 | itemid>=613 & itemid <=625) //Hand hoe, slasher, axe, sprayer, panga knife, sickle, treadle pump, watering can, ridger, cultivator, generator, motor pump, grain mill, other, chicken house, livestock and poultry kraal, storage house, granary, barn, pig sty
gen tractor = (itemid>=611 & itemid<=612) 
rename hh_m14 rental_cost 
gen rental_anml = rental_cost if animal_traction==1
gen rental_mech = rental_cost if ag_asset==1 | tractor==1
//gen rental_tractor = rental_cost if 
recode rental_anml rental_mech  (.=0)

collapse (sum) rental_anml rental_mech, by (y2_hhid)
lab var rental_anml "Costs for renting animal traction"
lab var rental_mech "Costs for renting other agricultural items" 
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_asset_rental_costs.dta", replace

ren rental_* val*

reshape long val, i(y2_hhid) j(var) string
ren var input
gen exp = "exp"
tempfile asset_rental
save `asset_rental'

*********************************************
*   TREE/ PERMANENT CROP TRANSPORTATION	    *
*********************************************

use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_q_13.dta", clear 
egen valtreetrans = rowtotal(ag_q18 ag_q27)
collapse (sum) val, by(y2_hhid)
reshape long val, i(y2_hhid) j(var) string
ren var input
gen exp = "exp" //Transportation is explicit
tempfile tree_transportation
save `tree_transportation' 

*********************************************
*       TEMPORARY CROP TRANSPORTATION       *
*********************************************

use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_i_13.dta", clear 

append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_o_13.dta"

egen valtempcroptrans = rowtotal(ag_i18 ag_i27 ag_o18  ag_o27)
collapse (sum) val, by(y2_hhid)
reshape long val, i(y2_hhid) j(var) string
ren var input
gen exp = "exp" //Transportation is explicit
tempfile tempcrop_transportation
save `tempcrop_transportation' 

*********************************************
*     	COMBINING AND GETTING PRICES	    *
*********************************************
*** Plot Level files: plot_rents
use `plotrents', clear
*append using `phys_inputs' 
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_cost_per_plot.dta", replace

merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_weights.dta",gen(weights) keep(1 3) keepusing(weight region district ea ta) 
merge m:1 y2_hhid plot_id  using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_plot_areas.dta", gen(plotareas) keep(1 3) keepusing(field_size) 
merge m:1 y2_hhid plot_id  using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_plot_decision_makers.dta", gen(dms) keep(1 3) keepusing(dm_gender) 
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
	foreach i in ea ta district region y2_hhid {
	preserve
		bys `i' input : egen obs_`i' = sum(obs)
		collapse (median) price_`i'=price [aw=plotweight], by (`i' input obs_`i')
		tempfile price_`i'_median
		save `price_`i'_median'
	restore
	}

	preserve
	bys input : egen obs_country = sum(obs)
	collapse (median) price_country = price [aw=plotweight], by(input  obs_country)
	tempfile price_country_median
	save `price_country_median'
	restore

	use `all_plot_inputs',clear
	foreach i in ea ta district region y2_hhid {
		merge m:1 `i' input using `price_`i'_median', nogen keep(1 3) 
	}
		merge m:1 input using `price_country_median', nogen keep(1 3)
		recode price_y2_hhid (.=0)
		gen price=price_y2_hhid
	foreach i in country ea ta district region  {
		replace price = price_`i' if obs_`i' > 9 & obs_`i'!=.
	}
	
	
	
//Default to household prices when available
replace price = price_y2_hhid if price_y2_hhid>0
replace qty = 0 if qty <0 
recode val qty (.=0)
drop if val==0 & qty==0 //Dropping unnecessary observations.
replace val=qty*price if val==0


* For PLOT LEVEL data, add in plot_labor data
append using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_plot_labor.dta" 
collapse (sum) val, by (y2_hhid plot_id  exp input dm_gender season)

* Save PLOT-LEVEL Crop Expenses (long)
	save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_plot_cost_inputs_long.dta",replace 

* Save PLOT-Level Crop Expenses (wide, does not currently get used in MWI W4 code)
preserve
	collapse (sum) val_=val, by(y2_hhid plot_id exp dm_gender season)
	reshape wide val_, i(y2_hhid plot_id dm_gender season) j(exp) string 
	save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_plot_cost_inputs.dta", replace
restore

* HKS 08.25.23: Aggregate PLOT-LEVEL crop expenses data up to HH level and append to HH LEVEL data.	
preserve
use "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_plot_cost_inputs_long.dta", clear
	collapse (sum) val, by(y2_hhid input exp season)
	tempfile plot_to_hh_cropexpenses
	save `plot_to_hh_cropexpenses', replace
restore


********
*** HH LEVEL Files: seed, asset_rental, phys inputs
use `seeds', clear
	append using `asset_rental'
	append using `phys_inputs'
	append using `tree_transportation'
	append using `tempcrop_transportation'
	merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_weights.dta", nogen keep(1 3) keepusing(weight region district ea ta) // merge in hh weight & geo data 
tempfile all_HH_LEVEL_inputs
save `all_HH_LEVEL_inputs', replace
	

* Calculating Geographic Medians for HH LEVEL files
	keep if strmatch(exp,"exp") & qty!=. 
	recode val (0=.)
	drop if unit==0 //Remove things with unknown units.
	gen price = val/qty
	drop if price==.
	gen obs=1

	capture restore,not 
	foreach i in ea ta district region y2_hhid {
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

	use `all_HH_LEVEL_inputs', clear
	foreach i in ea ta district region y2_hhid {
		merge m:1 `i' input unit itemcode using `price_`i'_median', nogen keep(1 3) 
	}
		merge m:1 input unit itemcode using `price_country_median', nogen keep(1 3)
		recode price_y2_hhid (.=0)
		gen price=price_y2_hhid
	foreach i in country ea ta district region  {
		replace price = price_`i' if obs_`i' > 9 & obs_`i'!=.
	}
	
	
//Default to household prices when available
replace price = price_y2_hhid if price_y2_hhid>0
replace qty = 0 if qty <0 // Remove any households reporting negative quantities of fertilizer.
recode val qty (.=0)
drop if val==0 & qty==0 
replace val=qty*price if val==0


preserve
	keep if strpos(input,"orgfert") | strpos(input,"inorg") | strpos(input,"herb") | strpos(input,"pest")
	//Unfortunately we have to compress liters and kg here, which isn't ideal.
	collapse (sum) qty_=qty, by(y2_hhid /*plot_id garden*/ input season)
	reshape wide qty_, i(y2_hhid /*plot_id garden*/ season) j(input) string
	ren qty_inorg inorg_fert_rate
	ren qty_orgfert org_fert_rate
	ren qty_herb herb_rate
	ren qty_pest pest_rate
	la var inorg_fert_rate "Qty inorganic fertilizer used (kg)"
	la var org_fert_rate "Qty organic fertilizer used (kg)"
    la var herb_rate "Qty of herbicide used (kg/L)"
    la var pest_rate "Qty of pesticide used (kg/L)"

	save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_input_quantities.dta", replace
restore	
	
* Save HH-LEVEL Crop Expenses (long)
preserve
collapse (sum) val, by(y2_hhid exp input region district ea ta) 
save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_hh_cost_inputs_long.dta", replace 
restore

* COMBINE HH-LEVEL crop expenses (long) with PLOT level data (long) aggregated up to HH LEVEL (hks 08.21.23):
use "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_hh_cost_inputs_long.dta", clear
	append using `plot_to_hh_cropexpenses'
		collapse (sum) val, by(y2_hhid exp input region district ea ta)
		replace exp = "exp" if strpos(input, "asset") |  strpos(input, "animal") | strpos(input, "tractor")
	save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_hh_cost_inputs_long_complete.dta", replace
tabstat val, by(input) s(mean median min max sd n)

**# Bookmark #2


********************************************************************************
* MONOCROPPED PLOTS *
********************************************************************************
use "${Malawi_IHPS_W2_created_data}/Malawi_W2_all_plots.dta",clear
	keep if purestand==1 
	ren crop_code cropcode
	save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_monocrop_plots.dta", replace

//Setting things up for AgQuery first
use "${Malawi_IHPS_W2_created_data}/Malawi_W2_all_plots.dta",clear
	merge m:1  y2_hhid plot_id  using  "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender)
	ren ha_planted monocrop_ha
	ren quant_harv_kg kgs_harv_mono
	ren value_harvest val_harv_mono
	collapse (sum) *mono*, by(y2_hhid plot_id crop_code dm_gender)
	
	
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
	save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_`cn'_monocrop.dta", replace
	
	foreach i in `cn'_monocrop_ha kgs_harv_mono_`cn' val_harv_mono_`cn' `cn'_monocrop {
		gen `i'_male = `i' if dm_gender==1
		gen `i'_female = `i' if dm_gender==2
		gen `i'_mixed = `i' if dm_gender==3
	}
	collapse (sum) *monocrop_ha* kgs_harv_mono* val_harv_mono* (max) `cn'_monocrop `cn'_monocrop_male `cn'_monocrop_female `cn'_monocrop_mixed, by(y2_hhid)
	la var `cn'_monocrop_ha "Total `cn' monocrop hectares - Household"
	la var `cn'_monocrop "Household has at least one `cn' monocrop"
	la var kgs_harv_mono_`cn' "Total kilograms of `cn' harvested - Household"
	la var val_harv_mono_`cn' "Value of harvested `cn' (MWK)"
	foreach g in male female mixed {		
		la var `cn'_monocrop_ha_`g' "Total `cn' monocrop hectares on `g' managed plots - Household"
		la var kgs_harv_mono_`cn'_`g' "Total kilograms of `cn' harvested on `g' managed plots - Household"
		la var val_harv_mono_`cn'_`g' "Total value of `cn' harvested on `g' managed plots - Household"
	}
	save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_`cn'_monocrop_hh_area.dta", replace
	}
	}
restore
}
	

use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_cost_inputs_long.dta", clear 
merge m:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender)
collapse (sum) val, by(y2_hhid plot_id dm_gender input)
levelsof input, clean l(input_names)
	ren val val_
	reshape wide val_, i(y2_hhid plot_id dm_gender) j(input) string
	gen dm_gender2 = "male" if dm_gender==1
	replace dm_gender2 = "female" if dm_gender==2
	replace dm_gender2 = "mixed" if dm_gender==3
	drop if dm_gender2 ==""
	drop dm_gender
	
foreach cn in $topcropname_area {
preserve

	capture confirm file "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_`cn'_monocrop.dta"
	if !_rc {
	ren val* val*_`cn'_
	reshape wide val*, i(y2_hhid plot_id) j(dm_gender2) string
	merge 1:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_`cn'_monocrop.dta", nogen keep(3)
	count
	if(r(N) > 0){
	collapse (sum) val*, by(y2_hhid)
	foreach i in `input_names' {
		
		egen val_`i'_`cn'_hh = rowtotal(val_`i'_`cn'_male val_`i'_`cn'_female ) //No Mixed Gender
	}
	
	save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_inputs_`cn'.dta", replace
	}
	}
restore
}
**# Bookmark #3
************
*LIVESTOCK INCOME - VAP complete; RH edited; HI checked 5/2/22 - needs review
************
{ //This bracket here to make the section collapsible.
*Expenses - RH edited, can't disaggregate; complete 7/20
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_r2_13.dta", clear
rename ag_r28 cost_fodder_livestock      
rename ag_r29 cost_vaccines_livestock     
rename ag_r30 cost_othervet_livestock    
gen cost_medical_livestock = cost_vaccines_livestock + cost_othervet_livestock
rename ag_r27 cost_hired_labor_livestock 
rename ag_r31 cost_input_livestock        
recode cost_fodder_livestock cost_vaccines_livestock cost_othervet_livestock cost_medical_livestock cost_hired_labor_livestock cost_input_livestock(.=0) 

collapse (sum) cost_fodder_livestock cost_vaccines_livestock cost_othervet_livestock  cost_hired_labor_livestock cost_input_livestock, by (y2_hhid)
lab var cost_fodder_livestock "Cost for fodder for <livestock>"
lab var cost_vaccines_livestock "Cost for vaccines and veterinary treatment for <livestock>"
lab var cost_othervet_livestock "Cost for other veterinary treatments for <livestock> (incl. dipping, deworming, AI)"
*lab var cost_medical_livestock "Cost for all veterinary services (total vaccine plus othervet)"
lab var cost_hired_labor_livestock "Cost for hired labor for <livestock>"
lab var cost_input_livestock "Cost for livestock inputs (incl. housing, equipment, feeding utensils)"
save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_livestock_expenses.dta", replace

*Livestock products 
* Milk - VAP complete (but question about per unit and per liter price)
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_s_13.dta", clear
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
keep y2_hhid livestock_code milk_liters_produced price_per_liter price_per_unit quantity_produced earnings_milk_year //why do we need both per liter and per unit if the same?
lab var price_per_liter "Price of milk per liter sold"
lab var price_per_unit "Price of milk per unit sold" 
lab var quantity_produced "Quantity of milk produced"
lab var earnings_milk_year "Total earnings of sale of milk produced"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products_milk", replace

* Other livestock products  // VAP: Includes milk, eggs, meat, hides/skins and manure. No honey in MW2. TZ does not have meat and manure.  
//RH: Why include milk here if we have a separate milk file (from same raw dta file) and append it later?
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_s_13.dta", clear
rename ag_s0a livestock_code
rename ag_s02 months_produced
rename ag_s03a quantity_month
rename ag_s03b quantity_month_unit
*replace quantity_month_unit =. if livestock_code==401 & quantity_month_unit!=1     // milk, keeping only liters.  // removing milk, since this is "other"
// 2 obsns in buckets will be 0. Conversion?
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
gen quantity_produced = months_produced * quantity_month // Units are liters for milk, pieces for eggs & skin, kg for meat and manure. (RH Note: only showing values for chicken eggs - is that correct?)
lab var quantity_produced "Quantity of this product produced in past year"

rename ag_s05a sales_quantity
rename ag_s05b sales_unit
*replace sales_unit =. if livestock_code==401 & sales_unit!=1 // milk, liters only
replace sales_unit =. if livestock_code==402 & sales_unit!=3  // chicken eggs, pieces only
replace sales_unit =. if livestock_code== 403 & sales_unit!=3   // guinea fowl eggs, pieces only
replace sales_quantity = sales_quantity*1.5 if livestock_code==404 & sales_unit==3 // VAP: converting obsns in pieces to kgs for meat. Using conversion for chicken. 
replace sales_unit = 2 if livestock_code== 404 & sales_unit==3 // VAP: kgs for meat
replace sales_unit =. if livestock_code== 406 & sales_unit!=3   // VAP: pieces for skin and hide, not converting kg (1 obsn).
replace sales_unit =. if livestock_code== 407 & quantity_month_unit!=2  // VAP: kgs for manure, not converting liters(1 obsn), bucket, wheelbarrow & oxcart (2 obsns each)

rename ag_s06 earnings_sales
recode sales_quantity months_produced quantity_month earnings_sales (.=0)
gen price_per_unit = earnings_sales / sales_quantity
keep y2_hhid livestock_code quantity_produced price_per_unit earnings_sales

label define livestock_code_label 402 "Chicken Eggs" 403 "Guinea Fowl Eggs" 404 "Meat" 406 "Skin/Hide" 407 "Manure" 408 "Other" //RH - added "other" lbl to 408, removed 401 "Milk"
label values livestock_code livestock_code_label
bys livestock_code: sum price_per_unit
gen price_per_unit_hh = price_per_unit
lab var price_per_unit "Price per unit sold"
lab var price_per_unit_hh "Price per unit sold at household level"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products_other", replace

// RH: removing milk, so this only has other livestock products. Next section will have milk and other

*All Livestock Products
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products_milk", clear
append using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products_other"
recode price_per_unit (0=.)
merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta"
drop if _merge==2
drop _merge
replace price_per_unit = . if price_per_unit == 0 
lab var price_per_unit "Price per unit sold"
lab var quantity_produced "Quantity of product produced"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products", replace
//RH Note: double check values later, esp quantity produced (why only chicken eggs?)

* EA Level
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products", clear
keep if price_per_unit !=. 
gen observation = 1
bys region district ta ea livestock_code: egen obs_ea = count(observation)
//RH note - ta is traditional authority. Do we want the label?
collapse (median) price_per_unit [aw=weight], by (region district ta ea livestock_code obs_ea)
rename price_per_unit price_median_ea
lab var price_median_ea "Median price per unit for this livestock product in the ea"
lab var obs_ea "Number of sales observations for this livestock product in the ea"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products_prices_ea.dta", replace

* ta Level
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys region district ta livestock_code: egen obs_TA = count(observation)
collapse (median) price_per_unit [aw=weight], by (region district ta livestock_code obs_TA)
rename price_per_unit price_median_TA
lab var price_median_TA "Median price per unit for this livestock product in the ta"
lab var obs_TA "Number of sales observations for this livestock product in the ta"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products_prices_TA.dta", replace

* District Level
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys region district livestock_code: egen obs_district = count(observation)
collapse (median) price_per_unit [aw=weight], by (region district livestock_code obs_district)
rename price_per_unit price_median_district
lab var price_median_district "Median price per unit for this livestock product in the district"
lab var obs_district "Number of sales observations for this livestock product in the district"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products_prices_district.dta", replace

* Region Level
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys region livestock_code: egen obs_region = count(observation)
collapse (median) price_per_unit [aw=weight], by (region livestock_code obs_region)
rename price_per_unit price_median_region
lab var price_median_region "Median price per unit for this livestock product in the region"
lab var obs_region "Number of sales observations for this livestock product in the region"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products_prices_region.dta", replace

* Country Level
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys livestock_code: egen obs_country = count(observation)
collapse (median) price_per_unit [aw=weight], by (livestock_code obs_country)
rename price_per_unit price_median_country
lab var price_median_country "Median price per unit for this livestock product in the country"
lab var obs_country "Number of sales observations for this livestock product in the country"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products_prices_country.dta", replace

use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products", clear
merge m:1 region district ta ea livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products_prices_ea.dta", nogen
merge m:1 region district ta livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products_prices_TA.dta", nogen
merge m:1 region district livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products_prices_district.dta", nogen
merge m:1 region livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products_prices_region.dta", nogen
merge m:1 livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_products_prices_country.dta", nogen
replace price_per_unit = price_median_ea if price_per_unit==. & obs_ea >= 10
replace price_per_unit = price_median_TA if price_per_unit==. & obs_TA >= 10
replace price_per_unit = price_median_district if price_per_unit==. & obs_district >= 10 
replace price_per_unit = price_median_region if price_per_unit==. & obs_region >= 10 
replace price_per_unit = price_median_country if price_per_unit==.
lab var price_per_unit "Price per unit of this livestock product, with missing values imputed using local median values" //is 10 the local median value?

gen value_milk_produced = milk_liters_produced * price_per_unit 
gen value_eggs_produced = quantity_produced * price_per_unit if livestock_code==402|livestock_code==403
gen value_other_produced = quantity_produced * price_per_unit if livestock_code== 404|livestock_code==406|livestock_code==407|livestock_code==408
egen sales_livestock_products = rowtotal(earnings_sales earnings_milk_year)		
collapse (sum) value_milk_produced value_eggs_produced value_other_produced sales_livestock_products, by (y2_hhid)

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
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_livestock_products", replace // RH complete
 
* Manure (Dung in TZ)
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_s_13.dta", clear
rename ag_s0a livestock_code
rename ag_s06 earnings_sales
gen sales_manure=earnings_sales if livestock_code==407 
recode sales_manure (.=0)
collapse (sum) sales_manure, by (y2_hhid)
lab var sales_manure "Value of manure sold" 
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_manure.dta", replace // RH complete

*Sales (live animals)
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_r1_13.dta", clear
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
merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta"
drop if _merge==2
drop _merge
keep y2_hhid weight region district ta ea livestock_code number_sold income_live_sales number_slaughtered /*number_slaughtered_sold income_slaughtered*/ price_per_animal value_livestock_purchases
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_livestock_sales", replace // RH complete

*Implicit prices  // VAP: MW2 does not have value of slaughtered livestock
* EA Level
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region district ta ea livestock_code: egen obs_ea = count(observation)
collapse (median) price_per_animal [aw=weight], by (region district ta ea livestock_code obs_ea)
rename price_per_animal price_median_ea
lab var price_median_ea "Median price per unit for this livestock in the ea"
lab var obs_ea "Number of sales observations for this livestock in the ea"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_ea.dta", replace // RH complete

* ta Level
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region district ta livestock_code: egen obs_TA = count(observation)
collapse (median) price_per_animal [aw=weight], by (region district ta livestock_code obs_TA)
rename price_per_animal price_median_TA
lab var price_median_TA "Median price per unit for this livestock in the ta"
lab var obs_TA "Number of sales observations for this livestock in the ta"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_TA.dta", replace // RH complete

* District Level
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region district livestock_code: egen obs_district = count(observation)
collapse (median) price_per_animal [aw=weight], by (region district livestock_code obs_district)
rename price_per_animal price_median_district
lab var price_median_district "Median price per unit for this livestock in the district"
lab var obs_district "Number of sales observations for this livestock in the district"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_district.dta", replace

* Region Level
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region livestock_code: egen obs_region = count(observation)
collapse (median) price_per_animal [aw=weight], by (region livestock_code obs_region)
rename price_per_animal price_median_region
lab var price_median_region "Median price per unit for this livestock in the region"
lab var obs_region "Number of sales observations for this livestock in the region"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_region.dta", replace

* Country Level
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys livestock_code: egen obs_country = count(observation)
collapse (median) price_per_animal [aw=weight], by (livestock_code obs_country)
rename price_per_animal price_median_country
lab var price_median_country "Median price per unit for this livestock in the country"
lab var obs_country "Number of sales observations for this livestock in the country"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_country.dta", replace //RH complete

use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_livestock_sales", clear
merge m:1 region district ta ea livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_ea.dta", nogen
merge m:1 region district ta livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_TA.dta", nogen
merge m:1 region district livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_district.dta", nogen
merge m:1 region livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_region.dta", nogen
merge m:1 livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_country.dta", nogen
replace price_per_animal = price_median_ea if price_per_animal==. & obs_ea >= 10
replace price_per_animal = price_median_TA if price_per_animal==. & obs_TA >= 10
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

collapse (sum) /*value_livestock_sales*/ value_livestock_purchases value_lvstck_sold /*value_slaughtered*/, by (y2_hhid)
drop if y2_hhid==""
*lab var value_livestock_sales "Value of livestock sold (live and slaughtered)"
lab var value_livestock_purchases "Value of livestock purchases"
*lab var value_slaughtered "Value of livestock slaughtered (with slaughtered livestock that weren't sold valued at local median prices for live animal sales)"
lab var value_lvstck_sold "Value of livestock sold live" 
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_sales", replace //RH complete

*TLU (Tropical Livestock Units)
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_r1_13.dta", clear
rename ag_r0a lvstckid //NOTE: why changing the name to lvstckid here?
gen tlu_coefficient=0.5 if (lvstckid==301|lvstckid==302|lvstckid==303|lvstckid==304|lvstckid==3304) // calf, steer/heifer, cow, bull, ox
replace tlu_coefficient=0.1 if (lvstckid==307|lvstckid==308) //goats, sheep
replace tlu_coefficient=0.2 if (lvstckid==309) // pigs
replace tlu_coefficient=0.01 if (lvstckid==311|lvstckid==313|lvstckid==315|lvstckid==319|lvstckid==3310|lvstckid==3314) // local hen, cock, duck, dove/pigeon, chicken layer/broiler, turkey/guinea fowl
replace tlu_coefficient=0.3 if (lvstckid==3305) // donkey/mule/horse
lab var tlu_coefficient "Tropical Livestock Unit coefficient"

rename lvstckid livestock_code //why not do this earlier?
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

rename ag_r23b lost_disease // VAP: Includes lost to injury in MW2
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
	collapse (firstnm) share_imp_herd_cows (sum) number_today_total number_1yearago animals_lost12months lost_disease /*ihs*/ number_today_exotic lvstck_holding=number_today_total, by(y2_hhid species)
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
	collapse (sum) number_today_total number_today_exotic (firstnm) *lrum *srum *pigs *equine *poultry share_imp_herd_cows, by(y2_hhid)
	
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
	save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_herd_characteristics", replace
restore

gen price_per_animal = income_live_sales / number_sold
merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta"
drop if _merge==2
drop _merge
merge m:1 region district ta ea livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_ea.dta"
drop _merge
merge m:1 region district ta livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_TA.dta"
drop _merge
merge m:1 region district livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_district.dta"
drop _merge
merge m:1 region livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_region.dta"
drop _merge
merge m:1 livestock_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_prices_country.dta"
drop _merge 
recode price_per_animal (0=.)
replace price_per_animal = price_median_ea if price_per_animal==. & obs_ea >= 10
replace price_per_animal = price_median_TA if price_per_animal==. & obs_TA >= 10
replace price_per_animal = price_median_district if price_per_animal==. & obs_district >= 10
replace price_per_animal = price_median_region if price_per_animal==. & obs_region >= 10
replace price_per_animal = price_median_country if price_per_animal==. 
lab var price_per_animal "Price per animal sold, imputed with local median prices if household did not sell"
gen value_1yearago = number_1yearago * price_per_animal
gen value_today = number_today_total * price_per_animal
collapse (sum) tlu_1yearago tlu_today value_1yearago value_today, by (y2_hhid)
lab var tlu_1yearago "Tropical Livestock Units as of 12 months ago"
lab var tlu_today "Tropical Livestock Units as of the time of survey"
gen lvstck_holding_tlu = tlu_today
lab var lvstck_holding_tlu "Total HH livestock holdings, TLU"  
lab var value_1yearago "Value of livestock holdings from one year ago"
lab var value_today "Value of livestock holdings today"
drop if y2_hhid==""
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_TLU.dta", replace

*Livestock income
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_sales", clear
merge 1:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_livestock_products", nogen
merge 1:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_manure.dta", nogen
merge 1:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_expenses", nogen
merge 1:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_TLU.dta", nogen

gen livestock_income = value_lvstck_sold + /*value_slaughtered*/ - value_livestock_purchases /*
*/ + (value_milk_produced + value_eggs_produced + value_other_produced + sales_manure) /*
*/ - (cost_hired_labor_livestock + cost_fodder_livestock + cost_vaccines_livestock + cost_othervet_livestock + cost_input_livestock)

lab var livestock_income "Net livestock income"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_income", replace

}

************
*FISH INCOME

************
*Fishing expenses  
/*VAP: Method of calculating ft and pt weeks and days consistent with ag module indicators for rainy/dry seasons*/
use "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_c_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_g_13.dta"
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
collapse (max) weeks_fishing days_per_week, by (y2_hhid) 
keep y2_hhid weeks_fishing days_per_week
lab var weeks_fishing "Weeks spent working as a fisherman (maximum observed across individuals in household)"
lab var days_per_week "Days per week spent working as a fisherman (maximum observed across individuals in household)"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_weeks_fishing.dta", replace

use "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_d1_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_h2_13.dta"
merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_weeks_fishing.dta"
rename weeks_fishing weeks
rename fs_d13 fuel_costs_week
replace fuel_costs_week = fs_h13 if fuel_costs_week==.
rename fs_d12 rental_costs_fishing // VAP: Boat/Engine rental.
// Relevant and in the MW2 Qs., but missing in .dta files. 
// fs_d6: "How much did your hh. pay to rent [gear] for use in last high season?" 
replace rental_costs_fishing=fs_h12 if rental_costs_fishing==.
rename fs_d10 purchase_costs_fishing // VAP: Boat/Engine purchase. Purchase cost is additional in MW2, TZ code does not have this. 
// Also relevant but missing in .dta files. 
// fs_d4: "If you or any member of your household engaged in fishing had to purchase a [FISHING GEAR], how much would you have
// paid during the last HIGH fishing season? 
replace purchase_costs_fishing=fs_h10 if purchase_costs_fishing==. 
recode weeks fuel_costs_week rental_costs_fishing  purchase_costs_fishing(.=0)
gen cost_fuel = fuel_costs_week * weeks
collapse (sum) cost_fuel rental_costs_fishing, by (y2_hhid)
lab var cost_fuel "Costs for fuel over the past year"
lab var rental_costs_fishing "Costs for other fishing expenses over the past year"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_fishing_expenses_1.dta", replace // VAP: Not including hired labor costs, keeping consistent with TZ. Can add this for MW if needed. 

* Other fishing costs  
use "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_d4_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_h4_13.dta"
merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_weeks_fishing"
rename fs_d24a total_cost_high // total other costs in high season, only 6 obsns. 
replace total_cost_high=fs_h24a if total_cost_high==.
rename fs_d24b unit
replace unit=fs_h24b if unit==. 
gen cost_paid = total_cost_high if unit== 2  // season
replace cost_paid = total_cost_high * weeks_fishing if unit==1 // weeks
collapse (sum) cost_paid, by (y2_hhid)
lab var cost_paid "Other costs paid for fishing activities"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_fishing_expenses_2.dta", replace

* Fish Prices
//ALT 10.18.19: It doesn't look like the data match up with the questions in module e.

use "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_e1_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_i1_13.dta"
rename fs_e02 fish_code 
replace fish_code=fs_i02 if fish_code==. 
recode fish_code (12=11) // recoding "aggregate" from low season to "other"
rename fs_e06a fish_quantity_year // high season
replace fish_quantity_year=fs_i06a if fish_quantity_year==. // low season
rename fs_e06b fish_quantity_unit
replace fish_quantity_unit=fs_i06b if fish_quantity_unit==.
rename fs_e08b unit  // piece, dozen/bundle, kg, small basket, large basket
gen price_per_unit = fs_e08d // VAP: This is already avg. price per packaging unit. Did not divide by avg. qty sold per week similar to TZ, seems to be an error?
replace price_per_unit = fs_i08d if price_per_unit==.
merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta"
drop if _merge==2
drop _merge
recode price_per_unit (0=.) 
collapse (median) price_per_unit [aw=weight], by (fish_code unit)
rename price_per_unit price_per_unit_median
replace price_per_unit_median = . if fish_code==11
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_fish_prices.dta", replace

* Value of fish harvest & sales 
use "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_e1_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_i1_13.dta"
rename fs_e02 fish_code 
replace fish_code=fs_i02 if fish_code==. 
recode fish_code (12=11) // recoding "aggregate" from low season to "other"
rename fs_e06a fish_quantity_year // high season
replace fish_quantity_year=fs_i06a if fish_quantity_year==. // low season
rename fs_e06b unit  // piece, dozen/bundle, kg, small basket, large basket
merge m:1 fish_code unit using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_fish_prices.dta"
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
recode quantity_1 quantity_2 fish_quantity_year (.=0)
gen income_fish_sales = (quantity_1 * price_unit_1) + (quantity_2 * price_unit_2)
gen value_fish_harvest = (fish_quantity_year * price_unit_1) if unit==unit_1 
replace value_fish_harvest = (fish_quantity_year * price_per_unit_median) if value_fish_harvest==.
collapse (sum) value_fish_harvest income_fish_sales, by (y2_hhid)
recode value_fish_harvest income_fish_sales (.=0)
lab var value_fish_harvest "Value of fish harvest (including what is sold), with values imputed using a national median for fish-unit-prices"
lab var income_fish_sales "Value of fish sales"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_fish_income.dta", replace


************
*SELF-EMPLOYMENT INCOME
************
use "${Malawi_IHPS_W2_raw_data}\household\HH_MOD_N2_13.dta", clear
rename hh_n40 last_months_profit
gen self_employed_yesno = .
replace self_employed_yesno = 1 if last_months_profit !=.
replace self_employed_yesno = 0 if last_months_profit == .
*DYA.2.9.2022 Collapse this at the household level
collapse (max) self_employed_yesno (sum) last_months_profit, by(y2_hhid)
drop if self != 1
ren last_months self_employ_income
*lab var self_employed_yesno "1=Household has at least one member with self-employment income"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_self_employment_income.dta", replace

*Fish trading
use "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_c_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_g_13.dta"
rename fs_c04a weeks_fish_trading 
replace weeks_fish_trading=fs_g04a if weeks_fish_trading==.
recode weeks_fish_trading (.=0)
collapse (max) weeks_fish_trading, by (y2_hhid) 
keep y2_hhid weeks_fish_trading
lab var weeks_fish_trading "Weeks spent working as a fish trader (maximum observed across individuals in household)"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_weeks_fish_trading.dta", replace

use "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_f1_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_f2_13.dta"
append using "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_j1_13.dta"
append using "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_j2_13.dta"
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
collapse (sum) weekly_fishtrade_profit, by (y2_hhid)
lab var weekly_fishtrade_profit "Average weekly profits from fish trading (sales minus purchases), summed across individuals"
keep y2_hhid weekly_fishtrade_profit
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_fish_trading_revenues.dta", replace   

use "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_f2_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}\Fisheries\fs_mod_j2_13.dta"
rename fs_f05 weekly_costs_for_fish_trading // VAP: Other costs: Hired labor, transport, packaging, ice, tax in MW2.
replace weekly_costs_for_fish_trading=fs_j05 if weekly_costs_for_fish_trading==.
recode weekly_costs_for_fish_trading (.=0)
collapse (sum) weekly_costs_for_fish_trading, by (y2_hhid)
lab var weekly_costs_for_fish_trading "Weekly costs associated with fish trading, in addition to purchase of fish"
keep y2_hhid weekly_costs_for_fish_trading
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_fish_trading_other_costs.dta", replace

use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_weeks_fish_trading.dta", clear
merge 1:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_fish_trading_revenues.dta" 
drop _merge
merge 1:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_fish_trading_other_costs.dta"
drop _merge
replace weekly_fishtrade_profit = weekly_fishtrade_profit - weekly_costs_for_fish_trading
gen fish_trading_income = (weeks_fish_trading * weekly_fishtrade_profit)
lab var fish_trading_income "Estimated net household earnings from fish trading over previous 12 months"
keep y2_hhid fish_trading_income
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_fish_trading_income.dta", replace


************
*NON-AG WAGE INCOME
************
use "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_e_13.dta", clear
rename hh_e06_4 wage_yesno // MW2: In last 12m,  work as an employee for a wage, salary, commission, or any payment in kind: incl. paid apprenticeship, domestic work or paid farm work, excluding ganyu
rename hh_e22 number_months  //MW2:# of months worked at main wage job in last 12m. 
rename hh_e23 number_weeks  // MW2:# of weeks/month worked at main wage job in last 12m. 
rename hh_e24 number_hours  // MW2:# of hours/week worked at main wage job in last 12m. 
rename hh_e25 most_recent_payment // amount of last payment
replace most_recent_payment=. if inlist(hh_e19b,62 63 64) // VAP: main wage job 
**** 
* VAP: For MW2, above codes are in .dta. 62:Agriculture and animal husbandry worker; 63: Forestry workers; 64: Fishermen, hunters and related workers   
* For TZ: TASCO codes from TZ Basic Info Document http://siteresources.worldbank.org/INTLSMS/Resources/3358986-1233781970982/5800988-1286190918867/TZNPS_2014_2015_BID_06_27_2017.pdf
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
replace secwage_most_recent_payment = . if hh_e33b== 62  // code of secondary wage job
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
collapse (sum) annual_salary, by (y2_hhid)
lab var annual_salary "Annual earnings from non-agricultural wage"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_wage_income.dta", replace



************
*AG WAGE INCOME
************
use "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_e_13.dta", clear
rename hh_e06_4 wage_yesno // MW2: last 12m,  work as an employee for a wage, salary, commission, or any payment in kind: incl. paid apprenticeship, domestic work or paid farm work, excluding ganyu
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
collapse (sum) annual_salary, by (y2_hhid)
rename annual_salary annual_salary_agwage
lab var annual_salary_agwage "Annual earnings from agricultural wage"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_agwage_income.dta", replace  // 0 annual earnings, 3907 obsns


************
*OTHER INCOME
************
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_crop_prices.dta", clear
keep if crop_code==1 // keeping only maize for later
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_maize_prices.dta", replace

use "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_p_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_r_13.dta"
append using "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_o_13.dta"
merge m:1 y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_maize_prices.dta"  // VAP: need maize prices for calculating cash value of free maize 
rename hh_p0a income_source
gen rental_income=1 if inlist(income_source, 106, 107, 108, 109) // non-ag land rental, house/apt rental, shope/store rental, vehicle rental
gen pension_investment_income=1 if income_source==105| income_source==104 // pension & savings/interest/investment income
gen asset_sale_income=1 if inlist(income_source, 110,111,112) // real estate sales, non-ag hh asset sale income, hh ag/fish asset sale income
gen other_income=1 if inlist(income_source, 113, 114, 115) // inheritance, lottery, other income
rename hh_r0a prog_code
gen assistance_cash= hh_r02a if inlist(prog_code, 1031, 1032,104,108,1091,111,112) // Cash from MASAF, Non-MASAF pub. works, 
*inputs-for-work, sec. level scholarships, tert. level. scholarships, dir. Cash Tr. from govt, DCT other
gen assistance_food= hh_r02b if inlist(prog_code, 102, 1032) // Cash value of in-kind assistance from free food and Food for work. 
replace assistance_food=hh_r02c*price_kg if prog_code==101 & crop_code==1 // cash value of free maize, imputed from hh. median prices. 
gen assistance_inkind=hh_r02b if inlist(prog_code, 1031, 104, 108, 1091, 111, 112) // cash value of in-kind assistance from MASAF
* inputs-for-work, scholarships (sec. & tert.), direct cash transfers (govt & other)
gen cash_received=1 if income_source== 101 // Cash transfers/gifts from indivs. 
gen inkind_gifts_received=1 if inlist(income_source, 102,103) // Food & In-kind transfers/gifts from indivs.
rename hh_o14 cash_remittance // VAP: Module O in MW2
rename hh_o17 in_kind_remittance // VAP: Module O in MW2
recode rental_income pension_investment_income asset_sale_income other_income assistance_cash assistance_food assistance_inkind cash_received inkind_gifts_received cash_remittance in_kind_remittance (.=0)

gen remittance_income = cash_received + inkind_gifts_received + cash_remittance + in_kind_remittance
gen assistance_income = assistance_cash + assistance_food + assistance_inkind
collapse (sum) rental_income pension_investment_income asset_sale_income other_income remittance_income assistance_income, by (y2_hhid)
lab var rental_income "Estimated income from rentals of buildings, land, vehicles over previous 12 months"
lab var pension_investment_income "Estimated income from a pension AND INTEREST/INVESTMENT/INTEREST over previous 12 months"
lab var other_income "Estimated income from inheritance, lottery/gambling and ANY OTHER source over previous 12 months"
lab var asset_sale_income "Estimated income from household asset and real estate sales over previous 12 months"
lab var remittance_income "Estimated income from remittances over previous 12 months"
lab var assistance_income "Estimated income from food aid, food-for-work, cash transfers etc. over previous 12 months"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_other_income.dta", replace


use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear // *VAP: The below code calculates only agricultural land rental income, per TZ guideline code 
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_k_13.dta"
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
collapse (sum) land_rental_income, by (y2_hhid)
lab var land_rental_income "Estimated income from renting out land over previous 12 months"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_land_rental_income.dta", replace

************
*FARM SIZE / LAND SIZE - TK 2/15/2024 Updated 
************
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_g_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_m_13.dta"
gen cultivated = 1 
replace ag_g00  = ag_m00 if ag_g00 ==""
ren ag_g00 plot_id
drop if plot_id==""
replace ag_g0a = ag_m0a if ag_g0a == .
ren ag_g0a cultivated_this_year // Plant any crops during 2012/2013 rainy season or 2013 dry season 

preserve 
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_p_13.dta", clear
gen cultivated = 1 if (ag_p05 !=. & ag_p05 !=0 | ag_p05 !=. & ag_p05 !=0)
ren ag_p00 plot_id
collapse (max) cultivated, by (y2_hhid plot_id)
tempfile tree
save `tree', replace
restore
append using `tree'

preserve 
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear 
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_k_13.dta"
replace ag_d00  = ag_k00 if ag_d00 =="" 
ren ag_d00 plot_id
drop if plot_id==""  
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_ag_mod_k_d_13_temp.dta", replace
restore 
merge m:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_ag_mod_k_d_13_temp.dta"
replace cultivated = 1 if (ag_d14==1 | ag_k15==1)
replace cultivated = 1 if cultivated_this_year==1 & cultivated==.

collapse (max) cultivated, by (y2_hhid plot_id)
lab var cultivated "1= Parcel was cultivated in this data set"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_parcels_cultivated.dta", replace

use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_parcels_cultivated.dta", clear
merge 1:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_plot_areas.dta", nogen keep(1 3)
keep if cultivated==1
replace area_meas_hectares=. if area_meas_hectares<0 
replace area_meas_hectares = area_est_hectares if area_meas_hectares ==. 
collapse (sum) area_meas_hectares, by (y2_hhid plot_id)
rename area_meas_hectares field_size
save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_plot_sizes.dta", replace
collapse (sum) field_size, by (y2_hhid)
ren field_size farm_area
lab var farm_area "Land size (denominator for land productivitiy), in hectares" 
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_land_size.dta", replace

* All agricultural land
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_ag_mod_k_d_13_temp.dta", clear 
gen agland = (ag_d14==1 | ag_d14==4 |ag_k15==1 | ag_k15==4) // All cultivated AND fallow plots 
merge m:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_parcels_cultivated.dta", nogen keep(1 3)
preserve 
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_p_13.dta", clear
gen cultivated = 1 if (ag_p05 !=. & ag_p05 !=0 | ag_p05 !=. & ag_p05 !=0)
ren ag_p00 plot_id
collapse (max) cultivated, by (y2_hhid plot_id)
tempfile tree
save `tree', replace
restore
append using `tree'
replace agland=1 if cultivated==1
keep if agland==1
collapse (max) agland, by (y2_hhid plot_id)
keep y2_hhid plot_id agland
lab var agland "1= Parcel was used for crop cultivation or left fallow in this past year (forestland and other uses excluded)"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_parcels_agland.dta", replace


use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_parcels_agland.dta", clear
merge 1:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_areas.dta"
keep if agland==1
replace area_meas_hectares=. if area_meas_hectares<0 
replace area_meas_hectares = area_est_hectares if area_meas_hectares ==. 
replace area_meas_hectares = area_est_hectares if area_meas_hectares==0 & (area_est_hectares>0 & area_est_hectares!=.)	
collapse (sum) area_meas_hectares, by (y2_hhid)
ren area_meas_hectares farm_size_agland
lab var farm_size_agland "Land size in hectares, including all plots cultivated or left fallow" 
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_farmsize_all_agland.dta", replace

* parcels held
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear
append using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_ag_mod_k_d_13_temp.dta"
drop if plot_id==""
gen rented_out = (ag_d14==2 | ag_d14==3 | ag_k15==2 | ag_k15==3) // VAP: In MW2, rented out (2) & gave out for free (3)
gen cultivated_dry = (ag_k15==1)
bys y2_hhid plot_id: egen plot_cult_dry = max(cultivated_dry)
replace rented_out = 0 if plot_cult_dry==1 // If cultivated in dry season, not considered rented out in rainy season.
drop if rented_out==1
gen plot_held = 1
collapse (max) plot_held, by (y2_hhid plot_id)
lab var plot_held "1= Parcel was NOT rented out in the main season"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_parcels_held.dta", replace

use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_parcels_held.dta", clear
merge 1:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_areas.dta"
drop if _merge==2
replace area_meas_hectares=. if area_meas_hectares<0 
replace area_meas_hectares = area_est_hectares if area_meas_hectares ==. 
collapse (sum) area_meas_hectares, by (y2_hhid)
rename area_meas_hectares land_size
lab var land_size "Land size in hectares, including all plots listed by the household except those rented out" 
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_land_size_all.dta", replace


use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_areas.dta", clear
replace area_meas_hectares=. if area_meas_hectares<0 
replace area_meas_hectares = area_est_hectares if area_meas_hectares ==. 
replace area_meas_hectares = area_est_hectares if area_meas_hectares==0 & (area_est_hectares>0 & area_est_hectares!=.)
collapse (sum) area_meas_hectares, by(y2_hhid)
ren area_meas_hectares land_size_total
lab var land_size_total "Total land size in hectares, including rented in and rented out plots"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_land_size_total.dta", replace


//
// ***Determining whether crops were grown on a plot
// use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_g_13.dta", clear
// append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_m_13.dta"
// ren ag_g00 plot_id
// drop if plot_id==""
// drop if ag_g0b==. // crop code
// gen crop_grown = 1 
// collapse (max) crop_grown, by(y2_hhid plot_id)
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crops_grown.dta", replace
// ***
//
// use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_k_13.dta", clear
// rename ag_k00 plot_id
// tempfile ag_mod_k_13_numeric
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_ag_mod_k_13_temp.dta", replace  // VAP:Renaming plot ids, to work with Module D and K together.
// use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear
// rename ag_d00 plot_id
// append using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_ag_mod_k_13_temp.dta"
// gen cultivated = (ag_d14==1 | ag_k15==1) // VAP: cultivated plots in rainy or dry seasons
// collapse (max) cultivated, by (y2_hhid plot_id)
// lab var cultivated "1= Parcel was cultivated in this data set"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_parcels_cultivated.dta", replace
//
// use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_parcels_cultivated.dta", clear
// merge 1:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_areas.dta",
// drop if _merge==2
// keep if cultivated==1
//
// replace area_acres_meas=. if area_acres_meas<0 
// replace area_acres_meas = area_acres_est if area_acres_meas==. 
// collapse (sum) area_acres_meas, by (y2_hhid)
// rename area_acres_meas farm_area
// replace farm_area = farm_area * (1/2.47105) /* Convert to hectares */
// lab var farm_area "Land size (denominator for land productivitiy), in hectares" 
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_land_size.dta", replace
//
// * All agricultural land
// use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear
// rename ag_d00 plot_id
// append using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_ag_mod_k_13_temp.dta"
// drop if plot_id==""
// merge m:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crops_grown.dta", nogen
// // VAP: 
// * 6,196 matched
// *1,107 not matched (from master)
// gen rented_out = (ag_d14==2 |ag_k15==2)
// gen cultivated_dry = (ag_k15==1)
// bys y2_hhid plot_id: egen plot_cult_dry = max(cultivated_dry)
// replace rented_out = 0 if plot_cult_dry==1 // VAP: From TZ:If cultivated in short season, not considered rented out in long season.
// // TZ code commented out the below:
// * drop if rented_out==1
// * 62 obs dropped
// //
// drop if rented_out==1 & crop_grown!=1
// * VAP:25 obs dropped
// gen agland = (ag_d14==1 | ag_d14==4 |ag_k15==1 | ag_k15==4) // All cultivated AND fallow plots, forests/woodlot & pasture is captured within "other" (can't be separated out)
//
// drop if agland!=1 & crop_grown==.
// * 352 obs dropped
// collapse (max) agland, by (y2_hhid plot_id)
// lab var agland "1= Parcel was used for crop cultivation or left fallow in this past year (forestland and other uses excluded)"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_parcels_agland.dta", replace
//
// use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_parcels_agland.dta", clear
// merge 1:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_areas.dta"
// drop if _merge==2
// replace area_acres_meas=. if area_acres_meas<0
// replace area_acres_meas = area_acres_est if area_acres_meas==. 
// replace area_acres_meas = area_acres_est if area_acres_meas==0 & (area_acres_est>0 & area_acres_est!=.)		
// collapse (sum) area_acres_meas, by (y2_hhid)
// rename area_acres_meas farm_size_agland
// replace farm_size_agland = farm_size_agland * (1/2.47105) /* Convert to hectares */
// lab var farm_size_agland "Land size in hectares, including all plots cultivated or left fallow" 
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_farmsize_all_agland.dta", replace
//
//
// use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear
// append using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_ag_mod_k_13_temp.dta"
// drop if plot_id==""
// gen rented_out = (ag_d14==2 | ag_d14==3 | ag_k15==2 | ag_k15==3) // VAP: In MW2, rented out (2) & gave out for free (3)
// gen cultivated_dry = (ag_k15==1)
// bys y2_hhid plot_id: egen plot_cult_dry = max(cultivated_dry)
// replace rented_out = 0 if plot_cult_dry==1 // If cultivated in dry season, not considered rented out in rainy season.
// drop if rented_out==1
// gen plot_held = 1
// collapse (max) plot_held, by (y2_hhid plot_id)
// lab var plot_held "1= Parcel was NOT rented out in the main season"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_parcels_held.dta", replace
//
// use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_parcels_held.dta", clear
// merge 1:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_areas.dta"
// drop if _merge==2
// replace area_acres_meas=. if area_acres_meas<0
// replace area_acres_meas = area_acres_est if area_acres_meas==. 
// collapse (sum) area_acres_meas, by (y2_hhid)
// rename area_acres_meas land_size
// lab var land_size "Land size in hectares, including all plots listed by the household except those rented out" 
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_land_size_all.dta", replace
//
// *Total land holding including cultivated and rented out
// use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear
// rename ag_d00 plot_id
// append using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_ag_mod_k_13_temp.dta"
// drop if plot_id==""
// merge m:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_areas.dta", nogen keep(1 3)
// replace area_acres_meas=. if area_acres_meas<0
// replace area_acres_meas = area_acres_est if area_acres_meas==. 
// replace area_acres_meas = area_acres_est if area_acres_meas==0 & (area_acres_est>0 & area_acres_est!=.)	
// collapse (max) area_acres_meas, by(y2_hhid plot_id)
// rename area_acres_meas land_size_total
// collapse (sum) land_size_total, by(y2_hhid)
// replace land_size_total = land_size_total * (1/2.47105) /* Convert to hectares */
// lab var land_size_total "Total land size in hectares, including rented in and rented out plots"
// save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_land_size_total.dta", replace


***************
*OFF-FARM HOURS TK Updated 
***************
use "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_e_13.dta", clear
gen  hrs_main_wage_off_farm=hh_e24_1 if !inlist(hh_e19b, 62, 63, 64) & hh_e19b!=. 	
gen  hrs_sec_wage_off_farm=hh_e38_1 if hh_e33b!=62 & hh_e33b!=.  
egen hrs_wage_off_farm= rowtotal(hrs_main_wage_off_farm hrs_sec_wage_off_farm)
gen  hrs_main_wage_on_farm=hh_e24_1 if inlist(hh_e19b, 62, 63, 64) & hh_e19b!=. 		 
gen  hrs_sec_wage_on_farm= hh_e38_1 if hh_e33b!=62 & hh_e33b!=.	 
egen hrs_wage_on_farm= rowtotal(hrs_main_wage_on_farm hrs_sec_wage_on_farm) 
drop *main* *sec*
gen hrs_unpaid_off_farm = hh_e52_1 //TK Q= During the last 7days, approximately how many hours did you work at this unpaid apprenticeship?

recode hh_e06 hh_e05 (.=0)
gen  hrs_domest_fire_fuel=(hh_e06+ hh_e05)*7 // hrs worked just yesterday

ren  hh_e07 hrs_ag_activ
egen hrs_off_farm=rowtotal(hrs_wage_off_farm)
egen hrs_on_farm=rowtotal(hrs_ag_activ hrs_wage_on_farm)
egen hrs_domest_all=rowtotal(hrs_domest_fire_fuel)
egen hrs_other_all=rowtotal(hrs_unpaid_off_farm)
gen hrs_self_off_farm=.
foreach v of varlist hrs_* {
	local l`v'=subinstr("`v'", "hrs", "nworker",.)
	gen  `l`v''=`v'!=0
} 
gen member_count = 1
collapse (sum) nworker_* hrs_*  member_count, by(y2_hhid)
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
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_off_farm_hours.dta", replace

********************************************************************************
*FARM LABOR TK Updated 2/8/24
********************************************************************************

use "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_plot_labor_long.dta", clear
drop if strmatch(gender,"all")
ren days labor_
collapse (sum) labor_, by(y2_hhid labor_type gender)
reshape wide labor_, i(y2_hhid gender) j(labor_type) string
drop if strmatch(gender,"")
ren labor* labor*_
reshape wide labor*, i(y2_hhid) j(gender) string
egen labor_total=rowtotal(labor*)
egen labor_hired = rowtotal(labor_hired*)
egen labor_family = rowtotal(labor_family*)
lab var labor_total "Total labor days (family, hired, or other) allocated to the farm in the past year"
lab var labor_hired "Total labor days (hired) allocated to the farm in the past year"
lab var labor_family "Total labor days (family) allocated to the farm in the past year"
lab var labor_hired_male "Workdays for male hired labor allocated to the farm in the past year"		
lab var labor_hired_female "Workdays for female hired labor allocated to the farm in the past year"		
keep y2_hhid labor_total labor_hired labor_family labor_hired_male labor_hired_female
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_family_hired_labor.dta", replace

***************
*VACCINE USAGE - VAP/ALT complete
***************
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_r1_13.dta", clear
gen vac_animal=ag_r24>0
* MW2: How many of your[Livestock] are currently vaccinated? 
* TZ: Did you vaccinate your[ANIMAL] in the past 12 months? 
replace vac_animal = 0 if ag_r24==0  
replace vac_animal = . if ag_r24==. // VAP: 4092 observations on a hh-animal level

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

collapse (max) vac_animal*, by (y2_hhid)
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
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_vaccine.dta", replace

 
*vaccine use livestock keeper  
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_r1_13.dta", clear
gen all_vac_animal=ag_r24>0
* MW2: How many of your[Livestock] are currently vaccinated? 
* TZ: Did you vaccinate your[ANIMAL] in the past 12 months? 
replace all_vac_animal = 0 if ag_r24==0  
replace all_vac_animal = . if ag_r24==. // VAP: 4092 observations on a hh-animal level
keep y2_hhid ag_r06a ag_r06b all_vac_animal

//ALT 10.21.19: These lines do the same thing as the commented lines without dealing with juggling tempfiles
ren ag_r06a farmerid1
ren ag_r06b farmerid2
gen t=1
gen patid=sum(t)
reshape long farmerid, i(patid) j(idnum)
drop t patid

collapse (max) all_vac_animal , by(y2_hhid farmerid)
gen indiv=farmerid
drop if indiv==.
merge 1:1 y2_hhid indiv using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_gender_merge.dta", nogen
lab var all_vac_animal "1 = Individual farmer (livestock keeper) uses vaccines"
ren indiv indidy2
gen livestock_keeper=1 if farmerid!=.
recode livestock_keeper (.=0)
lab var livestock_keeper "1=Indvidual is listed as a livestock keeper (at least one type of livestock)" 
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_farmer_vaccine.dta", replace

***************
*ANIMAL HEALTH - DISEASES - VAP complete, RH checked 8/3
***************
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_r1_13.dta", clear
gen disease_animal = 1 if ag_r22==1 // Answered "yes" for "Did livestock suffer from any disease in last 12m?"
replace disease_animal = 0 if inlist(ag_r22,0,2,3,4,6,9) // VAP: 2=No disease, other category numbers are unnamed, dropping these. 
replace disease_animal = . if (ag_r22==.) 
* VAP: TZ main diseases: FMD, lumpy skin, brucelosis, CCPP, BQ. MW2 has different main diseases. 
gen disease_ASF = ag_r23a==1  //  African swine fever
gen disease_amapl = ag_r23a==2 // Amaplasmosis
gen disease_bruc = ag_r23a== 7 // Brucelosis
gen disease_mange = ag_r23a==18 // Mange
gen disease_NC= ag_r23a==20 // New Castle disease
gen disease_spox= ag_r23a==22 // Small pox

rename ag_r0a livestock_code
gen species = (inlist(livestock_code, 301,302,303,304,3304)) + 2*(inlist(livestock_code,307,308)) + 3*(livestock_code==309) + 4*(livestock_code==3305) + 5*(inlist(livestock_code, 311,313,315,319,3310,3314))
recode species (0=.)
la def species 1 "Large ruminants (cows, buffalos)" 2 "Small ruminants (sheep, goats)" 3 "Pigs" 4 "Equine (horses, donkeys)" 5 "Poultry"
la val species species

*A loop to create species variables
foreach i in disease_animal disease_ASF disease_amapl disease_bruc disease_mange disease_NC disease_spox{
	gen `i'_lrum = `i' if species==1
	gen `i'_srum = `i' if species==2
	gen `i'_pigs = `i' if species==3
	gen `i'_equine = `i' if species==4
	gen `i'_poultry = `i' if species==5
}

collapse (max) disease_*, by (y2_hhid)
lab var disease_animal "1= Household has animal that suffered from disease"
lab var disease_ASF "1= Household has animal that suffered from African Swine Fever"
lab var disease_amapl"1= Household has animal that suffered from amaplasmosis disease"
lab var disease_bruc"1= Household has animal that suffered from brucelosis"
lab var disease_mange "1= Household has animal that suffered from mange disease"
lab var disease_NC "1= Household has animal that suffered from New Castle disease"
lab var disease_spox "1= Household has animal that suffered from small pox"

	foreach i in disease_animal disease_ASF disease_amapl disease_bruc disease_mange disease_NC disease_spox{
		local l`i' : var lab `i'
		lab var `i'_lrum "`l`i'' - large ruminants"
		lab var `i'_srum "`l`i'' - small ruminants"
		lab var `i'_pigs "`l`i'' - pigs"
		lab var `i'_equine "`l`i'' - equine"
		lab var `i'_poultry "`l`i'' - poultry"
	}

save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_livestock_diseases.dta", replace


********************************************************************************
* PLOT MANAGERS *
********************************************************************************
//This section combines all the variables that we're interested in at manager level
//(inorganic fertilizer, improved seed) into a single operation.
//Doing improved seed and agrochemicals at the same time.

//
// use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_h_13.dta", clear
//
// append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_n_13.dta"
//
//
// use "${Nigeria_GHS_W3_raw_data}/sect11e_plantingw3.dta", clear
// gen use_imprv_seed=s11eq3b==1 |  s11eq3b==2
// ren plotid plot_id
// ren cropcode crop_code
// //Crop recode
// recode crop_code (1053=1050) (1061 1062 = 1060) (1081 1082=1080) (1091 1092 1093 = 1090) (1111=1110) (2191 2192 2193=2190) /*Counting this generically as pumpkin, but it is different commodities
// 	*/				 (3181 3182 3183 3184 = 3180) (2170=2030) (3113 3112 3111 = 3110) (3022=3020) (2142 2141 = 2140) (1121 1122 1123 1124=1120)
// collapse (max) use_imprv_seed, by(hhid plot_id crop_code)
// tempfile imprv_seed
// save `imprv_seed'
// use "${Nigeria_GHS_W3_created_data}/Nigeria_GHS_W3_plot_areas.dta", clear
// ren s11aq6a pid1
// ren s11aq6b pid2
// replace pid1=sa1q11 if pid1==.
// replace pid2=sa1q11b if pid2==.
// keep hhid plot_id pid*
// reshape long pid, i(hhid plot_id) j(pidno)
// drop pidno
// drop if pid==.
// ren pid indiv
// merge m:1 hhid indiv using "${Nigeria_GHS_W3_created_data}/Nigeria_GHS_W3_gender_merge.dta", nogen keep(1 3)
// tempfile personids
// save `personids'
//
// use "${Nigeria_GHS_W3_created_data}/Nigeria_GHS_W3_input_quantities.dta", clear
// foreach i in inorg_fert org_fert pest herb {
// 	recode `i'_rate (.=0)
// 	replace `i'_rate=1 if `i'_rate >0 
// 	ren `i'_rate use_`i'
// }
// collapse (max) use_*, by(hhid plot_id)
// merge 1:m hhid plot_id using "${Nigeria_GHS_W3_created_data}/Nigeria_GHS_W3_all_plots.dta", nogen keep(1 3) keepusing(crop_code_master)
// ren crop_code_master crop_code
// collapse (max) use*, by(hhid plot_id crop_code)
// merge 1:1 hhid plot_id crop_code using `imprv_seed',nogen
// recode use* (.=0)
// preserve 
// keep hhid plot_id crop_code use_imprv_seed
// ren use_imprv_seed imprv_seed_
// gen hybrid_seed_ = .
// collapse (max) imprv_seed_ hybrid_seed_, by(hhid crop_code)
// merge m:1 crop_code using "${Nigeria_GHS_W3_created_data}/Nigeria_GHS_W3_cropname_table.dta", nogen keep(3)
// drop crop_code
// reshape wide imprv_seed_ hybrid_seed_, i(hhid) j(crop_name) string
// save "${Nigeria_GHS_W3_created_data}/Nigeria_GHS_W3_imprvseed_crop.dta",replace //ALT: this is slowly devolving into a kludgy mess as I try to keep continuity up in the hh_vars section.
// restore 
//
//
// merge m:m hhid plot_id using `personids', nogen keep(1 3)
// preserve
// ren use_imprv_seed all_imprv_seed_
// gen all_hybrid_seed_ =.
// collapse (max) all*, by(hhid indiv female crop_code)
// merge m:1 crop_code using "${Nigeria_GHS_W3_created_data}/Nigeria_GHS_W3_cropname_table.dta", nogen keep(3)
// drop crop_code
// gen farmer_=1
// reshape wide all_imprv_seed_ all_hybrid_seed_ farmer_, i(hhid indiv female) j(crop_name) string
// recode farmer_* (.=0)
// ren farmer_* *_farmer
// save "${Nigeria_GHS_W3_created_data}/Nigeria_GHS_W3_farmer_improvedseed_use.dta", replace
// restore
//
// collapse (max) use_*, by(hhid indiv female)
// gen all_imprv_seed_use = use_imprv_seed //Legacy
// //Temp code to get the values out faster
// /*	collapse (max) use_*, by(hhid)
// 	merge 1:1 hhid using "${Nigeria_GHS_W3_created_data}/Nigeria_GHS_W3_weights.dta", nogen keep(3)
// 	recode use* (.=0)
// 	collapse (mean) use* [aw=weight_pop_rururb] */
// //Legacy files, replacing the code below.
//
// preserve
// 	collapse (max) use_inorg_fert use_imprv_seed use_org_fert use_pest use_herb, by (hhid)
// 	la var use_inorg_fert "1= Household uses inorganic fertilizer"
// 	la var use_pest "1 = household uses pesticide"
// 	la var use_herb "1 = household uses herbicide"
// 	la var use_org_fert "1= household uses organic fertilizer"
// 	la var use_imprv_seed "1=household uses improved or hybrid seeds for at least one crop"
// 	gen use_hybrid_seed = .
// 	la var use_hybrid_seed "1=household uses hybrid seeds (not in this wave - see imprv_seed)"
// 	save "${Nigeria_GHS_W3_created_data}/Nigeria_GHS_W3_input_use.dta", replace 
// restore
//
// preserve
// 	ren use_inorg_fert all_use_inorg_fert
// 	lab var all_use_inorg_fert "1 = Individual farmer (plot manager) uses inorganic fertilizer"
// 	gen farm_manager=1 if indiv!=.
// 	recode farm_manager (.=0)
// 	lab var farm_manager "1=Indvidual is listed as a manager for at least one plot" 
// 	save "${Nigeria_GHS_W3_created_data}/Nigeria_GHS_W3_farmer_fert_use.dta", replace //This is currently used for AgQuery.
// restore
//








***************
*USE OF INORGANIC FERTILIZER -VAP/ALT, RH edited 8/6/21 
***************
use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_d_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_k_13.dta" 
gen all_use_inorg_fert=.
replace all_use_inorg_fert=0 if ag_d38==2| ag_k39==2
replace all_use_inorg_fert=1 if ag_d38==1| ag_k39==1
recode all_use_inorg_fert (.=0)
lab var all_use_inorg_fert "1 = Household uses inorganic fertilizer"

keep y2_hhid ag_d01 ag_d01_2a ag_d01_2b ag_k02 ag_k02_2a ag_k02_2b all_use_inorg_fert
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

collapse (max) all_use_inorg_fert , by(y2_hhid farmerid)
gen indiv=farmerid
drop if indiv==.
merge 1:1 y2_hhid indiv using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_gender_merge.dta", nogen

lab var all_use_inorg_fert "1 = Individual farmer (plot manager) uses inorganic fertilizer"
ren indiv indidy2
gen farm_manager=1 if farmerid!=.
recode farm_manager (.=0)
lab var farm_manager "1=Individual is listed as a manager for at least one plot" 
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_farmer_fert_use.dta", replace


*********************
*USE OF IMPROVED SEED - VAP: cannot be replicated       
*********************
/* VAP: Cannot replicate for MWI w2. Seed type is not broken down into improved and traditional in MW2. */


*********************
*REACHED BY AG EXTENSION - VAP complete, RH checked (1 question) 8/26/21   
*********************
//RH: edited to add ag_mod_t1_10, rainy vs dry season
use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_t1_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_t1_10.dta", force
//^^using append force b/c mismatch bw string and byte for variable qx_type; variable is not needed for this section
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
gen ext_reach_private=(advice_ngo==1 | advice_coop==1 | advice_pvt) //advice_pvt new addition
gen ext_reach_unspecified=(advice_neigh==1 | advice_pub==1 | advice_other==1 | advice_farmer==1 | advice_ffd==1 | advice_course==1 | advice_village==1) //RH - Re: VAP's check request - Farmer field days and courses incl. here - seems correct since we don't know who put those on, but flagging
gen ext_reach_ict=(advice_electronicmedia==1)
gen ext_reach_all=(ext_reach_public==1 | ext_reach_private==1 | ext_reach_unspecified==1 | ext_reach_ict==1)

collapse (max) ext_reach_* , by (y2_hhid)
lab var ext_reach_all "1 = Household reached by extension services - all sources"
lab var ext_reach_public "1 = Household reached by extension services - public sources"
lab var ext_reach_private "1 = Household reached by extension services - private sources"
lab var ext_reach_unspecified "1 = Household reached by extension services - unspecified sources"
lab var ext_reach_ict "1 = Household reached by extension services through ICT"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_any_ext.dta", replace

********************************************************************************
* MOBILE OWNERSHIP * //RH complete 8/26/21 - HI checked 5/2/22
********************************************************************************
//Added based on TZA w5 code

use "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_f_13.dta", clear
//recode missing to 0 in hh_g301 (0 mobile owned if missing)
recode hh_f34 (.=0)
ren hh_f34 hh_number_mobile_owned
*recode hh_number_mobile_owned (.=0) 
gen mobile_owned = 1 if hh_number_mobile_owned>0 
recode mobile_owned (.=0) // recode missing to 0
collapse (max) mobile_owned, by(y2_hhid)
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_mobile_own.dta", replace

*********************
*USE OF FORMAL FINANCIAL SERVICES -- VAP complete, RH checked 8/9/21 
*********************
use "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_f_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_s1_13.dta"
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

gen use_bank_acount=hh_f52==1
// VAP: No MM for MW2.  
// gen use_MM=hh_q01_1==1 | hh_q01_2==1 | hh_q01_3==1 | hh_q01_4==1 // use any MM services - MPESA ZPESA AIRTEL TIGO PESA. 
gen use_fin_serv_bank = use_bank_acount==1
gen use_fin_serv_credit= borrow_bank==1  | borrow_other_fin==1 // VAP: Include religious institution in this definition? No mortgage.  
// VAP: No digital and insurance in MW2
// gen use_fin_serv_insur= borrow_insurance==1
// gen use_fin_serv_digital=use_MM==1
gen use_fin_serv_others= borrow_other_fin==1
gen use_fin_serv_all=use_fin_serv_bank==1 | use_fin_serv_credit==1 |  use_fin_serv_others==1 /*use_fin_serv_insur==1 | use_fin_serv_digital==1 */ 
recode use_fin_serv* (.=0)

collapse (max) use_fin_serv_*, by (y2_hhid)
lab var use_fin_serv_all "1= Household uses formal financial services - all types"
lab var use_fin_serv_bank "1= Household uses formal financial services - bank account"
lab var use_fin_serv_credit "1= Household uses formal financial services - credit"
// lab var use_fin_serv_insur "1= Household uses formal financial services - insurance"
// lab var use_fin_serv_digital "1= Household uses formal financial services - digital"
lab var use_fin_serv_others "1= Household uses formal financial services - others"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_fin_serv.dta", replace

************
*MILK PRODUCTIVITY - VAP/ALT complete, TK Revised 11/21/2023
************
*Total production
//RH: only cow milk in MWI, not including large ruminant variables
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_s_13.dta", clear
rename ag_s0a product_code
keep if product_code==401
rename ag_s02 milk_months_produced // VAP: During the last 12 months, for how many months did your household produce any [PRODUCT]? (rh edited)
rename ag_s03a liters_month // VAP: During these months, what was the average quantity of [PRODUCT] produced PER MONTH?. (RH renamed to be more consistent with TZA (from qty_milk_per_month to liters_month))
drop if ag_s03b ==.
gen milk_quantity_produced = milk_months_produced * liters_month if ag_s03b==1 // VAP: Only including liters, not including 2 obsns in "buckets". 
lab var milk_quantity_produced "Number of months that the household produced milk" // TK: Aligned naming to NGA Wave 3

lab var  milk_months_produced "Average quantity of milk produced per month - liters"
drop if milk_months_produced==.
keep y2_hhid product_code  milk_quantity_produced milk_months_produced
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_milk_animals.dta", replace


************
*EGG PRODUCTIVITY - VAP complete, RH checked
************
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_r1_13.dta", clear
rename ag_r0a lvstckid
gen poultry_owned = ag_r02 if inlist(lvstckid, 311, 313, 315, 318, 319, 3310, 3314) // For MW2: local hen, local cock, duck, other, dove/pigeon, chicken layer/chicken-broiler and turkey/guinea fowl
collapse (sum) poultry_owned, by(y2_hhid)
tempfile eggs_animals_hh 
save `eggs_animals_hh'

use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_s_13.dta", clear
rename ag_s0a product_code
keep if product_code==402 | product_code==403
rename ag_s02 eggs_months_produced // # of months in past year that hh. produced eggs
rename ag_s03a eggs_quantity_produced  // avg. qty of eggs per month in past year
rename ag_s03b quantity_month_unit
replace quantity_month = round(quantity_month/0.06) if product_code==402 & quantity_month_unit==2 // VAP: converting obsns in kgs to pieces for eggs 
// using MW IHS Food Conversion factors.pdf. Cannot convert ox-cart & ltrs for eggs 
replace quantity_month_unit = 3 if product_code== 402 & quantity_month_unit==2    
replace quantity_month_unit =. if product_code==402 & quantity_month_unit!=3        // VAP: chicken eggs, pieces
replace quantity_month_unit =. if product_code== 403 & quantity_month_unit!=3      // guinea fowl eggs, pieces
recode eggs_months_produced eggs_quantity_produced (.=0)
collapse (sum) eggs_quantity_produced (max) eggs_months_produced, by (y2_hhid) // VAP: Collapsing chicken & guinea fowl eggs
gen eggs_total_year = eggs_months_produced* eggs_quantity_produced // Units are pieces for eggs 
merge 1:1 y2_hhid using  `eggs_animals_hh', nogen keep(1 3)			
keep y2_hhid eggs_months_produced eggs_quantity_produced eggs_total_year poultry_owned 

lab var eggs_months_produced "Number of months eggs were produced (household)"
lab var eggs_quantity_produced "Number of eggs that were produced per month (household)"
lab var eggs_total_year "Total number of eggs that was produced in a year (household)"
lab var poultry_owned "Total number of poultry owned (household)"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_eggs_animals.dta", replace



************
*LAND RENTAL 
************

* Rainy Season *
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_c_13.dta", clear		
rename ag_c00 plot_id
gen area_acres_est = ag_c04a if ag_c04b == 1
replace area_acres_est = (ag_c04a*2.47105) if ag_c04b == 2 & area_acres_est ==.  // ha to acres
replace area_acres_est = (ag_c04a*0.000247105) if ag_c04b == 3 & area_acres_est ==. // m-sq to acres
gen area_acres_meas = ag_c04c
keep if area_acres_est !=.
gen area_est_hectares=area_acres_est* (1/2.47105)  // farmer estimated
gen area_meas_hectares= area_acres_meas* (1/2.47105) // GPS area
keep y2_hhid plot_id area_est_hectares area_meas_hectares
lab var area_meas_hectares "Plot area in hectares (GPSd)"
lab var area_est_hectares "Plot area in hectares (estimated)"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_area_rainyseason.dta", replace


*Getting plot rental rate
use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_d_13.dta", clear
rename ag_d00 plot_id
merge 1:1 plot_id y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_area_rainyseason.dta" , nogen		
drop if plot_id=="" 
gen cultivated = ag_d14==1
merge m:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_decision_makers.dta", nogen keep (1 3)

tab ag_d12 // VAP: Periods of time covered: Rainy season, full year, other
gen rental_cost_land_cshpd = ag_d11a //rainy season, cash already paid
gen rental_cost_land_kindpd = ag_d11b //rainy season, in-kind already paid
gen rental_cost_land_cshfut = ag_d11c //rainy season, future cash payment owed
gen rental_cost_land_kindfut = ag_d11d //rainy season,in-kind payment owed
recode rental_cost_land_cshpd rental_cost_land_kindpd rental_cost_land_cshfut rental_cost_land_kindfut (.=0)
gen plot_rental_rate = rental_cost_land_cshpd + rental_cost_land_kindpd + rental_cost_land_cshfut + rental_cost_land_kindfut
recode plot_rental_rate (0=.) 
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_rent_nomiss_rainyseason.dta", replace

preserve
	gen value_rented_land_male = plot_rental_rate if dm_gender==1
	gen value_rented_land_female = plot_rental_rate if dm_gender==2
	// gen value_rented_land_mixed = plot_rental_rate if dm_gender==3
	collapse (sum) value_rented_land_* value_rented_land = plot_rental_rate, by(y2_hhid)
	lab var value_rented_land_male "Value of rented land (male-managed plot)
	lab var value_rented_land_female "Value of rented land (female-managed plot)
	// lab var value_rented_land_mixed "Value of rented land (mixed-managed plot)"
	save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_rental_rate_rainyseason.dta", replace
restore
 
gen ha_rental_rate_hh = plot_rental_rate/area_meas_hectares
preserve
	keep if plot_rental_rate!=. & plot_rental_rate!=0			
	collapse (sum) plot_rental_rate area_meas_hectares, by(y2_hhid)		
	gen ha_rental_hh_rs = plot_rental_rate/area_meas_hectares				
	keep ha_rental_hh_rs y2_hhid
	lab var ha_rental_hh_rs "Area of rented plot during the rainy season"
	save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_rental_rate_hhid_rainyseason.dta", replace
restore

*Merging in geographic variables
merge m:1 y2_hhid using "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_a_filt_13.dta", nogen assert(2 3) keep(3)
rename hh_a10a ta
rename ea ea	
*Geographic medians
bys region district ta ea: egen ha_rental_count_ea = count(ha_rental_rate_hh) // region, district, ta, ea (TZ had ward & village instead of ta & EA)
bys region district ta ea: egen ha_rental_rate_ea = median(ha_rental_rate_hh)

bys region district ta: egen ha_rental_count_TA = count(ha_rental_rate_hh)
bys region district ta: egen ha_rental_rate_TA = median(ha_rental_rate_hh)

bys region district: egen ha_rental_count_dist = count(ha_rental_rate_hh)
bys region district: egen ha_rental_rate_dist = median(ha_rental_rate_hh)

bys region: egen ha_rental_count_reg = count(ha_rental_rate_hh)
bys region: egen ha_rental_rate_reg = median(ha_rental_rate_hh)

egen ha_rental_rate_nat = median(ha_rental_rate_hh)
*Now, getting median rental rate at the lowest level of aggregation with at least ten observations
gen ha_rental_rate = ha_rental_rate_ea if ha_rental_count_ea>=10		
replace ha_rental_rate = ha_rental_rate_TA if ha_rental_count_TA>=10 & ha_rental_rate==.	
replace ha_rental_rate = ha_rental_rate_dist if ha_rental_count_dist>=10 & ha_rental_rate==.	
replace ha_rental_rate = ha_rental_rate_reg if ha_rental_count_reg>=10 & ha_rental_rate==.		
replace ha_rental_rate = ha_rental_rate_nat if ha_rental_rate==.				
collapse (firstnm) ha_rental_rate, by(region district ta ea)
lab var ha_rental_rate "Land rental rate per ha"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_rental_rate_rainyseason.dta", replace


* Dry Season *  
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_j_13.dta", clear		
rename ag_j00 plot_id
gen area_acres_est = ag_j05a if ag_j05b == 1
replace area_acres_est = (ag_j05a*0.000247105) if ag_j05b == 3 & area_acres_est ==. // m-sq to acres
gen area_acres_meas = ag_j05c
keep if area_acres_est !=.
gen area_est_hectares=area_acres_est* (1/2.47105)  // farmer estimated
gen area_meas_hectares= area_acres_meas* (1/2.47105) // GPS area
keep y2_hhid plot_id area_est_hectares area_meas_hectares
lab var area_meas_hectares "Plot area in hectares (GPSd)"
lab var area_est_hectares "Plot area in hectares (estimated)"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_area_dryseason.dta", replace
*Getting plot rental rate 
use "${Malawi_IHPS_W2_raw_data}/Agriculture/ag_mod_k_13.dta", clear
rename ag_k00 plot_id
drop if plot_id=="" 
gen cultivated = ag_k15==1
merge m:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_decision_makers.dta", nogen keep (1 3)
merge 1:1 plot_id y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_area_dryseason.dta" , nogen
// merge 1:1 plot_id y2_hhid using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_plot_area_rainyseason.dta", nogen update replace		

gen rental_cost_land_cshpd = ag_k12a //dry season, cash already paid
gen rental_cost_land_kindpd = ag_k12b //dry season, in-kind already paid
gen rental_cost_land_cshfut = ag_k12c //dry season, future cash payment owed
gen rental_cost_land_kindfut = ag_k12d //dry season,in-kind payment owed
recode rental_cost_land_cshpd rental_cost_land_kindpd rental_cost_land_cshfut rental_cost_land_kindfut (.=0)
gen plot_rental_rate = rental_cost_land_cshpd + rental_cost_land_kindpd + rental_cost_land_cshfut + rental_cost_land_kindfut
recode plot_rental_rate (0=.) 
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_rent_nomiss_dryseason.dta", replace

preserve
	gen value_rented_land_male = plot_rental_rate if dm_gender==1
	gen value_rented_land_female = plot_rental_rate if dm_gender==2
	// gen value_rented_land_mixed = plot_rental_rate if dm_gender==3
	collapse (sum) value_rented_land_* value_rented_land = plot_rental_rate, by(y2_hhid)
	lab var value_rented_land_male "Value of rented land (male-managed plot)"
	lab var value_rented_land_female "Value of rented land (female-managed plot)"
	// lab var value_rented_land_mixed "Value of rented land (mixed-managed plot)"
	save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_rental_rate_dryseason.dta", replace
restore
 
gen ha_rental_rate_hh = plot_rental_rate/area_meas_hectares
preserve
	keep if plot_rental_rate!=. & plot_rental_rate!=0			
	collapse (sum) plot_rental_rate area_meas_hectares, by(y2_hhid)		
	gen ha_rental_hh_ds = plot_rental_rate/area_meas_hectares				
	keep ha_rental_hh_ds y2_hhid
	lab var ha_rental_hh_ds "Area of rented plot during the dry season"
	save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_rental_rate_hhid_dryseason.dta", replace
restore

*Merging in geographic variables
merge m:1 y2_hhid using "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_a_filt_13.dta", nogen assert(2 3) keep(3)
rename hh_a10a ta
rename ea ea

*Geographic medians
bys region district ta ea: egen ha_rental_count_ea = count(ha_rental_rate_hh) // region, district, ta, ea (TZ had ward & village instead of ta & EA)
bys region district ta ea: egen ha_rental_rate_ea = median(ha_rental_rate_hh)

bys region district ta: egen ha_rental_count_TA = count(ha_rental_rate_hh)
bys region district ta: egen ha_rental_rate_TA = median(ha_rental_rate_hh)

bys region district: egen ha_rental_count_dist = count(ha_rental_rate_hh)
bys region district: egen ha_rental_rate_dist = median(ha_rental_rate_hh)

bys region: egen ha_rental_count_reg = count(ha_rental_rate_hh)
bys region: egen ha_rental_rate_reg = median(ha_rental_rate_hh)

egen ha_rental_rate_nat = median(ha_rental_rate_hh)
*Now, getting median rental rate at the lowest level of aggregation with at least ten observations
gen ha_rental_rate = ha_rental_rate_ea if ha_rental_count_ea>=10		
replace ha_rental_rate = ha_rental_rate_TA if ha_rental_count_TA>=10 & ha_rental_rate==.	
replace ha_rental_rate = ha_rental_rate_dist if ha_rental_count_dist>=10 & ha_rental_rate==.	
replace ha_rental_rate = ha_rental_rate_reg if ha_rental_count_reg>=10 & ha_rental_rate==.		
replace ha_rental_rate = ha_rental_rate_nat if ha_rental_rate==.		
collapse (firstnm) ha_rental_rate, by(region district ta ea)
lab var ha_rental_rate "Land rental rate per ha in dry season"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_rental_rate_dryseason.dta", replace

*Now getting total ha of all plots that were cultivated at least once 
                                     
append using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_rent_nomiss_dryseason.dta"
collapse (max) cultivated area_meas_hectares, by(y2_hhid plot_id)		// collapsing down to household-plot level
gen ha_cultivated_plots = area_meas_hectares if cultivate==1			// non-missing only if plot was cultivated in at least one season
collapse (sum) ha_cultivated_plots, by(y2_hhid)				// total ha of all plots that were cultivated in at least one season
lab var ha_cultivated_plots "Area of cultivated plots (ha)"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_cultivated_plots_ha.dta", replace

use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_rental_rate_rainyseason.dta", clear
append using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_rental_rate_dryseason.dta"
collapse (sum) value_rented_land*, by(y2_hhid)		// total over BOTH seasons (total spent on rent over course of entire year)
lab var value_rented_land "Value of rented land (household expenditures)"
lab var value_rented_land_male "Value of rented land (household expenditures - male-managed plots)"
lab var value_rented_land_female "Value of rented land (household expenditures - female-managed plots)"
// lab var value_rented_land_mixed "Value of rented land (household expenditures - mixed-managed plots)"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_rental_rate.dta", replace

*Now getting area planted 
*  Rainy Season *
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_g_13.dta", clear
drop if ag_g00==""
ren ag_g00 plot_id
merge m:1 y2_hhid plot_id using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_rent_nomiss_rainyseason.dta", nogen keep(1 3)

*First rescaling
gen percent_plot = 1 if ag_g02==1 // VAP: "Was crop planted in entire area of plot"
replace percent_plot = 0.125*(ag_g03==1) + 0.25*(ag_g03==2) + 0.5*(ag_g03==3) + 0.75*(ag_g03==4) + 0.875*(ag_g03==5) if ag_g02==2 // VAP: Created 2 new categories for < 1/4 & >3/4. "Approx how much of plot was planted with [crop]"
bys y2_hhid plot_id: egen total_percent_plot = total(percent_plot)		
replace percent_plot = percent_plot*(1/total_percent_plot) if total_percent_plot>1 & total_percent_plot!=.	


*AGRICULTURAL WAGES					Malawi_IHPS_W2_ag_wage.dta 

************
*AGRICULTURAL WAGES - RH FLAG
************
*RH note: no equivalent dta file - module d (rainy) k (dry) have plot details
*use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
*append using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta"
* The survey reports total wage paid and amount of hired labor: wage=total paid/ amount of labor
/* ALT 11.6.23: Needs review
*Rainy Season - Module D
use "${Malawi_IHPS_W2_raw_data}/Agriculture/AG_MOD_D_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}/Agriculture/AG_MOD_D_13.dta"

*this has rainy season plot details 

* The survey reports total wage paid and amount of hired labor: wage=total paid/ amount of labor
* set wage paid to . if zero or negative
recode ag_d48a (0=.) /* set hired 0 days to missing */
ren ag_d48a hired_male_lanprep
replace hired_male_lanprep = ag3b_74_2 if hired_male_lanprep==.
*FLAG - stopped here. Need to figure out how .10 and .13 relate to each other before setting missing to .13 variable (also they have the same name). 


*Dry Season - Module K
use "${Malawi_IHPS_W2_raw_data}/Agriculture/AG_MOD_K_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}/Agriculture/AG_MOD_K_13.dta"
*/
************
*WOMEN'S DIET QUALITY
************
*Women's diet quality: proportion of women consuming nutrient-rich foods (%)
*Information not available


************
*HOUSEHOLD'S DIET DIVERSITY SCORE - TK Checked 2/5/24
************
* Malawi LSMS 2 does not report individual consumption but instead household level consumption of various food items.
* Thus, only the proportion of households eating nutritious food can be estimated
use "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_g1_13.dta" , clear
ren hh_g02 itemcode
* recode food items to map HDDS food categories
recode itemcode 	(101/117 						=1	"CEREALS" )  //// VAP: Also includes biscuits, buns, scones
					(201/209    					=2	"WHITE ROOTS,TUBERS AND OTHER STARCHES"	)  ////
					(401/414	 					=3	"VEGETABLES"	)  ////	
					(601/610						=4	"FRUITS"	)  ////	
					(504/512 515					=5	"MEAT"	)  ////	VAP: 512: Tinned meat or fish, included in meat				
					(501 						    =6	"EGGS"	)  ////
					(502/503 513/514				=7  "FISH") ///
					(301/310						=8	"LEGUMES, NUTS AND SEEDS") ///
					(701/709						=9	"MILK AND MILK PRODUCTS")  ////
					(801/804  						=10	"OILS AND FATS"	)  ////
					(815/817 						=11	"SWEETS"	)  //// 
					(901/916  810/814 818			=14 "SPICES, CONDIMENTS, BEVERAGES"	)  ////
					,generate(Diet_ID)
				
gen adiet_yes=(hh_g01==1)
ta Diet_ID   
** Now, collapse to food group level; household consumes a food group if it consumes at least one item
collapse (max) adiet_yes, by(y2_hhid Diet_ID) 
label define YesNo 1 "Yes" 0 "No"
label val adiet_yes YesNo
* Now, estimate the number of food groups eaten by each individual
collapse (sum) adiet_yes, by(y2_hhid )
ren adiet_yes number_foodgroup 
sum number_foodgroup 
local cut_off1=6
local cut_off2=round(r(mean))
gen household_diet_cut_off1=(number_foodgroup>=`cut_off1')
gen household_diet_cut_off2=(number_foodgroup>=`cut_off2')
lab var household_diet_cut_off1 "1= household consumed at least `cut_off1' of the 12 food groups last week" 
lab var household_diet_cut_off2 "1= household consumed at least `cut_off2' of the 12 food groups last week" 
label var number_foodgroup "Number of food groups individual consumed last week HDDS"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_household_diet.dta", replace
 
 
 
************
*WOMEN'S OWNERSHIP OF ASSETS - TK Checked 2/5/24
************
* Code as 1 if a woman is sole or joint owner of any specified productive asset; 
* can report on % of women who own, taking total number of women HH members as denominator
* MLW W2 asked to list up to 2 owners.
* Indicator may be biased downward if some women would have been not listed among the two the first 2 asset-owners can also claim ownership of some assets
*First, append all files with information on asset ownership
use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear //rainy
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_k_13.dta" //dry
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_r1_13.dta"
gen type_asset=""
gen asset_owner1=.
gen asset_owner2=.
* Ownership of land.
replace type_asset="landowners" if  !inlist( ag_d04a, .,0,99) |  !inlist( ag_d04b, .,0,99) 
replace asset_owner1=ag_d04a if !inlist( ag_d04a, .,0,99)  
replace asset_owner2=ag_d04b if !inlist( ag_d04b, .,0,99)

replace type_asset="landowners" if  !inlist( ag_k05a, .,0,99) |  !inlist( ag_k05b, .,0,99) 
replace asset_owner1=ag_k05a if !inlist( ag_k05a, .,0,99)  
replace asset_owner2=ag_k05b if !inlist( ag_k05b, .,0,99)

* append who has right to sell or use
preserve
replace type_asset="landowners" if  !inlist( ag_d04_2a, .,0,99) |  !inlist( ag_d04_2b, .,0,99) 
replace asset_owner1=ag_d04_2a if !inlist( ag_d04_2a, .,0,99)  
replace asset_owner2=ag_d04_2b if !inlist( ag_d04_2b, .,0,99)

replace type_asset="landowners" if  !inlist( ag_k05_2a, .,0,99) |  !inlist( ag_k05_2b, .,0,99) 
replace asset_owner1=ag_k05_2a if !inlist( ag_k05_2a, .,0,99)  
replace asset_owner2=ag_k05_2b if !inlist( ag_k05_2b, .,0,99)
keep if !inlist( ag_d04_2a, .,0,99) |  !inlist( ag_d04_2b, .,0,99)   | !inlist( ag_k05_2a, .,0,99) |  !inlist( ag_k05_2b, .,0,99) 
keep y2_hhid type_asset asset_owner*
tempfile land2
save `land2'
restore
append using `land2'  

*non-poultry livestock (keeps/manages)
replace type_asset="livestockowners" if  !inlist( ag_r05a, .,0,99) |  !inlist( ag_r05b, .,0,99)  
replace asset_owner1=ag_r05a if !inlist( ag_r05a, .,0,99)  
replace asset_owner2=ag_r05b if !inlist( ag_r05b, .,0,99)
* non-farm equipment,  large durables/appliances, mobile phone
* SECTION M: FARM IMPLEMENTS, MACHINERY, AND STRUCTURES - does not report who in the household own them) 
* No ownership of non-farm equipment,  large durables/appliances, mobile phone
keep y2_hhid type_asset asset_owner1 asset_owner2  
preserve
keep y2_hhid type_asset asset_owner2
drop if asset_owner2==.
ren asset_owner2 asset_owner
tempfile asset_owner2
save `asset_owner2'
restore
keep y2_hhid type_asset asset_owner1
drop if asset_owner1==.
ren asset_owner1 asset_owner
append using `asset_owner2'
gen own_asset=1 
collapse (max) own_asset, by(y2_hhid asset_owner)
ren asset_owner indiv
* Now merge with member characteristics
merge 1:1 y2_hhid indiv  using  "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_person_ids.dta", nogen 
recode own_asset (.=0)
lab var own_asset "1=invidual owns an assets (land or livestock)"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_ownasset.dta", replace

********************************************************************************
*WOMEN'S PARTICIPATION IN AGRICULTURAL DECISION MAKING - TK Revised
********************************************************************************
*	Code as 1 if a woman is listed as one of the decision-makers for at least 2 plots, crops, or livestock activities; 
*	can report on % of women who make decisions, taking total number of women HH members as denominator
*	In most cases, MLW LSMS 4 lists the first TWO decision makers.
*	Indicator may be biased downward if some women would participate in decisions but are not listed among the first two
* first append all files related to agricultural activities with income in who participate in the decision making

use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_k_13.dta" 
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_g_13.dta"
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_m_13.dta"
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_i_13.dta"
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_o_13.dta"
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_p_13.dta"
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_q_13.dta"
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_r1_13.dta"
gen type_decision="" 
gen decision_maker1=.
gen decision_maker2=.
gen decision_maker3=.

* planting_input - Makes decision about plot Rainy Season
*Decisions concerning the timing of cropping activities, crop choice and input use on the [PLOT]
replace type_decision="planting_input" if !inlist(ag_d01, .,0,99) | !inlist(ag_d01_2a, .,0,99) | !inlist(ag_d01_2b, .,0,99)
replace decision_maker1=ag_d01 if !inlist(ag_d01, .,0,99, 98)
replace decision_maker2=ag_d01_2a if !inlist(ag_d01_2a, .,0,99, 98)
replace decision_maker3=ag_d01_2b if !inlist(ag_d01_2b, .,0,99, 98)

* Makes decision about plot dry Season
replace type_decision="planting_input" if !inlist(ag_k02, .,0,99) | !inlist(ag_k02_2a, .,0,99) | !inlist(ag_k02_2b, .,0,99)
replace decision_maker1=ag_k02 if !inlist(ag_k02, .,0,99, 98) 
replace decision_maker2=ag_k02_2a if !inlist(ag_k02_2a, .,0,99, 98) 
replace decision_maker2=ag_k02_2b if !inlist(ag_k02_2b, .,0,99, 98)  

* append who make decision about (owner plot) rainy
preserve
replace type_decision="planting_input" if !inlist(ag_d03_2a, .,0,99) | !inlist(ag_d03_2b, .,0,99) //| !inlist(ag_d04a, .,0,99) | !inlist(ag_d04b, .,0,99)
replace decision_maker1=ag_d03_2a if !inlist(ag_d03_2a, .,0,99, 98) 
replace decision_maker2=ag_d03_2b if !inlist(ag_d03_2b, .,0,99, 98) 
* append who make decision about (owner plot) dry
replace type_decision="planting_input" if !inlist(ag_k04_2a, .,0,99) | !inlist(ag_k04_2b, .,0,99) //| !inlist(ag_k05a, .,0,99) | !inlist(ag_k05b, .,0,99)
replace decision_maker1=ag_k04_2a if !inlist(ag_k04_2a, .,0,99, 98) 
replace decision_maker2=ag_k04_2b if !inlist(ag_k04_2b, .,0,99, 98) 

keep if !inlist(ag_d03_2a, .,0,99) | !inlist(ag_d03_2b, .,0,99) | !inlist(ag_k04_2a, .,0,99) | !inlist(ag_k04_2b, .,0,99)

keep y2_hhid type_decision decision_maker*
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

* sales_annualcrop
replace type_decision="sales_annualcrop" if !inlist(ag_i12_1a, .,0,99) | !inlist(ag_i12_1b, .,0,99)
replace decision_maker1=ag_i12_1a if !inlist(ag_i12_1a, .,0,99) 
replace decision_maker2=ag_i21_1a if !inlist(ag_i12_1b, .,0,99) 

replace type_decision="sales_annualcrop" if !inlist(ag_i21_1a, .,0,99) | !inlist(ag_i21_1b, .,0,99)
replace decision_maker1=ag_i21_1a if !inlist(ag_i21_1a, .,0,99) 
replace decision_maker2=ag_i21_1b if !inlist(ag_i21_1b, .,0,99)

* append who negotiate sale to customer 2
preserve
replace type_decision="sales_annualcrop" if !inlist(ag_o12_1a, .,0,99) | !inlist(ag_o12_1b, .,0,99)
replace decision_maker1=ag_o12_1a if !inlist(ag_o12_1a, .,0,99) 
replace decision_maker2=ag_o21_1a if !inlist(ag_o12_1b, .,0,99) 

replace type_decision="sales_annualcrop" if !inlist(ag_o21_1a, .,0,99) | !inlist(ag_o21_1b, .,0,99)
replace decision_maker1=ag_o21_1a if !inlist(ag_o21_1a, .,0,99) 
replace decision_maker2=ag_o21_1b if !inlist(ag_o21_1b, .,0,99)
keep if !inlist(ag_o12_1a, .,0,99) | !inlist(ag_o12_1b, .,0,99) | !inlist(ag_o21_1a, .,0,99) | !inlist(ag_o21_1b, .,0,99)
keep y2_hhid type_decision decision_maker* 
tempfile sales_annualcrop2
save `sales_annualcrop2'
restore
append using `sales_annualcrop2' 

keep y2_hhid type_decision decision_maker1 decision_maker2 decision_maker3
preserve
keep y2_hhid type_decision decision_maker2
drop if decision_maker2==.
ren decision_maker2 decision_maker
tempfile decision_maker2
save `decision_maker2'
restore
preserve
keep y2_hhid type_decision decision_maker3
drop if decision_maker3==.
ren decision_maker3 decision_maker
tempfile decision_maker3
save `decision_maker3'
restore
keep y2_hhid type_decision decision_maker1
drop if decision_maker1==.
ren decision_maker1 decision_maker
append using `decision_maker2'
append using `decision_maker3'
* number of time appears as decision maker
bysort y2_hhid decision_maker : egen nb_decision_participation=count(decision_maker)
drop if nb_decision_participation==1
gen make_decision_crop=1 if  type_decision=="planting_input" ///
							| type_decision=="harvest" ///
							| type_decision=="sales_annualcrop" ///
							| type_decision=="sales_processcrop"
recode 	make_decision_crop (.=0)
gen make_decision_livestock=1 if  type_decision=="livestockowners"   
recode 	make_decision_livestock (.=0)
gen make_decision_ag=1 if make_decision_crop==1 | make_decision_livestock==1
recode 	make_decision_ag (.=0)
collapse (max) make_decision_* , by(y2_hhid decision_maker )  //any decision
ren decision_maker indiv 
* Now merge with member characteristics
merge 1:1 y2_hhid indiv  using  "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_person_ids.dta", nogen // 4,747   matched
* 1 member ID in decision files not in member list
recode make_decision_* (.=0)
lab var make_decision_crop "1=invidual makes decision about crop production activities"
lab var make_decision_livestock "1=invidual makes decision about livestock production activities"
lab var make_decision_ag "1=invidual makes decision about agricultural (crop or livestock) production activities"

save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_make_ag_decision.dta", replace


************
*WOMEN'S CONTROL OVER INCOME TK Revised
************
*Code as 1 if a woman is listed as one of the decision-makers for at least 1 income-related area; 
*can report on % of women who make decisions, taking total number of women HH members as denominator
*In most cases, MW LSMS 2 lists the first TWO decision makers.
*Indicator may be biased downward if some women would participate in decisions about the use of income
*but are not listed among the first two
 

/*
Areas of decision making to be considered
Decision-making areas
*Control over crop production income
*Control over livestock production income
*Control over fish production income
*Control over farm (all) production income
*Control over wage income
*Control over business income
*Control over nonfarm (all) income
*Control over (all) income
		
VAP: TZ-4 and MW-2 both also include 
	* Control over remittance income
	* Control over income from [program] assistance (social safety nets)

VAP: Added the following to the indicator construction for MW2
	* Control over other income (cash & in-kind transfers from individuals, pension, rental, asset sale, lottery, inheritance)	
*/

* First append all files with information on who control various types of income


use "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_d_13.dta", clear
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_k_13.dta" 
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_g_13.dta"
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_m_13.dta"
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_r1_13.dta"

* Control over Crop production income
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_i_13.dta"  // control over crop sale earnings rainy season
// append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_ba_13.dta" // control over crop sale earnings rainy season
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_o_13.dta" // control over crop sale earnings dry season
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_p_13.dta"

append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_q_13.dta" // control over permanent crop sale earnings 

append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_r1_13.dta"
* Control over Livestock production income
append using "${Malawi_IHPS_W2_raw_data}\Agriculture\ag_mod_s_13.dta" // control over livestock product sale earnings
* Control over wage income
append using "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_e_13.dta" // control over salary payment, allowances/gratuities, ganyu labor earnings 
* Control over business income
append using "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_n2_13.dta" // household enterprise ownership
* Control over program assistance 
append using "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_r_13.dta"
* Control over other income 
append using "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_p_13.dta"
* Control over remittances
append using "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_o_13.dta"
gen type_decision="" 
gen controller_income1=. 
gen controller_income2=.


/* No question in MW2
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
replace controller_income1= ag_m13a if !inlist( ag_m13a, .,0,99)  
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
replace type_decision="control_annualsales" if  !inlist( ag_o23a, .,0,99) |  !inlist( ag_o23b, .,0,99) 
replace controller_income1=ag_o23a if !inlist( ag_o23a, .,0,99)  
replace controller_income2=ag_o23b if !inlist( ag_o23b, .,0,99)
keep if !inlist( ag_i23a, .,0,99) |  !inlist( ag_i23b, .,0,99)  | !inlist( ag_o23a, .,0,99) |  !inlist( ag_o23b, .,0,99) 
keep y2_hhid type_decision controller_income1 controller_income2
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
control_processedsales
*/

* livestock_sales (products- Milk, egges, Meat) 
replace type_decision="control_livestocksales" if  !inlist( ag_s07a, .,0,99) |  !inlist( ag_s07b, .,0,99) 
replace controller_income1=ag_s07a if !inlist( ag_s07a, .,0,99)  
replace controller_income2=ag_s07b if !inlist( ag_s07b, .,0,99)

/* No questions in MW2 
append who controls earning from livestock_sales (slaughtered)
 
* control milk_sales

* control control_otherlivestock_sales

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
keep y2_hhid type_decision controller_income1 controller_income2
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
keep if !inlist( hh_e42_1a, .,0,99) |  !inlist(hh_e42_1b , .,0,99)  //ALT 10.22.19: fixed typo, first hh_e42_1b -> hh_e42_1a
keep y2_hhid type_decision controller_income1 controller_income2
tempfile allowances2
save `allowances2'
restore
append using `allowances2'

* control_ganyu
replace type_decision="control_ganyu" if  !inlist(hh_e59_1a , .,0,99) |  !inlist(hh_e59_1b , .,0,99) 
replace controller_income1= hh_e59_1a if !inlist( hh_e59_1a, .,0,99)  
replace controller_income2= hh_e59_1b if !inlist( hh_e59_1b, .,0,99)

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
keep y2_hhid type_decision controller_income1 controller_income2
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

keep y2_hhid type_decision controller_income1 controller_income2
 
preserve
keep y2_hhid type_decision controller_income2
drop if controller_income2==.
ren controller_income2 controller_income
tempfile controller_income2
save `controller_income2'
restore
keep y2_hhid type_decision controller_income1
drop if controller_income1==.
ren controller_income1 controller_income
append using `controller_income2'
 
* create group


gen control_cropincome=1 if type_decision=="control_annualharvest" ///
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
																					
gen control_nonfarmincome=1 if  type_decision=="control_remittance" ///
							  | type_decision=="control_assistance" ///
							  | type_decision=="control_otherincome" /// VAP: additional in MW2
							  | control_salaryincome== 1 /// VAP: additional in MW2
							  | control_businessincome== 1 
recode 	control_nonfarmincome (.=0)
																		
collapse (max) control_* , by(y2_hhid controller_income )  //any decision
gen control_all_income=1 if  control_farmincome== 1 | control_nonfarmincome==1
recode 	control_all_income (.=0)															
ren controller_income indiv
*	Now merge with member characteristics
merge 1:1 y2_hhid indiv  using  "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_person_ids.dta", nogen keep (3) // 6,445  matched

recode control_* (.=0)
lab var control_cropincome "1=individual has control over crop income"
lab var control_livestockincome "1=individual has control over livestock income"
lab var control_farmincome "1=individual has control over farm (crop or livestock) income"
lab var control_businessincome "1=individual has control over business income"
lab var control_salaryincome "1= individual has control over salary income"
lab var control_nonfarmincome "1=individual has control over non-farm (business, salary, assistance, remittances or other income) income"
lab var control_all_income "1=individual has control over at least one type of income"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_control_income.dta", replace



********************************************************************************
*CROP YIELDS*
********************************************************************************

//Integrated from NGA W3
use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_all_plots.dta", clear
gen number_trees_planted_banana = number_trees_planted if crop_code == 55
recode crop_code (52 53 54 56 57 58 59 60 61 62 63 64=100) // recode to "other fruit":  mango, orange, papaya, avocado, guava, lemon, tangerine, peach, poza, masuku, masau, pineapple
gen number_trees_planted_other_fruit = number_trees_planted if crop_code == 100
gen number_trees_planted_cassava = number_trees_planted if crop_code == 49
gen number_trees_planted_tea = number_trees_planted if crop_code == 50
gen number_trees_planted_coffee = number_trees_planted if crop_code == 51 
recode number_trees_planted_banana number_trees_planted_other_fruit number_trees_planted_cassava number_trees_planted_tea number_trees_planted_coffee (.=0)
collapse (sum) number_trees_planted*, by(y2_hhid)
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_trees.dta", replace

use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_all_plots.dta", clear
collapse (sum) area_harv_=ha_harvest area_plan_=ha_planted harvest_=quant_harv_kg, by(y2_hhid dm_gender purestand crop_code)
drop if purestand == .
gen mixed = "inter" if purestand==0
replace mixed="pure" if purestand==1
gen dm_gender2="male"
replace dm_gender2="female" if dm_gender==2
replace dm_gender2="mixed" if dm_gender==3
drop dm_gender purestand
duplicates tag y2_hhid dm_gender2 crop_code mixed, gen(dups) // temporary measure while we work on plot_decision_makers
drop if dups > 0 // temporary measure while we work on plot_decision_makers
drop dups
reshape wide harvest_ area_harv_ area_plan_, i(y2_hhid dm_gender2 crop_code) j(mixed) string
ren area* area*_
ren harvest* harvest*_
reshape wide harvest* area*, i(y2_hhid crop_code) j(dm_gender2) string
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

use "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hhids.dta", clear
merge 1:m y2_hhid using `areas_sans_hh', keep(1 3) nogen
drop ea stratum weight district ta rural region

save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_crop_area_plan.dta", replace // temporary measure while we work on plot_decision_makers

*Total planted and harvested area summed accross all plots, crops, and seasons.
preserve
	collapse (sum) all_area_harvested=area_harv all_area_planted=area_plan, by(y2_hhid)
	replace all_area_harvested=all_area_planted if all_area_harvested>all_area_planted & all_area_harvested!=.
	save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_area_planted_harvested_allcrops.dta", replace
restore
keep if inlist(crop_code, $comma_topcrop_area)
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_crop_harvest_area_yield.dta", replace

**Yield at the household level

**# Bookmark #1
*Value of crop production
merge m:1 crop_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_cropname_table.dta", nogen keep(1 3) // 4,395 matched, 17,088 not matched (Master) 
merge 1:1 y2_hhid crop_code using "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_crop_values_production.dta", nogen keep(1 3) // NEED TO FINISH GROSS CROP REVENUE
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
reshape wide `vars', i(y2_hhid) j(crop_name) string
merge 1:1 y2_hhid using "${Malawi_IHPS_W2_created_data}}/Malawi_IHPS_W2_trees.dta"
collapse (sum) harvest* area_harv*  area_plan* total_planted_area* total_harv_area* kgs_harvest*   value_harv* value_sold* number_trees_planted*  , by(y2_hhid) 
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

//drop if y2_hhid== 200156 | y2_hhid==200190 | y2_hhid==310091 // households that have an area planted or harvested but indicated that they rented out or did not cultivate 
foreach p of global topcropname_area {
	gen grew_`p'=(total_harv_area_`p'!=. & total_harv_area_`p'!=.0 ) | (total_planted_area_`p'!=. & total_planted_area_`p'!=.0)
	lab var grew_`p' "1=Household grew `p'" 
	gen harvested_`p'= (total_harv_area_`p'!=. & total_harv_area_`p'!=.0 )
	lab var harvested_`p' "1= Household harvested `p'"
}
replace grew_banana =1 if  number_trees_planted_banana!=0 & number_trees_planted_banana!=. 
replace grew_cassav =1 if number_trees_planted_cassava!=0 & number_trees_planted_cassava!=. 
replace grew_cocoa =1 if number_trees_planted_cocoa!=0 & number_trees_planted_cocoa!=. 
//drop harvest- harvest_pure_mixed area_harv- area_harv_pure_mixed area_plan- area_plan_pure_mixed value_harv value_sold total_planted_area total_harv_area  
//ALT 08.16.21: No drops necessary; only variables here are the ones that are listed in the labeling block above.
save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_yield_hh_crop_level.dta", replace


********************************************************************************
*CONSUMPTION -- RH 7/14/21 complete - HI checked 5/2/22
******************************************************************************** 
use "${Malawi_IHPS_W2_raw_data}/ConsAggW2.dta", clear // RH - renamed dta file for consagg
ren rexpagg total_cons // using real consumption-adjusted for region price disparities -- household level
gen peraeq_cons = (total_cons / adulteq)
gen percapita_cons = (total_cons / hhsize)
gen daily_peraeq_cons = peraeq_cons/365 
gen daily_percap_cons = percapita_cons/365
lab var total_cons "Total HH consumption"
lab var peraeq_cons "Consumption per adult equivalent"
lab var percapita_cons "Consumption per capita"
lab var daily_peraeq_cons "Daily consumption per adult equivalent"
lab var daily_percap_cons "Daily consumption per capita" 
keep y2_hhid total_cons peraeq_cons percapita_cons daily_peraeq_cons daily_percap_cons adulteq
save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_consumption.dta", replace

********************************************************************************
*HOUSEHOLD FOOD PROVISION* - TIK checked 11/20/23
********************************************************************************
use "${Malawi_IHPS_W2_raw_data}\Household\HH_MOD_H_10.dta", clear

forvalues k=1/10 {
	local j : display %02.0f `k' // to account for leading zero
	gen food_insecurity_`k' = (hh_h05a_`j' == "X")
}
forvalues k=1/15 {
	local j : display %02.0f `k'
	local i = `k' + 10 //to continue list from a to b variable
	gen food_insecurity_`i' = (hh_h05b_`j' == "X")
}

egen months_food_insec = rowtotal(food_insecurity_*) 
* replacing those that report over 12 months
replace months_food_insec = 12 if months_food_insec>12
keep HHID months_food_insec
lab var months_food_insec "Number of months of inadequate food provision"
save "${Malawi_IHPS_W2_created_data}/Malawi_IHPS_W2_food_insecurity.dta", replace


***************************************************************************
*HOUSEHOLD ASSETS* TIK Revised 11/20/23
***************************************************************************
use "${Malawi_IHPS_W2_raw_data}\Household\hh_mod_l_13.dta", clear
*ren hh_m03 price_purch  // VAP: purchse price not available in MW2s
ren hh_l05 value_today
ren hh_l04 age_item
ren hh_l03 number_items_owned
gen value_assets = value_today*number_items_owned
collapse (sum) value_assets, by(y2_hhid) // no of assets multipl by value
la var value_assets "Value of household assets"
save "${Malawi_IHPS_W2_created_data}\Malawi_IHPS_W2_hh_assets.dta", replace 

