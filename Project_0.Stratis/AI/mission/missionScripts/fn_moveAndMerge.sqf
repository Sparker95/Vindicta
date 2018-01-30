/*

*/

#define DEBUG

params ["_gar", "_stateArray", "_RTB"];

_stateArray params ["_state", "_stateChanged"];

private _m = _gar call gar_fnc_getAssignedMission;
private _oTask = _gar call gar_fnc_getTask;
private _failureReason = "";

//State machine
switch (_state) do
{
	case "INIT":
	{
		if (_stateChanged) then
		{
			#ifdef DEBUG
			diag_log format ["INFO: fn_moveAndMerge.sqf: mission %1 entered INIT state, RTB: %2", _m getVariable "AI_m_name", _RTB];
			#endif
			//Switch state
			_stateChanged = true;
			_state = "MOVE";
		};
	};
	
	case "MOVE":
	{
		if (_stateChanged) then
		{
			#ifdef DEBUG
			diag_log format ["INFO: fn_moveAndMerge.sqf: mission %1 entered MOVE state", _m getVariable "AI_m_name"];
			#endif
			
			//Get the destination
			private _target = objNull;
			if(_RTB) then
			{ //If we need to RTB, then return to garrison's location
				_target = _gar call gar_fnc_getLocation;
			} else
			{ //Otherwise go to the destination defined in mission
				private _mParams = _m getVariable "AI_m_params";
				_target = _mParams select 0;
			};
			
			//Stop previous task (if it exists)
			_oTask call AI_fnc_task_delete;
			
			//Create the new task
			_oTask = [_gar, "MOVE", [_target, 500], "Move, move&merge mission"] call AI_fnc_task_create;
			_oTask call AI_fnc_task_start;
			
			_stateChanged = false;
		};
		
		//Wait until the move task has been finished
		private _taskState = _oTask call AI_fnc_task_getState;
		if (_taskState != "RUNNING") then
		{
			switch (_taskState) do
			{
				case "SUCCESS":
				{
					_state = "MERGE";
					_stateChanged = true;
				};
				case "FAILURE":
				{
					_failureReason = _oTask call AI_fnc_task_getFailureReason;
				};
			};
		};
	};
	
	case "MERGE":
	{
		if (_stateChanged) then
		{
			#ifdef DEBUG
			diag_log format ["INFO: fn_moveAndMerge.sqf: mission %1 entered MERGE state", _m getVariable "AI_m_name"];
			#endif
			
			//Stop previous task
			_oTask call AI_fnc_task_delete;
			_stateChanged = false;
			
			//Get the destination
			private _target = objNull;
			if(_RTB) then
			{ //If we need to RTB, then return to garrison's location
				_target = _gar call gar_fnc_getLocation;
			} else
			{ //Otherwise go to the destination defined in mission
				private _mParams = _m getVariable "AI_m_params";
				_target = _mParams select 0;
			};
			
			_oTask = [_gar, "MERGE", [_target], "Merge, move&merge mission"] call AI_fnc_task_create;
			_oTask call AI_fnc_task_start;
		};
		
		//Wait until merge is done
		private _taskState = _oTask call AI_fnc_task_getState;
		if (_taskState != "RUNNING") then {
			switch (_taskState) do {
				case "SUCCESS": {
					//Terminate this task
					_oTask call AI_fnc_task_delete;
					//Report success to the mission thread
					_state = "SUCCESS";
					_stateChanged = true;
				};
				case "FAILURE":	{
					_failureReason = _oTask call AI_fnc_task_getFailureReason;
				};
			};
		};
	};
};

//Return value
[_state, _stateChanged, _failureReason]