/*
Function: misc_fnc_getCargoInfantryCapacity
Returns how many units can be loaded as cargo by all the vehicles from _veh

Parameters: _veh

_vehArray - a single vehicle/vehicle classname OR an array of vehicles or vehicle classnames

Returns: Number
*/

private _vehArray = _this;

if(!(_vehArray isEqualType [])) then
{
	_vehArray = [_vehArray];
};


//Now we consider only loading of infantry
private _nCargoSeats = 0;
for "_i" from 0 to ((count _vehArray) - 1) do
{
	private _veh = _vehArray select _i;
	
	
	if (_veh isEqualType objNull) then {_veh = typeOf _veh};
	
	private _vehCfg = configFile >> "CfgVehicles" >> _veh;
	
	private _psgTurrets = [_veh, 0, 1] call misc_fnc_getTurrets;
	
	private _n_cargo = getNumber (_vehCfg >> "transportSoldier");
	
	// diag_log format ["%1 %2 turrets %3 cargo seats", _veh, (count _psgTurrets), _n_cargo];
	_nCargoSeats = _nCargoSeats + (count _psgTurrets) + _n_cargo;
};

_nCargoSeats