// init function thats runned from inside the addon config

params[["_vehicle",objNull,[objNull]]];

private _jn_fuel_capacity = getNumber(configfile >> "CfgVehicles" >> typeOf _vehicle>> "jn_fuel_capacity");
private _jn_fuel_cargoCapacity = getNumber(configfile >> "CfgVehicles" >> typeOf _vehicle>> "jn_fuel_cargoCapacity");

if(_jn_fuel_capacity > 0)then{
	[_vehicle,_jn_fuel_capacity] call JN_fnc_fuel_setCapacity;
	//set fuel starting condition
	_vehicle setFuel random [0.3, 0.6, 0.9];
};

if(_jn_fuel_cargoCapacity > 0)then{
	[_vehicle,_jn_fuel_cargoCapacity,round random[0,0.6*_jn_fuel_cargoCapacity,_jn_fuel_cargoCapacity]] call jn_fnc_fuel_addActionRefuel;
};
