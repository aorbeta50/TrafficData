global datadir C:\Powershell\Traffic\Traffic20170703

//cd "C:\Powershell\Traffic\Traffic20170703"
cd $datadir

// south bound
import delim using $datadir\C5\C5_SB_20170703.csv, clear varn(1) //(11 vars, 32,692 obs)
g route="sb"
/*
g seq1=.
replace seq1=0 if origin=="Mindanao Avenue, Novaliches, Quezon City, Metro Manila, Philippines"
replace seq1=1 if origin=="12 Congressional Ave, Project 8, Quezon City, 1106 Metro Manila, Philippines"
replace seq1=2 if origin=="C-5, Quezon City, Metro Manila, Philippines"
replace seq1=2 if origin=="Congressional Ave Ext, Quezon City, Metro Manila, Philippines"
replace seq1=3 if origin=="287 Katipunan Ave, Project 4, Quezon City, Metro Manila, Philippines"
replace seq1=3 if origin=="1102, 287 Katipunan Ave, Quezon City, 1108 Metro Manila, Philippines"
replace seq1=3 if origin=="CCA Building, 287 Katipunan Ave, Quezon City, 1108 Metro Manila, Philippines"
replace seq1=3 if origin=="287 Katipunan Ave, Quezon City, 1108 Metro Manila, Philippines"
replace seq1=4 if origin=="C-5, Bagumbayan, Quezon City, Metro Manila, Philippines"
replace seq1=4 if origin=="Eulogio Rodriguez Jr. Ave, Bagumbayan, Quezon City, Metro Manila, Philippines"
replace seq1=5 if origin=="C-5 E. Rodriguez Jr. corner Atis St. Brgy. Ugong, Pasig, Metro Manila, Philippines"
replace seq1=6 if origin=="C-5, Taguig, Metro Manila, Philippines"
replace seq1=6 if origin=="Upper McKinley Rd, Taguig, Metro Manila, Philippines"
replace seq1=6 if origin=="McKinley Hill Exit, Taguig, Metro Manila, Philippines"
replace seq1=6 if origin=="Campus Avenue, Taguig, 1630 Metro Manila, Philippines"
*/
// wrong origins
drop if distance>10000
cap save c5_sb_20170703, replace

// north bound
import delim using $datadir\C5\C5_NB_20170703.csv, clear varn(1) //(11 vars, 32,689 obs)
g route="nb"
/*
g seq1=.
replace seq1=0 if origin=="C-5, Taguig, Metro Manila, Philippines"
replace seq1=0 if origin=="C-5, Taguig, 1630 Metro Manila, Philippines"
replace seq1=0 if origin=="E Service Rd, Taguig, 1630 Metro Manila, Philippines"
replace seq1=0 if origin=="AFP-RSBS Industrial Park, Km12 East Service Rd. corner C5, Km12 E Service Rd, Taguig, 1630 Metro Manila, Philippines"
replace seq1=0 if origin=="AFP-RSBS Compound, Km 12 East Service Road Corner C5 South Superhighway, Bicutan, Taguig, 1631 Metro Manila, Philippines"
replace seq1=1 if origin=="1634, C5 Road Logcom, Barangay Ususan, Taguig, Metro Manila, Philippines"
//replace seq1=1 if origin=="Epifanio de los Santos Ave, Makati, Metro Manila, Philippines"
replace seq1=2 if origin=="R-5, Pasig, Metro Manila, Philippines"
replace seq1=2 if origin=="Eulogio Rodriguez Jr. Ave, Pasig, Metro Manila, Philippines"
replace seq1=2 if origin=="C-5, Pasig, Metro Manila, Philippines"
//replace seq1=2 if origin=="EDSA, corner Shaw Boulevard, Mandaluyong, 1550 Metro Manila, Philippines"
//replace seq1=2 if origin=="Epifanio de los Santos Ave, Ortigas Center, Mandaluyong, Metro Manila, Philippines"
replace seq1=3 if origin=="Eulogio Rodriguez Jr. Ave, Bagumbayan, Quezon City, Metro Manila, Philippines"
//replace seq1=3 if origin=="Epifanio de los Santos Ave, Bago Bantay, Quezon City, Metro Manila, Philippines"
replace seq1=4 if origin=="C-5, Quezon City, Metro Manila, Philippines"
replace seq1=4 if origin=="Katipunan Ave, Quezon City, Metro Manila, Philippines"
replace seq1=4 if origin=="President Carlos P. Garcia Ave, Quezon City, Metro Manila, Philippines"
replace seq1=4 if origin=="Father Masterson Dr, Quezon City, Metro Manila, Philippines"
replace seq1=5 if origin=="C-5, Quezon City, Metro Manila, Philippines"
replace seq1=5 if origin=="Congressional Ave Ext, Quezon City, Metro Manila, Philippines"
replace seq1=6 if origin=="Congressional Ave, Project 8, Quezon City, Metro Manila, Philippines"
*/

cap save c5_nb_20170703, replace
