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

	// Create GarrisonDatabaseClient
	gGarrisonDBClient = NEW("GarrisonDatabaseClient", []);	

/*
	private _serial = ["IntelCommanderActionAttack","o_intelcommanderactionattack_n_0_12",[2035,6,24,12,6],nil,[21281.7,7212.84,0],nil,nil,"o_IntelCommanderActionAttack_N_0_10",playerSide,[17430,13161,0],[21082,7324,0],"o_Garrison_N_0_27",[21281.7,7212.84,0],nil,nil,[2035,6,24,12,8.93733],[0,0,0,0,0,0,0,0],"o_Garrison_N_0_9","Reinforce garrison","o_Garrison_N_0_10",nil,nil];
	private _dummyIntel = ["IntelCommanderActionAttack", []] call OOP_new;
	[_dummyIntel, _serial] call OOP_deserialize;
	CALLM1(gIntelDatabaseClient, "addIntel", _dummyIntel);
*/

	// Initialize notification system
	CALLSM0("Notification", "staticInit");

};