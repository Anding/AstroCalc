\ Structured named spherical regions, independent of coordinate frame.
\ Longitude uses time seconds; latitude and radius use angular arcseconds.
\ RA/Dec parameter names are conventional, not a frame restriction.
\
\ Region and regionlist words return parameter-field addresses.  All region
\ records share one header and dispatch through a stored predicate xt.  An
\ open regionlist collects regions in source order; END-REGIONLIST then links
\ the completed list into the global list consulted by imaging metadata.
\
\ USER NOTES
\ Load with NEED SkyRegions; this defines mechanisms, not catalogues.
\ The caller owns the frame and epoch: use consistent coordinates for both
\ declarations and queries.  No precession or frame conversion occurs here.
\ Equatorial lists normally use J2000.  For horizon regions convert azimuth
\ with HorizonMasks' azimuth>longitude; latitude is then altitude.
\ RA, Dec and DEGMMSS build single-cell values from three integers.
\ Every nonzero component of a negative angle must be negative:
\ -05 -23 -23 Dec is -5 degrees 23 minutes 23 seconds.
\
\ Each geometry defining word parses the following Forth name and creates
\ a word with runtime effect ( -- region ), not a boolean test.  Its two
\ strings are a stable metadata ID and a human-readable label; both are
\ copied.  Use region-inside? for a direct test, or search-regionlist for
\ first-match classification.  Source order, not size or proximity, wins.
\
\ SkyRegions_test.f is the executable user tutorial: declarations, geometry
\ boundaries, first-match priority, independent lists and registry traversal.
\ SkyRegions_test1.f retains the wider catalogue and geometry regressions.
\
\ Lists and records live in the dictionary; queries allocate nothing.
\ Include a catalogue once: completing a list registers it automatically.
\ Do not redefine its words expecting old records to be removed.
\
\ CATALOGUES AND IMAGING
\ Keep catalogue data separate from this mechanism.  Begin a catalogue with
\ NEED SkyRegions and document its coordinate source and epoch.  Declare
\ specific regions in deliberate priority order and finish with one default.
\ Generated catalogues should identify their source version and generator;
\ change the generator rather than editing its output independently.
\ A target-association circle's radius is a matching tolerance, not
\ necessarily the object's physical extent.  AIF's Messier generator uses
\ an explicit five-arcminute radius, adjustable per entry.
\
\ AstroImagingInForth's AstroImagingTargets capability loads the default
\ fits-target-regions list.  At exposure time the pipeline uses the captured
\ mount J2000 coordinate to search this list for OBJECT, then searches every
\ registered list independently and records its FITS key and matched ID
\ under #REGION.  REGTARG deliberately repeats the primary target lookup.
\ Optional lists need only be included; no pipeline modification is needed.
\ Evaluating M42 returns a target reference without changing metadata state.
\ M42 goto-target is AIF's separate equipment operation, not part of this
\ library.  Standalone regions are not automatically searched for metadata.

need AstroCalc

\ Common dictionary-resident region record.  NEXT gives a region single-list
\ membership: do not append the same record to two lists.  PREDICATE provides
\ geometry dispatch; defining words own DATA0..DATA3 and must document them.
\ ID and LABEL point to counted strings.  To add a geometry, implement
\ ( longitude latitude region -- flag ), CREATE a word, compile this header
\ with its predicate xt, fill DATA cells, append-region, and use an empty
\ DOES> so the created word returns its record.  If four data cells are
\ insufficient, store a pointer to a separate dictionary descriptor.
0 cells constant REGION.NEXT
1 cells constant REGION.PREDICATE
2 cells constant REGION.ID
3 cells constant REGION.LABEL
4 cells constant REGION.DATA0
5 cells constant REGION.DATA1
6 cells constant REGION.DATA2
7 cells constant REGION.DATA3
8 cells constant /REGION

\ Regionlist records are also dictionary-resident and linked in inclusion
\ order.  The record address returned by the defining word is its identity;
\ only its display name and FITS key need stored strings.  FIRST/LAST make
\ catalogue construction O(1) per append without relying on dictionary order.
0 cells constant REGIONLIST.NEXT
1 cells constant REGIONLIST.NAME
2 cells constant REGIONLIST.FITS
3 cells constant REGIONLIST.FIRST
4 cells constant REGIONLIST.LAST
5 cells constant /REGIONLIST

\ These values are catalogue-construction state, not runtime search state.
\ Regionlist and polygon declarations are intentionally non-nestable.  The
\ first/last pair is the permanent session registry: there is deliberately no
\ removal or activation layer because inclusion means use.
0 value active-regionlist
0 value first-regionlist
0 value last-regionlist
0 value sky-polygon-start
0 value sky-polygon-count
0 value sky-polygon-building

