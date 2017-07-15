//cd "C:\Powershell\Traffic\PQN"
cd "C:\Powershell\Traffic\Traffic20170615"
//use F:\Traffic20170420\EDSA\v20170420\stata\all_traffic_EDSA_v5, clear
//use C:\Powershell\Traffic\PQN\stata\all_traffic_pqn, clear  // merged v4 & v5 data
use edsa_nb_20170615.dta, clear 
// added seq  
append using edsa_sb_20170615
// added seq
egen route_seq=group(route seq)
lab def ROUTE_SEQ ///
 1 "Globe Rotunda, Pasay" ///
 2 "BGC Bus EDSA Ayala Terminal, Makati" ///
 3 "Shaw Boulevard, Mandaluyong" ///
 4 "EDSA, Cubao, QC" ///
 5 "EDSA, Bago Bantay, Quezon City" ///
 6 "Monumento Cir, Caloocan" ///
 7 "North Avenue, Quezon City" ///
 8 "Cubao, Quezon City" ///
 9 "Shaw Boulevard, Mandaluyong" ///
 10 "Ayala Center Station, Makati"
lab val route_seq ROUTE_SEQ
 
// duration in seconds
// distance in meters
// date YYYYMMDD-HH-MM-SS

// date conversions
g double date_n=clock(date,"YMDhms") // to numeric date (must always be generated as double)
format date_n %tc // datetime format
g double date_n1=clock(date,"YMDhm#") // ignore seconds
format date_n1 %tc
g date_s=string(date_n,"%16.0g") // in string format

// into minutes
//g duration_min=duration/60
//g duration_in_traffic_min=duration_in_traffic/60

// speed, meters per min ; convert into km per hour
//g speed=(distance/1000)/(duration_min/60) 
//g speed_in_traffic=(distance/1000)/(duration_in_traffic_min/60) 
g speed=(distance/1000)/(duration/3600) 
g speed_in_traffic=(distance/1000)/(duration_in_traffic/3600) 

g hour=hh(date_n)

g dow=dow(dofc(date_n)) //day of the week , dofc days since 1Jan1960 00.00.00.000
lab def DOW 0 "Sunday" 1 "Monday" 2 "Tuesday" 3 "Wednesday" 4 "Thursday" 5 "Friday"  6 "Saturday"
lab val dow DOW
g day=day(dofc(date_n)) //day of the month

pause on

