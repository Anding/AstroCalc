# SkyRegions user and maintainer guide

`SkyRegions.f` gives names to areas of the J2000 sky. A coordinate can be
searched independently in several ordered `regionlist`s: one list may identify
an imaging target, another an atlas chart, and another a visually recognizable
part of the sky.

The design is deliberately Forth-like:

- region and regionlist names are ordinary dictionary words;
- definitions compile fixed records and strings into the dictionary;
- source order determines overlap priority;
- including a completed regionlist makes it active;
- runtime search follows explicit links and allocates no memory.

## Loading

Use the registered capability:

```forth
NEED SkyRegions
```

This loads `AstroCalc`, the finite-fraction words, and the native spherical
polygon predicate. Loading the mechanism defines no regionlists. Catalogue
files define them separately.

For example, AstroImagingInForth always loads its target list and may include
an additional list:

```forth
NEED AstroImagingTargets
include regions\VisualSky.f
```

Inclusion is activation. `END-REGIONLIST` automatically adds the completed
list to the session registry; there is no enable switch or search order.

## Coordinates and negative declinations

All coordinates are J2000. `RA` and `Dec` convert three integers into the
single-cell finite-fraction forms used by AstroCalc:

```forth
05 35 16 RA
-05 -23 -23 Dec
```

The sign convention is important: **every non-zero component of a negative
declination carries the minus sign**. Thus `-05 -23 -23 Dec` means
-5 degrees 23 minutes 23 seconds. Writing `-05 23 23 Dec` instead performs
finite-fraction arithmetic and denotes a different coordinate.

Angular radii use the same degree-minute-second representation:

```forth
00 05 00 DEGMMSS   \ five arcminutes
```

## Defining and searching a regionlist

A regionlist declaration supplies its display name, FITS key, and Forth word:

```forth
s" Familiar sky" s" REGVIS"
BEGIN-REGIONLIST familiar-regions

03 47 29 RA +24 06 19 Dec 03 00 00 DEGMMSS
    s" pleiades" s" Pleiades neighbourhood"
    sky-circle pleiades-neighbourhood

s" n-a" s" n/a" sky-default familiar-n-a
END-REGIONLIST
```

The FITS key must contain 1-8 characters. A list must contain at least one
region and end with exactly one default region. Empty names, nested lists,
empty lists, and missing defaults abort while the source is loaded.

The created word returns the regionlist record:

```forth
familiar-regions  ( -- regionlist )
```

Search it with:

```forth
03 47 29 RA +24 06 19 Dec
familiar-regions search-regionlist  ( -- region|0 )
```

`search-regionlist` tests regions in declaration order and returns the first
match. Source order is therefore the explicit priority when regions overlap.
This rule applies equally to circles, strips, and polygons; there is no
geometry-specific "nearest" rule.

A well-formed list always reaches its default, but `0` remains a defensive
result for a malformed or manually constructed record.

## Region identity and presentation

Every region definition has three names serving different purposes:

```forth
s" pleiades" s" Pleiades neighbourhood"
sky-circle pleiades-neighbourhood
```

| Name | Purpose |
|---|---|
| `pleiades` | Stable machine-readable ID, suitable for FITS values |
| `Pleiades neighbourhood` | Human-readable label |
| `pleiades-neighbourhood` | Forth dictionary word returning the record |

Use the accessors:

```forth
pleiades-neighbourhood region-id       ( -- c-addr u )
pleiades-neighbourhood region-label    ( -- c-addr u )
```

The Forth word/reference is the region's in-process identity. The stored ID
exists because persistent metadata needs a stable string.

Regionlist metadata is similarly direct:

```forth
familiar-regions regionlist-name      ( -- c-addr u )
familiar-regions regionlist-fits-key  ( -- c-addr u )
```

A regionlist needs no separate stored ID: its record address and defining word
already provide one inside Forth.

## Supported geometries

### Circle

```forth
12 27 00 RA +12 43 00 Dec 08 00 00 DEGMMSS
    s" virgo-cluster" s" Virgo galaxy cluster"
    sky-circle virgo-galaxy-cluster
```

Arguments are centre RA, centre declination, angular radius, ID, and label.
`ang_sep` computes spherical separation. The boundary is included.

Catalogue target circles normally describe an association tolerance, not an
object's apparent physical extent. AstroImagingInForth's generated Messier
catalogue uses an explicit five-arcminute default which can be changed for an
individual entry.

### RA/declination strip

```forth
04 00 00 RA -15 00 00 Dec
07 00 00 RA +25 00 00 Dec
    s" orion-quadrant" s" Orion quadrant"
    sky-strip orion-quadrant
```

Arguments are the two RA/declination corners followed by ID and label. Lower
bounds are inclusive; upper bounds are exclusive. Adjacent strips can
therefore share an edge without both matching it.

If the first RA is greater than the second, the interval crosses `00h`.
For example, `23h` to `01h` covers the two-hour interval around `00h`.

A strip follows lines of constant RA and declination. It is not a spherical
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

Rules:

- provide at least three vertices;
- use a convex polygon smaller than a hemisphere;
- declare vertices clockwise or anticlockwise;
- use no duplicate adjacent vertices;
- boundaries are included;
- crossing `00h` requires no special treatment.

