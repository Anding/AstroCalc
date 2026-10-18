\ SkyRegions executable user tutorial.
\
\ Read from top to bottom, or include the complete file in a fresh development
\ Forth session with the ForthBase NEED registry installed.  No hardware is
\ used.  Definitions remain in the dictionary, so run once per fresh session.
\
\ PowerShell, from E:\coding\AstroImagingInForth (startup.f installs NEED):
\   & '..\VFXForth\Tools\VFXControl.ps1' Start -Session sky-tutorial
\   & '..\VFXForth\Tools\VFXControl.ps1' Test `
\       'E:\coding\AstroCalc\ForthAstroCalc\SkyRegions_test.f' `
\       -Session sky-tutorial -TestTimeoutSeconds 30
\   & '..\VFXForth\Tools\VFXControl.ps1' Stop -Session sky-tutorial
\
\ simple-tester notation: T{ code }T expected-stack-items == .
\ Each assertion consumes its actual and expected results.  -1 is true;
\ 0 is false.  Tend prints REGRESSION PASSED only if every assertion passed.
\ This file does not execute BYE; the caller owns interpreter lifetime.

NEED SkyRegions
NEED simple-tester

depth constant sky-demo-depth

Tstart

\ 1. Coordinates are values; region words return references.
\
\ Longitude is measured in time seconds (24h around the sphere); latitude
\ and radius are angular arcseconds.  RA and Dec assemble three integers.
\ Negative finite-fraction components must all carry their own minus sign.
\ No frame is stored: this tutorial uses equatorial J2000 throughout.
T{ 01 00 00 RA }T 3600 ==
T{ -05 -23 -23 Dec }T -19403 ==

\ A standalone circle is useful without belonging to any regionlist.
\ The ID is stable metadata text, the label is display text, and the final
\ token names a normal Forth word.  Executing it does not perform a search.
06 00 00 RA 0 05 00 00 DEGMMSS
    s" demo-circle" s" Five-degree circle" sky-circle sky-demo-circle

T{ sky-demo-circle region-id hashS }T s" demo-circle" hashS ==
T{ sky-demo-circle region-label hashS }T s" Five-degree circle" hashS ==
T{ 06 00 00 RA 0 sky-demo-circle region-inside? }T -1 ==
T{ 06 00 00 RA 05 00 00 Dec sky-demo-circle region-inside? }T -1 ==
T{ 12 00 00 RA 0 sky-demo-circle region-inside? }T 0 ==

\ 2. Build an ordered classification.
\
\ The display name and 1..8-character FITS key are properties of the list.
\ Every geometry creates a NEW record; never append a standalone record to
\ several lists, because each record has only one NEXT link.
\ Smaller/specific areas should normally precede broader overlapping areas.
s" Tutorial regions" s" REGDEMO" BEGIN-REGIONLIST sky-demo-regions
06 00 00 RA 0 01 00 00 DEGMMSS
    s" small" s" Small priority circle" sky-circle sky-demo-small
06 00 00 RA 0 05 00 00 DEGMMSS
    s" broad" s" Broad circle" sky-circle sky-demo-broad

\ This strip crosses 00h: its longitude interval is [23h,01h).
\ Both lower bounds are included; both upper bounds are excluded.
\ Its horizontal edges follow latitude lines, not great-circle arcs.
23 00 00 RA -10 00 00 Dec 01 00 00 RA 10 00 00 Dec
    s" wrap" s" Strip across midnight" sky-strip sky-demo-strip

\ A polygon uses great-circle edges.  Supply a convex outline smaller than
\ a hemisphere, with at least three vertices in either winding.  Do not
\ repeat the first vertex: last-to-first closure is automatic.  Do not
\ compile unrelated dictionary data between BEGIN and END.
BEGIN-SKY-POLYGON
    23 00 00 RA 10 00 00 Dec SKY-VERTEX
    01 00 00 RA 10 00 00 Dec SKY-VERTEX
    01 00 00 RA 30 00 00 Dec SKY-VERTEX
    23 00 00 RA 30 00 00 Dec SKY-VERTEX
s" polygon" s" Polygon across midnight" END-SKY-POLYGON sky-demo-polygon

\ A final unconditional match makes the classification total.  Put exactly
\ one default at the end; an earlier default would hide later entries.
s" n-a" s" No named area" sky-default sky-demo-default
END-REGIONLIST

T{ sky-demo-regions regionlist-name hashS }T s" Tutorial regions" hashS ==
T{ sky-demo-regions regionlist-fits-key hashS }T s" REGDEMO" hashS ==

\ Both circles contain the centre, but the FIRST declaration wins.
\ Search returns a record reference; apply region-id or region-label later.
T{ 06 00 00 RA 0 sky-demo-regions search-regionlist }T sky-demo-small ==
T{ 06 00 00 RA 03 00 00 Dec sky-demo-regions search-regionlist }T sky-demo-broad ==
T{ 00 00 00 RA 0 sky-demo-regions search-regionlist }T sky-demo-strip ==
T{ 00 00 00 RA 20 00 00 Dec sky-demo-regions search-regionlist }T sky-demo-polygon ==
T{ 12 00 00 RA 50 00 00 Dec sky-demo-regions search-regionlist }T sky-demo-default ==

