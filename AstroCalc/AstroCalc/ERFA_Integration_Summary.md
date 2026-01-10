# ERFA Integration - Complete Summary

## ? Integration Complete!

Your AstroCalc project now includes ERFA library support for J2000 to JNOW coordinate conversions.

---

## Files Created

### 1. **AstroCalcERFA.c**
Location: `AstroCalc/AstroCalcERFA.c`

Two wrapper functions:
- `J2000_to_JNOW()` - Converts J2000.0 (ICRS) to JNOW (CIRS) coordinates
- `JNOW_to_J2000()` - Converts JNOW (CIRS) to J2000.0 (ICRS) coordinates

### 2. **ERFA_Integration_Instructions.md**
Location: `AstroCalc/ERFA_Integration_Instructions.md`

Complete documentation on the ERFA integration, functions, and usage.

### 3. **UpdateProjectForERFA.ps1**
Location: `AstroCalc/UpdateProjectForERFA.ps1`

PowerShell script that updates the .vcxproj file to include ERFA files.

### 4. **UpdateFiltersForERFA.ps1**
Location: `AstroCalc/UpdateFiltersForERFA.ps1`

PowerShell script that organizes ERFA files in Visual Studio Solution Explorer.

---

## Project Configuration

### ERFA Source Location
```
E:\coding\erfa\src
```

### Files Included
- **249 ERFA .c source files** (referenced from repository, not copied)
- **2 ERFA header files** (erfa.h, erfam.h)
- **1 wrapper file** (AstroCalcERFA.c)

### Build Configuration
- ERFA source directory added to include paths
- All ERFA files compile without precompiled headers
- erfaversion.c excluded (requires build-time configuration)
- ? **Build successful!**

---

## Function Usage

### J2000 to JNOW Conversion
```c
#include "erfa.h"

// Example: Convert star coordinates from J2000 to current date
void example_j2000_to_jnow() {
    // Star position at J2000.0 (RA and Dec in radians)
    double ra_j2000 = 4.659499;   // ~279.23 degrees
    double dec_j2000 = 0.678270;  // ~38.78 degrees
    
    // Julian Date in TT (Terrestrial Time)
    // For 2024-01-01: JD = 2460310.5
    double jd_tt = 2460310.5;
    
    // Output variables
    double ra_jnow, dec_jnow;
    
    // Convert (no proper motion, parallax, or radial velocity)
    J2000_to_JNOW(ra_j2000, dec_j2000, jd_tt,
                  0.0, 0.0, 0.0, 0.0,  // pr, pd, px, rv
                  &ra_jnow, &dec_jnow);
    
    // ra_jnow and dec_jnow now contain coordinates at the specified date
}
```

### JNOW to J2000 Conversion
```c
// Example: Convert current date coordinates back to J2000
void example_jnow_to_j2000() {
    // Coordinates at current date (radians)
    double ra_jnow = 4.661234;
    double dec_jnow = 0.677890;
    
    // Julian Date in TT
    double jd_tt = 2460310.5;
    
    // Output variables
    double ra_j2000, dec_j2000;
    
    // Convert back to J2000
    JNOW_to_J2000(ra_jnow, dec_jnow, jd_tt,
                  &ra_j2000, &dec_j2000);
    
    // ra_j2000 and dec_j2000 now contain J2000.0 coordinates
}
```

### With Proper Motion
```c
// Example: High proper motion star (e.g., Barnard's Star)
void example_with_proper_motion() {
    // Barnard's Star J2000 coordinates
    double ra_j2000 = 4.698;    // radians
    double dec_j2000 = 0.081;   // radians
    
    // Proper motion (radians/year)
    double pr = -0.00025;  // RA proper motion
    double pd = 0.00056;   // Dec proper motion
    
    // Parallax and radial velocity
    double px = 0.5477;    // arcseconds
    double rv = -110.0;    // km/s (approaching)
    
    // Julian Date
    double jd_tt = 2460310.5;
    
    double ra_jnow, dec_jnow;
    
    // Convert with all corrections
    J2000_to_JNOW(ra_j2000, dec_j2000, jd_tt,
                  pr, pd, px, rv,
                  &ra_jnow, &dec_jnow);
}
```

---

## Coordinate Systems

### ICRS (J2000.0)
- International Celestial Reference System
- Fixed reference frame
- Epoch: J2000.0 (January 1, 2000, 12:00 TT)
- Used for star catalogs (Hipparcos, Gaia, etc.)

### CIRS (JNOW)
- Celestial Intermediate Reference System
- Accounts for:
  - Precession
  - Nutation
  - Frame bias
  - Aberration (annual, diurnal)
  - Gravitational light deflection
  - Proper motion (if provided)
  - Parallax (if provided)

---

## Time Scales

The functions expect **TT (Terrestrial Time)**:

### Conversions:
- **TT ? UTC + 69 seconds** (as of 2024)
- More precisely: TT = TAI + 32.184 seconds
- TAI = UTC + leap_seconds (37 seconds as of 2024)

### For high precision:
Use ERFA's time conversion functions (e.g., `eraUtctai`, `eraTaitt`)

### For moderate precision:
```c
double jd_utc = 2460310.5;  // UTC Julian Date
double jd_tt = jd_utc + 69.0/86400.0;  // Add ~69 seconds
```

---

## Updating ERFA

To update to the latest ERFA version:

```powershell
cd E:\coding\erfa
git pull
```

Then rebuild AstroCalc - the latest ERFA code will be automatically included.

---

## Benefits of This Approach

? **No file duplication** - ERFA files stay in their repository  
? **Easy updates** - Just `git pull` in the ERFA repo  
? **Clean separation** - Your code separate from library code  
? **Version control friendly** - No large file commits in your repo  
? **Build successful** - All 249 ERFA functions available  

---

## What Corrections Are Applied?

The ERFA functions apply these corrections automatically:

1. **Precession** - Earth's axis precession (~50"/year)
2. **Nutation** - Short-term wobbles (~9" amplitude)
3. **Frame Bias** - ICRS vs FK5 difference
4. **Annual Aberration** - Earth's orbital motion (~20")
5. **Proper Motion** - Star's motion through space (if provided)
6. **Parallax** - Distance effect (if provided)
7. **Light Deflection** - Sun's gravity (up to 1.75" at limb)

---

## Accuracy

- **Sub-milliarcsecond** accuracy for most applications
- **Microarcsecond** level if proper time scales are used
- **Suitable for** astrometry, telescope pointing, satellite tracking

---

## References

- **ERFA Library**: https://github.com/liberfa/erfa
- **ERFA Documentation**: http://www.iausofa.org/
- **Standards**: IAU SOFA (Standards of Fundamental Astronomy)

---

## Questions?

Check the detailed documentation in:
- `ERFA_Integration_Instructions.md` - Full integration details
- `AstroCalcERFA.c` - Function comments with detailed notes

---

**Status**: ? Ready to use!  
**Build**: ? Successful  
**Files**: ? Configured  
**Tests**: ?? Not yet implemented (add your own test cases)