// ENTIRE ROUTE
// Duration and Speed by date-time
preserve
//collapse (sum) duration_min duration_in_traffic_min speed speed_in_traffic, by(route date_n)
collapse (sum) duration duration_in_traffic distance seq, by(route date_n) // sum the entire route
// pause press q or end to continue
//keep if seq==78 // keep only if sequence is complete 12 legs, some skips legs
g speed=(distance/1000)/(duration/3600)
g speed_in_traffic=(distance/1000)/(duration_in_traffic/3600)
bys route: summ
pause (check data)
su duration_in_traffic
loc ymin=`r(min)'
loc ymax=`r(max)'
qui su date_n
loc xmin=`r(min)'
loc xmax=`r(max)'
twoway line duration duration_in_traffic date_n, by(route /*, cols(1)*/) xlabel(`xmin'(172800000)`xmax',angle(45) labsize(small) format(%tcDay,dd_Mon_CCYY)) ///
   ylabel(`ymin'(20)`ymax',labsize(small) format(%5.0fc)) ytitle("Minutes") xtitle("Date") title("Duration, P-Q-N") ///
   legend(label(1 "Duration") lab(2 "Duration-in-traffic"))
pause press q or end to continue
qui su speed_in_traffic
loc ymin=`r(min)'
loc ymax=`r(max)'
qui su date_n
loc xmin=`r(min)'
loc xmax=`r(max)'
twoway (line speed date_n) (line speed_in_traffic date_n), by(route, cols(1)) xlabel(`xmin'(172800000)`xmax',angle(45) labsize(small) format(%tcDay,dd_Mon_CCYY)) ///
   ylabel(`ymin'(10)`ymax' ,labsize(small) format(%5.0fc)) ytitle("KM per hour") xtitle("Date") title("Speed,P-Q-N, km/hr") ///
   legend(label(1 "Speed") lab(2 "Speed-in-traffic"))
restore

// NOTE: two days in milliseconds is 172800000=1000*60*60*24*2

// by day of the week 
preserve
collapse (sum) duration duration_in_traffic distance, by(route date_n)
g dow=dow(dofc(date_n)) //day of the week , dofc days since 1Jan1960 00.00.00.000
//lab def DOW 0 "Sunday" 1 "Monday" 2 "Tuesday" 3 "Wednesday" 4 "Thursday" 5 "Friday"  6 "Saturday"
lab val dow DOW
collapse (mean) duration duration_in_traffic distance (sd) duration_in_traffic_sd=duration_in_traffic, by(route dow)
g speed=(distance/1000)/(duration/3600)
g speed_in_traffic=(distance/1000)/(duration_in_traffic/3600)
g u_duration_in_traffic=duration_in_traffic+duration_in_traffic_sd
g l_duration_in_traffic=duration_in_traffic-duration_in_traffic_sd
g u_speed_in_traffic=(distance/1000)/(l_duration_in_traffic/3600)
g l_speed_in_traffic=(distance/1000)/(u_duration_in_traffic/3600)
summ
// pause press q or end to continue
pause
qui su u_duration_in_traffic
loc ymax=`r(max)'
qui su l_duration_in_traffic
loc ymin=`r(min)'
//twoway connected duration_min duration_in_traffic_min dow, by(route) xlabel(0(1)6 ,angle(45) labsize(small) valuelabel) ///
twoway line u_duration_in_traffic duration_in_traffic l_duration_in_traffic dow, by(route) xlabel(0(1)6 ,angle(45) labsize(small) valuelabel) ///
  ylabel(`ymin'(20)`ymax' ,labsize(small) format(%5.0f)) xtitle("Day of the Week") ytitle("Minutes") title("Duration in traffic") ///
  legend(label(1 "Upper") lab(2 "Mean") lab(3 "Lower"))
pause press q or end to continue
qui su u_speed_in_traffic
loc ymax=`r(max)'
qui su l_speed_in_traffic
loc ymin=`r(min)'
//twoway connected /* speed */ speed_in_traffic dow, by(route) xlabel(0(1)6 ,angle(45) labsize(small) valuelabel) ///
twoway line u_speed_in_traffic speed_in_traffic l_speed_in_traffic dow, by(route) xlabel(0(1)6 ,angle(45) labsize(small) valuelabel) ///
  ylabel(`ymin'(10)`ymax' ,labsize(small) format(%5.0fc)) xtitle("Day of the Week") ytitle("Meters per minute") title("Speed in traffic") ///
  legend(label(1 "Upper") lab(2 "Mean") lab(3 "Lower"))
restore

// speed in traffic by segment, requires seq; change route_seq numbers 
preserve
collapse (mean) duration duration_in_traffic distance, by(route_seq date_n)
collapse (mean) duration duration_in_traffic distance (sd) duration_in_traffic_sd=duration_in_traffic, by(route_seq)
lab val route_seq ROUTE_SEQ // value labels is lost in collapse 
g speed=(distance/1000)/(duration/3600)
g speed_in_traffic=(distance/1000)/(duration_in_traffic/3600)
g u_duration_in_traffic=duration_in_traffic+duration_in_traffic_sd
g l_duration_in_traffic=duration_in_traffic-duration_in_traffic_sd
g u_speed_in_traffic=(distance/1000)/(l_duration_in_traffic/3600)
g l_speed_in_traffic=(distance/1000)/(u_duration_in_traffic/3600)
summ
pause (check data)
// pause press q or end to continue
// NOTE: duration not very meaningfull because distance is different 
// summ duration_in_traffic_min_mean
// twoway connected /*duration_min*/ duration_in_traffic_min_mean seq, by(route) xlabel(1(2)12,angle(45) labsize(small) valuelabel) ylabel(/*`r(min)'(100)`r(max)'*/,labsize(small) format(%5.0f))
// pause press q or end to continue
qui su u_speed_in_traffic
loc ymax=`r(max)'
qui su l_speed_in_traffic
loc ymin=`r(min)'
twoway (line u_speed_in_traffic speed_in_traffic l_speed_in_traffic route_seq if inrange(route_seq, 1,5) /*, ///
           xlabel( 1(1)12,angle(45) labsize(small) valuelabel)*/ ) ///
       (line u_speed_in_traffic speed_in_traffic l_speed_in_traffic route_seq if inrange(route_seq,6,10) /*, /// 
	       xlabel(13(1)24,angle(45) labsize(small) valuelabel)*/ ), ///
       ylabel(`ymin'(10)`ymax' ,labsize(small) format(%5.0f)) xtitle("Sequence") ytitle("KM per hour") title("Speed in traffic") ///
	   xlabel(1(1)10,angle(45) labsize(vsmall) valuelabel) ///
       legend(lab(1 "Upper,NB") lab(2 "Mean,NB") lab(3 "Lower,NB") lab(4 "Upper,SB") lab(5 "Mean,SB") lab(6 "Lower,SB")) 
//pause press q or end to continue (check data)
restore


// whole route by the hour
// count number of route hours combination
preserve
collapse (sum) duration duration_in_traffic distance, by(route date_n) // sums by route by date
g hour=hh(date_n)
// pause
collapse (mean) duration duration_in_traffic distance (sd) duration_in_traffic_sd=duration_in_traffic, by(route hour) // computes the average per route by hour
g speed=(distance/1000)/(duration/3600)
g speed_in_traffic=(distance/1000)/(duration_in_traffic/3600)
g u_duration_in_traffic=duration_in_traffic+duration_in_traffic_sd
g l_duration_in_traffic=duration_in_traffic-duration_in_traffic_sd
g u_speed_in_traffic=(distance/1000)/(l_duration_in_traffic/3600)
g l_speed_in_traffic=(distance/1000)/(u_duration_in_traffic/3600)
bys route: summ
pause (check data)
// pause press q or end to continue
// there is problem with duration because this involves repetition of several observations for the route
// solved by doing collapse twice
// with 1SD confidence band
qui su u_duration_in_traffic
loc ymax=`r(max)'
qui su l_duration_in_traffic
loc ymin=`r(min)'
twoway line u_duration_in_traffic duration_in_traffic l_duration_in_traffic hour, by(route) xlabel(0(2)24,angle(45) labsize(small)) ///
   ylabel(`ymin'(20)`ymax',labsize(small) format(%5.0f)) ///
   ytitle("Minutes") title("Duration in PQN by hour") legend(lab(1 "Upper") lab(2 "Mean") lab(3 "Lower"))
pause press q or end to continue
qui su u_speed_in_traffic
loc ymax=`r(max)'
qui su l_speed_in_traffic
loc ymin=`r(min)'
twoway line u_speed_in_traffic speed_in_traffic l_speed_in_traffic hour, by(route) xlabel(0(2)24,angle(45) labsize(small)) ///
  ylabel(`ymin'(5)`ymax',labsize(small) format(%5.0f) ) ///
  ytitle("KM per hour") title("Speed in PQN by hour") legend(lab(1 "Upper") lab(2 "Mean") lab(3 "Lower"))
restore




/*
bys date: egen tot_nb_distance=total(distance) if route=="nb"
bys date: egen tot_sb_distance=total(distance) if route=="sb"
 
bys date: egen tot_nb_duration_min=total(duration_min) if route=="nb"
bys date: egen tot_sb_duration_min=total(duration_min) if route=="sb"

bys date: egen tot_nb_duration_in_traffic_min=total(duration_in_traffic_min) if route=="nb"
bys date: egen tot_sb_duration_in_traffic_min=total(duration_in_traffic_min) if route=="sb"

g speed_nb=tot_nb_distance/tot_nb_duration_min
g speed_in_traffic_nb=tot_nb_distance/tot_nb_duration_min
g speed_sb=tot_sb_distance/tot_sb_duration_min
g speed_in_traffic_sb=tot_sb_distance/tot_sb_duration_min
*/

/*
// BY SEQUENCE
// BY DATE
preserve
// DURATION
collapse (mean) duration_min duration_in_traffic_min speed speed_in_traffic, by(route seq date_n)
// pause press q or end to continue
//nb
twoway connected duration_min duration_in_traffic_min date_n if route=="nb", by(seq) xlabel(,angle(45) labsize(small)) ylabel( ,labsize(small))
pause press q or end to continue
// sb
twoway connected duration_min duration_in_traffic_min date_n if route=="sb", by(seq) xlabel(,angle(45) labsize(small)) ylabel( ,labsize(small))
pause press q or end to continue
// SPEED
// nb
twoway connected /* speed */ speed_in_traffic date_n if route=="nb", by(seq) xlabel(,angle(45) labsize(small)) ylabel( ,labsize(small))
pause press q or end to continue
// sb
twoway connected /* speed */ speed_in_traffic date_n if route=="sb", by(seq) xlabel(,angle(45) labsize(small)) ylabel( ,labsize(small))
restore

// BY HOUR
preserve
// DURATION
collapse (mean) duration_min duration_in_traffic_min speed speed_in_traffic, by(route seq hour)
// pause press q or end to continue
//nb
twoway connected duration_min duration_in_traffic_min hour if route=="nb", by(seq) xlabel(,angle(45) labsize(small)) xscale(range(0 24)) ylabel( ,labsize(small))
pause press q or end to continue
// sb
twoway connected duration_min duration_in_traffic_min hour if route=="sb", by(seq) xlabel(,angle(45) labsize(small)) xscale(range(0 24)) ylabel( ,labsize(small))
pause press q or end to continue
// SPEED
// nb
twoway connected /* speed */ speed_in_traffic hour if route=="nb", by(seq) xlabel(,angle(45) labsize(small)) xscale(range(0 24)) ylabel( ,labsize(small))
pause press q or end to continue
// sb
twoway connected /* speed */ speed_in_traffic hour if route=="sb", by(seq) xlabel(,angle(45) labsize(small)) xscale(range(0 24)) ylabel( ,labsize(small))
restore
*/

/*
// NB
twoway connected tot_nb_duration_min tot_nb_duration_in_traffic_min date_n if route=="nb"
twoway connected speed_nb speed_in_traffic_nb date_n if route=="nb"
// all four destinations from makati
// duration
twoway connected tot_nb_duration_min tot_nb_duration_in_traffic_min date_n, xlabel(,angle(45) labsize(small)) ylabel( ,labsize(small))
twoway connected tot_sb_duration_min tot_sb_duration_in_traffic_min date_n, xlabel(,angle(45) labsize(small)) ylabel( ,labsize(small))
//twoway connected tot_sb_duration_min tot_sb_duration_in_traffic_min date_n, by(route) xlabel(,angle(45) labsize(small)) ylabel( ,labsize(small))

// speed
twoway connected speed speed_in_traffic date_n, by(destination) xlabel(,angle(45) labsize(small)) ylabel( ,labsize(small))
// table
table destination, c(mean speed sd speed mean speed_in_traffic sd speed_in_traffic)
*/

/*
// averaging by hour
g hour=hh(date_n)
preserve
collapse (mean) duration_min duration_in_traffic_min speed speed_in_traffic, by(route seq hour)
//table destination hour, c(mean duration_min mean duration_in_traffic_min mean speed mean speed_in_traffic)
// duration
twoway connected duration_min duration_in_traffic_min hour, by(destination) /* xlabel(,angle(45) labsize(small)) */ xscale(range(0 24)) ylabel( ,labsize(small))
pause press q or end to continue
// speed
twoway connected speed_in_traffic hour, by(destination) /*xlabel(,angle(45) labsize(small))*/ xscale(range(0 24)) ylabel( ,labsize(small))
//twoway connected speed speed_in_traffic hour, by(destination) /*xlabel(,angle(45) labsize(small))*/ xscale(range(0 24)) ylabel( ,labsize(small))
restore 

*/
