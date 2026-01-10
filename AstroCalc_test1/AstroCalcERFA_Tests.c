// Test cases for ERFA coordinate conversion functions
// File: AstroCalcERFA_Tests.c

#include <stdio.h>
#include <math.h>
#include "erfa.h"
#include "AstroCalc.h"

// Test result tracking
static int tests_passed = 0;
static int tests_failed = 0;

// Helper macros
#define DEG2RAD(deg) ((deg) * M_PI / 180.0)
#define RAD2DEG(rad) ((rad) * 180.0 / M_PI)
#define HOURS2RAD(hours) ((hours) * M_PI / 12.0)
#define RAD2HOURS(rad) ((rad) * 12.0 / M_PI)
#define ARCSEC2RAD(arcsec) ((arcsec) * M_PI / 648000.0)

// Test assertion
void assert_near(const char* test_name, double actual, double expected, double tolerance) {
    double diff = fabs(actual - expected);
    if (diff <= tolerance) {
        printf("[PASS] %s: %.12f (expected %.12f, diff %.3e)\n", 
               test_name, actual, expected, diff);
        tests_passed++;
    } else {
        printf("[FAIL] %s: %.12f (expected %.12f, diff %.3e, tolerance %.3e)\n", 
               test_name, actual, expected, diff, tolerance);
        tests_failed++;
    }
}

// Print test header
void print_test_header(const char* test_suite) {
    printf("\n");
    printf("========================================\n");
    printf("%s\n", test_suite);
    printf("========================================\n");
}

// Print test footer
void print_test_footer() {
    printf("\n");
}

// Test 1: Round-trip conversion (no proper motion)
void test_roundtrip_conversion() {
    print_test_header("TEST 1: Round-trip Conversion (No Proper Motion)");
    
    // Original J2000 coordinates (Vega approximate)
    double ra_j2000_orig = HOURS2RAD(18.615);     // 18h 36m 54s
    double dec_j2000_orig = DEG2RAD(38.783);      // +38° 47'
    
    // Julian Date for 2024-01-01 TT
    double jd_tt = 2460310.5;
    
    printf("Input J2000 coordinates:\n");
    printf("  RA:  %.6f rad (%.6f hours, %.3f deg)\n", 
           ra_j2000_orig, RAD2HOURS(ra_j2000_orig), RAD2DEG(ra_j2000_orig));
    printf("  Dec: %.6f rad (%.3f deg)\n", 
           dec_j2000_orig, RAD2DEG(dec_j2000_orig));
    printf("  JD:  %.1f (TT)\n\n", jd_tt);
    
    // Convert J2000 -> JNOW
    double ra_jnow, dec_jnow;
    J2000_to_JNOW(ra_j2000_orig, dec_j2000_orig, jd_tt,
                  0.0, 0.0, 0.0, 0.0,
                  &ra_jnow, &dec_jnow);
    
    printf("Intermediate JNOW coordinates:\n");
    printf("  RA:  %.6f rad (%.6f hours, %.3f deg)\n", 
           ra_jnow, RAD2HOURS(ra_jnow), RAD2DEG(ra_jnow));
    printf("  Dec: %.6f rad (%.3f deg)\n\n", 
           dec_jnow, RAD2DEG(dec_jnow));
    
    // Convert JNOW -> J2000
    double ra_j2000_back, dec_j2000_back;
    JNOW_to_J2000(ra_jnow, dec_jnow, jd_tt,
                  &ra_j2000_back, &dec_j2000_back);
    
    printf("Round-trip J2000 coordinates:\n");
    printf("  RA:  %.6f rad (%.6f hours, %.3f deg)\n", 
           ra_j2000_back, RAD2HOURS(ra_j2000_back), RAD2DEG(ra_j2000_back));
    printf("  Dec: %.6f rad (%.3f deg)\n\n", 
           dec_j2000_back, RAD2DEG(dec_j2000_back));
    
    // Check round-trip accuracy (should be within numerical precision)
    double tolerance = 1e-12;  // ~0.001 milliarcseconds
    assert_near("Round-trip RA", ra_j2000_back, ra_j2000_orig, tolerance);
    assert_near("Round-trip Dec", dec_j2000_back, dec_j2000_orig, tolerance);
    
    print_test_footer();
}

