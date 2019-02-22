/*
Class: Camp
Camp has garrisons at a static place and spawns units handle by location variable.
Camp has an arsenal and maybe events and other features ?

Author: Sparker 28.07.2018
*/
#include "common.hpp"
#include "camp.hpp"

CLASS("Camp", "Location")

	VARIABLE("arsenalBox"); // arsenalBox of this Camp

	/*
	Method: new
	Create new obj
	
	return nil
	*/
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_pos", [], [[]]] ];
		OOP_DEBUG_0("---- start Creating camp");
		
		// Set some infos
		SET_VAR_PUBLIC(_thisObject, "pos", _pos);
		SET_VAR(_thisObject, "type", LOCATION_TYPE_CAMP);

		// Create/Set ArsenalBox
		private _arsenalBox = "Box_FIA_Support_F" createVehicle _pos;
		[_arsenalBox] call JN_fnc_arsenal_init;
		SET_VAR(_thisObject, "arsenalBox", _arsenalBox);

		// Create Marker
		private _markerName = createMarker ["CustomCamp", _pos];
		_markerName setMarkerShape "RECTANGLE";
		_markerName setMarkerSize [100, 100];		
		
		{
			diag_log format ["marker: %1", _x];
		} forEach allMapMarkers;

		OOP_DEBUG_0("---- end Creating camp");
	} ENDMETHOD;

	/*
	Method: delete
	Delete current object

	return nil
	*/
	METHOD("delete") {
		params [["_thisObject", "", [""]]];

		SET_VAR(_thisObject, "arsenalBox", nil);
	} ENDMETHOD;

ENDCLASS;
