#define OOP_INFO
#define OOP_DEBUG
#include "..\OOP_Light\OOP_Light.h"
#include "..\Group\Group.hpp"

// Class: Location
/*
Method: initFromEditor
Initializes the location parameters from editor-placed objects.

Parameters: _locationSector

_locationSector - Object -> Location Module

Returns: nil

Author: Sparker 28.07.2018
*/

params ["_thisObject", "_locationSector"];

// Setup location's border from location module properties
private _locSize = _locationSector getVariable ["objectArea", ""];

if (_locSize select 0 == _locSize select 1) then { // if width==height, make it a circle
	private _radius = _locSize select 0;
	private _args = ["circle", _radius];
	CALL_METHOD(_thisObject, "setBorder", _args);
} else { // If width!=height, make border a rectangle
	private _dir = direction _locationSector;
	private _args = ["rectangle", [_locSize select 0, _locSize select 1, _dir] ];
	CALL_METHOD(_thisObject, "setBorder", _args);
};

// Setup marker allowed areas
private _allowedAreas = (allMapMarkers select {(tolower _x) find "allowedarea" == 0}) select {
	CALLM1(_thisObject, "isInBorder", markerPos _x)
};
{
	private _pos = markerPos _x;
	(markerSize _x) params ["_a", "_b"];
	private _dir = markerDir _x;
	
	//#ifdef RELEASE_BUILD
	_x setMarkerAlpha 0;
	deleteMarker _x;
	//#endif
	
	OOP_INFO_1("Adding allowed area: %1", _x);
	CALLM4(_thisObject, "addAllowedArea", _pos, _a, _b, _dir);
} forEach _allowedAreas;

// Setup location's spawn positions
private _radius = GET_VAR(_thisObject, "boundingRadius");
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

// forEach _no;
{
	_object = _x;
	if(CALLM1(_thisObject, "isInBorder", _object)) then
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

		// A cargo container defines a position for cargo boxes
		if (_type == "B_Slingload_01_Cargo_F") then {
			private _args = [T_PL_cargo, [GROUP_TYPE_IDLE], getPosATL _object, direction _object, objNull];
			CALL_METHOD(_thisObject, "addSpawnPos", _args);
			deleteVehicle _object;
		};
		
		// Process buildings
		if (_type isKindOf "House") then {
			T_CALLM1("addObject", _object);
		};

		if(_type == "Flag_BI_F") then {
			//Probably add support for the flag later
			// Why do we even need it
		};

		if(_type == "Sign_Arrow_Large_F") then { //Red arrow
			// Why do we need it
			deleteVehicle _object;
		};

		if(_type == "Sign_Arrow_Large_Blue_F") then { //Blue arrow
			// Why do we need it
			deleteVehicle _object;
		};
	};
} forEach _no;