: store-region-string ( caddr u field -- )
\ Copy a string into permanent dictionary storage and make field point to it.
\ Callers may therefore pass transient input strings; region records own the
\ compiled copies for the lifetime of the dictionary.
	>R here R> ! $,
;

: compile-region-header
	{ predicate id-addr id-u label-addr label-u | region -- region }
\ Compile the geometry-independent part of a region record.
\ The caller fills DATA0..DATA3 and then calls append-region.  HERE is saved
\ before the counted strings because the fixed offsets address only the header.
	id-u 0= abort" Region ID must not be empty"
	label-u 0= abort" Region label must not be empty"
	here to region
	0 , predicate , 0 , 0 , 0 , 0 , 0 , 0 ,
	id-addr id-u region REGION.ID + store-region-string
	label-addr label-u region REGION.LABEL + store-region-string
	region
;

: append-region { region | last -- }
\ Append in declaration order when a list is open.  Outside a list the region
\ remains a useful standalone object.  REGION.NEXT must still be zero from
\ compile-region-header; one region record cannot safely belong to two lists.
	active-regionlist 0= if exit then
	active-regionlist REGIONLIST.LAST + @ to last
	last 0= if
		region active-regionlist REGIONLIST.FIRST + !
	else
		region last REGION.NEXT + !
	then
	region active-regionlist REGIONLIST.LAST + !
;

: region-id ( region -- caddr u )
\ Return the stable machine-readable identity.
	REGION.ID + @ count
;

: region-label ( region -- caddr u )
\ Return the human-readable display label.
	REGION.LABEL + @ count
;

: region-inside? ( RA Dec region -- flag )
\ Dispatch without exposing the geometry-specific record contents.
\ DUP leaves the region address below the predicate xt for EXECUTE.  Every
\ geometry predicate therefore receives both the query coordinate and record.
	dup REGION.PREDICATE + @ execute
;

: circle-region-inside? { RA Dec region -- flag }
\ DATA0=center RA, DATA1=center Dec, DATA2=angular radius.
\ Circle boundaries are included.
	RA Dec
	region REGION.DATA0 + @
	region REGION.DATA1 + @
	ang_sep
	region REGION.DATA2 + @ <=
;

: box-test { RA Dec RA1 Dec1 RA2 Dec2 -- flag }
\ Test a half-open RA/Dec rectangle.  RA1>RA2 denotes a rectangle crossing
\ 00h; XOR then selects either side of the discontinuity.  Half-open bounds
\ let adjacent catalogue strips meet without matching twice at an edge.
	Dec Dec1 >= Dec Dec2 < and 0= if 0 exit then
	RA RA1 >= RA RA2 <
	RA1 RA2 > if xor else and then
;

: strip-region-inside? { RA Dec region -- flag }
\ DATA0..DATA3 contain RA1, Dec1, RA2, Dec2.
	RA Dec
	region REGION.DATA0 + @
	region REGION.DATA1 + @
	region REGION.DATA2 + @
	region REGION.DATA3 + @
	box-test
;

: below-region-inside? { longitude latitude region -- flag }
\ DATA0=latitude ceiling.  Longitude is ignored; the boundary is excluded.
    latitude region REGION.DATA0 + @ <
;

: band-region-inside? { longitude latitude region | first last -- flag }
\ Inclusive bounds; longitude may wrap through 00h.
\ DATA0..DATA3 contain longitude1, latitude1, longitude2, latitude2.
    latitude region REGION.DATA1 + @ >=
    latitude region REGION.DATA3 + @ <= and 0= if 0 exit then
    region REGION.DATA0 + @ to first
    region REGION.DATA2 + @ to last
    longitude first >= longitude last <=
    first last > if or else and then
;

: default-region-inside? ( RA Dec region -- flag )
\ The final region in every list supplies total classification.
	drop 2drop -1
;

: polygon-region-inside? { RA Dec region -- flag }
\ DATA0 points to packed RA/Dec cells and DATA1 is the vertex count.
\ C converts the query and vertices to 3-D unit vectors.  Each adjacent
\ vertex pair, including last-to-first, gives an edge normal by cross product.
\ Dot products with the query must have consistent signs; near-zero products
\ count as boundary hits.  Either winding works and 00h needs no special case.
\ Degenerate edges are rejected.  This is O(vertices), not a planar ray cast.
	RA Dec
	region REGION.DATA0 + @
	region REGION.DATA1 + @
	spherical_polygon_contains 0<>
;

: check-circle-radius ( radius -- )
\ Validate before CREATE so a negative radius does not leave a named record.
	0< abort" Negative region radius"