Edges are great-circle arcs. Two vertices at equal non-zero declination do not
produce a line of constant declination; the arc bows towards the nearer pole.

The native `spherical_polygon_contains` function tests the signs of
great-circle edge normals. Concave shapes must be represented by several
convex regions or by a future geometry predicate.

### Default

```forth
s" n-a" s" n/a" sky-default familiar-n-a
```

The default matches every coordinate and must be the final declaration. It
makes each list a total first-match search and provides an explicit metadata
value when no specific region applies.

## Automatic regionlist registry

Completed lists form a linked registry in inclusion order:

```forth
first-regionlist  ( -- regionlist|0 )
next-regionlist   ( regionlist -- next-regionlist|0 )
```

Typical traversal is:

```forth
first-regionlist
begin dup while
    dup regionlist-name type cr
    next-regionlist
repeat
drop
```

Only `END-REGIONLIST` links a list, after validating that it is non-empty and
ends in a default. The registry deliberately has no removal operation:
including a catalogue expresses the decision to use it for the lifetime of
that Forth dictionary.

Regionlist completion order affects registry traversal but not search within
another list. Each list is searched independently and may produce its own
answer for the same coordinate.

## AstroImagingInForth integration

AstroImagingInForth loads `fits-target-regions` by default. Its generated
Messier definitions provide pure coordinate words:

```forth
M42       ( -- RA Dec )
M42 goto
```

Evaluating a target word changes no target-name state. At exposure time the
pipeline captures the mount's J2000 coordinate once and:

1. searches `fits-target-regions` for `OBJECT`;
2. walks every registered regionlist;
3. writes each list's `regionlist-fits-key` with its matched `region-id`.

The target list participates in both passes, so a matching exposure may contain:

```text
OBJECT  = M42
#REGION
REGTARG = M42
REGVIS  = orion-belt-sword
```

Optional regionlists require no pipeline modification. Including their source
is sufficient.

## Writing catalogue files

Keep mechanism and catalogues separate. A catalogue file should:

1. `NEED SkyRegions`;
2. document its coordinate source and epoch;
3. declare one named regionlist;
4. order overlapping regions deliberately;
5. finish with a default;
6. call `END-REGIONLIST`.

Prefer explicit values in generated Forth:

```forth
M42 00 05 00 DEGMMSS
    s" M42" s" M42" sky-circle M42-region
```

An explicit radius is easy to review and edit entry by entry. Generated files
should identify their source version and generator and should not be edited
independently of that generator.

Regions created outside an open regionlist remain valid standalone records:

```forth
12 00 00 RA +20 00 00 Dec my-region region-inside?
```

They are not automatically searched by the imaging pipeline because they do
not belong to a completed registered list.

## Maintainer notes

Both record types and all copied strings live permanently in the Forth
dictionary. There is no allocation, freeing, or per-search scratch storage.

### Region record

The common fixed header contains:

1. `REGION.NEXT` - next region in one regionlist;
2. `REGION.PREDICATE` - geometry predicate execution token;
3. `REGION.ID` - pointer to a counted dictionary string;
4. `REGION.LABEL` - pointer to a counted dictionary string;
5. `REGION.DATA0` through `REGION.DATA3` - geometry-owned cells.

A region has only one `NEXT` field and must not be appended to more than one
list. A geometry defining word calls `compile-region-header`, fills its data
cells, then calls `append-region`.

`region-inside?` leaves the region record below its predicate execution token,
so every geometry predicate has the common stack effect:

```forth
( RA Dec region -- flag )
```

### Regionlist record

The record contains:

1. `REGIONLIST.NEXT` - next completed list in inclusion order;
2. `REGIONLIST.NAME` - counted display name;
3. `REGIONLIST.FITS` - counted FITS key;
4. `REGIONLIST.FIRST` - first region;
5. `REGIONLIST.LAST` - construction tail.

`FIRST` and `LAST` make ordered catalogue construction constant-time.
`active-regionlist` is compile-time construction state. `first-regionlist` and
`last-regionlist` are the permanent registry endpoints.

### Polygon storage

`BEGIN-SKY-POLYGON` remembers `HERE`; each `SKY-VERTEX` compiles an RA/Dec
pair. `END-SKY-POLYGON` then creates the region record whose `DATA0` points
back to the packed array and whose `DATA1` stores its count. Polygon and
regionlist builders are intentionally non-nestable.

### Adding a geometry

A new geometry defining word should:

1. implement `( RA Dec region -- flag )`;
2. use `CREATE`;
3. call `compile-region-header` with its predicate, ID, and label;
4. fill `REGION.DATA0` through `REGION.DATA3`;
5. call `append-region`;
6. use an empty `DOES>` so the created word returns its record.

If four cells are insufficient, compile a separate descriptor and store its
address in one data cell rather than enlarging the common record casually.

## Tests

Run:

```powershell
& 'E:\Coding\VFXForth\Bin\VFXterm.exe' `
  'E:\Coding\AstroCalc\ForthAstroCalc\SkyRegions_test1.f'
```

`SkyRegions_test1.f` covers record metadata, automatic registry order, circle,
strip, default and polygon predicates, RA wrap, polygon winding, boundaries,
and first-match priority. The simple-tester success sentinel is `65535`.
