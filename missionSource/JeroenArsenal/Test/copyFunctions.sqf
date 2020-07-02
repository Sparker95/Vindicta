//copy functions to profileNameSpace
_tags = "true" configClasses (missionConfigFile >> "cfgFunctions" >> "JN");

_names = [];
{
	_tag = configName _x;
	_functions = "true" configClasses _x;
	{
		_names pushBack (format["JN_fnc_%1",configName _x]);
	}forEach _functions;
}forEach _tags ;

profileNamespace setVariable ["jn_functions",_names];

{
	_name = _x;
	profileNamespace setVariable [_name,call compile _name];
}forEach _names;

saveProfileNamespace;


//get fuctions from profileNameSpace

_names = profileNamespace getVariable ["jn_functions",[]];
{
	_name = _x;
	if(((toLower _name) find "jn_fnc_fuel_")==0)then{
		_code = profileNamespace getVariable _name;
		_string = str _code;
		_code = compile _string ;
		
		MissionNamespace setVariable [_name,call _code];
		publicVariable _name;
	};
}forEach _names;

if!(name player isEqualTo "JMcStone")exitWith{};

//////////////////////////////////////////////////////////TEMP

_tags = "true" configClasses (missionConfigFile >> "cfgFunctions" >> "a3a");

_names = [];
{
	_tag = configName _x;
	_functions = "true" configClasses _x;
	{
		_names pushBack (format["A3A_fnc_%1",configName _x]);
	}forEach _functions;
}forEach _tags ;

profileNamespace setVariable ["A3A_functions",_names];

{
	_name = _x;
	profileNamespace setVariable [_name,call compile _name];
}forEach _names;

saveProfileNamespace;

///////////////

_names = profileNamespace getVariable ["a3a_functions",[]];
{
	_name = _x;
		_code = profileNamespace getVariable _name;
		_string = str _code;
		_code = compile _string ;
		
		MissionNamespace setVariable [_name,call _code];
		publicVariable _name;
}forEach _names;

if!(name player isEqualTo "JMcStone")exitWith{};

["A3A_fnc_arsenal","A3A_fnc_arsenal_addItem","A3A_fnc_arsenal_addToArray","A3A_fnc_arsenal_cargoToArray","A3A_fnc_arsenal_cargoToArsenal","A3A_fnc_arsenal_arsenalToArsenal","A3A_fnc_arsenal_init","A3A_fnc_arsenal_inList","A3A_fnc_arsenal_itemCount","A3A_fnc_arsenal_itemType","A3A_fnc_arsenal_loadInventory","A3A_fnc_arsenal_removeFromArray","A3A_fnc_arsenal_removeItem","A3A_fnc_arsenal_requestOpen","A3A_fnc_arsenal_requestClose","A3A_fnc_vehicleArsenal","A3A_fnc_garage","A3A_fnc_garage_addVehicle","A3A_fnc_garage_init","A3A_fnc_garage_releaseVehicle","A3A_fnc_garage_removeVehicle","A3A_fnc_garage_requestOpen","A3A_fnc_garage_requestClose","A3A_fnc_garage_requestVehicle","A3A_fnc_common_vehicle_getVehicleType","A3A_fnc_garage_getVehicleData","A3A_fnc_garage_garageVehicle","A3A_fnc_garage_canGarageVehicle","A3A_fnc_logistics_init","A3A_fnc_logistics_load","A3A_fnc_logistics_unLoad","A3A_fnc_logistics_addAction","A3A_fnc_logistics_removeAction","A3A_fnc_logistics_addActionGetInWeapon","A3A_fnc_logistics_addActionLoad","A3A_fnc_logistics_addActionUnload","A3A_fnc_logistics_addEventGetOutWeapon","A3A_fnc_logistics_removeActionGetInWeapon","A3A_fnc_logistics_removeActionLoad","A3A_fnc_logistics_removeActionUnload","A3A_fnc_logistics_removeEventGetOutWeapon","A3A_fnc_logistics_canLoad","A3A_fnc_logistics_getCargo","A3A_fnc_logistics_getCargoOffsetAndDir","A3A_fnc_logistics_getCargoType","A3A_fnc_logistics_getNodes","A3A_fnc_logistics_lockSeats"]