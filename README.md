# AstroCalc
Astronomical calculations in C and Forth for telescope control, based on Duffett-Smith and Zwart, "Practical Astronomy"

Documentation for these small Forth modules lives with the code:

- [`SkyRegions.f`](ForthAstroCalc/SkyRegions.f) documents the geometry algorithms
  and record conventions; [`SkyRegions_test.f`](ForthAstroCalc/SkyRegions_test.f)
  is an executable user tutorial for named regions and automatic regionlists.
- [`TargetLists.f`](ForthAstroCalc/TargetLists.f) documents target selection;
  [`TargetLists_test.f`](ForthAstroCalc/TargetLists_test.f) is an executable user
  tutorial for catalogue declarations, ranked walks, query policy and horizon masks.

Each tutorial contains commented examples, `simple-tester` assertions and
PowerShell commands to run it. The existing `*_test1.f` files retain the wider
regression checks. Successful execution ends with `REGRESSION PASSED`.

Use the current Win32 build of `AstroCalc.dll` alongside the 32-bit Forth
interpreter. In particular, sky polygons require the
`spherical_polygon_contains` export; older DLLs without it cannot run those
examples. The native project is `AstroCalc\AstroCalc.vcxproj`.
