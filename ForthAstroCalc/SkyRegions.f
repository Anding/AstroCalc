\ Structured named regions of the J2000 sky

need AstroCalc

0 cells constant REGION.NEXT
1 cells constant REGION.PREDICATE
2 cells constant REGION.ID
3 cells constant REGION.LABEL
4 cells constant REGION.DATA0
5 cells constant REGION.DATA1
6 cells constant REGION.DATA2
7 cells constant REGION.DATA3
8 cells constant /REGION

0 cells constant REGIONSET.ID
1 cells constant REGIONSET.LABEL
2 cells constant REGIONSET.FITS
3 cells constant REGIONSET.FIRST
4 cells constant REGIONSET.LAST
5 cells constant /REGIONSET

0 value active-region-set
0 value sky-polygon-start
0 value sky-polygon-count
0 value sky-polygon-building

: store-region-string ( caddr u field -- )
	>R here R> ! $,
;

: compile-region-header
	{ predicate id-addr id-u label-addr label-u | region -- region }
	id-u 0= abort" Region ID must not be empty"
	label-u 0= abort" Region label must not be empty"
	here to region
	0 , predicate , 0 , 0 , 0 , 0 , 0 , 0 ,
	id-addr id-u region REGION.ID + store-region-string
	label-addr label-u region REGION.LABEL + store-region-string
	region
;

: append-region { region | last -- }
	active-region-set 0= if exit then
	active-region-set REGIONSET.LAST + @ to last
	last 0= if
		region active-region-set REGIONSET.FIRST + !
	else
		region last REGION.NEXT + !
	then
	region active-region-set REGIONSET.LAST + !
;

: region-id ( region -- caddr u )
	REGION.ID + @ count
;

: region-label ( region -- caddr u )
	REGION.LABEL + @ count
;

: region-inside? ( RA Dec region -- flag )
	dup REGION.PREDICATE + @ execute
;

: circle-region-inside? { RA Dec region -- flag }
	RA Dec
	region REGION.DATA0 + @
	region REGION.DATA1 + @
	ang_sep
	region REGION.DATA2 + @ <=
;

: box-test { RA Dec RA1 Dec1 RA2 Dec2 -- flag }
	Dec Dec1 >= Dec Dec2 < and 0= if 0 exit then
	RA RA1 >= RA RA2 <
	RA1 RA2 > if xor else and then
;

: strip-region-inside? { RA Dec region -- flag }
	RA Dec
	region REGION.DATA0 + @
	region REGION.DATA1 + @
	region REGION.DATA2 + @
	region REGION.DATA3 + @
	box-test
;

: default-region-inside? ( RA Dec region -- flag )
	drop 2drop -1
;

: polygon-region-inside? { RA Dec region -- flag }
	RA Dec
	region REGION.DATA0 + @
	region REGION.DATA1 + @
	spherical_polygon_contains 0<>
;

: sky-circle
	{ center-RA center-Dec radius id-addr id-u label-addr label-u -- }
	create
	['] circle-region-inside?
	id-addr id-u label-addr label-u compile-region-header
	dup >R
	center-RA R@ REGION.DATA0 + !
	center-Dec R@ REGION.DATA1 + !
	radius R@ REGION.DATA2 + !
	R> append-region
DOES> ( -- region )
;

: sky-strip
	{ RA1 Dec1 RA2 Dec2 id-addr id-u label-addr label-u -- }
	create
	['] strip-region-inside?
	id-addr id-u label-addr label-u compile-region-header
	dup >R
	RA1 R@ REGION.DATA0 + !
	Dec1 R@ REGION.DATA1 + !
	RA2 R@ REGION.DATA2 + !
	Dec2 R@ REGION.DATA3 + !
	R> append-region
DOES> ( -- region )
;

: sky-default
	{ id-addr id-u label-addr label-u -- }
	create
	['] default-region-inside?
	id-addr id-u label-addr label-u compile-region-header
	append-region
DOES> ( -- region )
;

: BEGIN-SKY-POLYGON ( -- )
	sky-polygon-building abort" Nested sky polygon"
	here to sky-polygon-start
	0 to sky-polygon-count
	-1 to sky-polygon-building
;

: SKY-VERTEX ( RA Dec -- )
	sky-polygon-building 0= abort" SKY-VERTEX outside sky polygon"
	swap , ,
	sky-polygon-count 1+ to sky-polygon-count
;

: END-SKY-POLYGON
	{ id-addr id-u label-addr label-u -- }
	sky-polygon-building 0= abort" END-SKY-POLYGON without BEGIN-SKY-POLYGON"
	sky-polygon-count 3 < if
		0 to sky-polygon-building
		abort" A sky polygon needs at least three vertices"
	then
	create
	['] polygon-region-inside?
	id-addr id-u label-addr label-u compile-region-header
	dup >R
	sky-polygon-start R@ REGION.DATA0 + !
	sky-polygon-count R@ REGION.DATA1 + !
	R> append-region
	0 to sky-polygon-building
DOES> ( -- region )
;

: BEGIN-REGIONSET
	{ id-addr id-u label-addr label-u fits-addr fits-u | set -- }
	active-region-set abort" Nested region set"
	id-u 0= abort" Region set ID must not be empty"
	label-u 0= abort" Region set label must not be empty"
	fits-u 0= fits-u 8 > or abort" FITS name must contain 1..8 characters"
	create
	here to set
	0 , 0 , 0 , 0 , 0 ,
	id-addr id-u set REGIONSET.ID + store-region-string
	label-addr label-u set REGIONSET.LABEL + store-region-string
	fits-addr fits-u set REGIONSET.FITS + store-region-string
	set to active-region-set
DOES> ( -- region-set )
;

: END-REGIONSET ( -- )
	active-region-set 0= abort" END-REGIONSET without BEGIN-REGIONSET"
	active-region-set REGIONSET.LAST + @
	dup 0= abort" Empty region set"
	REGION.PREDICATE + @ ['] default-region-inside? <>
	abort" Region set must end with a default region"
	0 to active-region-set
;

: region-set-id ( region-set -- caddr u )
	REGIONSET.ID + @ count
;

: region-set-label ( region-set -- caddr u )
	REGIONSET.LABEL + @ count
;

: region-set-fits-name ( region-set -- caddr u )
	REGIONSET.FITS + @ count
;

: classify-region-set { RA Dec region-set | region -- region|0 }
	region-set REGIONSET.FIRST + @ to region
	begin region while
		RA Dec region region-inside? if region exit then
		region REGION.NEXT + @ to region
	repeat
	0
;

