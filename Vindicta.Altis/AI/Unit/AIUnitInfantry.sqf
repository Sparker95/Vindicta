#include "common.hpp"

/*
Class: AI.AIUnitInfantry

AI for military bots.

Author: Sparker 12.11.2018
*/

#define pr private

#define MRK_GOAL	"_goal"
#define MRK_ARROW	"_arrow"

#define OOP_CLASS_NAME AIUnitInfantry
CLASS("AIUnitInfantry", "AIUnitHuman")

	// Sentry position
	VARIABLE("sentryPos");

	#ifdef DEBUG_GOAL_MARKERS
	VARIABLE("markersEnabled");
	#endif

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_agent")];

		// Initialize sensors
		pr _sensorSalute = NEW("SensorUnitSalute", [_thisObject]);
		T_CALLM("addSensor", [_sensorSalute]);

		pr _sensorCivNear = NEW("SensorUnitCivNear", [_thisObject]);
		T_CALLM("addSensor", [_sensorCivNear]);

	ENDMETHOD;

	/* override */ METHOD(start)
		params [P_THISOBJECT];
		T_CALLM1("addToProcessCategory", "AIInfantry");
	ENDMETHOD;

	/*
	Method: setSentryPos
	Sets the sentry position, which may be later retrieved by actions.
	
	Parameters: _pos
	
	_pos - position
	
	Returns: nil
	*/
	
	METHOD(setSentryPos)
		params [P_THISOBJECT, P_POSITION("_pos")];
		T_SETV("sentryPos", _pos);
	ENDMETHOD;
	
	/*
	Method: getSentryPos
	Getter for setSentryPos
	
	Returns: position or [] if no position was assigned
	*/
	
	METHOD(getSentryPos)
		params [P_THISOBJECT];
		pr _pos = T_GETV("sentryPos");
		if (isNil "_pos") then {
			[]
		} else {
			_pos
		};
	ENDMETHOD;

	//                        G E T   P O S S I B L E   G O A L S
	METHOD(getPossibleGoals)
		//["GoalUnitSalute","GoalUnitScareAway"]
		["GoalUnitScareAway"]
	ENDMETHOD;

	//                      G E T   P O S S I B L E   A C T I O N S
	METHOD(getPossibleActions)
		//["ActionUnitSalute","ActionUnitScareAway"] // This is only for A* planner, which is not used for this AI type
		[]
	ENDMETHOD;

	/* override */ METHOD(setUrgentPriorityOnAddGoal)
		true
	ENDMETHOD;

ENDCLASS;