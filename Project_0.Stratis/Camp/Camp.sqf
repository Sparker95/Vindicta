/*
Class: Camp
Location has garrisons at a static place and spawns units.

Author: Sparker 28.07.2018
*/
#define OOP_DEBUG
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "Camp.hpp"

#define pr private

CLASS("Camp", "")

	VARIABLE("pos"); // Position of this location
	VARIABLE("location"); // Position of this location
	VARIABLE("arsenalBox"); // Position of this location

	// |                               N E W                             	|
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_pos", [], [[]]]];
		OOP_DEBUG_0("---- start Creating camp");

		private _allLocations = GETSV("Location", "all");

		private _isPosAllowed = true;

		{
			pr _locPos = GETV(_x, "pos");
			private _dist = _pos distance _locPos;
			OOP_DEBUG_1("_dist:  %1", _dist);
			// if (_dist < 1000) then {  OOP_DEBUG_0("breakOut"); breakOut ""; };
			if (_dist < 1000) exitWith {_isPosAllowed = false};
			diag_log "DEBUG: should be breakout";
		} forEach _allLocations;

		if (_isPosAllowed isEqualTo false) exitWith {OOP_DEBUG_0("---- end Creating camp NO POSITION AVAILABLE"); _isPosAllowed = false};

		OOP_DEBUG_1("_isPosAllowed: %1", _isPosAllowed);

		SET_VAR_PUBLIC(_thisObject, "pos", _pos);

		// create a new location for our camp
		private _location = NEW("Location", [_pos]);
		CALLM2(_location, "setBorder", "circle", CAMP_SIZE);
		SET_VAR(_thisObject, "location", _location);

		// create ArsenalBox
		private _arsenalBox = "Box_FIA_Support_F" createVehicle _pos;
		[_arsenalBox] call JN_fnc_arsenal_init;
		SET_VAR(_thisObject, "arsenalBox", _arsenalBox);

		// Check around locations
		private _all = GETSV("Location", "all");



		OOP_DEBUG_0("---- end Creating camp");
	} ENDMETHOD;

	/*
	Method: delete
	Delete current object

	return nil
	*/
	METHOD("delete") {
		params [["_thisObject", "", [""]]];

		SET_VAR(_thisObject, "pos", nil);
		SET_VAR(_thisObject, "location", nil);
		SET_VAR(_thisObject, "arsenalBox", nil);
		nil

	} ENDMETHOD;

	/*
	Method: (static)getAll
	Returns an array of all Camps.

	Returns: Array of location objects
	*/
	STATIC_METHOD("getAll") {
		private _all = GET_STATIC_VAR("Camp", "all");
		private _return = +_all;
		_return
	} ENDMETHOD;

	/*
	Method: getPos
	Returns position of this Camp
	Returns: Array, position
	*/
	METHOD("getPos") {
		params [ ["_thisObject", "", [""]] ];
		GETV(_thisObject, "pos")
	} ENDMETHOD;

ENDCLASS;
