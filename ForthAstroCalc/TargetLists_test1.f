NEED TargetLists
NEED simple-tester

depth constant target-test-depth
first-regionlist constant target-test-registry

BEGIN-TARGETLIST target-test-list
12 00 00 RA 0 POINT-TARGET: target-test-far
06 00 00 RA 0 POINT-TARGET: target-test-near-a
08 00 00 RA 0 POINT-TARGET: target-test-middle
06 00 00 RA 0 POINT-TARGET: target-test-near-b
END-TARGETLIST
BEGIN-TARGETLIST target-test-empty
END-TARGETLIST
00 00 00 RA 0 POINT-TARGET: target-test-outsider

' target-test-far >body constant target-test-far-record
' target-test-near-a >body constant target-test-a-record
' target-test-near-b >body constant target-test-b-record
' target-test-middle >body constant target-test-middle-record

BEGIN-HORIZON-MASK target-test-mask
0 horizon-below target-test-below
35 00 00 Alt 70 00 00 Alt 300 00 00 Az 60 00 00 Az
    horizon-strip target-test-north
END-HORIZON-MASK
BEGIN-HORIZON-MASK target-test-circle-mask
45 00 00 Alt 359 00 00 Az 5 00 00 DEGMMSS
    horizon-circle target-test-circle
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

Tstart
T{ depth }T target-test-depth ==
T{ first-regionlist }T target-test-registry ==
T{ target-test-near-a }T 06 00 00 RA 0 ==
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
