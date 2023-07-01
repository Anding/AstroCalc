\ automated test for ForthAstroCalc.f

include "e:\coding\ForthBase\FiniteFractions.f"
include "e:\coding\simple-tester\simple-tester.f"
include "e:\coding\AstroCalc\ForthAstroCalc\ForthAstroCalc.f"


CR ." Canonical date and time representations" CR
Tstart
T{ 12 30 45 ~time }T 45045 ==
T{ 45045 ~~~time }T 12 30 45 ==
T{ 2017 10 12 ~date }T 2842 ==
T{ 2842 ~~~date }T 2017 10 12 ==
T{ 2008 10 06 ~date }T -451 ==
T{ -451 ~~~date }T 2008 10 06 ==
T{ 2017 10 12 12 30 45 ~date-time }T 2842 45045 ==
T{ 2842 45045 ~~~date-time }T 2017 10 12 12 30 45 ==
T{ 1 12 30 45 ~duration }T 1 45045 ==
T{ 1 45045 ~~~duration }T 1 12 30 45 ==
T{ 1 24 30 45 ~duration }T 2 1845 ==
T{ 2 1845 ~~~duration }T 2 0 30 45 ==
T{ -1 -1 -1 -1 ~duration }T -1 -3661 ==
T{ -1 -3661 ~~~duration }T -1 -1 -1 -1 ==


CR ." Date and time arithmetic" CR
T{ 36 00 00 ~time %clock }T 1 12 00 00 ~time ==
T{ -26 00 00 ~time %clock }T -2 22 00 00 ~time ==
T{ 23 30 45 ~time 00 45 00 ~time +clock }T 00 15 45 ~time ==
T{ 00 15 45 ~time 00 45 00 ~time -clock }T 23 30 45 ~time ==

1 1 0 0 ~duration 2value OneDayOneHour
2017 10 12 12 0 0 ~date-time 2value MiddayMidOctober
T{ MiddayMidOctober OneDayOneHour +duration ~~~date-time }T 2017 10 13 13 0 0 ==
T{ MiddayMidOctober OneDayOneHour -duration ~~~date-time }T 2017 10 11 11 0 0 ==
\ +duration is not handling negative time values

CR ." Date and time conversion" CR
T{ -64 00 00 ~angle AngleToTime }T -04 -16 00 ~time ==
T{ -04 -16 00 ~time TimeToAngle }T -64 00 00 ~angle ==

0 0 0 ~time -> TimeZone
1 0 0 ~time -> DaylightSaving
T{ 0 23 30 45 ~time UTtoLT }T 1 00 30 45 ~time ==
T{ 1 00 30 45 ~time LTtoUT }T 0 23 30 45 ~time ==

8 0 0 ~time -> TimeZone
0 0 0 ~time -> DaylightSaving
T{ 0 10 00 00 ~time UTtoLT }T 0 18 00 00 ~time ==
T{ 0 18 00 00 ~time LTtoUT }T 0 10 00 00 ~time ==

64 00 00 ~angle -> Longitude
T{ 04 40 05 ~time GSTtoLST }T 00 24 05 ~time ==
T{ 00 24 05 ~time LSTtoGST }T 04 40 05 ~time ==

T{ 2012 04 01 23 30 0 ~date-time UTtoGST }T 12 12 53 ~ ==
Tend