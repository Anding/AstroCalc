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