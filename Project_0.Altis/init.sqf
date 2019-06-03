#define OOP_INFO
#define OOP_DEBUG
#include "OOP_Light\OOP_Light.h"

#define DEBUG

#ifndef _SQF_VM
// No saving
enableSaving [ false, false ]; // Saving disabled without autosave.

// If a client, wait for the server to finish its initialization
if (!IS_SERVER) then {
	private _str = format ["Waiting for server init, time: %1", diag_tickTime];
	systemChat _str;
	OOP_INFO_0(_str);

	waitUntil {! isNil "serverInitDone"};

	_str = format ["Server initialization completed at time: %1", diag_tickTime];
	systemChat _str;
	OOP_INFO_0(_str);
};
#endif

// if(true) exitWith {}; // Keep it here in case we want to not start the actual mission but to test some other code
if(IS_SERVER) then {
	gGameModeName = switch (PROFILE_NAME) do {
		//case "Sparker": { "GameModeRandom" };
		case "billw": 	{ "EmptyGameMode" };
		case "Jeroen not": 	{ "EmptyGameMode" };
		case "Marvis": 	{ "EmptyGameMode" };
		default 		{ "EmptyGameMode" };
	};
	PUBLIC_VARIABLE "gGameModeName";
} else {
	waitUntil { !isNil "gGameModeName" };
};

CRITICAL_SECTION {
	gGameMode = NEW(gGameModeName, []);

	diag_log format["Initializing game mode %1", GETV(gGameMode, "name")];
	CALLM(gGameMode, "init", []);
	diag_log format["Initialized game mode %1", GETV(gGameMode, "name")];

	serverInitDone = 1;
	PUBLIC_VARIABLE "serverInitDone";
};


fn_isect_update = {
	params ["_obj"];

	private _pos = getPos _obj;
	private _dir = getDir _obj;
	private _className = typeOf _obj;

	private _bb = [_className] call misc_fnc_boundingBoxReal;
	private _bx = _bb select 1 select 0; //width
	private _by = _bb select 1 select 1; //lenth
	private _bz = _bb select 1 select 2; //height

	private _c = cos _dir;
	private _s = sin _dir;


	private _posASL = ATLTOASL _pos;
	private _pos_0 = _posASL vectorAdd [_bx*_c + _by*_s, -_bx*_s + _by*_c, 1];
	private _pos_1 = _posASL vectorAdd [_bx*_c - _by*_s, -_bx*_s - _by*_c, 1];
	private _pos_2 = _posASL vectorAdd [-_bx*_c - _by*_s, _bx*_s - _by*_c, 1];
	private _pos_3 = _posASL vectorAdd [-_bx*_c + _by*_s, _bx*_s + _by*_c, 1];

	private _posArray = [_pos_0, _pos_1, _pos_2, _pos_3];

	private _color = [1,1,0,1];
	drawLine3D [ASLToAGL _pos_0, ASLToAGL _pos_2, _color];
	drawLine3D [ASLToAGL _pos_1, ASLToAGL _pos_3, _color];
	drawLine3D [ASLToAGL _pos_1, ASLToAGL _pos_2, _color];
	drawLine3D [ASLToAGL _pos_0, ASLToAGL _pos_3, _color];

	//Find objects
	//First check with line intersections
	private _o = 
			  lineIntersectsSurfaces [_pos_0, _pos_2, _obj, objNull, false]; //CF_FIRST_CONTACT + CF_ALL_OBJECTS
	_o append lineIntersectsSurfaces [_pos_1, _pos_3, _obj, objNull, false]; //CF_FIRST_CONTACT + CF_ALL_OBJECTS
	_o append lineIntersectsSurfaces [_pos_1, _pos_2, _obj, objNull, false]; //CF_FIRST_CONTACT + CF_ALL_OBJECTS
	_o append lineIntersectsSurfaces [_pos_0, _pos_3, _obj, objNull, false]; //CF_FIRST_CONTACT + CF_ALL_OBJECTS
	{
		_x params ["_intersectPosASL", "_surfaceNormal", "_intersectObj", "_parentObject"];
		drawIcon3D ["\a3\ui_f\data\gui\cfg\hints\BasicLook_ca.paa", [1,1,1,1], ASLToAGL _intersectPosASL, 1, 1, 45, "RayHit", 1, 0.05, "TahomaB"];
	} forEach _o;

	private _radius = sqrt (_bx*_bx + _by*_by);
	private _o = nearestObjects [_pos, [], (_radius + 1) max 1.7, true] - [_obj];

	// private _collisions = _o select { _x isKindOf "allVehicles" };
	{
		drawIcon3D ["\a3\ui_f\data\gui\cfg\hints\BasicLook_ca.paa", [1,0.5,0.5,1], ASLToAGL getPosASL _x, 1, 1, 45, typeOf _x, 1, 0.05, "TahomaB"];
	} forEach _o;
};

fn_do_thing = {
	currObj = cursorObject;
	currObj allowDamage false;
	currObj enableSimulation false;
	onEachFrame {
		[currObj] call fn_isect_update;
	};
};