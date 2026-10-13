\ Alt/Az obstruction regions, deliberately outside the FITS region registry.
NEED SkyRegions
0 value active-horizon-mask

: BEGIN-HORIZON-MASK ( "name" -- )
    active-regionlist abort" Nested regionlist"
    create here /REGIONLIST allot
    dup /REGIONLIST erase
    dup to active-horizon-mask to active-regionlist
DOES> ( -- mask )
;

: END-HORIZON-MASK ( -- )
    active-horizon-mask 0= abort" No open horizon mask"
    0 to active-regionlist
    0 to active-horizon-mask
;

: compile-mask-region { predicate | name-addr name-u -- region }
    BL parse-word to name-u to name-addr
    name-addr name-u ($create)
    predicate name-addr name-u name-addr name-u compile-region-header
;

: horizon-below? { alt az region -- flag }
    alt region REGION.DATA0 + @ <
;

: horizon-strip? { alt az region -- flag }
    alt region REGION.DATA0 + @ >=
    alt region REGION.DATA1 + @ <= and
    az region REGION.DATA2 + @ region REGION.DATA3 + @
        in-azimuth-sector? and
;

: horizon-circle? { alt az region -- flag }
\ AstroCalc longitude is in time seconds, not azimuth arcseconds.
    az 15 / alt
    region REGION.DATA1 + @ 15 / region REGION.DATA0 + @
    ang_sep region REGION.DATA2 + @ <=
;

: horizon-below { altitude | region -- }
    ['] horizon-below? compile-mask-region to region
    altitude region REGION.DATA0 + !
    region append-region
DOES> ( -- region )
;

: horizon-strip { min-alt max-alt start-az end-az | region -- }
    min-alt max-alt > abort" Inverted horizon altitude bounds"
    ['] horizon-strip? compile-mask-region to region
    min-alt region REGION.DATA0 + !
    max-alt region REGION.DATA1 + !
    start-az region REGION.DATA2 + !
    end-az region REGION.DATA3 + !
    region append-region
DOES> ( -- region )
;

: horizon-circle { alt az radius | region -- }
    radius 0< abort" Negative horizon radius"
    ['] horizon-circle? compile-mask-region to region
    alt region REGION.DATA0 + !
    az region REGION.DATA1 + !
    radius region REGION.DATA2 + !
    region append-region
DOES> ( -- region )
;

: horizon-blocked? { altitude azimuth mask -- flag }
    mask 0= if 0 exit then
    azimuth 360 00 00 Az mod
    dup 0< if 360 00 00 Az + then to azimuth
    altitude azimuth mask search-regionlist 0<>
;

BEGIN-HORIZON-MASK default-horizon-mask
0 horizon-below below-horizon
END-HORIZON-MASK
