// Astronomy calculations based on Duffett-Smith and Zwart, "Practical Astronomy"

#pragma once
#include <math.h>

#ifdef ASTROCALC_EXPORTS
	#define ASTROCALC_API __declspec(dllexport)
#else
	#define ASTROCALC_API __declspec(dllimport)
#endif

#define EPOCH 2455196.5	// 2010 January 0.0

// Return a version number
ASTROCALC_API int version();

// Convert at calendar date at Greenwich to the number of days since the EPOCH
ASTROCALC_API int days_since_epoch(int yyyymmdd);

// Convert at calendar date at Greenwich to the number of days since the EPOCH
ASTROCALC_API int date_after_epoch(int days);

// Convert a calendar date at Greenwich to a Julian Date; PA 4
double CDJD(double GD, int GM, int GY);

// Convert a Julian Date at Greenwich to a calendar date; PA 5
void JDCD(double* GD, int* GM, int* GY, double JD);