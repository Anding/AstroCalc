\ automated test for ForthAstroCalc.f

include "e:\coding\ForthBase\FiniteFractions.f"
include "e:\coding\simple-tester\simple-tester.f"
include "e:\coding\AstroCalc\ForthAstroCalc\ForthAstroCalc.f"

CR
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

1 1 0 0 ~duration 2value OneDayOneHour
2017 10 12 12 0 0 ~date-time 2value MiddayMidOctober
T{ MiddayMidOctober OneDayOneHour +duration ~~~date-time }T 2017 10 13 13 0 0 ==
T{ MiddayMidOctober OneDayOneHour -duration ~~~date-time }T 2017 10 11 11 0 0 ==

T{ 2012 04 01 23 30 0 ~date-time UTtoGST }T 12 12 53 ~ ==
Tend