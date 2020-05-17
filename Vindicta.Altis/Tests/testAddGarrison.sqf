// src: "o_Location_N_9"
// dest: "o_Location_N_10"

#include "..\common.h"

private _garSrc = CALLM0("o_Location_N_9", "getGarrisonMilitaryMain");
private _garDst = CALLM0("o_Location_N_10", "getGarrisonMilitaryMain");

private _args = [_garSrc, true];
CALLM2(_garDst, "postMethodAsync", "addGarrison", _args);