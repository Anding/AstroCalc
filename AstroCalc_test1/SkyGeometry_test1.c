#include <assert.h>
#include <stdio.h>
#include "..\AstroCalc\AstroCalc.h"

int main(void)
{
    const int point[] = { 0, 0, 0 };
    const int hemisphere[] = { 90 * 3600, 0, 0 };
    const int sphere[] = { 180 * 3600, 0, 0 };
    const int tiny[] = { 1, 0, 0 };
    const int larger[] = { 2, 0, 0 };
    const int octant[] = { -3, 0, 0, 6 * 3600, 0, 0, 90 * 3600 };
    const int reversed[] = { -3, 0, 90 * 3600, 6 * 3600, 0, 0, 0 };
    const int wrap[] = { -4, 23 * 3600, 10 * 3600, 3600, 10 * 3600,
        3600, 30 * 3600, 23 * 3600, 30 * 3600 };
    const int shifted[] = { -4, 11 * 3600, 10 * 3600, 13 * 3600, 10 * 3600,
        13 * 3600, 30 * 3600, 11 * 3600, 30 * 3600 };
    const int rectangle[] = { -4, 23 * 3600, -30 * 3600, 3600, -30 * 3600,
        3600, 30 * 3600, 23 * 3600, 30 * 3600 };
    const int bad[] = { -3, 0, 0, 0, 0, 3600, 0 };
    const int bad_radius[] = { 180 * 3600 + 1, 0, 0 };
    const int polar[] = { 0, 80 * 3600, 8 * 3600, 80 * 3600, 16 * 3600, 80 * 3600 };
    const int balanced[] = { 0, 0, 6 * 3600, 0, 12 * 3600, 0, 18 * 3600, 0 };
    int ra, dec, reversed_ra, reversed_dec;
    assert(spherical_polygon_centre(octant + 1, 3, &ra, &dec));
    assert(ra == 3 * 3600 && dec == 35 * 3600 + 15 * 60 + 52);
    assert(spherical_polygon_centre(reversed + 1, 3, &reversed_ra, &reversed_dec));
    assert(ra == reversed_ra && dec == reversed_dec);
    assert(spherical_polygon_centre(wrap + 1, 4, &ra, &dec));
    assert(ra == 0 && dec > 20 * 3600 && dec < 21 * 3600);
    assert(spherical_polygon_centre(shifted + 1, 4, &reversed_ra, &reversed_dec));
    assert(reversed_ra == 12 * 3600 && reversed_dec == dec);
    assert(spherical_polygon_centre(polar, 3, &ra, &dec));
    assert(ra == 0 && dec == 90 * 3600);
    assert(!spherical_polygon_centre(balanced, 4, &ra, &dec));
    assert(!spherical_polygon_centre(octant + 1, 2, &ra, &dec));
    assert(spherical_region_area(point) == 0.0);
    assert(fabs(spherical_region_area(hemisphere) - 2.0 * M_PI) < 1e-12);
    assert(fabs(spherical_region_area(sphere) - 4.0 * M_PI) < 1e-12);
    assert(fabs(spherical_region_area(octant) - M_PI / 2.0) < 1e-12);
    assert(fabs(spherical_region_area(reversed) - spherical_region_area(octant)) < 1e-12);
    assert(fabs(spherical_region_area(wrap) - spherical_region_area(shifted)) < 1e-12);
    // Great-circle edges bow beyond constant-declination corner bounds.
    assert(spherical_region_area(rectangle) > M_PI / 6.0);
    assert(spherical_polygon_contains(0, 30 * 3600, rectangle + 1, 4));
    assert(!spherical_polygon_contains(0, 31 * 3600, rectangle + 1, 4));
    assert(spherical_region_area_compare(tiny, larger) == -1);
    assert(spherical_region_area_compare(larger, tiny) == 1);
    assert(spherical_region_area_compare(wrap, wrap) == 0);
    assert(spherical_region_area_compare(octant, hemisphere) == -1);
    assert(isnan(spherical_region_area(bad)));
    assert(isnan(spherical_region_area(bad_radius)));
    assert(spherical_region_area_compare(bad, hemisphere) == 2);
    assert(spherical_polygon_contains(3600, 20 * 3600, octant + 1, 3));
    assert(!spherical_polygon_contains(13 * 3600, -20 * 3600, octant + 1, 3));
    assert(spherical_polygon_contains(0, 20 * 3600, wrap + 1, 4));
    assert(!spherical_polygon_contains(12 * 3600, -20 * 3600, wrap + 1, 4));
    puts("Sky geometry passed");
    return 0;
}
