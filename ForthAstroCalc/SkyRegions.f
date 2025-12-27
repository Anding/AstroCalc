\ define regions of the sky

need AstroCalc

: sky-region-circle
\ create a sky region that is a circle around a point
\ RA and Dec are finite fractions in single integer format
create  ( caddr u RA Dec rad <name> --) 
	>R >R , R> , R> , $, ( pfa: RA DEC rad u c1 c2 ... cn)
	
\ test if a coordinate lies within the region
DOES> ( RA' Dec' -- caddr u TRUE | FALSE)
	( pfa) >R
	R@ @ 				( RA' Dec' RA)
	R@ 1 cells+ @	( RA' Dec' RA Dec)
	.s
	ang_sep 			( deg)
	R@ 2 cells+ @	( deg rad)
	.s
	< if
		R> 3 cells+ count -1
	else
		R> drop 0
	then
;

: box-test { RA' Dec' RA1 Dec1 RA2 Dec2 | f -- flag }
\ test whether a coordinate lies within a bounding box
\ RA' Dec' is the test coordinate
\ RA1 Dec1 is the south west coordinate, RA2 Dec2 is the north east coordinate
\ of the bounding box
	RA1 RA2 > -> f 		\ wrap around RA 00 so invert the RA tests
	RA' RA1 >= f if 0= then
	Dec' Dec1 >=
	RA' RA2 < f if 0= then
	Dec' Dec2 <
	and and and
;

: sky-region-strip
\ create a sky region that is a strip
\ RA1 and Dec1 is the lower corner, RA2 and Dec2 is the upper corner of the inside of the strip
\ the strip must not cover RA = 0 
create  ( caddr u RA1 Dec1 RA2 Dec2 <name> --) 
	>R >R >R , R> , R> , R> , $, ( pfa: RA1 Dec1 RA2 Dec2 u c1 c2 ... cn)

\ test if a coordinate lies within the region
DOES> ( RA Dec -- caddr u TRUE | FALSE)
	( pfa) >R
	R@ @ 				( RA' Dec' RA1)
	R@ 1 cells+ @	( RA' Dec' RA1 Dec1)
	R@ 2 cells+ @	( RA' Dec' RA1 Dec1 RA2)	
	R@ 3 cells+ @	( RA' Dec' RA1 Dec1 RA2 Dec2)	
	box-test if
		R> 4 cells+ count -1
	else
		R> drop 0
	then
;   

: default-region
\ create a default sky region in case no other is found
create ( caddr u <name> --)
	$,
DOES>
	( pfa) count -1
;

: iterate-regions ( RA Dec nfa -- flag RA Dec)	\ nfa = name field address in the VFX dictionary header
	name>interpret ( RA Dec xt)
	>R 2dup R>		( RA Dec RA Dec xt)
	execute 			( RA Dec FALSE | RA Dec c-addr u TRUE)
	?dup 0=			( RA Dec TRUE  | RA Dec c-addr u TRUE FALSE)	
	\ top flag tells traverse-wordlist whether to continue
;

: BEGIN-REGION-SET
	get-current wordlist 	
	create ( wid <name> -- current-wid )
		dup , dup set-current +order
	DOES>
		( pfa) @ ( wid) ['] iterate-regions swap traverse-wordlist
		( RA Dec c-addr u TRUE )							\ the background region will always be found if no other
		drop rot drop rot drop ( c-addr u)
;

: END-REGION-SET ( wid)
	set-current
;

BEGIN-REGION-SET SAMPLE

s" no region" default-region
s" M42 Orion Nebula" 05 35 17 RA -05 23 15 Dec 05 00 00 DEGMMSS sky-region-circle M42?
s" Pisces" 00 00 00 RA 00 00 00 Dec 02 00 00 RA 20 00 00 Dec sky-region-strip Pisces?
s" Square of Pegasus" 23 00 00 RA 15 00 00 Dec 00 30 00 RA 30 00 00 Dec sky-region-strip Pegasus?

END-REGION-SET
