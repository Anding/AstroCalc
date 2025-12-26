\ Astronomical calculations based on Duffett-Smith and Zwart, "Practical Astronomy"
need FiniteFractions

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

\ Convert equatorial to horizon coordinates
Extern: void "C" EQtoHZ_ext(int H, int dec, int lat, int * alt, int * az) ;
\ alt, az, dec and lat are expressed in DEGMMSS format
\ H is expressed in integer seconds

\ Convert equatorial to horizon coordinates
Extern: void "C" HZtoEQ_ext(int alt, int az, int lat, int * H, int * dec) ;
\ alt, az, dec and lat are expressed in DEGMMSS format
\ H is expressed in integer seconds

\ Compute the angular separation between two coordinates
Extern: int "C" ang_sep(int H1, int dec1, int H2, int dec2) ;
\ dec is expressed in DEGMMSS format
\ H is expressed in integer seconds

\ Canonical date and time representations ***************************************************************

24 0 0 ~ constant 24HOURS

\ convert a time in hours, minutes and seconds to a single cell time finite fraction
: ~time ( hh mm ss -- T) ~ ;
\ T = ss + ( 60 * (mm + 60 * hh)), the total number of seconds

\ convert an angle in degrees, arcminutes, arcseconds to a single cell finite fraction
: ~angle ( deg mm ss -- D) ~ ;
\ D = ss + ( 60 * (mm + 60 * deg)), the total number of arcseconds	

\ convert an hour angle in hours, minutes and seconds to a single cell time finite fraction
: ~hourangle ( hh mm ss -- T) ~ ;
	
\ convert a single cell time finite fraction to hours minutes and seconds
: ~~~time ( T -- hh mm ss) ~~~ ;

\ convert year, month, day to a single cell date finite fraction
: ~date ( yyyy mm dd -- D)
\ D is the number of days since the Epoch of that date
	~ days_since_epoch
;

\ convert a single cell date finite fraction to year, month, day
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

\ convert a duration of days, hours, minutes and seconds to a two cell representation
: ~duration ( days hh mm ss -- D T)
\ time (in seconds) is the top-of-stack, days is next on stack
	~time				( days T)
	24HOURS /mod 	( days T +D)
	swap >R			( days +D R:T)
	+ R>				( D T)
;

\ convert a two cell duration representation to days, hours, minutes, and seconds
: ~~~duration ( D T -- days hh mm ss) ~~~time ;


\ Date and time arithmetic *****************************************************************************	

\ adjust a time to within 0 - 24h plus an increment number of days
: %clock ( T - D T)
	24HOURS /mod swap
	dup 0< if
		24HOURS +
		swap 1- swap
	then
;
	
\ add two time values and retain the result within the 24 hour clock
: +clock ( T1 T2 -- T)
	+ %clock nip
;

\ subtract a time value and retain the result within the 24 hour clock
: -clock ( T1 T2 -- T)
	negate +clock
;

\ add a duration to a date-time 
: +duration ( D1 T1 D2 T2 -- D3 T3)
\ D3 T3 = (D1 T1) + (D2 T2)
	rot swap				( D1 D2 T1 T2)
	+ %clock >R			( D1 D2 +D R:T3)
	+ + R>				( D3 T3)
;

\ subtract a duration from a date-time
: -duration ( D1 T1 D2 T2 -- D3 T3)
\ D3 T3 = (D1 T1) - (D2 T2)
	negate swap negate swap
	+duration
;


\ Date and time conversion *****************************************************************************

0 0 0 ~time value TimeZone					\ hh min sec, west is negative IN ALL THREE INTEGERS
0 0 0 ~time value DaylightSaving			\ hh min sec, expect 00 00 00 or 01 00 00
48 51 53 ~angle value Latitude			\ deg min sec, south is negative IN ALL THREE INTEGERS
02 20 56 ~angle value Longitude			\ deg min sec, west is negative IN ALL THREE INTEGERS


\ convert a finite fraction in deg min sec to hours min sec
: AngleToTime ( x -- y)
	15 /
;

\ convert a finite fraction in hours min sec to deg min sec
: TimeToAngle ( x -- y)
	15 *
;

\ convert a local civil date and time to UT, using the two-cell representation
: LTtoUT ( D T -- D T)
	DaylightSaving 0 swap -duration
	TimeZone 0 swap -duration
;

\ convert UT to a local civil date and time, using two-cell representation
: UTtoLT ( D T -- D T)
	TimeZone 0 swap +duration
	DaylightSaving 0 swap +duration
;

\ convert GST to LST
: GSTtoLST ( T -- T)
	longitude AngleToTime -clock
;

\ convert LST to GST
: LSTtoGST ( T -- T)
	longitude AngleToTime +clock
;

\ Coorodinate conversion ********************************************************************************

: EQtoHZ ( H dec -- alt az) { | alt az -- }
	latitude ADDR alt ADDR az				\ use VFX locals for the pass-by-reference
	( H dec lat &alt &az) EQtoHZ_ext ( --) alt az
;

: HZtoEQ ( alt az -- H dec) { | H dec -- }
	latitude ADDR H ADDR dec				\ use VFX locals for the pass-by-reference
	( alt az lat &H &dec) HZtoEQ_ext ( --) H dec
;

