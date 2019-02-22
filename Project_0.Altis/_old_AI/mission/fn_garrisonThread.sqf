/*
This thread monitors the execution of a mission by a specific garrison.
*/

#define DEBUG
#define DEBUG_MARKER
#define SLEEP_TIME 3
#define SLEEP_RESOLUTION 0.2

params ["_so", "_extraParams"]; //script object, extra params

private _hScript = [_so, _extraParams] spawn
{
	params ["_so", "_extraParams"];
	
	//Read extra parameters
	_extraParams params ["_gar"];
	private _side = _gar call gar_fnc_getSide;
	
	//Get mission assigned to this garrison
	private _mo = _gar call gar_fnc_getAssignedMission; //Mission object
	private _moPrev = _mo;
	private _moNullPrev = isNull _mo;
	
	//Variables for internal state machines
	//private _mChanged = true;
	private _stateArray = ["INIT", true, ""];
	//private _moPrev = _gar call gar_fnc_getAssignedMission;
	
	#ifdef DEBUG
	diag_log format ["<AI_MISSION> INFO: fn_garrisonThread.sqf: started thread for garrison: %1", _gar call gar_fnc_getName];
	#endif
	
	//Draw marker
	#ifdef DEBUG_MARKER
		private _colorFriendly = "ColorEAST";
		private _markerType = "flag_CSAT";
		switch (_side) do {
			case EAST: { _colorFriendly = "ColorEAST"; _markerType = "flag_CSAT"; };
			case WEST: { _colorFriendly = "ColorWEST"; _markerType = "flag_NATO"; };
			case INDEPENDENT: {	_colorFriendly = "ColorGUER"; _markerType = "flag_AAF";};
		};
		private _name = format ["mGarrison_%1", _gar];
		private _mrk = createmarker [_name, getPos _gar];
		_mrk setMarkerType _markerType; //Section marker
		_mrk setMarkerColor _colorFriendly;
		_mrk setMarkerAlpha 1.0;
		_mrk setMarkerText (format ["Mis. type: %1, state: %2",
			_mo call AI_fnc_mission_getType, _stateArray]);
	#endif
	
	private _t = time;
	private _type = "";
	private _run = true;
	private _deleteSO = false;
	while {_run && _so getVariable "so_run"} do
	{
		_mo = _gar call gar_fnc_getAssignedMission;
		//Check if the garrison was assigned a new mission or has switched to no mission
		private _moNull = isNull _mo;
		if (!(_mo isEqualTo _moPrev) || ((_moNull && (!_moNullPrev)) || ((!_moNull) && _moNullPrev)) ) then
		{
			_stateArray = ["INIT", true, ""];
			#ifdef DEBUG
			diag_log format ["<AI_MISSION> INFO: fn_garrisonThread.sqf: garrison %1 switched mission to: %2!", _gar call gar_fnc_getName, _mo getVariable "AI_m_name"];
			#endif
		}; //Reset the state array to begin from start
		_moPrev = _mo;
		_moNullPrev = isNull _mo;
		
		//If there is no mission assigned
		if (isNull _mo) then {
			_type = "NOTHING";
		} else {
			_type = _mo getVariable ["AI_m_type", "ERROR"];
		};
		
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
					diag_log format ["<AI_MISSION> INFO: fn_garrisonThread.sqf: mission %1, task failed, state: %2, reason: %3", _mo getVariable "AI_m_name", _state, _fReason];
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
				if(_state == "SUCCESS") then { //Time to terminate this garrison because it's empty
					#ifdef DEBUG
					diag_log format ["<AI_MISSION> INFO: fn_garrisonThread.sqf: garrison %1 returned to base!", _gar call gar_fnc_getName];
					#endif
					_run = false;
					_deleteSO = true;
				};
			};
			
			default
			{
				diag_log format ["<AI_MISSION> ERROR: fn_garrisonThread.sqf: mission: %1, garrison: %2, unknown type: %3",
					_mo getVariable "AI_m_name", _gar call gar_fnc_getName, _type];
			};
		}; //switch
		
		//Update the marker
		#ifdef DEBUG_MARKER
			private _name = format ["mGarrison_%1", _gar];
			_name setMarkerPos (getPos _gar);
			_mrk setMarkerText (format ["Mis. type: %1, %2", _type, _stateArray]);
		#endif
		
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
	
	//Time to terminate the script
	//Delete the marker
	#ifdef DEBUG_MARKER
		private _name = format ["mGarrison_%1", _gar];
		deleteMarker _name;
	#endif
	//Delete the script object
	if (_deleteSO) then {
		//diag_log "INFO: fn_garrisonThread.sqf: Deleting the scriptObject!";
		[_so, false] call scriptObject_fnc_delete;
		//diag_log "INFO: fn_garrisonThread.sqf: scriptObject deleted!";
	};
}; //spawn

_hScript