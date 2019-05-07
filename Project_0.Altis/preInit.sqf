#include "OOP_Light\OOP_Light.h"

/*
This file is called in preinit through cfgFunctions
preInit is executed before JIP functions and before init.sqf.
*/

// Initialize classes and other things
call compile preprocessFileLineNumbers "initModules.sqf"

// Only players
if (hasInterface) then {
	gIntelDatabaseClient = NEW("IntelDatabaseClient", [sidePlayer]);
};