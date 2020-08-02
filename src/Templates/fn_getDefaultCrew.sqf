params [["_catID", 0, [0]], ["_subcatID", 0, [0]], ["_className", "", [""]] ];

private _types = [];

private _fullCrew = [_className] call misc_fnc_getFullCrew;
//diag_log format ["Vehicle: %1 crew: %2", _unitClassName, _fullCrew];
private _np = _fullCrew select 0;			//Number of pilots or drivers
private _ncp = count (_fullCrew select 1);	//number of copilots
private _nt = count (_fullCrew select 2);	//Number of turrets
call //Check what kind of crew is needed for this vehicle
{
	if(_subcatID in T_VEH_need_crew) exitWith { //Some armored vehicle needs crewmen
		//_crewClass = [_template, T_INF, T_INF_crew, 0] call t_fnc_select;
		for "_j" from 0 to (_np + _ncp + _nt - 1) do {
			//_types pushBack [T_INF, T_INF_crew, 0];
			// Temp fix until cmdr can allocate proper crew men
			_types pushBack [T_INF, T_INF_rifleman, 0];
		};
	};
	if(_subcatID in T_VEH_need_heli_crew) exitWith { //Helicopter crew is needed. Pilot and copilot get pilot_heli classes, gunners get crew_heli classes.
		//_crewClass = [_template, T_INF, T_INF_pilot_heli, 0] call t_fnc_select;
		for "_j" from 0 to (_np + _ncp  - 1) do {
			//_types pushBack [T_INF, T_INF_pilot_heli, 0];
			// Temp fix until cmdr can allocate proper crew men
			_types pushBack [T_INF, T_INF_crew_heli, 0];
		};
		//_crewClass = [_template, T_INF, T_INF_crew_heli, 0] call t_fnc_select;
		for "_j" from 0 to (_nt  - 1) do {
			_types pushBack [T_INF, T_INF_crew_heli, 0];
		};
	};
	if(_subcatID in T_VEH_need_plane_crew) exitWith { //Plane pilots are needed
		//_crewClass = [_template, T_INF, T_INF_pilot, 0] call t_fnc_select;
		for "_j" from 0 to (_np + _ncp + _nt - 1) do {
			//_types pushBack [T_INF, T_INF_pilot, 0];
			// Temp fix until cmdr can allocate proper crew men
			_types pushBack [T_INF, T_INF_crew, 0];
		};
	};
	if(_subcatID in T_VEH_static) exitWith { //Static vehicles will have riflemen assigned
		//_crewClass = [_template, T_INF, T_INF_pilot, 0] call t_fnc_select; //todo replace pilots with riflemen
		for "_j" from 0 to (_np + _ncp + _nt - 1) do {
			_types pushBack [T_INF, T_INF_rifleman, 0];
		};
	};
	if(_subcatID in T_VEH_need_basic_crew) exitWith { //MRAPs and gunboats will have riflemen as drivers and gunners
		//_crewClass = [_template, T_INF, T_INF_rifleman, 0] call t_fnc_select;
		for "_j" from 0 to (_np + _ncp + _nt - 1) do {
			_types pushBack [T_INF, T_INF_rifleman, 0];
		};
	};
	//Else add riflemen as crew
	//_crewClass = [_template, T_INF, T_INF_rifleman, 0] call t_fnc_select;
	for "_j" from 0 to (_np + _ncp + _nt - 1) do {
		_types pushBack [T_INF, T_INF_rifleman, 0];
	};
};

_types