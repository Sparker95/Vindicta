/*
Checks the game world for predefined game objects and markers and creates locations from them.

Author: Sparker 28.07.2018
*/

#include "..\OOP_Light\OOP_Light.h"

private _radius = 0;
private _loc = objNull;
{
	private _mrk = _x;
	private _mrkPos = getMarkerPos _mrk;
	private _type = "";
	
	// Check marker name for location type
	call {
		if(_x find "base" == 0) exitWith {
			_type = "base";
		};
		if(_x find "outpost" == 0) exitWith {
			_type = "outpost";
		};
	};
	
	// Did we find a location marker?
	if(!(_type isEqualTo "")) then {
		private _side = WEST;
		private _template = tNATO;
		
		// Check marker side in its name
		if(_x find "_ind" > 0) then	{
			_side = INDEPENDENT;
			_template = tIND;
		} else	{
			if(_x find "_east" > 0) then {
				_side = EAST;
				_template = tCSAT;
			};
		};
		
		// Create a new location
		private _args = [_mrkPos];
		private _loc = NEW("Location", _args);
		
		// Initialize the new location
		CALL_METHOD(_loc, "initFromEditor", [_mrk]);
		
		//Add the main garrison to this location
		/*
		private _gar = [_loc] call loc_fnc_getMainGarrison;
		[_gar, _side] call gar_fnc_setSide;
		[_loc, _template] call loc_fnc_setMainTemplate;
		*/
	};
} forEach allMapMarkers;