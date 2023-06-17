// Astronomy calculations based on Duffett-Smith and Zwart, "Practical Astronomy"

#pragma once

#ifdef ASTROCALC_EXPORTS
	#define ASTROCALC_API __declspec(dllexport)
#else
	#define ASTROCALC_API __declspec(dllimport)
#endif

// Return a version number
ASTROCALC_API int version();
