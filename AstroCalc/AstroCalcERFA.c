// ERFA wrapper functions for J2000 (ICRS) to JNOW (CIRS) coordinate interconversion
// Uses the ERFA (Essential Routines for Fundamental Astronomy) library
// https://github.com/liberfa/erfa

#include "erfa.h"
#include "AstroCalc.h"

/*
** Convert J2000.0 (ICRS) coordinates to JNOW (CIRS) coordinates
**
** Given:
**    ra_j2000   double  Right ascension at J2000.0 (radians)
**    dec_j2000  double  Declination at J2000.0 (radians)
**    jd_tt      double  Julian Date in TT (Terrestrial Time)
**    pr         double  Proper motion in RA (radians/year), default 0.0
**    pd         double  Proper motion in Dec (radians/year), default 0.0
**    px         double  Parallax (arcseconds), default 0.0
**    rv         double  Radial velocity (km/s, +ve if receding), default 0.0
**
** Returned:
**    ra_jnow    double* Right ascension at date (CIRS) (radians)
**    dec_jnow   double* Declination at date (CIRS) (radians)
**
** Notes:
**    1) This function transforms ICRS star coordinates at J2000.0 to 
**       geocentric CIRS (Celestial Intermediate Reference System) coordinates
**       at the specified date, accounting for precession, nutation, frame bias,
**       proper motion, parallax, aberration, and gravitational light deflection.
**
**    2) The Julian Date should be in TT (Terrestrial Time). For most applications,
**       UTC + 32.184 + leap_seconds is adequate, or simply use UTC without
**       significant loss of accuracy for non-critical applications.
**
**    3) For catalog positions without proper motion data, set pr, pd, px, rv to 0.0
**
**    4) CIRS is the modern replacement for "mean place of date" and "true place of date"
*/
void J2000_to_JNOW(double ra_j2000, double dec_j2000, double jd_tt,
                   double pr, double pd, double px, double rv,
                   double* ra_jnow, double* dec_jnow)
{
    double eo;  // equation of the origins (not used here but required by ERFA)
    
    // ERFA expects JD split into two parts for precision
    // Use J2000.0 epoch as the first part and offset as the second part
    double date1 = 2451545.0;  // J2000.0 epoch
    double date2 = jd_tt - 2451545.0;
    
    // Call ERFA function to transform ICRS (J2000.0) to CIRS (JNOW)
    eraAtci13(ra_j2000, dec_j2000, pr, pd, px, rv, 
              date1, date2, ra_jnow, dec_jnow, &eo);
}

/*
** Convert JNOW (CIRS) coordinates to J2000.0 (ICRS) coordinates
**
** Given:
**    ra_jnow    double  Right ascension at date (CIRS) (radians)
**    dec_jnow   double  Declination at date (CIRS) (radians)
**    jd_tt      double  Julian Date in TT (Terrestrial Time)
**
** Returned:
**    ra_j2000   double* Right ascension at J2000.0 (radians)
**    dec_j2000  double* Declination at J2000.0 (radians)
**
** Notes:
**    1) This function transforms geocentric CIRS coordinates at the specified
**       date back to ICRS (J2000.0) coordinates, removing precession, nutation,
**       frame bias, aberration, and gravitational light deflection.
**
**    2) The Julian Date should be in TT (Terrestrial Time). For most applications,
**       UTC + 32.184 + leap_seconds is adequate, or simply use UTC without
**       significant loss of accuracy for non-critical applications.
**
**    3) This function is the inverse of J2000_to_JNOW (when proper motion terms
**       are zero). The iterative techniques used by ERFA ensure accurate inversion.
**
**    4) The returned coordinates are astrometric ICRS, suitable for catalog work.
**       Proper motion is not computed - the result is the position at J2000.0.
*/
void JNOW_to_J2000(double ra_jnow, double dec_jnow, double jd_tt,
                   double* ra_j2000, double* dec_j2000)
{
    double eo;  // equation of the origins (not used here but required by ERFA)
    
    // ERFA expects JD split into two parts for precision
    // Use J2000.0 epoch as the first part and offset as the second part
    double date1 = 2451545.0;  // J2000.0 epoch
    double date2 = jd_tt - 2451545.0;
    
    // Call ERFA function to transform CIRS (JNOW) to ICRS (J2000.0)
    eraAtic13(ra_jnow, dec_jnow, date1, date2, ra_j2000, dec_j2000, &eo);
}
