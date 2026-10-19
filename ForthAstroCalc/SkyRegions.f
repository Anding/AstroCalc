\ Named spherical regions; lists are zero-terminated arrays of references.
\ A circle stores radius RA Dec; a polygon stores -count RA1 Dec1 ...;
\ a coordinate strip stores -1 RA1 Dec1 RA2 Dec2.
\ RA is in time seconds; Dec and radius are angular arcseconds.
\ Circle radius is 0..180 degrees. Polygons are convex, smaller than a
\ hemisphere, with great-circle edges and either winding. Strips follow
\ coordinate lines, include lower bounds and exclude upper bounds.
\ The caller supplies a common coordinate frame and epoch.
NEED AstroCalc
NEED structured-lists

: CIRCLE-REGION: ( RA Dec radius <name> -- )
    dup 0< over 180 00 00 DEGMMSS > or abort" Invalid circle radius"
    create , swap , ,
;

: POLYGON-REGION: ( <name> -- )
\ Construction must be uninterrupted: the address at HERE is scratch,
\ overwritten by the next vertex, not part of the allocated polygon.
    create here 0 , here !
;

: ADD-REGION-POINT ( RA Dec -- )
    here @ >R
    swap , ,
    R@ @ 1- R@ !
    R> here !
;

: END-POLYGON ( -- )
    here @ @ -3 > abort" A polygon needs at least three vertices"
;

: STRIP-REGION: { RA1 Dec1 RA2 Dec2 -- }
\ RA1>RA2 crosses 00h; 00h..24h explicitly covers every longitude.
    Dec1 Dec2 > abort" Inverted region latitude bounds"
    create -1 , RA1 , Dec1 , RA2 , Dec2 ,
;

: region-name ( region -- caddr u ) ITEM-NAME ;

: region-inside? { RA Dec region | kind -- flag }
    region @ to kind
    kind 0< 0= if
        RA Dec region cell+ dup @ swap cell+ @ ang_sep kind <= exit
    then
    kind -1 = if
        Dec region 2 cells + @ >= Dec region 4 cells + @ < and
        RA region cell+ @ >= RA region 3 cells + @ <
        region cell+ @ region 3 cells + @ > if xor else and then
        and exit
    then
    RA Dec region cell+ kind negate spherical_polygon_contains 0<>
;

: region-contains? { RA Dec region -- RA Dec flag }
\ Predicate for QUERY-LIST and LIST-FROM; retain the query coordinate pair.
    RA Dec RA Dec region region-inside?
;

: search-regionlist { RA Dec list | region -- region|0 }
\ Declaration order wins unless the caller explicitly sorts this list.
    RA Dec ['] region-contains? list QUERY-LIST to region
    2drop region
;

: angular-area-compare ( first second -- flag )
\ Comparison word for SORT-LIST: smallest spherical solid angle first.
\ C computes in steradians without quantising areas to integer units.
    spherical_region_area_compare
    dup 2 = abort" Invalid region geometry for area comparison"
    0> 0=
;
