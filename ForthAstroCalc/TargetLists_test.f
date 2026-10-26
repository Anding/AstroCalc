\ Executable tutorial: targets are records; lists contain references.
NEED ForthAstroCalc
NEED simple-tester

\ J2000 positions, OpenNGC v20260501 (CC-BY-SA-4.0).
05 34 32 RA +22 00 52 Dec TARGET: M1
05 35 16 RA -05 -23 -23 Dec TARGET: M42
05 35 31 RA -05 -16 -03 Dec TARGET: M43
03 47 29 RA +24 06 19 Dec TARGET: M45
create winter-targets M1 , M42 , M43 , M45 , 0 ,

Tstart
T{ M42 target-coordinates }T 05 35 16 RA -05 -23 -23 Dec ==
T{ M42 target-name hashS }T s" M42" hashS ==

\ Sorting rewrites this list, not its records or their other memberships.
\ The comparison word preserves the reference coordinates on the stack.
T{ M42 target-coordinates ' angular-distance-compare winter-targets SORT-LIST }T
    05 35 16 RA -05 -23 -23 Dec ==
T{ winter-targets @ winter-targets cell+ @
    winter-targets 2 cells + @ winter-targets 3 cells + @ }T M42 M43 M1 M45 ==

\ There is no date, mount enquiry, visibility filter or observability policy.
\ A normal predicate can select references into an independent list.
: not-Orion ( target -- flag ) M42 <> ;
' not-Orion winter-targets LIST-FROM other-targets
T{ other-targets COUNT-LIST }T 3 ==
T{ other-targets @ }T M43 ==
T{ winter-targets @ }T M42 ==
Tend
