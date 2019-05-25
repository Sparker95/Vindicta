#include "OOP_Light\OOP_Light.h"

/*
This file is called in preinit through cfgFunctions
preInit is executed before JIP functions and before init.sqf.
*/

// Initialize classes and other things
call compile preprocessFileLineNumbers "initModules.sqf";

// Only players
if (hasInterface) then {
	gIntelDatabaseClient = NEW("IntelDatabaseClient", [playerSide]);

	private _dummyIntel = NEW("IntelCommanderAction", []);
	SETV(_dummyIntel, "side", EAST);
	SETV(_dummyIntel, "strength", 30);
	CALLM1(gIntelDatabaseClient, "addIntel", _dummyIntel);

	_dummyIntel = NEW("IntelCommanderActionAttack", []);
	SETV(_dummyIntel, "side", EAST);
	SETV(_dummyIntel, "strength", 30);
	CALLM1(gIntelDatabaseClient, "addIntel", _dummyIntel);

	_dummyIntel = NEW("IntelCommanderActionReinforce", []);
	SETV(_dummyIntel, "side", EAST);
	SETV(_dummyIntel, "strength", 30);
	CALLM1(gIntelDatabaseClient, "addIntel", _dummyIntel);
};