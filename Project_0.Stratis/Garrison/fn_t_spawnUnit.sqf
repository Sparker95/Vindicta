/*
Used inside the thread to spawn one unit.
First the unit's assigned group is checked. If it's not created with createGroup, it's created here.
*/

//todo Remove _pos parameter, it's not needed

params ["_lo", "_pos", "_unitData"];

//Get the unit, check if it exists
private _unit = [_lo, _unitData] call gar_fnc_getUnit;

//diag_log format ["Spawning unit: unitData: %1, unit: %2", _unitData, _unit];

if(_unit isEqualTO []) exitWIth //Error: unit with this ID not found
{
	diag_log format ["fn_t_spawnUnit.sqf: garrison: %1, unit not found: %2", _lo getVariable ["g_name", ""], _unitData];
};

//Get unit's group, check if it exists
private _groupID = _unit select 3;
private _group = [];
private _groupUnits = [];
if(_groupID != -1) then //Only vehicles can be created without a group
{
	_group = [_lo, _groupID] call gar_fnc_getGroup;
	_groupUnits = _group select 0;
};

if(_group isEqualTo [] && _groupID != -1) exitWIth
{
	diag_log format ["fn_t_spawnUnit.sqf: garrison: %1, error: unit's group not found: %2", _lo getVariable ["g_name", ""], _groupID];
};

private _catID = _unitData select 0;
private _subcatID = _unitData select 1;
private _unitID = _unitData select 2;

//If unit's group exists but wasn't created it, create it now
private _groupHandle = grpNull;
private _groupType = G_GT_idle; //Default group type if the unit isn't assigned to a group
private _firstInGroup = false; //If the unit is the first one to spawn from its group
if(_groupID != -1) then
{
	_groupHandle = _group select 1;
	private _side = _lo getVariable ["g_side", WEST];
	if((_groupHandle isEqualTo grpNull) && (_catID != T_VEH)) then //Don't createGroup if it's a vehicle
	{
		_groupHandle = createGroup [_side, true];
		_group set [1, _groupHandle];
		_firstInGroup = true;
		//_groupHandle enableDynamicSimulation true; //todo dynamic simulation
		//Set variables to this group
		_groupHandle setVariable ["g_garrison", _lo, false];
		_groupHandle setVariable ["g_groupID", _groupID, false];
		_groupHandle setVariable ["g_group", _group, false];
	};
	_groupType = _group select 3;
};

//Get unit's classname
private _class = _unit select 0;
//Create unit

private _objectHandle = objNull;
//Create the unit
private _spawnPosAndDir = [0, 0, 0, 0];
private _spawnPos = [0, 0, 0];
private _direction = 0;
private _locationObject = objNull;
switch(_catID) do
{
	case T_INF:
	{
		//diag_log format ["Creating infantry %1", _unitData];
		if(_groupType == G_GT_patrol && !_firstInGroup) then //If it's a patrol, spawn the unit near its leader, if there is a leader already
		{
			_spawnPos = (getPos (leader _groupHandle)) vectorAdd [-10 + (random (20)), -10 + (random (20)), 0];
			_direction = 0;
		}
		else //Otherwise request a pre-defined position
		{
			_locationObject = _lo getVariable ["g_location", objNull];
			//diag_log format ["Associated location of the garrison: %1", _locationObject];
			_spawnPosAndDir = [_locationObject, _catID, _subcatID, _class, _groupType] call loc_fnc_getSpawnPosition;
			_spawnPos = _spawnPosAndDir select [0, 3]; //Because it also returens the direction as 4th element inside the array
			_direction = _spawnPosAndDir select 3;
		};
		_objectHandle = _groupHandle createUnit [_class, _spawnPos, [], 10, "FORM"];
		[_objectHandle] joinSilent _groupHandle; //To force the unit join this side

		if(_groupType == G_GT_building_sentry) then //todo find a better way to do it
		{
			doStop _objectHandle;
			_objectHandle disableAI "PATH";
			_objectHandle setUnitPos "UP"; //Force him to not sit or lay down
		};

		//Assign unit's vehicle role
		//todo move it to another function?
		private _unitData2 = _groupUnits select {(_x select 0) isEqualTo _unitData};
		private _vehicleRole = _unitData2 select 0 select 1;
		if(!(_vehicleRole isEqualTo [])) then //If unit is assigned to any vehicle
		{
			private _vehData = _vehicleRole select 0;
			private _role = _vehicleRole select 1;
			private _turretPath = _vehicleRole select 2;
			private _vehData = [_lo, _vehData, 0] call gar_fnc_getUnit;
			if(!(_vehData isEqualTo [])) then //If the vehicle this unit is assigned to exists
			{
				private _vehHandle = _vehData select 1;
				switch (_role) do
				{
					case G_VR_driver:
					{
						_objectHandle assignAsDriver _vehHandle;
					};
					case G_VR_turret:
					{
						_objectHandle assignAsTurret [_vehHandle, _turretPath];
					};
					case G_VR_cargo_turret:
					{
						_objectHandle assignAsTurret [_vehHandle, _turretPath];
					};
					case G_VR_cargo:
					{
						_objectHandle assignAsCargo _vehHandle;
					};
				};
			};
		};
	};
	case T_VEH:
	{
		_locationObject = _lo getVariable ["g_location", objNull];
		//diag_log format ["Associated location of the garrison: %1", _locationObject];
		_spawnPosAndDir = [_locationObject, _catID, _subcatID, _class, _groupType] call loc_fnc_getSpawnPosition;
		_spawnPos = _spawnPosAndDir select [0, 3]; //Because it also returns the direction as 4th element inside the array
		_direction = _spawnPosAndDir select 3;
		//_objectHandle = _class createVehicle _spawnPos;
		_objectHandle = createVehicle [_class, _spawnPos, [], 0, "can_collide"];
		_objectHandle allowDamage false;
		[_objectHandle] spawn {sleep 1; (_this select 0) allowDamage true;};
	};
};
_objectHandle setDir _direction;
_objectHandle setPos _spawnPos;
//todo dynamic simulation
//_objectHandle enableDynamicSimulation true;



//Set unit's parameters in garrison array
_unit set [1, _objectHandle];
//Set unit's variables
_objectHandle setVariable ["g_garrison", _lo, false]; //The garrison this unit is associtiated with
_objectHandle setVariable ["g_unitData", [_catID, _subCatID, _unitID]];
//Add unit's event handlers
_objectHandle addEventHandler ["killed", gar_fnc_EH_killed];
if(_catID == T_INF) then
{
	_objectHandle addEventHandler ["HandleDamage", gar_fnc_EH_handleDamage];
};

//diag_log format ["Spawned unit: %1 %2 %3", _unit, _class, _groupHandle];

//sleep 0.8;