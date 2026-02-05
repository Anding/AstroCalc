\ automated test for ForthAstroCalc.f

need simple-tester

include "%idir%\ForthAstroCalc.f"

CR CR
." AstroCalc.dll load address " AstroCalc.dll u. CR
.BadExterns
 CR

CR ." Canonical date and time representations" CR
Tstart
T{ 12 30 45 ~ }T 45045 ==
T{ 45045 ~~~ }T 12 30 45 ==
T{ 2017 10 12 EpochDays }T 2842 ==
T{ 2842 fromEpochDays }T 2017 10 12 ==
T{ 2008 10 06 EpochDays }T -451 ==
T{ -451 fromEpochDays }T 2008 10 06 ==
T{ 1 12 30 45 TimeSpan }T 131445 ==
T{ 131445 fromTimeSpan }T 1 12 30 45 ==
T{ 1 24 30 45 TimeSpan }T 174645 ==
T{ 174645 fromTimeSpan }T 2 0 30 45 ==
T{ -1 -1 -1 -1 TimeSpan }T -90061 ==
T{ -90061 fromTimeSpan }T -1 -1 -1 -1 ==
T{ 2017 10 12 12 30 45 EpochTime }T 245593845 ==
T{ 245593845 fromEpochTime }T 2017 10 12 12 30 45 ==

CR ." Date and time arithmetic" CR
T{ 36 00 00 ~ %clock }T 12 00 00 ~ ==
T{ -26 00 00 ~ %clock }T 22 00 00 ~ ==
T{ 23 30 45 ~ 00 45 00 ~ + %clock }T 00 15 45 ~ ==
T{ 00 15 45 ~ 00 45 00 ~ - %clock }T 23 30 45 ~ ==

1 1 0 0 TimeSpan value OneDayOneHour
-1 -1 0 0 TimeSpan value MinusOneDayOneHour
2017 10 12 12 0 0 EpochTime value MiddayMidOctober
T{ MiddayMidOctober OneDayOneHour + fromEpochTime }T 2017 10 13 13 0 0 ==
T{ MiddayMidOctober OneDayOneHour - fromEpochTime }T 2017 10 11 11 0 0 ==
T{ MiddayMidOctober MinusOneDayOneHour + fromEpochTime }T 2017 10 11 11 0 0 ==

CR ." Date and time conversion" CR

0 0 0 ~ -> TimeZone
1 0 0 ~ -> DaylightSaving

T{ 2026 01 30 23 30 45 EpochTime UTtoLT }T 2026 01 31 00 30 45 EpochTime ==
T{ 2026 01 31 00 30 45 EpochTime LTtoUT }T 2026 01 30 23 30 45 EpochTime ==

8 0 0 ~ -> TimeZone
0 0 0 ~ -> DaylightSaving
T{ 2026 01 30 10 00 00 EpochTime UTtoLT }T 2026 01 30 18 00 00 EpochTime  ==
T{ 2026 01 30 18 00 00 EpochTime LTtoUT }T 2026 01 30 10 00 00 EpochTime  ==

64 00 00 ~ -> Longitude
T{ 04 40 05 ~ GSTtoLST }T 00 24 05 ~ ==
T{ 00 24 05 ~ LSTtoGST }T 04 40 05 ~ ==

T{ 1980 04 22 ~ 14 36 52 ~ UTtoGST }T 04 40 06 ~ ==
T{ 1980 04 22 ~ 04 40 05 ~ GSTtoUT }T 14 36 51 ~ ==

CR ." Coordinate conversion" CR

variable alt_i
variable az_i
T{ 05 51 44 ~ 23 13 10 ~ 52 00 00 ~ alt_i az_i EQtoHZ_ext alt_i @ az_i @ }T 19 20 04 ~ 283 16 16 ~ ==
52 00 00 ~ -> Latitude
T{ 05 51 44 ~ 23 13 10 ~ EQtoHZ }T 19 20 04 ~ 283 16 16 ~ ==
T{ 19 20 04 ~ 283 16 16 ~ HZtoEQ }T 05 51 44 ~ 23 13 10 ~ ==
CR 
Tend