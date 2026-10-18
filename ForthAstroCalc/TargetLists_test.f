\ TargetLists executable user tutorial.
\
\ Include once in a fresh development session with the ForthBase NEED
\ registry installed.  No equipment is connected, no clock is read, and no
\ slew is requested.  Sky/policy values are restored at the end; dictionary
\ definitions remain.  Run SkyRegions_test.f to learn the region geometries.
\
\ PowerShell, from E:\coding\AstroImagingInForth:
\   & '..\VFXForth\Tools\VFXControl.ps1' Start -Session target-tutorial
\   & '..\VFXForth\Tools\VFXControl.ps1' Test `
\       'E:\coding\AstroCalc\ForthAstroCalc\TargetLists_test.f' `
\       -Session target-tutorial -TestTimeoutSeconds 30
\   & '..\VFXForth\Tools\VFXControl.ps1' Stop -Session target-tutorial
\
\ T{ code }T expected-stack-items == checks and consumes the results.
\ Tend reports REGRESSION PASSED/FAILED; the caller, not this file, exits.

NEED TargetLists
NEED simple-tester

depth constant target-demo-depth
SkyDate constant target-demo-old-date
LST constant target-demo-old-lst
Latitude constant target-demo-old-latitude
targets.minimum-altitude constant target-demo-old-minimum
targets.maximum-altitude constant target-demo-old-maximum
targets.meridian-side constant target-demo-old-side
targets.mask constant target-demo-old-mask
first-regionlist constant target-demo-old-registry

Tstart

\ 1. Declare catalogue data as executable Forth.
\
\ These are synthetic J2000 equatorial points, chosen for simple ordering.
\ Source order intentionally differs from distance order.  The two "near"
\ targets share coordinates to demonstrate tie handling.  Magnitudes here
\ are invented examples, not measured photometry in a real passband.
BEGIN-TARGETLIST target-demo-list
12 00 00 RA 0 magnitude-unknown POINT-TARGET: target-demo-far
06 00 00 RA 0 -1460 POINT-TARGET: target-demo-near-a
08 00 00 RA 0 0 POINT-TARGET: target-demo-middle
06 00 00 RA 0 4199 POINT-TARGET: target-demo-near-b
END-TARGETLIST

\ Executing a target word leaves its record reference; it neither supplies
\ coordinates directly nor changes equipment or a "current target" global.
\ The parsed Forth name is also the catalogue name.  Magnitudes are integer
\ thousandths: negative and zero are valid; unknown is a distinct sentinel.
T{ target-demo-near-a target-coordinates }T 06 00 00 RA 0 ==
T{ target-demo-near-a target-name hashS }T s" target-demo-near-a" hashS ==
T{ target-demo-near-a target-magnitude }T -1460 ==
T{ target-demo-middle target-magnitude }T 0 ==
T{ target-demo-near-b target-magnitude }T 4199 ==
T{ target-demo-far target-magnitude }T magnitude-unknown ==

\ A display consumer is ordinary Forth.  .magnitude emits no separator, so
\ the caller supplies spaces/newlines.  Real catalogues must identify their
\ magnitude band; values in different bands are not interchangeable.
: target-demo-show ( target -- )
    dup target-name type space
    target-magnitude .magnitude cr
;
target-demo-list ' target-demo-show each-target

\ each-target visits ALL records in source order, with ( target -- ).
\ Selection never constructs subsets by moving/relinking these records.
\ A target record must belong to at most one list.
0 value target-demo-count
: target-demo-count-one ( target -- )
    drop target-demo-count 1+ to target-demo-count
;
target-demo-list ' target-demo-count-one each-target
T{ target-demo-count }T 4 ==

\ 2. Establish an explicit sky snapshot and query policy.
\
\ Use a UTC date, LOCAL sidereal time and observing latitude.  Longitude is
\ shared AstroCalc site state, but this query uses LST supplied by the caller
\ instead of deriving it again from longitude.  Here the equatorial site and
\ 07h LST put RA 06h west of the meridian and RA 08h east.
\ Date 2000-01-01 keeps these synthetic J2000 examples easy to recognise.
2000 01 01 ~ -> SkyDate
07 00 00 RA -> LST
0 -> Latitude
-90 00 00 Alt -> targets.minimum-altitude
90 00 00 Alt -> targets.maximum-altitude
meridian-indifferent -> targets.meridian-side
0 -> targets.mask

