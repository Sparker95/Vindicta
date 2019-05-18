#include "..\OOP_Light\OOP_Light.h"

#define pr private

params ["_pos"];

pr _loc = NEW("Location", [_pos]);
CALLM1(_loc, "setType", "roadblock");
CALLM2(_loc, "setBorder", "circle", [60]);
CALLM0(_loc, "build");