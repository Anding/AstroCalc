\ automated test for ForthAstroCalc.f

need FiniteFractions
need simple-tester 
include E:\coding\AstroCalc\ForthAstroCalc\ForthAstroCalc.f

CR
Tstart
T{ 05 00 00 RA +20 00 00 Dec 05 00 00 RA +20 00 00 Dec ang_sep }T 00 00 00  ~ ==     
T{ 10 12 00 RA +15 00 00 Dec 10 12 30 RA +15 00 00 Dec ang_sep }T 00 07 15  ~ ==     
T{ 12 00 00 RA -05 00 00 Dec 12 00 00 RA -04 59 59 Dec ang_sep }T 01 59 59  ~ ==    
T{ 03 00 00 RA +10 00 00 Dec 03 30 00 RA +12 00 00 Dec ang_sep }T 07 37 42  ~ ==    
T{ 18 00 00 RA +30 00 00 Dec 20 00 00 RA -10 00 00 Dec ang_sep }T 49 19 26  ~ ==     
T{ 06 00 00 RA +00 00 00 Dec 07 00 00 RA +00 00 00 Dec ang_sep }T 15 00 00  ~ ==    
T{ 02 00 00 RA +85 00 00 Dec 14 00 00 RA +85 00 00 Dec ang_sep }T 10 00 00  ~ ==    
T{ 00 00 00 RA +00 00 00 Dec 12 00 00 RA +00 00 00 Dec ang_sep }T 180 00 00 ~ ==   
T{ 04 00 00 RA +25 00 00 Dec 04 00 00 RA -25 00 00 Dec ang_sep }T 50 00 00  ~ ==  
T{ 18 36 56 RA +38 47 01 Dec 19 50 47 RA +08 52 06 Dec ang_sep }T 34 11 45  ~ ==
CR
Tend