\ Zero mask deliberately disables obstructions for the ordering lesson.
\ It does NOT disable altitude limits.  Normal default-horizon-mask rejects
\ Alt<0, with no additional hidden horizon test elsewhere in selection.
\ Positions are converted J2000 -> date -> hour angle -> Alt/Az for visibility;
\ DISTANCE ranking remains great-circle separation in J2000 coordinates.
T{ target-demo-list 06 00 00 RA 0 nearest-target }T target-demo-near-a ==
T{ target-demo-near-a 06 00 00 RA 0 target-distance }T 0 ==

\ next-target continues after a previous record at the SAME reference and
\ snapshot.  Equal-distance targets follow source order, even at identical
\ coordinates.  Passing zero previous starts again; zero result means done.
T{ target-demo-list target-demo-near-a 06 00 00 RA 0 next-target }T target-demo-near-b ==
T{ target-demo-list target-demo-near-b 06 00 00 RA 0 next-target }T target-demo-middle ==
T{ target-demo-list target-demo-middle 06 00 00 RA 0 next-target }T target-demo-far ==
T{ target-demo-list target-demo-far 06 00 00 RA 0 next-target }T 0 ==

\ walk-targets automates continuation, passing ( target distance -- ) to
\ a consumer.  Distance is angular arcseconds.  Keep sky state, reference,
\ policy and links fixed for the entire walk, including inside callbacks.
: target-demo-visit ( target distance -- )
    swap target-name type space . ." arcseconds" cr
    target-demo-count 1+ to target-demo-count
;
0 to target-demo-count
target-demo-list 06 00 00 RA 0 ' target-demo-visit walk-targets
T{ target-demo-count }T 4 ==

\ One selection scans N records; K results cost roughly (K+1)*N evaluations.
\ Only the previous address and best candidate/distance are needed: no result
\ array, sorting buffer, or catalogue-link rewriting.
\ An empty list is valid; an all-filtered nonempty list also returns zero.
BEGIN-TARGETLIST target-demo-empty
END-TARGETLIST
T{ target-demo-empty 06 00 00 RA 0 nearest-target }T 0 ==

\ 3. Meridian and altitude policy.
\
\ Meridian side is SKY side, not mount pier side or safe slew policy.
\ East requires negative hour angle; west includes zero and positive.
\ with-meridian-side gives a scoped override and restores the old policy.
: target-demo-query ( -- target|0 )
    target-demo-list 06 00 00 RA 0 nearest-target
