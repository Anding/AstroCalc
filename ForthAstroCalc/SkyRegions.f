\ define regions of the sky

: region ( RA Dec -- caddr u)
\ return the region given a celestial coordinate   
; 

: sky-region-circle
\ create a sky region that is a circle around a point
\ RA and Dec are finite fractions in single integer format
create  ( RA Dec rad caddr u --) 

\ test if a coordinate lies within the region
DOES> ( RA Dec -- flag)

;

: sky-region-strip-in
\ create a sky region that is a strip
\ RA1 and Dec1 is the lower corner, RA2 and Dec2 is the upper corner of the inside of the strip
\ the strip must not cover RA = 0 
create  ( RA1 Dec1 RA2 Dec2 caddr u --) 

\ test if a coordinate lies within the region
DOES> ( RA Dec -- flag)

;   

: sky-region-strip-out
\ create a sky region that is a strip
\ RA1 and Dec1 is the lower corner, RA2 and Dec2 is the upper corner of the outside of the strip
\ the strip must not cover RA = 0 
create  ( RA1 Dec1 RA2 Dec2 caddr u --) 

\ test if a coordinate lies within the region
DOES> ( RA Dec -- flag)

;  

