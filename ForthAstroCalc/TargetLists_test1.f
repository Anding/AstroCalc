NEED TargetLists
NEED simple-tester

depth constant target-test-depth
first-regionlist constant target-test-registry

BEGIN-TARGETLIST target-test-list
12 00 00 RA 0 magnitude-unknown POINT-TARGET: target-test-far
06 00 00 RA 0 -1460 POINT-TARGET: target-test-near-a
08 00 00 RA 0 0 POINT-TARGET: target-test-middle
06 00 00 RA 0 4199 POINT-TARGET: target-test-near-b
END-TARGETLIST
BEGIN-TARGETLIST target-test-empty
END-TARGETLIST
00 00 00 RA 0 magnitude-unknown POINT-TARGET: target-test-outsider

' target-test-far >body constant target-test-far-record
' target-test-near-a >body constant target-test-a-record
' target-test-near-b >body constant target-test-b-record
' target-test-middle >body constant target-test-middle-record

BEGIN-HORIZON-MASK target-test-mask
0 s" below" s" Below" sky-below target-test-below
300 00 00 Az azimuth>longitude 35 00 00 Alt
60 00 00 Az azimuth>longitude 70 00 00 Alt
    s" north" s" North" sky-band target-test-north
END-HORIZON-MASK
BEGIN-HORIZON-MASK target-test-circle-mask
359 00 00 Az azimuth>longitude 45 00 00 Alt 5 00 00 DEGMMSS
    s" circle" s" Circle" sky-circle target-test-circle
END-HORIZON-MASK

BEGIN-HORIZON-MASK target-test-full-mask
00 00 00 RA 35 00 00 Alt 24 00 00 RA 70 00 00 Alt
    s" full" s" Full longitude band" sky-band target-test-full-band
END-HORIZON-MASK

