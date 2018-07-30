/*
Initializes the location parameters from editor-plased objects.

Author: Sparker 28.07.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Group\Group.hpp"

params [ ["_thisObject", "", [""]], ["_marker", "", [""]] ];

// Setup location's border from marker properties
private _mrkSize = getMarkerSize _marker;
if(_mrkSize select 0 == _mrkSize select 1) then { // if width==height, make it a circle
	private _radius = _mrkSize select 0;
	private _args = ["circle", _radius];
	CALL_METHOD(_thisObject, "setBorder", _args);
} else { // If width!=height, make border a rectangle
	private _dir = markerDir _marker;
	private _args = ["rectangle", [_mrkSize select 0, _mrkSize select 1, _dir] ];
	CALL_METHOD(_thisObject, "setBorder", _args);
};

// Setup location's spawn positions
private _radius = GET_VAR(_thisObject, "boundingRadius");
diag_log format ["Bounding radius: %1", _radius];
private _locPos = GET_VAR(_thisObject, "pos");
private _no = _locPos nearObjects _radius;

private _object = objNull;
private _type = "";
private _bps = []; //Building positions
private _bp = []; //Building position
private _bc = []; //Building capacity
private _inf_capacity = 0;
private _position = [];
private _bdir = 0; //Building direction
{
	_object = _x;
	if(CALL_METHOD(_thisObject, "isInBorder", [_object])) then
	{
		_type = typeOf _object;

		//A truck's position defined the position for tracked and wheeled vehicles
		if(_type == "B_Truck_01_transport_F") then {
			private _args = [T_PL_tracked_wheeled, [GROUP_TYPE_IDLE, GROUP_TYPE_VEH_NON_STATIC], getPosATL _object, direction _object, objNull];
			CALL_METHOD(_thisObject, "addSpawnPos", _args);
			deleteVehicle _object;
		};

		//A mortar's position defines the position for mortars
		if(_type == "B_Mortar_01_F") then {
			private _args = [[T_VEH, T_VEH_stat_mortar_light], [GROUP_TYPE_IDLE, GROUP_TYPE_VEH_STATIC], getPosATL _object, direction _object, objNull];
			CALL_METHOD(_thisObject, "addSpawnPos", _args);
			deleteVehicle _object;
		};

		//A low HMG defines a position for low HMGs and low GMGs
		if(_type == "B_HMG_01_F") then {
			private _args = [T_PL_HMG_GMG_low, [GROUP_TYPE_IDLE, GROUP_TYPE_VEH_STATIC], getPosATL _object, direction _object, objNull];
			CALL_METHOD(_thisObject, "addSpawnPos", _args);
			deleteVehicle _object;
		};

		//A high HMG defines a position for high HMGs and high GMGs
		if(_type == "B_HMG_01_high_F") then {
			private _args = [T_PL_HMG_GMG_high, [GROUP_TYPE_IDLE, GROUP_TYPE_VEH_STATIC], getPosATL _object, direction _object, objNull];
			CALL_METHOD(_thisObject, "addSpawnPos", _args);
			deleteVehicle _object;
		};

		if(_type == "Flag_BI_F") then {
			//Probably add support for the flag later
		};

		if(_type == "Sign_Arrow_Large_F") then { //Red arrow
			deleteVehicle _object;
		};

		if(_type == "Sign_Arrow_Large_Blue_F") then { //Blue arrow
			deleteVehicle _object;
		};
	};
}forEach _no;