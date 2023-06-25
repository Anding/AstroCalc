\ Astronomical calculations based on Duffett-Smith and Zwart, "Practical Astronomy"
\ Requires ForthBase/FiniteFractions.f

\ Interface with the C language library rountines *******************************************************

LIBRARY: AstroCalc.dll
	
\ return a library version number in yymmdd format
Extern: int "C" version( ) ;

\ return the number of days since the Epoch of a calendar date
Extern: int "C" days_since_epoch ( int yymmdd) ;
\ the Epoch is a date defined in AstroCalc.dll, typically as January 0.0 of a certain year
\ yymmdd denotes calendar dates in single cell format as DD + (60 * (MM + 60 * YY)) using FiniteFractions
\ 	e.g. 2010 08 01 ~  ( 723481)
\  e.g. 7236481 ~~~ ( 2023 04 04)

\ return the calendar date ( yymmdd format) of a number of days since the Epoch
Extern: int "C" date_after_epoch ( int days) ;

\ return the GST of a given date and time at Greenwich
Extern: int "C" UTtoGST (int D, int UT) ;
\ D is the date expressed as number of days since the epoch
\ T is Ut expressed as seconds-of-the day

\ Canonical date and time representations ***************************************************************

\ convert hours, minutes and seconds to a single cell time value
: ~time ( hh mm ss -- T)
\ T = ss + ( 60 * (mm + 60 * hh)), the total number of seconds
	~
;

\ convert a single cell time value to hours minutes and seconds
: ~~~time ( T -- hh mm ss)
	~~~
;

\ convert year, month, day to a single cell date value
: ~date ( yyyy mm dd -- D)
\ D is the number of days since the Epoch of that date
	~ days_since_epoch
;

\ convert a single cell date value to year, month, day
: ~~~date ( D -- yyyy mm dd)
	date_after_epoch ~~~
;

\ convert a full calendar date and time to a two cell date-time representation
: ~date-time ( yyyy mm dd hh mm ss -- D T)
\ time (in seconds) is the top-of-stack, date (in days since the Epoch) is next-on-stack
	~time >R ~date R> 
;

\ convert a two cell date-time representation to a full calendar date and time
: ~~~date-time
	>R ~~~date R> ~~~time
;

24 0 0 ~time constant 24HOURS

\ convert a duration of days, hours, minutes and seconds to a two cell representation
: ~duration ( days hh mm ss -- D T)
\ time (in seconds) is the top-of-stack, days is next on stack
	~time				( days T)
	24HOURS /mod 	( days T +D)
	swap >R			( days +D R:T)
	+ R>				( D T)
;

\ convert a two cell duration representation to days, hours, minutes, and seconds
: ~~~duration ( D T -- days hh mm ss)
	~~~time
;


\ Date and time arithmetic *****************************************************************************	

\ add a duration to a date-time 
: +duration ( D1 T1 D2 T2 -- D3 T3)
\ D3 T3 = (D1 T1) + (D2 T2)
	rot swap				( D1 D2 T1 T2)
	+ 24HOURS /mod		( D1 D2 T3 +D)
	swap >R				( D1 D2 +D R:T3)
	+ + R>				( D3 T3)
;

\ subtract a duration from a date-time
: -duration ( D1 T1 D2 T2 -- D3 T3)
\ D3 T3 = (D1 T1) - (D2 T2)
	negate swap negate swap
	+duration
;

\ Date and time conversion *****************************************************************************

0 0 0 ~time value TimeZone
0 0 0 ~time value DaylightSaving

\ convert a local civil time to UT, using the two-cell representation
: LT-to-UT ( D T -- D T)
	DaylightSaving 0 swap -duration
	TimeZone 0 swap -duration
;

\ convert UT to a local civil time, using two-cell representation
: UT-to-LT ( D T -- D T)
	TimeZone 0 swap +duration
	DaylightSaving 0 swap +duration
;

