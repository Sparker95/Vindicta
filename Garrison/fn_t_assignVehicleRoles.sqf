/*
Used inside the garrison thread to assign or unassign vehicle roles for spawned units.
_groupUnits - unitData array of the group array in g_groups
*/

params ["_lo", "_groupID", "_spawned", "_assignDrivers", "_assignTurrets", "_assignPassengers"];

//diag_log format ["fn_t_assignVehicleRoles: assign drivers: %1, assign turrets: %2", _assignDrivers, _assignTurrets];

private _group = [_lo, _groupID] call gar_fnc_getGroup;
if(_group isEqualTo []) exitWith {};

private _groupUnits = _group select 0;
//diag_log format ["_groupUnits: %1", _groupUnits];

private _catID = 0;
private _class = "";
private _i = 0;
private _allCrew = []; //todo this variable isn't needed any more
private _count = count _groupUnits;
private _i = 0;
private _unitData = [];
private _unitID = 0;
private _vehHandle = objNull;
private _unitHandle = objNull;
private _vehUnitData = [];
private _vehUnit = [];
private _infUnit = [];

//Unassign all previously assigned vehicle roles
while {_i < _count} do
{
	_unitData = (_groupUnits select _i) select 0;
	_catID = _unitData select 0;
	_unitID = _unitData select 2;
	if(_catID == T_INF && _unitID != -1) then //If it's infantry
	{
		_unit = [_lo, _unitData] call gar_fnc_getUnit;
		_unitHandle = _unit select 1;
		(_groupUnits select _i) set [1, []]; //Reset the _vehicleRole value
		if(_spawned) then
		{
			unassignVehicle _unitHandle;
		};
	};
	_i = _i + 1;
};

 //Find vehicles in this group and assign roles
_i = 0;
while {_i < _count} do
{
	_unitData = (_groupUnits select _i) select 0;
	_catID = _unitData select 0;
	_unitID = _unitData select 2;
	if(_catID == T_VEH && _unitID != -1) then //If it's a vehicle and it's not destroyed
	{
		_vehUnitData = _unitData;
		_vehUnit = [_lo, _unitData] call gar_fnc_getUnit; //Get vehicle's data from the garrison array
		_vehHandle = _vehUnit select 1; //Get vehicle object handle
		_class = _vehUnit select 0;
		private _fullCrew = [_class] call gar_fnc_aux_getFullCrew;
		//diag_log format ["vehicle: %1 fullcrew: %2", _vehUnitData, _fullCrew];
		private _np = _fullCrew select 0; //Number of drivers or pilots
		private _t = (_fullCrew select 1) + (_fullCrew select 2); //Copilot and all other turrets
		private _ct = (_fullCrew select 3); //Cargo turrets
		private _c = _fullCrew select 4; //Cargo
		private _j = _i + 1;
		//Find driver if it's needed
		if(_np != 0) then
		{
			while {_j < _count} do
			{
				_unitData = (_groupUnits select _j) select 0;
				diag_log format ["_groupUnits: %1", _groupUnits];
				if(_unitData select 0 == T_INF && _unitData select 2 != -1) exitWith //Alive driver found
				{
					_infUnit = [_lo, _unitData, 0] call gar_fnc_getUnit;
					//diag_log format ["_unitData: %1, _unit: %2", _unitData, _unit];
					_unitHandle = _infUnit select 1;
					if(_assignDrivers) then
					{
						if(_spawned) then
						{
							_unitHandle assignAsDriver _vehHandle;
						};
						(_groupUnits select _j) set [1, [_vehUnitData, G_VR_driver, []]]; //Set _vehicleRole value
					};
					_allCrew pushback _unitHandle; //Add this unit to the crew array to order it to get in later.

					//_unitHandle moveInDriver _vehHandle;
					_j = _j + 1;
				};
				_j = _j + 1;
			};
		};

		//Find turret operators for each turret
		{
			while {_j < _count} do
			{
				_unitData = (_groupUnits select _j) select 0;
				if(_unitData select 0 == T_INF && _unitData select 2 != -1 && _assignTurrets) exitWith //Alive unit found
				{
					_infUnit = [_lo, _unitData] call gar_fnc_getUnit;
					_unitHandle = _infUnit select 1;
					if(_assignTurrets) then
					{
						if(_spawned) then
						{
							_unitHandle assignAsTurret [_vehHandle, _x]; //_x is the turret path
						};
						(_groupUnits select _j) set [1, [_vehUnitData, G_VR_turret, _x]]; //Set _vehicleRole value
					};
					_allCrew pushback _unitHandle; //Add this unit to the crew array to order it to get in later.
					//_unitHandle moveInTurret [_vehHandle, _x];
					_j = _j + 1;
				};
				_j = _j + 1;
			};
		} forEach _t;

		//Assign cargo turrets(FFVs)
		{
			while {_j < _count} do
			{
				_unitData = (_groupUnits select _j) select 0;
				if(_unitData select 0 == T_INF && _unitData select 2 != -1 && _assignTurrets) exitWith //Alive unit found
				{
					_infUnit = [_lo, _unitData] call gar_fnc_getUnit;
					_unitHandle = _infUnit select 1;
					if(_assignPassengers) then
					{
						if(_spawned) then
						{
							_unitHandle assignAsTurret [_vehHandle, _x]; //_x is the turret path
						};
						(_groupUnits select _j) set [1, [_vehUnitData, G_VR_cargo_turret, _x]]; //Set _vehicleRole value
					};
					_allCrew pushback _unitHandle; //Add this unit to the crew array to order it to get in later.
					//_unitHandle moveInTurret [_vehHandle, _x];
					_j = _j + 1;
				};
				_j = _j + 1;
			};
		} forEach _ct;

		//Assign cargo(non-FFV)
		private _cargoCounter = 0;
		while {_cargoCounter < _c} do
		{
			while {_j < _count} do
			{
				_unitData = (_groupUnits select _j) select 0;
				if(_unitData select 0 == T_INF && _unitData select 2 != -1 && _assignTurrets) exitWith //Alive unit found
				{
					_infUnit = [_lo, _unitData] call gar_fnc_getUnit;
					_unitHandle = _infUnit select 1;
					if(_assignPassengers) then
					{
						if(_spawned) then
						{
							_unitHandle assignAsCargo _vehHandle; //_x is the turret path
						};
						(_groupUnits select _j) set [1, [_vehUnitData, G_VR_cargo, []]]; //Set _vehicleRole value
					};
					_allCrew pushback _unitHandle; //Add this unit to the crew array to order it to get in later.
					//_unitHandle moveInTurret [_vehHandle, _x];
					_j = _j + 1;
				};
				_j = _j + 1;
			};
			_cargoCounter = _cargoCounter + 1;
		};
	};
	_i = _i + 1;
};