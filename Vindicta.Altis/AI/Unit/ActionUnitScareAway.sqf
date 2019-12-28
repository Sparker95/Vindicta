#include "common.hpp"

/*
Scare away action class
Author: Jeroen 11.12.2018
*/

#define pr private

CLASS("ActionUnitScareAway", "Action")

	VARIABLE("target");
	VARIABLE("activationTime");
	VARIABLE("objectHandle");
	VARIABLE("step");
	VARIABLE("warningShotTarget");
	// ------------ N E W ------------
	// _target - whom to scare off
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_target", objNull, [objNull]] ];

		SETV(_thisObject,"step",0);
		
		pr _laserT = createVehicle ["LaserTargetW", [0,0,0], [], 0, "NONE"];
		_laserT attachto [_target, [0, 0, 3]];
		SETV(_thisObject,"warningShotTarget",_laserT);
		
		//might want to move this to ActionUnit base class
		SETV(_thisObject, "target", _target);
		pr _a = GETV(_AI, "agent"); // cache the object handle
		pr _oh = CALLM(_a, "getObjectHandle", []);
		SETV(_thisObject, "objectHandle", _oh);

	} ENDMETHOD;
	
	METHOD("delete") {
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		
		OOP_DEBUG_0("active: Unit is pissed off!");
		
		//might what to move this to Action base class
		SETV(_thisObject, "activationTime", time);
		
		pr _oh = GETV(_thisObject, "objectHandle");
		pr _AI = GETV(_thisObject, "AI");
		pr _target = GETV(_thisObject, "target");
		
		group _oh setBehaviour "AWARE";
		
		//get world fact because we need to know how pissed the unit is
		pr _wf = WF_NEW();
		[_wf, WF_TYPE_UNIT_ANNOYED_BY] call wf_fnc_setType;
		pr _wfFound = CALLM(_AI, "findWorldFact", [_wf]);
		
		if(isnil "_wfFound")exitWith{ACTION_STATE_ACTIVE};
		
		//aim at target
		_oh doTarget _target;
		group _oh setSpeedMode "LIMITED";
		//might what to move this to Action base class
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);	
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		diag_log "scare away process was called!";
		
		CALLM0(_thisObject, "activateIfInactive");
		
		// If action is not active now, do nothing
		pr _state = GETV(_thisObject, "state");
		if (_state != ACTION_STATE_ACTIVE) exitWith {_state};
		
		// Action is active
		pr _oh = GETV(_thisObject, "objectHandle");
		pr _AI = GETV(_thisObject, "AI");
		pr _target = GETV(_thisObject, "target");
		
		//get world fact because we need to know how pissed the unit is
		pr _wf = WF_NEW();
		[_wf, WF_TYPE_UNIT_ANNOYED_BY] call wf_fnc_setType;
		_wf = CALLM(_AI, "findWorldFact", [_wf]);
		
		if(isnil "_wf" || {_oh distance _target > 10})exitWith{
			CALLM(_thisObject, "terminate", []);
			SETV(_thisObject, "state", ACTION_STATE_COMPLETED);
			ACTION_STATE_COMPLETED
		};
		
		pr _value = WF_GET_RELEVANCE(_wf);
		
		if(_value > 0.5)then{
			if(true)then{
				pr _step = GETV(_thisObject,"step");
				hint format["step %1",_step];
				pr _laserT = GETV(_thisObject,"warningShotTarget");
				if(_step == 1)then{
					_oh reveal _laserT;
					_oh doTarget _laserT;
				};
				if(_step == 2 || _step == 3)then{
					_oh reveal _laserT;
					_oh doTarget _laserT;
					_oh forceWeaponFire [weaponState _oh select 1, weaponState _oh select 2];
				};			

				if(_step > 4)then{_oh doTarget _target; _oh doFire _target};
				SETV(_thisObject,"step",_step + 1);
				
			}
		};//else only aim
		ACTION_STATE_ACTIVE;

		
		
		
	} ENDMETHOD;
	
	// logic to run when the goal is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		
		diag_log "Terminating scaring civilian!";
		
		
		
		
		// Stop scaring if we are
		pr _state = GETV(_thisObject, "state");
		if (_state == ACTION_STATE_ACTIVE) then {
			pr _oh = GETV(_thisObject, "objectHandle");
			pr _target = GETV(_thisObject, "target");
			_oh forgetTarget _target;
			_oh lookAt objNull; // Stop looking at your target
			_oh doFollow (leader group _oh); // Regroup
			group _oh setBehaviour "SAFE";
			group _oh setSpeedMode "NORMAL";
			pr _laserT = GETV(_thisObject,"warningShotTarget");
			detach _laserT;
			deleteVehicle _laserT;
		};
		
	} ENDMETHOD; 

ENDCLASS;