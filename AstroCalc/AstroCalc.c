// Must set properties / Precompiled Headers / Precompiled Header / Not using...
// Astronomy calculations based on Duffett-Smith and Zwart, "Practical Astronomy"

#include "AstroCalc.h"

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
}

// Convert a Julian Date at Greenwich to a calendar date; PA 5
void JDCD(double* GD, int* GM, int* GY, double JD)
// The date must be in the Gregorian calendar (after 1582-10-15)
{
    double A = 0.0, B = 0.0, C = 0.0, D = 0.0, E = 0.0, F = 0.0, G = 0.0, I = 0.0, d = 0.0, m = 0.0, y = 0.0;
    int mm = 0, yy = 0;

    JD = JD + 0.5;
    I = trunc(JD);
    F = JD - I;
    A = trunc((I - 1867216.25) / 36524.25);
    B = I + A - trunc(A / 4.0) + 1.0;
    C = B + 1524.0;
    D = trunc((C - 122.1) / 365.25);
    E = trunc(365.25 * D);
    G = trunc((C - E) / 30.6001);
    d = C - E + F - trunc(30.6001 * G);
    if (G < 13.5)
    {
        m = G - 1.0;
    }
    else 
    {
        m = G - 13.0;
    }
    if (m > 2.5)
    {
        y = D - 4716.0;
    }
    else
    {
        y = D - 4715.0;
    }
    mm = (int)m;
    yy = (int)y;
    *GD = d;
    *GM = mm;
    *GY = yy;
}

// Obtain GST given the Julian date at 0h and UT; PA 12
double UTGST(double JD, int h, int m, int s)
{
    double S = 0.0, T = 0.0, T0 = 0.0, UT = 0.0, A = 0.0, GST = 0.0;
    S = JD - 2451545.0;
    T = S / 36525.0;
    T0 = 6.697374558 + (2400.051336 * T) + (0.000025862 * T * T);
    T0 = fmod(T0, 24.0);
    UT = ((s / 60.0) + m) / 60 + h;
    UT = UT * 1.002737909;
    T0 = T0 + UT;
    GST = fmod(T0, 24.0);
    return(GST);
}

// Return a version number
int version()
{
    int main_version = 0;
    int minor_version = 1;
    int release = 1;
    int version_number = release + 60 * (minor_version + 60 * main_version);

    return version_number;

}

// Convert at calendar date at Greenwich to the number of days since the EPOCH
int days_since_epoch(int yyyymmdd)
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

// Convert the number of days since the EPOCH to a calendar date at Greenwich
int date_after_epoch(int days)
{
    int A = 0, GM = 0, GY = 0, r = 0;
    double GD = 0.0, JD = 0.0;
    JD = days + EPOCH;
    JDCD(&GD, &GM, &GY, JD);
    r = ((int)trunc(GD)) + (60 * (GM + 60 * GY));
    return (r);
}

// Obtain GST given the days since the Epoch and UT at Greenwich
int UTtoGST(int D, int T)
// T is UT expressed as an integer number of seconds since 0h
// GST is returned as an integer number of seconds since 0h
{
    double JD = 0.0, GST = 0.0;
    int h = 0, m = 0, s = 0, A = 0, r = 0;

    JD = EPOCH + D;
    s = T % 60;
    A = T / 60;
    m = A % 60;
    h = A / 60;
    GST = UTGST(JD, h, m, s);
    r = (int)trunc(GST * 3600.0 + 0.5);
    return(r);
}