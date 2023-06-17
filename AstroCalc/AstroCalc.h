// Astronomy calculations based on Duffet-Smith and Zwart, "Practical Astronomy"

#pragma once

#ifdef _WINDOWS
	#define ASTROCALC_API __declspec(dllexport)
#else
	#define ASTROCALC_API 
#endif

// Return a version number
ASTROCALC_API int version();
