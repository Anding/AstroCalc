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
    JDCD(&day, &month, &year, 2455002.25);
    printf("JD 2,455,002.25 is calendar date %d_%d_%f\n", year, month, day);

    int days = days_since_epoch(7232779);
    printf("2009-06-19 (encoded as 7232779) is %d days since the epoch\n", days);

    int r = date_after_epoch(-195);
    printf("-195 days after the Epoch is the date encoded as %d\n", r);
}


