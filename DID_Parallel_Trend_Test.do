//Import the file (!!!!!!you need to replace it with your asset path!!!!!!!!!!).
import delimited "F:\Onedrive映射\1kcl\ESG\7QQMM906 Environmental Economics\Group Assessment\Raw Data\NO2_Meteo_ALL_Data_2022-2024.csv"

/*===============Set variables==========*/

//Treat
gen Inner_ULEZ=1 if region=="Inner"
drop Inner_ULEZ 
gen treatment=1 if region=="Inner"
replace treatment=0 if treatment==.

//numeric date
gen date_numeric = date(date, "YMD") if !missing(date)
format date_numeric %td
drop date
rename date_numeric date

//Post
gen post=0
replace post=1 if date >= date("2023-08-29", "YMD")

//Interation term
gen treatment_post= treatment*post

//ln_NO2
gen ln_NO2= ln(no2) if no2>0
drop ln_NO2 
gen ln_NO2= ln(no2)

//Sitenum
encode sitecode, generate(sitenum)

//In_cloud
gen ln_cloudfraction=ln(cloudfraction)
drop if cloudfraction==.
drop if ln_cloudfraction ==.

//Is holiday?
gen is_holiday = 0
replace is_holiday = 1 if date == date("2023-01-02", "YMD") |date == date("2023-04-10", "YMD") | date == date("2023-05-01", "YMD") |date == date("2023-05-08", "YMD") | date == date("2023-05-29", "YMD") |date == date("2023-08-28", "YMD") |date == date("2023-12-25", "YMD") |date == date("2023-12-26", "YMD")

replace is_holiday = 1 if date == date("2024-01-01", "YMD") |date == date("2024-03-29", "YMD") |date == date("2024-04-01", "YMD") |date == date("2024-05-06", "YMD") |date == date("2024-05-27", "YMD") |date == date("2024-08-26", "YMD") |date == date("2024-12-25", "YMD") |date == date("2024-12-26", "YMD")

 replace is_holiday = 1 if date == date("2022-08-29", "YMD") |date == date("2022-09-19", "YMD") |date == date("2022-12-26", "YMD") |date == date("2022-12-27", "YMD")
 
label variable is_holiday "UK Bank Holiday (0=No, 1=Yes)"

//Time dummy
gen year = year(date)
gen month = month(date)
gen dow = dow(date)
reghdfe ln_NO2 treatment_post temp windspeed winddirection pressure rh precipitation ln_cloudfraction is_holiday ,absorb(sitenum dow month) vce(cluster sitenum)

/*======================Data Cleaning==========================*/
//Winsor
ssc install winsor2
winsor2 ln_NO2 temp windspeed winddirection pressure rh precipitation ln_cloudfraction, cuts(1 99) replace

//Drop
drop if missing(ln_NO2)|missing(temperature)|missing(windspeed)|missing(winddirection)|missing(pressure)|missing(rh)|missing(precipitation)|missing(ln_cloudfraction)

/*======================Regression analysis===================*/
//Penal 
xtset sitenum date

//Regression result
reghdfe ln_NO2 treatment_post temp windspeed winddirection pressure rh precipitation ln_cloudfraction is_holiday ,absorb(sitenum dow month) vce(cluster sitenum)

/*====================Descriptive statistics=================*/
/*tabstat ln_NO2 treatment post treatment_post cloudfraction temperature windspeed winddirection pressure rh precipitation ln_cloudfraction is_holiday, 

//Save to a folder(!!!!!!you need to replace it with your asset path!!!!!!!!!!).
cd"F:\Onedrive映射\1kcl\ESG\7QQMM906 Environmental Economics\Group Assessment"

logout,save(mytable) word replace: tabstat ln_NO2 treatment post treatment_post cloudfraction temperature windspeed winddirection pressure rh precipitation ln_cloudfraction is_holiday, s(N mean p50 sd min max range) f(%12.3f) c(s)*/

/*============demeaned parallel trends test===============*/
//Set the conditional variable
gen judgment= ym(year(date), month(date)) - ym(2023, 9)
gen pre_1 = ( judgment < 0 & treatment  ==1)
drop pre_1
ssc install coefplot

