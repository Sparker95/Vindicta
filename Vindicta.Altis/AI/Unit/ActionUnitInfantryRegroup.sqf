#include "common.hpp"

/*
Class: ActionUnit.ActionUnitInfantryRegroup
Makes a unit follow his leader
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitInfantryRegroup
CLASS("ActionUnitInfantryRegroup", "ActionUnit")
	
	// ------------ N E W ------------
	
	/*
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
	ENDMETHOD;
	*/
	
	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];
		
		pr _hO = T_GETV("hO");

		// Handle AI just spawned state
		if (_instant) then {
			// If leader of a group, teleport all units to the first waypoint position or to the leader
			pr _hG = group _hO;
			pr _forceAllUnitsToLeader = false;
			if (_hO isEqualTo leader _hG) then {
				pr _wps = waypoints _hG;
				if (count _wps > 0) then {
					pr _wp0 = currentWaypoint _hG; //  _wps#0;
					pr _pos0 = waypointPosition (_wps#_wp0);

					if (!isNil "_pos0" && {!(_pos0 isEqualTo [0, 0, 0])}) then {
						{
							_x setPos [_pos0#0 + random 10, _pos0#1 + random 10, 0];
						} forEach units _hG;
					} else {
						_forceAllUnitsToLeader = true;
					};
				} else {
					_forceAllUnitsToLeader = true;
				};

				if (_forceAllUnitsToLeader) then {
					{
						// Instantly move the unit into its required formation position
						pr _pos = getPos leader group _hO;
						_x setPos _pos;
					} forEach units _hG;
				};
			};
		};

		// Regroup
		_hO doFollow leader _hO;
		
		// Set state
		T_SETV("state", ACTION_STATE_COMPLETED);
		
		// Return ACTIVE state
		ACTION_STATE_COMPLETED
	ENDMETHOD;
	
	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];
		
		pr _state = T_CALLM0("activateIfInactive");
		
		T_SETV("state", _state);
		_state
	ENDMETHOD;
	
	// logic to run when the action is satisfied
	/*
	METHOD(terminate)
		params [P_THISOBJECT];
	ENDMETHOD;
	*/
	
ENDCLASS;