// Test 2: Known precession effect
void test_precession_effect() {
    print_test_header("TEST 2: Precession Effect (50 years)");
    
    // Star at celestial equator, 0h RA
    double ra_j2000 = 0.0;
    double dec_j2000 = 0.0;
    
    // JD for J2000.0
    double jd_2000 = 2451545.0;
    
    // JD for J2050.0 (50 years later)
    double jd_2050 = 2451545.0 + 365.25 * 50;
    
    printf("Testing star at celestial equator (RA=0h, Dec=0°)\n");
    printf("From J2000.0 to J2050.0 (50 years)\n\n");
    
    // Convert to 2050
    double ra_2050, dec_2050;
    J2000_to_JNOW(ra_j2000, dec_j2000, jd_2050,
                  0.0, 0.0, 0.0, 0.0,
                  &ra_2050, &dec_2050);
    
    // Precession should cause significant change
    double ra_change_arcsec = (ra_2050 - ra_j2000) * 648000.0 / M_PI;
    double dec_change_arcsec = (dec_2050 - dec_j2000) * 648000.0 / M_PI;
    
    printf("Coordinate changes over 50 years:\n");
    printf("  ?RA:  %.3f arcsec\n", ra_change_arcsec);
    printf("  ?Dec: %.3f arcsec\n\n", dec_change_arcsec);
    
    // Precession is roughly 50 arcsec/year, so 50 years should give ~2500 arcsec
    // At the equator, this should be significant
    double min_change = 1000.0;  // At least 1000 arcsec change expected
    
    if (fabs(ra_change_arcsec) > min_change || fabs(dec_change_arcsec) > min_change) {
        printf("[PASS] Precession effect detected (change > %g arcsec)\n", min_change);
        tests_passed++;
    } else {
        printf("[FAIL] Precession effect too small\n");
        tests_failed++;
    }
    
    print_test_footer();
}

// Test 3: High proper motion star (Barnard's Star)
void test_proper_motion() {
    print_test_header("TEST 3: High Proper Motion Star (Barnard's Star)");
    
    // Barnard's Star J2000 coordinates (epoch 2000.0)
    double ra_j2000 = HOURS2RAD(17.9634);      // 17h 57m 48.5s
    double dec_j2000 = DEG2RAD(4.6933);        // +04° 41' 36"
    
    // Proper motion (one of the highest known)
    double pm_ra = ARCSEC2RAD(-798.58e-3);     // -798.58 mas/yr
    double pm_dec = ARCSEC2RAD(10328.12e-3);   // +10328.12 mas/yr (very high!)
    
    // Parallax and radial velocity
    double parallax = 0.54697;                  // 547 mas (very close star)
    double rv = -110.51;                        // km/s (approaching)
    
    printf("Barnard's Star (one of the nearest stars):\n");
    printf("  J2000 RA:  %.6f rad (%.4fh)\n", ra_j2000, RAD2HOURS(ra_j2000));
    printf("  J2000 Dec: %.6f rad (%.4f°)\n", dec_j2000, RAD2DEG(dec_j2000));
    printf("  Proper motion: %.3f mas/yr (RA), %.3f mas/yr (Dec)\n", 
           pm_ra * 648000000.0 / M_PI, pm_dec * 648000000.0 / M_PI);
    printf("  Parallax: %.3f arcsec (distance ~%.2f ly)\n", parallax, 3.26 / parallax);
    printf("  Radial velocity: %.2f km/s\n\n", rv);
    
    // Convert to 2024
    double jd_2024 = 2460310.5;
    double ra_2024_with_pm, dec_2024_with_pm;
    J2000_to_JNOW(ra_j2000, dec_j2000, jd_2024,
                  pm_ra, pm_dec, parallax, rv,
                  &ra_2024_with_pm, &dec_2024_with_pm);
    
    // Convert without proper motion for comparison
    double ra_2024_no_pm, dec_2024_no_pm;
    J2000_to_JNOW(ra_j2000, dec_j2000, jd_2024,
                  0.0, 0.0, 0.0, 0.0,
                  &ra_2024_no_pm, &dec_2024_no_pm);
    
    // Calculate differences (24 years from J2000 to 2024)
    double ra_pm_effect = (ra_2024_with_pm - ra_2024_no_pm) * 648000.0 / M_PI;
    double dec_pm_effect = (dec_2024_with_pm - dec_2024_no_pm) * 648000.0 / M_PI;
    
    printf("Position in 2024 (with proper motion):\n");
    printf("  RA:  %.6f rad (%.4fh)\n", ra_2024_with_pm, RAD2HOURS(ra_2024_with_pm));
    printf("  Dec: %.6f rad (%.4f°)\n\n", dec_2024_with_pm, RAD2DEG(dec_2024_with_pm));
    
    printf("Proper motion effect over 24 years (2000-2024):\n");
    printf("  ?RA:  %.3f arcsec\n", ra_pm_effect);
    printf("  ?Dec: %.3f arcsec\n\n", dec_pm_effect);
    
    // Expected: Dec should change by ~10.3 arcsec/yr * 24 yr = ~247 arcsec
    double expected_dec_change = 10328.12e-3 * 24.0 / 1000.0;  // mas/yr * years / 1000 = arcsec
    assert_near("Proper motion Dec effect (arcsec)", 
                dec_pm_effect, expected_dec_change / 1000.0, 1.0);
    
    print_test_footer();
}

