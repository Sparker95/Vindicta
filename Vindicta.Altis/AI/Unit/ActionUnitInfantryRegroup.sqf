#include "common.hpp"

/*
Class: ActionUnit.ActionUnitInfantryRegroup
Makes a unit follow his leader
*/

#define pr private

CLASS("ActionUnitInfantryRegroup", "ActionUnit")
	
	// ------------ N E W ------------
	
	/*
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]] ];		
	} ENDMETHOD;
	*/
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];		
		
		pr _hO = T_GETV("hO");

		// Handle AI just spawned state
		pr _AI = T_GETV("AI");
		if (GETV(_AI, "new")) then {

			// If leader of a group, teleport all units to the first waypoint position or to the leader
			pr _hG = group _hO;
			pr _forceAllUnitsToLeader = false;
			if (_hO isEqualTo (leader _hG)) then {
				pr _wps = waypoints _hG;
				if ((count _wps) > 0) then {
					pr _wp0 = _wps#0;
					pr _pos0 = waypointPosition _wp0;
					// No teleporting over 50 meters you cheaters!
					if (! (_pos0 isEqualTo [0, 0, 0]) && _pos0 distance _hO < 50) then {
						{
							_x setPos [_pos0#0 + random 10, _pos0#1 + random 10, 0];
						} forEach (units _hG);
					} else {
						_forceAllUnitsToLeader = true;
					};
				} else {
					_forceAllUnitsToLeader = true;
				};

				if (_forceAllUnitsToLeader) then {
					{
						// Instantly move the unit into its required formation position
						pr _pos = getPos (leader group _hO);
						_x setPos _pos;
					} forEach (units _hG);
				};
			};



			SETV(_AI, "new", false);
		};

		
		// Regroup
		_hO doFollow (leader _hO);
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_COMPLETED);
		
		// Return ACTIVE state
		ACTION_STATE_COMPLETED
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		pr _state = CALLM0(_thisObject, "activateIfInactive");
		
		T_SETV("state", _state);
		_state
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	/*
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;
	*/
	
ENDCLASS;