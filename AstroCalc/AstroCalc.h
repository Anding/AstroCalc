// Astronomy calculations based on Duffett-Smith and Zwart, "Practical Astronomy"

#pragma once
#define _USE_MATH_DEFINES
#include <math.h>

#ifdef ASTROCALC_EXPORTS
	#define ASTROCALC_API __declspec(dllexport)
#else
	#define ASTROCALC_API __declspec(dllimport)
#endif

#define EPOCH 2455196.5	// 2010 January 0.0
#define RAD(x) ((x) * M_PI / 180.0)					// convert degrees to radians
#define DEG(x) ((x) * 180.0 / M_PI)					// convert radians to degrees
#define SEC(x) (int)trunc((x) * 3600.0 + 0.5)		// convert decimal hours to integer seconds

// Convert a calendar date at Greenwich to a Julian Date; PA 4
double CDJD(double GD, int GM, int GY);

// Convert a Julian Date at Greenwich to a calendar date; PA 5
void JDCD(double* GD, int* GM, int* GY, double JD);

// Obtain GST given the Julian date at 0h and UT; PA 12
double UTGST(double JD, int h, int m, int s);

// Obtain the azimuth and altitude given the hour angle and declination; PA 25
void EqAltAz(double* alt, double* az, double H, double dec, double lat);

// Return a version number
ASTROCALC_API int version();

// Convert at calendar date at Greenwich to the number of days since the EPOCH
ASTROCALC_API int days_since_epoch(int yyyymmdd);

// Convert at calendar date at Greenwich to the number of days since the EPOCH
ASTROCALC_API int date_after_epoch(int days);

// Obtain GST given the days since the Epoch and UT at Greenwich
ASTROCALC_API int UTtoGST(int D, int T);

// Convert equatorial to horizon coordinates
ASTROCALC_API void EQtoHZ(int* alt, int* az, int H, int dec, int lat);