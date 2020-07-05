#include "..\common.h"

private _locAndDist = CALLSM1("Location", "getNearestLocation", getPos player);
_locAndDist params ["_loc", "_dist"];

private _AI = CALLSM1("AICommander", "getAICommander", WEST);
CALLM2(_AI, "postMethodAsync", "debugAddGroupToLocation", [_loc ARG 5]);

