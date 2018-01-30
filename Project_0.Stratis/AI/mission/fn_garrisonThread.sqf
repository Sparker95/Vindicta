/*
This thread monitors the execution of a mission by a specific garrison.
*/

#define DEBUG
#define SLEEP_INTERVAL 3

params ["_gar"];

//Get mission assigned to this garrison
private _mo = _gar call gar_fnc_getAssignedMission; //Mission object

//Variables for internal state machines
//private _mChanged = true;
private _stateArray = ["INIT", true, ""];
//private _moPrev = _gar call gar_fnc_getAssignedMission;

#ifdef DEBUG
diag_log format ["INFO: mission\fn_garrisonThread.sqf: started thread for garrison: %1", _gar call gar_fnc_getName];
#endif

while {!(isNull _mo)} do
{
	sleep SLEEP_INTERVAL;
	
	_mo = _gar call gar_fnc_getAssignedMission;
	private _type = _mo getVariable ["AI_m_type", "ERROR"];
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
				diag_log format ["INFO: mission\fn_garrisonThread.sqf: mission %1, task failed, state: %2, reason: %3", _m getVariable "AI_m_name", _state, _reason];
				#endif
			};
		};
		
		case "CAPTURE":
		{
			_stateArray = [_gar, _stateArray] call AI_fnc_mission_capture;
		};
		
		case "PROVIDE_TRANSPORT":
		{
			
		};
		
		default
		{
			diag_log format ["ERROR: mission\fn_garrisonThread.sqf: mission %1, unknown type: %2", _mo getVariable "AI_m_name", _type];
			_mo = objNull;
		};
	};
};