// Must set properties / Precompiled Headers / Precompiled Header / Not using...
// Add to project the existing files, AstroCalc.h and AstroCalc.c, in place

#include <stdio.h>
#include "..\AstroCalc\AstroCalc.h"

int main()
{
    int version_number = version();
    printf("Version number %d\n", version_number);

    double JD = CDJD(19.75, 6, 2009);
    printf("2009-06-19.75 is Julian Date %f\n", JD);

    double day = 0.0;
    int month = 0, year = 0;
    JDCD(2455002.25 , &day, &month, &year);
    printf("JD 2,455,002.25 is calendar date %d_%d_%f\n", year, month, day);

    double GST = UTGST(2444351.5, 14, 36, 52);
    printf("GST at JD 24443511.5 14:36:52 is %f\n", GST);

    double az = 0.0, alt = 0.0;
    EqAltAz(5.862222, 23.219444, 52.0, &alt, &az);
    printf("Alt = %f, Az = %f, if H = 5.862222, Dec = 23.219444, Lat = 52.0\n", az, alt);

}


