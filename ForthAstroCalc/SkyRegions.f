\ Named spherical regions; lists are zero-terminated arrays of references.
\ A circle stores radius RA Dec; a polygon stores -count RA1 Dec1 ...
\ RA is in time seconds; Dec and radius are angular arcseconds.
\ Circle radius is 0..180 degrees. Polygons are convex, smaller than a
\ hemisphere, with great-circle edges and either winding.
\ Four RA/Dec corners define great-circle edges, not constant-Dec bounds.
\ Containment includes boundaries; overlapping regions use list priority.
\ The caller supplies a common coordinate frame and epoch.
\ Keep this cell layout consistent with AstroCalc.h and its native routines.
NEED AstroCalc
NEED structured-lists

: CIRCLE-REGION: ( RA Dec radius <name> -- )
\ Store the radius first so its nonnegative sign identifies a circle.
    dup 0< over 180 00 00 DEGMMSS > or if
        3drop bl word drop cr ." Invalid circle radius" cr exit
    then
    create , swap , ,
;

: POLYGON-REGION: ( <name> -- )
\ Allocate only the count cell; leave its address in unallocated HERE.
\ Each ADD-REGION-POINT overwrites that scratch cell with the next RA,
\ appends Dec, decrements the count and moves the scratch address to HERE.
\ No other dictionary allocation may intervene until all points are added.
\ The last point completes the record: no closing word or terminator.
\ The author supplies at least three valid vertices in perimeter order.
    create here 0 , here !
;

: ADD-REGION-POINT ( RA Dec -- )
\ Save the count address before comma overwrites its temporary copy.
    here @ >R
    swap , ,
    R@ @ 1- R@ !
    R> here !
;

: region-name ( region -- caddr u ) ITEM-NAME ;

: region-centre { region | RA Dec -- RA Dec 0 | ior }
\ Circles retain their stored centre; polygons use the mean vertex direction,
\ not an arithmetic RA/Dec average or a surface-area centroid.
    region @ 0< if
        region cell+ region @ negate ADDR RA ADDR Dec spherical_polygon_centre
        0= if cr ." Undefined polygon centre" cr -1 exit then
        RA Dec 0
    else
        region cell+ dup @ swap cell+ @ 0
    then
;

: region-inside? { RA Dec region | kind -- flag }
\ Circle: compare centre separation with radius. Polygon: pass packed
\ vertex pairs and the positive count to C; RA wrap needs no special case.
    region @ to kind
    kind 0< 0= if
        RA Dec region cell+ dup @ swap cell+ @ ang_sep kind <= exit
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
\ Native results are -1/0/1 (smaller/equal/larger), or 2 for invalid geometry.
\ Accept equality so SORT-LIST retains declaration order for equal areas.
    spherical_region_area_compare
    dup 2 = if drop cr ." Invalid region geometry for area comparison" cr 0 exit then
    0> 0=
;
