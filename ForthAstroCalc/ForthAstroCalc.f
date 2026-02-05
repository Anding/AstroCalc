\ Astronomical calculations based on Duffett-Smith and Zwart, "Practical Astronomy"
need FiniteFractions

\ Interface with the C language library rountines *******************************************************

LIBRARY: AstroCalc.dll
	
Extern: int "C" version( ) ;
\ return a library version number in yymmdd format

Extern: int "C" days_since_epoch ( int yymmdd) ;
\ return the number of days since the Epoch of a calendar date
\ the Epoch is a date defined in AstroCalc.dll, typically as January 0.0 of a certain year
\ yymmdd denotes calendar dates in single cell format as DD + (60 * (MM + 60 * YY)) using FiniteFractions
\ 	e.g. 2010 08 01 ~  ( 723481)
\  e.g. 7236481 ~~~ ( 2023 04 04)

Extern: int "C" date_after_epoch ( int days) ;
\ return the calendar date ( yymmdd format) of a number of days since the Epoch

Extern: int "C" UTtoGST_ext (int YYMMDD, int UT) ;
\ return the GST of a given date and time at Greenwich
\ D is in YYMMDD format
\ T is UT expressed as seconds-of-the day

Extern: int "C" GSTtoUT_ext (int YYMMDD, int GST) ;
\ return the UT of a given date and time at Greenwich
\ D is in YYMMDD format
\ T is SGT expressed as seconds-of-the day

Extern: void "C" EQtoHZ_ext(int H, int dec, int lat, int * alt, int * az) ;
\ Convert equatorial to horizon coordinates
\ alt, az, dec and lat are expressed in DEGMMSS format
\ H is expressed in integer seconds

Extern: void "C" HZtoEQ_ext(int alt, int az, int lat, int * H, int * dec) ;
\ Convert equatorial to horizon coordinates
\ alt, az, dec and lat are expressed in DEGMMSS format
\ H is expressed in integer seconds

Extern: int "C" ang_sep(int H1, int dec1, int H2, int dec2) ;
\ Compute the angular separation between two coordinates
\ dec is expressed in DEGMMSS format
\ H is expressed in integer seconds

Extern: void "C" J2000toJNOW(int RA_J2000, int DEC_J2000, int yyyymmdd, int * RA_JNOW, int * DEC_JNOW);
\ Convert J2000 to JNOW
\ RA is expressed in integer seconds
\ Dec is expressed in DEGMMSS formt
\ yymmdd is the expression of the date e.g. 2010 08 01 ~ ( 723481)

Extern: void "C" JNOWtoJ2000(int RA_JNOW, int DEC_JNOW, int yyyymmdd, int * RA_J2000, int * DEC_J2000);
\ Convert JNOW to J2000

\ Canonical date and time representations ***************************************************************
\ Astrocalc uses times and durations expressed in seconds since the epoch
\ The Epoch date is as defined in AstroCalc.dll

12 00 00 ~ constant 12HOURS     \ 12 hours in seconds   
24 00 00 ~ constant 24HOURS     \ 24 hours in seconds
24 00 00 ~ constant 1DAY        \ 1 days in seconds, a synonym

: TimeSpan ( days hh mm ss -- T)
\ convert an interval of time expressed as days hh mm ss into integer seconds
    ~ >R 1DAY * R> +
;

: fromTimeSpan ( T -- days hh mm ss)
\ convert integer seconds to a timespan expressed as daus hh mm ss)
    1DAY /mod swap ~~~
;

: EpochDays ( yyyy mm dd -- D)
\ convert year, month, day to a single cell date finite fraction    
\ D is the number of days since the Epoch of that date
	~ days_since_epoch
; 

: fromEpochDays ( D -- yyyy mm dd)
\ convert days after epoch to year, month, day   
	date_after_epoch ~~~
;

\ convert a full calendar date and time to a two cell date-time representation
: EpochTime ( yyyy mm dd hh mm ss -- T)
\ time (in seconds) is the top-of-stack, date (in days since the Epoch) is next-on-stack
	>R >R >R EpochDays R> R> R> ( days hh mm ss) TimeSpan
;

\ convert a two cell date-time representation to a full calendar date and time
: fromEpochTime ( T -- yyyy mm dd hh mm ss)
    1DAY /mod swap              ( days seconds)
    >R fromEpochDays R> ~~~     ( yyyy mm dd hh mm ss)
;

\ Date and time arithmetic *****************************************************************************	

: %clock ( T - T)
\ adjust a time expressed in seconds to within 0 - 24h    
	24HOURS /mod    ( seconds days)
	drop dup 0< if
		24HOURS +
	then
;

: %clockDiff ( T - T)
\ adjust a time difference expressed in seconds to within -11h59m59ss - 12h00m00ss
    24HOURS /mod    ( seconds days)
    drop 
    dup 12HOURS negate <= if
        24HOURS +
    then
    dup 12HOURS > if
        24HOURS -
    then
;

\ Date and time conversion *****************************************************************************

0 0 0 ~ value TimeZone				\ hh min sec, west is negative IN ALL THREE INTEGERS
0 0 0 ~ value DaylightSaving		\ hh min sec, expect 00 00 00 or 01 00 00
48 51 53 ~ value Latitude			\ deg min sec, south is negative IN ALL THREE INTEGERS
02 20 56 ~ value Longitude			\ deg min sec, west is negative IN ALL THREE INTEGERS

: UTtoGST ( yymmdd hhmmss - T)
\ convert a UT date and time to GST   
    UTtoGST_ext
;

: GSTtoUT ( yymmdd hhmmss - T)
\ convert a GST on a date to GST   
    GSTtoUT_ext
;

: RAtoHA ( RA LST -- HA)
\ convert the RA to Hour Angle using LST
    swap - %clockDiff
;

: EpochTimetoGST ( T -- T)
\ convert EpochTime at Greenwich to GST
    fromEpochTime ( yyyy mm dd hh mm ss) ~ >R ~ R> 
    UTtoGST_ext
;

: UTtoLT ( T -- T)
\ convert UT to a local civil date and time    
	TimeZone +
	DaylightSaving +
;

: LTtoUT ( T -- T)
\ convert a local civil date and time to UT    
	DaylightSaving -
	TimeZone -
;

: GSTtoLST ( T -- T)
\ convert GST to LST    
	longitude 15 / -
	%clock
;

: LSTtoGST ( T -- T)
\ convert LST to GST    
	longitude 15 / +
	%clock
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

: J2000 ( RA_JNOW DEC_JNOW YYMMDD -- RA_J2000 DEC_J2000) { | RA_J2000 DEC_J2000 -- }
    ADDR RA_J2000 ADDR DEC_J2000
    JNOWtoJ2000 ( --) RA_J2000 DEC_J2000
;  

: JNOW ( RA_J2000 DEC_J2000 YYMMDD -- RA_JNOW DEC_JNOW) { | RA_JNOW DEC_JNOW -- }
    ADDR RA_JNOW ADDR DEC_JNOW
    J2000toJNOW ( --) RA_JNOW DEC_JNOW
;

