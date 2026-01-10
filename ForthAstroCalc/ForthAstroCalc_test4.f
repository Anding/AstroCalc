Need Forthbase
Need ForthAstroCalc
Need simple-tester

CR CR
." AstroCalc.dll load address " AstroCalc.dll u.
.BadExterns CR

\ Provided by CoPilot
\ # Star    Date        J2000 RA	    J2000 Dec	    JNOW RA	        JNOW Dec
\ 1	Vega    2024-01-01	18h 36m 54s     +38° 47' 00"    18h 36m 27s     +38° 48' 07"
\ 2	Equator 2050-01-01	00h 00m 00s     +00° 00' 00"    00h 00m 00s     +00° 16' 46"
\ 3	Barnard 2024-01-01	17h 57m 48s	    +04° 41' 36"    17h 57m 21s     +04° 42' 50"
\ 4	Polaris 2024-01-01	02h 31m 49s	    +89° 15' 51"    03h 02m 06s     +89° 22' 11"
\ 5	Sirius  2024-01-01	06h 45m 07s	    -16° 42' 58"    06h 44m 43s     -16° 44' 04"

Tstart
T{ 18 36 54 RA 38 47 00 Dec 2024 01 01 ~ JNOW }T 18 36 27 RA 38 48 09 Dec ==
T{ 00 00 00 RA 00 00 00 Dec 2050 01 01 ~ JNOW }T 00 00 00 RA 00 16 46 Dec ==
T{ 17 57 48 RA 04 41 36 Dec 2024 01 01 ~ JNOW }T 17 57 44 RA 04 41 23 Dec ==
T{ 02 31 49 RA 89 15 51 Dec 2024 01 01 ~ JNOW }T 03 02 08 RA 89 22 11 Dec ==
T{ 06 45 07 RA -16 -42 -58 Dec 2024 01 01 ~ JNOW }T 06 44 59 RA -16 -44 -25 Dec ==


T{ 18 36 27 RA 38 48 07 Dec 2024 01 01 ~ J2000 }T 18 36 54 RA 38 46 58 Dec ==
T{ 00 00 00 RA 00 16 46 Dec 2050 01 01 ~ J2000 }T 00 00 00 RA 00 00 00 Dec ==
T{ 17 57 21 RA 04 42 50 Dec 2024 01 01 ~ J2000 }T 17 57 25 RA 04 43 04 Dec ==
T{ 03 02 06 RA 89 22 11 Dec 2024 01 01 ~ J2000 }T 02 31 48 RA 89 15 51 Dec ==
T{ 06 44 43 RA -16 -44 -04 Dec 2024 01 01 ~ J2000 }T 06 44 51 RA -16 -42 -36 Dec ==

Tend
cr