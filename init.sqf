/*
Dirty init.sqf
add inits here until it's so fucked up, then redo it all over again
*/

//==== Locations initialization
//player allowDamage false;
call compile preprocessFileLineNumbers "initModules.sqf";
if(isServer) then
{
	allLocations = call compile preprocessFileLineNumbers "Init\createAllLocations.sqf";
	[allLocations] call compile preprocessFileLineNumbers "Init\initAllGarrisons.sqf";

	HCGarrisonWEST = [] call gar_fnc_createGarrison;
	[HCGarrisonWEST, "HC WEST"] call gar_fnc_setName;
	[HCGarrisonWEST, WEST] call gar_fnc_setSide;
	[HCGarrisonWEST, G_AS_none] call gar_fnc_setAlertState;
	[HCGarrisonWEST] call gar_fnc_spawnGarrison;

	HCGarrisonEAST = [] call gar_fnc_createGarrison;
	[HCGarrisonEAST, "HC EAST"] call gar_fnc_setName;
	[HCGarrisonEAST, EAST] call gar_fnc_setSide;
	[HCGarrisonEAST, G_AS_none] call gar_fnc_setAlertState;
	[HCGarrisonEAST] call gar_fnc_spawnGarrison;

	publicVariable "allLocations";
};


//Commander's map
UI_fnc_onMapSingleClick =
compile preprocessfilelinenumbers "UI\onMapSingleClick.sqf";
onMapSingleClick {call UI_fnc_onMapSingleClick;};