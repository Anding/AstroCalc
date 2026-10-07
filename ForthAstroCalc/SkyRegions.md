# SkyRegions

`SkyRegions.f` classifies a J2000 right-ascension/declination coordinate
against named regions of the sky. Regions are collected into independent,
ordered region sets: an atlas set, a visual-observing set, and a deep-sky set
can therefore classify the same coordinate differently.

The module is declarative Forth. Defining words compile fixed-layout records
and create ordinary Forth words which return those records. Runtime
classification follows explicit links between records; it does not depend on
dictionary order or wordlist traversal.

## Loading

`SkyRegions.f` requires `AstroCalc`, including the 32-bit `AstroCalc.dll`
function used by spherical polygons:

```forth
include E:\coding\AstroCalc\ForthAstroCalc\SkyRegions.f
```

The representative catalogues are separate from the mechanism:

```forth
include E:\coding\AstroCalc\ForthAstroCalc\SkyRegions_catalogs.f
```

Load `SkyRegions.f` before `SkyRegions_catalogs.f`.

All catalogue coordinates are J2000. RA is an integer number of time seconds,
normally written with `RA`. Declination and angular radii use the
`DEGMMSS` finite-fraction representation, normally written with `Dec`:

```forth
05 35 17 RA
-05 23 15 Dec
05 00 00 DEGMMSS
```

## The region model

Every region word has the stack effect:

```forth
region-name  ( -- region )
```

The returned address refers to a common record containing:

1. a link to the next region in its set;
2. the execution token of its geometric predicate;
3. a stable ID;
4. a display label;
5. four geometry-specific data cells.

Use the public accessors rather than depending on the offsets:

```forth
region-id       ( region -- caddr u )
region-label    ( region -- caddr u )
region-inside?  ( RA Dec region -- flag )
```

The ID is intended for persistent storage and machine comparison. The label
is intended for display and may be changed without changing the identity of
the region.

For example:

```forth
05 35 00 RA -05 30 00 Dec orion-quadrant region-inside?

orion-quadrant region-id type
orion-quadrant region-label type
```

## Defining geometries

Definitions take a stable ID, a display label, and a Forth name. If a region
set is currently open, the new region is appended to that set. Otherwise it
is a valid standalone region.

IDs and labels must not be empty.

### Circle

```forth
12 27 00 RA +12 43 00 Dec 08 00 00 DEGMMSS
    s" virgo-cluster" s" Virgo galaxy cluster"
    sky-circle virgo-galaxy-cluster
```

The arguments are centre RA, centre Dec, and angular radius. `ang_sep` from
AstroCalc supplies the spherical angular separation. The boundary is inside.

### RA/Dec strip

```forth
04 00 00 RA -15 00 00 Dec
07 00 00 RA +25 00 00 Dec
    s" orion-quadrant" s" Orion quadrant"
    sky-strip orion-quadrant
```

The arguments are southwest RA/Dec followed by northeast RA/Dec. The lower
bounds are inclusive and the upper bounds are exclusive.

An RA interval whose first RA is greater than its second RA crosses `00h`.
For example, `23h` to `01h` covers two hours around the origin rather than
the other twenty-two hours.

A strip follows lines of constant RA and declination. It is therefore useful
for rectangular catalogue partitions, but it is not a general spherical
polygon.

### Convex spherical polygon

```forth
BEGIN-SKY-POLYGON
    23 00 00 RA +10 00 00 Dec SKY-VERTEX
    01 00 00 RA +10 00 00 Dec SKY-VERTEX
    01 00 00 RA +30 00 00 Dec SKY-VERTEX
    23 00 00 RA +30 00 00 Dec SKY-VERTEX
s" ra-wrap" s" RA wrap polygon"
END-SKY-POLYGON ra-wrap-region
```

`BEGIN-SKY-POLYGON` records the current dictionary address.
Each `SKY-VERTEX` compiles one packed RA/Dec pair. `END-SKY-POLYGON` compiles
the common region record, which points back to that vertex array.

The numerical predicate is `spherical_polygon_contains` in `AstroCalc.dll`.
It converts the query and vertices to Cartesian unit vectors and tests the
sign of the dot product with every great-circle edge normal.