;

: compile-circle-region
	{ center-RA center-Dec radius id-addr id-u label-addr label-u | region -- region }
\ Shared record compiler for circle-based defining words.  The caller must
\ validate radius before CREATE, then append the returned record as required.
\ DATA3 remains unused; geometry and strings have dictionary lifetime.
	['] circle-region-inside?
	id-addr id-u label-addr label-u compile-region-header to region
	center-RA region REGION.DATA0 + !
	center-Dec region REGION.DATA1 + !
	radius region REGION.DATA2 + !
	region
;

: sky-circle
	{ center-RA center-Dec radius id-addr id-u label-addr label-u -- }
\ Define ( ... "name" -- ): a spherical cap centred on the supplied position.
\ Radius is angular arcseconds, not longitude time seconds.  A point matches
\ when ang_sep <= radius, including the circumference; zero radius is valid.
\ Append to the open list, or leave a standalone region if no list is open.
	radius check-circle-radius
	create
	center-RA center-Dec radius id-addr id-u label-addr label-u
		compile-circle-region append-region
DOES> ( -- region )
;

: sky-strip
	{ RA1 Dec1 RA2 Dec2 id-addr id-u label-addr label-u -- }
\ Define a word returning a half-open RA/Dec strip record.
\ Defining syntax: RA1 Dec1 RA2 Dec2 s" id" s" label" sky-strip name
\ Bounds are [Dec1,Dec2) and [RA1,RA2); RA1>RA2 wraps through 00h.
\ Equal RA bounds match nothing.  Use 00h and 24h for all longitudes.
\ Supply ordered latitude bounds; this word does not validate them.
\ Edges follow coordinate lines, unlike polygon great-circle edges.
	create
	['] strip-region-inside?
	id-addr id-u label-addr label-u compile-region-header
	>R
	RA1 R@ REGION.DATA0 + !
	Dec1 R@ REGION.DATA1 + !
	RA2 R@ REGION.DATA2 + !
	Dec2 R@ REGION.DATA3 + !
	R> append-region
DOES> ( -- region )
;

: sky-below { latitude id-addr id-u label-addr label-u -- }
\ Define ( latitude s" id" s" label" "name" -- ) for all longitudes
\ strictly below latitude.  Useful for ground or other latitude cutoffs;
\ a point exactly on the cutoff is not inside.  DATA0 stores the cutoff.
    create
    ['] below-region-inside?
    id-addr id-u label-addr label-u compile-region-header
    >R
    latitude R@ REGION.DATA0 + !
    R> append-region
DOES> ( -- region ) ;

: sky-band
    { longitude1 latitude1 longitude2 latitude2 id-addr id-u label-addr label-u -- }
\ Define ( ... "name" -- ): a coordinate band including all four boundaries.
\ Longitude1>longitude2 wraps through 00h; equal endpoints select one
\ meridian, not the full circle.  Use explicit 00h and 24h bounds for that.
\ Do not normalise the 24h endpoint as a position: it would become 00h.
\ Latitude1 must be <= latitude2.  DATA0..DATA3 store the four bounds.
    latitude1 latitude2 > abort" Inverted region latitude bounds"
    create
    ['] band-region-inside?
    id-addr id-u label-addr label-u compile-region-header
    >R
    longitude1 R@ REGION.DATA0 + !
    latitude1 R@ REGION.DATA1 + !
    longitude2 R@ REGION.DATA2 + !
    latitude2 R@ REGION.DATA3 + !
    R> append-region
DOES> ( -- region ) ;

: sky-default
	{ id-addr id-u label-addr label-u -- }
\ Define an unconditional region, normally the last declaration in a list.
\ Defining syntax: s" id" s" label" sky-default name
\ This supplies an explicit fallback label/ID, not a missing-value sentinel.
\ Put it only at the end: any later regions would be unreachable by search.
	create
	['] default-region-inside?
	id-addr id-u label-addr label-u compile-region-header
	append-region
DOES> ( -- region )
;

: BEGIN-SKY-POLYGON ( -- )
\ Remember where the packed vertex array begins in the dictionary.  Vertices
\ are compiled before the region record, which later points back to this array.
\ Begin a non-nestable declaration, completed by END-SKY-POLYGON name.
\ Compile only SKY-VERTEX pairs in between; unrelated dictionary allocations
\ would break the packed array.  Do not repeat the first vertex at the end.
	sky-polygon-building abort" Nested sky polygon"
	here to sky-polygon-start
	0 to sky-polygon-count
	-1 to sky-polygon-building
;

: SKY-VERTEX ( RA Dec -- )
\ Compile one RA,Dec pair in the order expected by AstroCalc.dll.  SWAP makes
\ memory contain RA followed by Dec even though comma consumes stack top first.
	sky-polygon-building 0= abort" SKY-VERTEX outside sky polygon"
	swap , ,
	sky-polygon-count 1+ to sky-polygon-count
;

: END-SKY-POLYGON
	{ id-addr id-u label-addr label-u -- }
\ Finish the vertex array and define a word returning its polygon record.
\ Convexity and winding are numerical concerns; only cardinality is checked
\ while compiling the catalogue.  DATA0 owns the stable dictionary address;
\ DATA1 is the vertex count passed unchanged to the C predicate.
\ Defining syntax: s" id" s" label" END-SKY-POLYGON name
\ Supply at least three ordered vertices of a convex polygon smaller than
\ a hemisphere, with no duplicate adjacent or antipodal adjacent vertices.
\ The caller must ensure this geometry; declaration checks only vertex count.
\ Edges are great-circle arcs, not constant-latitude segments.  Boundary
\ points are included.  Use several convex regions for a concave outline.
	sky-polygon-building 0= abort" END-SKY-POLYGON without BEGIN-SKY-POLYGON"
	sky-polygon-count 3 < if
		0 to sky-polygon-building
		abort" A sky polygon needs at least three vertices"
	then
	create
	['] polygon-region-inside?
	id-addr id-u label-addr label-u compile-region-header
	>R
	sky-polygon-start R@ REGION.DATA0 + !
	sky-polygon-count R@ REGION.DATA1 + !
	R> append-region
	0 to sky-polygon-building
DOES> ( -- region )
;

: BEGIN-REGIONLIST
	{ name-addr name-u fits-addr fits-u | list -- }
\ Define a named list and make it the destination for subsequent regions.
\ The CREATE body is the list's public identity.  The completed list becomes
\ active automatically at END-REGIONLIST, never at BEGIN, so an incomplete
\ declaration cannot be searched through the session registry.
\ Defining syntax: s" display name" s" FITSKEY" BEGIN-REGIONLIST name
\ The created name returns ( -- regionlist ); regions declared until
\ END-REGIONLIST append here in source order.  Lists cannot be nested.
\ Display name must be nonempty; FITS key length must be 1..8 characters.
	active-regionlist abort" Nested regionlist"
	name-u 0= abort" Regionlist name must not be empty"
	fits-u 0= fits-u 8 > or abort" FITS name must contain 1..8 characters"
	create
	here to list
	0 , 0 , 0 , 0 , 0 ,
	name-addr name-u list REGIONLIST.NAME + store-region-string
	fits-addr fits-u list REGIONLIST.FITS + store-region-string
	list to active-regionlist
DOES> ( -- regionlist )
;

: END-REGIONLIST { | list -- }
\ Close, validate, and activate the list in inclusion order.  Catalogue files
\ need no registration word: if a regionlist is included, it is used.  Linking
\ only here also guarantees registered lists are non-empty and end in default.
\ The last predicate is checked, but earlier defaults are not rejected:
\ keep exactly one default at the end to avoid hiding later declarations.
	active-regionlist 0= abort" END-REGIONLIST without BEGIN-REGIONLIST"
	active-regionlist to list
	list REGIONLIST.LAST + @
	dup 0= abort" Empty regionlist"
	REGION.PREDICATE + @ ['] default-region-inside? <>
	abort" Regionlist must end with a default region"
	last-regionlist 0= if
		list to first-regionlist
	else
		list last-regionlist REGIONLIST.NEXT + !
	then
	list to last-regionlist
	0 to active-regionlist
;

: regionlist-name ( regionlist -- caddr u )
\ Return the human-readable list name.
	REGIONLIST.NAME + @ count
;

: regionlist-fits-key ( regionlist -- caddr u )
\ Return the validated 1..8 character FITS keyword.
	REGIONLIST.FITS + @ count
;

: next-regionlist ( regionlist -- next-regionlist )
\ Traverse the automatic registry without exposing the NEXT field offset.
	REGIONLIST.NEXT + @
;

: search-regionlist { RA Dec regionlist | region -- region|0 }
\ Search in declaration order and return the first matching region record.
\ Overlap is intentional: source order is priority for every geometry.  A
\ well-formed list always reaches its final default before returning zero.
\ O(number of regions), O(1) auxiliary storage; no sorting or relinking.
\ Nonregistered lists such as horizon masks may omit a default; zero then
\ means no match.  This routine does not check coordinate frame or epoch.
	regionlist REGIONLIST.FIRST + @ to region
	begin region while
		RA Dec region region-inside? if region exit then
		region REGION.NEXT + @ to region
	repeat
	0
;
