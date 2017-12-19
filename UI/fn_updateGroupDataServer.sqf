params ["_clientOwner", "_hcGroups"];

private _text = "";
private _textOnFoot = "on foot";
private _textInVeh = "in veh.";

{
	//Get the group array
	private _gar = _x getVariable ["g_garrison", objNull];
	private _groupID = _x getVariable ["g_groupID", 0];
	private _group = _x getVariable ["g_group", []];

	if(_gar isEqualTo objNull) then //If the group isn't from any garrison
	{
		_text = _text + format ["Group %1: %2\nUnits: %3\n", _x, behaviour (leader _x), count (units _x)];
		private _vehicles = [];
		{
			private _displayName = getText (configfile >> "CfgVehicles" >> (typeof _x) >> "displayName");
			private _vehRole = assignedVehicleRole _x;
			private _vehRoleText = "";
			if(count _vehRole > 0) then
			{
				_vehRoleText = _vehRole select 0;
			};
			private _onFootText = _textOnFoot;
			if(vehicle _x != _x) then //If the unit is in vehicle
			{
				_onFootText = _textInVeh;
			};
			_text = _text + "  " + _displayName + " " + _vehRoleText + " " + _onFootText + "\n";
			private _veh = assignedVehicle _x;
			if(!(_veh isEqualTo objNull)) then
			{
				_vehicles pushBackUnique _veh;
			};
		}forEach (units _x);
		if(count _vehicles > 0) then
		{
			_text = _text + format ["Vehicles: %1\n", count _vehicles];
			{
				private _displayName = getText (configfile >> "CfgVehicles" >> (typeof _x) >> "displayName");
				_text = _text + "  " + _displayName + "\n";
			} forEach _vehicles;
		};
	}
	else //If the group belongs to garrison
	{
		_text = _text + format ["Group %1: %2\n", _x, behaviour (leader _x)];
		private _groupUnits = _group select 0;
		private _unitsInf = _groupUnits select {_x select 0 select 0 == T_INF};
		private _unitsVeh = _groupUnits select {_x select 0 select 0 == T_VEH};
		private _groupType = _group select 3;
		if(count _unitsVeh > 0) then
		{
			_text = _text + format["Vehicles: %1\n", count _unitsVeh];
			{
				private _unitData = _x select 0;
				if(_unitData select 2 == -1) then //The unit has been killed
				{
					_text = _text + " Vehicle wreck\n";
				}
				else
				{
					private _unit = [_gar, _unitData] call gar_fnc_getUnit;
					private _objectHandle = _unit select 1;
					_text = _text +  " " + (getText (configfile >> "CfgVehicles" >> (typeof _objectHandle) >> "displayName")) + "\n";
					if(!canMove _objectHandle) then
					{
						_text = _text + "  Can't move!\n";
					};
					private _fullCrew = [typeOf _objectHandle] call gar_fnc_aux_getFullCrew;
					private _countCrew = (_fullCrew select 0) + (count (_fullCrew select 1)) + (count (_fullCrew select 2));
					private _countCargo = (count (_fullCrew select 3)) + (_fullCrew select 4);
					_text = _text + format["  Inf. capacity:\n  Crew: %1, Pass.: %2\n", _countCrew, _countCargo];
				};
			}forEach _unitsVeh;
		};
		if(count _unitsInf > 0) then
		{
			_text = _text + format["Infantry: %1\n", count _unitsInf];
			{
				private _unitData = _x select 0;
				private _subcat = _unitData select 1;
				_text = _text + " " + (T_NAMES select 0 select _subcat);
				private _vehRole = _x select 1;

				if(!(_vehRole isEqualTo [])) then
				{
					private _role = _vehRole select 1;
					switch (_role) do
					{
						case G_VR_driver:
						{_text = _text + ": driver, ";};
						case G_VR_turret:
						{_text = _text + ": turret, ";};
						case G_VR_cargo_turret:
						{_text = _text + ": cargo FFV, ";};
						case G_VR_cargo:
						{_text = _text + ": cargo, ";};
					};
				};

				if(_unitData select 2 == -1) then //The unit has been killed
				{
					_text = _text + " K.I.A.";
				}
				else
				{
					private _unit = [_gar, _unitData] call gar_fnc_getUnit;
					private _objectHandle = _unit select 1;
					private _onFootText = _textOnFoot;
					if(vehicle _objectHandle != _objectHandle) then //If the unit is in vehicle
					{
						_onFootText = _textInVeh;
					};
					_text = _text + _onFootText;
				};

				_text = _text + "\n";
			}forEach _unitsInf;
		};
	};

	_text = _text + "\n";
}forEach _hcGroups;

[_text] remoteExecCall ["ui_fnc_updateGroupDataClient", _clientOwner];