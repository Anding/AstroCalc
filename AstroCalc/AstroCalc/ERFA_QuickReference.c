// Quick Reference for ERFA Coordinate Conversion Functions
// File: AstroCalcERFA.c

// ============================================================================
// J2000 (ICRS) to JNOW (CIRS) Conversion
// ============================================================================

void J2000_to_JNOW(
    double ra_j2000,    // IN:  Right Ascension at J2000.0 (radians)
    double dec_j2000,   // IN:  Declination at J2000.0 (radians)
    double jd_tt,       // IN:  Julian Date in TT (Terrestrial Time)
    double pr,          // IN:  Proper motion in RA (radians/year) [use 0.0 if unknown]
    double pd,          // IN:  Proper motion in Dec (radians/year) [use 0.0 if unknown]
    double px,          // IN:  Parallax (arcseconds) [use 0.0 if unknown]
    double rv,          // IN:  Radial velocity (km/s, +ve receding) [use 0.0 if unknown]
    double* ra_jnow,    // OUT: Right Ascension at date (radians)
    double* dec_jnow    // OUT: Declination at date (radians)
);

// ============================================================================
// JNOW (CIRS) to J2000 (ICRS) Conversion
// ============================================================================

void JNOW_to_J2000(
    double ra_jnow,     // IN:  Right Ascension at date (radians)
    double dec_jnow,    // IN:  Declination at date (radians)
    double jd_tt,       // IN:  Julian Date in TT (Terrestrial Time)
    double* ra_j2000,   // OUT: Right Ascension at J2000.0 (radians)
    double* dec_j2000   // OUT: Declination at J2000.0 (radians)
);

// ============================================================================
// USAGE EXAMPLES
// ============================================================================

// Example 1: Simple conversion (no proper motion)
void example_simple() {
    double ra_j2000 = 1.234;     // RA in radians
    double dec_j2000 = 0.567;    // Dec in radians
    double jd_tt = 2460310.5;    // JD for 2024-01-01
    double ra_now, dec_now;
    
    J2000_to_JNOW(ra_j2000, dec_j2000, jd_tt,
                  0.0, 0.0, 0.0, 0.0,        // No proper motion data
                  &ra_now, &dec_now);
}

// Example 2: With proper motion (Hipparcos catalog data)
void example_hipparcos() {
    double ra_j2000 = 1.234;     // RA in radians
    double dec_j2000 = 0.567;    // Dec in radians
    double jd_tt = 2460310.5;    // JD for 2024-01-01
    
    // Proper motion from Hipparcos
    double pm_ra = 0.00001;      // radians/year
    double pm_dec = -0.00005;    // radians/year
    double parallax = 0.05;      // arcseconds
    double rad_vel = -25.0;      // km/s
    
    double ra_now, dec_now;
    J2000_to_JNOW(ra_j2000, dec_j2000, jd_tt,
                  pm_ra, pm_dec, parallax, rad_vel,
                  &ra_now, &dec_now);
}

// Example 3: Round-trip conversion (should recover original coords)
void example_roundtrip() {
    double ra_j2000_orig = 1.234;
    double dec_j2000_orig = 0.567;
    double jd_tt = 2460310.5;
    
    double ra_now, dec_now;
    J2000_to_JNOW(ra_j2000_orig, dec_j2000_orig, jd_tt,
                  0.0, 0.0, 0.0, 0.0,
                  &ra_now, &dec_now);
    
    double ra_j2000_back, dec_j2000_back;
    JNOW_to_J2000(ra_now, dec_now, jd_tt,
                  &ra_j2000_back, &dec_j2000_back);
    
    // ra_j2000_back and dec_j2000_back should match original values
    // (within numerical precision ~1e-12 radians or ~0.001 milliarcseconds)
}

// ============================================================================
// COORDINATE CONVERSION HELPERS
// ============================================================================

// Convert degrees to radians
#define DEG2RAD(deg) ((deg) * M_PI / 180.0)

// Convert radians to degrees
#define RAD2DEG(rad) ((rad) * 180.0 / M_PI)

// Convert hours to radians (for Right Ascension)
#define HOURS2RAD(hours) ((hours) * M_PI / 12.0)

// Convert radians to hours
#define RAD2HOURS(rad) ((rad) * 12.0 / M_PI)

// Example: RA = 18h 36m 56.3s, Dec = +38° 47' 01.2"
void example_sexagesimal() {
    // Convert RA from hours/minutes/seconds to radians
    double ra_hours = 18.0 + 36.0/60.0 + 56.3/3600.0;
    double ra_j2000 = HOURS2RAD(ra_hours);
    
    // Convert Dec from degrees/arcmin/arcsec to radians
    double dec_deg = 38.0 + 47.0/60.0 + 1.2/3600.0;
    double dec_j2000 = DEG2RAD(dec_deg);
    
    double jd_tt = 2460310.5;
    double ra_now, dec_now;
    
    J2000_to_JNOW(ra_j2000, dec_j2000, jd_tt,
                  0.0, 0.0, 0.0, 0.0,
                  &ra_now, &dec_now);
    
    // Convert back to degrees/hours for display
    double ra_now_hours = RAD2HOURS(ra_now);
    double dec_now_deg = RAD2DEG(dec_now);
}

// ============================================================================
// TIME SCALE CONVERSIONS (Approximate)
// ============================================================================

// UTC to TT (approximate, good to ~1 second)
double UTC_to_TT_approx(double jd_utc) {
    // TT = UTC + 69 seconds (as of 2024)
    return jd_utc + 69.0/86400.0;
}

// For precise applications, use ERFA's time functions:
// - eraUtctai() : UTC to TAI
// - eraTaitt()  : TAI to TT
// - eraUtcut1() : UTC to UT1 (requires DUT1 from IERS)
// - eraTttdb()  : TT to TDB (barycentric time)

// ============================================================================
// JULIAN DATE CONVERSIONS
// ============================================================================

// Calendar date to Julian Date (already in AstroCalc.h)
// double CDJD(double GD, int GM, int GY);

// Example: 2024 January 1.5 UTC
void example_julian_date() {
    double jd_utc = CDJD(1.5, 1, 2024);  // Returns 2460310.5
    double jd_tt = UTC_to_TT_approx(jd_utc);
    
    // Use jd_tt in coordinate conversions
}

// ============================================================================
// NOTES
// ============================================================================

// 1. All angles are in RADIANS, not degrees
// 2. Julian Date must be in TT (Terrestrial Time)
// 3. For most stars, use 0.0 for pr, pd, px, rv if data not available
// 4. Functions are accurate to sub-milliarcsecond level
// 5. CIRS is the modern replacement for "true place of date"
// 6. The functions handle all corrections automatically:
//    - Precession (~50 arcsec/year)
//    - Nutation (~9 arcsec amplitude)
//    - Aberration (~20 arcsec)
//    - Light deflection (up to 1.75 arcsec near Sun)
//    - Frame bias
//    - Proper motion (if provided)
//    - Parallax (if provided)

// ============================================================================
// COMPILE AND LINK
// ============================================================================

// The ERFA library is already integrated into your AstroCalc project.
// Just include the header:
//     #include "erfa.h"
// and call the functions as shown above.

// ============================================================================
