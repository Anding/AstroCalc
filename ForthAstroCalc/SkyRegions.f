\ a system to define custom regions of the sky

\ Each region may be:
\ 	a sky circle within a given radius of a coordinate
\ 	a sky strip within a box bounded by south-west and north-east coordinates
\ regions are created as Forth words with the stack effect ( RA Dec -- caddr u TRUE | FALSE) that test if a given coordinate is within the region

\ Region definitions may be organized into a list
\ lists are created as Forth words with the stack effect ( RA Dec -- caddr y ) that return the first region containing the given coordinate
\ lists are assembled in reverse search order ( the first region added is the last region tested)
\ rule: each list must match every coordinate  - a default region that matches all coordinates is provided

need AstroCalc

: sky-circle
\ create a sky region that is a circle around a point
\ RA and Dec are finite fractions in single integer format
create  ( caddr u RA Dec rad <name> --) 
	>R >R , R> , R> , $, ( pfa: RA DEC rad u c1 c2 ... cn)
	
\ test if a coordinate lies within the region
DOES> ( RA' Dec' -- caddr u TRUE | FALSE)
	( pfa) >R
	R@ @ 				( RA' Dec' RA)
	R@ 1 cells+ @	( RA' Dec' RA Dec)
	ang_sep 			( deg)
	R@ 2 cells+ @	( deg rad)
	< if
		R> 3 cells+ count -1
	else
		R> drop 0
	then
;

: box-test { RA' Dec' RA1 Dec1 RA2 Dec2 | f -- flag }
\ test whether a coordinate lies within a bounding box
\ RA' Dec' is the test coordinate
\ RA1 Dec1 is the south-west coordinate, RA2 Dec2 is the north-east coordinate
\ of the bounding box
	Dec' Dec1 >=
	Dec' Dec2 <	
	and
	0= if 0 exit then
	RA' RA1 >=
	RA' RA2 <
	RA1 RA2 > if 		\ wrap around RA 00 so adjust the RA tests
		xor
	else
		and
	then
;

: sky-strip
\ create a sky region that is a strip
\ RA1 and Dec1 is the south-west co0rodinate, RA2 and Dec2 is the north-east coordinate
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

: sky-default
\ create a sky region that matches any coordinate
create ( caddr u <name> --)
	$,
	
DOES> ( RA Dec -- caddr u TRUE)
	( pfa) nip nip count -1
;

\ an iterator supplied to traverse-wordlist
: iterate-regions ( RA Dec nfa -- flag RA Dec)	\ nfa = name field address in the VFX dictionary header
	name>interpret ( RA Dec xt)
	>R 2dup R>		( RA Dec RA Dec xt)
	execute 			( RA Dec FALSE | RA Dec c-addr u TRUE)
	?dup 0=			( RA Dec TRUE  | RA Dec c-addr u TRUE FALSE)	
	\ top flag tells traverse-wordlist whether or not to continue
;

\ organize region definitions into a named list
: BEGIN-REGIONSET ( <name>)
	get-current wordlist ( current-wid wid) 	
	create ( wid <name> -- current-wid )
		dup , dup set-current +order
		
	DOES> ( RA Dec -- c-addr u)
	\ find the first region in the list matching the given coordinate
		( pfa) @ ( wid) ['] iterate-regions swap traverse-wordlist
		( RA Dec c-addr u TRUE )							\ rule: every list must match every coordinate; use default region if necessary
		drop rot drop rot drop ( c-addr u)
;

\ end the list of region definitions
: END-REGIONSET ( wid)
	set-current
;


