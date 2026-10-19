# AstroCalc
Astronomical calculations in C and Forth for telescope control, based on Duffett-Smith and Zwart, "Practical Astronomy"

Documentation for these small Forth modules lives with the code:

- [`SkyRegions.f`](ForthAstroCalc/SkyRegions.f) documents the geometry algorithms
  and record conventions; [`SkyRegions_test.f`](ForthAstroCalc/SkyRegions_test.f)
  is an executable user tutorial for named regions, explicit lists and area sorting.
- [`TargetLists.f`](ForthAstroCalc/TargetLists.f) documents target records;
  [`TargetLists_test.f`](ForthAstroCalc/TargetLists_test.f) is an executable user
  tutorial for catalogue declarations and angular-distance sorting.

Both modules use ForthBase's `structured-lists`: ordinary `CREATE` records
and zero-terminated arrays of references. Records can appear in any number
of lists. There are no embedded links, active-list builders, automatic
registries or horizon masks. Visibility and `observable` are deferred.

Each tutorial contains commented examples and `simple-tester` assertions.
The existing `*_test1.f` files retain the wider
regression checks. Successful execution ends with `REGRESSION PASSED`.

Use the current Win32 build of `AstroCalc.dll` alongside the 32-bit Forth
interpreter. In particular, sky polygons require the
`spherical_polygon_contains` and `spherical_region_area_compare` exports;
older DLLs without them cannot run these examples. The native project is
`AstroCalc\AstroCalc.vcxproj`. Solid angles are computed in steradians;
polygon winding and crossing 00h do not change the area. Region lookup
uses declaration order unless a list is explicitly sorted.
Polygons are complete after their last `ADD-REGION-POINT`; no closing word
is needed. Their construction must not be interrupted by other dictionary
allocation. Four-corner atlas footprints use great-circle edges, not exact
constant-declination boundaries.

`AstroCalc_test1\SkyGeometry_test1.c` tests spherical areas and containment.
After building `Release|Win32`, compile it from a Win32 developer prompt:

```powershell
cl /nologo /W4 /Fe:AstroCalc\Release\SkyGeometry_test1.exe /Fo:AstroCalc\Release\SkyGeometry_test1.obj AstroCalc_test1\SkyGeometry_test1.c AstroCalc\Release\AstroCalc.lib
.\AstroCalc\Release\SkyGeometry_test1.exe
```
