/*
Create an empty location object
return value: the location object.
*/

params ["_pos", "_name", "_type"];

private _o = "Sign_Arrow_Large_Pink_F" createVehicle _pos;
hideObjectGlobal _o;

//==== Initialize general variables ====
_o setVariable ["l_st", [], false]; //Spawn types array
_o setVariable ["l_flag", [], false]; //todo add support for the flag The position of the flag if it should be here or [] if it doesn here
_o setVariable ["l_name", _name, true]; //The name of this location. Mainly for debug reasons.
_o setVariable ["l_inf_capacity", 0, false]; //Maximum capacity for infantry
//_o setVariable ["l_side", _side];
_o setVariable ["l_type", _type, true]; //Type of this location. See initVariablesServer.sqf for possible types.
_o setVariable ["l_thread", nil, false]; //Thread handle for for this location
_o setVariable ["l_oAIAlertStateScript", objNull, false];	//Object returned by a call to AI_fnc_startMediumLevelScript
_o setVariable ["l_oAIEnemiesScript", objNull, false];		//Object returned by a call to AI_fnc_startMediumLevelScript
_o setVariable ["l_AIScriptsMutex", 0, false];				//A mutex to synchronize starts/stops of AI sripts 
_o setVariable ["l_alertState", LOC_AS_safe, false]; //The alert state of this location
_o setVariable ["l_alertStateInternal", LOC_AS_safe, false]; //The alert state reported by enemy management thread
_o setVariable ["l_alertStateExternal", LOC_AS_safe, false]; //The alert state set by higher level modules
_o setVariable ["l_forceSpawnTimer", 0, false]; //When the timer is above zero, the location is forced to spawned

//=== Initialize the border type ====
_o setVariable ["l_borderType", 0, false]; //0 is circle, 1 is rectangle
_o setVariable ["l_boundingRadius", 5, false]; //This will be recalculated later with setBorderXXX functions
/*
Border data is:
	radius(number) - if the border type is circle
	[a, b, direction] - if the border type is a rectangle
*/
_o setVariable ["l_borderData", 5, false]; //If the border is circle, it only needs a radius

//==== Create the main garrison of this location ====
private _g_main = [] call gar_fnc_createGarrison;
[_g_main, _name + ": main gar."] call gar_fnc_setName;
[_g_main, _o] call gar_fnc_setLocation;
//[_g_main] call gar_fnc_startThread; //todo don't need to start the thread manually any more
//[_g_main, G_AS_safe] call gar_fnc_setAlertState;
_o setVariable ["l_garrison_main", _g_main, false];
_o setVariable ["l_template_main", []]; //Template for the main garrison
_o setVariable ["l_garrison_civ", objNull]; //todo civilian garrisons

//Dynamic simulation stuff
//todo delete this
_o enableDynamicSimulation true;

//Marker
//todo redo the markers
_o setVariable ["l_marker", ""];

_o