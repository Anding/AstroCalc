\ Dictionary-resident targets and buffer-free, snapshot-based selection.
\ Each record belongs to one catalogue; query subsets never relink records.
\
\ USER NOTES
\ NEED TargetLists loads HorizonMasks and SkyRegions as dependencies.
\ Targets are J2000 equatorial points, not regions or equipment commands.
\ RA is integer time seconds; Dec and distances are angular arcseconds.
\ Use RA/Dec constructors, making every nonzero negative component negative.
\ Magnitudes are integer millimagnitudes: -1460 means -1.460, 4199 means
\ 4.199.  Use magnitude-unknown, not zero, when no magnitude is known.
\ The catalogue must state its magnitude band; selection does not use it.
\
\   BEGIN-TARGETLIST my-targets
\   05 35 16 RA -05 -23 -23 Dec magnitude-unknown POINT-TARGET: M42
\   END-TARGETLIST
\   M42 target-coordinates                 \ -- RA Dec
\   M42 target-name                        \ -- caddr u
\
\ Before querying, supply a coherent snapshot: SkyDate (UTC yyyy mm dd ~),
\ LST (local sidereal time) and Latitude.  This library does not read a clock
\ or derive LST from Longitude.  Ranking coordinates on the stack are J2000;
\ use HZtoJ2000 to convert an Alt/Az reference with the same sky snapshot.
\   2026 10 13 ~ -> SkyDate
\   06 00 00 RA -> LST
\   22 18 00 DEGMMSS -> Latitude
\   35 00 00 Alt -> targets.minimum-altitude
\   my-targets M42 target-coordinates nearest-target  \ -- target|0
\
\ Set targets.maximum-altitude, targets.meridian-side and targets.mask
\ explicitly when required.  Defaults allow -90..+90 degrees, either side
\ of the meridian, but reject Alt<0 via default-horizon-mask.  Assigning
\ zero to targets.mask disables obstruction testing, not altitude bounds.
\ Masks are Alt/Az blocked regions, independent of equatorial FITS lists.
\ Selection is not slew-path validation: refresh and recheck before motion.
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
\ Define a word ( -- list ) and open an empty dictionary-resident catalogue.
\ Subsequent POINT-TARGET: declarations append in source order until
\ END-TARGETLIST.  Empty lists are valid; nested declarations are not.
\ Unlike regionlists, target lists have no global registry or final default.
    active-targetlist abort" Nested target list"
    create here /TARGETLIST allot
    dup /TARGETLIST erase to active-targetlist
DOES> ( -- list )
;

: END-TARGETLIST ( -- )
\ Close construction without querying or activating anything.  The named
\ list and its target records remain available for the dictionary lifetime.
    active-targetlist 0= abort" No open target list"
    0 to active-targetlist
;

: append-target { target | last -- }
\ O(1) append using the list tail; target must have a zero NEXT link and
\ belong to no other list.  With no open list it remains standalone.
    active-targetlist 0= if exit then
    active-targetlist TARGETLIST.LAST + @ to last
    last if target last TARGET.NEXT + !
    else target active-targetlist TARGETLIST.FIRST + ! then
    target active-targetlist TARGETLIST.LAST + !
;

: define-target
    { RA Dec magnitude |
      name-addr name-u target -- target }
\ Shared defining-word implementation: parse one nonempty Forth name,
\ CREATE its fixed record, copy that name into dictionary string storage,
\ then append to the open catalogue.  The caller supplies DOES> behavior.
\ Coordinates and magnitude are stored as supplied, without validation.
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
\ Return stored J2000 coordinates, not the precessed query position.
    dup TARGET.RA + @ swap TARGET.DEC + @
;
: target-name ( target -- caddr u ) TARGET.NAME + @ count ;
: target-magnitude ( target -- millimagnitudes ) TARGET.MAGNITUDE + @ ;

