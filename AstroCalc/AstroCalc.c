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
void JDCD(double JD, double* GD, int* GM, int* GY)
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

// Obtain the azimuth and altitude given the hour angle and declination; PA 25
void EqAltAz(double H, double dec, double lat, double* alt, double* az)
// H is expressed in decimal hours
// dec, alt and az are expressed in decimal degrees
{
    double sin_a = 0.0, cos_A = 0.0, sin_H = 0.0, a = 0.0, A = 0.0;
    H = RAD(H * 15.0);
    dec = RAD(dec);
    lat = RAD(lat);
    sin_a = sin(dec) * sin(lat) + cos(dec) * cos(lat) * cos(H);
    a = asin(sin_a);
    cos_A = (sin(dec) - sin(lat) * sin_a) / (cos(lat) * cos(a));
    A = acos(cos_A);
    sin_H = sin(H);
    if (sin_H < 0.0)
    {
        *az = DEG(A);
    }
    else
    {
        *az = 360.0 - DEG(A);
    }
    *alt = DEG(a);
}


// Obtain the hour angle and declination given the azimuth and altitude ; PA 26
void AltAzEq(double alt, double az, double lat, double* H, double* dec)
// H is expressed in decimal hours
// dec, alt and az are expressed in decimal degrees
{
    double sin_dec = 0.0, cos_H = 0.0, sin_A = 0.0, H_r = 0.0, dec_r = 0.0;
    alt = RAD(alt);
    az = RAD(az);
    lat = RAD(lat);
    sin_dec = sin(alt) * sin(lat) + cos(alt) * cos(lat) * cos(az);
    dec_r = asin(sin_dec);
    cos_H = (sin(alt) - sin(lat) * sin_dec) / (cos(lat) * cos(dec_r));
    H_r = acos(cos_H);
    sin_A = sin(az);
    if (sin_A < 0.0)
    {
        *H = DEG(H_r) / 15.0;
    }
    else
    {
        *H = (360.0 - DEG(H_r)) / 15.0;
    }
    *dec = DEG(dec_r);
}

// Convert the triple of integers x1 x2 x3 to a finite fraction in single integer format
int triple_to_ff(int x1, int x2, int x3)
// x1 is the most significant of the triple, eg YY, MM, DD ;  HH, MM, SS ;  DEG, MM, SS
{
    int x;
    x = x3 + 60 * (x2 + 60 * x1);
    return x;
}

// Convert the triple of integers x1, x2, x3 to a single decimal number
double triple_to_decimal(int x1, int x2, int x3)
{
    double d = 0.0;
    d = ((x3 / 60.0) + x2) / 60.0 + x1;
    return d;
}

// Convert a finite fraction in single integer format to the triple of integers x1 x2 x3
void ff_to_triple(int x, int *x1, int *x2, int *x3)
{
    int a = 0;
    *x3 = x % 60;
    a = x / 60;
    *x2 = a % 60;
    *x1 = a / 60;
}

// Convert a finite fraction in single integer format to a decimal number
double ff_to_decimal(int x)
{
    int x1 = 0, x2 = 0, x3 = 0;
    double d = 0.0;
    ff_to_triple(x, &x1, &x2, &x3);
    d = triple_to_decimal(x1, x2, x3);
    return d;
}

// Convert a decimal number to a finite fraction in single integer format
int decimal_to_ff(double d)
{
    int x1 = 0, x2 = 0, x3 = 0, x = 0;
    decimal_to_triple(d, &x1, &x2, &x3);
    x = triple_to_ff(x1, x2, x3);
    return x;
}

// Convert a decimal number to the triple of integers x1 x2 x3
void decimal_to_triple(double d, int *x1, int *x2, int *x3)
{
    double a = 0.0;
    *x1 = (int)trunc(d);
    a = 60.0 * (d - *x1);
    *x2 = (int)trunc(a);
    a = 60.0 * (a - *x2);
    *x3 = (int)trunc(a + 0.5);
}

// Return a version number
int version()
{
    int main_version = 0;
    int minor_version = 1;
    int release = 1;
    int version_number = triple_to_ff(release, minor_version, main_version);

    return version_number;

}

// Convert at calendar date at Greenwich to the number of days since the EPOCH
int days_since_epoch(int yyyymmdd)
{
    int A = 0, GD = 0, GM = 0, GY = 0, JD1 = 0;
    double JD = 0.0;
    ff_to_triple(yyyymmdd, &GY, &GM, &GD);
    JD = CDJD(GD, GM, GY);
    JD1 = (int) trunc(JD - EPOCH);
    return(JD1);
}

// Convert the number of days since the EPOCH to a calendar date at Greenwich
int date_after_epoch(int days)
// the date is returned in YYMMDD format
{
    int A = 0, D =0, GM = 0, GY = 0, r = 0;
    double GD = 0.0, JD = 0.0;
    JD = days + EPOCH;
    JDCD(JD, &GD, &GM, &GY);
    D = (int)trunc(GD);
    r = triple_to_ff(GY, GM, D);
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
    r = SEC(GST);
    return(r);
}

// Convert equatorial to horizon coordinates
void EQtoHZ_ext(int H, int dec, int lat, int *alt, int *az)
// alt, az, dec and lat are expressed in DEGMMSS format
// H is expressed in integer seconds
{
    double alt_dml = 0.0, az_dml = 0.0;
    double H_dml = 0.0, dec_dml = 0.0, lat_dml = 0.0;  // decimal quantities

    H_dml = ff_to_decimal(H);
    dec_dml = ff_to_decimal(dec);
    lat_dml = ff_to_decimal(lat);

    EqAltAz(H_dml, dec_dml, lat_dml, &alt_dml, &az_dml);

    *alt = decimal_to_ff(alt_dml);
    *az = decimal_to_ff(az_dml);
}

// Convert horizon to equatorial coordinates
void HZtoEQ_ext(int alt, int az, int lat, int* H, int* dec)
// alt, az, dec and lat are expressed in DEGMMSS format
// H is expressed in integer seconds
{
    double alt_dml = 0.0, az_dml = 0.0;
    double H_dml = 0.0, dec_dml = 0.0, lat_dml = 0.0;  // decimal quantities

    alt_dml = ff_to_decimal(alt);
    az_dml = ff_to_decimal(az);
    lat_dml = ff_to_decimal(lat);

    EqAltAz(alt_dml, az_dml, lat_dml, &H_dml, &dec_dml);

    *H = decimal_to_ff(H_dml);
    *dec = decimal_to_ff(dec_dml);
}