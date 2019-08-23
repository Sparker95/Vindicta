#include "common.hpp"



#define pr private

/*
Class: GarrisonRecord
Client-side representation of a garrison.

Author: Sparker 23 August 2019
*/

CLASS("GarrisonRecord", "")

	METHOD("new") {
		params [P_THISOBJECT, P_STRING("_garRef")];

		T_SETV("garRef", _garRef);
	} ENDMETHOD;

	// Ref to the actual garrison, which exists only on the server
	VARIABLE("garRef");

	// Ref to the map marker object
	VARIABLE("mapMarker");

	// Generic properties
	VARIABLE("pos");
	VARIABLE("side");
	VARIABLE("composition");

	// Current goal
	VARIABLE("goal");
	VARIABLE("goalPos");
	VARIABLE("goalMapMarker");

	// What else did I forget?

ENDCLASS;

/*
Class: GarrisonDatabaseClient
Singleton client-only class.
Stores data about garrisons on client side.
Receives data from GarrisonServer.

Author: Sparker 23 August 2019
*/

CLASS("GarrisonDatabaseClient", "")

	// Hashmap that maps actual garrison references to garrison records
	VARIABLE("hm");

	METHOD("new") {
		params [P_THISOBJECT];

		pr _ns = [false] call CBA_fnc_createNamespace;
		T_SETV("ns", _ns);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		pr _ns = T_GETV("ns");
		_ns call CBA_fnc_deleteNamespace;
	} ENDMETHOD;

	METHOD("addGarrisonRecord") {
		params [P_THISOBJECT, P_STRING("_garRef")];

		pr _record = NEW("GarrisonRecord", [_garRef]);
	} ENDMETHOD;

	METHOD("deleteGarrisonRecord") {

	} ENDMETHOD;

ENDCLASS;