#define OOP_INFO
#define OOP_DEBUG
#define OOP_ERROR
#define OOP_WARNING
#define OFSTREAM_FILE "civpresence.rpt"
#include "..\common.h"
#include "..\AI\parameterTags.hpp"
#include "..\Location\Location.hpp"

// Enabled debug markers
//#define DEBUG_CIV_PRESENCE

// Civilians per m^2 max
// 7 bots per 100x100m square
#define MAX_DENSITY (4/100/100)

// Each house will contribute this amount of active civilians
#define N_CIVS_PER_HOUSE 1.0

// Look ahead time for player position interpolation
#define TIME_INTERPOLATE 7