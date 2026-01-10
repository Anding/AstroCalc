# ERFA Library Integration Instructions

## Overview
The file `AstroCalcERFA.c` contains wrapper functions for J2000 (ICRS) to JNOW (CIRS) coordinate interconversion using the ERFA library.

## Functions Provided
1. **J2000_to_JNOW()** - Converts J2000.0 (ICRS) coordinates to JNOW (CIRS)
2. **JNOW_to_J2000()** - Converts JNOW (CIRS) coordinates to J2000.0 (ICRS)

## ERFA Integration Status

? **ERFA library is now integrated into your project!**

The project has been configured to reference ERFA source files directly from:
- **E:\coding\erfa\src**

This means:
- The ERFA files remain in their original repository location
- You can update the ERFA repository and the project will automatically use the latest version
- No file copying or duplication needed
- 249 ERFA source files and 2 header files are included in the build

### What was done:
1. Added ERFA source directory (`E:\coding\erfa\src`) to the include paths
2. Referenced all ERFA source files (*.c) from the repository directory
3. Referenced ERFA header files (erfa.h, erfam.h) from the repository directory
4. Configured all ERFA files to compile without precompiled headers
5. Added AstroCalcERFA.c to the project

---

## Required ERFA Files

### Header Files (Referenced from E:\coding\erfa\src)
- **erfa.h** - Main ERFA header with all function declarations
- **erfam.h** - ERFA macros and constants

### Source Files (Referenced from E:\coding\erfa\src)
All 249 .c files from the ERFA repository (excluding test files `t_erfa_c.c` and `t_erfa_c_extra.c`)

---

## Keeping ERFA Up-to-Date

To update to the latest version of ERFA:

```powershell
cd E:\coding\erfa
git pull
```

Then rebuild your AstroCalc project. The changes will be automatically included.

---

## Core ERFA Functions Used

The wrapper functions use these ERFA functions:
- **eraAtci13()** - Transform ICRS to CIRS (defined in `atci13.c`)
- **eraAtic13()** - Transform CIRS to ICRS (defined in `atic13.c`)

These functions internally call many other ERFA functions for:
- Precession and nutation calculations
- Frame bias corrections
- Aberration corrections
- Light deflection by the Sun
- Proper motion application
- Earth position and velocity
- Time scale transformations

---

## Project Configuration Details

### Include Directory
The project includes the ERFA source directory in the include path:
```xml
<AdditionalIncludeDirectories>$(ERFASourceDir);%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
```

Where `ERFASourceDir` is defined as:
```xml
<ERFASourceDir>E:\coding\erfa\src</ERFASourceDir>
```

### Source Files
All ERFA .c files are referenced using:
```xml
<ClCompile Include="$(ERFASourceDir)\[filename].c">
  <PrecompiledHeader>NotUsing</PrecompiledHeader>
</ClCompile>
```

---

## Testing the Integration

After integration, test with a simple example:
```c
#include "erfa.h"

// Example: Convert Vega's position from J2000 to date
void test_erfa_conversion() {
    // Vega J2000 coordinates (approximate)
    double ra_j2000 = 4.659499; // radians (279.23473479 degrees)
    double dec_j2000 = 0.678270; // radians (38.78368896 degrees)
    
    // Julian Date for 2024-01-01 TT
    double jd_tt = 2460310.5;
    
    double ra_jnow, dec_jnow;
    
    // Convert to current date
    J2000_to_JNOW(ra_j2000, dec_j2000, jd_tt, 0.0, 0.0, 0.0, 0.0, 
                  &ra_jnow, &dec_jnow);
    
    // Convert back
    double ra_back, dec_back;
    JNOW_to_J2000(ra_jnow, dec_jnow, jd_tt, &ra_back, &dec_back);
    
    // ra_back and dec_back should match ra_j2000 and dec_j2000
}
```

---

## Notes

1. **Coordinate Systems:**
   - ICRS (International Celestial Reference System) is effectively the same as J2000.0 for most purposes
   - CIRS (Celestial Intermediate Reference System) is the modern "true equator and equinox of date"
   
2. **Time Scales:**
   - The functions expect TT (Terrestrial Time)
   - For most applications: TT ? UTC + 69 seconds (as of 2024)
   - For precise work, use proper time scale conversion

3. **Proper Motion:**
   - If you don't have proper motion data, pass 0.0 for pr, pd, px, rv parameters
   - For stars with known proper motion (e.g., from Hipparcos catalog), include these values

4. **License:**
   - ERFA is released under a BSD-style license
   - Check the LICENSE file in the ERFA repository for details

---

## Troubleshooting

### If the ERFA repository is moved or you want to change the path:

1. Edit the `AstroCalc.vcxproj` file
2. Find the line: `<ERFASourceDir>E:\coding\erfa\src</ERFASourceDir>`
3. Update the path to the new location
4. Rebuild the project

### If you need to re-run the integration script:

```powershell
powershell -ExecutionPolicy Bypass -File "AstroCalc\UpdateProjectForERFA.ps1"
```

This will add the ERFA files to the project configuration (if they're not already there).
