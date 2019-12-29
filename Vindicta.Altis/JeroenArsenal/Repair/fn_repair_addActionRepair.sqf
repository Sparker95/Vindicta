#include "defineCommon.inc"
/*
	Author: Jeroen Notenbomer

	Description:
	adds repair button to object

	Parameter(s):
		Object: to add action to
		int: total amount of points that object can store
		(int): starting amount of points in object [default: 0]

	Returns:
		Nil
		
	Usage: [this,1000] call JN_fnc_repair_addActionRepair
	
*/

params[["_vehicle",objNull,[objNull]],["_repairCargoCapacity",0,[0]],["_repairCargo",0,[0,nil]]];

//check if it already has a action
if !isnil(_vehicle getVariable "repairAction_id")exitWith{diag_log ("JN_repair already init for object: "+str _vehicle)};

pr _id = _vehicle addaction [
	STR_ACTION_REPAIR(_repairCargo,_repairCargoCapacity),
	{
		pr _vehicle = _this select 0;

		//check if object has still repair
		pr _repairCargo = _vehicle call JN_fnc_repair_getCargo;
		if(_repairCargo == 0)exitWith{hint "No repair in object"};
		
		//create select action
		pr _script =  {
			params ["_vehicleFrom"];
			pr _vehicleTo = cursorObject;
			pr _type = _vehicleTo call JN_fnc_common_vehicle_getVehicleType;

			pr _skill_Vehicle = SKILL_REQUIRED_VEHICLE select _type;
			pr _skill = _vehicleFrom getVariable ["jn_repair_skill",1];
			pr _typeName = TYPE_VEHICLES select _type;
			if(_skill < _skill_Vehicle)exitWith{hint format["I dont know how to work on %1s",toLower _typeName]};
			
			pr _points = player call JN_fnc_repair_getCargo;
			if(_points == 0)exitWith{hint "no repair points"};
			if(_points < 10)exitWith{hint "to less points"};
			
			[_vehicleTo, player] call JN_fnc_repair_addSelectRepair;
			
			
			
			[_vehicle2,_vehicle] call JN_fnc_repair_repair;
			pr _id = _vehicle getVariable "repairAction_id";
		};
		pr _conditionActive = {
			params ["_vehicle"];
			alive player;
		};
		pr _conditionColor = {
			params ["_vehicle"];
			!isnull cursorObject&&{_vehicle distance cursorObject < INT_MAX_DISTANCE_TO_REPAIR}
		};
					
		[_script,_conditionActive,_conditionColor,_vehicle] call jn_fnc_common_addActionSelect;
	},
	[],
	4,
	true,
	false,
	"",
	"alive _target && {_target distance _this < 5} && {player == vehicle player}"
		
];
_vehicle setVariable ["repairAction_id",_id];

_vehicle setAmmoCargo 0; //disable Armas shit because its broken
[_vehicle, _repairCargoCapacity]	call JN_fnc_repair_setCargoCapacity;//call this before setting repair value
[_vehicle, _repairCargo]			call JN_fnc_repair_setCargo;//need actionId so we need to run it after we create the action


pr _id = _vehicle addaction [
	"Refill toolkit",
	{
		pr _vehicle = _this select 0;
		
		pr _pointsPlayer = player call JN_fnc_repair_getCargo;
		pr _pointsCapPlayer = player call JN_fnc_repair_getCargoCapacity;
		
		pr _pointsVehicle = _vehicle call JN_fnc_repair_getCargo;
		
		
		if(_pointsPlayer >= _pointsCapPlayer)exitWith{hint "already full"};
		if(_pointsVehicle == 0)exitWith{hint "No more points in object"};
		
		pr _amount = _pointsCapPlayer-_pointsPlayer;
		if(_amount > _pointsVehicle)then{_amount = _pointsVehicle; hint "partly refilled"}else{hint "fully refilled"};
		
		[player,_pointsPlayer+_amount] call JN_fnc_repair_setCargo;
		[_vehicle,_pointsVehicle-_amount] call JN_fnc_repair_setCargo;

	},
	[],
	5,
	true,
	false,
	"",
	"alive _target && {_target distance _this < 5} && {player == vehicle player} && {itemCargo backpackContainer player find 'ToolKit' != -1}"
		
];