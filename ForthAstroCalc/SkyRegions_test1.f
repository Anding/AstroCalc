NEED SkyRegions
NEED simple-tester

0 0 1 CIRCLE-REGION: region.point
0 0 90 00 00 DEGMMSS CIRCLE-REGION: region.hemisphere
0 0 180 00 00 DEGMMSS CIRCLE-REGION: region.sphere
0 0 2 CIRCLE-REGION: region.tiny
POLYGON-REGION: region.octant
    0 0 ADD-REGION-POINT
    06 00 00 RA 0 ADD-REGION-POINT
    0 90 00 00 Dec ADD-REGION-POINT
POLYGON-REGION: region.reversed
    0 90 00 00 Dec ADD-REGION-POINT
    06 00 00 RA 0 ADD-REGION-POINT
    0 0 ADD-REGION-POINT
POLYGON-REGION: region.wrap
    23 00 00 RA 10 00 00 Dec ADD-REGION-POINT
    01 00 00 RA 10 00 00 Dec ADD-REGION-POINT
    01 00 00 RA 30 00 00 Dec ADD-REGION-POINT
    23 00 00 RA 30 00 00 Dec ADD-REGION-POINT
POLYGON-REGION: region.rectangle
    23 00 00 RA -30 00 00 Dec ADD-REGION-POINT
    01 00 00 RA -30 00 00 Dec ADD-REGION-POINT
    01 00 00 RA +30 00 00 Dec ADD-REGION-POINT
    23 00 00 RA +30 00 00 Dec ADD-REGION-POINT
create region.list region.sphere , region.octant , region.hemisphere , region.tiny , region.point , 0 ,
create region.priority region.sphere , region.point , 0 ,
create region.empty 0 ,
create region.bad -3 , 0 , 0 , 0 , 0 , 3600 , 0 ,
: region.invalid-area region.bad region.point angular-area-compare drop ;
: region.invalid-radius 0 0 -1 CIRCLE-REGION: ;

Tstart
T{ region.wrap region-name hashS }T s" REGION.WRAP" hashS ==
T{ 0 0 region.point region-inside? }T -1 ==
T{ 0 1 region.point region-inside? }T -1 ==
T{ 0 2 region.point region-inside? }T 0 ==
T{ 01 00 00 RA 20 00 00 Dec region.octant region-inside? }T -1 ==
T{ 13 00 00 RA -20 00 00 Dec region.octant region-inside? }T 0 ==
T{ 01 00 00 RA 20 00 00 Dec region.reversed region-inside? }T -1 ==
T{ 0 20 00 00 Dec region.wrap region-inside? }T -1 ==
T{ 12 00 00 RA -20 00 00 Dec region.wrap region-inside? }T 0 ==
T{ 23 00 00 RA 10 00 00 Dec region.wrap region-inside? }T -1 ==
T{ 23 00 00 RA -30 00 00 Dec region.rectangle region-inside? }T -1 ==
T{ 01 00 00 RA 0 region.rectangle region-inside? }T -1 ==
\ The great-circle top bows north of the corner declinations.
T{ 0 30 00 00 Dec region.rectangle region-inside? }T -1 ==
T{ 0 31 00 00 Dec region.rectangle region-inside? }T 0 ==
T{ 0 0 region.priority search-regionlist }T region.sphere ==
T{ 0 0 region.empty search-regionlist }T 0 ==
T{ ' region.invalid-area catch 0<> }T -1 ==
T{ ' region.invalid-radius catch 0<> }T -1 ==
T{ region.octant region.reversed angular-area-compare }T -1 ==
T{ 123 ' angular-area-compare region.list SORT-LIST }T 123 ==
T{ region.list @ region.list cell+ @ region.list 2 cells + @
    region.list 3 cells + @ region.list 4 cells + @ }T
    region.point region.tiny region.octant region.hemisphere region.sphere ==
T{ region.priority @ }T region.sphere ==
' angular-area-compare region.priority SORT-LIST
T{ 0 0 region.priority search-regionlist }T region.point ==

include "%idir%\SkyRegions_catalogs.f"
T{ 21 00 00 RA 75 00 00 Dec REGATLAS search-regionlist }T chart-2 ==
T{ 14 00 00 RA 75 00 00 Dec REGATLAS search-regionlist }T chart-4 ==
T{ 05 30 00 RA 0 REGVIS search-regionlist }T orion-quadrant ==
T{ 19 30 00 RA 35 00 00 Dec REGVIS search-regionlist }T summer-triangle ==
T{ 12 27 00 RA 12 43 00 Dec REGDEEP search-regionlist }T virgo-cluster ==
T{ 20 30 00 RA 40 00 00 Dec REGDEEP search-regionlist }T cygnus-milky-way ==
T{ 0 -60 00 00 Dec REGDEEP search-regionlist }T 0 ==
TEnd
