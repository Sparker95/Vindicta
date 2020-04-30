#include "common.hpp"

/*
Scare away action class
Author: Jeroen 11.12.2018
*/

#define pr private

#define OOP_CLASS_NAME ActionUnitScareAway
CLASS("ActionUnitScareAway", "Action")

	VARIABLE("target");
	VARIABLE("activationTime");
	VARIABLE("objectHandle");
	VARIABLE("step");
	VARIABLE("warningShotTarget");
	
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		T_SETV("step",0);

		private _target = CALLSM2("Action", "getParameterValue", _parameters, TAG_TARGET);
		
		pr _laserT = createVehicle ["LaserTargetW", [0,0,0], [], 0, "NONE"];
		_laserT attachto [_target, [0, 0, 3]];
		T_SETV("warningShotTarget",_laserT);
		
		//might want to move this to ActionUnit base class
		T_SETV("target", _target);
		pr _a = GETV(_AI, "agent"); // cache the object handle
		pr _oh = CALLM0(_a, "getObjectHandle");
		T_SETV("objectHandle", _oh);

	ENDMETHOD;
	
	METHOD(delete)
	ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD(activate)
		params [P_THISOBJECT];
		
		OOP_DEBUG_0("active: Unit is pissed off!");
		
		//might what to move this to Action base class
		T_SETV("activationTime", GAME_TIME);
		
		pr _oh = T_GETV("objectHandle");
		pr _AI = T_GETV("AI");
		pr _target = T_GETV("target");
		
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
		T_SETV("state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	ENDMETHOD;
	
	// logic to run each update-step
	METHOD(process)
		params [P_THISOBJECT];
		
		diag_log "scare away process was called!";
		
		T_CALLM0("activateIfInactive");
		
		// If action is not active now, do nothing
		pr _state = T_GETV("state");
		if (_state != ACTION_STATE_ACTIVE) exitWith {_state};
		
		// Action is active
		pr _oh = T_GETV("objectHandle");
		pr _AI = T_GETV("AI");
		pr _target = T_GETV("target");
		
		//get world fact because we need to know how pissed the unit is
		pr _wf = WF_NEW();
		[_wf, WF_TYPE_UNIT_ANNOYED_BY] call wf_fnc_setType;
		_wf = CALLM(_AI, "findWorldFact", [_wf]);
		
		if(isnil "_wf" || {_oh distance _target > 10})exitWith{
			T_CALLM("terminate", []);
			T_SETV("state", ACTION_STATE_COMPLETED);
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
				T_SETV("step",_step + 1);
				
			}
		};//else only aim
		ACTION_STATE_ACTIVE;

		
		
		
	ENDMETHOD;
	
	// logic to run when the goal is satisfied
	METHOD(terminate)
		params [P_THISOBJECT];
		
		diag_log "Terminating scaring civilian!";
		
		
		
		
		// Stop scaring if we are
		pr _state = T_GETV("state");
		if (_state == ACTION_STATE_ACTIVE) then {
			pr _oh = T_GETV("objectHandle");
			pr _target = T_GETV("target");
			_oh forgetTarget _target;
			_oh lookAt objNull; // Stop looking at your target
			_oh doFollow (leader group _oh); // Regroup
			group _oh setBehaviour "SAFE";
			group _oh setSpeedMode "NORMAL";
			pr _laserT = GETV(_thisObject,"warningShotTarget");
			detach _laserT;
			deleteVehicle _laserT;
		};
		
	ENDMETHOD;

ENDCLASS;