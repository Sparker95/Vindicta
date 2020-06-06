#include "common.hpp"

/*
Class: ActionGarrison
Garrison action.
*/

#define pr private

#define OOP_CLASS_NAME ActionGarrison
CLASS("ActionGarrison", "Action")

	VARIABLE("gar");
	VARIABLE("reactivateOnSpawn");
	VARIABLE("replanOnCompositionChange");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI") ];

		ASSERT_OBJECT_CLASS(_AI, "AIGarrison");

		pr _gar = GETV(_AI, "agent");

		T_SETV("gar", _gar);
		T_SETV("reactivateOnSpawn", true);
		T_SETV("replanOnCompositionChange", true);
	ENDMETHOD;

	public override METHOD(terminate)
		params [P_THISOBJECT];

		// If we aren't spawned there shouldn't be any group goals
		pr _gar = T_GETV("gar");
		if (!CALLM0(_gar, "isSpawned")) exitWith {};

		T_CALLM0("clearGroupGoals");
	ENDMETHOD;

	protected METHOD(clearGroupGoals)
		params [P_THISOBJECT, ["_goals", [""], [[]]], ["_groups", 0, [0, []]]];

		if(_groups isEqualTo 0) then {
			_groups = CALLM0(T_GETV("gar"), "getGroups");
		};

		pr _AI = T_GETV("AI");

		{// foreach _groups
			pr _groupAI = CALLM0(_x, "getAI");
			{
				CALLM2(_groupAI, "deleteExternalGoal", _x, _AI);
			} forEach _goals;
		} forEach _groups;
	ENDMETHOD;

	/*
	Method: spawn
	Gets called from Garrison.spawn. It must perform non-standard spawning of garrison while this action is active.
	
	Returns: Bool. Return true if you have handled spawning here. If you return false, Garrison.spawn will perform spawning on its own.
	*/
	public virtual METHOD(spawn)
		params [P_THISOBJECT];
		false
	ENDMETHOD;

	/*
	Method: onGarrisonSpawned
	Gets called after the garrison has been spawned.
	
	Returns: Nothing.
	*/
	public virtual METHOD(onGarrisonSpawned)
		params [P_THISOBJECT];

		// Reactivate by default
		if(T_GETV("reactivateOnSpawn")) then {
			T_SETV("state", ACTION_STATE_INACTIVE);
		};
	ENDMETHOD;
	
	/*
	Method: onGarrisonDespawned
	Gets called after the garrison has been despawned.
	
	Returns: Nothing.
	*/
	public virtual METHOD(onGarrisonDespawned)
		params [P_THISOBJECT];

		// Reactivate by default
		if(T_GETV("reactivateOnSpawn")) then {
			T_SETV("state", ACTION_STATE_INACTIVE);
		};
	ENDMETHOD;

	
	// Handle units/groups added/removed
	public override METHOD(handleGroupsAdded)
		params [P_THISOBJECT, P_ARRAY("_groups")];

		// Replan by default
		if(T_GETV("replanOnCompositionChange")) then {
			T_SETV("state", ACTION_STATE_REPLAN);
		};
	ENDMETHOD;

	public override METHOD(handleGroupsRemoved)
		params [P_THISOBJECT, P_ARRAY("_groups")];

		// Replan by default
		if(T_GETV("replanOnCompositionChange")) then {
			T_SETV("state", ACTION_STATE_REPLAN);
		};
	ENDMETHOD;
	
	public override METHOD(handleUnitsRemoved)
		params [P_THISOBJECT, P_ARRAY("_units")];

		// Replan by default
		if(T_GETV("replanOnCompositionChange")) then {
			T_SETV("state", ACTION_STATE_REPLAN);
		};
	ENDMETHOD;
	
	public override METHOD(handleUnitsAdded)
		params [P_THISOBJECT, P_ARRAY("_units")];

		// Replan by default
		if(T_GETV("replanOnCompositionChange")) then {
			T_SETV("state", ACTION_STATE_REPLAN);
		};
	ENDMETHOD;

ENDCLASS;