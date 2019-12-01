#define OOP_INFO
#define OOP_DEBUG
#include "OOP_Light\OOP_Light.h"

#define DEBUG

if(IS_SERVER) then {
	gGameModeName = "CivilWarGameMode";
};

CRITICAL_SECTION {
		gGameMode = NEW(gGameModeName, []);

		systemChat format["Initializing game mode %1", GETV(gGameMode, "name")];
		CALLM(gGameMode, "init", []);
		systemChat format["Initialized game mode %1", GETV(gGameMode, "name")];
};
