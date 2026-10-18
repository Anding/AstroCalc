\ TargetLists executable user tutorial: choosing winter imaging targets.
\
\ Include once in a fresh development session with the ForthBase NEED
\ registry installed.  No equipment is connected and no slew is requested.
\ The observing setup remains in effect so you can explore it afterwards.
\ Run SkyRegions_test.f separately to learn the region geometries.
\
\ T{ code }T expected-stack-items == checks and consumes the results.
\ Tend reports REGRESSION PASSED/FAILED; this file does not exit Forth.
\ Boundary/error tests and equal-distance ties belong to TargetLists_test1.f.

NEED TargetLists
NEED simple-tester

depth constant winter-tutorial-depth
Tstart

\ 1. Make a small winter observing catalogue.
\
\ These J2000 positions are from OpenNGC v20260501 (CC-BY-SA-4.0), as used
\ by AstroImagingInForth's sky\messier.f.  All four are real objects:
\ M1 is the Crab Nebula, M42 the Orion Nebula, M43 its nearby companion
\ nebula, and M45 the Pleiades.  Catalogue order is not observing priority.
\ Magnitudes are left explicitly unknown rather than inventing values or
\ mixing different photometric bands.  To add sourced magnitudes, supply
\ integer millimagnitudes (4199 means 4.199) and document the passband.
BEGIN-TARGETLIST winter-targets
05 34 32 RA +22 00 52 Dec magnitude-unknown TARGET: M1
05 35 16 RA -05 -23 -23 Dec magnitude-unknown TARGET: M42
05 35 31 RA -05 -16 -03 Dec magnitude-unknown TARGET: M43
03 47 29 RA +24 06 19 Dec magnitude-unknown TARGET: M45
END-TARGETLIST

\ Each name returns a target reference, not coordinates and not a command
\ to move the telescope.  Extract coordinates only where they are needed.
\ Every nonzero component of a negative Dec needs its own minus sign.
T{ M42 target-coordinates }T 05 35 16 RA -05 -23 -23 Dec ==
T{ M42 target-name hashS }T s" M42" hashS ==
T{ M42 target-magnitude }T magnitude-unknown ==

\ A reusable catalogue display.  each-target passes ( target -- ) to the
\ consumer, visits source order, and performs NO visibility filtering.
\ .magnitude supplies neither spaces nor a newline; the consumer does.
: .winter-target ( target -- )
    dup target-name type space
    target-magnitude .magnitude cr
;
winter-targets ' .winter-target each-target

\ 2. Set up a winter-night sky snapshot.
\
\ Imagine observing from latitude 22d18m north on 2026-12-15, with local
\ sidereal time 05h.  These are explicitly chosen conditions, not readings
\ from a clock or mount.  LST already includes the site's longitude; this
\ query does not derive it from Longitude.  Replace the date, LST and
\ latitude with your own coherent snapshot before using this on another night.
2026 12 15 ~ -> SkyDate
05 00 00 RA -> LST
22 18 00 DEGMMSS -> Latitude
25 00 00 Alt -> targets.minimum-altitude
85 00 00 Alt -> targets.maximum-altitude
meridian-indifferent -> targets.meridian-side
default-horizon-mask -> targets.mask

\ We avoid low-altitude imaging below 25 degrees and the near-zenith area
\ above 85 degrees.  Bounds are inclusive.  The default mask also rejects
\ Alt<0; there is no hidden additional horizon cut.  Zero targets.mask would
\ disable obstruction testing, but would NOT disable these altitude limits.
\
\ Suppose the telescope is centred on M42.  Use its catalogue position as a
\ J2000 ranking reference; nearest-target includes the reference object itself
\ when it belongs to the list and passes the visibility policy.
T{ winter-targets M42 target-coordinates nearest-target }T M42 ==
T{ M42 M42 target-coordinates target-distance }T 0 ==

\ To find the NEXT field after imaging M42, pass its record as previous.
\ M43 is only about eight arcminutes away, followed by M1, then M45.
\ The previous record must belong to this list.  Zero result means finished;
\ zero previous starts over.  Never dereference zero as a target.
T{ winter-targets M42 M42 target-coordinates next-target }T M43 ==
T{ winter-targets M43 M42 target-coordinates next-target }T M1 ==
T{ winter-targets M1 M42 target-coordinates next-target }T M45 ==
T{ winter-targets M45 M42 target-coordinates next-target }T 0 ==

\ A complete observing shortlist can be displayed with a consumer taking
\ ( target distance -- ).  Native distances are angular arcseconds; this
\ display divides by 60 to show whole arcminutes from the M42 reference.
: .winter-candidate ( target distance -- )
    swap target-name type space
    60 / . ." arcmin from M42" cr
;
winter-targets M42 target-coordinates ' .winter-candidate walk-targets

\ Keep the same reference, sky snapshot, policy and catalogue links throughout
\ a walk, including inside its callback.  Ranking uses J2000 great-circle
\ distance; visibility converts each target to the date and then to Alt/Az.
\ No sorted result array is allocated: each successor is found by another
\ catalogue scan.  Each target belongs to one list; do not relink records
\ to build a shortlist.

