\ Structured named regions of the J2000 sky
\
\ Region and regionlist words return parameter-field addresses.  All region
\ records share one header and dispatch through a stored predicate xt.  An
\ open regionlist collects regions in source order; END-REGIONLIST then links
\ the completed list into the global list consulted by imaging metadata.

need AstroCalc

\ Common dictionary-resident region record.  NEXT gives a region single-list
\ membership: do not append the same record to two lists.  PREDICATE provides
\ geometry dispatch; defining words own DATA0..DATA3 and must document them.
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

: default-region-inside? ( RA Dec region -- flag )
\ The final region in every list supplies total classification.
	drop 2drop -1
;

: polygon-region-inside? { RA Dec region -- flag }
\ DATA0 points to packed RA/Dec cells and DATA1 is the vertex count.
\ The C function performs the numerical great-circle half-space tests.
	RA Dec
	region REGION.DATA0 + @
	region REGION.DATA1 + @
	spherical_polygon_contains 0<>
;

: sky-circle
	{ center-RA center-Dec radius id-addr id-u label-addr label-u -- }
\ Define a word returning a circle region record.
	create
	['] circle-region-inside?
	id-addr id-u label-addr label-u compile-region-header
	>R
	center-RA R@ REGION.DATA0 + !
	center-Dec R@ REGION.DATA1 + !
	radius R@ REGION.DATA2 + !
	R> append-region
DOES> ( -- region )
;

: sky-strip
	{ RA1 Dec1 RA2 Dec2 id-addr id-u label-addr label-u -- }
\ Define a word returning a half-open RA/Dec strip record.
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

: sky-default
	{ id-addr id-u label-addr label-u -- }
\ Define an unconditional region, normally the last declaration in a list.
	create
	['] default-region-inside?
	id-addr id-u label-addr label-u compile-region-header
	append-region
DOES> ( -- region )
;

: BEGIN-SKY-POLYGON ( -- )
\ Remember where the packed vertex array begins in the dictionary.  Vertices
\ are compiled before the region record, which later points back to this array.
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
	regionlist REGIONLIST.FIRST + @ to region
	begin region while
		RA Dec region region-inside? if region exit then
		region REGION.NEXT + @ to region
	repeat
	0
;
