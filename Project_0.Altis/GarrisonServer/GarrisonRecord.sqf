#include "common.hpp"
/*
Class: GarrisonRecord
Client-side representation of a garrison.

Author: Sparker 23 August 2019
*/

#define pr private

CLASS("GarrisonRecord", "")

	// Ref to the actual garrison, which exists only on the server
	VARIABLE("garRef");

	// Generic properties
	VARIABLE("pos");
	VARIABLE("side");
	VARIABLE("composition");

	// Current goal
	VARIABLE("goal");
	VARIABLE("goalPos");
	VARIABLE("goalMapMarker");

	// Ref to the map marker object
	VARIABLE("mapMarker");

	// What else did I forget?

	/*
	METHOD("new") {
		params [P_THISOBJECT];

	} ENDMETHOD;
	*/

	METHOD("delete") {

	} ENDMETHOD;

	// Fills data fields from a garrison object
	METHOD("initFromGarrison") {
		params [P_THISOBJECT, P_OOP_OBJECT("_gar")];

		// Accessing data without proper interfaces now
		// This is probably not so bad??
		// todo need to rethink it probably...
		pr _AI = GETV(_gar, "AI");
		T_SETV("pos", CALLM0(_AI, "getPos"));
		T_SETV("side", GETV(_gar, "side"));
		T_SETV("composition", GETV(_gar, "composition"));
	} ENDMETHOD;

	METHOD("_updateMapMarker") {
		params [P_THISOBJECT];

		CALLM1(_mapMarker, "setPos", T_GETV("pos"));
		CALLM1(_mapMarker, "setSide", T_GETV("side"));

	} ENDMETHOD;

	// Initializes this object on the client side 
	METHOD("clientInit") {
		params [P_THISOBJECT];

		// Create the map marker
		pr _mapMarker = NEW("MapMarkerGarrison", []);
		T_SETV("mapMarker", _mapMarker);
		T_CALLM0("_updateMapMarker");

	} ENDMETHOD;

	// Updates data in this object from another garrison record
	#define __TCOPYVAR(objNameStr, varNameStr) T_SETV(objNameStr, GETV(objNameStr, varNameStr)) // I love the preprocessor :3
	METHOD("clientUpdate") {
		params [P_THISOBJECT, P_OOP_OBJECT("_garRecord")];

		__TCOPYVAR(_garRecord, "pos");
		__TCOPYVAR(_garRecord, "side");
		__TCOPYVAR(_garRecord, "composition");

		// Update map marker properties
		T_CALLM0("_updateMapMarker");
	} ENDMETHOD;

	// Must be called before deleting this on client
	METHOD("clientDestroy") {
		params [P_THISOBJECT];

		// Delete the map marker
		pr _mapMarker = T_GETV("mapMarker");
		DELETE(_mapMarker);

		// Notify the UI?
	} ENDMETHOD;

ENDCLASS;