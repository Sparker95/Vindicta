/*
The thread for managing actions with garrison objects.
The core of it is a state machine with two major state:
	IDLE - the default state when we launch the thread or when garrison is despawned.
	SPAWNED - the state when the garrison has been spawned.
	STOPPING - assign this state to the _state variable and the thread will terminate at next iteration.

When the state machine is in IDLE or SPAWNED state, it processes incoming requests through the _queue variable. The queue is here because we want to process things in sequential synchronous order. Especially it is needed when we modify the garrison array. It should be modified by one script in non-parallel manner because we don't want to damage it.
*/

#include "garrison.hpp"

params ["_lo", ["_debug", true]];

private _state = G_S_IDLE; //Idle state
private _run = true;
private _request = [];
private _requestType = 0;
private _requestData = [];
private _queueNotEmpty = false;
private _queue = _lo getVariable ["g_threadQueue", []];
private _sleepInterval = 0.0;

while {_run} do
{
	sleep _sleepInterval;

	switch (_state) do {

		//==== Idle state. This is the default state when the thread starts. ====
	    case G_S_IDLE: //Idle state, garrison is despawned
	    {
	    	if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, state: idle, waiting for requests", _lo getVariable ["g_name", ""]];};
	    	waitUntil{ //Wait until there's something in the queue
	    		sleep _sleepInterval;
	    		(count _queue > 0)
	    	};
	    	_request = _queue select 0;
	    	_requestType = _request select 0;
	    	if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, state: idle, processing request: %2.", _lo getVariable ["g_name", ""], _request];};
	    	switch(_requestType) do
	    	{
	    		//Stop thread requast
	    		case G_R_STOP:
	    		{
	    			_state = G_S_STOPPING;
	    		};

	    		//Request to spawn garrison
	    		case G_R_SPAWN:
	    		{
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, state: spawning.", _lo getVariable ["g_name", ""]];};
			    	call gar_fnc_t_spawnGarrison;
			    	_lo setVariable ["g_spawned", true, false];
			    	_state = G_S_SPAWNED;
	    		};

	    		//Request to despawn garrison
	    		case G_R_DESPAWN:
	    		{
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, ignoring despawn request.", _lo getVariable ["g_name", ""], _request];};
	    		};

	    		//Request to add an existing unit
	    		case G_R_ADD_EXISTING_UNIT:
	    		{
	    			_requestData = _request select 1;
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, adding existing unit: %2", _lo getVariable ["g_name", ""], _requestData];};
	    			[_lo, _requestData, false] call gar_fnc_t_addExistingUnit;
	    		};

	    		//Request to add an existing group
	    		case G_R_ADD_EXISTING_GROUP:
	    		{
	    			_requestData = _request select 1;
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, adding existing group: %2", _lo getVariable ["g_name", ""], _requestData select 1];};
	    			[_lo, _requestData, false] call gar_fnc_t_addExistingGroup;
	    		};

	    		//Request to add a new unit
	    		case G_R_ADD_NEW_UNIT:
	    		{
	    			_requestData = _request select 1;
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, adding new unit: %2", _lo getVariable ["g_name", ""], _requestData];};
	    			[_lo, _requestData, false] call gar_fnc_t_addNewUnit;
	    		};

	    		//Request to add a new group
	    		case G_R_ADD_NEW_GROUP:
	    		{
	    			_requestData = _request select 1;
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, adding new group: %2", _lo getVariable ["g_name", ""], _requestData];};
	    			[_lo, _requestData, false] call gar_fnc_t_addNewGroup;
	    		};

	    		//Request to remove a unit
	    		case G_R_REMOVE_UNIT:
	    		{
	    			_requestData = _request select 1;
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, removing unit: %2", _lo getVariable ["g_name", ""], _requestData];};
	    			[_lo, _requestData] call gar_fnc_t_removeUnit;
	    		};

	    		//Request to move a unit from this garrison to another one
	    		case G_R_MOVE_UNIT:
	    		{
	    			_requestData = _request select 1;
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, moving unit to garrison: %2", _lo getVariable ["g_name", ""], (_requestData select 0) getVariable ["g_name", ""]];};
	    			[_lo, _requestData] call gar_fnc_t_moveUnit;
	    		};

	    		//Request to move a group from this garrison to another one
	    		case G_R_MOVE_GROUP:
	    		{
	    			_requestData = _request select 1;
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, moving a group to garrison: %2", _lo getVariable ["g_name", ""], (_requestData select 0) getVariable ["g_name", ""]];};
	    			[_lo, _requestData] call gar_fnc_t_moveGroup;
	    		};

	    		//Unknown request, probably an error
				default
				{
					_state = G_S_STOPPING;
					if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, error: unknown request: %2. Terminating thread.", _lo getVariable ["g_name", ""], _request];};
				};
	    	};
	    	_queue deleteAt 0; //Delete the processed request
	    };

	    //==== Stopping the thread ====
	    case G_S_STOPPING: //Stop the thread
	    {
	    	if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, state: stopping thread.", _lo getVariable ["g_name", ""]];};
			_lo setVariable ["g_threadHandle", scriptNull];
	    	_run = false;
	    };

	    //==== The units have been spawned ====
	    case G_S_SPAWNED: //Units have been spawned
	    {
	    	if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, state: spawned. Waiting for requests.", _lo getVariable ["g_name", ""]];};
	    	//Process requests now
	    	waitUntil{ //Wait until there's something in the queue
	    		sleep _sleepInterval;
	    		(count _queue > 0)
	    	};
	    	_request = _queue select 0;
	    	_requestType = _request select 0;
	    	if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, state: spawned, processing request: %2.", _lo getVariable ["g_name", ""], _request];};
	    	//Select the request type
	    	switch(_requestType) do
	    	{
	    		case G_R_STOP:
	    		{
	    			_state = G_S_STOPPING;
	    		};

	    		case G_R_SPAWN:
	    		{
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, ignoring spawn request.", _lo getVariable ["g_name", ""], _request];};
	    		};

	    		case G_R_DESPAWN:
	    		{
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, state: despawning.", _lo getVariable ["g_name", ""]];};
			    	call gar_fnc_t_despawnGarrison;
			    	_lo setVariable ["g_spawned", false, false];
			    	_state = G_S_IDLE;
	    		};

	    		//Request to add a unit
	    		case G_R_ADD_EXISTING_UNIT:
	    		{
	    			_requestData = _request select 1;
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, adding existing unit: %2", _lo getVariable ["g_name", ""], _requestData];};
	    			[_lo, _requestData, true] call gar_fnc_t_addExistingUnit;
	    		};

	    		//Request to add an existing group
	    		case G_R_ADD_EXISTING_GROUP:
	    		{
	    			_requestData = _request select 1;
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, adding existing group: %2", _lo getVariable ["g_name", ""], _requestData select 1];};
	    			[_lo, _requestData, true] call gar_fnc_t_addExistingGroup;
	    		};

	    		//Request to add a new unit
	    		case G_R_ADD_NEW_UNIT:
	    		{
	    			_requestData = _request select 1;
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, adding new unit: %2", _lo getVariable ["g_name", ""], _requestData];};
	    			[_lo, _requestData, true] call gar_fnc_t_addNewUnit;
	    		};

	    		//Request to add a new group
	    		case G_R_ADD_NEW_GROUP:
	    		{
	    			_requestData = _request select 1;
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, adding new group: %2", _lo getVariable ["g_name", ""], _requestData];};
	    			[_lo, _requestData, true] call gar_fnc_t_addNewGroup;
	    		};

				//Request to remove a unit
	    		case G_R_REMOVE_UNIT:
	    		{
	    			_requestData = _request select 1;
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, removing unit: %2", _lo getVariable ["g_name", ""], _requestData];};
	    			[_lo, _requestData] call gar_fnc_t_removeUnit;
	    		};

	    		//Request to move a unit from this garrison to another one
	    		case G_R_MOVE_UNIT:
	    		{
	    			_requestData = _request select 1;
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, moving unit to garrison: %2", _lo getVariable ["g_name", ""], (_requestData select 0) getVariable ["g_name", ""]];};
	    			[_lo, _requestData] call gar_fnc_t_moveUnit;
	    		};

	    		//Request to move a group from this garrison to another one
	    		case G_R_MOVE_GROUP:
	    		{
	    			_requestData = _request select 1;
	    			if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, moving group %2 to garrison: %3", _lo getVariable ["g_name", ""], _requestData select 0, (_requestData select 0) getVariable ["g_name", ""]];};
	    			[_lo, _requestData] call gar_fnc_t_moveGroup;
	    		};

				default
				{
					_state = G_S_STOPPING;
					if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, error: unknown request: %2. Terminating thread.", _lo getVariable ["g_name", ""], _request];};
				};
	    	};
	    	_queue deleteAt 0; //Delete the processed request
	    };

	    //==== Unknown state, probably an error ====
	    default
	    {
	    	if(_debug) then {diag_log format ["fn_garrisonThread.sqf: garrison: %1, error: unknown state: %2.", _lo getVariable ["g_name", ""], _state];};
			_state = G_S_STOPPING;
	    };
	};
};

diag_log "Thread stopped";