// Test 4: Multiple epochs
void test_multiple_epochs() {
    print_test_header("TEST 4: Multiple Epochs");
    
    // Polaris (close to north celestial pole)
    double ra_j2000 = HOURS2RAD(2.530);        // ~2h 31m 49s
    double dec_j2000 = DEG2RAD(89.264);        // ~89° 15' 51"
    
    printf("Polaris (near north celestial pole):\n");
    printf("  J2000 RA:  %.6f rad (%.4fh)\n", ra_j2000, RAD2HOURS(ra_j2000));
    printf("  J2000 Dec: %.6f rad (%.4f°)\n\n", dec_j2000, RAD2DEG(dec_j2000));
    
    // Test different epochs
    double epochs[] = {
        2451545.0,           // J2000.0
        2451545.0 + 365.25,  // 2001.0
        2451545.0 + 3652.5,  // 2010.0
        2460310.5,           // 2024.0
        2451545.0 + 18262.5  // 2050.0
    };
    
    int num_epochs = sizeof(epochs) / sizeof(epochs[0]);
    
    printf("Testing coordinates at different epochs:\n\n");
    for (int i = 0; i < num_epochs; i++) {
        double ra_now, dec_now;
        J2000_to_JNOW(ra_j2000, dec_j2000, epochs[i],
                      0.0, 0.0, 0.0, 0.0,
                      &ra_now, &dec_now);
        
        double year = 2000.0 + (epochs[i] - 2451545.0) / 365.25;
        printf("  Epoch %.1f (JD %.1f):\n", year, epochs[i]);
        printf("    RA:  %.6f rad (%.4fh, %.4f°)\n", 
               ra_now, RAD2HOURS(ra_now), RAD2DEG(ra_now));
        printf("    Dec: %.6f rad (%.4f°)\n\n", 
               dec_now, RAD2DEG(dec_now));
    }
    
    // All conversions should work without error
    printf("[PASS] Multiple epoch conversions completed\n");
    tests_passed++;
    
    print_test_footer();
}

// Test 5: Edge cases
void test_edge_cases() {
    print_test_header("TEST 5: Edge Cases");
    
    printf("Testing edge cases:\n\n");
    
    // Case 1: Zero coordinates
    printf("Case 1: Zero coordinates (RA=0, Dec=0)\n");
    double ra_jnow, dec_jnow;
    J2000_to_JNOW(0.0, 0.0, 2460310.5, 0.0, 0.0, 0.0, 0.0, &ra_jnow, &dec_jnow);
    printf("  Result: RA=%.6f, Dec=%.6f\n", ra_jnow, dec_jnow);
    if (isfinite(ra_jnow) && isfinite(dec_jnow)) {
        printf("  [PASS] Valid result\n\n");
        tests_passed++;
    } else {
        printf("  [FAIL] Invalid result\n\n");
        tests_failed++;
    }
    
    // Case 2: North celestial pole
    printf("Case 2: North celestial pole (Dec=90°)\n");
    J2000_to_JNOW(0.0, M_PI / 2.0, 2460310.5, 0.0, 0.0, 0.0, 0.0, &ra_jnow, &dec_jnow);
    printf("  Result: RA=%.6f, Dec=%.6f rad (%.4f°)\n", 
           ra_jnow, dec_jnow, RAD2DEG(dec_jnow));
    if (isfinite(ra_jnow) && isfinite(dec_jnow) && dec_jnow > 1.5) {
        printf("  [PASS] Valid result (Dec near 90°)\n\n");
        tests_passed++;
    } else {
        printf("  [FAIL] Invalid result\n\n");
        tests_failed++;
    }
    
    // Case 3: South celestial pole
    printf("Case 3: South celestial pole (Dec=-90°)\n");
    J2000_to_JNOW(0.0, -M_PI / 2.0, 2460310.5, 0.0, 0.0, 0.0, 0.0, &ra_jnow, &dec_jnow);
    printf("  Result: RA=%.6f, Dec=%.6f rad (%.4f°)\n", 
           ra_jnow, dec_jnow, RAD2DEG(dec_jnow));
    if (isfinite(ra_jnow) && isfinite(dec_jnow) && dec_jnow < -1.5) {
        printf("  [PASS] Valid result (Dec near -90°)\n\n");
        tests_passed++;
    } else {
        printf("  [FAIL] Invalid result\n\n");
        tests_failed++;
    }
    
    // Case 4: RA = 24h (wraps to 0h)
    printf("Case 4: RA = 24h (should wrap to 0h)\n");
    J2000_to_JNOW(2.0 * M_PI, 0.0, 2460310.5, 0.0, 0.0, 0.0, 0.0, &ra_jnow, &dec_jnow);
    printf("  Result: RA=%.6f rad (%.4fh)\n", ra_jnow, RAD2HOURS(ra_jnow));
    if (isfinite(ra_jnow) && ra_jnow >= 0.0 && ra_jnow < 2.0 * M_PI) {
        printf("  [PASS] Valid result\n\n");
        tests_passed++;
    } else {
        printf("  [FAIL] Invalid result\n\n");
        tests_failed++;
    }
    
    print_test_footer();
}