: .magnitude ( millimagnitudes -- )
\ Print a signed value to three decimal places, or "unknown" for the
\ sentinel.  No separator or newline is emitted.
    dup magnitude-unknown = if drop s" unknown" type exit then
    dup 0< if '-' emit then
    abs 0 <# # # # '.' hold #s #> type
;

: POINT-TARGET: ( RA Dec millimagnitudes "name" -- )
\ Define a named J2000 point; executing name returns ( -- target ).
\ The parsed dictionary name is also its stored catalogue name.  No popular
\ label, region radius or visibility state is stored.  May be used outside
\ BEGIN/END-TARGETLIST to make a standalone target.
    define-target drop
DOES> ( -- target ) ;

: each-target { list action | target -- }
\ Visit every record in declaration order, without visibility filtering or
\ distance ranking.  action has effect ( target -- ); do not change links.
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
\
\ Policy uses sky side, not mount pier side: east means negative hour angle,
\ west means zero or positive hour angle.  Altitude bounds include endpoints.
\ Keep these values and the shared sky snapshot fixed throughout a walk.

: with-meridian-side ( i*x side xt -- j*x )
    { side action | previous ior -- }
\ Execute ( i*x -- j*x ) with scoped policy, restoring it before rethrowing.
    targets.meridian-side to previous
    side to targets.meridian-side
    action catch to ior
    previous to targets.meridian-side
    ior throw
;

: validate-target-query ( -- )
\ Selection entry points reject a missing date, inverted altitude limits,
\ or an unknown meridian policy.  Site/LST coherence remains the caller's job.
    SkyDate 0= abort" Target query needs a UTC date"
    targets.minimum-altitude targets.maximum-altitude >
        abort" Inverted target altitude bounds"
    targets.meridian-side meridian-indifferent meridian-west 1+ within 0=
        abort" Invalid meridian side"
;

: target-visible? { target | RA Dec hour-angle altitude azimuth -- flag }
\ Precess the stored J2000 position to SkyDate, derive hour angle from LST,
\ filter sky side, then convert to Alt/Az at Latitude.  Accept only inclusive
\ altitude limits and a clear horizon mask.  No result is cached in target.
\ Direct callers must establish valid query state; next-target validates it.
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
\ Great-circle separation from a J2000 reference, in angular arcseconds.
\ Ranking deliberately uses catalogue positions, not the Alt/Az test frame.
    target target-coordinates RA Dec ang_sep
;

: next-target
    { list previous RA Dec | target best distance best-distance previous-distance seen -- target|0 }
\ Equal-distance successors follow source order. Only the previous address
\ is retained; neither catalogue links nor FITS region links are rewritten.
\ Algorithm: scan the catalogue, discarding invisible entries and anything
\ before or equal to the previous result in (distance, source-order) order.
\ The previous target's distance is the lower threshold; SEEN permits
\ equal-distance entries only after its address has been passed in the scan.
\ Keep the nearest eligible candidate; strict improvement preserves the first
\ source entry on ties.  Zero previous starts with distance threshold -1.
\ Zero result means exhausted/no visible target; a foreign previous is an
\ error even if that target would currently be invisible.
\ Each call is O(N) with O(1) auxiliary storage and no result buffer.
\ Continue with the same list, reference, sky state and policy; changing
\ these mid-walk does not define a stable ordering or visibility snapshot.
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
\ Start a distance-ranked visible selection; zero means no eligible target.
    list 0 RA Dec next-target
;

: walk-targets { list RA Dec action | target -- }
\ Visit visible targets by increasing separation, calling action with
\ ( target distance -- ).  Ties retain source order; empty selection calls
\ nothing.  A complete walk of K results costs O((K+1)*N), trading repeated
\ scans for no allocated sorting buffer.  Each callback must consume its
\ arguments and leave sky state, policy and catalogue links unchanged.
    list RA Dec nearest-target to target
    begin target while
        target target RA Dec target-distance action execute
        list target RA Dec next-target to target
    repeat
;
