// Must set properties / Precompiled Headers / Precompiled Header / Not using...
// Astronomy calculations based on Duffett-Smith and Zwart, "Practical Astronomy"

#include "AstroCalc.h"

int version()
{
    int main_version = 0;
    int minor_version = 1;
    int release = 1;
    int version_number = release + 60 * (minor_version + 60 * main_version);

    return version_number;

}

// Convert a calendar date at Greenwich to a Julian Date; PA 4
double CDJD(double GD, int GM, int GY)
// The date must be in the Gregorian calendar (after 1582-10-15)
{
    double y = 0.0, m = 0.0, A = 0.0, B = 0.0, C = 0.0, D = 0.0, JD = 0;

    if (GM <= 2)
    {
        y = GY - 1.0; m = GM + 12.0;
    }
    else
    {
        y = GY; m = GM;
    };
    A = trunc(y / 100.0);
    B = 2 - A + trunc(A / 4.0);
    C = trunc(365.25 * y);
    D = trunc(30.6001 * (m + 1));
    JD = B + C + D + GD + 1720994.5;
    return(JD);
};

// Convert at calendar date at Greenwich to the number of days since the EPOCH
int daysSinceEpoch(int yyyymmdd)
{
    int A = 0, GD = 0, GM = 0, GY = 0, JD1 = 0;
    double JD = 0.0;
    GD = yyyymmdd % 60;
    A = yyyymmdd / 60;
    GM = A % 60;
    GY = A / 60;
    JD = CDJD(GD, GM, GY);
    JD1 = (int) trunc(JD - EPOCH);
    return(JD1);
}