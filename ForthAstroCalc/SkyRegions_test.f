\ Executable tutorial: geometry is independent of list membership and order.
NEED SkyRegions
NEED simple-tester

06 00 00 RA 0 05 00 00 DEGMMSS CIRCLE-REGION: broad
06 00 00 RA 0 01 00 00 DEGMMSS CIRCLE-REGION: small
POLYGON-REGION: midnight
    23 00 00 RA 10 00 00 Dec ADD-REGION-POINT
    01 00 00 RA 10 00 00 Dec ADD-REGION-POINT
    01 00 00 RA 30 00 00 Dec ADD-REGION-POINT
    23 00 00 RA 30 00 00 Dec ADD-REGION-POINT
\ No other dictionary allocation is permitted during polygon construction.
create regions broad , small , midnight , 0 ,
create other-regions broad , midnight , 0 ,
create lists regions , other-regions , 0 ,

Tstart
\ Check region-centre's ior before using its RA Dec.
\ Polygon centres are mean vertex directions, with RA wrap handled in C.
T{ small region-centre }T 06 00 00 RA 0 0 ==
T{ midnight region-centre drop midnight region-inside? }T -1 ==
\ Names come from the dictionary; there are no duplicated IDs or labels.
T{ small region-name hashS }T s" SMALL" hashS ==
T{ 06 00 00 RA 0 regions search-regionlist }T broad ==
T{ 0 20 00 00 Dec regions search-regionlist }T midnight ==
T{ 12 00 00 RA 50 00 00 Dec regions search-regionlist }T 0 ==

\ Spherical area is solid angle, not planar RA/Dec extent. Sorting is explicit.
' angular-area-compare regions SORT-LIST
T{ 06 00 00 RA 0 regions search-regionlist }T small ==
T{ other-regions @ }T broad ==

\ The same containment predicate can produce a new ordinary list.
T{ 06 00 00 RA 0 ' region-contains? regions LIST-FROM containing }T 06 00 00 RA 0 ==
T{ containing COUNT-LIST }T 2 ==
T{ containing @ containing cell+ @ }T small broad ==
T{ lists @ lists cell+ @ }T regions other-regions ==
Tend
