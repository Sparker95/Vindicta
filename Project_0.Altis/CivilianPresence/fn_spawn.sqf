
params [["_module",objnull,[objnull]]];

_module setVariable ["#active",true];

//block sub-sequent executions
if (_module getVariable ["#running",false]) exitWith {};
_module setVariable ["#running",true];


_spawnPoints = _module getVariable ["#modulesUnit",[]];


_module spawn{
	private _module = _this;

	private _units = _module getVariable ["#units",[]];
	private _maxUnits = _module getVariable ["#unitCount",0];
	private _active = false;

	while{
		_active = _module getVariable ["#active",false];
		_units = _units select {!isNull _x && {alive _x}};
		(_active && _maxUnits > 0) || (!_active && count _units > 0)
	}do{
		if (_active) then{
			if (count _units < _maxUnits) then{
				private _unit = ["createUnit",[_module]] call bis_fnc_moduleCivilianPresence;
				if (!isNull _unit) then {_units pushBack _unit};
			};
		}else{
			private _unit = selectRandom _units;
			private _deleted = ["deleteUnit",[_module,_unit]] call bis_fnc_moduleCivilianPresence;

			if (_deleted) then
			{
				_units = _units - [_unit];
			};
		};

		//compact & store units array
		_units = _units select {!isNull _x && {alive _x}};
		_module setVariable ["#units",_units];

		sleep 1;
	};
};


//release module so it can be used again
_module setVariable ["#running",false];


//DEBUG
//	private _paramsDraw3D = missionNamespace getVariable ["bis_fnc_moduleCivilianPresence_paramsDraw3D",[]];
//	private _handle = addMissionEventHandler ["Draw3D",{["debug"] call bis_fnc_cp_debug;}];
//	_paramsDraw3D set [_handle,_module];
//	bis_fnc_moduleCivilianPresence_paramsDraw3D = _paramsDraw3D;