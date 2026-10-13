# Target lists and horizon masks

`NEED TargetLists` loads dictionary-resident J2000 targets and selection using
AstroCalc. Target links, obstruction-region links and the FITS region registry
are independent. Queries allocate no result arrays and never rewrite links.

## Catalogue declarations

```forth
BEGIN-TARGETLIST my-targets
05 35 16 RA -05 -23 -23 Dec magnitude-unknown POINT-TARGET: M42
END-TARGETLIST

M42                           \ -- target
M42 target-coordinates        \ -- RA Dec
M42 target-magnitude          \ -- millimagnitudes
```

`POINT-TARGET: ( RA Dec millimagnitudes "name" -- )` creates a target whose
only astronomical data are its catalogue name, J2000 equatorial coordinates
and magnitude. The name is the parsed dictionary name, not a popular label.
There are no separate source IDs, colours, notes or stored regions.
`target-name ( target -- caddr u )` returns the name.
Magnitude is an integer in thousandths: `4199` means 4.199;
negative and zero magnitudes are valid. `magnitude-unknown` is the explicit
unknown sentinel (-2147483647). `.magnitude` prints three decimals or `unknown`.
Each catalogue documents its magnitude band; different bands are not directly
interchangeable. `target-coordinates ( target -- RA Dec )` extracts position.
`each-target ( list xt -- )` visits every record in source
order, passing its address to `( target -- )`. Each record belongs to one
catalogue; do not append an existing record to another list. Subsets are
selected by the walk rather than constructed by relinking catalogue records.

## Shared sky state and query policy

Selection uses AstroCalc's `Latitude` and `Longitude`, together with `LST`
and `SkyDate`. Supply a fixed UTC date, local sidereal time and site location:

```forth
2026 10 13 ~ -> SkyDate
06 00 00 RA -> LST
22 18 00 DEGMMSS -> Latitude
114 01 00 DEGMMSS -> Longitude
35 00 00 Alt -> targets.minimum-altitude
88 00 00 Alt -> targets.maximum-altitude
meridian-east -> targets.meridian-side
```

Dates and angles use the existing AstroCalc finite-fraction constructors.
Ranking coordinates are J2000 RA/Dec passed on the stack; there are no
reference-coordinate globals. `HZtoJ2000 ( alt az -- RA Dec )` converts a
horizon reference using `Latitude`, `LST` and `SkyDate`.
Longitude is part of the shared site state; selection uses the supplied local
sidereal time rather than deriving it again from longitude.

Altitude bounds are inclusive. Meridian side means sky side, not pier side:
`meridian-east` requires negative hour angle; `meridian-west` includes zero
and positive hour angles; `meridian-indifferent` imposes no restriction.
Hour angle is calculated after precession to the snapshot date. This is a
simple meridian split, not a prediction of a mount's overlap or slew policy.

Core queries use the current `targets.meridian-side`. For a scoped override,
`with-meridian-side ( i*x side xt -- j*x )` executes the XT with that side
and restores the previous policy on both normal return and exception.
The original exception is rethrown. AIF's `.targets` and `nearest-focus-star`
use this word for their stack-supplied side; neither leaves a changed default.
Set `targets.meridian-side` explicitly when a lasting policy change is wanted.

The reusable altitude bounds are -90 through +90 degrees. The default
obstruction mask rejects `Alt < 0`; there is no extra hidden horizon test.
Invalid side values, inverted bounds and a missing UTC date raise errors.

```forth
my-targets M42 target-coordinates nearest-target     \ -- target|0
my-targets previous M42 target-coordinates next-target
my-targets M42 target-coordinates ' show-target walk-targets
```

`nearest-target ( list RA Dec -- target|0 )` starts a selection.
`next-target ( list previous RA Dec -- target|0 )` returns the next visible
record after `previous`; zero starts a new walk.
`walk-targets ( list RA Dec xt -- )` calls a consumer taking
`( target distance -- )`, with the calculated angular distance.
Equal distances follow source order, including different records at identical
coordinates. A previous record from another list is an error. An empty
selection returns zero.

Distance is great-circle separation in J2000 coordinates. Selection of one
target takes one scan; walking K results from N records takes approximately
K*N evaluations. The next scan retains only the previous record and a best
candidate/distance. Consumers must not change the shared sky globals, query
policy or catalogue links during a walk. Refresh sky state explicitly before
a new live query; AIF's `skynow` is the equipment bridge, not this library.

## Alt/Az obstruction regions

```forth
BEGIN-HORIZON-MASK observatory-mask
0 s" ground" s" Ground" sky-below ground
300 00 00 Az azimuth>longitude 0
60 00 00 Az azimuth>longitude 45 00 00 Alt
    s" building" s" Northern building" sky-band northern-building
180 00 00 Az azimuth>longitude 50 00 00 Alt 5 00 00 DEGMMSS
    s" small" s" Small obstruction" sky-circle small-obstruction
END-HORIZON-MASK
observatory-mask -> targets.mask
```

Masks are unions of blocked regions, searched by the existing region
predicate/traversal mechanism. They do not need an unconditional final region:
no match means clear. These are ordinary coordinate-agnostic `SkyRegions`
geometries: `sky-below` is strictly below its latitude, while `sky-band`
and circles include boundaries. A band's longitude interval may cross 00h.
`sky-strip` remains half-open for catalogue classification.

For an all-azimuth band, use longitude bounds **00h and 24h** directly:

```forth
00 00 00 RA 35 00 00 Alt 24 00 00 RA 70 00 00 Alt
    s" all-azimuths" s" All azimuths" sky-band all-azimuths
```

Place this declaration inside `BEGIN-HORIZON-MASK`/`END-HORIZON-MASK`.
Equal longitude endpoints select one meridian, not the full circle.
Do not convert 360 degrees for the upper interval bound: position
normalisation would turn it into 00h.

`horizon-blocked? ( alt az mask -- flag )` does not search equatorial FITS
regions. It converts azimuth at the boundary using
`azimuth>longitude ( azimuth -- longitude )`: normalise to [0,360), then
divide angular arcseconds by 15 to obtain integer time seconds (15 degrees
= 1 hour). All region longitude coordinates use this time-angle unit, and
latitude/radius use angular units. The same conversion is explicit when
declaring horizon regions. Longitude resolution is 15 azimuth arcseconds;
queries truncate to the lower time second, including at mask edges.
The caller owns frame consistency; regions contain no frame switch.
Masks are never registered as FITS classifications. Zero disables mask
testing for callers deliberately requesting an unrestricted calculation.

Selection neither slews nor guarantees that a slew path is safe. Refresh
context and recheck the selected coordinate before issuing equipment commands.

Targets and regions remain independent records. A target-centred region is
an explicit position-plus-radius construction, not a field of the target:

```forth
M42 target-coordinates 00 05 00 DEGMMSS
    s" M42" s" M42" sky-circle M42-region
```
