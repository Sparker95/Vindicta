#include "..\OOP_light\OOP_Light.h"

private _locAndDist = CALLSM1("Location", "getNearestLocation", getPos player);
_locAndDist params ["_loc", "_dist"];

private _AI = CALLSM1("AICommander", "getCommanderAIOfSide", WEST);
CALLM2(_AI, "postMethodAsync", "addGroupToLocation", [_loc ARG 5]);

