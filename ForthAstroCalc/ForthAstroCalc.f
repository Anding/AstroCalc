\ Astronomical calculations for telescope control, based on Duffett-Smith and Zwart, "Practical Astronomy"
\ Requires ForthBase/FiniteFractions.f

LIBRARY: AstroCalc.dll

Extern: int "C" version( ) ;
Extern: int "C" days_since_epoch ( int yymmdd) ;
Extern: int "C" date_after_epoch ( int days) ;

 CR
." AstroCalc.dll load address " AstroCalc.dll u. CR
.BadExterns CR