;
T{ meridian-east ' target-demo-query with-meridian-side }T target-demo-middle ==
T{ meridian-west ' target-demo-query with-meridian-side }T target-demo-near-a ==
T{ targets.meridian-side }T meridian-indifferent ==

\ Restoration also happens on THROW, and the original exception is rethrown.
: target-demo-throw ( -- ) -98 throw ;
: target-demo-scoped-error ( -- )
    meridian-east ['] target-demo-throw with-meridian-side
;
T{ ' target-demo-scoped-error catch }T -98 ==
T{ targets.meridian-side }T meridian-indifferent ==

\ Altitude limits are inclusive.  At this snapshot RA 06h and RA 08h are
\ about 75 degrees high; RA 12h is about 15 degrees high.
60 00 00 Alt -> targets.minimum-altitude
70 00 00 Alt -> targets.maximum-altitude
T{ target-demo-list 06 00 00 RA 0 nearest-target }T 0 ==
-90 00 00 Alt -> targets.minimum-altitude
90 00 00 Alt -> targets.maximum-altitude

\ An Alt/Az ranking reference must first become J2000 with this snapshot.
\ Round-trip a target through horizon coordinates to demonstrate the order
\ of arguments.  A small tolerance allows native integer-angle rounding.
T{ target-demo-near-a
    target-demo-near-a target-coordinates SkyDate LST Latitude J2000toHZ
    HZtoJ2000 target-distance 00 00 30 DEGMMSS <= }T -1 ==

\ 4. Obstructions are ordinary SkyRegions shapes in the horizon frame.
\
\ Masks are unions of BLOCKED regions.  No match means clear; unlike a
\ classification list they must not end in a catch-all default.  They never
\ join the FITS region registry.  The caller ensures frame consistency.
\ azimuth>longitude normalises angular azimuth to [0,360), then divides
\ arcseconds by 15 into time seconds (15 degrees = 1 hour).  This truncates
\ to 15-arcsecond azimuth resolution, including near mask boundaries.
BEGIN-HORIZON-MASK target-demo-observatory
0 s" ground" s" Below horizon" sky-below target-demo-ground
300 00 00 Az azimuth>longitude 0
60 00 00 Az azimuth>longitude 45 00 00 Alt
    s" building" s" Northern building" sky-band target-demo-building
180 00 00 Az azimuth>longitude 50 00 00 Alt 5 00 00 DEGMMSS
    s" small" s" Small obstruction" sky-circle target-demo-obstruction
END-HORIZON-MASK
target-demo-observatory -> targets.mask

\ A band crossing north includes both longitude and altitude endpoints;
\ sky-below is strictly below its cutoff, and circles include their edge.
\ horizon-blocked? takes angular altitude FIRST and angular azimuth SECOND.
T{ -1 180 00 00 Az targets.mask horizon-blocked? }T -1 ==
T{ 0 180 00 00 Az targets.mask horizon-blocked? }T 0 ==
T{ 40 00 00 Alt 0 targets.mask horizon-blocked? }T -1 ==
T{ 45 00 00 Alt 60 00 00 Az targets.mask horizon-blocked? }T -1 ==
T{ 46 00 00 Alt 0 targets.mask horizon-blocked? }T 0 ==
T{ 50 00 00 Alt 180 00 00 Az targets.mask horizon-blocked? }T -1 ==
T{ 15 00 00 Az azimuth>longitude }T 01 00 00 RA ==
T{ 360 00 00 Az azimuth>longitude }T 0 ==

\ Full-azimuth interval bounds are 00h and 24h, NOT 00h and 00h.
\ Do not convert 360 degrees for the upper endpoint: normalisation loses it.
BEGIN-HORIZON-MASK target-demo-all-azimuths
00 00 00 RA 35 00 00 Alt 24 00 00 RA 70 00 00 Alt
    s" all" s" All azimuths, 35 to 70 degrees" sky-band target-demo-all-band
END-HORIZON-MASK
T{ 50 00 00 Alt 180 00 00 Az target-demo-all-azimuths horizon-blocked? }T -1 ==
T{ 71 00 00 Alt 180 00 00 Az target-demo-all-azimuths horizon-blocked? }T 0 ==

\ Masks and targets did not register any FITS classification.
T{ first-regionlist }T target-demo-old-registry ==

\ Targets and sky regions are independent records.  When a metadata matching
\ circle is wanted, extract coordinates and specify an explicit radius.
\ A negative Dec example uses a minus on EVERY nonzero component.
05 35 16 RA -05 -23 -23 Dec magnitude-unknown POINT-TARGET: target-demo-M42
target-demo-M42 target-coordinates 00 05 00 DEGMMSS
    s" M42" s" Orion Nebula" sky-circle target-demo-M42-region
T{ target-demo-M42 target-coordinates target-demo-M42-region region-inside? }T -1 ==

\ 5. Invalid queries raise errors.
\
\ A previous target must actually belong to the queried list, not merely
\ share coordinates with a member.  This standalone point is not a member.
: target-demo-foreign-previous ( -- )
    target-demo-list target-demo-M42 06 00 00 RA 0 next-target drop
;
T{ ' target-demo-foreign-previous catch 0<> }T -1 ==

\ These errors are deliberate and caught; they are not failed assertions.
99 -> targets.meridian-side
T{ ' target-demo-query catch 0<> }T -1 ==
meridian-indifferent -> targets.meridian-side
90 00 00 Alt -> targets.minimum-altitude
0 -> targets.maximum-altitude
T{ ' target-demo-query catch 0<> }T -1 ==
-90 00 00 Alt -> targets.minimum-altitude
90 00 00 Alt -> targets.maximum-altitude
0 -> SkyDate
T{ ' target-demo-query catch 0<> }T -1 ==

\ In live use explicitly refresh context before a NEW query (AIF: skynow).
\ Selection neither moves equipment nor proves a slew path safe.  Recheck
\ the selected coordinate and equipment policy before commanding motion.
\ Restore the caller's sky and query policy; no dictionary data are removed.
target-demo-old-date -> SkyDate
target-demo-old-lst -> LST
target-demo-old-latitude -> Latitude
target-demo-old-minimum -> targets.minimum-altitude
target-demo-old-maximum -> targets.maximum-altitude
target-demo-old-side -> targets.meridian-side
target-demo-old-mask -> targets.mask
T{ depth }T target-demo-depth ==
Tend
