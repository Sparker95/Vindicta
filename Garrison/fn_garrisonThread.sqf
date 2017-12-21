/*
The thread for managing actions with garrison objects.

The queue is here because we want to process things in sequential synchronous order. Especially it is needed when we modify the garrison array. It should be modified by one script in non-parallel manner because we don't want to damage it.

_workTime - the time during which the thread will work, in seconds. After that the thread will self-terminate.
*/

#include "garrison.hpp"

params ["_lo", "_workTime", ["_debug", true]];

private _run = true;
private _request = [];
private _requestType = 0;
private _requestData = [];
private _requestReturn = [];
private _queueNotEmpty = false;
private _queue = _lo getVariable ["g_threadQueue", []];
private _sleepInterval = 0.0;
private _spawned = false;
private _timeEnd = time + _workTime;
while {_run} do
{
	sleep _sleepInterval;
	_spawned = _lo getVariable ["g_spawned", false];

	if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, spawned: %2, waiting for requests", _lo getVariable ["g_name", ""], _spawned];};

	waitUntil{ //Wait until there's something in the queue
		sleep _sleepInterval;
		((count _queue > 0) || (time > _timeEnd))
	};

	if(count _queue > 0) then //If there's something in the queue
	{
		//_timeEnd = _timeEnd + 1; //Every new request adds a second to run time of the thread
		_request = _queue select 0;
		_requestType = _request select 0;
		if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, spawned: %2, processing request: %3.", _lo getVariable ["g_name", ""], _spawned, _request];};
		switch(_requestType) do
		{
			//Stop thread request
			case G_R_STOP:
			{
				if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, state: stopping thread.", _lo getVariable ["g_name", ""]];};
				_lo setVariable ["g_threadHandle", scriptNull];
				_run = false;
			};

			//Request to spawn garrison
			case G_R_SPAWN:
			{
				if(_spawned) then
				{
					if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, ignoring spawn request.", _lo getVariable ["g_name", ""], _request];};
				}
				else
				{
					if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, state: spawning.", _lo getVariable ["g_name", ""]];};
			    	call gar_fnc_t_spawnGarrison;
			    	_lo setVariable ["g_spawned", true, false];
				};
			};

			//Request to despawn garrison
			case G_R_DESPAWN:
			{
				if(_lo getVariable ["g_spawned", false]) then
				{
					if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, state: despawning.", _lo getVariable ["g_name", ""]];};
			    	call gar_fnc_t_despawnGarrison;
			    	_lo setVariable ["g_spawned", false, false];
				}
				else
				{
					if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, ignoring despawn request.", _lo getVariable ["g_name", ""], _request];};
				};
			};

			//Request to add an existing unit
			//todo remove this piece of code
			/*
			case G_R_ADD_EXISTING_UNIT:
			{
				_requestData = _request select 1;
				if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, adding existing unit: %2", _lo getVariable ["g_name", ""], _requestData];};
				[_lo, _requestData, _spawned] call gar_fnc_t_addExistingUnit;
			};
			*/

			//Request to add an existing group
			case G_R_ADD_EXISTING_GROUP:
			{
				_requestData = _request select 1;
				_requestReturn = _request select 2;
				if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, adding existing group: %2", _lo getVariable ["g_name", ""], _requestData select 1];};
				private _groupID = [_lo, _requestData, _spawned] call gar_fnc_t_addExistingGroup;
				_requestReturn set [0, _groupID];
			};

			//Request to add a new unit
			case G_R_ADD_NEW_UNIT:
			{
				_requestData = _request select 1;
				_requestReturn = _request select 2;
				if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, adding new unit: %2", _lo getVariable ["g_name", ""], _requestData];};
				private _unitID = [_lo, _requestData, _spawned] call gar_fnc_t_addNewUnit;
				_requestReturn set [0, _unitID];
			};

			//Request to add a new group
			case G_R_ADD_NEW_GROUP:
			{
				_requestData = _request select 1;
				_requestReturn = _request select 2;
				if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, adding new group: %2", _lo getVariable ["g_name", ""], _requestData];};
				private _groupID = [_lo, _requestData, _spawned] call gar_fnc_t_addNewGroup;
				_requestReturn set [0, _groupID];
			};

			//Request to remove a unit
			case G_R_REMOVE_UNIT:
			{
				_requestData = _request select 1;
				if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, removing unit: %2", _lo getVariable ["g_name", ""], _requestData];};
				[_lo, _requestData] call gar_fnc_t_removeUnit;
			};

			//Request to move a unit from this garrison to another one
			//todo remove this piece of code
			/*
			case G_R_MOVE_UNIT:
			{
				_requestData = _request select 1;
				if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, moving unit to garrison: %2", _lo getVariable ["g_name", ""], (_requestData select 0) getVariable ["g_name", ""]];};
				[_lo, _requestData] call gar_fnc_t_moveUnit;
			};
			*/

			//Request to move a group from this garrison to another one
			case G_R_MOVE_GROUP:
			{
				_requestData = _request select 1;
				_requestReturn = _request select 2;
				if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, moving a group to garrison: %2", _lo getVariable ["g_name", ""], (_requestData select 0) getVariable ["g_name", ""]];};
				private _groupID = [_lo, _requestData, _spawned] call gar_fnc_t_moveGroup;
				_requestReturn set [0, _groupID];
			};

			/*
			//todo delete this
			case G_R_START_AI_THREAD:
			{
				_requestData = _request select 1;
				if(_spawned) then
				{
					[_lo, _requestData] call gar_fnc_t_startAIThread;
				}
				else
				{
					diag_log format ["fn_garrisonThread.sqf: garrison: %1, error: request to start AI thread for despawned garrison", _lo getVariable ["g_name", ""]];
				};
			};
			
			case G_R_STOP_AI_THREAD:
			{
				if(_spawned) then
				{
					[_lo, _requestData] call gar_fnc_t_stopAIThread;
				}
				else
				{
					diag_log format ["fn_garrisonThread.sqf: garrison: %1, error: request to stop AI thread for despawned garrison", _lo getVariable ["g_name", ""]];
				};
			};
			*/
			
			//Request to set the alert state of the garrison
			/*
			//todo: remove this piece of code
			case G_R_SET_ALERT_STATE:
			{
				_requestData = _request select 1;
				if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, setting new alert state: %2", _lo getVariable ["g_name", ""], _requestData];};
				[_lo, _requestData, _spawned, false] call gar_fnc_t_setAlertState; // [..., ..., _spawned, _justSpawned]
			};
			*/

			//Unknown request, probably an error
			default
			{
				if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, error: unknown request: %2. Terminating thread.", _lo getVariable ["g_name", ""], _request];};
				if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, state: stopping thread.", _lo getVariable ["g_name", ""]];};
							_lo setVariable ["g_threadHandle", nil];
				_run = false;
			};
		};
		_queue deleteAt 0; //Delete the processed request
		//Increase the requestID counter
		private _requestID = _lo getVariable["g_execRequestID", 0];
		_lo setVariable ["g_execRequestID", _requestID + 1];
	}
	else
	{
		if(time > _timeEnd) then //There's nothing else in the queue and we can terminate the thread because of timeout
		{
			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, state: stopping thread(timeout).", _lo getVariable ["g_name", ""]];};
			_lo setVariable ["g_threadHandle", scriptNull];
			_run = false;
		};
	};
};

if(_debug) then { diag_log format ["fn_garrisonThread.sqf: garrison: %1, thread stopped.", _lo getVariable ["g_name", ""]]; };