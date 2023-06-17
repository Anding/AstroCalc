// Must set properties / Precompiled Headers / Precompiled Header / Not using...
// Astronomy calculations based on Duffet-Smith and Zwart, "Practical Astronomy"

int version()
{
    int main_version = 0;
    int minor_version = 1;
    int release = 1;
    int version_number = release + 60 * (minor_version + 60 * main_version);

    return version_number;
    
}