2000 01 01 ~ -> SkyDate
07 00 00 RA -> LST
0 -> Latitude
0 -> targets.mask
0 value target-test-count
: target-test-visit ( target distance -- ) 2drop target-test-count 1+ to target-test-count ;
: target-test-invalid-previous ( -- )
    target-test-list ['] target-test-outsider >body 06 00 00 RA 0 next-target drop
;
: target-test-query ( -- ) target-test-list 06 00 00 RA 0 nearest-target drop ;
: target-test-altaz-reference ( -- ) 45 00 00 Alt 180 00 00 Az HZtoJ2000 2drop ;
: target-test-scoped-policy ( n -- n side ) targets.meridian-side ;
: target-test-throw-policy ( -- ) -98 throw ;
: target-test-scoped-error ( -- )
    meridian-east ['] target-test-throw-policy with-meridian-side
;

Tstart
T{ 42 meridian-east ' target-test-scoped-policy with-meridian-side }T 42 meridian-east ==
T{ targets.meridian-side }T meridian-indifferent ==
T{ ' target-test-scoped-error catch }T -98 ==
T{ targets.meridian-side }T meridian-indifferent ==
T{ depth }T target-test-depth ==
T{ first-regionlist }T target-test-registry ==
T{ target-test-near-a }T target-test-a-record ==
T{ target-test-near-a target-coordinates }T 06 00 00 RA 0 ==
T{ target-test-near-a target-magnitude }T -1460 ==
T{ target-test-middle target-magnitude }T 0 ==
T{ target-test-near-b target-magnitude }T 4199 ==
T{ target-test-far target-magnitude }T magnitude-unknown ==
T{ target-test-a-record target-name hashS }T s" target-test-near-a" hashS ==
T{ target-test-a-record 06 00 00 RA 0 target-distance }T 0 ==
T{ target-test-list 06 00 00 RA 0 nearest-target }T target-test-a-record ==
T{ target-test-list 08 00 00 RA 0 nearest-target }T target-test-middle-record ==
T{ target-test-list 06 00 00 RA 0 nearest-target }T target-test-a-record ==
T{ target-test-list target-test-a-record 06 00 00 RA 0 next-target }T target-test-b-record ==
T{ target-test-list target-test-b-record 06 00 00 RA 0 next-target }T target-test-middle-record ==
T{ target-test-list target-test-middle-record 06 00 00 RA 0 next-target }T target-test-far-record ==
T{ target-test-list target-test-far-record 06 00 00 RA 0 next-target }T 0 ==
T{ target-test-empty 06 00 00 RA 0 nearest-target }T 0 ==
T{ 45 00 00 Alt 180 00 00 Az HZtoEQ }T
    45 00 00 Alt 180 00 00 Az latitude HZtoEQ-at ==
T{ target-test-list 06 00 00 RA 0 ' target-test-visit walk-targets }T ==
T{ target-test-count }T 4 ==
T{ target-test-a-record TARGET.NEXT + @ }T target-test-middle-record ==
T{ ' target-test-invalid-previous catch 0<> }T -1 ==

meridian-east -> targets.meridian-side
T{ target-test-a-record target-visible? }T 0 ==
T{ target-test-middle-record target-visible? }T -1 ==
T{ target-test-list 06 00 00 RA 0 nearest-target }T target-test-middle-record ==
09 00 00 RA -> LST
T{ target-test-middle-record target-visible? }T 0 ==
07 00 00 RA -> LST
meridian-west -> targets.meridian-side
T{ target-test-a-record target-visible? }T -1 ==
T{ target-test-middle-record target-visible? }T 0 ==
meridian-indifferent -> targets.meridian-side
60 00 00 Alt -> targets.minimum-altitude
90 00 00 Alt -> targets.maximum-altitude
T{ target-test-far-record target-visible? }T 0 ==
T{ target-test-a-record target-visible? }T -1 ==
90 00 00 DEGMMSS -> Latitude
T{ target-test-a-record target-visible? }T 0 ==
0 -> Latitude
70 00 00 Alt -> targets.maximum-altitude
T{ target-test-list 06 00 00 RA 0 nearest-target }T 0 ==

T{ -1 180 00 00 Az target-test-mask horizon-blocked? }T -1 ==
T{ 0 180 00 00 Az target-test-mask horizon-blocked? }T 0 ==
T{ 50 00 00 Alt 0 target-test-mask horizon-blocked? }T -1 ==
T{ 50 00 00 Alt 300 00 00 Az target-test-mask horizon-blocked? }T -1 ==
T{ 50 00 00 Alt 60 00 00 Az target-test-mask horizon-blocked? }T -1 ==
T{ 50 00 00 Alt 61 00 00 Az target-test-mask horizon-blocked? }T 0 ==
T{ 71 00 00 Alt 0 target-test-mask horizon-blocked? }T 0 ==
T{ 50 00 00 Alt 360 00 00 Az target-test-mask horizon-blocked? }T -1 ==
T{ 45 00 00 Alt 1 00 00 Az target-test-circle-mask horizon-blocked? }T -1 ==
T{ 45 00 00 Alt 180 00 00 Az target-test-circle-mask horizon-blocked? }T 0 ==
T{ 50 00 00 Alt 0 target-test-full-mask horizon-blocked? }T -1 ==
T{ 50 00 00 Alt 180 00 00 Az target-test-full-mask horizon-blocked? }T -1 ==
T{ 50 00 00 Alt 359 59 59 Az target-test-full-mask horizon-blocked? }T -1 ==
T{ 50 00 00 Alt 360 00 00 Az target-test-full-mask horizon-blocked? }T -1 ==
T{ 50 00 00 Alt -1 target-test-full-mask horizon-blocked? }T -1 ==
T{ 34 59 59 Alt 90 00 00 Az target-test-full-mask horizon-blocked? }T 0 ==
T{ 70 00 01 Alt 90 00 00 Az target-test-full-mask horizon-blocked? }T 0 ==
T{ 15 00 00 Az azimuth>longitude }T 01 00 00 RA ==
T{ -15 00 00 Az azimuth>longitude }T 23 00 00 RA ==
T{ 20 00 00 RA 50 00 00 Dec target-test-north region-inside? }T -1 ==
T{ 00 04 00 RA 45 00 00 Dec target-test-circle region-inside? }T -1 ==
T{ 00 04 00 RA 45 00 00 Dec target-test-circle-mask search-regionlist }T target-test-circle ==
T{ -1460 .magnitude 0 .magnitude 4199 .magnitude magnitude-unknown .magnitude }T ==

T{ target-test-a-record
    target-test-a-record target-coordinates SkyDate LST Latitude J2000toHZ
    HZtoJ2000 target-distance 00 00 30 DEGMMSS <= }T -1 ==

99 -> targets.meridian-side
T{ ' target-test-query catch 0<> }T -1 ==
meridian-indifferent -> targets.meridian-side
90 00 00 Alt -> targets.minimum-altitude
0 -> targets.maximum-altitude
T{ ' target-test-query catch 0<> }T -1 ==
-90 00 00 Alt -> targets.minimum-altitude
90 00 00 Alt -> targets.maximum-altitude
default-horizon-mask -> targets.mask
0 -> SkyDate
T{ ' target-test-query catch 0<> }T -1 ==
T{ ' target-test-altaz-reference catch 0<> }T -1 ==
T{ depth }T target-test-depth ==
Tend
