#include "common.hpp"

/*
Class: ActionGroup.ActionGroupGetInBuilding
All members of this group will try to get into the specified building.

Parameter tags:
"building" - handle of the building object
*/

#define pr private

#define OOP_CLASS_NAME ActionGroupGetInBuilding
CLASS("ActionGroupGetInBuilding", "ActionGroup")

	VARIABLE("hBuilding");
	VARIABLE("timeComplete");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		pr _hBuilding = CALLSM2("Action", "getParameterValue", _parameters, TAG_TARGET);
		if (isNil "_hBuilding") exitWith {
			OOP_ERROR_0("Building handle was not provided");
			T_SETV("hBuilding", objNull);
		};
		T_SETV("hBuilding", _hBuilding);

		T_SETV("timeComplete", 0);

	ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];
		
		OOP_INFO_0("ACTIVATE");

		pr _hBuilding = T_GETV("hBuilding");
		pr _AI = T_GETV("AI");
		pr _group = T_GETV("group");
		pr _leaderUnit = CALLM0(_group, "getLeader");
		if (IS_NULL_OBJECT(_leaderUnit)) exitWith {
			T_SETV("state", ACTION_STATE_FAILED);
			OOP_INFO_0("Action failed: no leader");
			ACTION_STATE_FAILED
		};

		// Estimate when they will get into the building
		pr _posStart = ASLTOAGL (getPosASL CALLM0(_leaderUnit, "getObjectHandle"));
		pr _bpos = ASLTOAGL (getPosASL _hBuilding);
		pr _dist = (abs ((_bpos select 0) - (_posStart select 0)) ) + (abs ((_bpos select 1) - (_posStart select 1))) + (abs ((_bpos select 2) - (_posStart select 2))); // Manhattan distance
		pr _ETA = GAME_TIME + (_dist + 60);
		T_SETV("timeComplete", GAME_TIME + _ETA);

		// Find all available building positions
		// Building is guaranteed to be alive and not null by now, it's checked in process
		pr _countPos = count (_hBuilding buildingPos -1);
		pr _buildingPosIDs = [];
		_buildingPosIDs resize _countPos; // Array with available IDs of positions
		for "_i" from 0 to (_countPos - 1) do {
			_buildingPosIDs set [_i, _i];
		};

		// Add goals to all units
		pr _units = +CALLM0(_group, "getInfantryUnits");
		_units = [_leaderUnit] + (_units - [_leaderUnit]); // Move the leader to the front of the array, so that he is more likely to get the move goal into the house
		{ // foreach units
			pr _unit = _x;
			pr _unitAI = CALLM0(_unit, "getAI");

			// Remove previous goals
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitInfantryMoveBuilding", "");
			CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitInfantryRegroup", "");

			if (count _buildingPosIDs > 0) then {
				pr _posID = selectRandom _buildingPosIDs;
				_buildingPosIDs deleteAt (_buildingPosIDs find _posID);
				pr _parameters = [
					[TAG_TARGET, _hBuilding],
					[TAG_BUILDING_POS_ID, _posID],
					[TAG_INSTANT, _instant]
				];
				CALLM4(_unitAI, "addExternalGoal", "GoalUnitInfantryMoveBuilding", 0, _parameters, _AI);
			} else {
				// Move to a position in or near the building, hopefully we end up somewhere sensible
				pr _buildingPos = position _hBuilding;
				pr _pos = [_buildingPos, 0, 25, 0, 0, 2, 0, [], [_buildingPos, _buildingPos]] call BIS_fnc_findSafePos;
				pr _parameters = [
					[TAG_POS, _pos],
					[TAG_INSTANT, _instant]
				];
				CALLM4(_unitAI, "addExternalGoal", "GoalUnitInfantryMove", 0, _parameters, _AI);
			};
		} forEach _units;

		// Set group combat mode
		pr _hG = T_GETV("hG");
		_hG setCombatMode "GREEN"; // Hold fire, disengage. We don't want them to chase enemies right now, we want them to get into houses.

		// Return ACTIVE state
		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
		
	ENDMETHOD;
	
	// Logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];
		
		if(T_CALLM0("failIfNoInfantry") == ACTION_STATE_FAILED) exitWith {
			ACTION_STATE_FAILED
		};

		// Fail if building is destroyed or null
		pr _hBuilding = T_GETV("hBuilding");
		if (!(alive _hBuilding)) exitWith { // Alive will return false on objNull too
			T_SETV("state", ACTION_STATE_FAILED);
			OOP_INFO_0("Action failed: building is null or destroyed");
			ACTION_STATE_FAILED
		};
		
		pr _state = T_CALLM0("activateIfInactive");

		pr _group = T_GETV("group");
		pr _groupUnits = CALLM0(_group, "getInfantryUnits");
		if (_state == ACTION_STATE_ACTIVE) then {
			// Complete if everyone is in the building (very unlikely with arma AI, also not everyone might have got the goal to get into the building)
			if (CALLSM3("AI_GOAP", "allAgentsCompletedExternalGoal", _groupUnits, "GoalUnitInfantryMoveBuilding", "")) then {
				_state = ACTION_STATE_COMPLETED;
			};

			// For now we just use timeout which should be enough for most cases
			if (GAME_TIME > T_GETV("timeComplete")) then {
				_state = ACTION_STATE_COMPLETED;
			};
		};


		T_SETV("state", _state);
		_state
	ENDMETHOD;
	
	METHOD(handleUnitsRemoved)
		params [P_THISOBJECT, P_ARRAY("_units")];
		// Let them go, we don't care
	ENDMETHOD;

	METHOD(handleUnitsAdded)
		params [P_THISOBJECT];
		// We must replan everything
		T_SETV("state", ACTION_STATE_REPLAN);
	ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD(terminate)
		params [P_THISOBJECT];
		
		// Delete external goals
		pr _group = T_GETV("group");
		pr _units = CALLM0(_group, "getUnits");
		pr _AI = T_GETV("AI");
		{ // foreach units
			pr _unit = _x;
			pr _unitAI = CALLM0(_unit, "getAI");

			if (_unitAI != "") then { // Sanity check
				// Remove goals from this AI
				CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitInfantryRegroup", _AI);
				CALLM2(_unitAI, "deleteExternalGoal", "GoalUnitInfantryMoveBuilding", _AI);
			};
		} forEach _units;
		
	ENDMETHOD;

ENDCLASS;
