include "%idir%\..\..\ForthBase\FiniteFractions\FiniteFractions.f"
include "%idir%\..\..\simple-tester\simple-tester.f"
include "%idir%\ForthAstroCalc.f"

 CR
." AstroCalc.dll load address " AstroCalc.dll u. CR
.BadExterns CR

 CR

variable alt
variable az

05 51 44 ~
23 13 10 ~
52 00 00 ~
alt
az
EQtoHZ_ext
alt @ ~. CR
az @ ~. CR