//Variables generated 11 periods prior to policy implementation
forvalues i = 11(-1)1 {
    gen pre_`i'=(judgment ==-`i' & treatment ==1)
}

//current variable
gen current = ( judgment ==0 & treatment ==1)

//Variables in the 11 periods following the policy
forvalues i = 11(-1)1 {
    gen las_`i' = (judgment ==`i' & treatment ==1)
}

//regression analysis
reghdfe ln_NO2 treatment_post temp windspeed winddirection pressure rh precipitation ln_cloudfraction is_holiday pre_* current las_* ,absorb(sitenum dow month) vce(cluster sitenum)

//demeaned
//Install command
ssc install parmest, replace
ssc install fillmissing, replace

//Extract regression coefficients
parmest, format(estimate min95 max95 %8.3f p %8.3f) saving("temp1.dta", replace)

//Read temporary files and filter coefficients before and after the policy.
use "temp1.dta", clear
keep if ustrregexm(parm, "pre_*|las_*|current") 
drop if ustrregexm(parm, "pressure")
drop if ustrregexm(parm, "precipitation")
//Only retain the coefficients before and after the policy and during the policy period.

//Mark the current position of the policy, calculate the relative time, and id is the adjusted relative time.
gen num = _n

gen minus = num if ustrregexm(parm, "current") //Find the policy number for the current period
fillmissing minus //Fill in the current period number to all rows
gen id = num - minus

//Core: Calculate the mean of the coefficients before the policy, and subtract the mean from all coefficients.
egen average =mean(estimate)if id<0 //Only the mean coefficient before the policy was implemented (id<0) was calculated.

fillmissing average // Fill all rows with the mean (adjust using the same mean after the policy is implemented).
replace estimate=estimate-average //Subtract the pre-policy average from each coefficient to complete the adjustment.

//Step4-Recalculate the confidence intervals and plot the trend of "meeting the criteria".

*1. Recalculate the confidence interval (ul = upper limit, 11 = lower limit)
gen ul=estimate+stderr*1.65 //Upper limit of 90% confidence interval
gen ll=estimate-stderr*1.65 //90% confidence interval lower limit 

*2. Base period (1 period before the policy, id=-1) is set to 0 (base period effect is 0 when plotting).
for var estimate ul ll:replace X=0 if mi(estimate)& id == -1

*3.Draw a parallel trend chart (use the two command to combine the coefficient line and the confidence interval line).
sort id
twoway (rcap ul ll id, lcolor(gs12) lwidth(medthin)) ///
       (connected estimate id, msymbol(O) msize(medium) ///
        mcolor(black) lcolor(black) lwidth(medthick)), ///
       yline(0, lp(dash) lc(gs10)) ///
       xline(-0.5, lp(dash) lc(gs10)) ///
       xlabel(-11(1)12, nogrid labsize(small)) ///
       ylabel(, nogrid format(%4.2f) labsize(small)) ///
       xtitle("Relative Time (Treatment Period = 0)", size(medium)) ///
       ytitle("Adjusted Treatment Effect", size(medium)) ///
       legend(off) graphregion(color(white))

/*=============================Placebo Test===================================*/
use "data_after_cleaning.dta", clear
reghdfe ln_NO2 treatment_post temp windspeed winddirection pressure rh precipitation ln_cloudfraction is_holiday, absorb(sitenum dow month) vce(cluster sitenum)
estimates store main_did

//ssc install permute
//help permute
 
permute treatment_post beta=_b[treatment_post] se=_se[treatment_post] df=e(df_r), reps(588) seed(1008) saving("stimulations.dta"): reghdfe ln_NO2 treatment_post temp windspeed winddirection pressure rh precipitation ln_cloudfraction is_holiday, absorb(sitenum dow month ) vce(cluster sitenum)

use "stimulations.dta", clear

ssc install dpplot
/*#delimit ;
dpplot beta, xline(-0.0961978, lc(black*0.5) lp(dash))
             xline(0, lc(black*0.5) lp(solid))
             xtitle("Estimator", size(*0.8)) 
             xlabel(-0.1(0.02)0.1, format(%5.3f) labsize(small))
             ytitle("Density", size(*0.8)) 
             ylabel(, nogrid format(%3.0f) labsize(small)) 
             note("") caption("") 
             graphregion(fcolor(white)) ;
#delimit cr
graph export "Placebo Test.png", width(1000) replace

#delimit ;*/

