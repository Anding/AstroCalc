\ Scheduling tutorial: J2000 targets, geometric altitude, Windows-independent test epoch.
NEED ForthAstroCalc
NEED simple-tester

22 18 00 ~ -> Latitude
114 01 00 ~ -> Longitude
2026 11 2 12 0 0 EpochTime constant crossing.now
05 35 16 ~ constant crossing.RA
-05 -23 -23 ~ constant crossing.Dec

: crossing.altitude { epoch -- altitude }
\ Independently evaluate M42 at a scheduled epoch with the same frozen JNOW date.
    crossing.RA crossing.Dec crossing.now 1DAY / date_after_epoch JNOW
    swap epoch EpochTimetoGST GSTtoLST RAtoHA swap Latitude EQtoHZ-at drop
;

crossing.RA crossing.Dec 30 00 00 ~ false crossing.now altitude-next-at
    constant crossing.rise
crossing.RA crossing.Dec 30 00 00 ~ true crossing.now altitude-next-at
    constant crossing.set

Tstart
\ Each branch must cross in the correct direction, not merely reach the altitude.
T{ crossing.rise crossing.now > crossing.set crossing.now > and }T true ==
T{ crossing.rise crossing.altitude 30 00 00 ~ - abs 30 < }T true ==
T{ crossing.set crossing.altitude 30 00 00 ~ - abs 30 < }T true ==
T{ crossing.rise 120 - crossing.altitude 30 00 00 ~ <
   crossing.rise 120 + crossing.altitude 30 00 00 ~ > and }T true ==
T{ crossing.set 120 - crossing.altitude 30 00 00 ~ >
   crossing.set 120 + crossing.altitude 30 00 00 ~ < and }T true ==

\ J2000 conversion must be used, rather than treating catalogue RA/Dec as JNOW.
T{ crossing.rise
   crossing.RA crossing.Dec crossing.now 1DAY / date_after_epoch JNOW
   Latitude 30 00 00 ~ altitude_hour_angle - %clock
   crossing.now LST-next-at = }T true ==

\ A passed rising event schedules the next cycle, not a time in the past.
T{ crossing.RA crossing.Dec 30 00 00 ~ false crossing.rise 120 +
   altitude-next-at crossing.rise - 86165 - abs 2 <= }T true ==

\ A circumpolar star has no horizon crossing, but can cross a higher altitude.
T{ 0 80 00 00 ~ 0 ascending-next }T 0 ==
T{ 0 80 00 00 ~ 0 descending-next }T 0 ==
T{ 0 -80 00 00 ~ 0 ascending-next }T 0 ==
T{ 0 -80 00 00 ~ 0 descending-next }T 0 ==
T{ 0 80 00 00 ~ Latitude ascending-next astrocalc.epoch-now > }T true ==

\ Southern latitude uses the same geometry and signs.
-22 -18 00 ~ -> Latitude
T{ 0 -80 00 00 ~ 0 descending-next }T 0 ==
T{ 0 80 00 00 ~ 0 ascending-next }T 0 ==
T{ crossing.RA crossing.Dec 30 00 00 ~ descending-next
   astrocalc.epoch-now > }T true ==
T{ depth }T 0 ==
Tend
