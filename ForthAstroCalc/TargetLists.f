\ Targets are named RA,Dec records.
\ Coordinates must share a frame and epoch when compared. No visibility,
\ sky snapshot, equipment state or list membership is stored in a record.
\ Lists use ForthBase's ordinary zero-terminated arrays of references.
NEED AstroCalc
NEED structured-lists

: TARGET: ( RA Dec <name> -- )
    create swap , ,
;

: target-name ( target -- caddr u ) ITEM-NAME ;
: target-coordinates ( target -- RA Dec ) dup @ swap cell+ @ ;
: target-distance ( target RA Dec -- distance )
\ Great-circle angular separation in arcseconds, without frame conversion.
    rot target-coordinates ang_sep
;

: angular-distance-compare { RA Dec first second -- RA Dec flag }
\ Comparison word for SORT-LIST: nearest first, preserving the reference.
    RA Dec
    first RA Dec target-distance second RA Dec target-distance <=
;
