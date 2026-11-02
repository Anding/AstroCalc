\ Executable scheduling examples. No equipment or machine timezone changes.
NEED ForthAstroCalc
NEED simple-tester

Tstart

\ Local sidereal time increases eastward; conversions wrap across midnight.
114 01 00 ~ -> Longitude
T{ 20 00 00 ~ GSTtoLST }T 03 36 04 ~ ==
T{ 03 36 04 ~ LSTtoGST }T 20 00 00 ~ ==
-114 -01 00 ~ -> Longitude
T{ 03 00 00 ~ GSTtoLST }T 19 23 56 ~ ==

114 01 00 ~ -> Longitude
2026 11 2 15 59 00 EpochTime constant next.test-now
next.test-now EpochTimetoGST GSTtoLST constant next.test-lst

\ Future LST, an already-passed LST and an exact match all select the next cycle.
T{ next.test-lst 3600 + %clock next.test-now LST-next-at
   next.test-now - }T 3591 ==
T{ next.test-lst 3600 - %clock next.test-now LST-next-at
   next.test-now - }T 82574 ==
T{ next.test-lst next.test-now LST-next-at next.test-now - }T 86165 ==

\ The same LST can occur twice on one UTC date, near either end of that day.
2026 11 2 0 0 0 EpochTime constant next.test-midnight
next.test-midnight EpochTimetoGST GSTtoLST constant next.test-midnight-lst
T{ next.test-midnight-lst next.test-midnight 60 + LST-next-at
   next.test-midnight - }T 86165 ==

: next.test-LST-match? { requested current | deadline -- flag }
\ Check the computed deadline against AstroCalc's independent forward conversion.
    requested current LST-next-at -> deadline
    deadline current >
    deadline EpochTimetoGST GSTtoLST requested - %clockDiff abs 1 <= and
;
T{ 00 00 01 ~ next.test-now next.test-LST-match? }T true ==
T{ 23 59 59 ~ next.test-midnight next.test-LST-match? }T true ==
T{ next.test-midnight-lst next.test-midnight 60 + next.test-LST-match? }T true ==

\ Use Windows timezone records without changing the machine's timezone.
LIBRARY: advapi32.dll
Extern: int WINAPI EnumDynamicTimeZoneInformation( int index, int * zone );
LIBRARY: kernel32.dll
Extern: int WINAPI lstrcmpW( int * first, int * second );
256 buffer: next.test-key

: next.test-zone { text length dest -- status }
\ Find an installed Windows timezone by its invariant UTF-16 registry key.
    next.test-key 256 erase
    length 0 do text i + c@ next.test-key i 2* + w! loop
    256 0 do
        i dest EnumDynamicTimeZoneInformation if -1 unloop exit then
        next.test-key dest 172 + lstrcmpW 0= if 0 unloop exit then
    loop
    -1
;

432 buffer: next.test-utc
432 buffer: next.test-east
432 buffer: next.test-dst
T{ s" UTC" next.test-utc next.test-zone }T 0 ==
T{ s" China Standard Time" next.test-east next.test-zone }T 0 ==
T{ s" Eastern Standard Time" next.test-dst next.test-zone }T 0 ==

T{ 00 01 00 ~ next.test-now next.test-east localtime-next-at
}T 2026 11 2 16 1 0 EpochTime ==
T{ 23 58 00 ~ next.test-now next.test-east localtime-next-at
}T 2026 11 3 15 58 0 EpochTime ==
T{ 23 59 00 ~ next.test-now next.test-east localtime-next-at
}T 2026 11 3 15 59 0 EpochTime ==
T{ 00 01 00 ~ 2026 12 31 23 59 0 EpochTime next.test-utc localtime-next-at
}T 2027 1 1 0 1 0 EpochTime ==
T{ 00 01 00 ~ 2028 2 28 23 59 0 EpochTime next.test-utc localtime-next-at
}T 2028 2 29 0 1 0 EpochTime ==

\ Spring's nonexistent 02:30 is skipped, rather than silently shifted to 03:30.
T{ 02 30 00 ~ 2026 3 8 5 0 0 EpochTime next.test-dst localtime-next-at
}T 2026 3 9 6 30 0 EpochTime ==

\ Autumn's two 01:30 occurrences are considered independently, including equality.
T{ 01 30 00 ~ 2026 11 1 4 0 0 EpochTime next.test-dst localtime-next-at
}T 2026 11 1 5 30 0 EpochTime ==
T{ 01 30 00 ~ 2026 11 1 5 30 0 EpochTime next.test-dst localtime-next-at
}T 2026 11 1 6 30 0 EpochTime ==
T{ 01 30 00 ~ 2026 11 1 5 45 0 EpochTime next.test-dst localtime-next-at
}T 2026 11 1 6 30 0 EpochTime ==
T{ 01 30 00 ~ 2026 11 1 6 30 0 EpochTime next.test-dst localtime-next-at
}T 2026 11 2 6 30 0 EpochTime ==

\ Public words sample Windows time; both results must be strictly future.
T{ 12 00 00 ~ localtime-next astrocalc.epoch-now > }T true ==
T{ 12 00 00 ~ LST-next astrocalc.epoch-now > }T true ==
T{ depth }T 0 ==
Tend