#delimit ;

dpplot beta, 
  
    xline(-0.0961978, lcolor(cranberry) lpattern(dash) lwidth(medthick))
    xline(0, lcolor(gs6) lpattern(solid) lwidth(medium))
    
 
    color(navy%50) recast(area)
    lcolor(navy) lwidth(medium)
    

    xtitle("2×2 DD Estimate", size(small))
    xlabel(-0.10(0.02)0.10, format(%4.2f) labsize(vsmall))
    

    ytitle("Density", size(small))
    ylabel(0(50)150, format(%3.0f) labsize(vsmall) angle(horizontal) nogrid)
    

    legend(order(1 "Placebo estimates" 
                 2 "True effect (β̂=-0.096)" 
                 3 "Null (β=0)")
           position(2) ring(0) cols(1) size(vsmall)
           region(lcolor(gs12) fcolor(white%90) lwidth(vthin))
           symxsize(*.6) rowgap(*.5))
    

    note("Notes: Dashed line shows actual treatment effect; solid line indicates null hypothesis.",size(vsmall))

    graphregion(color(white) margin(small))
    plotregion(lcolor(black) lwidth(thin) margin(small))
    
    scheme(s1mono) ;

#delimit cr

graph export "placebo_paper.png", replace width(2400) height(1800)
graph export "placebo_paper.eps", replace


// Export
graph export "permutation_test.png", replace width(3000)
graph export "permutation_test.eps", replace
graph export "permutation_test.pdf", replace

//=========================Regression by sitetype=============================//
//merge datasets
merge m:1 sitecode using "sitetype_sitename.dta"

save "F:\Onedrive映射\1kcl\ESG\7QQMM906 Environmental Economics\Group Assessment\data after cleaning\data_after_cleaning.dta", replace

use "F:\Onedrive映射\1kcl\ESG\7QQMM906 Environmental Economics\Group Assessment\data after cleaning\data_after_cleaning.dta", replace
encode sitetype, generate(siteype_num)

tab siteype_num

use "F:\Onedrive映射\1kcl\ESG\7QQMM906 Environmental Economics\Group Assessment\data after cleaning\data_after_cleaning.dta", clear


* 1.Main DID
reghdfe ln_NO2 treatment_post temperature windspeed winddirection pressure rh precipitation ln_cloudfraction is_holiday, absorb(sitenum dow month) vce(cluster sitenum)
estimates store main_did

* 2. Heterogeneity by Site Type
foreach type in "Roadside" "Urban Background" "Kerbside" "Suburban" "Industrial" {
    quietly reghdfe ln_NO2 treatment_post temp windspeed winddirection pressure rh precipitation ln_cloudfraction is_holiday,  absorb(sitenum dow month) vce(cluster sitenum), if sitetype == "`type'"
    
    estimates store `=subinstr("`type'", " ", "_", .)'
}

* 3. Export
esttab main_did Roadside Urban_Background Kerbside Suburban Industrial ///
    using "full_regression_table1.rtf", ///
    replace rtf ///
    keep(treatment_post temperature windspeed winddirection pressure rh precipitation ln_cloudfraction ls_holiday) ///
    order(treatment_post temperature windspeed winddirection pressure rh precipitation ln_cloudfraction ls_holiday) ///
    b(4) se(4) star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("All Sites" "Roadside" "Urban BG" "Kerbside" "Suburban" "Industrial") ///
    mgroups("Main did" "Heterogeneity by Site Type", ///
            pattern(1 1 0 0 0 0) ///
            prefix(\multicolumn{@span}{c}{) suffix(}) ///
            span erepeat(\cmidrule(lr){@span})) ///
    title("Table: DID Estimates and Heterogeneity by Site Type") ///
    addnote("Standard errors clustered at site level in parentheses." ///
            "All models include site, month, and day-of-week fixed effects." ///
            "* p<0.10, ** p<0.05, *** p<0.01") ///
    stats(N r2, fmt(%9.0fc %9.3f) ///
          labels("Observations" "R-squared")) ///
    label
	  