\ Check the strip directly so a list's default cannot conceal a boundary.
T{ 23 00 00 RA -10 00 00 Dec sky-demo-strip region-inside? }T -1 ==
T{ 01 00 00 RA 0 sky-demo-strip region-inside? }T 0 ==
T{ 00 00 00 RA 10 00 00 Dec sky-demo-strip region-inside? }T 0 ==

\ Polygon vertices and edges are included.  Equal-latitude vertices do not
\ make a latitude-line edge: a great-circle arc bows towards the nearer pole.
T{ 23 00 00 RA 10 00 00 Dec sky-demo-polygon region-inside? }T -1 ==
T{ 12 00 00 RA 20 00 00 Dec sky-demo-polygon region-inside? }T 0 ==

\ 3. Latitude cutoffs and inclusive bands.
\
\ Below excludes the cutoff itself and ignores longitude.  Bands include
\ both endpoints and may wrap through 00h.  These are standalone examples;
\ TargetLists_test.f shows the same geometries used as Alt/Az obstructions.
0 s" below" s" Below equator" sky-below sky-demo-below
23 00 00 RA -10 00 00 Dec 01 00 00 RA 10 00 00 Dec
    s" band" s" Inclusive midnight band" sky-band sky-demo-band
T{ 12 00 00 RA -1 sky-demo-below region-inside? }T -1 ==
T{ 12 00 00 RA 0 sky-demo-below region-inside? }T 0 ==
T{ 01 00 00 RA 10 00 00 Dec sky-demo-band region-inside? }T -1 ==

\ Equal band longitudes mean ONE meridian.  To cover all longitudes use
\ explicit 00h and 24h endpoints; do not normalise that upper endpoint to 0.
00 00 00 RA -10 00 00 Dec 24 00 00 RA 10 00 00 Dec
    s" all" s" All longitudes" sky-band sky-demo-all
T{ 00 00 00 RA 0 sky-demo-all region-inside? }T -1 ==
T{ 12 00 00 RA 0 sky-demo-all region-inside? }T -1 ==
T{ 23 59 59 RA 0 sky-demo-all region-inside? }T -1 ==

\ 4. Independent lists and automatic registration.
\
\ Completing a list appends it to the session registry.  Merely loading
\ SkyRegions creates no lists.  Each completed list gives its own answer
\ to the same query: there is no priority between DIFFERENT lists.
\ The standalone shapes above do not appear in the registry.
s" Tutorial context" s" REGCTX" BEGIN-REGIONLIST sky-demo-context
00 00 00 RA -90 00 00 Dec 24 00 00 RA 90 00 00 Dec
    s" whole-sky" s" Broad context" sky-band sky-demo-whole-sky
s" n-a" s" No context" sky-default sky-demo-no-context
END-REGIONLIST

T{ sky-demo-regions next-regionlist }T sky-demo-context ==
T{ sky-demo-context next-regionlist }T 0 ==
T{ 06 00 00 RA 0 sky-demo-context search-regionlist }T sky-demo-whole-sky ==
T{ 06 00 00 RA 0 sky-demo-regions search-regionlist }T sky-demo-small ==

\ Traversal belongs in a colon definition: BEGIN/WHILE/REPEAT compile control
\ flow, rather than running directly at the interactive prompt.
: sky-demo-show-lists ( -- )
    first-regionlist
    begin dup while
        dup regionlist-name type cr
        next-regionlist
    repeat
    drop
;
sky-demo-show-lists

\ AIF uses this same registry to write each list's FITS key and matching
\ region-id at exposure time.  Inclusion is activation, with no removal
\ operation.  Use a fresh session rather than including catalogues twice.
\ Real examples live in SkyRegions_catalogs.f and the generated
\ SkyRegions_interstellarum.f; SkyRegions_test1.f checks those catalogues.
\ Catalogue files should state source/epoch, deliberately order overlaps,
\ and close with a default.  Generated data should identify the generator.

\ 5. Invalid declarations are errors, not empty regions.
\
\ CATCH executes an XT and returns its exception code (zero on success).
\ These examples reject invalid geometry BEFORE parsing/creating a name.
\ Larger construction errors (nested lists, empty lists, missing final
\ default, empty IDs/labels, too few polygon vertices) also raise errors.
: sky-demo-negative-radius ( -- )
    0 0 -1 s" bad" s" Negative radius" sky-circle
;
: sky-demo-inverted-band ( -- )
    0 1 0 -1 s" bad" s" Inverted band" sky-band
;
T{ ' sky-demo-negative-radius catch 0<> }T -1 ==
T{ ' sky-demo-inverted-band catch 0<> }T -1 ==

\ No query allocates result storage or rewrites links.  Successful tutorial
\ execution also leaves the data stack exactly as it found it.
T{ depth }T sky-demo-depth ==
Tend
