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

    int days = daysSinceEpoch(7232779);
    printf("2009-06-91 is %d days since the epoch\n", days);
}


