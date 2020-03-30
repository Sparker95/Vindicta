#include "common.hpp"

/*
Class: ActionGroup
Group action.
*/

#define THIS_ACTION_NAME "MyAction"

CLASS("ActionGroup", "Action")

	VARIABLE("hG");
	VARIABLE("group");
	VARIABLE("behaviour");
	VARIABLE("combatMode");
	VARIABLE("formation");
	VARIABLE("speedMode");
	
	METHOD("new") {
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
	} ENDMETHOD;
	
	/*
	Method: failIfEmpty
	Sets this action to failed state if there are no units
	
	Returns: action state
	*/
	METHOD("failIfEmpty") {
		params [P_THISOBJECT];
		if (CALLM0(T_GETV("group"), "isEmpty")) then {
			T_SETV("state", ACTION_STATE_FAILED);
			OOP_INFO_0("Action failed: group is empty");
			ACTION_STATE_FAILED
		} else {
			T_GETV("state")
		};
	} ENDMETHOD;
	
	/*
	Method: failIfNoInfantry
	Sets this action to failed state if there are no infantry units.
	
	Returns: action state
	*/
	METHOD("failIfNoInfantry") {
		params [P_THISOBJECT];
		
		if ((count CALLM0(T_GETV("group"), "getInfantryUnits")) == 0) then {
			T_SETV("state", ACTION_STATE_FAILED);
			OOP_INFO_0("Action failed: no infantry in group");
			ACTION_STATE_FAILED
		} else {
			T_GETV("state")
		};
	} ENDMETHOD;

	/*
	Method: handleUnitsRemoved
	Handles what happened when units get removed from its group while the group has some action operational.
	By default it does nothing.
	
	How it gets called: called by <AIGroup> directly.
	
	Parameters: _unit
	
	_unit - <Unit>
	
	Returns: nil
	*/

	METHOD("handleUnitsRemoved") {
		params [P_THISOBJECT, P_ARRAY("_units")];
		
	} ENDMETHOD;

	/*
	Method: handleUnitsAdded
	Handles what happened when units get added to its group while the group has some action operational.
	By default it does nothing.
	
	How it gets called: called by <AIGroup> directly.
	
	Parameters: _unit
	
	_unit - <Unit>
	
	Returns: nil
	*/

	METHOD("handleUnitsAdded") {
		params [P_THISOBJECT, P_ARRAY("_units")];
		
	} ENDMETHOD;

	METHOD("applyGroupBehaviour") {
		params [P_THISOBJECT, ["_defaultFormation", "WEDGE"], ["_defaultBehaviour", "AWARE"], ["_defaultCombatMode", "YELLOW"], ["_defaultSpeedMode", "NORMAL"]];
		private _hG = T_GETV("hG");
		private _formation = T_GETV("formation");
		_hG setFormation ([_formation, _defaultFormation] select (_formation isEqualTo ""));
		private _behaviour = T_GETV("behaviour");
		_hG setBehaviour ([_behaviour, _defaultBehaviour] select (_behaviour isEqualTo ""));
		private _combatMode = T_GETV("combatMode");
		_hG setCombatMode ([_combatMode, _defaultCombatMode] select (_combatMode isEqualTo ""));
		private _speedMode = T_GETV("speedMode");
		_hG setSpeedMode ([_speedMode, _defaultCombatMode] select (_speedMode isEqualTo ""));
	} ENDMETHOD;

	METHOD("clearWaypoints") {
		params [P_THISOBJECT];
		private _hG = T_GETV("hG");
		CALLSM1("Action", "_clearWaypoints", _hG);
	} ENDMETHOD;

	METHOD("regroup") {
		params [P_THISOBJECT];
		private _hG = T_GETV("hG");
		CALLSM1("Action", "_regroup", _hG);
	} ENDMETHOD;

ENDCLASS;