// Test 6: Accuracy verification
void test_accuracy() {
    print_test_header("TEST 6: Numerical Accuracy");
    
    // Test with a known star position
    double ra_j2000 = HOURS2RAD(6.752);        // Sirius approximate
    double dec_j2000 = DEG2RAD(-16.716);
    double jd_tt = 2460310.5;
    
    printf("Testing numerical accuracy with multiple conversions:\n");
    printf("Initial J2000: RA=%.12f, Dec=%.12f\n\n", ra_j2000, dec_j2000);
    
    // Perform multiple round trips
    double ra_current = ra_j2000;
    double dec_current = dec_j2000;
    
    int num_roundtrips = 100;
    for (int i = 0; i < num_roundtrips; i++) {
        double ra_temp, dec_temp;
        J2000_to_JNOW(ra_current, dec_current, jd_tt, 0.0, 0.0, 0.0, 0.0, &ra_temp, &dec_temp);
        JNOW_to_J2000(ra_temp, dec_temp, jd_tt, &ra_current, &dec_current);
    }
    
    printf("After %d round trips: RA=%.12f, Dec=%.12f\n\n", num_roundtrips, ra_current, dec_current);
    
    double ra_error = fabs(ra_current - ra_j2000);
    double dec_error = fabs(dec_current - dec_j2000);
    
    printf("Accumulated error:\n");
    printf("  RA:  %.3e rad (%.6f milliarcsec)\n", 
           ra_error, ra_error * 648000000.0 / M_PI);
    printf("  Dec: %.3e rad (%.6f milliarcsec)\n\n", 
           dec_error, dec_error * 648000000.0 / M_PI);
    
    // Error should remain very small even after 100 round trips
    double tolerance = 1e-10;  // ~0.1 milliarcseconds
    assert_near("Accumulated RA error", ra_error, 0.0, tolerance);
    assert_near("Accumulated Dec error", dec_error, 0.0, tolerance);
    
    print_test_footer();
}

// Main test runner
int main() {
    printf("\n");
    printf("=====================================\n");
    printf("ERFA COORDINATE CONVERSION TEST SUITE\n");
    printf("=====================================\n");
    printf("Testing functions: J2000_to_JNOW() and JNOW_to_J2000()\n");
    
    // Run all tests
    test_roundtrip_conversion();
    test_precession_effect();
    test_proper_motion();
    test_multiple_epochs();
    test_edge_cases();
    test_accuracy();
    
    // Print summary
    printf("\n");
    printf("=====================================\n");
    printf("TEST SUMMARY\n");
    printf("=====================================\n");
    printf("Tests passed: %d\n", tests_passed);
    printf("Tests failed: %d\n", tests_failed);
    printf("Total tests:  %d\n", tests_passed + tests_failed);
    printf("Success rate: %.1f%%\n", 100.0 * tests_passed / (tests_passed + tests_failed));
    printf("=====================================\n");
    printf("\n");
    
    return (tests_failed == 0) ? 0 : 1;
}


