/*
Class: Camp
Camp has garrisons at a static place and spawns units handle by location variable.
Camp has an arsenal and maybe events and other features ?

Author: Sparker 28.07.2018
*/
#define OOP_DEBUG
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "Camp.hpp"

CLASS("Camp", "Location")

	VARIABLE("pos"); // Position of this Camp
	VARIABLE("arsenalBox"); // arsenalBox of this Camp

	// |                               N E W                             	|
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_pos", [], [[]]]];
		OOP_DEBUG_0("---- start Creating camp");

		// CALL_CLASS_METHOD location->new()
		SET_VAR(_thisObject, "pos", _pos);

		// create a new location for our camp
		private _location = NEW("Location", [_pos]);
		CALLM2(_location, "setBorder", "circle", CAMP_SIZE);
		SET_VAR(_thisObject, "location", _location);

		// create ArsenalBox
		private _arsenalBox = "Box_FIA_Support_F" createVehicle _pos;
		[_arsenalBox] call JN_fnc_arsenal_init;
		SET_VAR(_thisObject, "arsenalBox", _arsenalBox);


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
