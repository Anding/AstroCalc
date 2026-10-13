\ Dictionary-resident targets and buffer-free, snapshot-based selection.
\ Each record belongs to one catalogue; query subsets never relink records.
NEED HorizonMasks

0 cells constant TARGET.NEXT
1 cells constant TARGET.RA
2 cells constant TARGET.DEC
3 cells constant TARGET.NAME
4 cells constant TARGET.SOURCE
5 cells constant TARGET.MAGNITUDE
6 cells constant TARGET.COLOUR
7 cells constant /TARGET
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
    { RA Dec source-addr source-u mag-addr mag-u colour-addr colour-u |
      name-addr name-u target -- target }
    BL parse-word to name-u to name-addr
    name-u 0= abort" Target name must not be empty"
    name-addr name-u ($create)
    here to target
    0 , RA , Dec , 0 , 0 , 0 , 0 ,
    name-addr name-u target TARGET.NAME + store-region-string
    source-addr source-u target TARGET.SOURCE + store-region-string
    mag-addr mag-u target TARGET.MAGNITUDE + store-region-string
    colour-addr colour-u target TARGET.COLOUR + store-region-string
    target append-target
    target
;

: target-coordinates ( target -- RA Dec )
    dup TARGET.RA + @ swap TARGET.DEC + @
;
: target-name ( target -- caddr u ) TARGET.NAME + @ count ;
: target-source ( target -- caddr u ) TARGET.SOURCE + @ count ;
: target-magnitude ( target -- caddr u ) TARGET.MAGNITUDE + @ count ;
: target-colour ( target -- caddr u ) TARGET.COLOUR + @ count ;

: POINT-TARGET: { RA Dec -- }
    RA Dec s" " s" " s" " define-target drop
DOES> ( -- RA Dec ) target-coordinates ;

: FOCUS-TARGET: ( RA Dec source-addr source-u mag-addr mag-u colour-addr colour-u "name" -- )
    define-target drop
DOES> ( -- RA Dec ) target-coordinates ;

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
0 value targets.date
0 value targets.lst
0 value targets.latitude
0 value targets.reference-RA
0 value targets.reference-Dec
-90 00 00 Alt value targets.minimum-altitude
90 00 00 Alt value targets.maximum-altitude
default-horizon-mask value targets.mask

: target-context { date lst latitude -- }
    date to targets.date
    lst to targets.lst
    latitude to targets.latitude
;

: target-reference { RA Dec -- }
    RA to targets.reference-RA
    Dec to targets.reference-Dec
;

: target-reference-altaz ( alt az -- )
    targets.date 0= abort" AltAz reference needs a time and site context"
    targets.latitude HZtoEQ-at
    swap targets.lst swap - %clock swap
    targets.date J2000 target-reference
;

: validate-target-query ( -- )
    targets.date 0= abort" Target query needs a time and site context"
    targets.minimum-altitude targets.maximum-altitude >
        abort" Inverted target altitude bounds"
    targets.meridian-side meridian-indifferent meridian-west 1+ within 0=
        abort" Invalid meridian side"
;

: target-visible? { target | RA Dec hour-angle altitude azimuth -- flag }
    target target-coordinates targets.date JNOW to Dec to RA
    RA targets.lst RAtoHA to hour-angle
    targets.meridian-side meridian-east = if
        hour-angle 0< 0= if 0 exit then
    then
    targets.meridian-side meridian-west = if
        hour-angle 0< if 0 exit then
    then
    hour-angle Dec targets.latitude EQtoHZ-at to azimuth to altitude
    altitude targets.minimum-altitude >=
    altitude targets.maximum-altitude <= and
    altitude azimuth targets.mask horizon-blocked? 0= and
;

: target-distance ( target -- distance )
    target-coordinates targets.reference-RA targets.reference-Dec ang_sep
;

: next-target
    { list previous | target best distance best-distance previous-distance seen -- target|0 }
\ Equal-distance successors follow source order. Only the previous address
\ is retained; neither catalogue links nor FITS region links are rewritten.
    validate-target-query
    0 to best
    0 to best-distance
    0 to seen
    previous if previous target-distance else -1 then to previous-distance
    list TARGETLIST.FIRST + @ to target
    begin target while
        target previous = if -1 to seen then
        target target-visible? if
            target target-distance to distance
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

: nearest-target ( list -- target|0 ) 0 next-target ;

: walk-targets { list action | target -- }
    list nearest-target to target
    begin target while
        target action execute
        list target next-target to target
    repeat
;
