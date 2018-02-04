/*
This thread monitors the execution of a mission by a specific garrison.
*/

#define DEBUG
#define SLEEP_TIME 3
#define SLEEP_RESOLUTION 0.2

params ["_so", "_extraParams"]; //script object, extra params

private _hScript = [_so, _extraParams] spawn
{
	params ["_so", "_extraParams"];
	
	//Read extra parameters
	_extraParams params ["_gar"];
	
	//Get mission assigned to this garrison
	private _mo = _gar call gar_fnc_getAssignedMission; //Mission object
	private _moPrev = _mo;
	
	//Variables for internal state machines
	//private _mChanged = true;
	private _stateArray = ["INIT", true, ""];
	//private _moPrev = _gar call gar_fnc_getAssignedMission;
	
	#ifdef DEBUG
	diag_log format ["INFO: mission\fn_garrisonThread.sqf: started thread for garrison: %1", _gar call gar_fnc_getName];
	#endif
	
	private _t = time;
	private _type = "";
	private _run = true;
	while {_run && _so getVariable "so_run"} do
	{
		_mo = _gar call gar_fnc_getAssignedMission;
		//Check if the garrison was assigned a new mission
		if (!(_mo isEqualTo _moPrev)) then
		{
			_stateArray = ["INIT", true, ""];
			#ifdef DEBUG
			diag_log format ["INFO: mission\fn_garrisonThread.sqf: garrison %1 switched mission to: %2!", _gar call gar_fnc_getName, _mo getVariable "AI_m_name"];
			#endif
		}; //Reset the state array to begin from start
		_moPrev = _mo;
		
		//If there is no mission assigned
		if (isNull _mo) then { _type = "NOTHING"; } else
		{ _type = _mo getVariable ["AI_m_type", "ERROR"]; };
		
		switch (_type) do
		{
			case "SAD":
			{
				_stateArray = [_gar, _stateArray] call AI_fnc_mission_SAD;
				private _fReason = _stateArray select 2; //Failure reason
				if (_fReason != "") then //Something has failed
				{
					//Houston, we have a problem!
					private _state = _stateArray select 0;
					#ifdef DEBUG
					diag_log format ["INFO: mission\fn_garrisonThread.sqf: mission %1, task failed, state: %2, reason: %3", _mo getVariable "AI_m_name", _state, _fReason];
					#endif
					//Try to RTB
					_type = "NOTHING";
					[_mo, _gar] call AI_fnc_mission_unassignGarrison;
				};
			};
			
			case "CAPTURE":
			{
				_stateArray = [_gar, _stateArray] call AI_fnc_mission_capture;
			};
			
			case "PROVIDE_TRANSPORT":
			{
				
			};
			
			case "NOTHING": //If we are doing nothing
			{
				_stateArray = [_gar, _stateArray, true] call AI_fnc_mission_moveAndMerge; //[..., ..., true] = RTB
				private _state = _stateArray select 0;
				if(_state == "SUCCESS") then //Time to terminate this garrison because it's empty
				{
					#ifdef DEBUG
					diag_log format ["INFO: mission\fn_garrisonThread.sqf: garrison %1 returned to base!", _gar call gar_fnc_getName];
					#endif
					_run = false;
				};
			};
			
			default
			{
				diag_log format ["ERROR: mission\fn_garrisonThread.sqf: mission: %1, garrison: %2, unknown type: %3",
					_mo getVariable "AI_m_name", _gar call gar_fnc_getName, _type];
			};
		}; //switch
		
		if (_run) then
		{
			//Update time variable
			_t = time + SLEEP_TIME;
			//Sleep and check if it's ordered to stop the thread
			waitUntil
			{
				sleep SLEEP_RESOLUTION;
				(time > _t) || (!(_so getVariable "so_run"))
			};
		};
	}; //while
}; //spawn

_hScript