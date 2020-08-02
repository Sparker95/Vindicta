#include "..\common.h"

#define pr private

params ["_pos"];

pr _loc = NEW("Location", [_pos]);
CALLM1(_loc, "setType", "roadblock");
CALLM1(_loc, "setBorderCircle", 60);
CALLM0(_loc, "build");