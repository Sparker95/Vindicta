#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR

#include "..\common.hpp"

/*
Class: AI.CmdrAI.CmdrAction.CmdrActionRecord

Commander action records are serializable objects having data about the current action given to a garrison by commander.
It's used by <GarrisonServer> and <GarrisonDatabaseClient> to send data about friendly garrisons to players of the same side.

Author: Sparker

Parent: none
*/

#define pr private

CLASS("CmdrActionRecord", "")
	
	// Ref to the actual garrison
	VARIABLE_ATTR("garRef", [ATTR_SERIALIZABLE]);
	
	STATIC_METHOD("getText") {
		params [P_THISCLASS];
		OOP_ERROR_0("getText must be called on final classes!");
		"<Base class>"
	} ENDMETHOD;
ENDCLASS;

// - - - - Targeted at position or location - - - -

CLASS("DirectedCmdrActionRecord", "")

	// Destination position
	VARIABLE_ATTR("pos", [ATTR_SERIALIZABLE]);

	// Destination actual location reference (if exists)
	VARIABLE_ATTR("locRef", [ATTR_SERIALIZABLE]);

	// Destination garrison (if exists)
	VARIABLE_ATTR("garRef", [ATTR_SERIALIZABLE]);

	// Returns position, location position or garrison position, !! ON CLIENT !!
	METHOD("getPos") {
		params [P_THISOBJECT];

		pr _pos = T_GETV("pos");
		if (!isNil "_pos") exitWith {_pos};

		pr _loc = T_GETV("locRef");
		if (!isNil "_loc") exitWith {CALLM0(_loc, "getPos")};

		pr _gar = T_GETV("garRef");
		pr _garRecord = CALLM1(gGarrisonDBClient, "getGarrisonRecord", _gar);
		if (_garRecord == "") exitWith {[]};
		GETV(_garRecord, "pos")
	} ENDMETHOD;

	STATIC_METHOD("getText") {
		params [P_THISCLASS];
		OOP_ERROR_0("getText must be called on final classes!");
		"<Directed base class>"
	} ENDMETHOD;

ENDCLASS;

// Done
CLASS("MoveCmdrActionRecord", "DirectedCmdrActionRecord")
	STATIC_METHOD("getText") {
		"Move"
	} ENDMETHOD;
ENDCLASS;

// Done
CLASS("TakeLocationCmdrActionRecord", "DirectedCmdrActionRecord")
	STATIC_METHOD("getText") {
		"Capture"
	} ENDMETHOD;
ENDCLASS;

// Done
CLASS("QRFCmdrActionRecord", "DirectedCmdrActionRecord")
	STATIC_METHOD("getText") {
		"Attack"
	} ENDMETHOD;
ENDCLASS;

// Done
CLASS("ReinforceCmdrActionRecord", "DirectedCmdrActionRecord")
	STATIC_METHOD("getText") {
		"Reinforce"
	} ENDMETHOD;
ENDCLASS;

/*
// NYI
CLASS("ReconCmdrActionRecord", "DirectedCmdrActionRecord")

ENDCLASS;
*/

// - - - - Targeted at another garrison - - - -

// - - - - Other - - - -

// todo
CLASS("PatrolCmdrActionRecord", "CmdrActionRecord")

	STATIC_METHOD("getText") {
		"Patrol"
	} ENDMETHOD;
ENDCLASS;