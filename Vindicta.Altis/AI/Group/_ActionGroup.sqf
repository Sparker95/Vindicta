#include "common.hpp"

/*
Class: ActionGroup
Group action.
*/

#define OOP_CLASS_NAME ActionGroup
CLASS("ActionGroup", "Action")

	VARIABLE("hG");
	VARIABLE("group");
	VARIABLE("behaviour");
	VARIABLE("combatMode");
	VARIABLE("formation");
	VARIABLE("speedMode");
	VARIABLE("replanOnCompositionChange");
	
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		ASSERT_OBJECT_CLASS(_AI, "AIGroup");
		
		private _agent = GETV(_AI, "agent");
		T_SETV("group", _agent);
		private _hG = CALLM0(_agent, "getGroupHandle"); // Group handle
		T_SETV("hG", _hG);
		private _behaviour = CALLSM3("Action", "getParameterValue", _parameters, TAG_BEHAVIOUR, "");
		T_SETV("behaviour", _behaviour);
		private _combatMode = CALLSM3("Action", "getParameterValue", _parameters, TAG_COMBAT_MODE, "");
		T_SETV("combatMode", _combatMode);
		private _formation = CALLSM3("Action", "getParameterValue", _parameters, TAG_FORMATION, "");
		T_SETV("formation", _formation);
		private _speedMode = CALLSM3("Action", "getParameterValue", _parameters, TAG_SPEED_MODE, "");
		T_SETV("speedMode", _speedMode);

		T_SETV("replanOnCompositionChange", true);
	ENDMETHOD;

	/* protected override */ METHOD(terminate)
		params [P_THISOBJECT];

		T_CALLM0("clearUnitGoals");
	ENDMETHOD;

	/*
	Method: failIfEmpty
	Sets this action to failed state if there are no units
	
	Returns: action state
	*/
	METHOD(failIfEmpty)
		params [P_THISOBJECT];

		if (CALLM0(T_GETV("group"), "isEmpty")) then {
			T_SETV("state", ACTION_STATE_FAILED);
			OOP_INFO_0("Action failed: group is empty");
			ACTION_STATE_FAILED
		} else {
			T_GETV("state")
		};
	ENDMETHOD;
	
	/*
	Method: failIfNoInfantry
	Sets this action to failed state if there are no infantry units.
	
	Returns: action state
	*/
	METHOD(failIfNoInfantry)
		params [P_THISOBJECT];
		
		if ((count CALLM0(T_GETV("group"), "getInfantryUnits")) == 0) then {
			T_SETV("state", ACTION_STATE_FAILED);
			OOP_INFO_0("Action failed: no infantry in group");
			ACTION_STATE_FAILED
		} else {
			T_GETV("state")
		};
	ENDMETHOD;

	/*
	Method: handleUnitsRemoved
	Handles what happened when units get removed from its group while the group has some action operational.
	By default it does nothing.
	
	How it gets called: called by <AIGroup> directly.
	
	Parameters: _unit
	
	_unit - <Unit>
	
	Returns: nil
	*/
	/* public virtual */ METHOD(handleUnitsRemoved)
		params [P_THISOBJECT, P_ARRAY("_units")];
		// Replan by default
		if(T_GETV("replanOnCompositionChange")) then {
			T_SETV("state", ACTION_STATE_REPLAN);
		};
	ENDMETHOD;

	/*
	Method: handleUnitsAdded
	Handles what happened when units get added to its group while the group has some action operational.
	By default it does nothing.
	
	How it gets called: called by <AIGroup> directly.
	
	Parameters: _unit
	
	_unit - <Unit>
	
	Returns: nil
	*/
	/* public virtual */ METHOD(handleUnitsAdded)
		params [P_THISOBJECT, P_ARRAY("_units")];
		// Replan by default
		if(T_GETV("replanOnCompositionChange")) then {
			T_SETV("state", ACTION_STATE_REPLAN);
		};
	ENDMETHOD;

	/* protected */ METHOD(applyGroupBehaviour)
		params [P_THISOBJECT, ["_defaultFormation", "WEDGE"], ["_defaultBehaviour", "AWARE"], ["_defaultCombatMode", "YELLOW"], ["_defaultSpeedMode", "NORMAL"]];

		private _hG = T_GETV("hG");
		private _formation = T_GETV("formation");
		_hG setFormation ([_formation, _defaultFormation] select (_formation isEqualTo ""));
		private _behaviour = T_GETV("behaviour");
		_hG setBehaviour ([_behaviour, _defaultBehaviour] select (_behaviour isEqualTo ""));
		private _combatMode = T_GETV("combatMode");
		_hG setCombatMode ([_combatMode, _defaultCombatMode] select (_combatMode isEqualTo ""));
		private _speedMode = T_GETV("speedMode");
		_hG setSpeedMode ([_speedMode, _defaultSpeedMode] select (_speedMode isEqualTo ""));
	ENDMETHOD;

	/* protected */ METHOD(clearWaypoints)
		params [P_THISOBJECT];

		private _hG = T_GETV("hG");
		CALLSM1("Action", "_clearWaypoints", _hG);
	ENDMETHOD;

	/* protected */ METHOD(regroup)
		params [P_THISOBJECT];

		private _hG = T_GETV("hG");
		CALLSM1("Action", "_regroup", _hG);
	ENDMETHOD;

	// // We override this to toggle off the "new" flag in the AIGroup
	// /* protected override */ METHOD(activateIfInactive)
	// 	params [P_THISOBJECT];
	// 	private _state = T_GETV("state");
	// 	if (_state == ACTION_STATE_INACTIVE) then {
	// 		private _AI = T_GETV("AI");
	// 		private _new = GETV(_AI, "new");
	// 		_state = T_CALLM1("activate", _new);
	// 		SETV(_AI, "new", false);
	// 	};
	// 	_state
	// ENDMETHOD;

	/* protected */ METHOD(teleport)
		params [P_THISOBJECT, P_POSITION("_pos"), ["_units", 0, [0, []]]];

		if(_units isEqualTo 0) then {
			_units = CALLM0(T_GETV("group"), "getUnits");
		};
		CALLSM2("Action", "_teleport", _units, _pos);
	ENDMETHOD;


	/* protected */ METHOD(clearUnitGoals)
		params [P_THISOBJECT, ["_goals", [""], ["", []]], ["_units", 0, [0, []]]];

		if(_units isEqualTo 0) then {
			_units = CALLM0(T_GETV("group"), "getInfantryUnits");
		};

		private _AI = T_GETV("AI");
		{// foreach _units
			private _unitAI = CALLM0(_x, "getAI");
			{
				CALLM2(_unitAI, "deleteExternalGoal", _x, _AI);
			} forEach _goals;
		} forEach _units;
	ENDMETHOD;

	METHOD(updateVehicleAssignments)
		params [P_THISOBJECT];

		private _group = T_GETV("group");
		private _inf = CALLM0(_group, "getInfantryUnits");

		// Order crew in vehicles, and inf out
		private _crew = _inf select { CALLM0(CALLM0(_x, "getAI"), "getAssignedVehicleRole") != "" };
		private _nonCrew = _inf - _crew;

		private _hCrew = _crew apply { CALLM0(_x, "getObjectHandle") };
		_hCrew allowGetIn true;
		_hCrew orderGetIn true;

		private _hNonCrew = _nonCrew apply { CALLM0(_x, "getObjectHandle") };

		_hNonCrew allowGetIn false;
		_hNonCrew orderGetIn false;

		private _hVeh = CALLM0(_group, "getVehicleUnits") apply { CALLM0(_x, "getObjectHandle") };

		// TODO: do a better job assigning them if there is more than one vehicle...
		if(count _hVeh > 0) then {
			{
				_x assignAsCargo _hVeh#0;
			} forEach _hNonCrew;
			// Let them get in the vehicle if they want
			_hNonCrew allowGetIn true;
		};
	ENDMETHOD;
	

ENDCLASS;