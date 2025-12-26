\ define regions of the sky

need AstroCalc

: region ( RA Dec -- caddr u)
\ return the region given a celestial coordinate   
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
	

: sky-region-circle
\ create a sky region that is a circle around a point
\ RA and Dec are finite fractions in single integer format
create  ( caddr u RA Dec rad <Name> --) 
	>R >R , R> , R> , $, ( pfa: RA DEC rad u c1 c2 ... cn)
	
\ test if a coordinate lies within the region
DOES> ( RA' Dec' -- name TRUE | FALSE)
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

: sky-region-strip
\ create a sky region that is a strip
\ RA1 and Dec1 is the lower corner, RA2 and Dec2 is the upper corner of the inside of the strip
\ the strip must not cover RA = 0 
create  ( caddr u RA1 Dec1 RA2 Dec2 <Name> --) 
	>R >R >R , R> , R> , R> , $, ( pfa: RA1 Dec1 RA2 Dec2 u c1 c2 ... cn)

\ test if a coordinate lies within the region
DOES> ( RA Dec -- flag)
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

\ s" M42 Orion Nebula" 05 35 17 RA -05 23 15 Dec 05 00 00 DEGMMSS sky-region-circle M42?

s" Pisces" 00 00 00 RA 00 00 00 Dec 02 00 00 RA 20 00 00 Dec sky-region-strip-in Pisces?

01 00 00 RA 10 00 00 Dec Pisces? .
05 00 00 RA 10 00 00 Dec Pisces? .

s" Square of Pegasus" 23 00 00 RA 15 00 00 Dec 00 30 00 RA 30 00 00 Dec sky-region-strip Pegasus?
00 00 00 RA 20 00 00 Dec Pegasus? .
22 00 00 RA 20 00 00 Dec Pegasus? .