\ automated test for ForthAstroCalc.f

need FiniteFractions
need simple-tester

\ Point A RA, Dec                      Point B (RA, Dec)                    Expected Separation

 05 00 00 RA +20 00 00 Dec 05 00 00 RA +20 00 00 Dec ang_sep ~. cr  
 10 12 00 RA +15 00 00 Dec 10 12 30 RA +15 00 00 Dec ang_sep ~. cr  
 12 00 00 RA -05 00 00 Dec 12 00 00 RA -04 59 59 Dec ang_sep ~. cr  
 03 00 00 RA +10 00 00 Dec 03 30 00 RA +12 00 00 Dec ang_sep ~. cr  
 18 00 00 RA +30 00 00 Dec 20 00 00 RA -10 00 00 Dec ang_sep ~. cr  
 06 00 00 RA +00 00 00 Dec 07 00 00 RA +00 00 00 Dec ang_sep ~. cr  
 02 00 00 RA +85 00 00 Dec 14 00 00 RA +85 00 00 Dec ang_sep ~. cr 
 00 00 00 RA +00 00 00 Dec 12 00 00 RA +00 00 00 Dec ang_sep ~. cr 
 04 00 00 RA +25 00 00 Dec 04 00 00 RA -25 00 00 Dec ang_sep ~. cr 
 18 36 56 RA +38 47 01 Dec 19 50 47 RA +08 52 06 Dec ang_sep ~. cr  

 0 7 15
 1 59 59                                      
 7 37 42
 49 19 26
 15 0 0
 10 0 0
 180 0 0
 50 0 0
 34 11 45