\ 3. Ask for a particular part of the available sky.
\
\ At LST 05h, Orion and the Crab Nebula are east of the meridian; the
\ Pleiades have already crossed west.  This is SKY side, not mount pier side
\ or proof that a slew is safe.  East means negative hour angle; west
\ includes zero and positive hour angles.
: nearest-to-Orion ( -- target|0 )
    winter-targets M42 target-coordinates nearest-target
;
T{ meridian-east ' nearest-to-Orion with-meridian-side }T M42 ==
T{ meridian-west ' nearest-to-Orion with-meridian-side }T M45 ==
T{ targets.meridian-side }T meridian-indifferent ==

\ with-meridian-side applies its choice only while the XT runs, restoring
\ policy even if it throws.  For a lasting change, assign the value directly:
meridian-east -> targets.meridian-side
T{ nearest-to-Orion }T M42 ==
meridian-indifferent -> targets.meridian-side

\ At this snapshot Orion is roughly 61 degrees high, the Pleiades about
\ 73 degrees, and the Crab Nebula about 82 degrees.  Raising the altitude
\ floor excludes Orion.  Lowering the ceiling then excludes the Crab too.
70 00 00 Alt -> targets.minimum-altitude
T{ nearest-to-Orion }T M1 ==
80 00 00 Alt -> targets.maximum-altitude
T{ nearest-to-Orion }T M45 ==

\ A valid query can find NOTHING: none of these targets is above 85 degrees.
\ This is not an error and should be handled before requesting coordinates.
85 00 00 Alt -> targets.minimum-altitude
90 00 00 Alt -> targets.maximum-altitude
T{ nearest-to-Orion }T 0 ==
25 00 00 Alt -> targets.minimum-altitude
85 00 00 Alt -> targets.maximum-altitude

\ 4. Describe obstructions at your observing site.
\
\ This is an ILLUSTRATIVE site, not a surveyed description of an observatory:
\ a northern building reaches altitude 45 degrees, and southern trees reach
\ 65 degrees.  Replace these outlines with measurements for your own site.
\ Mask shapes describe BLOCKED sky; no match means clear.  Do not add a
\ final sky-default, which would block everything.  These horizon regions
\ never join the equatorial FITS classification registry.
BEGIN-HORIZON-MASK winter-site
0 s" ground" s" Below horizon" sky-below winter-ground
300 00 00 Az azimuth>longitude 0
60 00 00 Az azimuth>longitude 45 00 00 Alt
    s" building" s" Northern building" sky-band winter-building
120 00 00 Az azimuth>longitude 0
240 00 00 Az azimuth>longitude 65 00 00 Alt
    s" trees" s" Southern trees" sky-band winter-trees
END-HORIZON-MASK
winter-site -> targets.mask

\ Region longitudes use time-angle seconds, not angular azimuth seconds:
\ azimuth>longitude normalises to [0,360) degrees and divides by 15.
\ It truncates to 15-arcsecond azimuth resolution, including at mask edges.
\ The northern building crosses 00h.  Bands include all boundaries, while
\ sky-below excludes its cutoff.  horizon-blocked? takes altitude FIRST.
T{ 40 00 00 Alt 0 winter-site horizon-blocked? }T -1 ==
T{ 46 00 00 Alt 0 winter-site horizon-blocked? }T 0 ==
T{ 60 00 00 Alt 180 00 00 Az winter-site horizon-blocked? }T -1 ==
T{ 66 00 00 Alt 180 00 00 Az winter-site horizon-blocked? }T 0 ==

\ The southern trees now hide M42 and M43, but not M1 or M45.  The same
\ selection command therefore recommends the Crab Nebula instead of Orion.
T{ M42 target-visible? }T 0 ==
T{ M43 target-visible? }T 0 ==
T{ M1 target-visible? }T -1 ==
T{ nearest-to-Orion }T M1 ==
winter-targets M42 target-coordinates ' .winter-candidate walk-targets

\ Other useful mask shapes are sky-circle for a localised obstruction and
\ sky-band with explicit 00h..24h bounds for an all-azimuth altitude band.
\ Do not convert a 360-degree upper interval bound: it normalises to zero,
\ and equal band endpoints mean one meridian rather than the full circle.

\ 5. Bridge coordinates without conflating targets, regions and equipment.
\
\ If your reference is Alt/Az, HZtoJ2000 converts it with the SAME date,
\ latitude and LST.  For example, find the nearest clear field to a point
\ due south at altitude 60 degrees, rather than to a catalogue object's centre.
T{ winter-targets 60 00 00 Alt 180 00 00 Az HZtoJ2000 nearest-target }T M1 ==

\ A target is a point, not a metadata region.  Make a separate association
\ circle with an explicit matching tolerance when one is needed.  This
\ five-arcminute radius is a coordinate-association choice, not M42's size.
M42 target-coordinates 00 05 00 DEGMMSS
    s" M42" s" Orion Nebula pointing" sky-circle winter-Orion-region
T{ M42 target-coordinates winter-Orion-region region-inside? }T -1 ==

\ In live AIF use, skynow obtains fresh context before a NEW query.
\ Selection neither moves equipment nor guarantees a safe slew path.
\ Recheck visibility and equipment policy immediately before motion.
\ Leave this example site's configuration in place for further exploration.
T{ depth }T winter-tutorial-depth ==
Tend
