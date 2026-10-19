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
    const int strip[] = { -1, 23 * 3600, -30 * 3600, 3600, 30 * 3600 };
    const int polar_strip[] = { -1, 0, 60 * 3600, 2 * 3600, 90 * 3600 };
    const int equator_strip[] = { -1, 0, 0, 2 * 3600, 30 * 3600 };
    const int bad[] = { -3, 0, 0, 0, 0, 3600, 0 };
    const int bad_radius[] = { 180 * 3600 + 1, 0, 0 };
    assert(spherical_region_area(point) == 0.0);
    assert(fabs(spherical_region_area(hemisphere) - 2.0 * M_PI) < 1e-12);
    assert(fabs(spherical_region_area(sphere) - 4.0 * M_PI) < 1e-12);
    assert(fabs(spherical_region_area(octant) - M_PI / 2.0) < 1e-12);
    assert(fabs(spherical_region_area(reversed) - spherical_region_area(octant)) < 1e-12);
    assert(fabs(spherical_region_area(wrap) - spherical_region_area(shifted)) < 1e-12);
    assert(fabs(spherical_region_area(strip) - M_PI / 6.0) < 1e-12);
    assert(spherical_region_area(polar_strip) < spherical_region_area(equator_strip));
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
