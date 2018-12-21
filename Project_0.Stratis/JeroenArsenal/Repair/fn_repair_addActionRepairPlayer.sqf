#include "defineCommon.inc"
/*
	Author: Jeroen Notenbomer

	Description:
	adds repair action to player (local)

	Parameter(s):
		(int): repair skill of player [default: 0.1]

	Returns:
		Nil
		
	Usage: [this,0.5] call JN_fnc_repair_addActionRepairPlayer
	
*/
params [["_skill",0.1]];
player setVariable ["jn_repair_skill",_skill];

//disable armas repair script
player setUnitTrait ["engineer",false,true];

//reinit
uiNamespace setVariable ['jn_repair_draw3d',nil];
pr _id = player getVariable "repairAction_id";
if(isnil "_id")then{player removeAction _id};

_id = player addaction [
	"",
	{
		private _vehicle = cursorObject;
		
		pr _type = _vehicle call JN_fnc_common_vehicle_getVehicleType;

		pr _skill_Vehicle = SKILL_REQUIRED_VEHICLE select _type;
		pr _skill = player getVariable ["jn_repair_skill",1];
		pr _typeName = TYPE_VEHICLES select _type;
		if(_skill < _skill_Vehicle)exitWith{hint format["I dont know how to work on %1s",toLower _typeName]};
		
		pr _points = player call JN_fnc_repair_getCargo;
		if(_points == 0)exitWith{hint "no repair points"};
		if(_points < 10)exitWith{hint "to less points"};
		
		[_vehicle, player] call JN_fnc_repair_addSelectRepair;
		
	},
	[],
	10,
	true,
	false,
	"",
	"if(alive player && {player distance cursorObject < 5} && {player == vehicle player} && {isNil {uiNamespace getVariable 'jn_repair_draw3d'}} && {cursorObject isKindOf 'AllVehicles'})then{
		player setUserActionText [(player getVariable ['repairAction_id',-1]), 'Repair ' + getText(configfile >> 'CfgVehicles' >> typeof cursorObject >>'displayName')];
		true;
	}"
		
];
player setVariable ["repairAction_id",_id];

