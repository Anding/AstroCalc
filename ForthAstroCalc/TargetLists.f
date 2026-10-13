\ Dictionary-resident targets and buffer-free, snapshot-based selection.
\ Each record belongs to one catalogue; query subsets never relink records.
NEED HorizonMasks

0 cells constant TARGET.NEXT
1 cells constant TARGET.RA
2 cells constant TARGET.DEC
3 cells constant TARGET.NAME
4 cells constant TARGET.MAGNITUDE
5 cells constant /TARGET
-2147483647 constant magnitude-unknown
0 cells constant TARGETLIST.FIRST
1 cells constant TARGETLIST.LAST
2 cells constant /TARGETLIST
0 value active-targetlist

: BEGIN-TARGETLIST ( "name" -- )
    active-targetlist abort" Nested target list"
    create here /TARGETLIST allot
    dup /TARGETLIST erase to active-targetlist
DOES> ( -- list )
;

: END-TARGETLIST ( -- )
    active-targetlist 0= abort" No open target list"
    0 to active-targetlist
;

: append-target { target | last -- }
    active-targetlist 0= if exit then
    active-targetlist TARGETLIST.LAST + @ to last
    last if target last TARGET.NEXT + !
    else target active-targetlist TARGETLIST.FIRST + ! then
    target active-targetlist TARGETLIST.LAST + !
;

: define-target
    { RA Dec magnitude |
      name-addr name-u target -- target }
    BL parse-word to name-u to name-addr
    name-u 0= abort" Target name must not be empty"
    name-addr name-u ($create)
    here to target
    0 , RA , Dec , 0 , magnitude ,
    name-addr name-u target TARGET.NAME + store-region-string
    target append-target
    target
;

: target-coordinates ( target -- RA Dec )
    dup TARGET.RA + @ swap TARGET.DEC + @
;
: target-name ( target -- caddr u ) TARGET.NAME + @ count ;
: target-magnitude ( target -- millimagnitudes ) TARGET.MAGNITUDE + @ ;

: .magnitude ( millimagnitudes -- )
    dup magnitude-unknown = if drop s" unknown" type exit then
    dup 0< if '-' emit then
    abs 0 <# # # # '.' hold #s #> type
;

: POINT-TARGET: ( RA Dec millimagnitudes "name" -- )
    define-target drop
DOES> ( -- target ) ;

: each-target { list action | target -- }
    list TARGETLIST.FIRST + @ to target
    begin target while
        target action execute
        target TARGET.NEXT + @ to target
    repeat
;

0 constant meridian-indifferent
1 constant meridian-east
2 constant meridian-west
meridian-indifferent value targets.meridian-side
-90 00 00 Alt value targets.minimum-altitude
90 00 00 Alt value targets.maximum-altitude
default-horizon-mask value targets.mask

: validate-target-query ( -- )
    SkyDate 0= abort" Target query needs a UTC date"
    targets.minimum-altitude targets.maximum-altitude >
        abort" Inverted target altitude bounds"
    targets.meridian-side meridian-indifferent meridian-west 1+ within 0=
        abort" Invalid meridian side"
;

: target-visible? { target | RA Dec hour-angle altitude azimuth -- flag }
    target target-coordinates SkyDate JNOW to Dec to RA
    RA LST RAtoHA to hour-angle
    targets.meridian-side meridian-east = if
        hour-angle 0< 0= if 0 exit then
    then
    targets.meridian-side meridian-west = if
        hour-angle 0< if 0 exit then
    then
    hour-angle Dec EQtoHZ to azimuth to altitude
    altitude targets.minimum-altitude >=
    altitude targets.maximum-altitude <= and
    altitude azimuth targets.mask horizon-blocked? 0= and
;

: target-distance { target RA Dec -- distance }
    target target-coordinates RA Dec ang_sep
;

: next-target
    { list previous RA Dec | target best distance best-distance previous-distance seen -- target|0 }
\ Equal-distance successors follow source order. Only the previous address
\ is retained; neither catalogue links nor FITS region links are rewritten.
    validate-target-query
    0 to best
    0 to best-distance
    0 to seen
    previous if previous RA Dec target-distance else -1 then to previous-distance
    list TARGETLIST.FIRST + @ to target
    begin target while
        target previous = if -1 to seen then
        target target-visible? if
            target RA Dec target-distance to distance
            distance previous-distance >
            distance previous-distance = seen and target previous <> and or if
                best 0= distance best-distance < or if
                    target to best distance to best-distance
                then
            then
        then
        target TARGET.NEXT + @ to target
    repeat
    previous seen 0= and abort" Previous target is not in this list"
    best
;

: nearest-target { list RA Dec -- target|0 }
    list 0 RA Dec next-target
;

: walk-targets { list RA Dec action | target -- }
    list RA Dec nearest-target to target
    begin target while
        target target RA Dec target-distance action execute
        list target RA Dec next-target to target
    repeat
;