Polygon rules are:

- at least three vertices;
- convex geometry;
- great-circle edges;
- clockwise or anticlockwise declaration order;
- boundary points are inside;
- no duplicate adjacent vertices;
- the intended region should be the convex region smaller than a hemisphere.

The polygon may cross `00h` without special treatment. A line between two
vertices at equal nonzero declination is a great-circle arc, not a line of
constant declination; its midpoint will generally bow towards the nearer
pole.

Concave polygons are not supported directly. Represent one as several convex
regions, or add a future spherical winding predicate.

### Default

```forth
s" n-a" s" n/a" sky-default visual-n-a
```

A default matches every coordinate. Every region set must contain at least
one region and must end with a default. `END-REGIONSET` enforces this rule.

## Region sets

A region set word also returns a record:

```forth
set-name  ( -- region-set )
```

Declare a set with its stable ID, display label, and FITS keyword:

```forth
s" visual" s" Visual" s" REGVIS"
BEGIN-REGIONSET visual-regions

    \ Specific regions, in priority order.

    s" n-a" s" n/a" sky-default visual-n-a
END-REGIONSET
```

The FITS name must contain one to eight characters. Empty set IDs and labels,
nested sets, empty sets, and sets without a final default are rejected while
the catalogue is being loaded.

Region declaration order is classification priority. The first matching
region wins:

```forth
classify-region-set  ( RA Dec region-set -- region|0 )
```

For example:

```forth
05 30 00 RA 00 00 00 Dec
visual-regions classify-region-set
dup region-id type
space region-label type
```

Because a valid set ends in a default, classification normally returns a
region. The `0` result remains part of the general API for malformed or
manually constructed set records.

Set metadata is available through:

```forth
region-set-id         ( region-set -- caddr u )
region-set-label      ( region-set -- caddr u )
region-set-fits-name  ( region-set -- caddr u )
```

The module does not write FITS headers. A publisher can classify a
coordinate, use `region-set-fits-name` as the keyword, and use `region-id` as
the stable value. The display label can be published separately or shown to
the observer.

## Independent classifications

Sets do not inherit from one another and do not share search state. The same
coordinate can be classified independently:

```forth
RA-value Dec-value interstellarum-regions classify-region-set
RA-value Dec-value visual-regions          classify-region-set
RA-value Dec-value deep-sky-regions        classify-region-set
```

`SkyRegions_catalogs.f` currently supplies representative, not exhaustive,
catalogues:

| Set | FITS name | Examples |
|---|---|---|
| Interstellarum | `REGATLAS` | Charts 1-4 |
| Visual | `REGVIS` | Orion quadrant, Summer Triangle |
| Deep Sky | `REGDEEP` | Virgo galaxy cluster, Cygnus Milky Way |

The atlas file is deliberately incomplete. Its records demonstrate catalogue
structure without claiming complete Interstellarum coverage.

## Extending the mechanism

Geometry predicates have the common stack effect:

```forth
( RA Dec region -- flag )
```

`region-inside?` obtains the predicate execution token from the record and
executes it with the record still on the stack. A new defining word can
therefore:

1. use `CREATE`;
2. call `compile-region-header` with its predicate, ID, and label;
3. store geometry parameters in `REGION.DATA0` through `REGION.DATA3`;
4. call `append-region`;
5. use an empty `DOES>` so the created word returns its parameter-field
   address.

The four data cells can also hold an address and count, as the polygon
implementation does. If a future geometry needs more state, store a pointer
to a separately compiled descriptor rather than changing the common record
without also migrating every accessor.

`active-region-set` and the polygon builder values are compile-time
construction state. Region and polygon declarations must not be nested.
Runtime classification itself only reads compiled records.

## Tests

`SkyRegions_test1.f` covers:

- region and set metadata;
- circle, strip, default, and polygon predicates;
- RA wrap;
- polygon boundary and winding;
- direct invocation of the C predicate;
- declaration-order priority;
- representative classifications in all three supplied sets.

The native polygon cases are in
`AstroCalc_test1\AstroCalcERFA_Tests.c`.
