/*
Task types:
	MOVE
		Parameters:
			_dest - ARRAY or OBJECT
				ARRAY - the destination position
				OBJECT - the location object. It will be queried for side(owner) change, in which case the task will fail.
	
*/

AI_fnc_task_create =
{
	params ["_gar", "_taskType", "_taskParams", ["_taskName", "noname task"]];	
	//Resolve the script name
	private _taskScriptName = "";
	switch (_taskType) do
	{
		case "MOVE":
		{
			_taskScriptName = "AI_fnc_task_move";
		};
		case "LOAD":
		{
			_taskScriptName = "AI_fnc_task_load";
		};
		case "GET_LOADED":
		{
			
		};
		case "UNLOAD":
		{
			
		};
		case "GET_UNLOADED":
		{
			
		};
		case "CAPTURE_LOC":
		{
			
		};
		case "MERGE":
		{
			
		};
	};
	if(_taskScriptName == "") exitWith
	{
		diag_log format ["AI_fnc_task_create: task: %1, error: unknown type: %2", _taskName, _taskType];
		objNull
	};
	//Create the task object
	private _to = groupLogic createUnit ["LOGIC", [9, 9, 9], [], 0, "NONE"]; //Create a logic object
	_to setVariable ["AI_taskState", "IDLE", false];
	_to setVariable ["AI_name", _taskName, false];					//Name of this task for debug purposes
	_to setVariable ["AI_hScript", scriptNull, false];				//Handle of the script spawned to process this task
	_to setVariable ["AI_taskScriptName", _taskScriptName, false];	//Name of the script to call at the task start
	_to setVariable ["AI_stopFunctionName", "", false];					//Function to call when this task has to be stopped
	_to setVariable ["AI_garrison", _gar, false];					//The garrison for which this task is started
	_to setVariable ["AI_taskParams", _taskParams, false]; 			//Parameters to be passed to the script
	_to setVariable ["AI_failReason", "", false];					//The reason why the task has failed
	
	//Return value
	_to
};

AI_fnc_task_delete =
{
	params ["_to"];
	if(isNull _to) exitWith
	{
		diag_log "AI_fnc_task_delete: error: task is objNull!";
	};
	//private _state = _to getVariable "AI_taskState";
	deleteVehicle _to;
};

AI_fnc_task_getState =
{
	params ["_to"];
	_to getVariable "AI_taskState"
};

AI_fnc_task_start =
{
	params ["_to"];
	//Set the state of task
	_to setVariable ["AI_taskState", "RUNNING", false];
	//Get variables
	private _taskScriptName = _to getVariable "AI_taskScriptName";
	//Spawn the script
	private _hScript = [_to] spawn (call compile _taskScriptName);
	//Set the script handler
	_to setVariable ["AI_hScript", _hScript, false];
};


AI_fnc_task_stop =
{
	/*
	Resets the task to its default (IDLE) state and stops the scripts associated with it.
	*/
	params ["_to"];
	private _stopFunctionName = _to getVariable "AI_stopFunctionName";
	if(_stopFunctionName == "") then
	{
		//diag_log format ["AI_fnc_task_stop: task: %1, error: stop function is not specified!", _to getVeriable "AI_name"];
	}
	else
	{
		//Call the stop function
		call (call compile _stopFunctionName);
	};
	//Terminate the script in case it wasn't terminated
	private _hScript = _to getVariable "AI_hScript";
	
	if(!scriptDone _hScript) then
	{
		terminate _hScript;
		_to setVariable ["AI_hScript", scriptNull, false];
		//diag_log format ["AI_fnc_task_stop: task: %1, warning: task script was terminated by AI_fnc_task_stop!", _to getVeriable "AI_name"];
	};
};
