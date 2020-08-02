#include "..\..\common.h"

[] spawn COMPILE_COMMON("AI\VirtualRoute\gps_core\init.sqf");

CALL_COMPILE_COMMON("AI\VirtualRoute\VirtualRoute.sqf");

[] spawn COMPILE_COMMON("AI\VirtualRoute\debug\init.sqf");
