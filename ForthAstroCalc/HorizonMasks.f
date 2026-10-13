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

: azimuth>longitude ( azimuth -- longitude )
    360 00 00 Az mod
    dup 0< if 360 00 00 Az + then
    15 /
;

: horizon-blocked? { altitude azimuth mask -- flag }
    mask 0= if 0 exit then
    azimuth azimuth>longitude altitude mask search-regionlist 0<>
;

BEGIN-HORIZON-MASK default-horizon-mask
0 s" below-horizon" s" Below horizon" sky-below below-horizon
END-HORIZON-MASK
