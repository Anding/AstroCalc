# Target lists and horizon masks

`NEED TargetLists` loads dictionary-resident J2000 targets and selection using
AstroCalc. Target links, obstruction-region links and the FITS region registry
are independent. Queries allocate no result arrays and never rewrite links.

## Catalogue declarations

```forth
BEGIN-TARGETLIST my-targets
05 35 16 RA -05 -23 -23 Dec POINT-TARGET: Orion
END-TARGETLIST

Orion                         \ -- RA Dec
' Orion >body                 \ -- target address
```

`FOCUS-TARGET:` additionally consumes three strings: source ID, magnitude
and colour, before parsing the word name. `target-name`, `target-source`,
`target-magnitude` and `target-colour` return the stored strings.
`target-coordinates ( target -- RA Dec )` reads the same coordinates returned
by the named word. `each-target ( list xt -- )` visits every record in source
order, passing its address to `( target -- )`. Each record belongs to one
catalogue; do not append an existing record to another list. Subsets are
selected by the walk rather than constructed by relinking catalogue records.

## Query policy

Supply one frozen date, local sidereal time and site latitude:

```forth
2026 10 13 ~ 06 00 00 RA 22 18 00 DEGMMSS target-context
Orion target-reference
35 00 00 Alt -> targets.minimum-altitude
88 00 00 Alt -> targets.maximum-altitude
meridian-east -> targets.meridian-side
```

Dates and angles use the existing AstroCalc finite-fraction constructors.
`target-reference ( RA Dec -- )` takes J2000 coordinates;
`target-reference-altaz ( alt az -- )` converts a reference using the same
context and explicit latitude.

Altitude bounds are inclusive. Meridian side means sky side, not pier side:
`meridian-east` requires negative hour angle; `meridian-west` includes zero
and positive hour angles; `meridian-indifferent` imposes no restriction.
Hour angle is calculated after precession to the snapshot date. This is a
simple meridian split, not a prediction of a mount's overlap or slew policy.

The reusable altitude bounds are -90 through +90 degrees. The default
obstruction mask rejects `Alt < 0`; there is no extra hidden horizon test.
Invalid side values, inverted bounds and a missing context raise errors.

```forth
my-targets nearest-target     \ -- target|0
my-targets previous next-target
my-targets ' show-target walk-targets
```

`show-target` is a caller-defined `( target -- )` action. `next-target`
returns the next visible record after `previous`; zero starts a new walk.
Equal distances follow source order, including different records at identical
coordinates. A previous record from another list is an error. An empty
selection returns zero.

Distance is great-circle separation in J2000 coordinates. Selection of one
target takes one scan; walking K results from N records takes approximately
K*N evaluations. The next scan retains only the previous record and a best
candidate/distance. Consumers must not change query policy or catalogue links
during a walk. A new query must refresh time explicitly.

## Alt/Az obstruction regions

```forth
BEGIN-HORIZON-MASK observatory-mask
0 horizon-below ground
0 45 00 00 Alt 300 00 00 Az 60 00 00 Az
    horizon-strip northern-building
50 00 00 Alt 180 00 00 Az 5 00 00 DEGMMSS
    horizon-circle small-obstruction
END-HORIZON-MASK
observatory-mask -> targets.mask
```

Masks are unions of blocked regions, searched by the existing region
predicate/traversal mechanism. They do not need an unconditional final region:
no match means clear. `horizon-below` is strictly below its altitude;
strips and circles include their boundaries. A strip's azimuth sector may
cross north. Query azimuths are normalised across 0/360 degrees.

`horizon-blocked? ( alt az mask -- flag )` does not search equatorial FITS
regions. Horizon predicates explicitly interpret Alt/Az; circle longitude
uses AstroCalc's integer time-second resolution (15 azimuth arcseconds).
Masks are never registered as FITS classifications. Zero disables mask
testing for callers deliberately requesting an unrestricted calculation.

Selection neither slews nor guarantees that a slew path is safe. Refresh
context and recheck the selected coordinate before issuing equipment commands.
