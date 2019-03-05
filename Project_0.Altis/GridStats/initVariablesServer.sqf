#define OOP_DEBUG
#include "..\OOP_Light\OOP_Light.h"
#include "..\OOP_Light\OOP_Light_init.sqf"

//Initialize global server variables and grids. Execute after initFunctions.sqf

ws_territory		= call ws_fnc_newGridArray;	//Territories, >0 means AAF, <0 means FIA
ws_frontlineSmooth	= call ws_fnc_newGridArray;	//Smooth frontline
ws_frontline		= call ws_fnc_newGridArray;	//Frontline
ws_frontlineDir		= call ws_fnc_newGridArray;	//Frontline direction

private _args = ["0", "1", "2", "3"]; // message receiver, interval, message, timer service
private _newCell = NEW("Cell", _args);

OOP_DEBUG_1("ws_territory: %1", ws_territory);
OOP_DEBUG_1("_newGrid: %1", _newGrid);
_newGrid call OOP_dumpAllVariables;
