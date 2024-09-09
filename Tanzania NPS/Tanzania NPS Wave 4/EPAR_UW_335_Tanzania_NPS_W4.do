
/*
-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title/Purpose 	: This do.file was developed by the Evans School Policy Analysis & Research Group (EPAR) 
				  for the construction of a set of agricultural development indicators 
				  using the Tanzania National Panel Survey (TNPS) LSMS-ISA Wave 4 (2014-15).
*Author(s)		: Didier Alia, Andrew Tomes, & C. Leigh Anderson

*Acknowledgments: We acknowledge the helpful contributions of Pierre Biscaye, David Coomes, Ushanjani Gollapudi, Jack Knauer, Lucero Marquez Josh Merfeld, Isabella Sun, Chelsea Sweeney, Emma Weaver, Ayala Wineman, 
				  Travis Reynolds, the World Bank's LSMS-ISA team, the FAO's RuLIS team, IFPRI, IRRI, and the Bill & Melinda Gates Foundation Agricultural Development Data and Policy team in discussing indicator construction decisions. 
				  
*Date			: This  Version 06 August 2024
*Dataset Version: TZA_2014_NPS-R4_v03_M_STATA11
----------------------------------------------------------------------------------------------------------------------------------------------------*/


*Data source
*-----------
*The Tanzania National Panel Survey was collected by the Tanzania National Bureau of Statistics (NBS) 
*and the World Bank's Living Standards Measurement Study - Integrated Surveys on Agriculture(LSMS - ISA)
*The data were collected over the period October 2015 - January 2016.
*All the raw data, questionnaires, and basic information documents are available for downloading free of charge at the following link
*http://microdata.worldbank.org/index.php/catalog/2862

*Throughout the do-file, we sometimes use the shorthand LSMS to refer to the Tanzania National Panel Survey.


*Summary of Executing the Master do.file
*-----------
*This Master do.file constructs selected indicators using the Tanzania NPS data set.
*Using data files from within the "Raw DTA files" folder within the "Tanzania NPS Wave 4" folder, 
*the do.file first constructs common and intermediate variables, saving dta files when appropriate 
*in the folder "\Tanzania TNPS - LSMS-ISA - Wave 4 (2014-15)\Tanzania_NPS_W4_created_data" within the "Final DTA files" folder.
*These variables are then brought together at the household, plot, or individual level, saving dta files at each level when available 
*in the folder "Tanzania TNPS - LSMS-ISA - Wave 4 (2014-15)" within the "Final DTA files" folder.

*The processed files include all households, individuals, and plots in the sample.
*Toward the end of the do.file, a block of code estimates summary statistics (mean, standard error of the mean, minimum, first quartile, median, third quartile, maximum) 
*of final indicators, restricted to the rural households only, disaggregated by gender of head of household or plot manager or farm size.
*The results are outputted in the excel file "Tanzania_NPS_W4_summary_stats.xlsx" in the "Tanzania TNPS - LSMS-ISA - Wave 4 (2014-15)" within the "Final DTA files" folder.
*It is possible to modify the condition  "if rural==1" in the portion of code following the heading "SUMMARY STATISTICS" to generate all summary statistics for a different sub_population.
										
 
/*
*FINAL FILES CREATED
*-------------------------------------------------------------------------------------
*HOUSEHOLD VARIABLES				Tanzania_NPS_W4_household_variables.dta
*INDIVIDUAL-LEVEL VARIABLES			Tanzania_NPS_W4_individual_variables.dta	
*PLOT-LEVEL VARIABLES				Tanzania_NPS_W4_field_plot_variables.dta
*SUMMARY STATISTICS					Tanzania_NPS_W4_summary_stats.xlsx
*/
 
 
 
clear	
set more off
clear matrix	
clear mata	
set maxvar 8000	
ssc install findname  // need this user-written ado file for some commands to work


*Set location of raw data and output
global directory			    "LSMS-Agricultural-Indicators-Code"
//set directories: These paths correspond to the folders where the raw data files are located and where the created data and final data will be stored.
global Tanzania_NPS_W4_raw_data 			"$directory/Tanzania NPS/Tanzania NPS Wave 4/Raw DTA files/"
global Tanzania_NPS_W4_created_data 		"$directory/Tanzania NPS/Tanzania NPS Wave 4/Final DTA files/created_data"
global Tanzania_NPS_W4_final_data  			"$directory/Tanzania NPS/Tanzania NPS Wave 4/Final DTA files/final_data"


********************************************************************************
*EXCHANGE RATE AND INFLATION FOR CONVERSION IN SUD IDS
********************************************************************************
global Tanzania_NPS_W4_exchange_rate 2158			// https://www.bloomberg.com/quote/USDETB:CUR
global Tanzania_NPS_W4_gdp_ppp_dollar 719.023   	// https://data.worldbank.org/indicator/PA.NUS.PPP
global Tanzania_NPS_W4_cons_ppp_dollar 809.32		// https://data.worldbank.org/indicator/PA.NUS.PRVT.PP
global Tanzania_NPS_W4_inflation 0.051701989  		// inflation rate 2015-2016. Data was collected during oct2014-2015. We want to adjust the monetary values to 2016


********************************************************************************
*THRESHOLDS FOR WINSORIZATION
********************************************************************************
global wins_lower_thres 1    						//  Threshold for winzorization at the bottom of the distribution of continous variables
global wins_upper_thres 99							//  Threshold for winzorization at the top of the distribution of continous variables

********************************************************************************
*GLOBALS OF PRIORITY CROPS 
********************************************************************************
*Enter the 12 priority crops here (maize, rice, wheat, sorghum, pearl millet (or just millet if not disaggregated), cowpea, groundnut, common bean, yam, sweet potato, cassava, banana)
*plus any crop in the top ten crops by area planted that is not already included in the priority crops - limit to 6 letters or they will be too long!
*For consistency, add the 12 priority crops in order first, then the additional top ten crops
global topcropname_area "maize rice wheat sorgum pmill cowpea grdnt beans yam swtptt cassav banana cotton sunflr pigpea"
global topcrop_area "11 12 16 13 14 32 43 31 24 22 21 71 50 41 34"
global comma_topcrop_area "11, 12, 16, 13, 14, 32, 43, 31, 24, 22, 21, 71, 50, 41, 34"
global nb_topcrops : list sizeof global(topcropname_area) // Gets the current length of the global macro list "topcropname_area" 
display "$nb_topcrops"

*DYA.11.1.2020 Re-scaling survey weights to match population estimates
*https://databank.worldbank.org/source/world-development-indicators#
global Tanzania_NPS_W4_pop_tot 49959822
global Tanzania_NPS_W4_pop_rur 34520239
global Tanzania_NPS_W4_pop_urb 15439583

********************************************************************************
*HOUSEHOLD IDS
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/hh_sec_a.dta", clear
ren hh_a01_1 region 
ren hh_a01_2 region_name
ren hh_a02_1 district
ren hh_a02_2 district_name
ren hh_a03_1 ward 
ren hh_a03_2 ward_name
ren hh_a03_3a village 
ren hh_a03_3b village_name
ren hh_a04_1 ea
ren y4_weights weight
gen rural = (clustertype==1)
keep y4_hhid region district ward village region_name district_name ward_name village_name ea rural weight strataid clusterid
lab var rural "1=Household lives in a rural area"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta", replace


********************************************************************************
*INDIVIDUAL IDS
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/hh_sec_b.dta", clear
keep y4_hhid indidy4 hh_b02 hh_b04 hh_b05
gen female=hh_b02==2 
lab var female "1= indivdual is female"
gen age=hh_b04
lab var age "Indivdual age"
gen hh_head=hh_b05==1 
lab var hh_head "1= individual is household head"
drop hh_b02 hh_b04 hh_b05
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_person_ids.dta", replace
 
 
********************************************************************************
*HOUSEHOLD SIZE
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/hh_sec_b.dta", clear
gen hh_members = 1
ren hh_b05 relhead 
ren hh_b02 gender
gen fhh = (relhead==1 & gender==2)
collapse (sum) hh_members (max) fhh, by (y4_hhid)
lab var hh_members "Number of household members"
lab var fhh "1= Female-headed household"
*DYA.11.1.2020 Re-scaling survey weights to match population estimates
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta", nogen
*Adjust to match total population
total hh_members [pweight=weight]
matrix temp =e(b)
gen weight_pop_tot=weight*${Tanzania_NPS_W4_pop_tot}/el(temp,1,1)
total hh_members [pweight=weight_pop_tot]
lab var weight_pop_tot "Survey weight - adjusted to match total population"
*Adjust to match total population but also rural and urban
total hh_members [pweight=weight] if rural==1
matrix temp =e(b)
gen weight_pop_rur=weight*${Tanzania_NPS_W4_pop_rur}/el(temp,1,1) if rural==1
total hh_members [pweight=weight_pop_tot]  if rural==1

total hh_members [pweight=weight] if rural==0
matrix temp =e(b)
gen weight_pop_urb=weight*${Tanzania_NPS_W4_pop_urb}/el(temp,1,1) if rural==0
total hh_members [pweight=weight_pop_urb]  if rural==0

egen weight_pop_rururb=rowtotal(weight_pop_rur weight_pop_urb)
total hh_members [pweight=weight_pop_rururb]  
lab var weight_pop_rururb "Survey weight - adjusted to match rural and urban population"
drop weight_pop_rur weight_pop_urb
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhsize.dta", replace


********************************************************************************
*PLOT AREAS
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/ag_sec_2a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_2b.dta", gen(short)		
ren plotnum plot_id
gen area_acres_est = ag2a_04
replace area_acres_est = ag2b_15 if area_acres_est==.
gen area_acres_meas = ag2a_09
replace area_acres_meas = ag2b_20 if area_acres_meas==.
keep if area_acres_est !=. 
keep y4_hhid plot_id area_acres_est area_acres_meas
lab var area_acres_meas "Plot are in acres (GPSd)"
lab var area_acres_est "Plot area in acres (estimated)"
gen area_est_hectares=area_acres_est* (1/2.47105)  
gen area_meas_hectares= area_acres_meas* (1/2.47105)
lab var area_meas_hectares "Plot are in hectares (GPSd)"
lab var area_est_hectares "Plot area in hectares (estimated)"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_areas.dta", replace


********************************************************************************
*PLOT DECISION MAKERS
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/hh_sec_b.dta", clear
ren indidy4 personid			// personid is the roster number, combination of household_id2 and personid are unique id for this wave
gen female =hh_b02==2
gen age = hh_b04
gen head = hh_b05==1 if hh_b05!=.
keep personid female age y4_hhid head
lab var female "1=Individual is a female"
lab var age "Individual age"
lab var head "1=Individual is the head of household"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_gender_merge.dta", replace

use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
drop if plotnum==""
gen cultivated = ag3a_03==1
gen season=1
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta"
replace season=2 if season==.
drop if plotnum==""
drop if ag3b_03==. & ag3a_03==.
replace cultivated = 1 if  ag3b_03==1 
*Gender/age variables
gen personid = ag3a_08_1
replace personid =ag3b_08_1 if personid==. &  ag3b_08_1!=.
merge m:1 y4_hhid personid using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_gender_merge.dta", gen(dm1_merge) keep(1 3)		// Dropping unmatched from using
*First decision-maker variables
gen dm1_female = female
drop female personid
*Second owner
gen personid = ag3a_08_2
replace personid =ag3b_08_2 if personid==. &  ag3b_08_2!=.
merge m:1 y4_hhid personid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_gender_merge.dta", gen(dm2_merge) keep(1 3)		// Dropping unmatched from using
gen dm2_female = female
drop female personid
*Third
gen personid = ag3a_08_3
replace personid =ag3b_08_3 if personid==. &  ag3b_08_3!=.
merge m:1 y4_hhid personid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_gender_merge.dta", gen(dm3_merge) keep(1 3)		// Dropping unmatched from using
gen dm3_female = female
drop female personid
*Constructing three-part gendered decision-maker variable; male only (=1) female only (=2) or mixed (=3)
gen dm_gender = 1 if (dm1_female==0 | dm1_female==.) & (dm2_female==0 | dm2_female==.) & (dm3_female==0 | dm3_female==.) & !(dm1_female==. & dm2_female==. & dm3_female==.)
replace dm_gender = 2 if (dm1_female==1 | dm1_female==.) & (dm2_female==1 | dm2_female==.) & (dm3_female==1 | dm3_female==.) & !(dm1_female==. & dm2_female==. & dm3_female==.)
replace dm_gender = 3 if dm_gender==. & !(dm1_female==. & dm2_female==. & dm3_female==.)
la def dm_gender 1 "Male only" 2 "Female only" 3 "Mixed gender"
la val dm_gender dm_gender
lab var  dm_gender "Gender of plot manager/decision maker"
*Replacing observations without gender of plot manager with gender of HOH
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhsize.dta", nogen 								
replace dm_gender = 1 if fhh==0 & dm_gender==.
replace dm_gender = 2 if fhh==1 & dm_gender==.
ren plotnum plot_id 
drop if  plot_id==""
keep y4_hhid plot_id plotname dm_gender  cultivated  
lab var cultivated "1=Plot has been cultivated"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_decision_makers.dta", replace


********************************************************************************
*ALL PLOTS - AT Updated on 6/16/21
********************************************************************************
/* This is a new module that's designed to combine/streamline a lot of the crop
data processing. My goal is to have crops crunched down to 2-ish sections; one for
production, and the second for expenses.
	Workflow:
		Combine all plots into a single file
		Calculate area planted and area harvested
		Determine (actual) purestand/mixed plot status
		Determine yields
		Generate geographic medians for prices 
		Determine value
*/


use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
merge 1:1 y4_hhid plotnum using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta", nogen
ren plotnum plot_id
	gen mech0=ag3a_71a==1
	gen mech1=ag3b_71a==1
	gen anml0=ag3a_71b==1
	gen anml1=ag3b_71b==1
preserve
	keep *hhid plot_id anml* mech*
	tempfile use_mech
	save `use_mech' //TO DO: Incorporate
restore


*formalized land rights 
//ALT: 07.23.22: Put this here as ownership could easily be included in the all plots file if desired
replace ag3a_28d = ag3b_28d if ag3a_28d==.		// replacing with values in short season for short season observations
gen formal_land_rights = ag3a_28d>=1 & ag3a_28d<=7										// Note: Including anything other than "no documents" as formal

*Individual level (for women)
ren ag3a_29_* personid1*
ren ag3b_29_* personid2*
keep y4_hhid formal_land_rights person*
gen dummy=_n
reshape long personid, i(y4_hhid formal_land_rights dummy) j(personno) //Can drop
drop personno dummy
ren personid indidy4
merge m:1 y4_hhid indidy4 using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_person_ids.dta", nogen keep(3)
gen formal_land_rights_f = formal_land_rights==1 & female==1
preserve
collapse (max) formal_land_rights_f, by(y4_hhid indidy4)		
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_rights_ind.dta", replace
restore	
collapse (max) formal_land_rights_hh=formal_land_rights, by(y4_hhid)		// taking max at household level; equals one if they have official documentation for at least one plot
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_rights_hh.dta", replace


	
use "${Tanzania_NPS_W4_raw_data}/ag_sec_5a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_7a.dta"
gen short=0 //Not absolutely necessary right now because we consolidate over main and short rainy seasons
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_5b.dta"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_7b.dta"
recode short(.=1)
ren zaocode crop_code
recode ag7a_03 ag7b_03 ag5a_02 ag5b_02 (.=0)
egen quantity_sold=rowtotal(ag7a_03 ag7b_03 ag5a_02 ag5b_02) 
recode ag7a_04 ag7b_04 ag5a_03 ag5b_03 (.=0)
egen value_sold = rowtotal(ag7a_04 ag7b_04 ag5a_03 ag5b_03)
collapse (sum) quantity_sold value_sold, by (y4_hhid crop_code)
lab var quantity_sold "Kgs sold of this crop, summed over main and short season"
lab var value_sold "Value sold of this crop, summed over main and short season"
gen price_kg = value_sold / quantity_sold
lab var price_kg "Price per kg sold"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_sales.dta", replace
 
use "${Tanzania_NPS_W4_raw_data}/ag_sec_4a.dta", clear
	append using "${Tanzania_NPS_W4_raw_data}/ag_sec_6a.dta"
	gen short=0
	append using "${Tanzania_NPS_W4_raw_data}/ag_sec_4b.dta"
	append using "${Tanzania_NPS_W4_raw_data}/ag_sec_6b.dta"
recode short (.=1)
ren plotnum plot_id
ren zaocode crop_code
drop if crop_code==.
ren ag6a_02 number_trees_planted
replace number_trees_planted = ag6b_02 if number_trees_planted==.
sort y4_hhid plot_id crop_code
bys y4_hhid plot_id short : gen cropid = _n //Get number of crops grown on each plot in each season
bys y4_hhid plot_id short : egen num_crops = max(cropid)
gen purestand = 1 if ag4a_04==2 
replace purestand = 1 if ag4b_04==2 & purestand==.
replace purestand = 1 if ag6a_05==2 & purestand==.
replace purestand = 1 if ag6b_05==2 & purestand==.
replace purestand = 1 if num_crops==1 //141 instances where cropping system was reported as other than monocropping, but only one crop was reported
//At this point, we have about 830 observations that reported monocropping but have something else on the plot
recode purestand (.=0)


//gen month_harv = ag4a_24_2 //Strangely, all 12 months are represented here despite the long rainy season officially occurring from March to May. Sweet potatoes account for the bulk of out-of-season harvest, indicating that they may be more of an irregularly-harvested backup/long-haul crop
//replace month_harv = ag4a_24_1 if ag4a_24_1 > ag4a_24_2 //Harvests that are unfinished are coded as 0
//replace month_harv = ag4b_24_2 if month_harv==. 
//replace month_harv = ag4b_24_1 if ag4b_24_1 > ag4b_24_2
//Tree crops are an additional layer of complexity because we have production records from 2018, 2019, and 2020 - but only temp crop records for 2018.  Because the instrument only asks about most recent production period for tree crops,
//we could smoosh them all together into a single "year" for each plot. But that complicates rent valuation.

gen prop_planted = ag4a_02/4
replace prop_planted = ag4b_02/4 if prop_planted==.
replace prop_planted=1 if ag4a_01==1 | ag4b_01==1
//Remaining issue is tree crops: we don't have area harvested nor area planted, so if a tree crop is reported as a purestand but grown on a plot with other crops, we have to assume that the growers accurately estimate the area of their remaining crops; this can lead to some incredibly large plant populations on implausibly small patches of ground. For now, I assume a tree is purestand if it's the only crop on the plot (and assign it all plot area regardless of tree count) or if there's a plausible amount of room for at least *some* trees to be grown on a subplot.
replace prop_planted = 1 if prop_planted==. & num_crops==1 
bys y4_hhid plot_id short : egen total_prop_planted=sum(prop_planted)
bys y4_hhid plot_id : egen max_prop_planted=max(total_prop_planted) //Used for tree crops
gen intercropped = ag6a_05
replace intercropped = ag6b_05 if intercropped==.
replace purestand=0 if prop_planted==. & (max_prop_planted>=1 | intercropped==1) //311 changes from monocropped to not monocropped

merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_areas.dta", nogen keep(1 3) keepusing(area_est_hectares area_meas_hectares)
ren area_meas_hectares field_size
replace field_size = area_est_hectares if field_size==.
gen est_ha_planted=prop_planted*area_est_hectares //Used later.

replace prop_planted = prop_planted/total_prop_planted if total_prop_planted > 1
replace total_prop_planted=1 if total_prop_planted > 1
gen ha_planted = prop_planted*field_size

gen ha_harvest = ag4a_21/2.47105
replace ha_harvest = ag4b_21/2.47105 if ha_harvest==.

/*Filling in permcrops
//Per Ayala et al. in technical report 354, bananas and cassava likely occupy non-trivial quantities of land;
//remaining crops may be trivial, but some folks have a lot of permanent crops planted on their plots
	A: Assume purestand plantings that are the only listed crop take up the whole field
	B: For fields where the only crops are permanent crops (i.e., n_permcrops==n_crops), area is proportional to the total number of trees
	C: For fields where the planting is split (i.e., total fraction of annuals planted < 1), permcrops are assigned remaining area according to A or B.
		C.1: For plots that were cultivated in both short and long seasons, trees must take up the smallest area remaining on each plot
	D: For fields where the trees are intercropped/mixed in (i.e., total fraction of annuals >=1), total area planted is both unknown and unknowable; omit.
*/
gen permcrop=number_trees_planted>0 & number_trees_planted!=.
bys y4_hhid plot_id : egen anypermcrop=max(permcrop)
bys y4_hhid plot_id : egen n_permcrops = sum(permcrop)
bys y4_hhid plot_id : egen n_trees=sum(number_trees_planted)
replace ha_planted = number_trees_planted/n_trees*(field_size*(1-max_prop_planted)) if max_prop_planted<=1 & ha_planted==.
recode ha_planted (0=.) 
//324 obs still have missing values; a lot of these are small (<10) plantings; but about two thirds are over 10.
//Some are implausibly huge (48,000 pineapples on 5.4 ha? Assuming 1 sq m per pineapple, that's not impossible, but where are the other 4 crops planted?)
//I tried estimating stand densities based on the estimated crop areas, but the ranges are huge, likely indicative of a large range of planting patterns


//Rescaling
//SOP from the previous wave was to assume, for plots that have been subdivided and partially reported as monocropped, that the monocrop area is accurate and the intercrop area accounts for the rest of the plot. 
//Difficulty with accounting for tree crops in both long and short rainy seasons, although there's only a few where this is a problem.
bys y4_hhid plot_id short : gen total_ha_planted=sum(ha_planted)
bys y4_hhid plot_id short : egen max_ha_planted=max(total_ha_planted) 
replace total_ha_planted=max_ha_planted
drop max_ha_planted
bys y4_hhid plot_id short purestand : gen total_purestand_ha = sum(ha_planted)
gen total_mono_ha = total_purestand_ha if purestand==1
gen total_inter_ha = total_purestand_ha if purestand==0
recode total_*_ha (.=0)
bys y4_hhid plot_id short : egen mono_ha = max(total_mono_ha)
bys y4_hhid plot_id short : egen inter_ha = max(total_inter_ha)
drop total_mono_ha total_inter_ha
replace mono_ha = mono_ha/total_ha_planted * field_size if mono_ha > total_ha_planted
gen intercrop_ha_adj = field_size - mono_ha if mono_ha < field_size & (mono_ha+inter_ha)>field_size
gen ha_planted_adj = ha_planted/inter_ha * intercrop_ha_adj if purestand==0
recode ha_planted_adj (0=.)
replace ha_planted = ha_planted_adj if ha_planted_adj!=.

//Harvest
gen kg_harvest = ag4a_27
replace kg_harvest = ag6a_09 if kg_harvest==.
replace kg_harvest = ag6b_09 if kg_harvest==.
//Only 3 obs are not finished with harvest
replace kg_harvest = ag4b_28 if kg_harvest==.
replace kg_harvest = kg_harvest/(1-ag4b_27/100) if ag4b_25==2
	//Rescale harvest area 
gen over_harvest = ha_harvest > ha_planted & ha_planted!=.
gen lost_plants = ag4a_17==1 | ag6a_10==1 | ag4b_17==1 | ag6b_10==1
//Assume that the area harvest=area planted if the farmer does not report crop losses
replace ha_harvest = ha_planted if over_harvest==1 & lost_plants==0 
replace ha_harvest = ha_planted if ag4a_22==2 | ag4b_22==2 //"Was area harvested less than area planted? 2=no"
replace ha_harvest = ha_planted if permcrop==1 & over_harvest==1 //Lack of information to deal with permanent crops, so rescaling to ha_planted
replace ha_harvest = 0 if kg_harvest==. 
//Remaining observations at this point have (a) recorded preharvest losses (b) have still harvested some crop, and (c) have area harvested greater than area planted, likely because estimated area > GPS-measured area. We can conclude that the area_harvested should be less than the area planted; one possible scaling factor could be area_harvested over estimated area planted.
gen ha_harvest_adj = ha_harvest/est_ha_planted * ha_planted if over_harvest==1 & lost_plants==1 
replace ha_harvest = ha_harvest_adj if ha_harvest_adj !=. & ha_harvest_adj<= ha_harvest
replace ha_harvest = ha_planted if ha_harvest_adj !=. & ha_harvest_adj > ha_harvest //14 plots where this clever plan did not work; going with area planted because that's all we got for these guys


ren ag4a_28 value_harvest
replace value_harvest=ag4b_29 if value_harvest==.
gen val_kg = value_harvest/kg_harvest
//Bringing in the permanent crop price data.
merge m:1 y4_hhid crop_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_sales.dta", nogen keep(1 3) keepusing(price_kg)
replace price_kg = val_kg if price_kg==.
drop val_kg
ren price_kg val_kg //Use observed sales prices where available, farmer estimated values where not 
gen obs=kg_harvest>0 & kg_harvest!=.
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta", nogen keep(1 3)
gen plotweight=ha_planted*weight
foreach i in region district ward village ea y4_hhid {
preserve
	bys crop_code `i' : egen obs_`i' = sum(obs)
	collapse (median) val_kg_`i'=val_kg (sum) obs_`i'_kg=obs  [aw=plotweight], by (`i' crop_code)
	tempfile val_kg_`i'_median
	save `val_kg_`i'_median'
restore
merge m:1 `i' crop_code using `val_kg_`i'_median', nogen keep(1 3)
}
preserve
collapse (median) val_kg_country = val_kg (sum) obs_country_kg=obs [aw=plotweight], by(crop_code)
tempfile val_kg_country_median
save `val_kg_country_median'
restore
merge m:1 crop_code using `val_kg_country_median',nogen keep(1 3)
foreach i in country region district ward village ea {
	replace val_kg = val_kg_`i' if obs_`i'_kg >9
}
	replace val_kg = val_kg_y4_hhid if val_kg_y4_hhid!=.
	replace value_harvest=val_kg*kg_harvest if value_harvest==.

preserve
	//gen month_harv = max(month_harv0 month_harv1)
	collapse (sum) value_harvest /*(max) month_harv*/, by(y4_hhid plot_id short)
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_value_prod.dta", replace //Needed to estimate plot rent values
restore
	collapse (sum) kg_harvest value_harvest ha_planted ha_harvest number_trees_planted (min) purestand, by(region district ward village ea y4_hhid plot_id crop_code field_size short) 
		merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender)
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_all_plots.dta",replace
	

********************************************************************************
* CROP EXPENSES *
********************************************************************************

//ALT: Updated this section to improve efficiency and remove redundancies elsewhere.
	*********************************
	* 			SEED				*
	*********************************

use "${Tanzania_NPS_W4_raw_data}/ag_sec_4a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_4b.dta"
	ren plotnum plot_id
	drop if zaocode==.
ren ag4a_10c_1 qtyseedexp0 //There are ~40 non-kg obs
ren ag4a_10c_2 unitseedexp0
ren ag4a_12 valseedexp0
ren ag4b_10c_1 qtyseedexp1
ren ag4b_10c_2 unitseedexp1
ren ag4b_12 valseedexp1
/* For implicit costing - currently omitting (see comments below)
gen qtyseedimp0 = ag4a_10_1 - qtyseedexp0 if ag4a_10_2==unitseedexp0 //Only one ob without same units
gen qtyseedimp1 = ag4b_10_1 - qtyseedexp1 if ag4b_10_2==unitseedexp1 
gen valseedimp0 =.
gen valseedimp1 =.*/ 
collapse (sum) val*, by(y4_hhid plot_id)
tempfile seeds
save `seeds'
	
	******************************************************
	* LABOR, CHEMICALS, FERTILIZER, LAND   				 *
	******************************************************
	*Hired labor
//ALT 06.25.21: No labor days for family means we can't estimate implicit cost of family labor. In W4, family labor was about 90% of all plot labor days, so this omission is substantial.
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
merge 1:1 y4_hhid plotnum using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta", nogen keep(1 3)
	drop if ag3a_07_2==. & ag3b_07_2==.
	ren plotnum plot_id
merge 1:1 y4_hhid plot_id using `seeds', nogen
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta", nogen keep(1 3) keepusing(weight)
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_areas.dta", nogen keep(1 3) keepusing(area_meas_hectares area_est_hectares)
ren area_meas_hectares field_size
replace field_size = area_est_hectares if field_size==.
drop area_est_hectares
	//No way to disaggregate by gender of worker because instrument only asks for aggregate pay.
	egen wagesexp0=rowtotal(ag3a_74_4 ag3a_74_8 ag3a_74_16)
	egen wagesexp1= rowtotal(ag3b_74_4 ag3b_74_8 ag3b_74_16)
	
preserve
	keep y4_hhid plot_id wages*
	reshape long wagesexp, i(y4_hhid plot_id) j(short)
	reshape long wages, i(y4_hhid plot_id short) j(exp) string
	ren wages val
	gen input = "hired_labor"
	tempfile labor
	save `labor'
restore

//ALT 07.09.21: I use code I developed for NGA W4 here - this is designed to estimate prices from explicit costs to value
//leftover/free inputs. For TZA W5, only organic fertilizer and seed have an implicit component, so this is overkill (labor is probably the biggest implicit cost and is missing from this wave). However,
//I leave it in because it allows median prices to be easily extracted if for some reason that information becomes relevant, and it makes the code more portable.
ren ag3a_65b_1 qtypestexp0 //0-1 designators for long/short growing seasons.
ren ag3a_65b_2 unitpestexp0
ren ag3a_65c valpestexp0
ren ag3b_65b_1 qtypestexp1 //The label says long season, but I'm pretty sure these are short season inputs?
ren ag3b_65b_2 unitpestexp1
ren ag3b_65c valpestexp1
ren ag3a_62_1 qtyherbexp0
ren ag3a_62_2 unitherbexp0
ren ag3a_63 valherbexp0
ren ag3b_62_1 qtyherbexp1
ren ag3b_62_2 unitherbexp1
ren ag3b_63 valherbexp1

foreach i in herbexp pestexp {
	foreach j in 0 1 {
	replace qty`i'`j'=qty`i'`j'/1000 if unit`i'`j'==3 & qty`i'`j'>9 //Assuming instances of very small amounts are typos. 
	replace unit`i'`j'=2 if unit`i'`j'==3
		}
	}

ren ag3a_44 qtyorgfertexp0 
recode qtyorgfertexp0 (.=0)
ren ag3a_45 valorgfertexp0

ren ag3b_44 qtyorgfertexp1
recode qtyorgfertexp1 (.=0)
ren ag3b_45 valorgfertexp1

/* ALT 07.13.21: I initially set this up like the Nigeria code on the assumption that implicit costs were highly relevant to crop production; however, it doesn't seem like this 
is as much of a thing in Tanzania, and there's not enough information to accurately account for them if it turns out that they are. All explicit inputs have price information,
so there's also no need to do geographic medians to fill in holes. I'm leaving the implicit valuation for organic fertilizer and seed in case we come back to this.
gen qtyorgfertimp0 = ag3a_42-qtyorgfertexp0
gen valorgfertimp0 = .
gen qtyorgfertimp1 = ag3b_42-qtyorgfertexp1 
gen valorgfertimp1 = . //We should expect only this value to get filled in by the pricing code.
*/
//Price disaggregation of inorganic fertilizer isn't necessary, because there's no implicit inorganic fertilizer useage
egen qtyinorgfertexp0=rowtotal(ag3a_49 ag3a_56)
egen valinorgfertexp0=rowtotal(ag3a_51 ag3a_58)
egen qtyinorgfertexp1=rowtotal(ag3b_49 ag3b_56)
egen valinorgfertexp1=rowtotal(ag3b_51 ag3b_58)


**Land Rent
/*ALT 07.09.21: Previous versions of the code use these rental expenses in their entirety; I imagine this results in wonky findings,
because rental values can cover anywhere from 1 month to 3 years (even though the question is, "How much did you pay to rent plot during <season>?"). 
It stands to reason that we should rescale at least the long-term rentals to a standard growing season length, but it isn't obvious what that should be. 
The separation between short and long in the dta files and instruments implies that the whole country has two growing seasons, but, in fact, the country is divided
into two regions: unimodal (one long rainy season - Msimu) and bimodal (two shorter rainy seasons - Vuli and Masika). 
Even within these regions, growing season length can vary greatly. Estimates based on weather data by Yohan, Oteng'i, and Lukorito (2006) Assessment of the Growing Season over the Unimodal Rainfall Regime Region of Tanzania 
suggest that the growing season length varies anywhere from 1.5 to 6 months within unimodal rainfall regions: 
	*Kigoma: 94-196 (150) days
	*Tabora: 85-175 (134)
	*Mbeya: 90-181 (139)
	*Songea: 76-169 (131)
	*Iringa: 42-145 (97)
	*Dodoma: 47-126 (93)
	*Mtwara: 48-219 (137)
The instrument adds complexity to these length estimations because there are no questions about planting dates, just harvest (permanent crops, however, have start and end dates for the most recent production period).
We can make a rough assumption that planting occurred at the beginning of the growing season as it was defined in the instrument, the start of Vuli is Sept/October, with Msimu starting about a month later;
the Masika, which tends to be referred to as the long rainy season is generally in March (although planting probably occurs as early as February). FAO reports the following crop calendars:
	Maize (Vuli): Sept-February (inclusive)
	Maize, Sorghum & Millet (Masika): Feb/Mar-Aug (inclusive)
	Maize and Sorghum (Msimu - one crop/year) : Nov-June (inclusive)
	Rice (Msimu) December-June (inclusive)
Cropping regime partially depends on region - the msimu/unimodal/NDJFMA rainfall areas include the western, central, southwestern and southern regions. Bimodal rains occur in the remainder.
The regional variation is highly visible in the data - 31/33 plots in Kagera and 22/31 in Geita were cultivated during the short rainy season of 2018, and 0/21 in Shinyanga, 0/41 in Pwani, and 0/48 in Morogoro were cultivated.
*But* this doesn't follow the regional distribution we'd expect based on rainfall regime - Kagera and Geita are in the bimodal region, but so are Pwani and Shinyanga (only Morogoro is not). The Kagera and Geita plots were 
largely harvested in December/January and February respectively, consistent with Vuli rains and implying a planting date in September. For the long rainy season, harvests in June and July are common in unimodal Morogoro and Rukwa, but also
the (theoretically) bimodal Kagera. Relatively few harvests occur in August/September, suggesting either that Masika cropping is not broadly popular even in regions where it would be expected to be dominant or that the FAO report is a little off with respect to harvest dates. If we look specifically at maize and sorghum, harvest end dates are +/- normally distributed around a peak of June (likewise with sorghum and rice), suggesting that the "long rainy season" mainly encompasses
Msimu crops, with a small proportion (about 1/10th) being harvested in the expected Masika months of August and September.
 
For permanent crops with longer production periods, the longer rental term might make sense - if you rent land to plant trees, you're going to have a higher sunk cost than an annual producer;
likewise, the opportunity cost (in terms of foregone rent per harvest for an owned plot) is likely higher for tree crops. However, we don't necessarily know how many crops are produced during
the longer rental period from this survey alone, so it stands to reason that comparability will be higher if we just consider the growing season rather than the full rental term.
*/

preserve
	//For rent, need to generate a price (for implicit costing), adjust quantity for long seasons (main file) and generate a total value. Geographic medians may not be particularly useful given the small sample size
	drop val*
	ren ag3a_33 vallandrentexp0
	ren ag3b_33 vallandrentexp1
	gen monthslandrent0 = ag3a_34_1
	replace monthslandrent0=monthslandrent0*12 if ag3a_34_2==2
	gen monthslandrent1 = ag3b_34_1
	replace monthslandrent1=monthslandrent1*12 if ag3b_34_2==2
	//Changing the in-kind share categories from categorical to fourths
	recode ag3a_35 ag3b_35 (1 2 .=0) (3=1) (4=2) (5=3) (6=4)
	gen propinkindpaid0 = ag3a_35/4
	gen propinkindpaid1 = ag3b_35/4
	replace vallandrentexp0 = . if monthslandrent0==0 //One obs with rent paid but no time period of rental
	keep y4_hhid plot_id months* prop* val* field_size
	reshape long monthslandrent vallandrentexp propinkindpaid, i(y4_hhid plot_id) j(short)
	la val short //Remove value labels from the short variable - not sure why they're getting applied
	merge 1:1 y4_hhid plot_id short using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_value_prod.dta"
	gen pricelandrent = (vallandrentexp+(propinkindpaid*value_harvest))/monthslandrent/field_size 
	keep y4_hhid plot_id pricelandrent short field_size
	reshape wide pricelandrent, i(y4_hhid plot_id field_size) j(short) //82 total observations; there isn't a significant difference between short and long rainy season rents.
	la var pricelandrent0 "Cost of land rental per hectare per month (long rainy season data)"
	la var pricelandrent1 "Cost of land rental per hectare per month (short rainy season data)"
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_rents.dta", replace
restore
merge 1:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_rents.dta", nogen keep(1 3)
/* Standardizing Rental Prices 
*/
//Doing one year with the option to rescale to growing season if we figure out a way to do it later.
gen n_seas=pricelandrent0!=.+pricelandrent1!=.
gen vallandrent0 = pricelandrent0*12*field_size/n_seas 
gen vallandrent1 = pricelandrent1*12*field_size/n_seas
recode vallandrent* (.=0)
keep y4_hhid plot_id qty* val* unit*

unab vars1 : *1 //This is a shortcut to get all stubs 
local stubs1 : subinstr local vars1 "1" "", all
reshape long `stubs1', i(y4_hhid plot_id) j(short)

unab vars2 : *exp
local stubs2 : subinstr local vars2 "exp" "", all
reshape long `stubs2', i(y4_hhid plot_id short) j(exp) string
reshape long qty val unit, i(y4_hhid plot_id short exp) j(input) string
la val short //Remove a weird label that got stuck on this at some point.
//The var exp will be "exp" for all because we aren't doing implicit expenses and can be dropped or ignored.

/* Geographic median code (for filling in missing/implicit values)

tempfile all_plot_inputs
save `all_plot_inputs'

keep if strmatch(exp,"exp") & qty!=. //Now for geographic medians
gen plotweight = weight*field_size
recode val (0=.)
drop if unit==0 //Remove things with unknown units.
gen price = val/qty
drop if price==.
gen obs=1

foreach i in zone state lga ea hhid {
preserve
	bys `i' input unit itemcode : egen obs_`i' = sum(obs)
	collapse (median) price_`i'=val [aw=plotweight], by (`i' input unit obs_`i')
	tempfile price_`i'_median
	save `price_`i'_median'
restore
}
preserve
bys input unit itemcode : egen obs_country = sum(obs)
collapse (median) price_country = price [aw=plotweight], by(input unit itemcode obs_country)
tempfile price_country_median
save `price_country_median'
restore

use `all_plot_inputs',clear
foreach i in zone state lga ea hhid {
	merge m:1 `i' input unit itemcode using `price_`i'_median', nogen keep(1 3) 
}
	merge m:1 input unit itemcode using `price_country_median', nogen keep(1 3)
	recode price_hhid (.=0)
	gen price=price_hhid
foreach i in country zone state lga ea {
	replace price = price_`i' if obs_`i' > 9 & obs_`i'!=.
}
//Default to household prices when available
replace price = price_hhid if price_hhid>0
replace val = qty*price if val==. | val==0

save `all_plot_inputs', replace 
*/

recode val qty (.=0)
//drop if val==0 & qty==0 //Important to exclude this if we're doing plot or hh-level averages.
preserve
	//Need this for quantities and not sure where it should go.
	keep if strmatch(input,"orgfert") | strmatch(input,"inorgfert") | strmatch(input,"herb") | strmatch(input,"pest") //Seed rates would also be doable if we have conversions for the nonstandard units
	//Unfortunately we have to compress liters and kg here, which isn't ideal. But we don't know which inputs were used, so we would have to guess at density.
	collapse (sum) qty_=qty, by(y4_hhid plot_id input short)
	reshape wide qty_, i(y4_hhid plot_id short) j(input) string
	ren qty_inorg inorg_fert_rate
	ren qty_orgfert org_fert_rate
	ren qty_herb herb_rate
	ren qty_pest pest_rate
	la var inorg_fert_rate "Qty inorganic fertilizer used (kg)"
	la var org_fert_rate "Qty organic fertilizer used (kg)"
	la var herb_rate "Qty of herbicide used (kg/L)"
	la var pest_rate "Qty of pesticide used (kg/L)"
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_input_quantities.dta", replace
restore
append using `labor'
collapse (sum) val, by (y4_hhid plot_id input short)
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_decision_makers.dta",  keepusing(dm_gender) nogen keep(3) //Removes uncultivated plots
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_cost_inputs_long.dta",replace
/*preserve
	collapse (sum) val_=val, by(y4_hhid plot_id dm_gender short)
	reshape wide val_, i(y4_hhid plot_id dm_gender) j(short)
	save "${Tanzania_NPS_W5_created_data}/Tanzania_NPS_W5_plot_cost_inputs.dta", replace //This gets used below.
restore
*/	
//Household level
	**Animals and machines (not plot level)
	//ALT: We could allocate these expenses to plot based on plot area because they ask for the plots where traction was used. 
	/*
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
merge 1:1 y4_hhid plotnum using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta", nogen
ren plotnum plot_id
	gen mech0=ag3a_71a==1
	gen mech1=ag3b_71a==1
	gen anml0=ag3a_71b==1
	gen anml1=ag3b_71b==1
preserve
	keep *hhid plot_id anml* mech*
	tempfile use_mech
	save `use_mech'
restore
*/

use "${Tanzania_NPS_W4_raw_data}/ag_sec_11.dta", clear
gen animal_traction = (itemid>=3 & itemid<=5)
gen ag_asset = (itemid<3 | itemid>8)
gen tractor = (itemid>=6 & itemid<=8)
ren ag11_09 rental_cost
gen rental_cost_animal_traction = rental_cost if animal_traction==1
gen rental_cost_ag_asset = rental_cost if ag_asset==1
gen rental_cost_tractor = rental_cost if tractor==1
recode rental_cost_animal_traction rental_cost_ag_asset rental_cost_tractor (.=0)
collapse (sum) rental_cost_animal_traction rental_cost_ag_asset rental_cost_tractor, by (y4_hhid)
lab var rental_cost_animal_traction "Costs for renting animal traction"
lab var rental_cost_ag_asset "Costs for renting other agricultural items"
lab var rental_cost_tractor "Costs for renting a tractor"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_asset_rental_costs.dta", replace
//ALT: This is a little convoluted but I'm doing it to maintain the original file structure
ren rental_cost_* val*_rent
reshape long val, i(y4_hhid) j(var) string
ren var input
tempfile asset_rental
save `asset_rental'
 
use "${Tanzania_NPS_W4_raw_data}/ag_sec_5a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_5b.dta"
ren ag5a_22 transport_costs_cropsales
replace transport_costs_cropsales = ag5b_22 if transport_costs_cropsales==.
recode transport_costs_cropsales (.=0)
collapse (sum) transport_costs_cropsales, by (y4_hhid)
lab var transport_costs_cropsales "Expenditures on transportation for crop sales of temporary crops"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_transportation_cropsales.dta", replace
ren transport_costs_cropsales val
gen input = "crop_transport"
tempfile trans_cost
save `trans_cost'
 
 
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_cost_inputs_long.dta", clear
//back to wide
collapse (sum) val, by(y4_hhid input)
append using `asset_rental'
append using `trans_cost'
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_inputs_long.dta", replace //AgQuery
ren val val_
reshape wide val_, i(y4_hhid) j(input) string
recode val* (.=0)
egen crop_production_expenses = rowtotal(val*)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_inputs.dta", replace
 
	

********************************************************************************
*MONOCROPPED PLOTS - ALT updated 07/21
********************************************************************************
//Generating area harvested and kilograms harvested - for monocropped plots
/* Checking to see if there's an issue where expenses are recorded but crops are not (e.g., for tree crops); no mismatches occur. I'm assuming this is because all relevant expenses are recorded when the crop is surveyed.
It could also be because there is not a lot in the way of crop expenses. 
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_inputs_long.dta", clear
collapse (sum) val, by(y4_hhid plot_id short)
tempfile plot_exp
save `plot_exp'
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_all_plots.dta", clear
	keep if purestand==1
	merge m:1 y4_hhid plot_id short using `plot_exp', nogen keep(1 3)
*/	
	use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_all_plots.dta", clear
	merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender)
	ren ha_planted monocrop_ha
	ren kg_harvest kgs_harv_mono
	ren value_harvest val_harv_mono
	collapse (sum) *mono*, by(y4_hhid plot_id crop_code dm_gender short)

forvalues k=1(1)$nb_topcrops  {		
preserve	
	local c : word `k' of $topcrop_area
	local cn : word `k' of $topcropname_area
	local cn_full : word `k' of $topcropname_area_full
	keep if crop_code==`c'
	count
	if _N!=0 { //If we haven't dropped everything, continue.
	ren monocrop_ha `cn'_monocrop_ha
	drop if `cn'_monocrop_ha==0 		
	ren kgs_harv_mono kgs_harv_mono_`cn'
	ren val_harv_mono val_harv_mono_`cn'
	gen `cn'_monocrop=1
	la var `cn'_monocrop "HH grows `cn_full' on a monocropped plot"
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_`cn'_monocrop.dta", replace
	foreach i in `cn'_monocrop_ha kgs_harv_mono_`cn' val_harv_mono_`cn' `cn'_monocrop { 
		gen `i'_male = `i' if dm_gender==1
		gen `i'_female = `i' if dm_gender==2
		gen `i'_mixed = `i' if dm_gender==3
	}
	collapse (sum) *monocrop_ha* kgs_harv_mono* val_harv_mono* (max) `cn'_monocrop `cn'_monocrop_male `cn'_monocrop_female `cn'_monocrop_mixed, by(y4_hhid)
	la var `cn'_monocrop_ha "Total `cn' monocrop hectares - Household"
	la var `cn'_monocrop "Household has at least one `cn' monocrop"
	la var kgs_harv_mono_`cn' "Total kilograms of `cn' harvested - Household"
	la var val_harv_mono_`cn' "Value of harvested `cn' (TSH)"
	foreach g in male female mixed {		
		la var `cn'_monocrop_ha_`g' "Total `cn' monocrop hectares on `g' managed plots - Household"
		la var kgs_harv_mono_`cn'_`g' "Total kilograms of `cn' harvested on `g' managed plots - Household"
		la var val_harv_mono_`cn'_`g' "Total value of `cn' harvested on `g' managed plots - Household"
	}
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_`cn'_monocrop_hh_area.dta", replace
	}
restore
}

use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_cost_inputs_long.dta", clear
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender)
collapse (sum) val, by(y4_hhid plot_id dm_gender input short)
levelsof input, clean l(input_names)
	ren val val_
	reshape wide val_, i(y4_hhid plot_id dm_gender short) j(input) string
	gen dm_gender2 = "male" if dm_gender==1
	replace dm_gender2 = "female" if dm_gender==2
	replace dm_gender2 = "mixed" if dm_gender==3
	replace dm_gender2 = "unknown" if dm_gender==. //ALT 09.23.22: to fix
	drop dm_gender
foreach cn in $topcropname_area {
preserve
	//keep if strmatch(exp, "exp")
	//drop exp
	capture confirm file "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_`cn'_monocrop.dta"
	if !_rc {
	ren val* val*_`cn'_
	reshape wide val*, i(y4_hhid plot_id short) j(dm_gender2) string
	merge 1:1 y4_hhid plot_id short using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_`cn'_monocrop.dta", nogen keep(3)
	count
	if(r(N) > 0){
	collapse (sum) val*, by(y4_hhid)
	foreach i in `input_names' {
		egen val_`i'_`cn'_hh = rowtotal(val_`i'_`cn'_male val_`i'_`cn'_female val_`i'_`cn'_mixed)
	}
	//To do: labels
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_inputs_`cn'.dta", replace
	}
	}
restore
}


********************************************************************************
*TLU (Tropical Livestock Units)
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/lf_sec_02.dta", clear
gen tlu_coefficient=0.5 if (lvstckid==1|lvstckid==2|lvstckid==3|lvstckid==4|lvstckid==5|lvstckid==6)
replace tlu_coefficient=0.1 if (lvstckid==7|lvstckid==8)
replace tlu_coefficient=0.2 if (lvstckid==9)
replace tlu_coefficient=0.01 if (lvstckid==10|lvstckid==11|lvstckid==12|lvstckid==13)
replace tlu_coefficient=0.3 if (lvstckid==14)
lab var tlu_coefficient "Tropical Livestock Unit coefficient"

*Owned
gen cattle=inrange(lvstckid,1,6)
gen smallrum=inlist(lvstckid,7,8,9)
gen poultry=inlist(lvstckid,10,11,12,13)
gen other_ls=inlist(lvstckid,14,15,16)
gen cows=inrange(lvstckid,2,2)
gen chickens=inrange(lvstckid,10,10)
ren lf02_03 nb_ls_1yearago
gen nb_cattle_1yearago=nb_ls_1yearago if cattle==1 
gen nb_smallrum_1yearago=nb_ls_1yearago if smallrum==1 
gen nb_poultry_1yearago=nb_ls_1yearago if poultry==1 
gen nb_other_ls_1yearago=nb_ls_1yearago if other_ls==1 
gen nb_cows_1yearago=nb_ls_1yearago if cows==1 
gen nb_chickens_1yearago=nb_ls_1yearago if chickens==1 
egen nb_ls_today= rowtotal(lf02_04_1  lf02_04_2)
gen nb_cattle_today=nb_ls_today if cattle==1 
gen nb_smallrum_today=nb_ls_today if smallrum==1 
gen nb_poultry_today=nb_ls_today if poultry==1 
gen nb_other_ls_today=nb_ls_today if other_ls==1  
gen nb_cows_today=nb_ls_today if cows==1 
gen nb_chickens_today=nb_ls_today if chickens==1 
gen tlu_1yearago = nb_ls_1yearago * tlu_coefficient
gen tlu_today = nb_ls_today * tlu_coefficient
ren lf02_26 income_live_sales 
ren lf02_25 number_sold 
*Lots of things are valued in between here, but it isn't a complete story.
*So livestock holdings will be valued using observed sales prices.
ren lvstckid livestock_code
recode tlu_* nb_* (.=0)
collapse (sum) tlu_* nb_*  , by (y4_hhid)
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
drop if y4_hhid==""
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_TLU_Coefficients.dta", replace


********************************************************************************
*GROSS CROP REVENUE - ALT 7/6/21
********************************************************************************
*ALT 07.06.21: The preprocessing - including value imputation - is all in the "all plots" section above; this is mostly legacy compatibility stuff
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_all_plots.dta", clear
gen value_harvest_imputed = value_harvest
ren kg_harvest kgs_harvest //ALT 07.19.21: Note to go back and fix this elsewhere
lab var value_harvest_imputed "Imputed value of crop production"
/*replace value_harvest_imputed = kgs_harvest * price_kg_hh if price_kg_hh!=. /* Use observed hh price if it exists */
replace value_harvest_imputed = kgs_harvest * price_kg if value_harvest_imputed==.
replace value_harvest_imputed = value_harvest if value_harvest_imputed==. & crop_code==998 /* "Other" */
replace value_harvest_imputed = 0 if value_harvest_imputed==.
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_values_tempfile.dta", replace 
*/
collapse (sum) value_harvest_imputed kgs_harvest, by (y4_hhid crop_code)
merge 1:1 y4_hhid crop_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_sales.dta", nogen //assert(1 3) <- everything works as expected
preserve
	recode  value_harvest_imputed value_sold kgs_harvest quantity_sold (.=0)
	collapse (sum) value_harvest_imputed value_sold kgs_harvest quantity_sold , by (y4_hhid crop_code)
	ren value_harvest_imputed value_crop_production
	lab var value_crop_production "Gross value of crop production, summed over main and short season"
	ren value_sold value_crop_sales
	lab var value_crop_sales "Value of crops sold so far, summed over main and short season"
	lab var kgs_harvest "Kgs harvested of this crop, summed over main and short season"
	ren quantity_sold kgs_sold
	gen price_kg = value_crop_production/kgs_harvest
	lab var price_kg "Estimated household value of crop per kg, from sales and imputed values" //ALT 07.22.21: Added this var to make the crop processing value calculations work.
	lab var kgs_sold "Kgs sold of this crop, summed over main and short season"
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_values_production.dta", replace
restore
*The file above will be used is the estimation intermediate variables : Gross value of crop production, Total value of crop sold, Total quantity harvested,  

collapse (sum) value_harvest_imputed value_sold, by (y4_hhid)
replace value_harvest_imputed = value_sold if value_sold>value_harvest_imputed & value_sold!=. & value_harvest_imputed!=. /* 155 changes here, suggests big gap between farmer estimated valuation and sales price. */
ren value_harvest_imputed value_crop_production
lab var value_crop_production "Gross value of crop production for this household"
*This is estimated using household value estimated for temporary crop production plus observed sales prices for permanent/tree crops.
*Prices are imputed using local median values when there are no sales.
ren value_sold value_crop_sales
lab var value_crop_sales "Value of crops sold so far"
gen proportion_cropvalue_sold = value_crop_sales / value_crop_production
lab var proportion_cropvalue_sold "Proportion of crop value produced that has been sold"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_production.dta", replace

 /* See all plots file
*Plot value of crop production
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_values_tempfile.dta", clear
collapse (sum) value_harvest_imputed, by (y4_hhid plot_id)
ren value_harvest_imputed plot_value_harvest
lab var plot_value_harvest "Value of crop harvest on this plot"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_cropvalue.dta", replace
*/
*Crop residues (captured only in Tanzania) 
use "${Tanzania_NPS_W4_raw_data}/ag_sec_5a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_5b.dta"

gen residue_sold_yesno = (ag5a_33==7) /* Just 3 observations of sales of crop residue */
ren ag5a_35 value_cropresidue_sales
recode value_cropresidue_sales (.=0)
collapse (sum) value_cropresidue_sales, by (y4_hhid)
lab var value_cropresidue_sales "Value of sales of crop residue (considered an agricultural byproduct)"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_residues.dta", replace

*Crops lost post-harvest
use "${Tanzania_NPS_W4_raw_data}/ag_sec_7a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_7b.dta"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_5a.dta"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_5b.dta" 

ren zaocode crop_code
ren ag7a_16 value_lost
replace value_lost = ag7b_16 if value_lost==.
replace value_lost = ag5a_32 if value_lost==.
replace value_lost = ag5b_32 if value_lost==.
recode value_lost (.=0)
collapse (sum) value_lost, by (y4_hhid crop_code)
merge 1:1 y4_hhid crop_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_values_production.dta", nogen keep(1 3)
replace value_lost = value_crop_production if value_lost > value_crop_production
collapse (sum) value_lost, by (y4_hhid)
ren value_lost crop_value_lost
lab var crop_value_lost "Value of crop production that had been lost by the time of survey"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_losses.dta", replace


********************************************************************************
*LIVESTOCK INCOME
********************************************************************************
*Expenses
use "${Tanzania_NPS_W4_raw_data}/lf_sec_04.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/lf_sec_03.dta"
append using "${Tanzania_NPS_W4_raw_data}/lf_sec_05.dta"
ren lf04_04 cost_fodder_livestock
ren lf04_09 cost_water_livestock
ren lf03_14 cost_vaccines_livestock /* Includes costs of treatment */
ren lf05_07 cost_hired_labor_livestock 
recode cost_fodder_livestock cost_water_livestock cost_vaccines_livestock cost_hired_labor_livestock (.=0)

preserve
keep if lvstckcat == 1
collapse (sum) cost_fodder_livestock cost_water_livestock cost_vaccines_livestock cost_hired_labor_livestock, by (y4_hhid)
egen cost_lrum = rowtotal (cost_fodder_livestock cost_water_livestock cost_vaccines_livestock cost_hired_labor_livestock)
keep y4_hhid cost_lrum
lab var cost_lrum "Livestock expenses for large ruminants"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_lrum_expenses", replace
restore 

preserve 
ren lvstckcat livestock_code
gen species = (inlist(livestock_code,1,2,3,4,5,6)) + 2*(inlist(livestock_code,7,8)) + 3*(livestock_code==9) + 4*(livestock_code==14) + 5*(inlist(livestock_code,10,11,12))
recode species (0=.)
la def species 1 "Large ruminants (cows, buffalos)" 2 "Small ruminants (sheep, goats)" 3 "Pigs" 4 "Equine (horses, donkeys)" 5 "Poultry"
la val species species

collapse (sum) cost_vaccines_livestock, by (y4_hhid species) 
ren cost_vaccines_livestock ls_exp_vac
foreach i in ls_exp_vac{
	gen `i'_lrum = `i' if species==1
	gen `i'_srum = `i' if species==2
	gen `i'_pigs = `i' if species==3
	gen `i'_equine = `i' if species==4
	gen `i'_poultry = `i' if species==5
}
collapse (firstnm) *lrum *srum *pigs *equine *poultry, by(y4_hhid)

foreach i in ls_exp_vac{
	gen `i' = .
}
la var ls_exp_vac "Cost for vaccines and veterinary treatment for livestock"

foreach i in ls_exp_vac{
	local l`i' : var lab `i'
	lab var `i'_lrum "`l`i'' - large ruminants"
	lab var `i'_srum "`l`i'' - small ruminants"
	lab var `i'_pigs "`l`i'' - pigs"
	lab var `i'_equine "`l`i'' - equine"
	lab var `i'_poultry "`l`i'' - poultry"
}
drop ls_exp_vac
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_expenses_animal", replace
restore 
collapse (sum) cost_fodder_livestock cost_water_livestock cost_vaccines_livestock cost_hired_labor_livestock, by (y4_hhid)
lab var cost_water_livestock "Cost for water for livestock"
lab var cost_fodder_livestock "Cost for fodder for livestock"
lab var cost_vaccines_livestock "Cost for vaccines and veterinary treatment for livestock"
lab var cost_hired_labor_livestock "Cost for hired labor for livestock"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_expenses", replace

*Livestock products
use "${Tanzania_NPS_W4_raw_data}/lf_sec_06.dta", clear
ren lvstckcat livestock_code 
keep if livestock_code==1 | livestock_code==2
ren lf06_01 animals_milked
ren lf06_02 months_milked
ren lf06_03 liters_per_day 
recode animals_milked months_milked liters_per_day (.=0)
gen milk_liters_produced = (animals_milked * months_milked * 30 * liters_per_day) /* 30 days per month */
lab var milk_liters_produced "Liters of milk produced in past 12 months"
ren lf06_08 liters_sold_per_day
ren lf06_10 liters_perday_to_cheese 
ren lf06_11 earnings_per_day_milk
recode liters_sold_per_day liters_perday_to_cheese (.=0)
gen liters_sold_day = liters_sold_per_day + liters_perday_to_cheese 
gen price_per_liter = earnings_per_day_milk / liters_sold_day
gen price_per_unit = price_per_liter
gen quantity_produced = milk_liters_produced
recode price_per_liter price_per_unit (0=.) 
gen earnings_milk_year = earnings_per_day_milk*months_milked*30		
keep y4_hhid livestock_code milk_liters_produced price_per_liter price_per_unit quantity_produced earnings_milk_year
lab var price_per_liter "Price of milk per liter sold"
lab var price_per_unit "Price of milk per unit sold"
lab var quantity_produced "Quantity of milk produced"
lab var earnings_milk_year "Total earnings of sale of milk produced"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products_milk", replace

use "${Tanzania_NPS_W4_raw_data}/lf_sec_08.dta", clear
ren productid livestock_code
ren lf08_02 months_produced
ren lf08_03_1 quantity_month
ren lf08_03_2 quantity_month_unit
replace quantity_month_unit = 3 if livestock_code==1
replace quantity_month_unit = 1 if livestock_code==2
replace quantity_month_unit = 3 if livestock_code==3
recode months_produced quantity_month (.=0)
gen quantity_produced = months_produced * quantity_month /* Units are pieces for eggs & skin, liters for honey */
lab var quantity_produced "Quantity of this product produed in past year"
ren lf08_05_1 sales_quantity
ren lf08_05_2 sales_unit
replace sales_unit = 3 if livestock_code==1
replace sales_unit = 1 if livestock_code==2
replace sales_unit = 3 if livestock_code==3
ren lf08_06 earnings_sales
recode sales_quantity months_produced quantity_month earnings_sales (.=0)
gen price_per_unit = earnings_sales / sales_quantity
keep y4_hhid livestock_code quantity_produced price_per_unit earnings_sales
replace livestock_code = 21 if livestock_code==1
replace livestock_code = 22 if livestock_code==2
replace livestock_code = 23 if livestock_code==3
label define livestock_code_label 21 "Eggs" 22 "Honey" 23 "Skins"
label values livestock_code livestock_code_label
bys livestock_code: sum price_per_unit
gen price_per_unit_hh = price_per_unit
lab var price_per_unit "Price of milk per unit sold"
lab var price_per_unit_hh "Price of milk per unit sold at household level"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products_other", replace

use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products_milk", clear
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products_other"
recode price_per_unit (0=.)
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta"
drop if _merge==2
drop _merge
replace price_per_unit = . if price_per_unit == 0 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products", replace

use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products", clear
keep if price_per_unit !=. 
gen observation = 1
bys region district ward ea livestock_code: egen obs_ea = count(observation)
collapse (median) price_per_unit [aw=weight], by (region district ward ea livestock_code obs_ea)
ren price_per_unit price_median_ea
lab var price_median_ea "Median price per unit for this livestock product in the ea"
lab var obs_ea "Number of sales observations for this livestock product in the ea"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products_prices_ea.dta", replace
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys region district ward livestock_code: egen obs_ward = count(observation)
collapse (median) price_per_unit [aw=weight], by (region district ward livestock_code obs_ward)
ren price_per_unit price_median_ward
lab var price_median_ward "Median price per unit for this livestock product in the ward"
lab var obs_ward "Number of sales observations for this livestock product in the ward"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products_prices_ward.dta", replace
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys region district livestock_code: egen obs_district = count(observation)
collapse (median) price_per_unit [aw=weight], by (region district livestock_code obs_district)
ren price_per_unit price_median_district
lab var price_median_district "Median price per unit for this livestock product in the district"
lab var obs_district "Number of sales observations for this livestock product in the district"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products_prices_district.dta", replace
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys region livestock_code: egen obs_region = count(observation)
collapse (median) price_per_unit [aw=weight], by (region livestock_code obs_region)
ren price_per_unit price_median_region
lab var price_median_region "Median price per unit for this livestock product in the region"
lab var obs_region "Number of sales observations for this livestock product in the region"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products_prices_region.dta", replace
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products", clear
keep if price_per_unit !=.
gen observation = 1
bys livestock_code: egen obs_country = count(observation)
collapse (median) price_per_unit [aw=weight], by (livestock_code obs_country)
ren price_per_unit price_median_country
lab var price_median_country "Median price per unit for this livestock product in the country"
lab var obs_country "Number of sales observations for this livestock product in the country"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products_prices_country.dta", replace

use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products", clear
merge m:1 region district ward ea livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products_prices_ea.dta", nogen
merge m:1 region district ward livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products_prices_ward.dta", nogen
merge m:1 region district livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products_prices_district.dta", nogen
merge m:1 region livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products_prices_region.dta", nogen
merge m:1 livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_products_prices_country.dta", nogen
replace price_per_unit = price_median_ea if price_per_unit==. & obs_ea >= 10
replace price_per_unit = price_median_ward if price_per_unit==. & obs_ward >= 10
replace price_per_unit = price_median_district if price_per_unit==. & obs_district >= 10 
replace price_per_unit = price_median_region if price_per_unit==. & obs_region >= 10 
replace price_per_unit = price_median_country if price_per_unit==.
lab var price_per_unit "Price per unit of this livestock product, with missing values imputed using local median values"
gen price_cowmilk_med = price_median_country if livestock_code==1
egen price_cowmilk = max(price_cowmilk_med)
replace price_per_unit = price_cowmilk if livestock_code==2
lab var price_per_unit "Price per liter (milk) or per egg/liter/container honey, imputed with local median prices if household did not sell"
gen value_milk_produced = milk_liters_produced * price_per_unit 
gen value_eggs_produced = quantity_produced * price_per_unit if livestock_code==21
gen value_other_produced = quantity_produced * price_per_unit if livestock_code==22 | livestock_code==23
egen sales_livestock_products = rowtotal(earnings_sales earnings_milk_year)		

collapse (sum) value_milk_produced value_eggs_produced value_other_produced sales_livestock_products, by (y4_hhid)
*First, constructing total value
egen value_livestock_products = rowtotal(value_milk_produced value_eggs_produced value_other_produced)
lab var value_livestock_products "value of livesotck prodcuts produced (milk, eggs, other)"
*Now, the share
gen share_livestock_prod_sold = sales_livestock_products/value_livestock_products
replace share_livestock_prod_sold = 1 if share_livestock_prod_sold>1 & share_livestock_prod_sold!=.
lab var share_livestock_prod_sold "Percent of production of livestock products that is sold" 
lab var value_milk_produced "Value of milk produced"
lab var value_eggs_produced "Value of eggs produced"
lab var value_other_produced "Value of honey and skins produced"
recode value_milk_produced value_eggs_produced value_other_produced (0=.)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_livestock_products", replace
 
use "${Tanzania_NPS_W4_raw_data}/lf_sec_07.dta", clear
ren lf07_03 sales_dung
recode sales_dung (.=0)
collapse (sum) sales_dung, by (y4_hhid)
lab var sales_dung "Value of dung sold" 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_dung.dta", replace

*Sales (live animals)
use "${Tanzania_NPS_W4_raw_data}/lf_sec_02.dta", clear
ren lvstckid livestock_code
ren lf02_26 income_live_sales 
ren lf02_25 number_sold 
ren lf02_30 number_slaughtered 
ren lf02_32 number_slaughtered_sold 
replace number_slaughtered = number_slaughtered_sold if number_slaughtered < number_slaughtered_sold  
ren lf02_33 income_slaughtered
ren lf02_08 value_livestock_purchases
recode income_live_sales number_sold number_slaughtered number_slaughtered_sold income_slaughtered number_slaughtered_sold value_livestock_purchases (.=0)
gen price_per_animal = income_live_sales / number_sold
lab var price_per_animal "Price of live animale sold"
recode price_per_animal (0=.) 
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta"
drop if _merge==2
drop _merge
keep y4_hhid weight region district ward ea livestock_code number_sold income_live_sales number_slaughtered number_slaughtered_sold income_slaughtered price_per_animal value_livestock_purchases
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_livestock_sales", replace

*Implicit prices
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region district ward ea livestock_code: egen obs_ea = count(observation)
collapse (median) price_per_animal [aw=weight], by (region district ward ea livestock_code obs_ea)
ren price_per_animal price_median_ea
lab var price_median_ea "Median price per unit for this livestock in the ea"
lab var obs_ea "Number of sales observations for this livestock in the ea"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_ea.dta", replace
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region district ward livestock_code: egen obs_ward = count(observation)
collapse (median) price_per_animal [aw=weight], by (region district ward livestock_code obs_ward)
ren price_per_animal price_median_ward
lab var price_median_ward "Median price per unit for this livestock in the ward"
lab var obs_ward "Number of sales observations for this livestock in the ward"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_ward.dta", replace
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region district livestock_code: egen obs_district = count(observation)
collapse (median) price_per_animal [aw=weight], by (region district livestock_code obs_district)
ren price_per_animal price_median_district
lab var price_median_district "Median price per unit for this livestock in the district"
lab var obs_district "Number of sales observations for this livestock in the district"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_district.dta", replace
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys region livestock_code: egen obs_region = count(observation)
collapse (median) price_per_animal [aw=weight], by (region livestock_code obs_region)
ren price_per_animal price_median_region
lab var price_median_region "Median price per unit for this livestock in the region"
lab var obs_region "Number of sales observations for this livestock in the region"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_region.dta", replace
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_livestock_sales", clear
keep if price_per_animal !=.
gen observation = 1
bys livestock_code: egen obs_country = count(observation)
collapse (median) price_per_animal [aw=weight], by (livestock_code obs_country)
ren price_per_animal price_median_country
lab var price_median_country "Median price per unit for this livestock in the country"
lab var obs_country "Number of sales observations for this livestock in the country"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_country.dta", replace

use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_livestock_sales", clear
merge m:1 region district ward ea livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_ea.dta", nogen
merge m:1 region district ward livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_ward.dta", nogen
merge m:1 region district livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_district.dta", nogen
merge m:1 region livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_region.dta", nogen
merge m:1 livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_country.dta", nogen
replace price_per_animal = price_median_ea if price_per_animal==. & obs_ea >= 10
replace price_per_animal = price_median_ward if price_per_animal==. & obs_ward >= 10
replace price_per_animal = price_median_district if price_per_animal==. & obs_district >= 10
replace price_per_animal = price_median_region if price_per_animal==. & obs_region >= 10
replace price_per_animal = price_median_country if price_per_animal==. 
lab var price_per_animal "Price per animal sold, imputed with local median prices if household did not sell"
gen value_lvstck_sold = price_per_animal * number_sold
gen value_slaughtered = price_per_animal * number_slaughtered
gen value_slaughtered_sold = price_per_animal * number_slaughtered_sold 
* gen value_slaughtered_sold = income_slaughtered 
replace value_slaughtered_sold = income_slaughtered if (value_slaughtered_sold < income_slaughtered) & number_slaughtered!=0 /* Replace value of slaughtered animals with income from slaughtered-sales if the latter is larger */
replace value_slaughtered = value_slaughtered_sold if (value_slaughtered_sold > value_slaughtered) & (number_slaughtered > number_slaughtered_sold) //replace value of slaughtered with value of slaughtered sold if value sold is larger
gen value_livestock_sales = value_lvstck_sold + value_slaughtered_sold
collapse (sum) value_livestock_sales value_livestock_purchases value_lvstck_sold value_slaughtered, by (y4_hhid)
drop if y4_hhid==""
lab var value_livestock_sales "Value of livestock sold (live and slaughtered)"
lab var value_livestock_purchases "Value of livestock purchases (seems to span only the agricutlural season, not the year)"
lab var value_slaughtered "Value of livestock slaughtered (with slaughtered livestock that weren't sold valued at local median prices for live animal sales)"
lab var value_lvstck_sold "Value of livestock sold live" 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_sales", replace
 
*TLU (Tropical Livestock Units)
use "${Tanzania_NPS_W4_raw_data}/lf_sec_02.dta", clear
gen tlu_coefficient=0.5 if (lvstckid==1|lvstckid==2|lvstckid==3|lvstckid==4|lvstckid==5|lvstckid==6)
replace tlu_coefficient=0.1 if (lvstckid==7|lvstckid==8)
replace tlu_coefficient=0.2 if (lvstckid==9)
replace tlu_coefficient=0.01 if (lvstckid==10|lvstckid==11|lvstckid==12|lvstckid==13)
replace tlu_coefficient=0.3 if (lvstckid==14)
lab var tlu_coefficient "Tropical Livestock Unit coefficient"
ren lvstckid livestock_code
ren lf02_03 number_1yearago
ren lf02_04_1 number_today_indigenous
ren lf02_04_2 number_today_exotic
recode number_today_indigenous number_today_exotic (.=0)
gen number_today = number_today_indigenous + number_today_exotic
gen tlu_1yearago = number_1yearago * tlu_coefficient
gen tlu_today = number_today * tlu_coefficient
ren lf02_26 income_live_sales 
ren lf02_25 number_sold 
ren lf02_16 lost_disease
ren lf02_22 lost_injury 
egen mean_12months = rowmean(number_today number_1yearago)
egen animals_lost12months = rowtotal(lost_disease lost_injury)
gen share_imp_herd_cows = number_today_exotic/(number_today) if livestock_code==2
gen species = (inlist(livestock_code,1,2,3,4,5,6)) + 2*(inlist(livestock_code,7,8)) + 3*(livestock_code==9) + 4*(livestock_code==14) + 5*(inlist(livestock_code,10,11,12))
recode species (0=.)
la def species 1 "Large ruminants (cows, buffalos)" 2 "Small ruminants (sheep, goats)" 3 "Pigs" 4 "Equine (horses, donkeys)" 5 "Poultry"
la val species species

preserve
*Now to household level
*First, generating these values by species
collapse (firstnm) share_imp_herd_cows (sum) number_today number_1yearago animals_lost12months lost_disease number_today_exotic lvstck_holding=number_today, by(y4_hhid species)
egen mean_12months = rowmean(number_today number_1yearago)
gen any_imp_herd = number_today_exotic!=0 if number_today!=. & number_today!=0

foreach i in animals_lost12months mean_12months any_imp_herd lvstck_holding lost_disease {
	gen `i'_lrum = `i' if species==1
	gen `i'_srum = `i' if species==2
	gen `i'_pigs = `i' if species==3
	gen `i'_equine = `i' if species==4
	gen `i'_poultry = `i' if species==5
}
*Now we can collapse to household (taking firstnm because these variables are only defined once per household)
collapse (sum) number_today number_today_exotic (firstnm) *lrum *srum *pigs *equine *poultry share_imp_herd_cows, by(y4_hhid)

*Overall any improved herd
gen any_imp_herd = number_today_exotic!=0 if number_today!=0
drop number_today_exotic number_today

foreach i in lvstck_holding animals_lost12months mean_12months lost_disease {
	gen `i' = .
}
la var lvstck_holding "Total number of livestock holdings (# of animals)"
la var any_imp_herd "At least one improved animal in herd"
la var share_imp_herd_cows "Share of improved animals in total herd - Cows only"
lab var animals_lost12months  "Total number of livestock  lost to disease or injury"
lab var  mean_12months  "Average number of livestock  today and 1  year ago"
lab var lost_disease "Total number of livestock lost to disease" 

foreach i in any_imp_herd lvstck_holding animals_lost12months mean_12months lost_disease {
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
drop lvstck_holding animals_lost12months mean_12months lost_disease 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_herd_characteristics", replace
restore

gen price_per_animal = income_live_sales / number_sold
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta", nogen keep(1 3)
merge m:1 region district ward ea livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_ea.dta", nogen
merge m:1 region district ward livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_ward.dta", nogen
merge m:1 region district livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_district.dta", nogen
merge m:1 region livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_region.dta", nogen
merge m:1 livestock_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_prices_country.dta", nogen
recode price_per_animal (0=.)
replace price_per_animal = price_median_ea if price_per_animal==. & obs_ea >= 10
replace price_per_animal = price_median_ward if price_per_animal==. & obs_ward >= 10
replace price_per_animal = price_median_district if price_per_animal==. & obs_district >= 10
replace price_per_animal = price_median_region if price_per_animal==. & obs_region >= 10
replace price_per_animal = price_median_country if price_per_animal==. 
lab var price_per_animal "Price per animal sold, imputed with local median prices if household did not sell"
gen value_1yearago = number_1yearago * price_per_animal
gen value_today = number_today * price_per_animal
collapse (sum) tlu_1yearago tlu_today value_1yearago value_today, by (y4_hhid)
lab var tlu_1yearago "Tropical Livestock Units as of 12 months ago"
lab var tlu_today "Tropical Livestock Units as of the time of survey"
gen lvstck_holding_tlu = tlu_today
lab var lvstck_holding_tlu "Total HH livestock holdings, TLU"  
lab var value_1yearago "Value of livestock holdings from one year ago"
lab var value_today "Value of livestock holdings today"
drop if y4_hhid==""
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_TLU.dta", replace

*Livestock income
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_sales", clear
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_livestock_products", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_dung.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_expenses", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_TLU.dta", nogen
gen livestock_income = value_lvstck_sold + value_slaughtered - value_livestock_purchases /*
*/ + (value_milk_produced + value_eggs_produced + value_other_produced + sales_dung) /*
*/ - (cost_hired_labor_livestock + cost_fodder_livestock + cost_vaccines_livestock + cost_water_livestock)
lab var livestock_income "Net livestock income"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_income", replace


********************************************************************************
*FISH INCOME
********************************************************************************
*Fishing expenses
use "${Tanzania_NPS_W4_raw_data}/lf_sec_09.dta", clear
ren lf09_02_1 weeks_fishing
ren lf09_02_2 days_per_week
recode weeks_fishing days_per_week (.=0)
collapse (max) weeks_fishing days_per_week, by (y4_hhid) 
keep y4_hhid weeks_fishing days_per_week
lab var weeks_fishing "Weeks spent working as a fisherman (maximum observed across individuals in household)"
lab var days_per_week "Days per week spent working as a fisherman (maximum observed across individuals in household)"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_weeks_fishing.dta", replace

use "${Tanzania_NPS_W4_raw_data}/lf_sec_11a.dta", clear
ren lf11_03 weeks
ren lf11_07 fuel_costs_week
ren lf11_08 rental_costs_fishing 
recode weeks fuel_costs_week rental_costs_fishing (.=0)
gen cost_fuel = fuel_costs_week * weeks
collapse (sum) cost_fuel rental_costs_fishing, by (y4_hhid)
lab var cost_fuel "Costs for fuel over the past year"
lab var rental_costs_fishing "Costs for other fishing expenses over the past year"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fishing_expenses_1.dta", replace

use "${Tanzania_NPS_W4_raw_data}/lf_sec_11b.dta", clear
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_weeks_fishing.dta"
gen cost = lf11b_10_1 if lf11b_10_1>=4 
ren lf11b_10_2 unit
gen cost_paid = cost if unit==4 | unit==3
replace cost_paid = cost * weeks_fishing if unit==2
replace cost_paid = cost * weeks_fishing * days_per_week if unit==1
collapse (sum) cost_paid, by (y4_hhid)
lab var cost_paid "Other costs paid for fishing activities"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fishing_expenses_2.dta", replace

use "${Tanzania_NPS_W4_raw_data}/lf_sec_12.dta", clear
ren lf12_02_3 fish_code 
drop if fish_code==. 
ren lf12_05_1 fish_quantity_year
ren lf12_05_2 fish_quantity_unit
ren lf12_12_2 unit 
gen price_per_unit = lf12_12_4/lf12_12_1 
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta"
drop if _merge==2
drop _merge
recode price_per_unit (0=.) 
collapse (median) price_per_unit [aw=weight], by (fish_code unit)
ren price_per_unit price_per_unit_median
replace price_per_unit_median = . if fish_code==33
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fish_prices.dta", replace

use "${Tanzania_NPS_W4_raw_data}/lf_sec_12.dta", clear
ren lf12_02_3 fish_code 
drop if fish_code==. 
ren lf12_05_1 fish_quantity_year
ren lf12_05_2 unit
merge m:1 fish_code unit using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fish_prices.dta"
drop if _merge==2
drop _merge
ren lf12_12_1 quantity_1
ren lf12_12_2 unit_1
gen price_unit_1 = lf12_12_4/quantity_1
ren lf12_12_5 quantity_2
ren lf12_12_6 unit_2
gen price_unit_2 = lf12_12_8/quantity_2
recode quantity_1 quantity_2 fish_quantity_year (.=0)
gen income_fish_sales = (quantity_1 * price_unit_1) + (quantity_2 * price_unit_2)
gen value_fish_harvest = (fish_quantity_year * price_unit_1) if unit==unit_1 
replace value_fish_harvest = (fish_quantity_year * price_per_unit_median) if value_fish_harvest==.
collapse (sum) value_fish_harvest income_fish_sales, by (y4_hhid)
recode value_fish_harvest income_fish_sales (.=0)
lab var value_fish_harvest "Value of fish harvest (including what is sold), with values imputed using a national median for fish-unit-prices"
lab var income_fish_sales "Value of fish sales"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fish_income.dta", replace


********************************************************************************
*SELF-EMPLOYMENT INCOME
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/hh_sec_n.dta", clear
ren hh_n19 months_activ
ren hh_n20 monthly_profit
gen annual_selfemp_profit = monthly_profit * months_activ
recode annual_selfemp_profit (.=0)
collapse (sum) annual_selfemp_profit, by (y4_hhid)
lab var annual_selfemp_profit "Estimated annual net profit from self-employment over previous 12 months"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_self_employment_income.dta", replace

*Processed crops 
use "${Tanzania_NPS_W4_raw_data}/ag_sec_10.dta", clear
ren zaocode crop_code
ren zaoname crop_name
ren ag10_06 byproduct_sold_yesno
ren ag10_07_1 byproduct_quantity
ren ag10_07_2 byproduct_unit
ren ag10_08 kgs_used_in_byproduct 
ren ag10_11 byproduct_price_received
ren ag10_13 other_expenses_yesno
ren ag10_14 byproduct_other_costs
merge m:1 y4_hhid crop_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_values_production.dta", nogen keep(1 3)
recode byproduct_quantity kgs_used_in_byproduct byproduct_other_costs (.=0)
gen byproduct_sales = byproduct_quantity * byproduct_price_received
gen byproduct_crop_cost = kgs_used_in_byproduct * price_kg
gen byproduct_profits = byproduct_sales - (byproduct_crop_cost + byproduct_other_costs)
collapse (sum) byproduct_profits, by (y4_hhid)
lab var byproduct_profits "Net profit from sales of agricultural processed products or byproducts"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_agproducts_profits.dta", replace

*Fish trading
use "${Tanzania_NPS_W4_raw_data}/lf_sec_09.dta", clear
ren lf09_04_1 weeks_fish_trading 
recode weeks_fish_trading (.=0)
collapse (max) weeks_fish_trading, by (y4_hhid) 
keep y4_hhid weeks_fish_trading
lab var weeks_fish_trading "Weeks spent working as a fish trader (maximum observed across individuals in household)"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_weeks_fish_trading.dta", replace

use "${Tanzania_NPS_W4_raw_data}/lf_sec_13a.dta", clear
ren lf13a_03_1 quant_fish_purchased_1
ren lf13a_03_4 price_fish_purchased_1
ren lf13a_03_5 quant_fish_purchased_2
ren lf13a_03_8 price_fish_purchased_2
ren lf13a_04_1 quant_fish_sold_1
ren lf13a_04_4 price_fish_sold_1
ren lf13a_04_5 quant_fish_sold_2
ren lf13a_04_8 price_fish_sold_2
recode quant_fish_purchased_1 price_fish_purchased_1 quant_fish_purchased_2 price_fish_purchased_2 /*
*/ quant_fish_sold_1 price_fish_sold_1 quant_fish_sold_2 price_fish_sold_2 (.=0)
gen weekly_fishtrade_costs = (quant_fish_purchased_1 * price_fish_purchased_1) + (quant_fish_purchased_2 * price_fish_purchased_2)
gen weekly_fishtrade_revenue = (quant_fish_sold_1 * price_fish_sold_1) + (quant_fish_sold_2 * price_fish_sold_2)
gen weekly_fishtrade_profit = weekly_fishtrade_revenue - weekly_fishtrade_costs
collapse (sum) weekly_fishtrade_profit, by (y4_hhid)
lab var weekly_fishtrade_profit "Average weekly profits from fish trading (sales minus purchases), summed across individuals"
keep y4_hhid weekly_fishtrade_profit
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fish_trading_revenue.dta", replace

use "${Tanzania_NPS_W4_raw_data}/lf_sec_13b.dta", clear
ren lf13b_06 weekly_costs_for_fish_trading
recode weekly_costs_for_fish_trading (.=0)
collapse (sum) weekly_costs_for_fish_trading, by (y4_hhid)
lab var weekly_costs_for_fish_trading "Weekly costs associated with fish trading, in addition to purchase of fish"
keep y4_hhid weekly_costs_for_fish_trading
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fish_trading_other_costs.dta", replace

use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_weeks_fish_trading.dta", clear
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fish_trading_revenue.dta" 
drop _merge
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fish_trading_other_costs.dta"
drop _merge
replace weekly_fishtrade_profit = weekly_fishtrade_profit - weekly_costs_for_fish_trading
gen fish_trading_income = (weeks_fish_trading * weekly_fishtrade_profit)
lab var fish_trading_income "Estimated net household earnings from fish trading over previous 12 months"
keep y4_hhid fish_trading_income
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fish_trading_income.dta", replace


********************************************************************************
*NON-AG WAGE INCOME
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/hh_sec_e.dta", clear
ren hh_e04ab wage_yesno
ren hh_e29 number_months
ren hh_e30 number_weeks
ren hh_e31 number_hours
ren hh_e26_1 most_recent_payment
replace most_recent_payment = . if (hh_e20_2=="921" | hh_e20_2=="611" | hh_e20_2=="612" | hh_e20_2=="613" | hh_e20_2=="614" | hh_e20_2=="621")
ren hh_e26_2 payment_period
ren hh_e28_1 most_recent_payment_other
replace most_recent_payment_other = . if (hh_e20_2=="921" | hh_e20_2=="611" | hh_e20_2=="612" | hh_e20_2=="613" | hh_e20_2=="614" | hh_e20_2=="621")
ren hh_e28_2 payment_period_other
ren hh_e36 secondary_wage_yesno
ren hh_e44_1 secwage_most_recent_payment
replace secwage_most_recent_payment = . if (hh_e20_2=="921" | hh_e20_2=="611" | hh_e20_2=="612" | hh_e20_2=="613" | hh_e20_2=="614" | hh_e20_2=="621")
ren hh_e44_2 secwage_payment_period
ren hh_e46_1 secwage_recent_payment_other
ren hh_e46_2 secwage_payment_period_other
ren hh_e50 secwage_hours_pastweek
gen annual_salary_cash = most_recent_payment if payment_period==8
replace annual_salary_cash = ((number_months/6)*most_recent_payment) if payment_period==7
replace annual_salary_cash = ((number_months/4)*most_recent_payment) if payment_period==6
replace annual_salary_cash = (number_months*most_recent_payment) if payment_period==5
replace annual_salary_cash = (number_months*(number_weeks/2)*most_recent_payment) if payment_period==4
replace annual_salary_cash = (number_months*number_weeks*most_recent_payment) if payment_period==3
replace annual_salary_cash = (number_months*number_weeks*(number_hours/8)*most_recent_payment) if payment_period==2
replace annual_salary_cash = (number_months*number_weeks*number_hours*most_recent_payment) if payment_period==1
gen wage_salary_other = most_recent_payment_other if payment_period_other==8
replace wage_salary_other = ((number_months/6)*most_recent_payment_other) if payment_period_other==7
replace wage_salary_other = ((number_months/4)*most_recent_payment_other) if payment_period_other==6
replace wage_salary_other = (number_months*most_recent_payment_other) if payment_period_other==5
replace wage_salary_other = (number_months*(number_weeks/2)*most_recent_payment_other) if payment_period_other==4
replace wage_salary_other = (number_months*number_weeks*most_recent_payment_other) if payment_period_other==3
replace wage_salary_other = (number_months*number_weeks*(number_hours/8)*most_recent_payment_other) if payment_period_other==2
replace wage_salary_other = (number_months*number_weeks*number_hours*most_recent_payment_other) if payment_period_other==1
recode annual_salary_cash wage_salary_other (.=0)
gen annual_salary = annual_salary_cash + wage_salary_other
tab secwage_payment_period
collapse (sum) annual_salary, by (y4_hhid)
lab var annual_salary "Annual earnings from non-agricultural wage"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_wage_income.dta", replace


********************************************************************************
*AG WAGE INCOME
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/hh_sec_e.dta", clear
ren hh_e04ab wage_yesno
ren hh_e29 number_months
ren hh_e30 number_weeks
ren hh_e31 number_hours
ren hh_e26_1 most_recent_payment
gen agwage = 1 if (hh_e20_2=="921" | hh_e20_2=="611" | hh_e20_2=="612" | hh_e20_2=="613" | hh_e20_2=="614" | hh_e20_2=="621")
gen secagwage = 1 if (hh_e38_2=="921" | hh_e38_2=="611" | hh_e38_2=="612" | hh_e38_2=="613" | hh_e38_2=="614" | hh_e38_2=="621")
replace most_recent_payment = . if agwage!=1
ren hh_e26_2 payment_period
ren hh_e28_1 most_recent_payment_other
replace most_recent_payment_other = . if agwage!=1
ren hh_e28_2 payment_period_other
ren hh_e36 secondary_wage_yesno
ren hh_e44_1 secwage_most_recent_payment
replace secwage_most_recent_payment = . if secagwage!=1
ren hh_e44_2 secwage_payment_period
ren hh_e46_1 secwage_recent_payment_other
ren hh_e46_2 secwage_payment_period_other
ren hh_e50 secwage_hours_pastweek
gen annual_salary_cash = most_recent_payment if payment_period==8
replace annual_salary_cash = ((number_months/6)*most_recent_payment) if payment_period==7
replace annual_salary_cash = ((number_months/4)*most_recent_payment) if payment_period==6
replace annual_salary_cash = (number_months*most_recent_payment) if payment_period==5
replace annual_salary_cash = (number_months*(number_weeks/2)*most_recent_payment) if payment_period==4
replace annual_salary_cash = (number_months*number_weeks*most_recent_payment) if payment_period==3
replace annual_salary_cash = (number_months*number_weeks*(number_hours/8)*most_recent_payment) if payment_period==2
replace annual_salary_cash = (number_months*number_weeks*number_hours*most_recent_payment) if payment_period==1
gen wage_salary_other = most_recent_payment_other if payment_period_other==8
replace wage_salary_other = ((number_months/6)*most_recent_payment_other) if payment_period_other==7
replace wage_salary_other = ((number_months/4)*most_recent_payment_other) if payment_period_other==6
replace wage_salary_other = (number_months*most_recent_payment_other) if payment_period_other==5
replace wage_salary_other = (number_months*(number_weeks/2)*most_recent_payment_other) if payment_period_other==4
replace wage_salary_other = (number_months*number_weeks*most_recent_payment_other) if payment_period_other==3
replace wage_salary_other = (number_months*number_weeks*(number_hours/8)*most_recent_payment_other) if payment_period_other==2
replace wage_salary_other = (number_months*number_weeks*number_hours*most_recent_payment_other) if payment_period_other==1
recode annual_salary_cash wage_salary_other (.=0)
gen annual_salary = annual_salary_cash + wage_salary_other
collapse (sum) annual_salary, by (y4_hhid)
ren annual_salary annual_salary_agwage
lab var annual_salary_agwage "Annual earnings from agricultural wage"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_agwage_income.dta", replace


********************************************************************************
*OTHER INCOME
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/hh_sec_q1.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/hh_sec_q2.dta"
append using "${Tanzania_NPS_W4_raw_data}/hh_sec_o1.dta"
ren hh_q06 rental_income
ren hh_q07 pension_income
ren hh_q08 other_income
ren hh_q23 cash_received
ren hh_q26 inkind_gifts_received
ren hh_o03 assistance_cash
ren hh_o04 assistance_food
ren hh_o05 assistance_inkind
recode rental_income pension_income other_income cash_received inkind_gifts_received assistance_cash assistance_food assistance_inkind (.=0)
gen remittance_income = cash_received + inkind_gifts_received
gen assistance_income = assistance_cash + assistance_food + assistance_inkind
collapse (sum) rental_income pension_income other_income remittance_income assistance_income, by (y4_hhid)
lab var rental_income "Estimated income from rentals of buildings, tools, land, transport animals over previous 12 months"
lab var pension_income "Estimated income from a pension AND INTEREST over previous 12 months"
lab var other_income "Estimated income from any OTHER source over previous 12 months"
lab var remittance_income "Estimated income from remittances over previous 12 months"
lab var assistance_income "Estimated income from a food aid, food-for-work, etc. over previous 12 months"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_other_income.dta", replace

use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
ren ag3a_04 land_rental_income_mainseason
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta"
ren ag3b_04 land_rental_income_shortseason
recode land_rental_income_mainseason land_rental_income_shortseason (.=0)
gen land_rental_income = land_rental_income_mainseason + land_rental_income_shortseason
collapse (sum) land_rental_income, by (y4_hhid)
lab var land_rental_income "Estimated income from renting out land over previous 12 months"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_rental_income.dta", replace


********************************************************************************
*FARM SIZE / LAND SIZE
********************************************************************************
*Determining whether crops were grown on a plot
use "${Tanzania_NPS_W4_raw_data}/ag_sec_4a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_4b.dta"
ren plotnum plot_id
drop if plot_id==""
drop if zaocode==.
gen crop_grown = 1 
collapse (max) crop_grown, by(y4_hhid plot_id)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crops_grown.dta", replace

use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta"
gen cultivated = (ag3a_03==1 | ag3b_03==1)
ren plotnum plot_id
collapse (max) cultivated, by (y4_hhid plot_id)
lab var cultivated "1= Parcel was cultivated in this data set"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_parcels_cultivated.dta", replace

use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_parcels_cultivated.dta", clear
merge 1:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_areas.dta"
drop if _merge==2
keep if cultivated==1
replace area_acres_meas=. if area_acres_meas<0 
replace area_acres_meas = area_acres_est if area_acres_meas==. 
collapse (sum) area_acres_meas, by (y4_hhid)
ren area_acres_meas farm_area
replace farm_area = farm_area * (1/2.47105) /* Convert to hectares */
lab var farm_area "Land size (denominator for land productivitiy), in hectares" 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_size.dta", replace

*All agricultural land
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta"
ren plotnum plot_id
drop if plot_id==""
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crops_grown.dta", nogen
*6,862 matched
*1,704 not matched (from master)
gen rented_out = (ag3a_03==2 | ag3a_03==3 | ag3b_03==2 | ag3b_03==3)
gen cultivated_short = (ag3b_03==1)
bys y4_hhid plot_id: egen plot_cult_short = max(cultivated_short)
replace rented_out = 0 if plot_cult_short==1 // If cultivated in short season, not considered rented out in long season.
*drop if rented_out==1
*62 obs dropped
drop if rented_out==1 & crop_grown!=1
*56 obs dropped
gen agland = (ag3a_03==1 | ag3a_03==4 | ag3b_03==1 | ag3b_03==4) // All cultivated AND fallow plots, pasture is captured within "other" (can't be separated out)
*keep if agland==1
*4,360 obs dropped 
drop if agland!=1 & crop_grown==.
*907 obs dropped
collapse (max) agland, by (y4_hhid plot_id)
lab var agland "1= Parcel was used for crop cultivation or left fallow in this past year (forestland and other uses excluded)"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_parcels_agland.dta", replace

use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_parcels_agland.dta", clear
merge 1:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_areas.dta"
drop if _merge==2
replace area_acres_meas=. if area_acres_meas<0
replace area_acres_meas = area_acres_est if area_acres_meas==. 
replace area_acres_meas = area_acres_est if area_acres_meas==0 & (area_acres_est>0 & area_acres_est!=.)	
collapse (sum) area_acres_meas, by (y4_hhid)
ren area_acres_meas farm_size_agland
replace farm_size_agland = farm_size_agland * (1/2.47105) /* Convert to hectares */
lab var farm_size_agland "Land size in hectares, including all plots cultivated or left fallow" 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_farmsize_all_agland.dta", replace

use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta"
ren plotnum plot_id
drop if plot_id==""
gen rented_out = (ag3a_03==2 | ag3a_03==3 | ag3b_03==2 | ag3b_03==3)
gen cultivated_short = (ag3b_03==1)
bys y4_hhid plot_id: egen plot_cult_short = max(cultivated_short)
replace rented_out = 0 if plot_cult_short==1 // If cultivated in short season, not considered rented out in long season.
drop if rented_out==1
gen plot_held = 1
collapse (max) plot_held, by (y4_hhid plot_id)
lab var plot_held "1= Parcel was NOT rented out in the main season"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_parcels_held.dta", replace

use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_parcels_held.dta", clear
merge 1:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_areas.dta"
drop if _merge==2
replace area_acres_meas=. if area_acres_meas<0
replace area_acres_meas = area_acres_est if area_acres_meas==. 
collapse (sum) area_acres_meas, by (y4_hhid)
ren area_acres_meas land_size
replace land_size = land_size * (1/2.47105) /* Convert to hectares */
lab var land_size "Land size in hectares, including all plots listed by the household except those rented out" 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_size_all.dta", replace

*Total land holding including cultivated and rented out
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta"
ren plotnum plot_id
drop if plot_id==""
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_areas.dta", nogen keep(1 3)
replace area_acres_meas=. if area_acres_meas<0
replace area_acres_meas = area_acres_est if area_acres_meas==. 
replace area_acres_meas = area_acres_est if area_acres_meas==0 & (area_acres_est>0 & area_acres_est!=.)	
collapse (max) area_acres_meas, by(y4_hhid plot_id)
ren area_acres_meas land_size_total
collapse (sum) land_size_total, by(y4_hhid)
replace land_size_total = land_size_total * (1/2.47105) /* Convert to hectares */
lab var land_size_total "Total land size in hectares, including rented in and rented out plots"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_size_total.dta", replace

/*DYA.10.26.2020 OLD
********************************************************************************
*OFF-FARM HOURS
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/hh_sec_e.dta", clear
gen primary_hours = hh_e32 if hh_e21_2>9 & hh_e21_2!=.	
gen secondary_hours = hh_e50 if hh_e39_2>9 & hh_e39_2!=.
gen ownbiz_hours =  hh_e64
egen off_farm_hours = rowtotal(primary_hours secondary_hours ownbiz_hours)
gen off_farm_any_count = off_farm_hours!=0
gen member_count = 1
collapse (sum) off_farm_hours off_farm_any_count member_count, by(y4_hhid)
la var member_count "Number of HH members age 5 or above"
la var off_farm_any_count "Number of HH members with positive off-farm hours"
la var off_farm_hours "Total household off-farm hours"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_off_farm_hours.dta", replace
*/


/*DYA.10.26.2020 NEW*/
********************************************************************************
*OFF-FARM HOURS
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/hh_sec_e.dta", clear
gen  hrs_main_wage_off_farm=hh_e32 if (hh_e21_2>3 & hh_e21_2!=.)		// hh_e21_2 1 to 3 is agriculture  (exclude mining)  //DYA.10.26.2020  I think this is limited to only 
gen  hrs_sec_wage_off_farm= hh_e50 if (hh_e39_2>3 & hh_e39_2!=.)		// hh_e21_2 1 to 3 is agriculture  
egen hrs_wage_off_farm= rowtotal(hrs_main_wage_off_farm hrs_sec_wage_off_farm) 
gen  hrs_main_wage_on_farm=hh_e32 if (hh_e21_2<=3 & hh_e21_2!=.)		 
gen  hrs_sec_wage_on_farm= hh_e50 if (hh_e39_2<=3 & hh_e39_2!=.)	 
egen hrs_wage_on_farm= rowtotal(hrs_main_wage_on_farm hrs_sec_wage_on_farm) 
drop *main* *sec*
ren hh_e64 hrs_unpaid_off_farm
recode hh_e70 hh_e71 (.=0) 
gen  hrs_domest_fire_fuel=(hh_e70+ hh_e71)*7  // hrs worked just yesterday
ren  hh_e66 hrs_ag_activ
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
collapse (sum) nworker_* hrs_*  member_count, by(y4_hhid)
la var member_count "Number of HH members age 5 or above"
la var hrs_unpaid_off_farm  "Total household hours - unpaid activities"
la var hrs_ag_activ "Total household hours - agricultural activities"
la var hrs_wage_off_farm "Total household hours - wage off-farm"
la var hrs_wage_on_farm  "Total household hours - wage on-farm"
la var hrs_domest_fire_fuel  "Total household hours - collecting fuel and making fire"
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
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_off_farm_hours.dta", replace

//ALT: Future versions should have the updated section for efficiency but the old code produces the same results.
********************************************************************************
*FARM LABOR
********************************************************************************
*Family labor
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
ren ag3a_74_1 landprep_women 
ren ag3a_74_2 landprep_men 
ren ag3a_74_3 landprep_child 
ren ag3a_74_5 weeding_men 
ren ag3a_74_6 weeding_women 
ren ag3a_74_7 weeding_child 
ren ag3a_74_13 harvest_men 
ren ag3a_74_14 harvest_women 
ren ag3a_74_15 harvest_child
recode landprep_women landprep_men landprep_child weeding_men weeding_women weeding_child harvest_men harvest_women harvest_child (.=0)
egen days_hired_mainseason = rowtotal(landprep_women landprep_men landprep_child weeding_men weeding_women weeding_child harvest_men harvest_women harvest_child) 
recode ag3a_72_1 ag3a_72_2 ag3a_72_3 ag3a_72_4 ag3a_72_5 ag3a_72_6 (.=0)
egen days_flab_landprep = rowtotal(ag3a_72_1 ag3a_72_2 ag3a_72_3 ag3a_72_4 ag3a_72_5 ag3a_72_6)
recode ag3a_72_7 ag3a_72_8 ag3a_72_9 ag3a_72_10 ag3a_72_11 ag3a_72_12 (.=0)
egen days_flab_weeding = rowtotal(ag3a_72_7 ag3a_72_8 ag3a_72_9 ag3a_72_10 ag3a_72_11 ag3a_72_12)
recode ag3a_72_13 ag3a_72_14 ag3a_72_15 ag3a_72_16 ag3a_72_17 ag3a_72_18 (.=0)
egen days_flab_harvest = rowtotal(ag3a_72_13 ag3a_72_14 ag3a_72_15 ag3a_72_16 ag3a_72_17 ag3a_72_18)
gen days_famlabor_mainseason = days_flab_landprep + days_flab_weeding + days_flab_harvest
ren plotnum plot_id
collapse (sum) days_hired_mainseason days_famlabor_mainseason, by (y4_hhid plot_id)
lab var days_hired_mainseason  "Workdays for hired labor (crops) in main growing season"
lab var days_famlabor_mainseason  "Workdays for family labor (crops) in main growing season"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_farmlabor_mainseason.dta", replace

use "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta", clear
ren ag3b_74_1 landprep_women 
ren ag3b_74_2 landprep_men 
ren ag3b_74_3 landprep_child 
ren ag3b_74_5 weeding_men 
ren ag3b_74_6 weeding_women 
ren ag3b_74_7 weeding_child 
ren ag3b_74_13 harvest_men 
ren ag3b_74_14 harvest_women 
ren ag3b_74_15 harvest_child
recode landprep_women landprep_men landprep_child weeding_men weeding_women weeding_child harvest_men harvest_women harvest_child (.=0)
egen days_hired_shortseason = rowtotal(landprep_women landprep_men landprep_child weeding_men weeding_women weeding_child harvest_men harvest_women harvest_child) 
recode ag3b_72_1 ag3b_72_2 ag3b_72_3 ag3b_72_4 ag3b_72_5 ag3b_72_6 (.=0)
egen days_flab_landprep = rowtotal(ag3b_72_1 ag3b_72_2 ag3b_72_3 ag3b_72_4 ag3b_72_5 ag3b_72_6)
recode ag3b_72_7 ag3b_72_8 ag3b_72_9 ag3b_72_10 ag3b_72_11 ag3b_72_12 (.=0)
egen days_flab_weeding = rowtotal(ag3b_72_7 ag3b_72_8 ag3b_72_9 ag3b_72_10 ag3b_72_11 ag3b_72_12)
recode ag3b_72_13 ag3b_72_14 ag3b_72_15 ag3b_72_16 ag3b_72_17 ag3b_72_18 (.=0)
egen days_flab_harvest = rowtotal(ag3b_72_13 ag3b_72_14 ag3b_72_15 ag3b_72_16 ag3b_72_17 ag3b_72_18)
gen days_famlabor_shortseason = days_flab_landprep + days_flab_weeding + days_flab_harvest
ren plotnum plot_id
collapse (sum) days_hired_shortseason days_famlabor_shortseason, by (y4_hhid plot_id)
lab var days_hired_shortseason  "Workdays for hired labor (crops) in short growing season"
lab var days_famlabor_shortseason  "Workdays for family labor (crops) in short growing season"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_farmlabor_shortseason.dta", replace

*Hired Labor
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_farmlabor_mainseason.dta", clear
merge 1:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_farmlabor_shortseason.dta"
drop _merge
recode days*  (.=0)
collapse (sum) days*, by(y4_hhid plot_id)
egen labor_hired =rowtotal(days_hired_mainseason days_hired_shortseason)
egen labor_family=rowtotal(days_famlabor_mainseason  days_famlabor_shortseason)
egen labor_total = rowtotal(days_hired_mainseason days_famlabor_mainseason days_hired_shortseason days_famlabor_shortseason)
lab var labor_total "Total labor days (family, hired, or other) allocated to the farm"
lab var labor_hired "Total labor days (hired) allocated to the farm"
lab var labor_family "Total labor days (family) allocated to the farm"
lab var labor_total "Total labor days allocated to the farm"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_family_hired_labor.dta", replace
collapse (sum) labor_*, by(y4_hhid)
lab var labor_total "Total labor days (family, hired, or other) allocated to the farm"
lab var labor_hired "Total labor days (hired) allocated to the farm"
lab var labor_family "Total labor days (family) allocated to the farm"
lab var labor_total "Total labor days allocated to the farm" 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_family_hired_labor.dta", replace

********************************************************************************
*VACCINE USAGE
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/lf_sec_03.dta", clear
gen vac_animal=lf03_03==1 | lf03_03==2
replace vac_animal = . if lf03_01 ==2 | lf03_01==. //missing if the household did now own any of these types of animals 
replace vac_animal = . if lvstckcat==6
*Disagregating vaccine usage by animal type 
ren lvstckcat livestock_code
gen species = (inlist(livestock_code,1)) + 2*(inlist(livestock_code,2)) + 3*(livestock_code==3) + 4*(livestock_code==5) + 5*(inlist(livestock_code,4))
recode species (0=.)
la def species 1 "Large ruminants (cows, buffalos)" 2 "Small ruminants (sheep, goats)" 3 "Pigs" 4 "Equine (horses, donkeys)" 5 "Poultry"
la val species species
*A loop to create species variables
foreach i in vac_animal {
	gen `i'_lrum = `i' if species==1
	gen `i'_srum = `i' if species==2
	gen `i'_pigs = `i' if species==3
	gen `i'_equine = `i' if species==4
	gen `i'_poultry = `i' if species==5
}
collapse (max) vac_animal*, by (y4_hhid)
lab var vac_animal "1= Household has an animal vaccinated"
foreach i in vac_animal {
	local l`i' : var lab `i'
	lab var `i'_lrum "`l`i'' - large ruminants"
	lab var `i'_srum "`l`i'' - small ruminants"
	lab var `i'_pigs "`l`i'' - pigs"
	lab var `i'_equine "`l`i'' - equine"
	lab var `i'_poultry "`l`i'' - poultry"
}
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_vaccine.dta", replace
 
*vaccine use livestock keeper  
use "${Tanzania_NPS_W4_raw_data}/lf_sec_03.dta", clear
merge 1:1 y4_hhid lvstckcat using "${Tanzania_NPS_W4_raw_data}/lf_sec_05.dta", nogen keep (1 3)
gen all_vac_animal=lf03_03==1 | lf03_03==2
replace all_vac_animal = . if lf03_01 ==2 | lf03_01==. //missing if the household did now own any of these types of animals 
replace all_vac_animal = . if lvstckcat==6  
preserve
keep y4_hhid lf05_01_1 all_vac_animal 
ren lf05_01_1 farmerid
tempfile farmer1
save `farmer1'
restore
preserve
keep y4_hhid  lf05_01_2  all_vac_animal 
ren lf05_01_2 farmerid
tempfile farmer2
save `farmer2'
restore

use   `farmer1', replace
append using  `farmer2'
collapse (max) all_vac_animal , by(y4_hhid farmerid)
gen personid=farmerid
drop if personid==.
merge 1:1 y4_hhid personid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_gender_merge.dta", nogen
lab var all_vac_animal "1 = Individual farmer (livestock keeper) uses vaccines"
ren personid indidy4
gen livestock_keeper=1 if farmerid!=.
recode livestock_keeper (.=0)
lab var livestock_keeper "1=Indvidual is listed as a livestock keeper (at least one type of livestock)" 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_farmer_vaccine.dta", replace


********************************************************************************
*ANIMAL HEALTH - DISEASES
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/lf_sec_03.dta", clear
gen disease_animal = 1 if (lf03_02_1!=22 | lf03_02_2!=22 | lf03_02_3!=22 | lf03_02_4!=22) 
replace disease_animal = 0 if (lf03_02_1==22)
replace disease_animal = . if (lf03_02_1==. & lf03_02_2==. & lf03_02_3==. & lf03_02_4==.) 
gen disease_fmd = (lf03_02_1==7 | lf03_02_2==7 | lf03_02_3==7 | lf03_02_4==7 )
gen disease_lump = (lf03_02_1==3 | lf03_02_2==3 | lf03_02_3==3 | lf03_02_4==3 )
gen disease_bruc = (lf03_02_1==1 | lf03_02_2==1 | lf03_02_3==1 | lf03_02_4==1 )
gen disease_cbpp = (lf03_02_1==2 | lf03_02_2==2 | lf03_02_3==2 | lf03_02_4==2 )
gen disease_bq = (lf03_02_1==9 | lf03_02_2==9 | lf03_02_3==9 | lf03_02_4==9 )
ren lvstckcat livestock_code
gen species = (inlist(livestock_code,1)) + 2*(inlist(livestock_code,2)) + 3*(livestock_code==3) + 4*(livestock_code==5) + 5*(inlist(livestock_code,4))
recode species (0=.)
la def species 1 "Large ruminants (cows, buffalos)" 2 "Small ruminants (sheep, goats)" 3 "Pigs" 4 "Equine (horses, donkeys)" 5 "Poultry"
la val species species

*A loop to create species variables
foreach i in disease_animal disease_fmd disease_lump disease_bruc disease_cbpp disease_bq{
	gen `i'_lrum = `i' if species==1
	gen `i'_srum = `i' if species==2
	gen `i'_pigs = `i' if species==3
	gen `i'_equine = `i' if species==4
	gen `i'_poultry = `i' if species==5
}
collapse (max) disease_*, by (y4_hhid)
lab var disease_animal "1= Household has animal that suffered from disease"
lab var disease_fmd "1= Household has animal that suffered from foot and mouth disease"
lab var disease_lump "1= Household has animal that suffered from lumpy skin disease"
lab var disease_bruc "1= Household has animal that suffered from black quarter"
lab var disease_cbpp "1= Household has animal that suffered from brucelosis"
lab var disease_bq "1= Household has animal that suffered from black quarter"
foreach i in disease_animal disease_fmd disease_lump disease_bruc disease_cbpp disease_bq{
	local l`i' : var lab `i'
	lab var `i'_lrum "`l`i'' - large ruminants"
	lab var `i'_srum "`l`i'' - small ruminants"
	lab var `i'_pigs "`l`i'' - pigs"
	lab var `i'_equine "`l`i'' - equine"
	lab var `i'_poultry "`l`i'' - poultry"
}
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_diseases.dta", replace


********************************************************************************
*LIVESTOCK WATER, FEEDING, AND HOUSING
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/lf_sec_04.dta", clear
gen feed_grazing = (lf04_01_1==1 | lf04_01_1==2)
lab var feed_grazing "1=HH feeds only or mainly by grazing"
gen water_source_nat = (lf04_06_1==5 | lf04_06_1==6 | lf04_06_1==7)
gen water_source_const = (lf04_06_1==1 | lf04_06_1==2 | lf04_06_1==3 | lf04_06_1==4 | lf04_06_1==8 | lf04_06_1==9 | lf04_06_1==10)
gen water_source_cover = (lf04_06_1==1 | lf04_06_1==2 )
lab var water_source_nat "1=HH water livestock using natural source"
lab var water_source_const "1=HH water livestock using constructed source"
lab var water_source_cover "1=HH water livestock using covered source"
gen lvstck_housed = (lf04_11==2 | lf04_11==3 | lf04_11==4 | lf04_11==5 | lf04_11==6 )
lab var lvstck_housed "1=HH used enclosed housing system for livestock" 
ren lvstckcat livestock_code
gen species = (inlist(livestock_code,1)) + 2*(inlist(livestock_code,2)) + 3*(livestock_code==3) + 4*(livestock_code==5) + 5*(inlist(livestock_code,4))
recode species (0=.)
la def species 1 "Large ruminants (cows, buffalos)" 2 "Small ruminants (sheep, goats)" 3 "Pigs" 4 "Equine (horses, donkeys)" 5 "Poultry"
la val species species

*A loop to create species variables
foreach i in feed_grazing water_source_nat water_source_const water_source_cover lvstck_housed {
	gen `i'_lrum = `i' if species==1
	gen `i'_srum = `i' if species==2
	gen `i'_pigs = `i' if species==3
	gen `i'_equine = `i' if species==4
	gen `i'_poultry = `i' if species==5
}
collapse (max) feed_grazing* water_source* lvstck_housed*, by (y4_hhid)
lab var feed_grazing "1=HH feeds only or mainly by grazing"
lab var water_source_nat "1=HH water livestock using natural source"
lab var water_source_const "1=HH water livestock using constructed source"
lab var water_source_cover "1=HH water livestock using covered source"
lab var lvstck_housed "1=HH used enclosed housing system for livestock" 
foreach i in feed_grazing water_source_nat water_source_const water_source_cover lvstck_housed {
	local l`i' : var lab `i'
	lab var `i'_lrum "`l`i'' - large ruminants"
	lab var `i'_srum "`l`i'' - small ruminants"
	lab var `i'_pigs "`l`i'' - pigs"
	lab var `i'_equine "`l`i'' - equine"
	lab var `i'_poultry "`l`i'' - poultry"
}
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_feed_water_house.dta", replace

 /*
********************************************************************************
*USE OF INORGANIC FERTILIZER
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta" 
gen use_inorg_fert=.
replace use_inorg_fert=0 if ag3a_47==2 | ag3b_47==2 | ag3a_54==2 | ag3b_54==2 
replace use_inorg_fert=1 if ag3a_47==1 | ag3b_47==1 | ag3a_54==1 | ag3b_54==1  
recode use_inorg_fert (.=0)
collapse (max) use_inorg_fert, by (y4_hhid)
lab var use_inorg_fert "1 = Household uses inorganic fertilizer"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fert_use.dta", replace
  
*Fertilizer use by farmers ( a farmer is an individual listed as plot manager)
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta" 
gen all_use_inorg_fert=(ag3a_47==1 | ag3b_47==1 | ag3a_54==1 | ag3b_54==1 )
preserve
keep y4_hhid ag3a_08_1 ag3b_08_1 all_use_inorg_fert 
ren ag3a_08_1 farmerid
replace farmerid= ag3b_08_1 if farmerid==.
tempfile farmer1
save `farmer1'
restore
preserve
keep y4_hhid ag3a_08_2 ag3b_08_2  all_use_inorg_fert 
ren ag3a_08_2 farmerid
replace farmerid= ag3b_08_2 if farmerid==.
tempfile farmer2
save `farmer2'
restore
preserve
keep y4_hhid ag3a_08_3 ag3b_08_3 all_use_inorg_fert 
ren ag3a_08_3 farmerid
replace farmerid= ag3b_08_3 if farmerid==.		
tempfile farmer3
save `farmer3'
restore
use   `farmer1', replace
append using  `farmer2'
append using  `farmer3'
collapse (max) all_use_inorg_fert , by(y4_hhid farmerid)
gen personid=farmerid
drop if personid==.
merge 1:1 y4_hhid personid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_gender_merge.dta", nogen
lab var all_use_inorg_fert "1 = Individual farmer (plot manager) uses inorganic fertilizer"
ren personid indidy4
gen farm_manager=1 if farmerid!=.
recode farm_manager (.=0)
lab var farm_manager "1=Indvidual is listed as a manager for at least one plot" 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_farmer_fert_use.dta", replace
*/


********************************************************************************
*USE OF INORGANIC FERTILIZER (& other inputs) - ALT 07.06.21
********************************************************************************
//ALT 07.22.21: Changing this section to include use of other inputs because folks have been asking about them.
//They still need to be integrated at the end, though.
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
gen short=0
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta"
recode short (.=1)
ren plotnum plot_id

merge 1:1 y4_hhid plot_id short using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_input_quantities.dta", nogen
recode herb_rate inorg_fert_rate org_fert_rate pest_rate (.=0)
replace herb_rate=1 if herb_rate >0 
replace inorg_fert_rate = 1 if inorg_fert_rate >0 
replace org_fert_rate=1 if org_fert_rate > 0 
replace pest_rate=1 if pest_rate>0
ren *_rate all_use_*
ren ag3a_09_* dm*
ren ag3b_09_* dm*0
keep y4_hhid plot_id dm* all_use*
gen dummy = _n
reshape long dm, i(y4_hhid plot_id all_use* dummy) j(idno)
drop if dm==.
collapse (max) all_use*, by(y4_hhid dm)
ren dm farmerid
gen personid=farmerid
drop if personid==.
merge 1:1 y4_hhid personid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_gender_merge.dta", nogen
lab var all_use_inorg_fert "1 = Individual farmer (plot manager) uses inorganic fertilizer"
la var all_use_org_fert "1 = Individual farmer uses organic fertilizer"
la var all_use_herb "1 = Individual farmer uses herbicide"
la var all_use_pest "1 = Individual farmer uses pesticide"
ren personid indidy4
gen farm_manager=1 if farmerid!=.
recode farm_manager (.=0)
lab var farm_manager "1=Indvidual is listed as a manager for at least one plot" 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_farmer_input_use.dta", replace
collapse (max) all_use*, by(y4_hhid)
ren all_use* use*
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_input_use.dta", replace

//ALT: To do: Update section
********************************************************************************
*USE OF IMPROVED SEED
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/ag_sec_4a.dta", clear 
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_4b.dta" 
gen imprv_seed_new=.
replace imprv_seed_new=1 if ag4a_08==1 | ag4a_08==3 | ag4b_08==1 | ag4b_08==3 
replace imprv_seed_new=0 if ag4a_08==2 | ag4a_08==4 | ag4b_08==2 | ag4b_08==4 
gen imprv_seed_old=.
replace imprv_seed_old=1 if ag4a_10b==1 | ag4a_10b==3 | ag4b_10b==1 | ag4a_10b==3
replace imprv_seed_old=0 if ag4a_10b==2 | ag4a_10b==4 | ag4b_10b==2 | ag4b_10b==4
replace imprv_seed_old=. if ag4a_10b==. | ag4b_10b==. 
gen imprv_seed_use=.
replace imprv_seed_use=1 if imprv_seed_new==1 | imprv_seed_old==1
replace imprv_seed_use=0 if imprv_seed_new==0 & imprv_seed_old==0 
recode imprv_seed_use (.=0)
*Use of seed by crop
forvalues k=1/$nb_topcrops {
	local c : word `k' of $topcrop_area
	local cn : word `k' of $topcropname_area
	gen imprv_seed_`cn'=imprv_seed_use if zaocode==`c'
	gen hybrid_seed_`cn'=.
}
collapse (max) imprv_seed_* hybrid_seed_*, by(y4_hhid)
lab var imprv_seed_use "1 = Household uses improved seed"
foreach v in $topcropname_area {
	lab var imprv_seed_`v' "1= Household uses improved `v' seed"
	lab var hybrid_seed_`v' "1= Household uses improved `v' seed"
}
*Replacing permanent crop seed information with missing because this section does not ask about permanent crops 
replace imprv_seed_cassav = . 
replace imprv_seed_banana = . 
drop imprv_seed_new imprv_seed_old
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_improvedseed_use.dta", replace
  
*Seed adoption by farmers ( a farmer is an individual listed as plot manager)
use "${Tanzania_NPS_W4_raw_data}/ag_sec_4a.dta", clear 
merge m:1 y4_hhid plotnum using  "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", nogen keep(1 3)
preserve
use "${Tanzania_NPS_W4_raw_data}/ag_sec_4b.dta" , clear
merge m:1 y4_hhid plotnum using  "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta", nogen keep(1 3)
tempfile seedb
save `seedb'
restore
append using `seedb' 
gen imprv_seed_new=.
replace imprv_seed_new=1 if ag4a_08==1 | ag4a_08==3 | ag4b_08==1 | ag4b_08==3 
replace imprv_seed_new=0 if ag4a_08==2 | ag4a_08==4 | ag4b_08==2 | ag4b_08==4 
gen imprv_seed_old=.
replace imprv_seed_old=1 if ag4a_10b==1 | ag4a_10b==3 | ag4b_10b==1 | ag4a_10b==3
replace imprv_seed_old=0 if ag4a_10b==2 | ag4a_10b==4 | ag4b_10b==2 | ag4b_10b==4
replace imprv_seed_old=. if ag4a_10b==. | ag4b_10b==. 
gen imprv_seed_use=.
replace imprv_seed_use=1 if imprv_seed_new==1 | imprv_seed_old==1
replace imprv_seed_use=0 if imprv_seed_new==0 & imprv_seed_old==0 
recode imprv_seed_use (.=0)
ren imprv_seed_use all_imprv_seed_use
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_farmer_improvedseed_use_temp.dta", replace

*Use of seed by crop
forvalues k=1/$nb_topcrops {
	use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_farmer_improvedseed_use_temp.dta", clear
	local c : word `k' of $topcrop_area
	local cn : word `k' of $topcropname_area
	*Adding adoption of improved maize seeds
	gen all_imprv_seed_`cn'=all_imprv_seed_use if zaocode==`c'  
	gen all_hybrid_seed_`cn' =. 
	*We also need a variable that indicates if farmer (plot manager) grows crop
	gen `cn'_farmer= zaocode==`c' 
	preserve
	keep y4_hhid ag3a_08_1 ag3b_08_1 all_imprv_seed_use all_imprv_seed_`cn' all_hybrid_seed_`cn' `cn'_farmer  
	ren ag3a_08_1 farmerid
	replace farmerid= ag3b_08_1 if farmerid==.
	tempfile farmer1
	save `farmer1'
	restore
	preserve
	keep y4_hhid ag3a_08_2 ag3b_08_2 all_imprv_seed_use all_imprv_seed_`cn' all_hybrid_seed_`cn' `cn'_farmer  
	ren ag3a_08_2 farmerid
	replace farmerid= ag3b_08_2 if farmerid==.
	tempfile farmer2
	save `farmer2'
	restore
	preserve
	keep y4_hhid ag3a_08_3 ag3b_08_3 all_imprv_seed_use all_imprv_seed_`cn' all_hybrid_seed_`cn' `cn'_farmer  
	ren ag3a_08_3 farmerid
	replace farmerid= ag3b_08_3 if farmerid==.		 
	tempfile farmer3
	save `farmer3'
	restore

	use   `farmer1', replace
	append using  `farmer2'
	append using  `farmer3'
	collapse (max) all_imprv_seed_use  all_imprv_seed_`cn' all_hybrid_seed_`cn'  `cn'_farmer, by (y4_hhid farmerid)
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_farmer_improvedseed_use_temp_`cn'.dta", replace
}

*Combining all crop disaggregated files together
foreach v in $topcropname_area {
	merge 1:1 y4_hhid farmerid all_imprv_seed_use using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_farmer_improvedseed_use_temp_`v'.dta", nogen
}	 
gen personid=farmerid
drop if personid==.
merge 1:1 y4_hhid personid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_gender_merge.dta", nogen
lab var all_imprv_seed_use "1 = Individual farmer (plot manager) uses improved seeds"
foreach v in $topcropname_area {
	lab var all_imprv_seed_`v' "1 = Individual farmer (plot manager) uses improved seeds - `v'"
	lab var all_hybrid_seed_`v' "1 = Individual farmer (plot manager) uses hybrid seeds - `v'"
	lab var `v'_farmer "1 = Individual farmer (plot manager) grows `v'"
}
ren personid indidy4
gen farm_manager=1 if farmerid!=.
recode farm_manager (.=0)
lab var farm_manager "1=Indvidual is listed as a manager for at least one plot" 
*Replacing permanent crop seed information with missing because this section does not ask about permanent crops
replace all_imprv_seed_cassav = . 
replace all_imprv_seed_banana = . 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_farmer_improvedseed_use.dta", replace
//IHS 10/11/19 END


********************************************************************************
*REACHED BY AG EXTENSION
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/ag_sec_12b.dta", clear
ren ag12b_08 receive_advice
preserve
use "${Tanzania_NPS_W4_raw_data}/ag_sec_12a.dta", clear
ren ag12a_02 receive_advice
replace sourceid=8 if sourceid==5
tempfile TZ_advice2
save `TZ_advice2'
restore
append using  `TZ_advice2'
**Government Extension
gen advice_gov = (sourceid==1 & receive_advice==1)
**NGO
gen advice_ngo = (sourceid==2 & receive_advice==1)
**Cooperative/ Farmer Association
gen advice_coop = (sourceid==3 & receive_advice==1)
**Large Scale Farmer
gen advice_farmer =(sourceid==4 & receive_advice==1)
**Radio
gen advice_radio = (sourceid==5 & receive_advice==1)
**Publication
gen advice_pub = (sourceid==6 & receive_advice==1)
**Neighbor
gen advice_neigh = (sourceid==7 & receive_advice==1)
**Other
gen advice_other = (sourceid==8 & receive_advice==1)
**advice on prices from extension
*Five new variables  ext_reach_all, ext_reach_public, ext_reach_private, ext_reach_unspecified, ext_reach_ict  
gen ext_reach_public=(advice_gov==1)
gen ext_reach_private=(advice_ngo==1 | advice_coop==1)
gen ext_reach_unspecified=(advice_radio==1 | advice_pub==1 | advice_other==1)
gen ext_reach_ict=(advice_radio==1)
gen ext_reach_all=(ext_reach_public==1 | ext_reach_private==1 | ext_reach_unspecified==1 | ext_reach_ict==1)
collapse (max) ext_reach_* , by (y4_hhid)
lab var ext_reach_all "1 = Household reached by extensition services - all sources"
lab var ext_reach_public "1 = Household reached by extensition services - public sources"
lab var ext_reach_private "1 = Household reached by extensition services - private sources"
lab var ext_reach_unspecified "1 = Household reached by extensition services - unspecified sources"
lab var ext_reach_ict "1 = Household reached by extensition services through ICT"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_any_ext.dta", replace
 
//IHS 10/11/19 START
********************************************************************************
*USE OF FORMAL FINANCIAL SERVICES
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/hh_sec_p.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/hh_sec_q1.dta" 
gen borrow_bank= hh_p03==1
gen borrow_micro=hh_p03==2
gen borrow_mortgage=hh_p03==3
gen borrow_insurance=hh_p03==4
gen borrow_other_fin=hh_p03==5
gen borrow_neigh=hh_p03==6
gen borrow_employer=hh_p03==9
gen borrow_ngo=hh_p03==11
gen use_bank_acount=hh_q10==1
gen use_MM=hh_q01_1==1 | hh_q01_2==1 | hh_q01_3==1 | hh_q01_4==1 //use any MM services
gen use_fin_serv_bank= use_bank_acount==1
gen use_fin_serv_credit= borrow_mortgage==1 | borrow_bank==1  | borrow_other_fin==1
gen use_fin_serv_insur= borrow_insurance==1
gen use_fin_serv_digital=use_MM==1
gen use_fin_serv_others= borrow_other_fin==1
gen use_fin_serv_all=use_fin_serv_bank==1 | use_fin_serv_credit==1 | use_fin_serv_insur==1 | use_fin_serv_digital==1 |  use_fin_serv_others==1  
recode use_fin_serv* (.=0)
collapse (max) use_fin_serv_*, by (y4_hhid)
lab var use_fin_serv_all "1= Household uses formal financial services - all types"
lab var use_fin_serv_bank "1= Household uses formal financial services - bank accout"
lab var use_fin_serv_credit "1= Household uses formal financial services - credit"
lab var use_fin_serv_insur "1= Household uses formal financial services - insurance"
lab var use_fin_serv_digital "1= Household uses formal financial services - digital"
lab var use_fin_serv_others "1= Household uses formal financial services - others"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fin_serv.dta", replace


********************************************************************************
*MILK PRODUCTIVITY
********************************************************************************
*Total production
use "${Tanzania_NPS_W4_raw_data}/lf_sec_06.dta", clear
gen ruminants_large = lvstckcat==1
keep if ruminants_large
gen milk_animals = lf06_01			
gen months_milked = lf06_02			
gen liters_day = lf06_03			
gen liters_per_largeruminant = (liters_day*365*(months_milked/12))	
keep if milk_animals!=0 & milk_animals!=.
drop if liters_per_largeruminant==.
keep y4_hhid milk_animals months_milked liters_per_largeruminant 
lab var milk_animals "Number of large ruminants that was milk (household)"
lab var months_milked "Average months milked in last year (household)"
lab var liters_per_largeruminant "average quantity (liters) per year (household)"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_milk_animals.dta", replace


********************************************************************************
*EGG PRODUCTIVITY
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/lf_sec_02.dta", clear
egen poultry_owned = rowtotal(lf02_04_1 lf02_04_2) if inlist(lvstckid,10,11,12)
collapse (sum) poultry_owned, by(y4_hhid)
tempfile eggs_animals_hh 
save `eggs_animals_hh'
use "${Tanzania_NPS_W4_raw_data}/lf_sec_08.dta", clear
keep if productid==1			
gen eggs_months = lf08_02		
gen eggs_per_month = lf08_03_1 if lf08_03_2==3			
gen eggs_total_year = eggs_month*eggs_per_month			
merge 1:1 y4_hhid using  `eggs_animals_hh', nogen keep(1 3)			
keep y4_hhid eggs_months eggs_per_month eggs_total_year poultry_owned 
lab var eggs_months "Number of months eggs were produced (household)"
lab var eggs_per_month "Number of months eggs that were produced per month (household)"
lab var eggs_total_year "Total number of eggs that was produced (household)"
lab var poultry_owned "Total number of poulty owned (household)"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_eggs_animals.dta", replace


********************************************************************************
*LAND RENTAL & INPUT COSTS * //ALT: Combining below sections, reducing redundant computations & preserving legacy file structure compatibility. 
********************************************************************************
//Preprocessing was done in the inputs section
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_all_plots.dta", clear
collapse (sum) ha_planted, by(y4_hhid plot_id field_size)
merge 1:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_rents.dta", nogen
reshape long pricelandrent, i(y4_hhid plot_id field_size) j(short) //Get both seasons
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender)
gen plot_rental_rate = pricelandrent*field_size //Back to per month
gen value_rented_land = plot_rental_rate*12
preserve
gen value_rented_land_male = plot_rental_rate if dm_gender==1
gen value_rented_land_female = plot_rental_rate if dm_gender==2
gen value_rented_land_mixed = plot_rental_rate if dm_gender==3
collapse (sum) value_rented_land_* value_rented_land = plot_rental_rate, by(y4_hhid short)
lab var value_rented_land_male "Value of rented land (male-managed plot)
lab var value_rented_land_female "Value of rented land (female-managed plot)
lab var value_rented_land_mixed "Value of rented land (mixed-managed plot)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rental_rate.dta", replace
restore
/*Geographic medians
ALT 07.20.21: There are 82 rental observations in the dataset total, and the per-ha per-mo rental rate varies quite a bit (14,500 +/- 14,800 sd, n=71 and 14,200 +/- 8,000 sd, n=11)
I'm not convinced we're generating reliable estimates using these data.
*/
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta", nogen keep(1 3)
gen plotweight=ha_planted*weight
gen obs=1
foreach i in region district ward village ea y4_hhid {
preserve
	bys short `i' : egen obs_`i' = sum(obs)
	collapse (median) pricelandrent_`i'=pricelandrent (sum) obs_`i'=obs  [aw=plotweight], by (`i' short)
	tempfile pricelandrent_`i'_median
	save `pricelandrent_`i'_median'
restore
merge m:1 `i' short using `pricelandrent_`i'_median', nogen keep(1 3)
}
preserve
collapse (median) pricelandrent_country = pricelandrent (sum) obs_country_kg=obs [aw=plotweight], by(short)
tempfile pricelandrent_country_median
save `pricelandrent_country_median'
restore
merge m:1 short using `pricelandrent_country_median',nogen keep(1 3)
foreach i in country region district ward village ea {
	replace pricelandrent = pricelandrent_`i' if obs_`i' >9
}
	replace pricelandrent = pricelandrent_y4_hhid if pricelandrent_y4_hhid!=.
	gen value_owned_land=pricelandrent*field_size if value_rented_land==.
	gen value_owned_land_male = value_owned_land if dm_gender==1
	gen value_owned_land_female = value_owned_land if dm_gender==2
	gen value_owned_land_mixed = value_owned_land if dm_gender==3
	gen ha_planted_male = ha_planted if dm_gender==1
	gen ha_planted_female = ha_planted if dm_gender==2
	gen ha_planted_mixed = ha_planted if dm_gender==3

preserve
collapse (sum) ha_planted*, by(y4_hhid)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_ha_planted_total.dta", replace
restore
collapse (max) ha_planted* value_owned_land*, by(y4_hhid plot_id)			// taking max area planted (and value owned) by plot so as to not double count plots that were planted in both seasons
																			//ALT 07.22.21: sum -> max; typo in previous code versions?
collapse (sum) ha_planted* value_owned_land*, by(y4_hhid)					// now summing to household
lab var value_owned_land "Value of owned land that was cultivated (household)"
lab var value_owned_land_male "Value of owned land (male-managed plots)"
lab var value_owned_land_female "Value of owned land (female-managed plots)"
lab var value_owned_land_mixed "Value of owned land (mixed-managed plots)"
lab var ha_planted "Area planted (household)"
lab var ha_planted_male "Area planted (male-managed plots)"
lab var ha_planted_female "Area planted (female-managed plots)"
lab var ha_planted_mixed "Area planted (mixed-managed plots)"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_land.dta", replace



//ALT 07.21.21: Building legacy file for compatibility with later code.
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_all_plots.dta", clear
collapse (sum) ha_planted, by(y4_hhid plot_id)
tempfile planted_area
save `planted_area'
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_cost_inputs_long.dta", clear
collapse (sum) val, by(y4_hhid plot_id input)
ren val value_
reshape wide value_, i(y4_hhid plot_id) j(input) string
ren value_landrent value_rented_land
ren value_orgfert value_org_purchased
ren value_inorgfert value_inorg_fert
//ren value_labor value_hired_labor
ren value_seed value_seeds_purchased //ALT 09.23.22: To fix
gen value_herb_pest = value_herb+value_pest
merge 1:1 y4_hhid plot_id using `planted_area', nogen keep(3)
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_decision_makers.dta", nogen keep(1 3)
foreach i in value_inorg_fert value_org_purchased value_hired_labor value_rented_land value_seeds_purchased ha_planted value_herb_pest {
	gen `i'_male = `i' if dm_gender==1
	gen `i'_female = `i' if dm_gender==2
	gen `i'_mixed = `i' if dm_gender==3
}
collapse (sum) value* ha*, by(y4_hhid)
lab var value_hired_labor "Value of hired labor (household)"
lab var value_hired_labor_male "Value of hired labor (male-managed crops)"
lab var value_hired_labor_female "Value of hired labor (female-managed crops)"
lab var value_hired_labor_mixed "Value of hired labor (mixed-managed crops)"
lab var value_rented_land "Value of rented land that was cultivated (household)"
lab var value_rented_land_male "Value of rented land (male-managed plots)"
lab var value_rented_land_female "Value of rented land (female-managed plots)"
lab var value_rented_land_mixed "Value of rented land (mixed-managed plots)"
lab var ha_planted "Area planted (household)"
lab var ha_planted_male "Area planted (male-managed plots)"
lab var ha_planted_female "Area planted (female-managed plots)"
lab var ha_planted_mixed "Area planted (mixed-managed plots)"
lab var value_herb_pest "Value of herbicide_pesticide (household)"
lab var value_herb_pest_male "Value of herbicide_pesticide (male-managed plots)"
lab var value_herb_pest_female "Value of herbicide_pesticide (female-managed plots)"
lab var value_herb_pest_mixed "Value of herbicide_pesticide (mixed-managed plots)"
lab var value_org_purchased "Value organic fertilizer purchased (household)"
lab var value_org_purchased_male "Value organic fertilizer purchased (male-managed plots)"
lab var value_org_purchased_female "Value organic fertilizer purchased (female-managed plots)"
lab var value_org_purchased_mixed "Value organic fertilizer purchased (mixed-managed plots)"
lab var value_inorg_fert "Value of inorganic fertilizer (household)"
lab var value_inorg_fert_male "Value of inorganic fertilizer (male-managed plots)"
lab var value_inorg_fert_female "Value of inorganic fertilizer female-managed plots)"
lab var value_inorg_fert_mixed "Value of inorganic fertilizer (mixed-managed plots)"
/*lab var value_fam_labor "Value of family labor (household)"
lab var value_fam_labor_male "Value of family labor (male-managed crops)"
lab var value_fam_labor_female "Value of family labor (female-managed crops)"
lab var value_fam_labor_mixed "Value of family labor (mixed-managed crops)"*/
//merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_asset_rental_costs.dta", nogen keep(1 3)
//egen value_ag_rentals = rowtotal(rental_cost*)
//drop rental_cost*
//lab var value_ag_rentals "Value of rented equipment (household level)"
recode ha_planted* (0=.)
*Explicit and implicit costs at the plot level
//egen cost_total =rowtotal(value_owned_land value_rented_land value_inorg_fert value_herb_pest value_org_purchased ///
	//value_org_notpurchased value_hired_labor value_fam_labor value_seeds_not_purchased value_seeds_purchased)
//lab var cost_total "Explicit costs of crop production (plot level)" 
gen cost_total = .
lab var cost_total "Not constructable for W5"
*Creating total costs by gender (NOTE: excludes ag_rentals because those are at the household level)
/*foreach i in male female mixed{
	egen cost_total_`i' = rowtotal(value_owned_land_`i' value_rented_land_`i' value_inorg_fert_`i' value_herb_pest_`i' value_org_purchased_`i' ///
	value_org_notpurchased_`i' value_hired_labor_`i' value_fam_labor_`i' value_seeds_not_purchased_`i' value_seeds_purchased_`i')
	*/

*Explicit costs at the plot level 
egen cost_expli =rowtotal(value_rented_land value_inorg_fert value_herb_pest value_org_purchased value_hired_labor value_seeds_purchased)
lab var cost_expli "Explicit costs of crop production (plot level)" 
*Creating explicit costs by gender
foreach i in male female mixed{
	egen cost_expli_`i' = rowtotal( value_rented_land_`i' value_inorg_fert_`i' value_herb_pest_`i' value_org_purchased_`i' value_hired_labor_`i' value_seeds_purchased_`i')
	gen cost_total_`i'=.
}
lab var cost_expli_male "Explicit costs of crop production (male-managed plots)" 
lab var cost_expli_female "Explicit costs of crop production (female-managed plots)" 
lab var cost_expli_mixed "Explicit costs of crop production (mixed-managed plots)" 
lab var cost_total_male "Explicit + implicit costs of crop production (male-managed plots)" 
lab var cost_total_female "Explicit + implicit costs of crop production (female-managed plots)"
lab var cost_total_mixed "Explicit + implicit costs of crop production (mixed-managed plots)"
*Explicit costs at the household level
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_inputs.dta", nogen keepusing(val_ag_asset_rent val_tractor_rent val_animal_traction_rent val_crop_transport)
egen value_ag_rentals = rowtotal(val_ag_asset_rent val_tractor_rent val_animal_traction_rent)
drop val_ag_asset_rent val_tractor_rent val_animal_traction_rent
ren val_crop_transport value_crop_transport
lab var value_ag_rentals "Value of rented equipment (household level)"
egen cost_expli_hh = rowtotal(value_ag_rentals value_rented_land value_inorg_fert value_herb_pest value_org_purchased value_hired_labor value_seeds_purchased value_crop_transport)
lab var cost_expli_hh "Total explicit crop production (household level)" 
count if cost_expli_hh==0
*Recoding zeros as missings
recode cost_total* (0=.)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_cropcosts_total.dta", replace //If we don't ned up needing the disaggregated costs, we can make this much quicker by doing a collapse on the expenses file down to plot level.




/*
********************************************************************************
*LAND RENTAL 
********************************************************************************
* LRS *
use "${Tanzania_NPS_W4_raw_data}/ag_sec_2a.dta", clear
drop if plotnum==""
gen plot_ha = ag2a_09/2.47105						
replace plot_ha = ag2a_04/2.47105 if plot_ha==.			
keep plot_ha plotnum y4_hhid
ren plotnum plot_id
lab var plot_ha "Plot area in hectare" 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_area_lrs.dta", replace
*Getting plot rental rate
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
ren plotnum plot_id
merge 1:1 plot_id y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_area_lrs.dta" , nogen		
drop if plot_id==""
gen cultivated = ag3a_03==1
merge m:1 y4_hhid plot_id using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_decision_makers.dta", nogen keep (1 3)
tab ag3a_34_1 ag3a_34_2, nol
gen plot_rental_rate = ag3a_33*(12/ag3a_34_1) if ag3a_34_2==1		
replace plot_rental_rate = ag3a_33*(1/ag3a_34_1) if ag3a_34_2==2	
recode plot_rental_rate (0=.) 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rent_nomiss_lrs.dta", replace					

preserve
gen value_rented_land_male = plot_rental_rate if dm_gender==1
gen value_rented_land_female = plot_rental_rate if dm_gender==2
gen value_rented_land_mixed = plot_rental_rate if dm_gender==3
collapse (sum) value_rented_land_* value_rented_land = plot_rental_rate, by(y4_hhid)
lab var value_rented_land_male "Value of rented land (male-managed plot)
lab var value_rented_land_female "Value of rented land (female-managed plot)
lab var value_rented_land_mixed "Value of rented land (mixed-managed plot)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rental_rate_lrs.dta", replace
restore

gen ha_rental_rate_hh = plot_rental_rate/plot_ha
preserve
keep if plot_rental_rate!=. & plot_rental_rate!=0			
collapse (sum) plot_rental_rate plot_ha, by(y4_hhid)		
gen ha_rental_hh_lrs = plot_rental_rate/plot_ha				
keep ha_rental_hh_lrs y4_hhid
lab var ha_rental_hh_lrs "Area of rented plot during the long run season"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_rental_rate_hhid_lrs.dta", replace
restore

*Merging in geographic variables
merge m:1 y4_hhid using "${Tanzania_NPS_W4_raw_data}/hh_sec_a.dta", nogen assert(2 3) keep(3)	
*Geographic medians
bys hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen ha_rental_count_vil = count(ha_rental_rate_hh)
bys hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen ha_rental_rate_vil = median(ha_rental_rate_hh)
bys hh_a01_1 hh_a02_1 hh_a03_1: egen ha_rental_count_ward = count(ha_rental_rate_hh)
bys hh_a01_1 hh_a02_1 hh_a03_1: egen ha_rental_rate_ward = median(ha_rental_rate_hh)
bys hh_a01_1 hh_a02_1: egen ha_rental_count_dist = count(ha_rental_rate_hh)
bys hh_a01_1 hh_a02_1: egen ha_rental_rate_dist = median(ha_rental_rate_hh)
bys hh_a01_1: egen ha_rental_count_reg = count(ha_rental_rate_hh)
bys hh_a01_1: egen ha_rental_rate_reg = median(ha_rental_rate_hh)
egen ha_rental_rate_nat = median(ha_rental_rate_hh)
*Now, getting median rental rate at the lowest level of aggregation with at least ten observations
gen ha_rental_rate = ha_rental_rate_vil if ha_rental_count_vil>=10		
replace ha_rental_rate = ha_rental_rate_ward if ha_rental_count_ward>=10 & ha_rental_rate==.	
replace ha_rental_rate = ha_rental_rate_dist if ha_rental_count_dist>=10 & ha_rental_rate==.	
replace ha_rental_rate = ha_rental_rate_reg if ha_rental_count_reg>=10 & ha_rental_rate==.		
replace ha_rental_rate = ha_rental_rate_nat if ha_rental_rate==.				
collapse (firstnm) ha_rental_rate, by(hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a)
lab var ha_rental_rate "Land rental rate per ha"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_rental_rate_lrs.dta", replace

*  SRS  *
use "${Tanzania_NPS_W4_raw_data}/ag_sec_2b.dta", clear
drop if plotnum==""
gen plot_ha = ag2b_20/2.47105						
replace plot_ha = ag2b_15/2.47105 if plot_ha==.		
keep plot_ha plotnum y4_hhid
ren plotnum plot_id
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_area_srs.dta", replace
*Getting plot rental rate
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta", clear
drop if plotnum==""
gen cultivated = ag3b_03==1
ren  plotnum plot_id
merge m:1 y4_hhid plot_id using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_decision_makers.dta", nogen 
merge 1:1 plot_id y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_area_lrs.dta", nogen					
merge 1:1 plot_id y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_area_srs.dta", nogen update replace		
*Total rent - rescaling to a YEARLY value
tab ag3b_34_1 ag3b_34_2, nol					
gen plot_rental_rate = ag3b_33*(12/ag3b_34_1) if ag3b_34_2==1			
replace plot_rental_rate = ag3b_33*(1/ag3b_34_1) if ag3b_34_2==2		
recode plot_rental_rate (0=.) 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rent_nomiss_srs.dta", replace
preserve
gen value_rented_land_male = plot_rental_rate if dm_gender==1
gen value_rented_land_female = plot_rental_rate if dm_gender==2
gen value_rented_land_mixed = plot_rental_rate if dm_gender==3
lab var value_rented_land_male "Value of rented land (male-managed plot)
lab var value_rented_land_female "Value of rented land (female-managed plot)
lab var value_rented_land_mixed "Value of rented land (mixed-managed plot)	
collapse (sum) value_rented_land_* value_rented_land = plot_rental_rate, by(y4_hhid)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rental_rate_srs.dta", replace
restore
gen ha_rental_rate_hh = plot_rental_rate/plot_ha
preserve
keep if plot_rental_rate!=. & plot_rental_rate!=0			
collapse (sum) plot_rental_rate plot_ha, by(y4_hhid)		
gen ha_rental_hh_srs = plot_rental_rate/plot_ha				
keep ha_rental_hh_srs y4_hhid
lab var ha_rental_hh_srs "Area of rented plot during the short run season"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_rental_rate_hhid_srs.dta", replace
restore
*Merging in geographic variables
merge m:1 y4_hhid using "${Tanzania_NPS_W4_raw_data}/hh_sec_a.dta", nogen assert(2 3) keep(3)		
*Geographic medians
bys hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen ha_rental_count_vil = count(ha_rental_rate_hh)
bys hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen ha_rental_rate_vil = median(ha_rental_rate_hh)
bys hh_a01_1 hh_a02_1 hh_a03_1: egen ha_rental_count_ward = count(ha_rental_rate_hh)
bys hh_a01_1 hh_a02_1 hh_a03_1: egen ha_rental_rate_ward = median(ha_rental_rate_hh)
bys hh_a01_1 hh_a02_1: egen ha_rental_count_dist = count(ha_rental_rate_hh)
bys hh_a01_1 hh_a02_1: egen ha_rental_rate_dist = median(ha_rental_rate_hh)
bys hh_a01_1: egen ha_rental_count_reg = count(ha_rental_rate_hh)
bys hh_a01_1: egen ha_rental_rate_reg = median(ha_rental_rate_hh)
egen ha_rental_rate_nat = median(ha_rental_rate_hh)
*Now, getting median rental rate at the lowest level of aggregation with at least ten observations
gen ha_rental_rate = ha_rental_rate_vil if ha_rental_count_vil>=10		
replace ha_rental_rate = ha_rental_rate_ward if ha_rental_count_ward>=10 & ha_rental_rate==.	
replace ha_rental_rate = ha_rental_rate_dist if ha_rental_count_dist>=10 & ha_rental_rate==.	
replace ha_rental_rate = ha_rental_rate_reg if ha_rental_count_reg>=10 & ha_rental_rate==.		
replace ha_rental_rate = ha_rental_rate_nat if ha_rental_rate==.				
collapse (firstnm) ha_rental_rate_srs = ha_rental_rate, by(hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a)
lab var ha_rental_rate "Land rental rate per ha in the short run season"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_rental_rate_srs.dta", replace

*Now getting total ha of all plots that were cultivated at least once
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rent_nomiss_lrs.dta", clear
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rent_nomiss_srs.dta"
collapse (max) cultivated plot_ha, by(y4_hhid plot_id)		// collapsing down to household-plot level
gen ha_cultivated_plots = plot_ha if cultivate==1			// non-missing only if plot was cultivated in at least one season
collapse (sum) ha_cultivated_plots, by(y4_hhid)				// total ha of all plots that were cultivated in at least one season
lab var ha_cultivated_plots "Area of cultivated plots (ha)"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cultivated_plots_ha.dta", replace

use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rental_rate_lrs.dta", clear
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rental_rate_srs.dta"
collapse (sum) value_rented_land*, by(y4_hhid)		// total over BOTH seasons (total spent on rent over course of entire year)
lab var value_rented_land "Value of rented land (household expenditures)"
lab var value_rented_land_male "Value of rented land (household expenditures - male-managed plots)"
lab var value_rented_land_female "Value of rented land (household expenditures - female-managed plots)"
lab var value_rented_land_mixed "Value of rented land (household expenditures - mixed-managed plots)"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rental_rate.dta", replace

*Now getting area planted
*  LRS  *
use "${Tanzania_NPS_W4_raw_data}/ag_sec_4a.dta", clear
drop if plotnum==""
ren  plotnum plot_id
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rent_nomiss_lrs.dta", nogen keep(1 3)
*First rescaling
gen percent_plot = 0.25*(ag4a_02==1) + 0.5*(ag4a_02==2) + 0.75*(ag4a_02==3)
replace percent_plot = 1 if ag4a_01==1
bys y4_hhid plot_id: egen total_percent_plot = total(percent_plot)		
replace percent_plot = percent_plot*(1/total_percent_plot) if total_percent_plot>1 & total_percent_plot!=.	
*Merging in total plot area from previous module
merge m:1 plot_id y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_area_lrs", nogen assert(2 3) keep(3)			
gen ha_planted = percent_plot*plot_ha
gen ha_planted_male = ha_planted if dm_gender==1
gen ha_planted_female = ha_planted if dm_gender==2
gen ha_planted_mixed = ha_planted if dm_gender==3
*Merging in geographic variables
merge m:1 y4_hhid using "${Tanzania_NPS_W4_raw_data}/hh_sec_a.dta", nogen assert(2 3) keep(3)			
*Now merging in aggregate rental costs
merge m:1 hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_rental_rate_lrs", nogen assert(2 3) keep(3)			
*Now merging in rental costs of individual plots
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rent_nomiss_lrs.dta", nogen keep(1 3)
*Now merging in household rental rate
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_rental_rate_hhid_lrs.dta", nogen keep(1 3)
gen value_owned_land = ha_planted*ha_rental_rate if ag3a_33==0 | ag3a_33==.		
replace value_owned_land = ha_planted*ha_rental_hh_lrs if ha_rental_hh_lrs!=0 & ha_rental_hh_lrs!=. & (ag3a_33==0 | ag3a_33==.)		
*Now creating gender value
gen value_owned_land_male = ha_planted*ha_rental_rate if (ag3a_33==0 | ag3a_33==.) & dm_gender==1
replace value_owned_land_male = ha_planted*ha_rental_hh_lrs if ha_rental_hh_lrs!=0 & ha_rental_hh_lrs!=. & (ag3a_33==0 | ag3a_33==.) & dm_gender==1
*Female
gen value_owned_land_female = ha_planted*ha_rental_rate if (ag3a_33==0 | ag3a_33==.) & dm_gender==2
replace value_owned_land_female = ha_planted*ha_rental_hh_lrs if ha_rental_hh_lrs!=0 & ha_rental_hh_lrs!=. & (ag3a_33==0 | ag3a_33==.) & dm_gender==2
*Mixed
gen value_owned_land_mixed = ha_planted*ha_rental_rate if (ag3a_33==0 | ag3a_33==.) & dm_gender==3
replace value_owned_land_mixed = ha_planted*ha_rental_hh_lrs if ha_rental_hh_lrs!=0 & ha_rental_hh_lrs!=. & (ag3a_33==0 | ag3a_33==.) & dm_gender==3
collapse (sum) value_owned_land* ha_planted*, by(y4_hhid plot_id)			// summing ha_planted across crops on same plot
lab var value_owned_land "Value of owned land that was cultivated (household)"
lab var value_owned_land_male "Value of owned land (male-managed)"
lab var value_owned_land_female "Value of owned land (female-managed)"
lab var value_owned_land_mixed "Value of owned land (mixed-managed)"
lab var ha_planted "Area planted (household)"
lab var ha_planted_male "Area planted (male-managed)"
lab var ha_planted_female "Area planted (female-managed)"
lab var ha_planted_mixed "Area planted (mixed-managed)"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_land_lrs.dta", replace

*  SRS  *
*Now getting area planted
use "${Tanzania_NPS_W4_raw_data}/ag_sec_4b.dta", clear
drop if plotnum==""
ren plotnum plot_id 
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rent_nomiss_lrs.dta", nogen keep(1 3) keepusing(dm_gender)
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rent_nomiss_srs.dta", nogen keep(1 3) keepusing(dm_gender) update
*First rescaling
gen percent_plot = 0.25*(ag4b_02==1) + 0.5*(ag4b_02==2) + 0.75*(ag4b_02==3)
replace percent_plot = 1 if ag4b_01==1
bys y4_hhid plot_id: egen total_percent_plot = total(percent_plot)
replace percent_plot = percent_plot*(1/total_percent_plot) if total_percent_plot>1 & total_percent_plot!=.	
*3,044 changes (55 percent of observations)!
*Merging in total plot area
merge m:1 plot_id y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_area_lrs", nogen keep(1 3) keepusing(plot_ha)						
merge m:1 plot_id y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_area_srs", nogen keepusing(plot_ha) update							
gen ha_planted = percent_plot*plot_ha
gen ha_planted_male = ha_planted if dm_gender==1
gen ha_planted_female = ha_planted if dm_gender==2
gen ha_planted_mixed = ha_planted if dm_gender==3
*Merging in geographic variables
merge m:1 y4_hhid using "${Tanzania_NPS_W4_raw_data}/hh_sec_a.dta", nogen assert(2 3) keep(3)			
*Now merging in rental costs
merge m:1 hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_rental_rate_lrs", nogen assert(2 3) keep(3)			
*Now merging in rental costs actually incurred by household
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rent_nomiss_lrs.dta", nogen keep(1 3)
*Now merging in household rental rate
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_rental_rate_hhid_lrs.dta", nogen keep(1 3)		
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_rental_rate_hhid_srs.dta", nogen	update			
gen value_owned_land = ha_planted*ha_rental_rate if ag3a_33==0 | ag3a_33==.		
replace value_owned_land = ha_planted*ha_rental_hh_lrs if ha_rental_hh_lrs!=0 & ha_rental_hh_lrs!=. & (ag3a_33==0 | ag3a_33==.)		
*Now creating gender value
gen value_owned_land_male = ha_planted*ha_rental_rate if (ag3a_33==0 | ag3a_33==.) & dm_gender==1
replace value_owned_land_male = ha_planted*ha_rental_hh_lrs if ha_rental_hh_lrs!=0 & ha_rental_hh_lrs!=. & (ag3a_33==0 | ag3a_33==.) & dm_gender==1
*Female
gen value_owned_land_female = ha_planted*ha_rental_rate if (ag3a_33==0 | ag3a_33==.) & dm_gender==2
replace value_owned_land_female = ha_planted*ha_rental_hh_lrs if ha_rental_hh_lrs!=0 & ha_rental_hh_lrs!=. & (ag3a_33==0 | ag3a_33==.) & dm_gender==2
*Mixed
gen value_owned_land_mixed = ha_planted*ha_rental_rate if (ag3a_33==0 | ag3a_33==.) & dm_gender==3
replace value_owned_land_mixed = ha_planted*ha_rental_hh_lrs if ha_rental_hh_lrs!=0 & ha_rental_hh_lrs!=. & (ag3a_33==0 | ag3a_33==.) & dm_gender==3
collapse (sum) value_owned_land* ha_planted*, by(y4_hhid plot_id)			
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_land_lrs.dta"						

preserve
collapse (sum) ha_planted*, by(y4_hhid)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_ha_planted_total.dta", replace
restore
collapse (sum) ha_planted* value_owned_land*, by(y4_hhid plot_id)			// taking max area planted (and value owned) by plot so as to not double count plots that were planted in both seasons
collapse (sum) ha_planted* value_owned_land*, by(y4_hhid)					// now summing to household
lab var value_owned_land "Value of owned land that was cultivated (household)"
lab var value_owned_land_male "Value of owned land (male-managed plots)"
lab var value_owned_land_female "Value of owned land (female-managed plots)"
lab var value_owned_land_mixed "Value of owned land (mixed-managed plots)"
lab var ha_planted "Area planted (household)"
lab var ha_planted_male "Area planted (male-managed plots)"
lab var ha_planted_female "Area planted (female-managed plots)"
lab var ha_planted_mixed "Area planted (mixed-managed plots)"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_land.dta", replace


********************************************************************************
*INPUT COST *
********************************************************************************
*  LRS  *
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
drop if plotnum==""			
*Merging in geographic variables first (for constructing prices)
merge m:1 y4_hhid using "${Tanzania_NPS_W4_raw_data}/hh_sec_a.dta", nogen assert(2 3) keep(3)		
*Gender variables
ren  plotnum plot_id
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rent_nomiss_lrs.dta", nogen keep(1 3) keepusing(dm_gender)
*Starting with fertilizer
egen value_inorg_fert_lrs = rowtotal(ag3a_51 ag3a_58)			
egen value_herb_pest_lrs = rowtotal(ag3a_63 ag3a_65c)			
gen value_org_purchased_lrs = ag3a_45						

preserve
gen fert_org_kg = ag3a_42		
egen fert_inorg_kg = rowtotal(ag3a_49 ag3a_56)		
gen fert_inorg_kg_male = fert_inorg_kg if dm_gender==1
gen fert_inorg_kg_female = fert_inorg_kg if dm_gender==2
gen fert_inorg_kg_mixed = fert_inorg_kg if dm_gender==3
collapse (sum) fert_org_kg fert_inorg_kg*, by(y4_hhid)
lab var fert_org_kg "Organic fertilizer (kgs)"
lab var fert_inorg_kg "Inorganic fertilizer (kgs)"	
lab var fert_inorg_kg_male "Inorganic fertilizer (kgs) for male-managed crops"
lab var fert_inorg_kg_female "Inorganic fertilizer (kgs) for female-managed crops"
lab var fert_inorg_kg_mixed "Inorganic fertilizer (kgs) for mixed-managed crops"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_fert_lrs.dta", replace
restore

recode ag3a_42 ag3a_44 (.=0)						
gen org_fert_notpurchased = ag3a_42-ag3a_44			
replace org_fert_notpurchased = 0 if org_fert_notpurchased<0			
gen org_fert_purchased = ag3a_44					
gen org_fert_price = ag3a_45/org_fert_purchased		
recode org_fert_price (0=.) 

*Household-specific value
preserve
keep if org_fert_purchased!=0 & org_fert_purchased!=.		
collapse (sum) org_fert_purchased ag3a_45, by(y4_hhid)		
gen org_fert_price_hh = ag3a_45/org_fert_purchased
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_org_fert_lrs.dta", replace
restore
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_org_fert_lrs.dta", nogen

*Geographic medians
bys hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen org_price_count_vil = count(org_fert_price)
bys hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen org_price_vil = median(org_fert_price) 
bys hh_a01_1 hh_a02_1 hh_a03_1: egen org_price_count_ward = count(org_fert_price)
bys hh_a01_1 hh_a02_1 hh_a03_1: egen org_price_ward = median(org_fert_price) 
bys hh_a01_1 hh_a02_1: egen org_price_count_dist = count(org_fert_price)
bys hh_a01_1 hh_a02_1: egen org_price_dist = median(org_fert_price) 
bys hh_a01_1: egen org_price_count_reg = count(org_fert_price)
bys hh_a01_1: egen org_price_reg = median(org_fert_price)
egen org_price_nat = median(org_fert_price)
drop org_fert_price
gen org_fert_price = org_price_vil if org_price_count_vil>=10
replace org_fert_price = org_price_ward if org_price_count_ward>=10 & org_fert_price==.
replace org_fert_price = org_price_dist if org_price_count_dist>=10 & org_fert_price==.
replace org_fert_price = org_price_reg if org_price_count_reg>=10 & org_fert_price==.
replace org_fert_price = org_price_nat if org_fert_price==.			
replace org_fert_price = org_fert_price_hh if org_fert_price_hh!=. & org_fert_price_hh!=0		
gen value_org_notpurchased_lrs = org_fert_price*org_fert_notpurchased						
*Hired labor
egen prep_labor = rowtotal(ag3a_74_1 ag3a_74_2 ag3a_74_3)		
egen weed_labor = rowtotal(ag3a_74_5 ag3a_74_6 ag3a_74_7)		
egen harv_labor = rowtotal(ag3a_74_13 ag3a_74_14 ag3a_74_15)	
*Hired wages:
gen prep_wage = ag3a_74_4/prep_labor
gen weed_wage = ag3a_74_8/weed_labor
gen harv_wage = ag3a_74_16/harv_labor
*Hired costs
gen prep_labor_costs = ag3a_74_4
gen weed_labor_costs = ag3a_74_8
gen harv_labor_costs = ag3a_74_16
egen value_hired_labor_prep_lrs = rowtotal(*_labor_costs)
*Constructing a household-specific wage
preserve
collapse (sum) prep_labor weed_labor harv_labor *labor_costs, by(y4_hhid)		
gen prep_wage_hh = prep_labor_costs/prep_labor									
gen weed_wage_hh = weed_labor_costs/weed_labor
gen harv_wage_hh = harv_labor_costs/harv_labor
recode *wage* (0=.)			
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_wages_hh_lrs.dta", replace
restore
*Merging right back in
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_wages_hh_lrs.dta", nogen

*Going to construct wages separately for each type
*Constructing for each labor type
foreach i in prep weed harv{
	recode `i'_wage (0=.) 
	bys hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen `i'_wage_count_vil = count(`i'_wage)
	bys hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen `i'_wage_price_vil = median(`i'_wage)
	bys hh_a01_1 hh_a02_1 hh_a03_1: egen `i'_wage_count_ward = count(`i'_wage)
	bys hh_a01_1 hh_a02_1 hh_a03_1: egen `i'_wage_price_ward = median(`i'_wage)
	bys hh_a01_1 hh_a02_1: egen `i'_wage_count_dist = count(`i'_wage)
	bys hh_a01_1 hh_a02_1: egen `i'_wage_price_dist = median(`i'_wage)
	bys hh_a01_1: egen `i'_wage_count_reg = count(`i'_wage)
	bys hh_a01_1: egen `i'_wage_price_reg = median(`i'_wage)
	egen `i'_wage_price_nat = median(`i'_wage)
	*Creating wage rate
	gen `i'_wage_rate = `i'_wage_price_vil if `i'_wage_count_vil>=10
	replace `i'_wage_rate = `i'_wage_price_ward if `i'_wage_count_ward>=10 & `i'_wage_rate==.
	replace `i'_wage_rate = `i'_wage_price_dist if `i'_wage_count_dist>=10 & `i'_wage_rate==.
	replace `i'_wage_rate = `i'_wage_price_reg if `i'_wage_count_reg>=10 & `i'_wage_rate==.
	replace `i'_wage_rate = `i'_wage_price_nat if `i'_wage_rate==.
}

*prep
egen prep_fam_labor_tot = rowtotal(ag3a_72_1 ag3a_72_2 ag3a_72_3 ag3a_72_4 ag3a_72_5 ag3a_72_6)
*weed
egen weed_fam_labor_tot = rowtotal(ag3a_72_7 ag3a_72_8 ag3a_72_9 ag3a_72_10 ag3a_72_11 ag3a_72_12)
*prep
egen harv_fam_labor_tot = rowtotal(ag3a_72_13 ag3a_72_14 ag3a_72_15 ag3a_72_16 ag3a_72_17 ag3a_72_18)
*Generating family values for each activity
gen fam_prep_val = prep_fam_labor_tot*prep_wage_rate											
replace fam_prep_val = prep_fam_labor_tot*prep_wage_hh if prep_wage_hh!=0 & prep_wage_hh!=.		
gen fam_weed_val = weed_fam_labor_tot*weed_wage_rate
replace fam_weed_val = weed_fam_labor_tot*weed_wage_hh if weed_wage_hh!=0 & weed_wage_hh!=.
gen fam_harv_val = harv_fam_labor_tot*harv_wage_rate
replace fam_harv_val = harv_fam_labor_tot*harv_wage_hh if harv_wage_hh!=0 & harv_wage_hh!=.
*Summing at the plot level
egen value_fam_labor_lrs = rowtotal(fam_prep_val fam_weed_val fam_harv_val)
*Renaming (dropping lrs)
ren *_lrs *
foreach i in value_inorg_fert value_herb_pest value_org_purchased value_org_notpurchased value_hired_labor_prep value_fam_labor{
	gen `i'_male = `i' if dm_gender==1
	gen `i'_female = `i' if dm_gender==2
	gen `i'_mixed = `i' if dm_gender==3
}
collapse (sum) value_*, by(y4_hhid)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_inputs_lrs.dta", replace


*  SRS  *
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta", clear
drop if plotnum==""			
*Merging in geographic variables first (for constructing prices)
merge m:1 y4_hhid using "${Tanzania_NPS_W4_raw_data}/hh_sec_a.dta", nogen assert(2 3) keep(3)		
*Gender variables
ren plotnum plot_id
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rent_nomiss_lrs.dta", nogen keep(1 3) keepusing(dm_gender)
*Starting with fertilizer
egen value_inorg_fert_srs = rowtotal(ag3b_51 ag3b_58)
egen value_herb_pest_srs = rowtotal(ag3b_63 ag3b_65c)
gen value_org_purchased_srs = ag3b_45
preserve
gen fert_org_kg = ag3b_42
egen fert_inorg_kg = rowtotal(ag3b_49 ag3b_56)
gen fert_inorg_kg_male = fert_inorg_kg if dm_gender==1
gen fert_inorg_kg_female = fert_inorg_kg if dm_gender==2
gen fert_inorg_kg_mixed = fert_inorg_kg if dm_gender==3
collapse (sum) fert_org_kg fert_inorg_kg*, by(y4_hhid)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_fert_srs.dta", replace
restore
recode ag3b_42 ag3b_44 (.=0)
gen org_fert_notpurchased = ag3b_42-ag3b_44			
replace org_fert_notpurchased = 0 if org_fert_notpurchased<0			
gen org_fert_purchased = ag3b_44					
gen org_fert_price = ag3b_45/org_fert_purchased		
recode org_fert_price (0=.)

*Household-specific value
preserve
keep if org_fert_purchased!=0 & org_fert_purchased!=.		
collapse (sum) org_fert_purchased ag3b_45, by(y4_hhid)		
gen org_fert_price_hh = ag3b_45/org_fert_purchased
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_org_fert_srs.dta", replace
restore
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_org_fert_srs.dta", nogen
*Geographic medians
bys hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen org_price_count_vil = count(org_fert_price)
bys hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen org_price_vil = median(org_fert_price) 
bys hh_a01_1 hh_a02_1 hh_a03_1: egen org_price_count_ward = count(org_fert_price)
bys hh_a01_1 hh_a02_1 hh_a03_1: egen org_price_ward = median(org_fert_price) 
bys hh_a01_1 hh_a02_1: egen org_price_count_dist = count(org_fert_price)
bys hh_a01_1 hh_a02_1: egen org_price_dist = median(org_fert_price) 
bys hh_a01_1: egen org_price_count_reg = count(org_fert_price)
bys hh_a01_1: egen org_price_reg = median(org_fert_price)
egen org_price_nat = median(org_fert_price)
drop org_fert_price
gen org_fert_price = org_price_vil if org_price_count_vil>=10
replace org_fert_price = org_price_ward if org_price_count_ward>=10 & org_fert_price==.
replace org_fert_price = org_price_dist if org_price_count_dist>=10 & org_fert_price==.
replace org_fert_price = org_price_reg if org_price_count_reg>=10 & org_fert_price==.
replace org_fert_price = org_price_nat if org_fert_price==.			
replace org_fert_price = org_fert_price_hh if org_fert_price_hh!=. & org_fert_price_hh!=0		
gen value_org_notpurchased_srs = org_fert_price*org_fert_notpurchased						
*Hired labor
egen prep_labor = rowtotal(ag3b_74_1 ag3b_74_2 ag3b_74_3)		
egen weed_labor = rowtotal(ag3b_74_5 ag3b_74_6 ag3b_74_7)		
egen harv_labor = rowtotal(ag3b_74_13 ag3b_74_14 ag3b_74_15)	
*Hired wages:
gen prep_wage = ag3b_74_4/prep_labor
gen weed_wage = ag3b_74_8/weed_labor
gen harv_wage = ag3b_74_16/harv_labor
*Hired costs
gen prep_labor_costs = prep_labor*prep_wage
gen weed_labor_costs = weed_labor*weed_wage
gen harv_labor_costs = harv_labor*harv_wage
egen value_hired_labor_prep_srs = rowtotal(*_labor_costs)

*Constructing a household-specific wage
preserve
collapse (sum) prep_labor weed_labor harv_labor *labor_costs, by(y4_hhid)
gen prep_wage_hh = prep_labor_costs/prep_labor			
gen weed_wage_hh = weed_labor_costs/weed_labor
gen harv_wage_hh = harv_labor_costs/harv_labor
recode *wage* (0=.)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_wages_hh_srs.dta", replace
restore
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_wages_hh_srs.dta", nogen
*construct wages separately for each type
*Constructing for each labor type
foreach i in prep weed harv{
	recode `i'_wage (0=.) 
	bys hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen `i'_wage_count_vil = count(`i'_wage)
	bys hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen `i'_wage_price_vil = median(`i'_wage)
	bys hh_a01_1 hh_a02_1 hh_a03_1: egen `i'_wage_count_ward = count(`i'_wage)
	bys hh_a01_1 hh_a02_1 hh_a03_1: egen `i'_wage_price_ward = median(`i'_wage)
	bys hh_a01_1 hh_a02_1: egen `i'_wage_count_dist = count(`i'_wage)
	bys hh_a01_1 hh_a02_1: egen `i'_wage_price_dist = median(`i'_wage)
	bys hh_a01_1: egen `i'_wage_count_reg = count(`i'_wage)
	bys hh_a01_1: egen `i'_wage_price_reg = median(`i'_wage)
	egen `i'_wage_price_nat = median(`i'_wage)
	*Creating wage rate
	gen `i'_wage_rate = `i'_wage_price_vil if `i'_wage_count_vil>=10
	replace `i'_wage_rate = `i'_wage_price_ward if `i'_wage_count_ward>=10 & `i'_wage_rate==.
	replace `i'_wage_rate = `i'_wage_price_dist if `i'_wage_count_dist>=10 & `i'_wage_rate==.
	replace `i'_wage_rate = `i'_wage_price_reg if `i'_wage_count_reg>=10 & `i'_wage_rate==.
	replace `i'_wage_rate = `i'_wage_price_nat if `i'_wage_rate==.
}
*prep
egen prep_fam_labor_tot = rowtotal(ag3b_72_1 ag3b_72_2 ag3b_72_3 ag3b_72_4 ag3b_72_5 ag3b_72_6)
*weed
egen weed_fam_labor_tot = rowtotal(ag3b_72_7 ag3b_72_8 ag3b_72_9 ag3b_72_10 ag3b_72_11 ag3b_72_12)
*prep
egen harv_fam_labor_tot = rowtotal(ag3b_72_13 ag3b_72_14 ag3b_72_15 ag3b_72_16 ag3b_72_17 ag3b_72_18)
*Generating family values for each activity
gen fam_prep_val = prep_fam_labor_tot*prep_wage_rate										
replace fam_prep_val = prep_fam_labor_tot*prep_wage_hh if prep_wage_hh!=0 & prep_wage_hh!=.		
gen fam_weed_val = weed_fam_labor_tot*weed_wage_rate
replace fam_weed_val = weed_fam_labor_tot*weed_wage_hh if weed_wage_hh!=0 & weed_wage_hh!=.
gen fam_harv_val = harv_fam_labor_tot*harv_wage_rate
replace fam_harv_val = harv_fam_labor_tot*harv_wage_hh if harv_wage_hh!=0 & harv_wage_hh!=.
egen value_fam_labor_srs = rowtotal(fam_prep_val fam_weed_val fam_harv_val)
ren *_srs *
foreach i in value_inorg_fert value_herb_pest value_org_purchased value_org_notpurchased value_hired_labor_prep value_fam_labor{
	gen `i'_male = `i' if dm_gender==1
	gen `i'_female = `i' if dm_gender==2
	gen `i'_mixed = `i' if dm_gender==3
}
collapse (sum) value_*, by(y4_hhid)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_inputs_srs.dta", replace

use  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_inputs_lrs.dta", clear
append using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_inputs_srs.dta"
collapse (sum) value_*, by(y4_hhid)
foreach v of varlist *prep*  {
	local l`v' = subinstr("`v'","_prep","",1)
	ren `v' `l`v''
}

*/

//ALT 02.02.23: Note to see if this can be replaced by new inputs code 
/*
********************************************************************************
* SEED COST *
********************************************************************************
*  LRS  *
use "${Tanzania_NPS_W4_raw_data}/ag_sec_4a.dta", clear
drop if plotnum==""
ren plotnum plot_id
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rent_nomiss_lrs.dta", nogen keep(1 3) keepusing(dm_gender)
tab ag4a_10_2 ag4a_10c_2		

gen seeds_not_purchased = ag4a_10_1 - ag4a_10c_1					
replace seeds_not_purchased = 0 if seeds_not_purchased<0			
replace seeds_not_purchased = ag4a_10_1 if seeds_not_purchased==.	
gen seeds_purchased = ag4a_10c_1									
gen seed_price_hh = ag4a_12/ag4a_10c_1			
recode seed_price_hh (0=.) 
*Household-specific values
preserve
drop if ag4a_12==0 | ag4a_12==.				
collapse (sum) ag4a_12 ag4a_10c_1, by(y4_hhid zaocode)
gen seed_price_hh_crop = ag4a_12/ag4a_10c_1
recode seed_price_hh_crop (0=.) 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_seeds_hh_lrs.dta", replace
restore
merge m:1 y4_hhid zaocode using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_seeds_hh_lrs.dta", nogen

*Geographically
*Merging in geographic variables first
merge m:1 y4_hhid using "${Tanzania_NPS_W4_raw_data}/hh_sec_a.dta", nogen assert(2 3) keep(3)
bys zaocode ag4a_10_2 hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen seed_count_vil = count(seed_price_hh)		
bys zaocode ag4a_10_2 hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen seed_price_vil = median(seed_price_hh)
bys zaocode ag4a_10_2 hh_a01_1 hh_a02_1 hh_a03_1: egen seed_count_ward = count(seed_price_hh)
bys zaocode ag4a_10_2 hh_a01_1 hh_a02_1 hh_a03_1: egen seed_price_ward = median(seed_price_hh)
bys zaocode ag4a_10_2 hh_a01_1 hh_a02_1: egen seed_count_dist = count(seed_price_hh)
bys zaocode ag4a_10_2 hh_a01_1 hh_a02_1: egen seed_price_dist = median(seed_price_hh)
bys zaocode ag4a_10_2 hh_a01_1: egen seed_count_reg = count(seed_price_hh)
bys zaocode ag4a_10_2 hh_a01_1: egen seed_price_reg = median(seed_price_hh)
bys zaocode ag4a_10_2: egen seed_price_nat = median(seed_price_hh)
gen seed_price = seed_price_vil if seed_count_vil>=10
replace seed_price = seed_price_ward if seed_count_ward>=10 & seed_price==.
replace seed_price = seed_price_dist if seed_count_dist>=10 & seed_price==.
replace seed_price = seed_price_reg if seed_count_reg>=10 & seed_price==.
replace seed_price = seed_price_nat if seed_price==.			
gen value_seeds_not_purchased_lrs = seeds_not_purchased*seed_price			
replace value_seeds_not_purchased_lrs = seeds_not_purchased*seed_price_hh_crop if seed_price_hh_crop!=. & seed_price_hh_crop!=0			
gen value_seeds_purchased_lrs = ag4a_12
ren *_lrs *
foreach i in value_seeds_purchased value_seeds_not_purchased{
	gen `i'_male = `i' if dm_gender==1
	gen `i'_female = `i' if dm_gender==2
	gen `i'_mixed = `i' if dm_gender==3
}
collapse (sum) value_* , by(y4_hhid)
sum value_seeds_purchased, d
sum value_seeds_not_purchased, d
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_seed_lrs.dta", replace

 
*  SRS  *
use "${Tanzania_NPS_W4_raw_data}/ag_sec_4b.dta", clear
drop if plotnum==""
ren plotnum plot_id
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rent_nomiss_lrs.dta", nogen keep(1 3) keepusing(dm_gender)		
gen seeds_not_purchased = ag4b_10_1 - ag4b_10c_1				
replace seeds_not_purchased = 0 if seeds_not_purchased<0			
replace seeds_not_purchased = ag4b_10_1 if seeds_not_purchased==.	
gen seeds_purchased = ag4b_10c_1									
gen seed_price_hh = ag4b_12/ag4b_10c_1			
*Household-specific values
preserve
drop if ag4b_12==0 | ag4b_12==.				
collapse (sum) ag4b_12 ag4b_10c_1, by(y4_hhid zaocode)
gen seed_price_hh_crop = ag4b_12/ag4b_10c_1
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_seeds_hh_srs.dta", replace
restore
merge m:1 y4_hhid zaocode using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_seeds_hh_srs.dta", nogen
*Geographically
*Merging in geographic variables first
merge m:1 y4_hhid using "${Tanzania_NPS_W4_raw_data}/hh_sec_a.dta", nogen assert(2 3) keep(3)
recode seed_price_hh (0=.)
bys zaocode ag4b_10_2 hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen seed_count_vil = count(seed_price_hh)		
bys zaocode ag4b_10_2 hh_a01_1 hh_a02_1 hh_a03_1 hh_a03_3a: egen seed_price_vil = median(seed_price_hh)
bys zaocode ag4b_10_2 hh_a01_1 hh_a02_1 hh_a03_1: egen seed_count_ward = count(seed_price_hh)
bys zaocode ag4b_10_2 hh_a01_1 hh_a02_1 hh_a03_1: egen seed_price_ward = median(seed_price_hh)
bys zaocode ag4b_10_2 hh_a01_1 hh_a02_1: egen seed_count_dist = count(seed_price_hh)
bys zaocode ag4b_10_2 hh_a01_1 hh_a02_1: egen seed_price_dist = median(seed_price_hh)
bys zaocode ag4b_10_2 hh_a01_1: egen seed_count_reg = count(seed_price_hh)
bys zaocode ag4b_10_2 hh_a01_1: egen seed_price_reg = median(seed_price_hh)
bys zaocode ag4b_10_2: egen seed_price_nat = median(seed_price_hh)
gen seed_price = seed_price_vil if seed_count_vil>=10
replace seed_price = seed_price_ward if seed_count_ward>=10 & seed_price==.
replace seed_price = seed_price_dist if seed_count_dist>=10 & seed_price==.
replace seed_price = seed_price_reg if seed_count_reg>=10 & seed_price==.
replace seed_price = seed_price_nat if seed_price==.
gen value_seeds_not_purchased_srs = seeds_not_purchased*seed_price		
replace value_seeds_not_purchased_srs = seeds_not_purchased*seed_price_hh_crop if seed_price_hh_crop!=. & seed_price_hh_crop!=0			
gen value_seeds_purchased_srs = ag4b_12
ren *_srs *
foreach i in value_seeds_purchased value_seeds_not_purchased{
	gen `i'_male = `i' if dm_gender==1
	gen `i'_female = `i' if dm_gender==2
	gen `i'_mixed = `i' if dm_gender==3
}
collapse (sum) value_* , by(y4_hhid)
sum value_seeds_purchased, d
sum value_seeds_not_purchased, d
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_seed_srs.dta", replace

*Rental of agricultural tools, machines, animal traction
use "${Tanzania_NPS_W4_raw_data}/ag_sec_11.dta", clear
gen animal_traction = (itemid>=3 & itemid<=5)
gen ag_asset = (itemid<3 | itemid>8)
gen tractor = (itemid>=6 & itemid<=8)
ren ag11_09 rental_cost
gen rental_cost_animal_traction = rental_cost if animal_traction==1
gen rental_cost_ag_asset = rental_cost if ag_asset==1
gen rental_cost_tractor = rental_cost if tractor==1
recode rental_cost_animal_traction rental_cost_ag_asset rental_cost_tractor (.=0)
collapse (sum) rental_cost_animal_traction rental_cost_ag_asset rental_cost_tractor, by (y4_hhid)
lab var rental_cost_animal_traction "Costs for renting animal traction"
lab var rental_cost_ag_asset "Costs for renting other agricultural items"
lab var rental_cost_tractor "Costs for renting a tractor"
egen value_ag_rentals = rowtotal(rental_cost_*)
lab var value_ag_rentals "Value of rented equipment (household level"
 save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_asset_rental_costs.dta", replace

* merging cost variable together
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_land.dta", clear
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_rental_rate.dta"
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_inputs_lrs.dta"
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_inputs_srs.dta"
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_seed_lrs.dta"
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_seed_srs.dta"
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_asset_rental_costs.dta"
collapse (sum) value_* ha_planted*, by(y4_hhid)
lab var value_owned_land "Value of owned land that was cultivated (household)"
lab var value_owned_land_male "Value of owned land (male-managed plots)"
lab var value_owned_land_female "Value of owned land (female-managed plots)"
lab var value_owned_land_mixed "Value of owned land (mixed-managed plots)"
lab var value_rented_land "Value of rented land that was cultivated (household)"
lab var value_rented_land_male "Value of rented land (male-managed plots)"
lab var value_rented_land_female "Value of rented land (female-managed plots)"
lab var value_rented_land_mixed "Value of rented land (mixed-managed plots)"
lab var ha_planted "Area planted (household)"
lab var ha_planted_male "Area planted (male-managed plots)"
lab var ha_planted_female "Area planted (female-managed plots)"
lab var ha_planted_mixed "Area planted (mixed-managed plots)"
lab var value_seeds_not_purchased "Value of seeds not purchased (household)"
lab var value_seeds_not_purchased_male "Value of seeds not purchased (male-managed plots)"
lab var value_seeds_not_purchased_female "Value of seeds not purchased (female-managed plots)"
lab var value_seeds_not_purchased_mixed "Value of seeds not purchased (mixed-managed plots)"
lab var value_seeds_purchased "Value of seeds purchased (household)"
lab var value_seeds_purchased_male "Value of seeds purchased (male-managed plots)"
lab var value_seeds_purchased_female "Value of seeds purchased (female-managed plots)"
lab var value_seeds_purchased_mixed "Value of seeds purchased (mixed-managed plots)"
lab var value_herb_pest "Value of herbicide_pesticide (household)"
lab var value_herb_pest_male "Value of herbicide_pesticide (male-managed plots)"
lab var value_herb_pest_female "Value of herbicide_pesticide (female-managed plots)"
lab var value_herb_pest_mixed "Value of herbicide_pesticide (mixed-managed plots)"
lab var value_inorg_fert "Value of inorganic fertilizer (household)"
lab var value_inorg_fert_male "Value of inorganic fertilizer (male-managed plots)"
lab var value_inorg_fert_female "Value of inorganic fertilizer female-managed plots)"
lab var value_inorg_fert_mixed "Value of inorganic fertilizer (mixed-managed plots)"
lab var value_org_purchased "Value organic fertilizer purchased (household)"
lab var value_org_purchased_male "Value organic fertilizer purchased (male-managed plots)"
lab var value_org_purchased_female "Value organic fertilizer purchased (female-managed plots)"
lab var value_org_purchased_mixed "Value organic fertilizer purchased (mixed-managed plots)"
lab var value_org_notpurchased "Value organic fertilizer not purchased (household)"
lab var value_org_notpurchased_male "Value organic fertilizer not purchased (male-managed plots)"
lab var value_org_notpurchased_female "Value organic fertilizer not purchased (female-managed plots)"
lab var value_org_notpurchased_mixed "Value organic fertilizer not purchased (mixed-managed plots)"
foreach v of varlist *prep*  {
	local l`v' = subinstr("`v'","_prep","",1)
	ren `v' `l`v''
}
lab var value_hired_labor "Value of hired labor (household)"
lab var value_hired_labor_male "Value of hired labor (male-managed crops)"
lab var value_hired_labor_female "Value of hired labor (female-managed crops)"
lab var value_hired_labor_mixed "Value of hired labor (mixed-managed crops)"
lab var value_fam_labor "Value of family labor (household)"
lab var value_fam_labor_male "Value of family labor (male-managed crops)"
lab var value_fam_labor_female "Value of family labor (female-managed crops)"
lab var value_fam_labor_mixed "Value of family labor (mixed-managed crops)"
lab var value_ag_rentals "Value of rented equipment (household level"
recode ha_planted* (0=.)
*Explicit and implicit costs at the plot level
egen cost_total =rowtotal(value_owned_land value_rented_land value_inorg_fert value_herb_pest value_org_purchased ///
	value_org_notpurchased value_hired_labor value_fam_labor value_seeds_not_purchased value_seeds_purchased)
lab var cost_total "Explicit + implicit costs of crop production (plot level)" 
*Creating total costs by gender (NOTE: excludes ag_rentals because those are at the household level)
foreach i in male female mixed{
	egen cost_total_`i' = rowtotal(value_owned_land_`i' value_rented_land_`i' value_inorg_fert_`i' value_herb_pest_`i' value_org_purchased_`i' ///
	value_org_notpurchased_`i' value_hired_labor_`i' value_fam_labor_`i' value_seeds_not_purchased_`i' value_seeds_purchased_`i')
}
lab var cost_total_male "Explicit + implicit costs of crop production (male-managed plots)" 
lab var cost_total_female "Explicit + implicit costs of crop production (female-managed plots)"
lab var cost_total_mixed "Explicit + implicit costs of crop production (mixed-managed plots)"
*Explicit costs at the plot level 
egen cost_expli =rowtotal(value_rented_land value_inorg_fert value_herb_pest value_org_purchased value_hired_labor value_seeds_purchased)
lab var cost_expli "Explicit costs of crop production (plot level)" 
*Creating explicit costs by gender
foreach i in male female mixed{
	egen cost_expli_`i' = rowtotal( value_rented_land_`i' value_inorg_fert_`i' value_herb_pest_`i' value_org_purchased_`i' value_hired_labor_`i' value_seeds_purchased_`i')
}
lab var cost_expli_male "Explicit costs of crop production (male-managed plots)" 
lab var cost_expli_female "Explicit costs of crop production (female-managed plots)" 
lab var cost_expli_mixed "Explicit costs of crop production (mixed-managed plots)" 
*Explicit costs at the household level
egen cost_expli_hh = rowtotal(value_ag_rentals value_rented_land value_inorg_fert value_herb_pest value_org_purchased value_hired_labor value_seeds_purchased)
lab var cost_expli_hh "Total explicit crop production (household level)" 
count if cost_expli_hh==0
*Recoding zeros as missings
recode cost_total* (0=.)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_cropcosts_total.dta", replace
//IHS 10/11/19 END
*/

********************************************************************************
*AGRICULTURAL WAGES
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta"
* The survey reports total wage paid and amount of hired labor: wage=total paid/ amount of labor
* set wage paid to . if zero or negative
recode ag3a_74_* ag3a_74_* (0=.)
ren ag3a_74_2 hired_male_lanprep
replace hired_male_lanprep = ag3b_74_2 if hired_male_lanprep==.
ren ag3a_74_1 hired_female_lanprep
replace hired_female_lanprep = ag3b_74_1 if hired_female_lanprep==.
ren ag3a_74_4 hlabor_paid_lanprep
replace hlabor_paid_lanprep = ag3b_74_4 if hlabor_paid_lanprep==.
ren ag3a_74_5 hired_male_weedingothers
replace hired_male_weedingothers = ag3b_74_5 if hired_male_weedingothers==.
ren ag3a_74_6 hired_female_weedingothers
replace hired_female_weedingothers = ag3b_74_6 if hired_female_weedingothers==.
ren ag3a_74_8 hlabor_paid_weedingothers
replace hlabor_paid_weedingothers = ag3b_74_8 if hlabor_paid_weedingothers==.
ren ag3a_74_14 hired_male_harvest
replace hired_male_harvest = ag3b_74_14 if hired_male_harvest==.
ren ag3a_74_13 hired_female_harvest
replace hired_female_harvest = ag3b_74_13 if hired_female_harvest==.
ren ag3a_74_16 hlabor_paid_harvest
replace hlabor_paid_harvest = ag3b_74_16 if hlabor_paid_harvest==.
recode hired* hlabor* (.=0)
*first collapse accross plot  to houshold level
collapse (sum) hired* hlabor*, by(y4_hhid)
gen hirelabor_lanprep=(hired_male_lanprep+hired_female_lanprep)
gen wage_lanprep=hlabor_paid_lanprep/hirelabor_lanprep
gen hirelabor_weedingothers=(hired_male_weedingothers+hired_female_weedingothers)
gen wage_weedingothers=hlabor_paid_weedingothers/hirelabor_weedingothers
gen hirelabor_harvest=(hired_male_harvest+hired_female_harvest)
gen wage_harvest=hlabor_paid_harvest/hirelabor_harvest
recode wage_lanprep hirelabor_lanprep wage_weedingothers hirelabor_weedingothers  wage_harvest hirelabor_harvest (.=0)
* get weighted average average accross group of activities to get paid wage at household level
gen wage_paid_aglabor=(wage_lanprep*hirelabor_lanprep+wage_weedingothers*hirelabor_weedingothers+wage_harvest*hirelabor_harvest)/ (hirelabor_lanprep+hirelabor_harvest+hirelabor_harvest)
*later will use hired_labor*weight for the summary stats on wage 
keep y4_hhid wage_paid_aglabor 
lab var wage_paid_aglabor "Daily wage in agriculture"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_ag_wage.dta", replace

//IHS 10/11/19 START

********************************************************************************
*RATE OF FERTILIZER APPLICATION *ALT 08.06.24: Updated; mainly legacy now.
********************************************************************************
//TO DO: Rate of nutrient application
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_input_quantities.dta", clear
keep y4_hhid plot_id short inorg_fert_rate org_fert_rate
ren inorg_fert_rate fert_inorg_kg
ren org_fert_rate fert_org_kg
drop if fert_inorg_kg==0 & fert_org_kg==0
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender)
collapse (sum) fert*, by(y4_hhid dm_gender)
gen dm_gender2="male" if dm_gender==1
replace dm_gender2="female" if dm_gender==2
replace dm_gender2 = "mixed" if dm_gender==3
ren fert_*_kg fert_*_kg_
drop dm_gender
reshape wide fert*_, i(y4_hhid) j(dm_gender2) string
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta", keep (1 3) nogen
gen fert_org_kg = fert_org_kg_male+fert_org_kg_female+fert_org_kg_mixed
gen fert_inorg_kg = fert_inorg_kg_male+fert_inorg_kg_female+fert_inorg_kg_mixed

lab var fert_inorg_kg "Quantity of fertilizer applied (kgs) (household level)"
lab var fert_inorg_kg_male "Quantity of fertilizer applied (kgs) (male-managed plots)"
lab var fert_inorg_kg_female "Quantity of fertilizer applied (kgs) (female-managed plots)"
lab var fert_inorg_kg_mixed "Quantity of fertilizer applied (kgs) (mixed-managed plots)"

save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fertilizer_application.dta", replace


********************************************************************************
*WOMEN'S DIET QUALITY
********************************************************************************
*Women's diet quality: proportion of women consuming nutrient-rich foods (%)
*Information not available

********************************************************************************
*HOUSEHOLD'S DIET DIVERSITY SCORE
********************************************************************************
* TZA LSMS 4 does not report individual consumption but instead household level consumption of various food items.
* Thus, only the proportion of householdd eating nutritious food can be estimated
use "${Tanzania_NPS_W4_raw_data}/hh_sec_j1.dta" , clear
* recode food items to map HDDS food categories
recode itemcode 	(101/112 1081 1082 				=1	"CEREALS" )  //// 
					(201/207    					=2	"WHITE ROOTS,TUBERS AND OTHER STARCHES"	)  ////
					(602 601 603	 				=3	"VEGETABLES"	)  ////	
					(703 701 702					=4	"FRUITS"	)  ////	
					(801/806 						=5	"MEAT"	)  ////					
					(807							=6	"EGGS"	)  ////
					(808/810 						=7  "FISH") ///
					(401  501/504					=8	"LEGUMES, NUTS AND SEEDS") ///
					(901/903						=9	"MILK AND MILK PRODUCTS")  ////
					(1001 1002   					=10	"OILS AND FATS"	)  ////
					(301/303 704 1104 				=11	"SWEETS"	)  //// 
					(1003 1004 1101/1103 1105/1108 =14 "SPICES, CONDIMENTS, BEVERAGES"	)  ////
					,generate(Diet_ID)		
gen adiet_yes=(hh_j01==1)
ta Diet_ID   
** Now, collapse to food group level; household consumes a food group if it consumes at least one item
collapse (max) adiet_yes, by(y4_hhid   Diet_ID) 
label define YesNo 1 "Yes" 0 "No"
label val adiet_yes YesNo
* Now, estimate the number of food groups eaten by each individual
collapse (sum) adiet_yes, by(y4_hhid )
ren adiet_yes number_foodgroup 
sum number_foodgroup 
local cut_off1=6
local cut_off2=round(r(mean))
gen household_diet_cut_off1=(number_foodgroup>=`cut_off1')
gen household_diet_cut_off2=(number_foodgroup>=`cut_off2')
lab var household_diet_cut_off1 "1= houseold consumed at least `cut_off1' of the 12 food groups last week" 
lab var household_diet_cut_off2 "1= houseold consumed at least `cut_off2' of the 12 food groups last week" 
label var number_foodgroup "Number of food groups individual consumed last week HDDS"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_household_diet.dta", replace
 
 
********************************************************************************
*WOMEN'S CONTROL OVER INCOME
********************************************************************************
*Code as 1 if a woman is listed as one of the decision-makers for at least 1 income-related area; 
*can report on % of women who make decisions, taking total number of women HH members as denominator
*Inmost cases, TZA LSMS 4 lsit the first TWO decision makers.
*Indicator may be biased downward if some women would participate in decisions about the use of income
*but are not listed among the first two
/*
Areas of decision making to be considered
Decision-making areas
*	Control over crop production income
*	Control over livestock production income
*	Control over fish production income
*	Control over farm (all) production income
*	Control over wage income
*	Control over business income
*	Control over nonfarm (all) income
*	Control over (all) income
*/
* First append all files with information on who control various types of income
use "${Tanzania_NPS_W4_raw_data}/ag_sec_4a", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_4b"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_5a"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_5b"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_6a"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_6b"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_7a"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_7b"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_10"
append using "${Tanzania_NPS_W4_raw_data}/lf_sec_02.dta"
append using "${Tanzania_NPS_W4_raw_data}/lf_sec_06.dta"
append using "${Tanzania_NPS_W4_raw_data}/lf_sec_08.dta"
append using "${Tanzania_NPS_W4_raw_data}/hh_sec_n.dta"
append using "${Tanzania_NPS_W4_raw_data}/hh_sec_q2.dta"
append using "${Tanzania_NPS_W4_raw_data}/hh_sec_o1.dta"
gen type_decision="" 
gen controller_income1=.
gen controller_income2=.
* control of harvest from annual crops
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
* control_annualsales
replace type_decision="control_annualsales" if  !inlist( ag5a_10_1, .,0,99) |  !inlist( ag5a_10_2, .,0,99) 
replace controller_income1=ag5a_10_1 if !inlist( ag5a_10_1, .,0,99)  
replace controller_income2=ag5a_10_2 if !inlist( ag5a_10_2, .,0,99)
replace type_decision="control_annualsales" if  !inlist( ag5b_10_1, .,0,99) |  !inlist( ag5b_10_2, .,0,99) 
replace controller_income1=ag5b_10_1 if !inlist( ag5b_10_1, .,0,99)  
replace controller_income2=ag5b_10_2 if !inlist( ag5b_10_2, .,0,99)
* append who controle earning from sale to customer 2
preserve
replace type_decision="control_annualsales" if  !inlist( ag5a_17_1, .,0,99) |  !inlist( ag5a_17_2, .,0,99) 
replace controller_income1=ag5a_17_1 if !inlist( ag5a_17_1, .,0,99)  
replace controller_income2=ag5a_17_2 if !inlist( ag5a_17_2, .,0,99)
replace type_decision="control_annualsales" if  !inlist( ag5b_17_1, .,0,99) |  !inlist( ag5b_17_2, .,0,99) 
replace controller_income1=ag5b_17_1 if !inlist( ag5b_17_1, .,0,99)  
replace controller_income2=ag5b_17_2 if !inlist( ag5b_17_2, .,0,99)
keep if !inlist( ag5a_17_1, .,0,99) |  !inlist( ag5a_17_2, .,0,99)  | !inlist( ag5b_17_1, .,0,99) |  !inlist( ag5b_17_2, .,0,99) 
keep y4_hhid type_decision controller_income1 controller_income2
tempfile saletocustomer2
save `saletocustomer2'
restore
append using `saletocustomer2'  
* control_permsales
replace type_decision="control_permsales" if  !inlist( ag7a_06_1, .,0,99) |  !inlist( ag7a_06_2, .,0,99) 
replace controller_income1=ag7a_06_1 if !inlist( ag7a_06_1, .,0,99)  
replace controller_income2=ag7a_06_2 if !inlist( ag7a_06_2, .,0,99)
replace type_decision="control_permsales" if  !inlist( ag7b_06_1, .,0,99) |  !inlist( ag7b_06_2, .,0,99) 
replace controller_income1=ag7b_06_1 if !inlist( ag7b_06_1, .,0,99)  
replace controller_income2=ag7b_06_2 if !inlist( ag7b_06_2, .,0,99)
* control_processedsales
replace type_decision="control_processedsales" if  !inlist( ag10_10_1, .,0,99) |  !inlist( ag10_10_2, .,0,99) 
replace controller_income1=ag10_10_1 if !inlist( ag10_10_1, .,0,99)  
replace controller_income2=ag10_10_2 if !inlist( ag10_10_2, .,0,99)
* livestock_sales (live)
replace type_decision="control_livestocksales" if  !inlist( lf02_27_1, .,0,99) |  !inlist( lf02_27_2, .,0,99) 
replace controller_income1=lf02_27_1 if !inlist( lf02_27_1, .,0,99)  
replace controller_income2=lf02_27_2 if !inlist( lf02_27_2, .,0,99)
* append who controle earning from livestock_sales (slaughtered)
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
* Fish production income 
*No information available

* Business income 
* Tanzania LSMS 4 did not ask directly about of who control Business Income
* We are making the assumption that whoever owns the business might have some sort of control over the income generated by the business.
* We don't think that the business manager have control of the business income. If she does, she is probaly listed as owner
* control_businessincome
replace type_decision="control_businessincome" if  !inlist( hh_n05_1, .,0,99) |  !inlist( hh_n05_2, .,0,99) 
replace controller_income1=hh_n05_1 if !inlist( hh_n05_1, .,0,99)  
replace controller_income2=hh_n05_2 if !inlist( hh_n05_2, .,0,99)

** --- Wage income --- *
* There is no question in Tanzania LSMS on who controls wage earnings
* and we can't assume that the wage earner always controls the wage income

* control_remittance
replace type_decision="control_remittance" if  !inlist( hh_q25_1, .,0,99) |  !inlist( hh_q25_2, .,0,99) 
replace controller_income1=hh_q25_1 if !inlist( hh_q25_1, .,0,99)  
replace controller_income2=hh_q25_2 if !inlist( hh_q25_2, .,0,99)
* append who controls in-kind remittances
preserve
replace type_decision="control_remittance" if  !inlist( hh_q27_1, .,0,99) |  !inlist( hh_q27_2, .,0,99) 
replace controller_income1=hh_q27_1 if !inlist( hh_q27_1, .,0,99)  
replace controller_income2=hh_q27_2 if !inlist( hh_q27_2, .,0,99)
keep if  !inlist( hh_q27_1, .,0,99) |  !inlist( hh_q27_2, .,0,99) 
keep y4_hhid type_decision controller_income1 controller_income2
tempfile control_remittance2
save `control_remittance2'
restore
append using `control_remittance2'
* control_assistance income
replace type_decision="control_assistance" if  !inlist( hh_o07_1, .,0,99) |  !inlist( hh_o07_2, .,0,99) 
replace controller_income1=hh_o07_1 if !inlist( hh_o07_1, .,0,99)  
replace controller_income2=hh_o07_2 if !inlist( hh_o07_2, .,0,99)
keep y4_hhid type_decision controller_income1 controller_income2
preserve
keep y4_hhid type_decision controller_income2
drop if controller_income2==.
ren controller_income2 controller_income
tempfile controller_income2
save `controller_income2'
restore
keep y4_hhid type_decision controller_income1
drop if controller_income1==.
ren controller_income1 controller_income
append using `controller_income2'
* create group
gen control_cropincome=1 if  type_decision=="control_annualharvest" ///
							| type_decision=="control_permharvest" ///
							| type_decision=="control_annualsales" ///
							| type_decision=="control_permsales" ///
							| type_decision=="control_processedsales"
recode 	control_cropincome (.=0)								
gen control_livestockincome=1 if  type_decision=="control_livestocksales" ///
							| type_decision=="control_milksales" ///
							| type_decision=="control_otherlivestock_sales"				
recode 	control_livestockincome (.=0)

gen control_farmincome=1 if  control_cropincome==1 | control_livestockincome==1							
recode 	control_farmincome (.=0)							
gen control_businessincome=1 if  type_decision=="control_businessincome" 
recode 	control_businessincome (.=0)																					
gen control_nonfarmincome=1 if  type_decision=="control_remittance" ///
							  | type_decision=="control_assistance" ///
							  | control_businessincome== 1 
recode 	control_nonfarmincome (.=0)																		
collapse (max) control_* , by(y4_hhid controller_income )  //any decision
gen control_all_income=1 if  control_farmincome== 1 | control_nonfarmincome==1
recode 	control_all_income (.=0)															
ren controller_income indidy4
*	Now merge with member characteristics
merge 1:1 y4_hhid indidy4  using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_person_ids.dta", nogen 
recode control_* (.=0)
lab var control_cropincome "1=invidual has control over crop income"
lab var control_livestockincome "1=invidual has control over livestock income"
lab var control_farmincome "1=invidual has control over farm (crop or livestock) income"
lab var control_businessincome "1=invidual has control over business income"
lab var control_nonfarmincome "1=invidual has control over non-farm (business or remittances) income"
lab var control_all_income "1=invidual has control over at least one type of income"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_control_income.dta", replace

********************************************************************************
*WOMEN'S PARTICIPATION IN AGRICULTURAL DECISION MAKING
********************************************************************************
*	Code as 1 if a woman is listed as one of the decision-makers for at least 2 plots, crops, or livestock activities; 
*	can report on % of women who make decisions, taking total number of women HH members as denominator
*	In most cases, TZA LSMS 4 lists the first TWO decision makers.
*	Indicator may be biased downward if some women would participate in decisions but are not listed among the first two
* first append all files related to agricultural activities with income in who participate in the decision making
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_4a"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_4b"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_5a"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_5b"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_6a"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_6b"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_7a"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_7b"
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_10"
append using "${Tanzania_NPS_W4_raw_data}/lf_sec_02.dta"
append using "${Tanzania_NPS_W4_raw_data}/lf_sec_05.dta"
append using "${Tanzania_NPS_W4_raw_data}/lf_sec_06.dta"
append using "${Tanzania_NPS_W4_raw_data}/lf_sec_08.dta"
gen type_decision="" 
gen decision_maker1=.
gen decision_maker2=.
gen decision_maker3=.
* planting_input
replace type_decision="planting_input" if  !inlist( ag3a_08_1, .,0,99) |  !inlist( ag3a_08_2, .,0,99) |  !inlist( ag3a_08_3, .,0,99) 
replace decision_maker1=ag3a_08_1 if !inlist( ag3a_08_1, .,0,99)  
replace decision_maker2=ag3a_08_2 if !inlist( ag3a_08_2, .,0,99)
replace decision_maker3=ag3a_08_2 if !inlist( ag3a_08_3, .,0,99)
replace type_decision="planting_input" if  !inlist( ag3b_08_1, .,0,99) |  !inlist( ag3b_08_2, .,0,99) |  !inlist( ag3b_08_3, .,0,99) 
replace decision_maker2=ag3b_08_1 if !inlist( ag3b_08_1, .,0,99)  
replace decision_maker2=ag3b_08_2 if !inlist( ag3b_08_2, .,0,99)
replace decision_maker3=ag3b_08_3 if !inlist( ag3b_08_3, .,0,99)
* append who make decision about input use
preserve
replace type_decision="planting_input" if  !inlist( ag3a_09_1, .,0,99) |  !inlist( ag3a_09_2, .,0,99) |  !inlist( ag3a_09_3, .,0,99) 
replace decision_maker1=ag3a_09_1 if !inlist( ag3a_09_1, .,0,99)  
replace decision_maker2=ag3a_09_2 if !inlist( ag3a_09_2, .,0,99)
replace decision_maker3=ag3a_09_2 if !inlist( ag3a_09_3, .,0,99)
replace type_decision="planting_input" if  !inlist( ag3b_09_1, .,0,99) |  !inlist( ag3b_09_2, .,0,99) |  !inlist( ag3b_09_3, .,0,99) 
replace decision_maker2=ag3b_09_1 if !inlist( ag3b_09_1, .,0,99)  
replace decision_maker2=ag3b_09_2 if !inlist( ag3b_09_2, .,0,99)
replace decision_maker3=ag3b_09_3 if !inlist( ag3b_09_3, .,0,99)                        
keep if !inlist( ag3a_09_1, .,0,99) |  !inlist( ag3a_09_2, .,0,99) |  !inlist( ag3a_09_3, .,0,99) |  !inlist( ag3b_09_1, .,0,99) |  !inlist( ag3b_09_2, .,0,99) |  !inlist( ag3b_09_3, .,0,99) 
keep y4_hhid type_decision decision_maker*
tempfile planting_input2
save `planting_input2'
restore
* harvest
replace type_decision="harvest" if  !inlist( ag4a_30_1, .,0,99) |  !inlist( ag4a_30_2, .,0,99)  
replace decision_maker1=ag4a_30_1 if !inlist( ag4a_30_1, .,0,99)  
replace decision_maker2=ag4a_30_2 if !inlist( ag4a_30_2, .,0,99)
replace type_decision="harvest" if  !inlist( ag4b_30_1, .,0,99) |  !inlist( ag4b_30_2, .,0,99)  
replace decision_maker1=ag4b_30_1 if !inlist( ag4b_30_1, .,0,99)  
replace decision_maker2=ag4b_30_2 if !inlist( ag4b_30_2, .,0,99)
* sales_annualcrop
replace type_decision="sales_annualcrop" if  !inlist( ag5a_09_1, .,0,99) |  !inlist( ag5a_09_2, .,0,99) 
replace decision_maker1=ag5a_09_1 if !inlist( ag5a_09_1, .,0,99)  
replace decision_maker2=ag5a_09_2 if !inlist( ag5a_09_2, .,0,99)
replace type_decision="sales_annualcrop" if  !inlist( ag5b_09_1, .,0,99) |  !inlist( ag5b_09_2, .,0,99) 
replace decision_maker1=ag5b_09_1 if !inlist( ag5b_09_1, .,0,99)  
replace decision_maker2=ag5b_09_2 if !inlist( ag5b_09_2, .,0,99)
* append who make negotiate sale to custumer 2
preserve
replace type_decision="sales_annualcrop" if  !inlist( ag5a_16_1, .,0,99) |  !inlist( ag5a_16_2, .,0,99) 
replace decision_maker1=ag5a_16_1 if !inlist( ag5a_16_1, .,0,99)  
replace decision_maker2=ag5a_16_2 if !inlist( ag5a_16_2, .,0,99)
replace type_decision="sales_annualcrop" if  !inlist( ag5b_16_1, .,0,99) |  !inlist( ag5b_16_2, .,0,99) 
replace decision_maker1=ag5b_16_1 if !inlist( ag5b_16_1, .,0,99)  
replace decision_maker2=ag5b_16_2 if !inlist( ag5b_16_2, .,0,99)
keep if !inlist( ag5a_16_1, .,0,99) |  !inlist( ag5a_16_2, .,0,99) | !inlist( ag5b_16_1, .,0,99) |  !inlist( ag5b_16_2, .,0,99)
keep y4_hhid type_decision decision_maker*
tempfile sales_annualcrop2
save `sales_annualcrop2'
restore
append using `sales_annualcrop2'  
* sales_permcrop
replace type_decision="sales_permcrop" if  !inlist( ag7a_05_1, .,0,99) |  !inlist( ag7a_05_2, .,0,99)  
replace decision_maker1=ag7a_05_1 if !inlist( ag7a_05_1, .,0,99)  
replace decision_maker2=ag7a_05_2 if !inlist( ag7a_05_2, .,0,99)
replace type_decision="sales_permcrop" if  !inlist( ag7b_05_1, .,0,99) |  !inlist( ag7b_05_2, .,0,99)  
replace decision_maker1=ag7b_05_1 if !inlist( ag7b_05_1, .,0,99)  
replace decision_maker2=ag7b_05_2 if !inlist( ag7b_05_2, .,0,99)
* sales_processcrop
replace type_decision="sales_processcrop" if  !inlist( ag10_09_1, .,0,99) |  !inlist( ag10_09_2, .,0,99)  
replace decision_maker1=ag10_09_1 if !inlist( ag10_09_1, .,0,99)  
replace decision_maker2=ag10_09_2 if !inlist( ag10_09_2, .,0,99)
* keep/manage livesock
replace type_decision="livestockowners" if  !inlist( lf05_01_1, .,0,99) |  !inlist( lf05_01_2, .,0,99)  
replace decision_maker1=lf05_01_1 if !inlist( lf05_01_1, .,0,99)  
replace decision_maker2=lf05_01_2 if !inlist( lf05_01_2, .,0,99)
keep y4_hhid type_decision decision_maker1 decision_maker2 decision_maker3
preserve
keep y4_hhid type_decision decision_maker2
drop if decision_maker2==.
ren decision_maker2 decision_maker
tempfile decision_maker2
save `decision_maker2'
restore
preserve
keep y4_hhid type_decision decision_maker3
drop if decision_maker3==.
ren decision_maker3 decision_maker
tempfile decision_maker3
save `decision_maker3'
restore
keep y4_hhid type_decision decision_maker1
drop if decision_maker1==.
ren decision_maker1 decision_maker
append using `decision_maker2'
append using `decision_maker3'
* number of time appears as decision maker
bysort y4_hhid decision_maker : egen nb_decision_participation=count(decision_maker)
drop if nb_decision_participation==1
gen make_decision_crop=1 if  type_decision=="planting_input" ///
							| type_decision=="harvest" ///
							| type_decision=="sales_annualcrop" ///
							| type_decision=="sales_permcrop" ///
							| type_decision=="sales_processcrop"
recode 	make_decision_crop (.=0)
gen make_decision_livestock=1 if  type_decision=="livestockowners"   
recode 	make_decision_livestock (.=0)
gen make_decision_ag=1 if make_decision_crop==1 | make_decision_livestock==1
recode 	make_decision_ag (.=0)
collapse (max) make_decision_* , by(y4_hhid decision_maker )  //any decision
ren decision_maker indidy4 
* Now merge with member characteristics
merge 1:1 y4_hhid indidy4  using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_person_ids.dta", nogen 
* 1 member ID in decision files not in member list
recode make_decision_* (.=0)
lab var make_decision_crop "1=invidual makes decision about crop production activities"
lab var make_decision_livestock "1=invidual makes decision about livestock production activities"
lab var make_decision_ag "1=invidual makes decision about agricultural (crop or livestock) production activities"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_make_ag_decision.dta", replace

 
********************************************************************************
*WOMEN'S OWNERSHIP OF ASSETS
********************************************************************************
* Code as 1 if a woman is sole or joint owner of any specified productive asset; 
* can report on % of women who own, taking total number of women HH members as denominator
* In most cases, TZA LSMS 4 as the first TWO owners.
* Indicator may be biased downward if some women would have been not listed among the two the first 2 asset-owners can also claim ownership of some assets
*First, append all files with information on asset ownership
use "${Tanzania_NPS_W4_raw_data}/ag_sec_3a.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_3b.dta" 
append using "${Tanzania_NPS_W4_raw_data}/lf_sec_05.dta"
gen type_asset=""
gen asset_owner1=.
gen asset_owner2=.
* Ownership of land.
replace type_asset="landowners" if  !inlist( ag3a_29_1, .,0,99) |  !inlist( ag3a_29_2, .,0,99) 
replace asset_owner1=ag3a_29_1 if !inlist( ag3a_29_1, .,0,99)  
replace asset_owner2=ag3a_29_1 if !inlist( ag3a_29_2, .,0,99)
replace type_asset="landowners" if  !inlist( ag3b_29_1, .,0,99) |  !inlist( ag3b_29_2, .,0,99) 
replace asset_owner1=ag3b_29_1 if !inlist( ag3b_29_1, .,0,99)  
replace asset_owner2=ag3b_29_1 if !inlist( ag3b_29_2, .,0,99)
* append who hss right to sell or use
preserve
replace type_asset="landowners" if  !inlist( ag3a_31_1, .,0,99) |  !inlist( ag3a_31_2, .,0,99) 
replace asset_owner1=ag3a_31_1 if !inlist( ag3a_31_1, .,0,99)  
replace asset_owner2=ag3a_31_2 if !inlist( ag3a_31_2, .,0,99)
replace type_asset="landowners" if  !inlist( ag3b_31_1, .,0,99) |  !inlist( ag3b_31_2, .,0,99) 
replace asset_owner1=ag3b_31_1 if !inlist( ag3b_31_1, .,0,99)  
replace asset_owner2=ag3b_31_2 if !inlist( ag3b_31_2, .,0,99)
keep if !inlist( ag3a_31_1, .,0,99) |  !inlist( ag3a_31_2, .,0,99)   | !inlist( ag3b_31_1, .,0,99) |  !inlist( ag3b_31_2, .,0,99) 
keep y4_hhid type_asset asset_owner*
tempfile land2
save `land2'
restore
append using `land2'  
*non-poultry livestock (keeps/manages)
replace type_asset="livestockowners" if  !inlist( lf05_01_1, .,0,99) |  !inlist( lf05_01_2, .,0,99)  
replace asset_owner1=lf05_01_1 if !inlist( lf05_01_1, .,0,99)  
replace asset_owner2=lf05_01_2 if !inlist( lf05_01_2, .,0,99)
* non-farm equipment,  large durables/appliances, mobile phone
* SECTION M: HOUSEHOLD ASSETS - does not report who in the household own them) 
* No ownership of non-farm equipment,  large durables/appliances, mobile phone
keep y4_hhid type_asset asset_owner1 asset_owner2  
preserve
keep y4_hhid type_asset asset_owner2
drop if asset_owner2==.
ren asset_owner2 asset_owner
tempfile asset_owner2
save `asset_owner2'
restore
keep y4_hhid type_asset asset_owner1
drop if asset_owner1==.
ren asset_owner1 asset_owner
append using `asset_owner2'
gen own_asset=1 
collapse (max) own_asset, by(y4_hhid asset_owner)
ren asset_owner indidy4
* Now merge with member characteristics
merge 1:1 y4_hhid indidy4  using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_person_ids.dta", nogen 
* 3 member ID in assed files not is member list
recode own_asset (.=0)
lab var own_asset "1=invidual owns an assets (land or livestock)"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_ownasset.dta", replace
 
//ALT 02.02.23: Now shorter!

********************************************************************************
*CROP YIELDS - ALT 07.21.21
********************************************************************************
//ALT 07.20.21: Preprocessing taken care of in the all plots section. At this point, I have what I need for AgQuery and so this is purely for legacy file compatibility
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_all_plots.dta", clear
collapse (sum) number_trees_planted, by(y4_hhid crop_code short)
tempfile trees
save `trees'
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_all_plots.dta", clear
ren kg_harvest harvest_
ren ha_harvest area_harv_
ren ha_planted area_plan_
gen inter = "inter" if purestand==0
replace inter = "pure" if purestand==1
gen dm_gender2 = "male"
replace dm_gender2 = "female" if dm_gender==2
replace dm_gender2 = "mixed" if dm_gender==3
keep crop_code dm_gender2 inter harvest_ area_harv_ area_plan_ y4_hhid plot_id short
reshape wide harvest_ area_harv_ area_plan_, i(y4_hhid plot_id dm_gender2 crop_code short) j(inter) string
ren harvest* harvest*_
ren area_harv* area_harv*_
ren area_plan* area_plan*_
reshape wide harvest*_ area_harv*_ area_plan*_, i(y4_hhid plot_id crop_code short) j(dm_gender2) string
collapse (sum) harvest* area_harv* area_plan*, by(y4_hhid crop_code short)
egen area_harv = rowtotal(area_harv*)
egen area_plan = rowtotal(area_plan*)
egen harvest = rowtotal(harvest*)

foreach i in male female mixed {
	egen harvest_`i' = rowtotal(harvest_*_`i')
	egen area_harv_`i' = rowtotal(area_harv_*_`i')
	egen area_plan_`i' = rowtotal(area_plan_*_`i')
}

foreach j in inter pure {
	egen harvest_`j' = rowtotal(harvest_`j'_*)
	egen area_harv_`j' = rowtotal(area_harv_`j'_*)
	egen area_plan_`j' = rowtotal(area_plan_`j'_*)
}
merge 1:1 y4_hhid crop_code short using `trees', nogen
merge m:1 y4_hhid using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta", nogen keep(1 3)
preserve
	keep if short==0
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_area_plan_LRS.dta", replace
	keep if inlist(crop_code, $comma_topcrop_area)
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_harvest_area_yield_LRS.dta", replace
restore
preserve
	keep if short==0
	collapse (sum) all_area_harvested=area_harv all_area_planted=area_plan, by(y4_hhid)
	replace all_area_harvested=all_area_planted if all_area_harvested>all_area_planted & all_area_harvested!=.
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_area_planted_harvested_allcrops_LRS.dta", replace
restore


preserve
	keep if short==1
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_area_plan_SRS.dta", replace
	keep if inlist(crop_code, $comma_topcrop_area)
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_harvest_area_yield_SRS.dta", replace
restore
preserve
	keep if short==1
	collapse (sum) all_area_harvested=area_harv all_area_planted=area_plan, by(y4_hhid)
	replace all_area_harvested=all_area_planted if all_area_harvested>all_area_planted & all_area_harvested!=.
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_area_planted_harvested_allcrops_SRS.dta", replace
restore
	collapse (sum) all_area_harvested=area_harv all_area_planted=area_plan, by(y4_hhid)
	replace all_area_harvested=all_area_planted if all_area_harvested>all_area_planted & all_area_harvested!=.
	save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_area_planted_harvested_allcrops.dta", replace
*Yield at the household level
//ALT 07.21.21: Code continues here as written in W4
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_harvest_area_yield_LRS.dta", clear
preserve
gen season="LRS"
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_harvest_area_yield_SRS.dta"
recode area_plan area_harv (.=0)
collapse (sum)area_plan area_harv, by(y4_hhid crop_code)
ren area_plan total_planted_area
ren area_harv total_harv_area 
tempfile area_allseasons
save `area_allseasons'
restore
merge 1:1 y4_hhid crop_code using `area_allseasons', nogen
*Adding value of crop production
merge 1:1 y4_hhid crop_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_values_production.dta", nogen keep(1 3)
ren value_crop_production value_harv
ren value_crop_sales value_sold
local ncrop : word count $topcropname_area
foreach v of varlist  harvest*  area_harv* area_plan* total_planted_area total_harv_area kgs_harvest* kgs_sold* value_harv value_sold {
	separate `v', by(crop_code)
	forvalues i=1(1)`ncrop' {
		local p : word `i' of  $topcrop_area
		local np : word `i' of  $topcropname_area
	capture confirm var `v'`p' //ALT 07.21.21: Crops not grown in the topcrop list do not appear here.
	if _rc!=0 gen `v'`p'=.
		local `v'`p' = subinstr("`v'`p'","`p'","_`np'",1)	
		ren `v'`p'  ``v'`p''
	}	
}
gen number_trees_planted_cassava=number_trees_planted if crop_code==21
gen number_trees_planted_banana=number_trees_planted if crop_code==71
recode number_trees_planted_cassava number_trees_planted_banana (.=0) 	
collapse (firstnm) harvest* area_harv*  area_plan* total_planted_area* total_harv_area* kgs_harvest*  kgs_sold*  value_harv* value_sold* (sum) number_trees_planted_*, by(y4_hhid)
recode harvest*   area_harv* area_plan* kgs_harvest* total_planted_area* total_harv_area* kgs_sold*  value_harv* value_sold* (0=.)
lab var kgs_harvest "Kgs harvested (household) (all seasons)"
lab var kgs_sold "Kgs sold (household) (all seasons)"
foreach p of global topcropname_area {
	lab var value_harv_`p' "Value harvested of `p' (household)" 
	lab var value_sold_`p' "Value sold of `p' (household)" 
	lab var kgs_harvest_`p'  "Harvest of `p' (kgs) (household) (all seasons)" 
	lab var kgs_sold_`p'  "Quantity sold of `p' (kgs) (household) (all seasons)" 
	lab var total_harv_area_`p'  "Total area harvested of `p' (ha) (household) (all seasons)" 
	lab var total_planted_area_`p'  "Total area planted of `p' (ha) (household) (all seasons)" 
	lab var harvest_`p' "Harvest of `p' (kgs) (household) - LRS" 
	lab var harvest_male_`p' "Harvest of `p' (kgs) (male-managed plots) - LRS" 
	lab var harvest_female_`p' "Harvest of `p' (kgs) (female-managed plots) - LRS" 
	lab var harvest_mixed_`p' "Harvest of `p' (kgs) (mixed-managed plots) - LRS"
	lab var harvest_pure_`p' "Harvest of `p' (kgs) - purestand (household) - LRS"
	lab var harvest_pure_male_`p'  "Harvest of `p' (kgs) - purestand (male-managed plots) - LRS"
	lab var harvest_pure_female_`p'  "Harvest of `p' (kgs) - purestand (female-managed plots) - LRS"
	lab var harvest_pure_mixed_`p'  "Harvest of `p' (kgs) - purestand (mixed-managed plots) - LRS"
	lab var harvest_inter_`p' "Harvest of `p' (kgs) - intercrop (household) - LRS"
	lab var harvest_inter_male_`p' "Harvest of `p' (kgs) - intercrop (male-managed plots) - LRS" 
	lab var harvest_inter_female_`p' "Harvest of `p' (kgs) - intercrop (female-managed plots) - LRS"
	lab var harvest_inter_mixed_`p' "Harvest  of `p' (kgs) - intercrop (mixed-managed plots) - LRS"
	lab var area_harv_`p' "Area harvested of `p' (ha) (household) - LRS" 
	lab var area_harv_male_`p' "Area harvested of `p' (ha) (male-managed plots) - LRS" 
	lab var area_harv_female_`p' "Area harvested of `p' (ha) (female-managed plots) - LRS" 
	lab var area_harv_mixed_`p' "Area harvested of `p' (ha) (mixed-managed plots) - LRS"
	lab var area_harv_pure_`p' "Area harvested of `p' (ha) - purestand (household) - LRS"
	lab var area_harv_pure_male_`p'  "Area harvested of `p' (ha) - purestand (male-managed plots) - LRS"
	lab var area_harv_pure_female_`p'  "Area harvested of `p' (ha) - purestand (female-managed plots) - LRS"
	lab var area_harv_pure_mixed_`p'  "Area harvested of `p' (ha) - purestand (mixed-managed plots) - LRS"
	lab var area_harv_inter_`p' "Area harvested of `p' (ha) - intercrop (household) - LRS"
	lab var area_harv_inter_male_`p' "Area harvested of `p' (ha) - intercrop (male-managed plots) - LRS" 
	lab var area_harv_inter_female_`p' "Area harvested of `p' (ha) - intercrop (female-managed plots) - LRS"
	lab var area_harv_inter_mixed_`p' "Area harvested  of `p' (ha) - intercrop (mixed-managed plots - LRS)"
	lab var area_plan_`p' "Area planted of `p' (ha) (household) - LRS" 
	lab var area_plan_male_`p' "Area planted of `p' (ha) (male-managed plots) - LRS" 
	lab var area_plan_female_`p' "Area planted of `p' (ha) (female-managed plots) - LRS" 
	lab var area_plan_mixed_`p' "Area planted of `p' (ha) (mixed-managed plots) - LRS"
	lab var area_plan_pure_`p' "Area planted of `p' (ha) - purestand (household) - LRS"
	lab var area_plan_pure_male_`p'  "Area planted of `p' (ha) - purestand (male-managed plots) - LRS"
	lab var area_plan_pure_female_`p'  "Area planted of `p' (ha) - purestand (female-managed plots) - LRS"
	lab var area_plan_pure_mixed_`p'  "Area planted of `p' (ha) - purestand (mixed-managed plots) - LRS"
	lab var area_plan_inter_`p' "Area planted of `p' (ha) - intercrop (household) - LRS"
	lab var area_plan_inter_male_`p' "Area planted of `p' (ha) - intercrop (male-managed plots) - LRS" 
	lab var area_plan_inter_female_`p' "Area planted of `p' (ha) - intercrop (female-managed plots) - LRS"
	lab var area_plan_inter_mixed_`p' "Area planted  of `p' (ha) - intercrop (mixed-managed plots) - LRS"
}
*Household grew crop
foreach p of global topcropname_area {
	gen grew_`p'=(total_harv_area_`p'!=. & total_harv_area_`p'!=0 ) | (total_planted_area_`p'!=. & total_planted_area_`p'!=0)
	lab var grew_`p' "1=Household grew `p'" 
	gen harvested_`p'= (total_harv_area_`p'!=. & total_harv_area_`p'!=.0 )
	lab var harvested_`p' "1= Household harvested `p'"
}
foreach p in cassav banana { //tree/permanent crops have no area in this instrument 
	replace grew_`p' = 1 if number_trees_planted_`p'!=0 & number_trees_planted_`p'!=.
}

*Household grew crop in the LRS
foreach p of global topcropname_area {
	gen grew_`p'_lrs=(area_harv_`p'!=. & area_harv_`p'!=0 ) | (area_plan_`p'!=. & area_plan_`p'!=0)
	lab var grew_`p'_lrs "1=Household grew `p' in the long rainy season" 
	gen harvested_`p'_lrs= (area_harv_`p'!=. & area_harv_`p'!=.0 )
	lab var harvested_`p'_lrs "1= Household harvested `p' in the long rainy season"
}

foreach p of global topcropname_area {
	recode kgs_harvest_`p' (.=0) if grew_`p'==1 
	recode value_sold_`p' (.=0) if grew_`p'==1 
	recode value_harv_`p' (.=0) if grew_`p'==1 
}

//Drop everything that isn't crop-related - changing to make this location-independent.
drop *_inter *_male *_female *mixed *_pure area_harv area_plan harvest kgs_harvest total_harv_area total_planted_area 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_yield_hh_crop_level.dta", replace

/*
********************************************************************************
*CROP YIELDS
********************************************************************************
* crops
use "${Tanzania_NPS_W4_raw_data}/ag_sec_4a.dta", clear
* Percent of area
gen pure_stand = ag4a_04==2 
gen any_pure = pure_stand==1
gen any_mixed = pure_stand==0
gen percent_field = 0.25 if ag4a_02==1
replace percent_field = 0.50 if ag4a_02==2
replace percent_field = 0.75 if ag4a_02==3
replace percent_field = 1 if ag4a_01==1
duplicates report y4_hhid plotnum zaocode 	
duplicates drop y4_hhid plotnum zaocode, force		
drop if plotnum==""
ren plotnum plot_id 
*Merging in variables from tzn4_field
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_areas.dta" , nogen keep(1 3)  
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_decision_makers" , nogen keep(1 3)
gen field_area =  area_meas_hectares
replace field_area= area_est_hectares if field_area==.
gen intercropped_yn = (ag4a_04==1) //See EPAR Technical Report #354 "Crop Yield Measurement on Multi-Cropped Plots" 
replace intercropped_yn = . if ag4a_04==. //replace intercropped variable with missing if we do not know that it was or was not intercropped 
gen mono_field = percent_field if intercropped_yn==0 //not intercropped 
gen int_field = percent_field if intercropped_yn==1 
*Generating total percent of purestand and monocropped on a field
bys y4_hhid plot_id: egen total_percent_int_sum = total(int_field) 
bys y4_hhid plot_id: egen total_percent_mono = total(mono_field) 
//Dealing with crops which have monocropping larger than plot size or monocropping that fills plot size and still has intercropping to add
gen oversize_plot = (total_percent_mono >1)
replace oversize_plot = 1 if total_percent_mono >=1 & total_percent_int_sum >0 
bys y4_hhid plot_id: egen total_percent_field = total(percent_field)			            
replace percent_field = percent_field/total_percent_field if total_percent_field>1 & oversize_plot ==1
replace total_percent_mono = 1 if total_percent_mono>1 
gen total_percent_inter = 1-total_percent_mono 
bys y4_hhid plot_id: egen inter_crop_number = total(intercropped_yn) 
gen percent_inter = (int_field/total_percent_int_sum)*total_percent_inter if total_percent_field >1 
replace percent_inter = int_field if total_percent_field<=1		
replace percent_inter = percent_field if oversize_plot ==1 & intercropped_yn==1
ren cultivated field_cultivated  
gen field_area_cultivated = field_area if field_cultivated==1
gen crop_area_planted = percent_field*field_area_cultivated  if intercropped_yn == 0 
replace crop_area_planted = percent_inter*field_area_cultivated  if intercropped_yn == 1 
gen us_total_area_planted = total_percent_field*field_area_cultivated 
gen us_inter_area_planted = total_percent_int_sum*field_area_cultivated 
keep crop_area_planted* y4_hhid plot_id zaocode dm_* any_* pure_stand dm_gender  field_area us* area_est_hectares area_meas_hectares 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_crop_area.dta", replace


*Now to harvest
use "${Tanzania_NPS_W4_raw_data}/ag_sec_4a.dta", clear
gen kg_harvest = ag4a_28
ren ag4a_22 harv_less_plant			//yes if they harvested less than they planted
ren ag4a_19 no_harv
replace kg_harvest = 0 if ag4a_20==3
replace kg_harvest =. if ag4a_20==1 | ag4a_20==2 | ag4a_20==4		
drop if kg_harvest==.							
gen area_harv_ha= ag4a_21*0.404686						
keep y4_hhid plotnum zaocode kg_harvest area_harv_ha harv_less_plant no_harv
ren plotnum plot_id 
*Merging decision maker and intercropping variables
merge m:1 y4_hhid plot_id zaocode using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_crop_area.dta", nogen /*keep(1 3)*/ // we still want to keep those that report an area planted but no harvest		
//Add production of permanent crops (cassava and banana)
preserve
use "${Tanzania_NPS_W4_raw_data}/ag_sec_6b.dta", clear
append using "${Tanzania_NPS_W4_raw_data}/ag_sec_6a.dta"		// include fruit crops 
gen kg_harvest = ag6b_09
replace kg_harvest = ag6a_09 if kg_harvest==.				
gen pure_stand = ag6b_05==2
replace pure_stand = ag6a_05==2 if pure_stand==. 				
gen any_pure = pure_stand==1
gen any_mixed = pure_stand==0
ren plotnum plot_id
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_areas.dta", nogen keep(1 3)	              
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_decision_makers" , nogen keep(1 3) 
gen field_area =  area_meas_hectares
replace field_area= area_est_hectares if field_area==.
ren ag6b_02 number_trees_planted
keep y4_hhid plot_id zaocode kg_harvest number_trees_planted pure_stand any_pure any_mixed field_area dm_gender 
tempfile  cassava
save `cassava', replace
restore 
append using `cassava'
ren crop_area_planted area_plan
//Capping Code:
gen over_harvest = area_harv_ha>field_area & area_harv_ha!=. & area_meas_hectares!=.	
gen over_harvest_scaling = field_area/area_harv_ha if over_harvest == 1
bys y4_hhid plot_id: egen mean_harvest_scaling = mean(over_harvest_scaling)
replace mean_harvest_scaling =1 if missing(mean_harvest_scaling)
replace area_harv_ha = field_area if over_harvest == 1
replace area_harv_ha = area_harv_ha*mean_harvest_scaling if over_harvest == 0
//Intercropping Scaling Code:
bys y4_hhid plot_id: egen over_harv_plot = max(over_harvest)
gen intercropped_yn = pure_stand !=1 
gen int_f_harv = area_harv_ha if intercropped_yn==1
bys y4_hhid plot_id: egen total_area_int_sum_hv = total(int_f_harv)
bys y4_hhid plot_id: egen total_area_hv = total(area_harv_ha)
replace us_total_area_planted = total_area_hv if over_harv_plot ==1
replace us_inter_area_planted = total_area_int_sum_hv if over_harv_plot ==1
drop intercropped_yn int_f_harv total_area_int_sum_hv total_area_hv
gen intercropped_yn = pure_stand !=1 
gen mono_f_harv = area_harv_ha if intercropped_yn==0
gen int_f_harv = area_harv_ha if intercropped_yn==1
bys y4_hhid plot_id: egen total_area_int_sum_hv = total(int_f_harv)
bys y4_hhid plot_id: egen total_area_mono_hv = total(mono_f_harv)
//Oversize Plots
gen oversize_plot = total_area_mono_hv > field_area & total_area_mono_hv!=. 	
replace oversize_plot = 1 if total_area_mono_hv >= field_area & total_area_int_sum_hv>0 & total_area_mono_hv!=.
gen percent_harvest = area_harv_ha/field_area
bys y4_hhid plot_id: egen total_percent_harvest = total(percent_harvest)
//using this in the construction of area_harv_ha below
bys y4_hhid plot_id: egen total_area_harv = total(area_harv_ha)	
replace area_harv_ha = (area_harv_ha/us_total_area_planted)*field_area if oversize_plot ==1 
gen total_area_int_hv = field_area - total_area_mono_hv
replace area_harv_ha = (int_f_harv/us_inter_area_planted)*total_area_int_hv if intercropped_yn==1 & oversize_plot !=1 & total_percent_harv>1 
//3,060 changes with rescaling up
//2,138 changes without rescaling up
replace area_harv_ha=. if area_harv_ha==0 //11 to missing
replace area_plan=area_harv_ha if area_plan==. & area_harv_ha!=.
*Cap area harvested at area planted (area harvested should not be greater than the area planted)
count if area_harv_ha>area_plan & area_harv_ha!=. //832 observations where area harvested is greater than area planted 
replace area_harv_ha = area_plan if area_harv_ha>area_plan & area_harv_ha!=.

*Creating area and quantity variables by decision-maker and type of planting
ren kg_harvest harvest 
ren area_harv_ha area_harv 
ren any_mixed inter
gen harvest_male = harvest if dm_gender==1
gen area_harv_male = area_harv if dm_gender==1
gen harvest_female = harvest if dm_gender==2
gen area_harv_female = area_harv if dm_gender==2
gen harvest_mixed = harvest if dm_gender==3
gen area_harv_mixed = area_harv if dm_gender==3
gen area_harv_inter= area_harv if inter==1
gen area_harv_pure= area_harv if inter==0
gen harvest_inter= harvest if inter==1
gen harvest_pure= harvest if inter==0
gen harvest_inter_male= harvest if dm_gender==1 & inter==1
gen harvest_pure_male= harvest if dm_gender==1 & inter==0
gen harvest_inter_female= harvest if dm_gender==2 & inter==1
gen harvest_pure_female= harvest if dm_gender==2 & inter==0
gen harvest_inter_mixed= harvest if dm_gender==3 & inter==1
gen harvest_pure_mixed= harvest if dm_gender==3 & inter==0
gen area_harv_inter_male= area_harv if dm_gender==1 & inter==1
gen area_harv_pure_male= area_harv if dm_gender==1 & inter==0
gen area_harv_inter_female= area_harv if dm_gender==2 & inter==1
gen area_harv_pure_female= area_harv if dm_gender==2 & inter==0
gen area_harv_inter_mixed= area_harv if dm_gender==3 & inter==1
gen area_harv_pure_mixed= area_harv if dm_gender==3 & inter==0
gen area_plan_male = area_plan if dm_gender==1
gen area_plan_female = area_plan if dm_gender==2
gen area_plan_mixed = area_plan if dm_gender==3
gen area_plan_inter= area_plan if inter==1
gen area_plan_pure= area_plan if inter==0
gen area_plan_inter_male= area_plan if dm_gender==1 & inter==1
gen area_plan_pure_male= area_plan if dm_gender==1 & inter==0
gen area_plan_inter_female= area_plan if dm_gender==2 & inter==1
gen area_plan_pure_female= area_plan if dm_gender==2 & inter==0
gen area_plan_inter_mixed= area_plan if dm_gender==3 & inter==1
gen area_plan_pure_mixed= area_plan if dm_gender==3 & inter==0
recode number_trees_planted (.=0)
collapse (sum) area_harv* harvest* area_plan* number_trees_planted , by (y4_hhid zaocode)
*merging survey weights
merge m:1 y4_hhid using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta", nogen keep(1 3)
*Saving area planted for Shannon diversity index
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_area_plan_LRS.dta", replace

*Adding here total planted and harvested area all plots, crops, and seasons.
preserve
collapse (sum) all_area_harvested=area_harv all_area_planted=area_plan, by(y4_hhid)
replace all_area_harvested=all_area_planted if all_area_harvested>all_area_planted & all_area_harvested!=.
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_area_planted_harvested_allcrops_LRS.dta", replace
restore
keep if inlist(zaocode, $comma_topcrop_area)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_harvest_area_yield_LRS.dta", replace

/////Generating yield variables for short rainy season////
* crops
use "${Tanzania_NPS_W4_raw_data}/ag_sec_4b.dta", clear
* Percent of area
gen pure_stand = ag4b_04==2
gen any_pure = pure_stand==1
gen any_mixed = pure_stand==0
gen percent_field = 0.25 if ag4b_02==1
replace percent_field = 0.50 if ag4b_02==2
replace percent_field = 0.75 if ag4b_02==3
replace percent_field = 1 if ag4b_01==1
duplicates report y4_hhid plotnum zaocode		
duplicates drop y4_hhid plotnum zaocode, force	
drop if plotnum==""
ren plotnum plot_id 
*Merging in variables from tzn4_field
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_areas.dta" , nogen keep(1 3)    
merge m:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_decision_makers" , nogen keep(1 3)
gen field_area =  area_meas_hectares
replace field_area= area_est_hectares if field_area==.
//See EPAR Technical Report #354 "Crop Yield Measurement on Multi-Cropped Plots" 
gen intercropped_yn = (ag4b_04==1) 
replace intercropped_yn = . if ag4b_04==. 
gen mono_field = percent_field if intercropped_yn==0 //not intercropped 
gen int_field = percent_field if intercropped_yn==1 
bys y4_hhid plot_id: egen total_percent_mono = total(mono_field)
bys y4_hhid plot_id: egen total_percent_int_sum = total(int_field) 
//Dealing with crops which have monocropping larger than plot size or monocropping that fills plot size and till has intercropping to add
gen oversize_plot = (total_percent_mono >1)
replace oversize_plot = 1 if total_percent_mono >=1 & total_percent_int_sum >0 
bys y4_hhid plot_id: egen total_percent_field = total(percent_field)			            
replace percent_field = percent_field/total_percent_field if total_percent_field>1 & oversize_plot ==1		//17 changes made
replace total_percent_mono = 1 if total_percent_mono>1 
gen total_percent_inter = 1-total_percent_mono
bys y4_hhid plot_id: egen inter_crop_number = total(intercropped_yn) 
gen percent_inter = (int_field/total_percent_int_sum)*total_percent_inter if total_percent_field >1 
replace percent_inter=int_field if total_percent_field<=1
replace percent_inter = percent_field if oversize_plot ==1 & intercropped_yn==1 
ren cultivated field_cultivated  
gen field_area_cultivated = field_area if field_cultivated==1
gen crop_area_planted = percent_field*field_area_cultivated  if intercropped_yn == 0
replace crop_area_planted = percent_inter*field_area_cultivated  if intercropped_yn == 1
gen us_total_area_planted = total_percent_field*field_area_cultivated 
gen us_inter_area_planted = total_percent_int_sum*field_area_cultivated 
keep crop_area_planted* y4_hhid plot_id zaocode dm_* any_* pure_stand dm_gender  field_area us* area_meas_hectares area_est_hectares 
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_crop_area_SRS.dta", replace

*Now to harvest
use "${Tanzania_NPS_W4_raw_data}/ag_sec_4b.dta", clear
gen kg_harvest = ag4b_28
ren ag4b_22 harv_less_plant			//yes if they harvested less than they planted
ren ag4b_19 no_harv
replace kg_harvest = 0 if ag4b_20==3
replace kg_harvest =. if ag4b_20==1 | ag4b_20==2 | ag4b_20==4	
drop if kg_harvest==.							
gen area_harv_ha= ag4b_21*0.404686						
keep y4_hhid plotnum zaocode kg_harvest area_harv_ha harv_less_plant no_harv
ren plotnum plot_id 
*Merging decision maker and intercropping variables
merge m:1 y4_hhid plot_id zaocode using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_crop_area_SRS.dta", nogen /*keep(1 3)*/ //we still want to keep those that report an area planted but no harvest			
//Capping Code:
gen over_harvest = area_harv_ha>field_area & area_harv_ha!=. & area_meas_hectares!=.	
gen over_harvest_scaling = field_area/area_harv_ha if over_harvest == 1
bys y4_hhid plot_id: egen mean_harvest_scaling = mean(over_harvest_scaling)
replace mean_harvest_scaling =1 if missing(mean_harvest_scaling)
replace area_harv_ha = field_area if over_harvest == 1
replace area_harv_ha = area_harv_ha*mean_harvest_scaling if over_harvest == 0 

//Intercropping Scaling Code (Method 4):
bys y4_hhid plot_id: egen over_harv_plot = max(over_harvest)
gen intercropped_yn = pure_stand !=1 
gen int_f_harv = area_harv_ha if intercropped_yn==1
bys y4_hhid plot_id: egen total_area_int_sum_hv = total(int_f_harv)
bys y4_hhid plot_id: egen total_area_hv = total(area_harv_ha)
replace us_total_area_planted = total_area_hv if over_harv_plot ==1
replace us_inter_area_planted = total_area_int_sum_hv if over_harv_plot ==1
drop intercropped_yn int_f_harv total_area_int_sum_hv total_area_hv

// Adding Method 4 to Area Harvested
gen intercropped_yn = pure_stand !=1 
gen mono_f_harv = area_harv_ha if intercropped_yn==0
gen int_f_harv = area_harv_ha if intercropped_yn==1
bys y4_hhid plot_id: egen total_area_int_sum_hv = total(int_f_harv)
bys y4_hhid plot_id: egen total_area_mono_hv = total(mono_f_harv)
//Oversize Plots
gen oversize_plot = total_area_mono_hv > field_area
replace oversize_plot = 1 if total_area_mono_hv >=1 & total_area_int_sum_hv >0 
bys y4_hhid plot_id: egen total_area_harv = total(area_harv_ha)	
replace area_harv_ha = (area_harv_ha/us_total_area_planted)*field_area if oversize_plot ==1 
gen total_area_int_hv = field_area - total_area_mono_hv
replace area_harv_ha = (int_f_harv/us_inter_area_planted)*total_area_int_hv if intercropped_yn==1 & oversize_plot !=1 
*rescaling area harvested to area planted if area harvested > area planted
ren crop_area_planted area_plan
replace area_harv_ha=. if area_harv_ha==0 //11 to missing
replace area_plan=area_harv_ha if area_plan==. & area_harv_ha!=.
*Capping area harvested at area planted
count if area_harv_ha>area_plan & area_harv_ha!=. //228 observations where area harvested is greater than area planted 
replace area_harv_ha = area_plan if area_harv_ha>area_plan & area_harv_ha!=.

*Creating area and quantity variables by decision-maker and type of planting
ren kg_harvest harvest 
ren area_harv_ha area_harv 
ren any_mixed inter
gen harvest_male = harvest if dm_gender==1
gen area_harv_male = area_harv if dm_gender==1
gen harvest_female = harvest if dm_gender==2
gen area_harv_female = area_harv if dm_gender==2
gen harvest_mixed = harvest if dm_gender==3
gen area_harv_mixed = area_harv if dm_gender==3
gen area_harv_inter= area_harv if inter==1
gen area_harv_pure= area_harv if inter==0
gen harvest_inter= harvest if inter==1
gen harvest_pure= harvest if inter==0
gen harvest_inter_male= harvest if dm_gender==1 & inter==1
gen harvest_pure_male= harvest if dm_gender==1 & inter==0
gen harvest_inter_female= harvest if dm_gender==2 & inter==1
gen harvest_pure_female= harvest if dm_gender==2 & inter==0
gen harvest_inter_mixed= harvest if dm_gender==3 & inter==1
gen harvest_pure_mixed= harvest if dm_gender==3 & inter==0
gen area_harv_inter_male= area_harv if dm_gender==1 & inter==1
gen area_harv_pure_male= area_harv if dm_gender==1 & inter==0
gen area_harv_inter_female= area_harv if dm_gender==2 & inter==1
gen area_harv_pure_female= area_harv if dm_gender==2 & inter==0
gen area_harv_inter_mixed= area_harv if dm_gender==3 & inter==1
gen area_harv_pure_mixed= area_harv if dm_gender==3 & inter==0
gen area_plan_male = area_plan if dm_gender==1
gen area_plan_female = area_plan if dm_gender==2
gen area_plan_mixed = area_plan if dm_gender==3
gen area_plan_inter= area_plan if inter==1
gen area_plan_pure= area_plan if inter==0
gen area_plan_inter_male= area_plan if dm_gender==1 & inter==1
gen area_plan_pure_male= area_plan if dm_gender==1 & inter==0
gen area_plan_inter_female= area_plan if dm_gender==2 & inter==1
gen area_plan_pure_female= area_plan if dm_gender==2 & inter==0
gen area_plan_inter_mixed= area_plan if dm_gender==3 & inter==1
gen area_plan_pure_mixed= area_plan if dm_gender==3 & inter==0
collapse (sum) area_harv* harvest* area_plan*, by (y4_hhid zaocode)
*Adding here total planted and harvested area summed accross all plots, crops, and seasons.
*Saving area planted for Shannon diversity index
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_area_plan_SRS.dta", replace


preserve
collapse (sum) all_area_harvested=area_harv all_area_planted=area_plan, by(y4_hhid)
replace all_area_harvested=all_area_planted if all_area_harvested>all_area_planted & all_area_harvested!=.
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_area_planted_harvested_allcrops_SRS.dta", replace
*Append LRS
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_area_planted_harvested_allcrops_LRS.dta"
recode all_area_harvested all_area_planted (.=0)
collapse (sum) all_area_harvested all_area_planted, by(y4_hhid)
lab var all_area_planted "Total area planted, all plots, crops, and seasons"
lab var all_area_harvested "Total area harvested, all plots, crops, and seasons"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_area_planted_harvested_allcrops.dta", replace
restore

*merging survey weights
merge m:1 y4_hhid using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta", nogen keep(1 3)
keep if inlist(zaocode, $comma_topcrop_area)
gen season="SRS"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_harvest_area_yield_SRS.dta", replace

*Yield at the household level
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_harvest_area_yield_LRS.dta", clear
preserve
gen season="LRS"
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_harvest_area_yield_SRS.dta"
recode area_plan area_harv (.=0)
collapse (sum)area_plan area_harv, by(y4_hhid zaocode)
ren area_plan total_planted_area
ren area_harv total_harv_area 
tempfile area_allseasons
save `area_allseasons'
restore
merge 1:1 y4_hhid zaocode using `area_allseasons', nogen
ren  zaocode crop_code
*Adding value of crop production
merge 1:1 y4_hhid crop_code using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_values_production.dta", nogen keep(1 3)
ren value_crop_production value_harv
ren value_crop_sales value_sold
local ncrop : word count $topcropname_area
foreach v of varlist  harvest*  area_harv* area_plan* total_planted_area total_harv_area kgs_harvest* kgs_sold* value_harv value_sold {
	separate `v', by(crop_code)
	forvalues i=1(1)`ncrop' {
		local p : word `i' of  $topcrop_area
		local np : word `i' of  $topcropname_area
		local `v'`p' = subinstr("`v'`p'","`p'","_`np'",1)	
		ren `v'`p'  ``v'`p''
	}	
}
gen number_trees_planted_cassava=number_trees_planted if crop_code==21
gen number_trees_planted_banana=number_trees_planted if crop_code==71
recode number_trees_planted_cassava number_trees_planted_banana (.=0) 	
collapse (firstnm) harvest* area_harv*  area_plan* total_planted_area* total_harv_area* kgs_harvest*  kgs_sold*  value_harv* value_sold* (sum) number_trees_planted_*, by(y4_hhid)
recode harvest*   area_harv* area_plan* kgs_harvest* total_planted_area* total_harv_area* kgs_sold*  value_harv* value_sold* (0=.)
lab var kgs_harvest "Kgs harvested (household) (all seasons)"
lab var kgs_sold "Kgs sold (household) (all seasons)"
foreach p of global topcropname_area {
	lab var value_harv_`p' "Value harvested of `p' (household)" 
	lab var value_sold_`p' "Value sold of `p' (household)" 
	lab var kgs_harvest_`p'  "Harvest of `p' (kgs) (household) (all seasons)" 
	lab var kgs_sold_`p'  "Quantity sold of `p' (kgs) (household) (all seasons)" 
	lab var total_harv_area_`p'  "Total area harvested of `p' (ha) (household) (all seasons)" 
	lab var total_planted_area_`p'  "Total area planted of `p' (ha) (household) (all seasons)" 
	lab var harvest_`p' "Harvest of `p' (kgs) (household) - LRS" 
	lab var harvest_male_`p' "Harvest of `p' (kgs) (male-managed plots) - LRS" 
	lab var harvest_female_`p' "Harvest of `p' (kgs) (female-managed plots) - LRS" 
	lab var harvest_mixed_`p' "Harvest of `p' (kgs) (mixed-managed plots) - LRS"
	lab var harvest_pure_`p' "Harvest of `p' (kgs) - purestand (household) - LRS"
	lab var harvest_pure_male_`p'  "Harvest of `p' (kgs) - purestand (male-managed plots) - LRS"
	lab var harvest_pure_female_`p'  "Harvest of `p' (kgs) - purestand (female-managed plots) - LRS"
	lab var harvest_pure_mixed_`p'  "Harvest of `p' (kgs) - purestand (mixed-managed plots) - LRS"
	lab var harvest_inter_`p' "Harvest of `p' (kgs) - intercrop (household) - LRS"
	lab var harvest_inter_male_`p' "Harvest of `p' (kgs) - intercrop (male-managed plots) - LRS" 
	lab var harvest_inter_female_`p' "Harvest of `p' (kgs) - intercrop (female-managed plots) - LRS"
	lab var harvest_inter_mixed_`p' "Harvest  of `p' (kgs) - intercrop (mixed-managed plots) - LRS"
	lab var area_harv_`p' "Area harvested of `p' (ha) (household) - LRS" 
	lab var area_harv_male_`p' "Area harvested of `p' (ha) (male-managed plots) - LRS" 
	lab var area_harv_female_`p' "Area harvested of `p' (ha) (female-managed plots) - LRS" 
	lab var area_harv_mixed_`p' "Area harvested of `p' (ha) (mixed-managed plots) - LRS"
	lab var area_harv_pure_`p' "Area harvested of `p' (ha) - purestand (household) - LRS"
	lab var area_harv_pure_male_`p'  "Area harvested of `p' (ha) - purestand (male-managed plots) - LRS"
	lab var area_harv_pure_female_`p'  "Area harvested of `p' (ha) - purestand (female-managed plots) - LRS"
	lab var area_harv_pure_mixed_`p'  "Area harvested of `p' (ha) - purestand (mixed-managed plots) - LRS"
	lab var area_harv_inter_`p' "Area harvested of `p' (ha) - intercrop (household) - LRS"
	lab var area_harv_inter_male_`p' "Area harvested of `p' (ha) - intercrop (male-managed plots) - LRS" 
	lab var area_harv_inter_female_`p' "Area harvested of `p' (ha) - intercrop (female-managed plots) - LRS"
	lab var area_harv_inter_mixed_`p' "Area harvested  of `p' (ha) - intercrop (mixed-managed plots - LRS)"
	lab var area_plan_`p' "Area planted of `p' (ha) (household) - LRS" 
	lab var area_plan_male_`p' "Area planted of `p' (ha) (male-managed plots) - LRS" 
	lab var area_plan_female_`p' "Area planted of `p' (ha) (female-managed plots) - LRS" 
	lab var area_plan_mixed_`p' "Area planted of `p' (ha) (mixed-managed plots) - LRS"
	lab var area_plan_pure_`p' "Area planted of `p' (ha) - purestand (household) - LRS"
	lab var area_plan_pure_male_`p'  "Area planted of `p' (ha) - purestand (male-managed plots) - LRS"
	lab var area_plan_pure_female_`p'  "Area planted of `p' (ha) - purestand (female-managed plots) - LRS"
	lab var area_plan_pure_mixed_`p'  "Area planted of `p' (ha) - purestand (mixed-managed plots) - LRS"
	lab var area_plan_inter_`p' "Area planted of `p' (ha) - intercrop (household) - LRS"
	lab var area_plan_inter_male_`p' "Area planted of `p' (ha) - intercrop (male-managed plots) - LRS" 
	lab var area_plan_inter_female_`p' "Area planted of `p' (ha) - intercrop (female-managed plots) - LRS"
	lab var area_plan_inter_mixed_`p' "Area planted  of `p' (ha) - intercrop (mixed-managed plots) - LRS"
}
*Household grew crop
foreach p of global topcropname_area {
	gen grew_`p'=(total_harv_area_`p'!=. & total_harv_area_`p'!=.0 ) | (total_planted_area_`p'!=. & total_planted_area_`p'!=.0)
	lab var grew_`p' "1=Household grew `p'" 
	gen harvested_`p'= (total_harv_area_`p'!=. & total_harv_area_`p'!=.0 )
	lab var harvested_`p' "1= Household harvested `p'"
}
foreach p in cassav banana { //tree/permanent crops have no area in this instrument 
	replace grew_`p' = 1 if number_trees_planted_`p'!=0 & number_trees_planted_`p'!=.
}

*Household grew crop in the LRS
foreach p of global topcropname_area {
	gen grew_`p'_lrs=(area_harv_`p'!=. & area_harv_`p'!=.0 ) | (area_plan_`p'!=. & area_plan_`p'!=.0)
	lab var grew_`p'_lrs "1=Household grew `p' in the long rainy season" 
	gen harvested_`p'_lrs= (area_harv_`p'!=. & area_harv_`p'!=.0 )
	lab var harvested_`p'_lrs "1= Household harvested `p' in the long rainy season"
}

foreach p of global topcropname_area {
	recode kgs_harvest_`p' (.=0) if grew_`p'==1 
	recode value_sold_`p' (.=0) if grew_`p'==1 
	recode value_harv_`p' (.=0) if grew_`p'==1 
}
drop harvest- harvest_pure_mixed area_harv- area_harv_pure_mixed area_plan- area_plan_pure_mixed value_harv value_sold total_planted_area total_harv_area number_trees_planted_*
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_yield_hh_crop_level.dta", replace

*/


*Start DYA 9.13.2020 
********************************************************************************
*PRODUCTION BY HIGH/LOW VALUE CROPS
********************************************************************************


* VALUE OF CROP PRODUCTION  // using 335 output
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_values_production.dta", clear
*Grouping following IMPACT categories but also mindful of the consumption categories.
gen crop_group=""
replace crop_group=	"Maize"	if crop_code==	11
replace crop_group=	"Rice"	if crop_code==	12
replace crop_group=	"Millet and sorghum"	if crop_code==	13
replace crop_group=	"Millet and sorghum"	if crop_code==	14
replace crop_group=	"Millet and sorghum"	if crop_code==	15
replace crop_group=	"Wheat"	if crop_code==	16
replace crop_group=	"Other cereals"	if crop_code==	17
replace crop_group=	"Spices"	if crop_code==	18
replace crop_group=	"Spices"	if crop_code==	19
replace crop_group=	"Cassava"	if crop_code==	21
replace crop_group=	"Sweet potato"	if crop_code==	22
replace crop_group=	"Potato"	if crop_code==	23
replace crop_group=	"Yam"	if crop_code==	24
replace crop_group=	"Yam"	if crop_code==	25
replace crop_group=	"Vegetables"	if crop_code==	26
replace crop_group=	"Spices"	if crop_code==	27
replace crop_group=	"Beans, peas, and pulses"	if crop_code==	31
replace crop_group=	"Beans, peas, and pulses"	if crop_code==	32
replace crop_group=	"Beans, peas, and pulses"	if crop_code==	33
replace crop_group=	"Beans, peas, and pulses"	if crop_code==	34
replace crop_group=	"Beans, peas, and pulses"	if crop_code==	35
replace crop_group=	"Other nuts, seeds, and pulses"	if crop_code==	36
replace crop_group=	"Beans, peas, and pulses"	if crop_code==	37
replace crop_group=	"Fruits"	if crop_code==	38
replace crop_group=	"Fruits"	if crop_code==	39
replace crop_group=	"Oils and fats"	if crop_code==	41
replace crop_group=	"Oils and fats"	if crop_code==	42
replace crop_group=	"Groundnuts"	if crop_code==	43
replace crop_group=	"Oils and fats"	if crop_code==	44
replace crop_group=	"Other nuts, seeds, and pulses"	if crop_code==	45
replace crop_group=	"Other nuts, seeds, and pulses"	if crop_code==	46
replace crop_group=	"Soyabeans"	if crop_code==	47
replace crop_group=	"Other nuts, seeds, and pulses"	if crop_code==	48
replace crop_group=	"Cotton"	if crop_code==	50
replace crop_group=	"Other other"	if crop_code==	51
replace crop_group=	"Other other"	if crop_code==	52
replace crop_group=	"Other other"	if crop_code==	53
replace crop_group=	"Tea, coffee, cocoa"	if crop_code==	54
replace crop_group=	"Tea, coffee, cocoa"	if crop_code==	55
replace crop_group=	"Tea, coffee, cocoa"	if crop_code==	56
replace crop_group=	"Other other"	if crop_code==	57
replace crop_group=	"Other other"	if crop_code==	58
replace crop_group=	"Other other"	if crop_code==	59
replace crop_group=	"Sugar"	if crop_code==	60
replace crop_group=	"Spices"	if crop_code==	61
replace crop_group=	"Spices"	if crop_code==	62
replace crop_group=	"Spices"	if crop_code==	63
replace crop_group=	"Spices"	if crop_code==	64
replace crop_group=	"Spices"	if crop_code==	65
replace crop_group=	"Spices"	if crop_code==	66
replace crop_group=	"Fruits"	if crop_code==	67
replace crop_group=	"Fruits"	if crop_code==	68
replace crop_group=	"Fruits"	if crop_code==	69
replace crop_group=	"Fruits"	if crop_code==	70
replace crop_group=	"Bananas and plantains"	if crop_code==	71
replace crop_group=	"Fruits"	if crop_code==	72
replace crop_group=	"Fruits"	if crop_code==	73
replace crop_group=	"Fruits"	if crop_code==	74
replace crop_group=	"Fruits"	if crop_code==	75
replace crop_group=	"Fruits"	if crop_code==	76
replace crop_group=	"Fruits"	if crop_code==	77
replace crop_group=	"Fruits"	if crop_code==	78
replace crop_group=	"Fruits"	if crop_code==	79
replace crop_group=	"Fruits"	if crop_code==	80
replace crop_group=	"Fruits"	if crop_code==	81
replace crop_group=	"Fruits"	if crop_code==	82
replace crop_group=	"Fruits"	if crop_code==	83
replace crop_group=	"Fruits"	if crop_code==	84
replace crop_group=	"Vegetables"	if crop_code==	86
replace crop_group=	"Vegetables"	if crop_code==	87
replace crop_group=	"Vegetables"	if crop_code==	88
replace crop_group=	"Vegetables"	if crop_code==	89
replace crop_group=	"Vegetables"	if crop_code==	90
replace crop_group=	"Vegetables"	if crop_code==	91
replace crop_group=	"Vegetables"	if crop_code==	92
replace crop_group=	"Vegetables"	if crop_code==	93
replace crop_group=	"Vegetables"	if crop_code==	94
replace crop_group=	"Fruits"	if crop_code==	95
replace crop_group=	"Vegetables"	if crop_code==	96
replace crop_group=	"Vegetables"	if crop_code==	97
replace crop_group=	"Vegetables"	if crop_code==	98
replace crop_group=	"Vegetables"	if crop_code==	99
replace crop_group=	"Vegetables"	if crop_code==	100
replace crop_group=	"Fruits"	if crop_code==	101
replace crop_group=	"Fruits"	if crop_code==	200
replace crop_group=	"Fruits"	if crop_code==	201
replace crop_group=	"Fruits"	if crop_code==	202
replace crop_group=	"Fruits"	if crop_code==	203
replace crop_group=	"Fruits"	if crop_code==	204
replace crop_group=	"Fruits"	if crop_code==	205
replace crop_group=	"Other other"	if crop_code==	210
replace crop_group=	"Vegetables"	if crop_code==	211
replace crop_group=	"Vegetables"	if crop_code==	212
replace crop_group=	"Vegetables"	if crop_code==	300
replace crop_group=	"Vegetables"	if crop_code==	301
replace crop_group=	"Other other"	if crop_code==	302
replace crop_group=	"Other other"	if crop_code==	303
replace crop_group=	"Other other"	if crop_code==	304
replace crop_group=	"Other other"	if crop_code==	305
replace crop_group=	"Other other"	if crop_code==	306
replace crop_group=	"Fruits"	if crop_code==	851
replace crop_group=	"Fruits"	if crop_code==	852
replace crop_group=	"Other other"	if crop_code==	998
ren  crop_group commodity

*High/low value crops
gen type_commodity=""
* CJS 10.21 revising commodity high/low classification
replace type_commodity=	"Low"	if crop_code==	11
replace type_commodity=	"High"	if crop_code==	12
replace type_commodity=	"Low"	if crop_code==	13
replace type_commodity=	"Low"	if crop_code==	14
replace type_commodity=	"Low"	if crop_code==	15
replace type_commodity=	"Low"	if crop_code==	16
replace type_commodity=	"Low"	if crop_code==	17
replace type_commodity=	"High"	if crop_code==	18
replace type_commodity=	"High"	if crop_code==	19
replace type_commodity=	"Low"	if crop_code==	21
replace type_commodity=	"Low"	if crop_code==	22
replace type_commodity=	"Low"	if crop_code==	23
replace type_commodity=	"Low"	if crop_code==	24
replace type_commodity=	"Low"	if crop_code==	25
replace type_commodity=	"High"	if crop_code==	26
replace type_commodity=	"High"	if crop_code==	27
replace type_commodity=	"High"	if crop_code==	31
replace type_commodity=	"High"	if crop_code==	32
replace type_commodity=	"High"	if crop_code==	33
replace type_commodity=	"High"	if crop_code==	34
replace type_commodity=	"High"	if crop_code==	35
replace type_commodity=	"High"	if crop_code==	36
replace type_commodity=	"High"	if crop_code==	37
replace type_commodity=	"High"	if crop_code==	38
replace type_commodity=	"High"	if crop_code==	39
replace type_commodity=	"High"	if crop_code==	41
replace type_commodity=	"High"	if crop_code==	42
replace type_commodity=	"High"	if crop_code==	43
replace type_commodity=	"Out"	if crop_code==	44
replace type_commodity=	"High"	if crop_code==	45
replace type_commodity=	"High"	if crop_code==	46
replace type_commodity=	"High"	if crop_code==	47
replace type_commodity=	"High"	if crop_code==	48
replace type_commodity=	"Out"	if crop_code==	50
replace type_commodity=	"Out"	if crop_code==	51
replace type_commodity=	"High"	if crop_code==	52
replace type_commodity=	"Out"	if crop_code==	53
replace type_commodity=	"High"	if crop_code==	54
replace type_commodity=	"Out"	if crop_code==	55
replace type_commodity=	"High"	if crop_code==	56
replace type_commodity=	"Out"	if crop_code==	57
replace type_commodity=	"Out"	if crop_code==	58
replace type_commodity=	"Out"	if crop_code==	59
replace type_commodity=	"Out"	if crop_code==	60
replace type_commodity=	"High"	if crop_code==	61
replace type_commodity=	"Out"	if crop_code==	62
replace type_commodity=	"High"	if crop_code==	63
replace type_commodity=	"High"	if crop_code==	64
replace type_commodity=	"High"	if crop_code==	65
replace type_commodity=	"High"	if crop_code==	66
replace type_commodity=	"High"	if crop_code==	67
replace type_commodity=	"High"	if crop_code==	68
replace type_commodity=	"High"	if crop_code==	69
replace type_commodity=	"High"	if crop_code==	70
replace type_commodity=	"Low"	if crop_code==	71
replace type_commodity=	"High"	if crop_code==	72
replace type_commodity=	"High"	if crop_code==	73
replace type_commodity=	"High"	if crop_code==	74
replace type_commodity=	"High"	if crop_code==	75
replace type_commodity=	"High"	if crop_code==	76
replace type_commodity=	"High"	if crop_code==	77
replace type_commodity=	"High"	if crop_code==	78
replace type_commodity=	"High"	if crop_code==	79
replace type_commodity=	"High"	if crop_code==	80
replace type_commodity=	"High"	if crop_code==	81
replace type_commodity=	"High"	if crop_code==	82
replace type_commodity=	"High"	if crop_code==	83
replace type_commodity=	"High"	if crop_code==	84
replace type_commodity=	"High"	if crop_code==	86
replace type_commodity=	"High"	if crop_code==	87
replace type_commodity=	"High"	if crop_code==	88
replace type_commodity=	"High"	if crop_code==	89
replace type_commodity=	"High"	if crop_code==	90
replace type_commodity=	"High"	if crop_code==	91
replace type_commodity=	"High"	if crop_code==	92
replace type_commodity=	"High"	if crop_code==	93
replace type_commodity=	"High"	if crop_code==	94
replace type_commodity=	"High"	if crop_code==	95
replace type_commodity=	"High"	if crop_code==	96
replace type_commodity=	"High"	if crop_code==	97
replace type_commodity=	"High"	if crop_code==	98
replace type_commodity=	"High"	if crop_code==	99
replace type_commodity=	"High"	if crop_code==	100
replace type_commodity=	"High"	if crop_code==	101
replace type_commodity=	"High"	if crop_code==	200
replace type_commodity=	"High"	if crop_code==	201
replace type_commodity=	"High"	if crop_code==	202
replace type_commodity=	"High"	if crop_code==	203
replace type_commodity=	"High"	if crop_code==	204
replace type_commodity=	"High"	if crop_code==	205
replace type_commodity=	"High"	if crop_code==	210
replace type_commodity=	"High"	if crop_code==	211
replace type_commodity=	"High"	if crop_code==	212
replace type_commodity=	"High"	if crop_code==	300
replace type_commodity=	"High"	if crop_code==	301
replace type_commodity=	"High"	if crop_code==	302
replace type_commodity=	"Out"	if crop_code==	303
replace type_commodity=	"Out"	if crop_code==	304
replace type_commodity=	"Out"	if crop_code==	305
replace type_commodity=	"Out"	if crop_code==	306
replace type_commodity=	"High"	if crop_code==	851
replace type_commodity=	"High"	if crop_code==	852
replace type_commodity=	"Out"	if crop_code==	998

	
preserve
collapse (sum) value_crop_production value_crop_sales, by( y4_hhid commodity) 
ren value_crop_production value_pro
ren value_crop_sales value_sal
separate value_pro, by(commodity)
separate value_sal, by(commodity)
foreach s in pro sal {
	ren value_`s'1 value_`s'_bana
	ren value_`s'2 value_`s'_bpuls
	ren value_`s'3 value_`s'_casav
	ren value_`s'4 value_`s'_coton
	ren value_`s'5 value_`s'_fruit
	ren value_`s'6 value_`s'_gdnut
	ren value_`s'7 value_`s'_maize
	ren value_`s'8 value_`s'_mlsor
	ren value_`s'9 value_`s'_oilc
	ren value_`s'10 value_`s'_onuts
	ren value_`s'11 value_`s'_oths
	ren value_`s'12 value_`s'_pota
	ren value_`s'13 value_`s'_rice
	ren value_`s'14 value_`s'_sybea
	ren value_`s'15 value_`s'_spice
	ren value_`s'16 value_`s'_suga
	ren value_`s'17 value_`s'_spota
	ren value_`s'18 value_`s'_tcofc
	ren value_`s'19 value_`s'_vegs
	ren value_`s'20 value_`s'_whea
	ren value_`s'21 value_`s'_yam
} 

foreach x of varlist value_pro* {
	local l`x':var label `x'
	local l`x'= subinstr("`l`x''","value_pro, commodity == ","Value of production, ",.) 
	lab var `x' "`l`x''"
}
foreach x of varlist value_sal* {
	local l`x':var label `x'
	local l`x'= subinstr("`l`x''","value_sal, commodity == ","Value of sales, ",.) 
	lab var `x' "`l`x''"
}

qui recode value_* (.=0)
foreach x of varlist value_* {
	local l`x':var label `x'
}
collapse (sum) value_*, by(y4_hhid)
foreach x of varlist value_* {
	lab var `x' "`l`x''"
}

drop value_pro value_sal
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_values_production_grouped.dta", replace
restore

*type of commodity
collapse (sum) value_crop_production value_crop_sales, by( y4_hhid type_commodity) 
ren value_crop_production value_pro
ren value_crop_sales value_sal
separate value_pro, by(type_commodity)
separate value_sal, by(type_commodity)
foreach s in pro sal {
	ren value_`s'1 value_`s'_high
	ren value_`s'2 value_`s'_low
	/*DYA.10.30.2020*/ ren value_`s'3 value_`s'_other
} 
foreach x of varlist value_pro* {
	local l`x':var label `x'
	local l`x'= subinstr("`l`x''","value_pro, type_commodity == ","Value of production, ",.) 
	lab var `x' "`l`x''"
}
foreach x of varlist value_sal* {
	local l`x':var label `x'
	local l`x'= subinstr("`l`x''","value_sal, type_commodity == ","Value of sales, ",.) 
	lab var `x' "`l`x''"
}

qui recode value_* (.=0)
foreach x of varlist value_* {
	local l`x':var label `x'
}

qui recode value_* (.=0)
collapse (sum) value_*, by(y4_hhid)
foreach x of varlist value_* {
	lab var `x' "`l`x''"
}
drop value_pro value_sal
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_values_production_type_crop.dta", replace
*End DYA 9.13.2020 

********************************************************************************
*SHANNON DIVERSITY INDEX
********************************************************************************
*Area planted
*Bringing in area planted for LRS //Could be replaced with all_plots 
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_area_plan_LRS.dta", clear
append using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_area_plan_SRS.dta"
//ALT 07.21.21: As of this update, most tree crops are included with the exception of some instances where it is impossible to estimate crop area because any reasonable attempt at estimation would result in an overplanted plot. The line below is designed to drop tree crops for consistency with past estimates; remove or comment out if you want to include them
//Begin tree crop removal
	drop if area_plan==0 //2782 instances where area is indeterminable
	drop if number_trees_planted>0 &  (crop_code!=21 & crop_code!=71) //Hold on to cassava and banana; 1376 obs removed
//End tree crop removal
*generating area planted of each crop as a proportion of the total area
collapse (sum) area_plan*, by(y4_hhid crop_code)
preserve 
collapse (sum) area_plan_hh=area_plan area_plan_female_hh=area_plan_female area_plan_male_hh=area_plan_male area_plan_mixed_hh=area_plan_mixed, by(y4_hhid)
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_area_plan_shannon.dta", replace
restore
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_area_plan_shannon.dta", nogen		//all matched
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
bysort y4_hhid (sdi_crop_female) : gen allmissing_female = mi(sdi_crop_female[1])
bysort y4_hhid (sdi_crop_male) : gen allmissing_male = mi(sdi_crop_male[1])
bysort y4_hhid (sdi_crop_mixed) : gen allmissing_mixed = mi(sdi_crop_mixed[1])
*Generating number of crops per household
bysort y4_hhid crop_code : gen nvals_tot = _n==1
gen nvals_female = nvals_tot if area_plan_female!=0 & area_plan_female!=.
gen nvals_male = nvals_tot if area_plan_male!=0 & area_plan_male!=. 
gen nvals_mixed = nvals_tot if area_plan_mixed!=0 & area_plan_mixed!=.
collapse (sum) sdi=sdi_crop sdi_female=sdi_crop_female sdi_male=sdi_crop_male sdi_mixed=sdi_crop_mixed num_crops_hh=nvals_tot num_crops_female=nvals_female ///
num_crops_male=nvals_male num_crops_mixed=nvals_mixed (max) allmissing_female allmissing_male allmissing_mixed, by(y4_hhid)
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
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_shannon_diversity_index.dta", replace


//IHS 10/11/19 START
********************************************************************************
*CONSUMPTION
******************************************************************************** 
use "${Tanzania_NPS_W4_raw_data}/consumptionnps4.dta", clear
ren expmR total_cons // using real consumption-adjusted for region price disparities
gen peraeq_cons = (total_cons / adulteq)
gen percapita_cons = (total_cons / hhsize)
gen daily_peraeq_cons = peraeq_cons/365 
gen daily_percap_cons = percapita_cons/365
lab var total_cons "Total HH consumption"
lab var peraeq_cons "Consumption per adult equivalent"
lab var percapita_cons "Consumption per capita"
lab var daily_peraeq_cons "Daily consumption per adult equivalent"
lab var daily_percap_cons "Daily consumption per capita" 
keep y4_hhid total_cons peraeq_cons percapita_cons daily_peraeq_cons daily_percap_cons adulteq
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_consumption.dta", replace
//IHS 10/11/19 END


********************************************************************************
*HOUSEHOLD FOOD PROVISION*
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/hh_sec_h.dta", clear
forvalues k=1/36 {
	gen food_insecurity_`k' = (hh_h09_`k'=="X")
}
egen months_food_insec = rowtotal(food_insecurity_*) 
* replacing those that report over 12 months
replace months_food_insec = 12 if months_food_insec>12
keep y4_hhid months_food_insec
lab var months_food_insec "Number of months of inadequate food provision"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_food_insecurity.dta", replace


********************************************************************************
*HOUSEHOLD ASSETS*
********************************************************************************
use "${Tanzania_NPS_W4_raw_data}/hh_sec_m.dta", clear
ren hh_m03 price_purch
ren hh_m04 value_today
ren hh_m02 age_item
ren hh_m01 num_items
*dropping items that don't report prices
drop if itemcode==413 | itemcode==414 | itemcode==416 | itemcode==424 | itemcode==436 | itemcode==440
collapse (sum) value_assets=value_today, by(y4_hhid)
la var value_assets "Value of household assets"
save "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_assets.dta", replace 



********************************************************************************
*DISTANCE TO AGRO DEALERS*
********************************************************************************
*Cannot create in this instrument

 
********************************************************************************
*HOUSEHOLD VARIABLES
********************************************************************************
//ALT 02.02.23: Updated to align with W5 code
global empty_vars ""
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta", clear

*Gross crop income 
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_production.dta", nogen
* Production by group and type of crop
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_crop_losses.dta", nogen
recode value_crop_production crop_value_lost (.=0)
*Variables: value_crop_production crop_value_lost
* Production by group and type of crops
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_values_production_grouped.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_crop_values_production_type_crop.dta", nogen
recode value_pro* value_sal* (.=0)
*Crop costs
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_cost_inputs.dta", nogen
gen crop_income = value_crop_production - crop_production_expenses - crop_value_lost

lab var crop_production_expenses "Crop production expenditures (explicit)"
lab var crop_income "Net crop revenue"

foreach c in $topcropname_area {
	capture confirm file "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_inputs_`c'.dta"
	if _rc==0 {
	merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_inputs_`c'.dta", nogen
	merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_`c'_monocrop_hh_area.dta", nogen
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


*land rights
merge 1:1 y4_hhid using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_rights_hh.dta", nogen
la var formal_land_rights_hh "Household has documentation of land rights (at least one plot)"

*Livestock income
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_sales", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_livestock_products", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_dung.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_expenses", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_TLU.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_herd_characteristics", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_TLU_Coefficients.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_expenses_animal.dta", nogen 

/*OUT DYA.10.30.2020*/
recode value_slaughtered value_lvstck_sold value_livestock_purchases value_milk_produced value_eggs_produced value_other_produced sales_dung cost_hired_labor_livestock cost_fodder_livestock cost_vaccines_livestock cost_water_livestock (.=0) // AYW 8.7.20
gen livestock_income = value_slaughtered + value_lvstck_sold - value_livestock_purchases /*
*/ + (value_milk_produced + value_eggs_produced + value_other_produced + sales_dung) /* 
*/ - (cost_hired_labor_livestock + cost_fodder_livestock + cost_vaccines_livestock + cost_water_livestock)
lab var livestock_income "Net livestock income"
gen livestock_expenses = cost_hired_labor_livestock + cost_fodder_livestock + cost_vaccines_livestock + cost_water_livestock
ren cost_vaccines_livestock ls_exp_vac  
drop value_livestock_purchases value_other_produced sales_dung cost_hired_labor_livestock cost_fodder_livestock cost_water_livestock
lab var sales_livestock_products "Value of sales of livestock products"
lab var value_livestock_products "Value of livestock products"
lab var livestock_expenses "Total livestock expenses"

*Fish income
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fish_income.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fishing_expenses_1.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fishing_expenses_2.dta", nogen
/*OUT DYA.10.30.2020*/
gen fishing_income = value_fish_harvest - cost_fuel - rental_costs_fishing - cost_paid
lab var fishing_income "Net fish income"
drop cost_fuel rental_costs_fishing cost_paid

*Self-employment income
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_self_employment_income.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fish_trading_income.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_agproducts_profits.dta", nogen

/*OUT DYA.10.30.2020*/
egen self_employment_income = rowtotal(annual_selfemp_profit fish_trading_income byproduct_profits)
lab var self_employment_income "Income from self-employment"
drop annual_selfemp_profit fish_trading_income byproduct_profits 

*Wage income
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_wage_income.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_agwage_income.dta", nogen
/*OUT DYA.10.30.2020*/
recode annual_salary annual_salary_agwage(.=0)
ren annual_salary nonagwage_income
ren annual_salary_agwage agwage_income

*Off-farm hours
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_off_farm_hours.dta", nogen

*Other income
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_other_income.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_rental_income.dta", nogen

/*OUT DYA.10.30.2020*/
egen transfers_income = rowtotal (pension_income remittance_income assistance_income)
lab var transfers_income "Income from transfers including pension, remittances, and assisances)"
egen all_other_income = rowtotal (rental_income other_income  land_rental_income)
lab var all_other_income "Income from all other revenue"
drop pension_income remittance_income assistance_income rental_income other_income land_rental_income

*Farm size
merge 1:1 y4_hhid using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_size.dta", nogen
merge 1:1 y4_hhid using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_size_all.dta", nogen
merge 1:1 y4_hhid using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_farmsize_all_agland.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_size_total.dta", nogen

/*OUT DYA.10.30.2020*/
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
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_family_hired_labor.dta", nogen
/*OUT DYA.10.30.2020*/
recode   labor_hired labor_family (.=0)
  
*Household size
merge 1:1 y4_hhid using  "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhsize.dta", nogen

*Rates of vaccine usage, improved seeds, etc.
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_vaccine.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_input_use.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_improvedseed_use.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_any_ext.dta", nogen
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fin_serv.dta", nogen

/*OUT DYA.10.30.2020*/
recode use_fin_serv* ext_reach* use_inorg_fert imprv_seed_use vac_animal (.=0)
replace vac_animal=. if tlu_today==0 
replace use_inorg_fert=. if farm_area==0 | farm_area==. 
recode ext_reach* (0 1=.) if (value_crop_production==0 & livestock_income==0 & farm_area==0 & tlu_today==0)
recode ext_reach* (0 1=.) if farm_area==.
replace imprv_seed_use=. if farm_area==.
global empty_vars $empty_vars imprv_seed_cassav imprv_seed_banana hybrid_seed_*

*Milk productivity
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_milk_animals.dta", nogen

/*OUT DYA.10.30.2020*/
gen liters_milk_produced=liters_per_largeruminant * milk_animals
lab var liters_milk_produced "Total quantity (liters) of milk per year" 
drop liters_per_largeruminant
gen liters_per_cow = . 
gen liters_per_buffalo = . 

*Dairy costs 
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_lrum_expenses", nogen

/*OUT DYA.10.30.2020*/
gen avg_cost_lrum = cost_lrum/mean_12months_lrum 
lab var avg_cost_lrum "Average cost per large ruminant"
gen costs_dairy = avg_cost_lrum*milk_animals 
*gen costs_dairy_percow == avg_cost_lrum
gen costs_dairy_percow=. 
drop avg_cost_lrum cost_lrum
lab var costs_dairy "Dairy production cost (explicit)"
lab var costs_dairy_percow "Dairy production cost (explicit) per cow"
gen share_imp_dairy = . 

*Egg productivity
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_eggs_animals.dta", nogen

/*OUT DYA.10.30.2020*/
gen egg_poultry_year = . 
global empty_vars $empty_vars *liters_per_cow *liters_per_buffalo *costs_dairy_percow* share_imp_dairy *egg_poultry_year

*Costs of crop production per hectare
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_cropcosts_total.dta", nogen
*Rate of fertilizer application 
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_fertilizer_application.dta", nogen
*Agricultural wage rate
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_ag_wage.dta", nogen
*Crop yields 
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_yield_hh_crop_level.dta", nogen
*Total area planted and harvested accross all crops, plots, and seasons
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_area_planted_harvested_allcrops.dta", nogen
*Household diet
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_household_diet.dta", nogen
*Consumption
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_consumption.dta", nogen
*Household assets
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hh_assets.dta", nogen

*Food insecurity
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_food_insecurity.dta", nogen

/*OUT DYA.10.30.2020*/
gen hhs_little = . 
gen hhs_moderate = . 
gen hhs_severe = . 
gen hhs_total = . 
global empty_vars $empty_vars hhs_* 

*Distance to agrodealer // cannot construct 
gen dist_agrodealer = . 
global empty_vars $empty_vars *dist_agrodealer
 
*Livestock health
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_diseases.dta", nogen

*livestock feeding, water, and housing
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_livestock_feed_water_house.dta", nogen
 
*Shannon diversity index
merge 1:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_shannon_diversity_index.dta", nogen

/*OUT DYA.10.30.2020*/ 
*Farm Production 
recode value_crop_production  value_livestock_products value_slaughtered  value_lvstck_sold (.=0)
gen value_farm_production = value_crop_production + value_livestock_products + value_slaughtered + value_lvstck_sold
lab var value_farm_production "Total value of farm production (crops + livestock products)"
gen value_farm_prod_sold = value_crop_sales + sales_livestock_products + value_livestock_sales 
lab var value_farm_prod_sold "Total value of farm production that is sold" 
replace value_farm_prod_sold = 0 if value_farm_prod_sold==. & value_farm_production!=.



*Agricultural households
recode value_crop_production livestock_income farm_area tlu_today (.=0)
gen ag_hh = (value_crop_production!=0 | crop_income!=0 | livestock_income!=0 | farm_area!=0 | tlu_today!=0)
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
recode fishing_income (.=0)
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

 *households engaged in monocropped production of specific crops
 foreach cn in $topcropname_area {
	recode `cn'_monocrop (.=0)
	foreach g in male female mixed {
		recode `cn'_monocrop_`g' (.=0)
	}
}
forvalues k=1/$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode `cn'_exp `cn'_monocrop_ha (.=0) if `cn'_monocrop==1
	recode `cn'_exp `cn'_monocrop_ha (nonmissing=.) if `cn'_monocrop==0
	foreach g in male female mixed {
			recode `cn'_exp_`g' `cn'_monocrop_ha_`g' (.=0) if `cn'_monocrop_`g'==1
			recode `cn'_exp_`g' `cn'_monocrop_ha_`g' (nonmissing=.) if `cn'_monocrop_`g'==0
	}
}
*all rural households engaged in livestcok production of a given species
foreach i in lrum srum poultry{
	recode lost_disease_`i' ls_exp_vac_`i' disease_animal_`i' feed_grazing_`i' water_source_nat_`i' water_source_const_`i' water_source_cover_`i' lvstck_housed_`i' (nonmissing=.) if lvstck_holding_`i'==0
	recode lost_disease_`i' ls_exp_vac_`i' disease_animal_`i' feed_grazing_`i' water_source_nat_`i' water_source_const_`i' water_source_cover_`i' lvstck_housed_`i'(.=0) if lvstck_holding_`i'==1	
}
 
*households engaged in crop production
recode cost_expli_hh value_crop_production value_crop_sales labor_hired labor_family farm_size_agland all_area_harvested all_area_planted (.=0) if crop_hh==1
recode cost_expli_hh value_crop_production value_crop_sales labor_hired labor_family farm_size_agland all_area_harvested all_area_planted (nonmissing=.) if crop_hh==0
 
*all rural households engaged in livestock production 
recode animals_lost12months* mean_12months* livestock_expenses disease_animal feed_grazing water_source_nat water_source_const water_source_cover lvstck_housed (.=0) if livestock_hh==1
recode animals_lost12months* mean_12months* livestock_expenses disease_animal feed_grazing water_source_nat water_source_const water_source_cover lvstck_housed (nonmissing=.) if livestock_hh==0
 
*all rural households 
recode /*DYA.10.26.2020*/ hrs_ag_activ hrs_wage_off_farm hrs_wage_on_farm hrs_unpaid_off_farm hrs_domest_fire_fuel hrs_off_farm hrs_on_farm hrs_domest_all hrs_other_all hrs_self_off_farm crop_income livestock_income self_employment_income nonagwage_income agwage_income fishing_income transfers_income all_other_income value_assets (.=0)
*all rural households engaged in dairy production
recode costs_dairy liters_milk_produced value_milk_produced (.=0) if dairy_hh==1 
recode costs_dairy liters_milk_produced value_milk_produced (nonmissing=.) if dairy_hh==0
*all rural households eith egg-producing animals
recode eggs_total_year value_eggs_produced (.=0) if egg_hh==1
recode eggs_total_year value_eggs_produced (nonmissing=.) if egg_hh==0

global gender "female male mixed"
*Variables winsorized at the top 1% only 
global wins_var_top1 /*
*/ value_crop_production value_crop_sales value_harv* value_sold* kgs_harvest* kgs_harv_mono* total_planted_area* total_harv_area* /*
*/ labor_hired labor_family /*
*/ animals_lost12months* mean_12months* lost_disease* /* 
*/ liters_milk_produced costs_dairy /*
*/ eggs_total_year value_eggs_produced value_milk_produced egg_poultry_year /*
*/ /*DYA.10.26.2020*/ hrs_ag_activ hrs_wage_off_farm hrs_wage_on_farm hrs_unpaid_off_farm hrs_domest_fire_fuel hrs_off_farm hrs_on_farm hrs_domest_all hrs_other_all hrs_self_off_farm crop_production_expenses value_assets cost_expli_hh /*
*/ livestock_expenses ls_exp_vac*  sales_livestock_products value_livestock_products value_livestock_sales /*
*/ value_farm_production value_farm_prod_sold value_pro* value_sal*

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
global wins_var_top1_gender $wins_var_top1_gender cost_total cost_expli fert_inorg_kg wage_paid_aglabor
gen wage_paid_aglabor_female=. 
gen wage_paid_aglabor_male=.
gen wage_paid_aglabor_mixed=. 
lab var wage_paid_aglabor_female "Daily wage in agricuture - female workers"
lab var wage_paid_aglabor_male "Daily wage in agricuture - male workers"

global empty_vars $empty_vars *wage_paid_aglabor_female* *wage_paid_aglabor_male* 
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
* gen labor_total  as sum of winsorized labor_hired and labor_family
egen w_labor_total=rowtotal(w_labor_hired w_labor_family)
local llabor_total : var lab labor_total 
lab var w_labor_total "`llabor_total' - Winzorized top 1%"

*Variables winsorized both at the top 1% and bottom 1% 
global wins_var_top1_bott1  /* 
*/ farm_area farm_size_agland all_area_harvested all_area_planted ha_planted /*
*/ crop_income livestock_income fishing_income self_employment_income nonagwage_income agwage_income transfers_income all_other_income /*
*/ total_cons percapita_cons daily_percap_cons peraeq_cons daily_peraeq_cons /* 
*/ *_monocrop_ha* dist_agrodealer land_size_total

foreach v of varlist $wins_var_top1_bott1 {
	_pctile `v' [aw=weight] , p($wins_lower_thres $wins_upper_thres) 
	gen w_`v'=`v'
	replace w_`v'= r(r1) if w_`v' < r(r1) & w_`v'!=. & w_`v'!=0  /* we want to keep actual zeros */
	replace w_`v'= r(r2) if  w_`v' > r(r2)  & w_`v'!=.		
	local l`v' : var lab `v'
	lab var  w_`v'  "`l`v'' - Winzorized top and bottom 1%"
	*some vriables  are disaggreated by gender of plot manager. For these variables, we use the top and bottom 1% percentile to winsorize gender-disagregated variables
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

*area_harv  and area_plan are also winsorized both at the top 1% and bottom 1% because we need to treat at the crop level 
global allyield male female mixed inter inter_male inter_female inter_mixed pure  pure_male pure_female pure_mixed
global wins_var_top1_bott1_2 area_harv  area_plan harvest 
foreach v of global wins_var_top1_bott1_2 {
	foreach c of global topcropname_area {		
		_pctile `v'_`c'  [aw=weight] , p($wins_lower_thres $wins_upper_thres)
		gen w_`v'_`c'=`v'_`c'
		replace w_`v'_`c' = r(r1) if w_`v'_`c' < r(r1)   &  w_`v'_`c'!=0 
		replace w_`v'_`c' = r(r2) if (w_`v'_`c' > r(r2) & w_`v'_`c' !=.)  		
		local l`v'_`c'  : var lab `v'_`c'
		lab var  w_`v'_`c' "`l`v'_`c'' - Winzorized top and bottom 1%"	
		* now use pctile from area for all to trim gender/inter/pure area
		foreach g of global allyield {
			gen w_`v'_`g'_`c'=`v'_`g'_`c'
			replace w_`v'_`g'_`c' = r(r1) if w_`v'_`g'_`c' < r(r1) &  w_`v'_`g'_`c'!=0 
			replace w_`v'_`g'_`c' = r(r2) if (w_`v'_`g'_`c' > r(r2) & w_`v'_`g'_`c' !=.)  	
			local l`v'_`g'_`c'  : var lab `v'_`g'_`c'
			lab var  w_`v'_`g'_`c' "`l`v'_`g'_`c'' - Winzorized top and bottom 1%"
			
		}
	}
}

*Estimate variables that are ratios then winsorize top 1% and bottom 1% of the ratios (do not replace 0 by the percentitles)
*generate yield and weights for yields using winsorized values 
*Yield by Area Planted 
foreach c of global topcropname_area {		
	gen yield_pl_`c'=w_harvest_`c'/w_area_plan_`c'
	lab var  yield_pl_`c' "Yield by area planted of `c' (kgs/ha) (household)" 
	gen ar_pl_wgt_`c' =  weight*w_area_plan_`c'
	lab var ar_pl_wgt_`c' "Planted area-adjusted weight for `c' (household)"
	foreach g of global allyield  {
		gen yield_pl_`g'_`c'=w_harvest_`g'_`c'/w_area_plan_`g'_`c'
		lab var  yield_pl_`g'_`c'  "Yield by area planted of `c' -  (kgs/ha) (`g')" 
		gen ar_pl_wgt_`g'_`c' =  weight*w_area_plan_`g'_`c'
		lab var ar_pl_wgt_`g'_`c' "Planted area-adjusted weight for `c' (`g')"
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
 
*generate inorg_fert_rate, costs_total_ha, and costs_expli_ha using winsorized values
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
	gen mortality_rate_`s' = animals_lost12months_`s'/mean_12months_`s'
	lab var mortality_rate_`s' "Mortality rate - `s'"
}

*generating top crop expenses using winsoried values (monocropped)
foreach c in $topcropname_area{		
	gen `c'_exp_ha =w_`c'_exp /w_`c'_monocrop_ha
	la var `c'_exp_ha "Costs per hectare - Monocropped `c' plots"
	foreach  g of global gender{
		gen `c'_exp_ha_`g' =w_`c'_exp_`g'/w_`c'_monocrop_ha_`g'	
		local l`c'_exp_ha : var lab `c'_exp_ha
		lab var `c'_exp_ha_`g'  "`l`c'_exp_ha'- `g' managed plots"
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
gen liters_per_largeruminant= w_liters_milk_produced/milk_animals 
lab var liters_per_largeruminant "Average quantity (liters) per year (household)"

*crop value sold
gen w_proportion_cropvalue_sold = w_value_crop_sales /  w_value_crop_production
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
		local l`c'_exp_kg : var lab `c'_exp_kg
		lab var `c'_exp_kg_`g'  "`l`c'_exp_kg'- `g' managed plots"
	}
}

*dairy
gen cost_per_lit_milk = w_costs_dairy/w_liters_milk_produced 
lab var cost_per_lit_milk "dairy production cost per liter"

*****getting correct subpopulations***
*all rural households engaged in crop production 
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
		foreach g in male female mixed { 
		recode `cn'_exp_`g' `cn'_exp_ha_`g' `cn'_exp_kg_`g' (.=0) if `cn'_monocrop_`g'==1
		recode `cn'_exp_`g' `cn'_exp_ha_`g' `cn'_exp_kg_`g' (nonmissing=.) if `cn'_monocrop_`g'==0
		}
}

*all rural households growing specific crops (in the long rainy season) 
forvalues k=1(1)$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode yield_pl_`cn' (.=0) if grew_`cn'_lrs==1 //only reporting LRS yield so only replace if grew in LRS
	recode yield_pl_`cn' (nonmissing=.) if grew_`cn'_lrs==0 
}
*all rural households harvesting specific crops (in the long rainy season)
forvalues k=1(1)$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode yield_hv_`cn' (.=0) if harvested_`cn'_lrs==1 
	recode yield_hv_`cn' (nonmissing=.) if harvested_`cn'_lrs==0 
}

*households growing specific crops that have also purestand plots of that crop 
forvalues k=1(1)$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode yield_pl_pure_`cn' (.=0) if grew_`cn'_lrs==1 & w_area_plan_pure_`cn'!=. 
	recode yield_pl_pure_`cn' (nonmissing=.) if grew_`cn'_lrs==0 | w_area_plan_pure_`cn'==.  
}
*all rural households harvesting specific crops (in the long rainy season) that also have purestand plots 
forvalues k=1(1)$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode yield_hv_pure_`cn' (.=0) if harvested_`cn'_lrs==1 & w_area_plan_pure_`cn'!=. 
	recode yield_hv_pure_`cn' (nonmissing=.) if harvested_`cn'_lrs==0 | w_area_plan_pure_`cn'==.  
}

*households engaged in dairy production 
recode costs_dairy_percow cost_per_lit_milk (.=0) if dairy_hh==1
recode costs_dairy_percow cost_per_lit_milk (nonmissing=.) if dairy_hh==0

*now winsorize ratios only at top 1% 
global wins_var_ratios_top1 inorg_fert_rate /*
*/ cost_total_ha cost_expli_ha cost_expli_hh_ha /*
*/ land_productivity labor_productivity /*
*/ mortality_rate* liters_per_largeruminant costs_dairy_percow liters_per_cow liters_per_buffalo /*
*/ /*DYA.10.26.2020*/  hrs_*_pc_all hrs_*_pc_any cost_per_lit_milk 	

foreach v of varlist $wins_var_ratios_top1 {
	_pctile `v' [aw=weight] , p($wins_upper_thres) 
	gen w_`v'=`v'
	replace  w_`v' = r(r1) if  w_`v' > r(r1) &  w_`v'!=.
	local l`v' : var lab `v'
	lab var  w_`v'  "`l`v'' - Winzorized top 1%"

	*some variables are disaggreated by gender of plot manager. For these variables, we use the top 1% percentile to winsorize gender-disagregated variables
	if "`v'" =="inorg_fert_rate" | "`v'" =="cost_total_ha"  | "`v'" =="cost_expli_ha"  {
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
	lab var  w_`v'_exp_ha  "`l`v'_exp_ha' - Winzorized top 1%"
		*now by gender using the same method as above
		foreach g of global gender {
		gen w_`v'_exp_ha_`g'= `v'_exp_ha_`g'
		replace w_`v'_exp_ha_`g' = r(r1) if w_`v'_exp_ha_`g' > r(r1) & w_`v'_exp_ha_`g'!=.
		local l`v'_exp_ha : var lab `v'_exp_ha
		lab var w_`v'_exp_ha_`g' "`l`v'_exp_ha' - winsorized top 1%"
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
		local l`v'_exp_kg : var lab `v'_exp_kg
		lab var w_`v'_exp_kg_`g' "`l`v'_exp_kg' - winsorized top 1%"
	}
}

*now winsorize ratio only at top 1% - yield 
foreach c of global topcropname_area {
foreach i in yield_pl yield_hv{
	_pctile `i'_`c' [aw=weight] , p($wins_upper_thres) 
	gen w_`i'_`c'=`i'_`c'
	replace  w_`i'_`c' = r(r1) if  w_`i'_`c' > r(r1) &  w_`i'_`c'!=.
	local w_`i'_`c' : var lab `i'_`c'
	lab var  w_`i'_`c'  "`w_`i'_`c'' - Winzorized top 1%"
	foreach g of global allyield  {
		gen w_`i'_`g'_`c'= `i'_`g'_`c'
		replace  w_`i'_`g'_`c' = r(r1) if  w_`i'_`g'_`c' > r(r1) &  w_`i'_`g'_`c'!=.
		local w_`i'_`g'_`c' : var lab `i'_`g'_`c'
		lab var  w_`i'_`g'_`c'  "`w_`i'_`g'_`c'' - Winzorized top 1%"
		}
	}
}
 

*Create final income variables using winzorized and un_winzorized values
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
recode w_total_income w_percapita_income w_crop_income w_livestock_income w_fishing_income w_nonagwage_income w_agwage_income w_self_employment_income w_transfers_income w_all_other_income /*
*/ w_share_crop w_share_livestock w_share_fishing w_share_nonagwage w_share_agwage w_share_self_employment w_share_transfers w_share_all_other w_share_nonfarm /*
*/ use_fin_serv* /*
*/ formal_land_rights_hh  /*DYA.10.26.2020*/ *_hrs_*_pc_all months_food_insec w_value_assets /*
*/ lvstck_holding_tlu lvstck_holding_all lvstck_holding_lrum lvstck_holding_srum lvstck_holding_poultry (.=0) if rural==1 
 
*all rural households engaged in livestock production
recode vac_animal w_share_livestock_prod_sold w_livestock_expenses w_ls_exp_vac  any_imp_herd_all (. = 0) if livestock_hh==1 
recode vac_animal w_share_livestock_prod_sold w_livestock_expenses w_ls_exp_vac  any_imp_herd_all (nonmissing = .) if livestock_hh==0 

*all rural households engaged in livestcok production of a given species
foreach i in lrum srum poultry{
	recode vac_animal_`i' any_imp_herd_`i' w_lost_disease_`i' w_ls_exp_vac_`i' (nonmissing=.) if lvstck_holding_`i'==0
	recode vac_animal_`i' any_imp_herd_`i' w_lost_disease_`i' w_ls_exp_vac_`i' (.=0) if lvstck_holding_`i'==1	
}

*households engaged in crop production
recode w_proportion_cropvalue_sold w_farm_size_agland w_labor_family w_labor_hired /*
*/ imprv_seed_use use_inorg_fert w_labor_productivity w_land_productivity /*
*/ w_inorg_fert_rate* w_cost_expli* w_cost_total* /*
*/ w_value_crop_production w_value_crop_sales w_all_area_planted w_all_area_harvested /*
*/ encs* num_crops* multiple_crops (.=0) if crop_hh==1
recode w_proportion_cropvalue_sold w_farm_size_agland w_labor_family w_labor_hired /*
*/ imprv_seed_use use_inorg_fert w_labor_productivity w_land_productivity /*
*/ w_inorg_fert_rate* w_cost_expli* w_cost_total* /*
*/ w_value_crop_production w_value_crop_sales w_all_area_planted w_all_area_harvested /*
*/ encs* num_crops* multiple_crops (nonmissing= . ) if crop_hh==0
		
*hh engaged in crop or livestock production
recode ext_reach* (.=0) if (crop_hh==1 | livestock_hh==1)
recode ext_reach* (nonmissing=.) if crop_hh==0 & livestock_hh==0

*all rural households growing specific crops 
forvalues k=1(1)$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode imprv_seed_`cn' hybrid_seed_`cn' /*
	*/ w_value_harv_`cn' w_value_sold_`cn' w_kgs_harvest_`cn' w_total_planted_area_`cn' w_total_harv_area_`cn' (.=0) if grew_`cn'==1
	recode imprv_seed_`cn' hybrid_seed_`cn' /*
	*/ w_value_harv_`cn' w_value_sold_`cn' w_kgs_harvest_`cn' w_total_planted_area_`cn' w_total_harv_area_`cn' (nonmissing=.) if grew_`cn'==0
}
	
*all rural households growing specific crops (in the long rainy season)
forvalues k=1(1)$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode w_yield_pl_`cn' (.=0) if grew_`cn'_lrs==1
	recode w_yield_pl_`cn' (nonmissing=.) if grew_`cn'_lrs==0
}
*all rural households that harvested specific crops (in the long rainy season)
forvalues k=1(1)$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode w_yield_hv_`cn' (.=0) if harvested_`cn'_lrs==1
	recode w_yield_hv_`cn' (nonmissing=.) if harvested_`cn'_lrs==0
}
	
*households engaged in monocropped production of specific crops
forvalues k=1/$nb_topcrops {
	local cn: word `k' of $topcropname_area
	recode w_`cn'_exp w_`cn'_exp_ha w_`cn'_exp_kg (.=0) if `cn'_monocrop==1
	recode w_`cn'_exp w_`cn'_exp_ha w_`cn'_exp_kg (nonmissing=.) if `cn'_monocrop==0
}

*all rural households engaged in dairy production
recode costs_dairy  liters_milk_produced w_value_milk_produced (.=0) if dairy_hh==1 
recode costs_dairy  liters_milk_produced w_value_milk_produced (nonmissing=.) if dairy_hh==0
*all rural households eith egg-producing animals
recode w_eggs_total_year w_value_eggs_produced (.=0) if egg_hh==1
recode w_eggs_total_year w_value_eggs_produced (nonmissing=.) if egg_hh==0
 
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
gen weight_milk=milk_animals*weight
gen weight_egg=poultry_owned*weight
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

************Rural poverty headcount ratio***************
*First, we convert $1.90/day to local currency in 2011 using https://data.worldbank.org/indicator/PA.NUS.PRVT.PP?end=2011&locations=TZ&start=1990
	// 1.90 * 585.52 = 1112.488  
*NOTE: this is using the "Private Consumption, PPP" conversion factor because that's what we have been using. 
* This can be changed this to the "GDP, PPP" if we change the rest of the conversion factors.
*The global poverty line of $1.90/day is set by the World Bank
*http://www.worldbank.org/en/topic/poverty/brief/global-poverty-line-faq
*Second, we inflate the local currency to the year that this survey was carried out using the CPI inflation rate using https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2017&locations=TZ&start=2003
	// 1+(158.021 - 112.691)/ 112.691 = 1.4022504	
	// 1112.488* 1.4022504 = 1559.9867 TSH
*NOTE: if the survey was carried out over multiple years we use the last year
*This is the poverty line at the local currency in the year the survey was carried out

gen poverty_under_1_9 = (daily_percap_cons<1559.9867)
la var poverty_under_1_9 "Household has a percapita conumption of under $1.90 in 2011 $ PPP)"

*average consumption expenditure of the bottom 40% of the rural consumption expenditure distribution
*By per capita consumption
_pctile w_daily_percap_cons [aw=individual_weight] if rural==1, p(40)
gen bottom_40_percap = 0
replace bottom_40_percap = 1 if r(r1) > w_daily_percap_cons & rural==1

*By peraeq consumption
_pctile w_daily_peraeq_cons [aw=adulteq_weight] if rural==1, p(40)
gen bottom_40_peraeq = 0
replace bottom_40_peraeq = 1 if r(r1) > w_daily_peraeq_cons & rural==1

********Currency Conversion Factors*********
gen ccf_loc = (1+$Tanzania_NPS_W4_inflation) 
lab var ccf_loc "currency conversion factor - 2016 $TSH"
gen ccf_usd = (1+$Tanzania_NPS_W4_inflation) / $Tanzania_NPS_W4_exchange_rate 
lab var ccf_usd "currency conversion factor - 2016 $USD"
gen ccf_1ppp = (1+$Tanzania_NPS_W4_inflation) / $Tanzania_NPS_W4_cons_ppp_dollar 
lab var ccf_1ppp "currency conversion factor - 2016 $Private Consumption PPP"
gen ccf_2ppp = (1+$Tanzania_NPS_W4_inflation) / $Tanzania_NPS_W4_gdp_ppp_dollar
lab var ccf_2ppp "currency conversion factor - 2016 $GDP PPP"

*replace vars that cannot be created with .
*empty crop vars (cassava and banana - no area information for permanent crops) 
global empty_vars $empty_vars *yield_*_cassav *yield_*_banana *total_planted_area_cassav *total_harv_area_cassav *total_planted_area_banana *total_harv_area_banana *cassav_exp_ha* *banana_exp_ha*

*replace empty vars with missing 
foreach v of varlist $empty_vars {
	replace `v' = .
}

*Cleaning up output to get below 5,000 variables
*dropping unnecessary variables and recoding to missing any variables that cannot be created in this instrument
drop *_inter_* harvest_* w_harvest_*

// Removing intermediate variables to get below 5,000 vars
keep y4_hhid fhh clusterid strataid *weight* *wgt* region region_name district district_name ward ward_name village village_name ea rural farm_size* *total_income* /*
*/ *percapita_income* *percapita_cons* *daily_percap_cons* *peraeq_cons* *daily_peraeq_cons* /*
*/ *income* *share* *proportion_cropvalue_sold *farm_size_agland hh_members adulteq *labor_family *labor_hired use_inorg_fert vac_* /*
*/ feed* water* lvstck_housed* ext_* use_fin_* lvstck_holding* *mortality_rate* *lost_disease* disease* any_imp* formal_land_rights_hh /*
*/ *livestock_expenses* *ls_exp_vac* *prop_farm_prod_sold  /*DYA.10.26.2020*/ *hrs_*   months_food_insec *value_assets* hhs_* *dist_agrodealer /*
*/ encs* num_crops_* multiple_crops* imprv_seed_* hybrid_seed_* *labor_total *farm_area *labor_productivity* *land_productivity* /*
*/ *wage_paid_aglabor* *labor_hired ar_h_wgt_* *yield_hv_* ar_pl_wgt_* *yield_pl_* *liters_per_* milk_animals poultry_owned *costs_dairy* *cost_per_lit* /*
*/ *egg_poultry_year* *inorg_fert_rate* *ha_planted* *cost_expli_hh* *cost_expli_ha* *monocrop_ha* *kgs_harv_mono* *cost_total_ha* /*
*/ *_exp* poverty_under_1_9 *value_crop_production* *value_harv* *value_crop_sales* *value_sold* *kgs_harvest* *total_planted_area* *total_harv_area* /*
*/ *all_area_* grew_* agactivities_hh ag_hh crop_hh livestock_hh fishing_hh *_milk_produced* *eggs_total_year *value_eggs_produced* /*
*/ *value_livestock_products* *value_livestock_sales* *total_cons* nb_cattle_today nb_poultry_today bottom_40_percap bottom_40_peraeq /*
*/ ccf_loc ccf_usd ccf_1ppp ccf_2ppp *sales_livestock_products *value_pro* *value_sal*  /*DYA 10.6.2020*/ *value_livestock_sales*  *w_value_farm_production* *value_slaughtered* *value_lvstck_sold* *value_crop_sales* *sales_livestock_products* *value_livestock_sales*

//////////Identifier Variables ////////
*Add variables and ren household id so dta file can be appended with dta files from other instruments
ren y4_hhid hhid
gen hhid_panel = hhid 
lab var hhid_panel "panel hh identifier" 
gen geography = "Tanzania"
gen survey = "LSMS-ISA" 
gen year = "2014-15" 
gen instrument = 14 
//Only runs if label isn't already defined.
capture label define instrument 11 "Tanzania NPS Wave 1" 12 "Tanzania NPS Wave 2" 13 "Tanzania NPS Wave 3" 14 "Tanzania NPS Wave 4" 15 "Tanzania NPS Wave 5" /*
	*/ 21 "Ethiopia ESS Wave 1" 22 "Ethiopia ESS Wave 2" 23 "Ethiopia ESS Wave 3" 24 "Ethiopia ESS Wave 4" 25 "Ethiopia ESS Wave 5" /*
	*/ 31 "Nigeria GHS Wave 1" 32 "Nigeria GHS Wave 2" 33 "Nigeria GHS Wave 3" 34 "Nigeria GHS Wave 4"/*
	*/ 41 "Malawi IHS/IHPS Wave 1" 42 "Malawi IHS/IHPS Wave 2" 43 "Malawi IHS/IHPS Wave 3" 44 "Malawi IHS/IHPS Wave 4" /*
    */ 51 "Uganda NPS Wave 1" 52 "Uganda NPS Wave 2" 53 "Uganda NPS Wave 3" 54 "Uganda NPS Wave 4" 55 "Uganda NPS Wave 5" /*W6 does not exist*/ 56 "Uganda NPS Wave 7" 57 "Uganda NPS Wave 8" /* 
*/ 61 "Burkina Faso EMC Wave 1" /* 
*/ 71 "Mali EACI Wave 1" 72 "Mali EACI Wave 2" /*
*/ 81 "Niger ECVMA Wave 1" 82 "Niger ECVMA Wave 2"
saveold "${Tanzania_NPS_W4_final_data}/Tanzania_NPS_W4_household_variables.dta", replace

//stop
********************************************************************************
*INDIVIDUAL-LEVEL VARIABLES
********************************************************************************
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_person_ids.dta", clear
merge m:1 y4_hhid   using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_household_diet.dta", nogen
merge 1:1 y4_hhid indidy4 using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_control_income.dta", nogen  keep(1 3)
merge 1:1 y4_hhid indidy4 using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_make_ag_decision.dta", nogen  keep(1 3)
merge 1:1 y4_hhid indidy4 using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_ownasset.dta", nogen  keep(1 3)
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhsize.dta", nogen keep (1 3)
merge 1:1 y4_hhid indidy4 using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_farmer_input_use.dta", nogen  keep(1 3)
merge 1:1 y4_hhid indidy4 using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_farmer_improvedseed_use.dta", nogen  keep(1 3)
merge 1:1 y4_hhid indidy4 using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_farmer_vaccine.dta", nogen  keep(1 3)
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta", nogen keep (1 3)

*land rights
merge 1:1 y4_hhid indidy4 using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_land_rights_ind.dta", nogen
recode formal_land_rights_f (.=0) if female==1		
la var formal_land_rights_f "Individual has documentation of land rights (at least one plot) - Women only"

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
foreach v of varlist *hybrid_seed*{
	replace `v' = .
}
gen female_use_inorg_fert=all_use_inorg_fert if female==1
gen male_use_inorg_fert=all_use_inorg_fert if female==0
lab var male_use_inorg_fert "1 = Individual male farmers (plot manager) uses inorganic fertilizer"
lab var female_use_inorg_fert "1 = Individual female farmers (plot manager) uses inorganic fertilizer"
gen female_imprv_seed_use=all_imprv_seed_use if female==1
gen male_imprv_seed_use=all_imprv_seed_use if female==0
lab var male_imprv_seed_use "1 = Individual male farmer (plot manager) uses improved seeds"
lab var female_imprv_seed_use "1 = Individual female farmer (plot manager) uses improved seeds"
gen female_vac_animal=all_vac_animal if female==1
gen male_vac_animal=all_vac_animal if female==0
lab var male_vac_animal "1 = Individual male farmers (livestock keeper) uses vaccines"
lab var female_vac_animal "1 = Individual female farmers (livestock keeper) uses vaccines"
*getting correct subpopulations (women aged 18 or above in rural households)
recode control_all_income make_decision_ag own_asset formal_land_rights_f (.=0) if female==1 
recode control_all_income make_decision_ag own_asset formal_land_rights_f (nonmissing=.) if female==0
* NA in TZA NPS_LSMS-ISA
gen women_diet=.
replace number_foodgroup=.

//////////Identifier Variables ////////
*Add variables and ren household id so dta file can be appended with dta files from other instruments
ren y4_hhid hhid
ren indidy4 indid
gen hhid_panel = hhid 
lab var hhid_panel "panel hh identifier" 
gen geography = "Tanzania" 
gen survey = "LSMS-ISA" 
gen year = "2014-15" 
gen instrument = 14 
capture label define instrument 11 "Tanzania NPS Wave 1" 12 "Tanzania NPS Wave 2" 13 "Tanzania NPS Wave 3" 14 "Tanzania NPS Wave 4" 15 "Tanzania NPS Wave 5" /*
	*/ 21 "Ethiopia ESS Wave 1" 22 "Ethiopia ESS Wave 2" 23 "Ethiopia ESS Wave 3" 24 "Ethiopia ESS Wave 4" 25 "Ethiopia ESS Wave 5" /*
	*/ 31 "Nigeria GHS Wave 1" 32 "Nigeria GHS Wave 2" 33 "Nigeria GHS Wave 3" 34 "Nigeria GHS Wave 4"/*
	*/ 41 "Malawi IHS/IHPS Wave 1" 42 "Malawi IHS/IHPS Wave 2" 43 "Malawi IHS/IHPS Wave 3" 44 "Malawi IHS/IHPS Wave 4" /*
    */ 51 "Uganda NPS Wave 1" 52 "Uganda NPS Wave 2" 53 "Uganda NPS Wave 3" 54 "Uganda NPS Wave 4" 55 "Uganda NPS Wave 5" /*W6 does not exist*/ 56 "Uganda NPS Wave 7" 57 "Uganda NPS Wave 8" /* 
*/ 61 "Burkina Faso EMC Wave 1" /* 
*/ 71 "Mali EACI Wave 1" 72 "Mali EACI Wave 2" /*
*/ 81 "Niger ECVMA Wave 1" 82 "Niger ECVMA Wave 2"
label values instrument instrument	

*merge in hh variable to determine ag household
preserve
use "${Tanzania_NPS_W4_final_data}/Tanzania_NPS_W4_household_variables.dta", clear
keep hhid ag_hh
tempfile ag_hh
save `ag_hh'
restore
merge m:1 hhid using `ag_hh', nogen keep (1 3)
replace   make_decision_ag =. if ag_hh==0
saveold "${Tanzania_NPS_W4_final_data}/Tanzania_NPS_W4_individual_variables.dta", replace


********************************************************************************
*PLOT -LEVEL VARIABLES
********************************************************************************
*GENDER PRODUCTIVITY GAP (PLOT LEVEL)
use "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_all_plots.dta", clear
collapse (sum) plot_value_harvest=value_harvest, by(dm_gender y4_hhid plot_id field_size)
merge 1:1 y4_hhid plot_id using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_plot_family_hired_labor.dta", keep (1 3) nogen
merge m:1 y4_hhid using "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_hhids.dta", keep (1 3) nogen //ALT 07.26.21: Note to include this in the all_plots file.
/*DYA.12.2.2020*/ gen hhid=y4_hhid
/*DYA.12.2.2020*/ merge m:1 hhid using "${Tanzania_NPS_W4_final_data}/Tanzania_NPS_W4_household_variables.dta", nogen keep (1 3) keepusing(ag_hh fhh farm_size_agland)
/*DYA.12.2.2020*/ recode farm_size_agland (.=0) 
/*DYA.12.2.2020*/ gen rural_ssp=(farm_size_agland<=4 & farm_size_agland!=0) & rural==1 
ren field_size area_meas_hectares //This variable is filled with farmer-estimated area if GPS is unavailable. Name is slightly misleading; should fix.

//keep if cultivated==1 //only cultivated plots in the main file.
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
	gen `p'_1ppp = (1+$Tanzania_NPS_W4_inflation) * `p' / $Tanzania_NPS_W4_cons_ppp_dollar 
	gen `p'_2ppp = (1+$Tanzania_NPS_W4_inflation) * `p' / $Tanzania_NPS_W4_gdp_ppp_dollar 
	gen `p'_usd = (1+$Tanzania_NPS_W4_inflation) * `p' / $Tanzania_NPS_W4_exchange_rate
	gen `p'_loc = (1+$Tanzania_NPS_W4_inflation) * `p' 
	local l`p' : var lab `p' 
	lab var `p'_1ppp "`l`p'' (2016 $ Private Consumption PPP)"
	lab var `p'_2ppp "`l`p'' (2016 $ GDP PPP)"
	lab var `p'_usd "`l`p'' (2016 $ USD)"
	lab var `p'_loc "`l`p'' (2016 TSH)"  
	lab var `p' "`l`p'' (TSH)"  
	gen w_`p'_1ppp = (1+$Tanzania_NPS_W4_inflation) * w_`p' / $Tanzania_NPS_W4_cons_ppp_dollar 
	gen w_`p'_2ppp = (1+$Tanzania_NPS_W4_inflation) * w_`p' / $Tanzania_NPS_W4_gdp_ppp_dollar 
	gen w_`p'_usd = (1+$Tanzania_NPS_W4_inflation) * w_`p' / $Tanzania_NPS_W4_exchange_rate 
	gen w_`p'_loc = (1+$Tanzania_NPS_W4_inflation) * w_`p' 
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

rename v1 TNZ_wave4 
save   "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_gendergap.dta", replace
*save   "${Tanzania_NPS_W4_created_data}/Tanzania_NPS_W4_gendergap_nowin.dta", replace
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
gen hhid_panel = hhid 
lab var hhid_panel "panel hh identifier" 
gen geography = "Tanzania" 
gen survey = "LSMS-ISA" 
gen year = "2014-15" 
gen instrument = 14 
//Only runs if label isn't already defined.
capture label define instrument 11 "Tanzania NPS Wave 1" 12 "Tanzania NPS Wave 2" 13 "Tanzania NPS Wave 3" 14 "Tanzania NPS Wave 4" 15 "Tanzania NPS Wave 5" /*
	*/ 21 "Ethiopia ESS Wave 1" 22 "Ethiopia ESS Wave 2" 23 "Ethiopia ESS Wave 3" 24 "Ethiopia ESS Wave 4" 25 "Ethiopia ESS Wave 5" /*
	*/ 31 "Nigeria GHS Wave 1" 32 "Nigeria GHS Wave 2" 33 "Nigeria GHS Wave 3" 34 "Nigeria GHS Wave 4"/*
	*/ 41 "Malawi IHS/IHPS Wave 1" 42 "Malawi IHS/IHPS Wave 2" 43 "Malawi IHS/IHPS Wave 3" 44 "Malawi IHS/IHPS Wave 4" /*
    */ 51 "Uganda NPS Wave 1" 52 "Uganda NPS Wave 2" 53 "Uganda NPS Wave 3" 54 "Uganda NPS Wave 4" 55 "Uganda NPS Wave 5" /*W6 does not exist*/ 56 "Uganda NPS Wave 7" 57 "Uganda NPS Wave 8" /* 
*/ 61 "Burkina Faso EMC Wave 1" /* 
*/ 71 "Mali EACI Wave 1" 72 "Mali EACI Wave 2" /*
*/ 81 "Niger ECVMA Wave 1" 82 "Niger ECVMA Wave 2"
label values instrument instrument	
saveold "${Tanzania_NPS_W4_final_data}/Tanzania_NPS_W4_field_plot_variables.dta", replace




********************************************************************************
*SUMMARY STATISTICS
******************************************************************************** 
/* 
All the pre-processed files include all households, individuals, and plots in the sample. 
The summary statistics are outputted only for the sub_population of households, individuals, and plots in rural areas. 
The code for outputting the summary statistics is in a separare dofile that is called here
*/ 
//Parameters
global list_instruments  "Tanzania_NPS_W4"
do "${directory}\_Summary_statistics\EPAR_UW_335_SUMMARY_STATISTICS.do" 
