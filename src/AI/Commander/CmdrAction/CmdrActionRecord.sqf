#define OOP_DEBUG
#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR

#define PROFILER_COUNTERS_ENABLE

// It's really part of GarrisonServer, so we don't want to output text into the CmdrAI log file
//#define OFSTREAM_FILE "CmdrAI.rpt"

#include "..\..\..\common.h"
#include "..\..\..\Templates\Efficiency.hpp"
#include "..\..\..\Mutex\Mutex.hpp"
#include "..\CmdrAction\CmdrActionStates.hpp"
#include "..\..\..\Location\Location.hpp"
#include "..\AICommander.hpp"

/*
Class: AI.CmdrAI.CmdrAction.CmdrActionRecord

Commander action records are serializable objects having data about the current action given to a garrison by commander.
It's used by <GarrisonServer> and <GarrisonDatabaseClient> to send data about friendly garrisons to players of the same side.

Author: Sparker

Parent: none
*/

#define pr private

#define OOP_CLASS_NAME CmdrActionRecord
CLASS("CmdrActionRecord", "")
	
	public STATIC_METHOD(getText)
		params [P_THISCLASS];
		OOP_ERROR_0("getText must be called on final classes!");
		"<Base class>"
	ENDMETHOD;
ENDCLASS;

// - - - - Targeted at position or location - - - -

#define OOP_CLASS_NAME DirectedCmdrActionRecord
CLASS("DirectedCmdrActionRecord", "CmdrActionRecord")

	// Destination position
	VARIABLE_ATTR("pos", [ATTR_SERIALIZABLE]);

	// Destination actual location reference (if exists)
	VARIABLE_ATTR("locRef", [ATTR_SERIALIZABLE]);

	// Destination garrison (if exists)
	VARIABLE_ATTR("dstGarRef", [ATTR_SERIALIZABLE]);

	// Returns position, location position or garrison position, !! ON CLIENT !!
	public client METHOD(getPos)
		params [P_THISOBJECT];

		pr _pos = T_GETV("pos");
		if (!isNil "_pos") exitWith {_pos};

		pr _loc = T_GETV("locRef");
		if (!isNil "_loc") exitWith {CALLM0(_loc, "getPos")};

		pr _gar = T_GETV("dstGarRef");
		if (!isNil "_gar") exitWith {
			pr _garRecord = CALLM1(gGarrisonDBClient, "getGarrisonRecord", _gar);
			if (IS_NULL_OBJECT(_garRecord)) then {
				// This can happen if garrison is destroyed, and associated action didn't terminate yet
				OOP_WARNING_1("Can't resolve position of target garrison: %1", _gar);
				//[_thisObject] call OOP_dumpAllVariables;
				[]
			} else {
				GETV(_garRecord, "pos")
			};
		};

		// Else return [] and print an error
		OOP_WARNING_1("No target in cmdr action record %1", _thisObject);
		//[_thisObject] call OOP_dumpAllVariables;
		[]
	ENDMETHOD;

	public client STATIC_METHOD(getText)
		params [P_THISCLASS];
		OOP_ERROR_0("getText must be called on final classes!");
		"<Directed base class>"
	ENDMETHOD;

ENDCLASS;

// Done
#define OOP_CLASS_NAME MoveCmdrActionRecord
CLASS("MoveCmdrActionRecord", "DirectedCmdrActionRecord")
	public client STATIC_METHOD(getText)
		"MOVE"
	ENDMETHOD;
ENDCLASS;

// Done
#define OOP_CLASS_NAME TakeLocationCmdrActionRecord
CLASS("TakeLocationCmdrActionRecord", "DirectedCmdrActionRecord")
	public client STATIC_METHOD(getText)
		"CAPTURE"
	ENDMETHOD;
ENDCLASS;

// Done
#define OOP_CLASS_NAME AttackCmdrActionRecord
CLASS("AttackCmdrActionRecord", "DirectedCmdrActionRecord")
	public client STATIC_METHOD(getText)
		"ATTACK"
	ENDMETHOD;
ENDCLASS;

// Done
#define OOP_CLASS_NAME ReinforceCmdrActionRecord
CLASS("ReinforceCmdrActionRecord", "DirectedCmdrActionRecord")
	public client STATIC_METHOD(getText)
		"REINFORCE"
	ENDMETHOD;
ENDCLASS;

// Done
#define OOP_CLASS_NAME SupplyConvoyCmdrActionRecord
CLASS("SupplyConvoyCmdrActionRecord", "DirectedCmdrActionRecord")
	public client STATIC_METHOD(getText)
		"SUPPLY"
	ENDMETHOD;
ENDCLASS;

/*
// NYI
#define OOP_CLASS_NAME ReconCmdrActionRecord
CLASS("ReconCmdrActionRecord", "DirectedCmdrActionRecord")

ENDCLASS;
*/

// - - - - Targeted at another garrison - - - -

// - - - - Other - - - -

// todo
#define OOP_CLASS_NAME PatrolCmdrActionRecord
CLASS("PatrolCmdrActionRecord", "CmdrActionRecord")
	public client STATIC_METHOD(getText)
		"Patrol"
	ENDMETHOD;
ENDCLASS;