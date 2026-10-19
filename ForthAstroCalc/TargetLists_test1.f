NEED TargetLists
NEED simple-tester

00 00 00 RA 0 TARGET: target.origin
01 00 00 RA 0 TARGET: target.east
23 00 00 RA 0 TARGET: target.west
00 00 00 RA 10 00 00 Dec TARGET: target.north
00 00 00 RA 0 4199 FOCUS-STAR: target.star
create target.list target.east , target.west , target.north , target.origin , 0 ,
create target.other target.north , target.east , 0 ,
create target.empty 0 ,

Tstart
T{ target.origin target-coordinates }T 0 0 ==
T{ target.star target-coordinates }T 0 0 ==
T{ target.star target-magnitude }T 4199 ==
T{ target.origin target-name hashS }T s" TARGET.ORIGIN" hashS ==
T{ target.east target.origin target-coordinates target-distance }T 15 00 00 DEGMMSS ==
T{ target.west target.origin target-coordinates target-distance }T 15 00 00 DEGMMSS ==
T{ target.north target.origin target-coordinates target-distance }T 10 00 00 DEGMMSS ==
T{ target.origin target-coordinates ' angular-distance-compare target.list SORT-LIST }T 0 0 ==
T{ target.list @ target.list cell+ @ target.list 2 cells + @
    target.list 3 cells + @ }T target.origin target.north target.east target.west ==
T{ target.other @ target.other cell+ @ }T target.north target.east ==
T{ 123 456 ' angular-distance-compare target.empty SORT-LIST }T 123 456 ==
T{ target.east target.list ITEM-IN-LIST? }T 2 -1 ==
Tend
