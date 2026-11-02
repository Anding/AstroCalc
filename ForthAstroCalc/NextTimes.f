\ Next occurrences use Windows time, not mount clocks or connection state.
\ Inputs are finite fractions: e.g. 23 30 00 ~, not the decimal integer 233000.
\ Results use AstroCalc's epoch, directly suitable for gather-until.
: astrocalc.epoch-now ( -- epoch )
\ Sample Windows UTC once and express it in AstroCalc epoch seconds.
    0 now >R ~~~ R> ~~~ EpochTime
;

: LST-next-at { requested current -- epoch }
\ Find the strictly next LST after an explicit UTC epoch, at Longitude (east-positive).
\ A sidereal second is 1/1.002737909 solar seconds; round the wait upward.
    requested current EpochTimetoGST GSTtoLST - %clock
    dup 0= if drop 24HOURS then
    1000000000 1002737909 */mod swap if 1+ then
    current +
;

: LST-next ( hhmmss -- epoch )
\ Return the next requested LST using Windows UTC and configured Longitude.
    astrocalc.epoch-now LST-next-at
;

LIBRARY: kernel32.dll
Extern: int WINAPI GetTimeZoneInformationForYear( int year, int * dynamic, int * info );
Extern: int WINAPI SystemTimeToTzSpecificLocalTimeEx( int * dynamic, int * utc, int * local );

16 buffer: next-time.utc
16 buffer: next-time.local
172 buffer: next-time.zone

: next-time>systemtime ( epoch addr -- ) { addr -- }
\ Write a Windows SYSTEMTIME from a calendar encoded as AstroCalc epoch seconds.
    addr 16 erase
    fromEpochTime
    addr 12 + w! addr 10 + w! addr 8 + w!
    addr 6 + w! addr 2 + w! addr w!
;

: next-time>epoch ( addr -- epoch ) { addr -- }
\ Read the calendar fields of a Windows SYSTEMTIME into AstroCalc epoch seconds.
    addr w@ addr 2 + w@ addr 6 + w@
    addr 8 + w@ addr 10 + w@ addr 12 + w@ EpochTime
;

: next-time>local { utc-epoch zone -- local-calendar-epoch }
\ Apply Windows dynamic timezone rules, including the date's daylight-saving rule.
    utc-epoch next-time.utc next-time>systemtime
    zone next-time.utc next-time.local SystemTimeToTzSpecificLocalTimeEx drop
    next-time.local next-time>epoch
;

: localtime-next-at { requested current zone | local-day wanted candidate best -- epoch }
\ Select the earliest future UTC matching the requested local clock.
\ Try both Windows biases: round trips reject nonexistent spring times and
\ distinguish both occurrences of an autumn repeated time. ZONE=0 uses Windows.
    current zone next-time>local 1DAY / 1DAY * -> local-day
    begin
        local-day requested + -> wanted
        wanted next-time.utc next-time>systemtime
        next-time.utc w@ zone next-time.zone GetTimeZoneInformationForYear drop
        0 -> best
        2 0 do
            wanted next-time.zone @
                next-time.zone i if 168 else 84 then + @ + 60 * + -> candidate
            candidate current > if
                candidate zone next-time>local wanted = if
                    best 0= candidate best < or if candidate -> best then
                then
            then
        loop
        best if best exit then
        local-day 1DAY + -> local-day
    again
;

: localtime-next ( hhmmss -- epoch )
\ Return the strictly next local time under Windows timezone rules.
\ Skip nonexistent dates/times; choose the next occurrence when a clock repeats.
    astrocalc.epoch-now 0 localtime-next-at
;

: altitude-next-at { RA Dec altitude descending? current | H -- epoch|0 }
\ Schedule J2000 coordinates using JNOW at the sampled UTC date.
\ Geometric altitude only; freeze coordinates for this next sidereal cycle.
    RA Dec current 1DAY / date_after_epoch JNOW -> Dec -> RA
    Dec Latitude altitude altitude_hour_angle -> H
    H 0< if 0 exit then
    RA descending? if H + else H - then %clock current LST-next-at
;

: ascending-next ( RA Dec altitude -- epoch|0 )
\ Next rising crossing for J2000 coordinates; zero means this altitude is never crossed.
    false astrocalc.epoch-now altitude-next-at
;

: descending-next ( RA Dec altitude -- epoch|0 )
\ Next setting crossing for J2000 coordinates; zero also covers culmination tangencies.
    true astrocalc.epoch-now altitude-next-at
;
