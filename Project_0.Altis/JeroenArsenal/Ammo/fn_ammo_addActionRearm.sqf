#include "defineCommon.inc"
/*
	Author: Jeroen Notenbomer

	Description:
	adds rearm button to object

	Parameter(s):
		Object: to add action to
		int: total amount of points that object can store
		(int): starting amount of points in object [default: 0]

	Returns:
		Nil
		
	Usage: [this,1000] call JN_fnc_ammo_addActionRearm
	
*/

params["_vehicleFrom","_rearmCargoCapacity",["_rearmCargo",0]];

//check if it already has a action
if !isnil(_vehicleFrom getVariable "rearmAction_id")exitWith{diag_log ("JN_ammo already init for object: "+str _vehicleFrom)};

pr _id = _vehicleFrom addaction [
	"",
	{
		pr _vehicleFrom = _this select 0;

		//check if object has still ammo
		pr _rearmCargo = _vehicleFrom call JN_fnc_ammo_getCargo;
		if(_rearmCargo == 0)exitWith{hint "No ammo in object"};
		
		//create select action
		pr _script =  {
			params ["_vehicleFrom"];
			
			pr _vehicleTo = cursorObject;
			["Open",[_vehicleFrom,_vehicleTo]] call JN_fnc_ammo_gui;
			pr _id = _vehicleFrom getVariable "rearmAction_id";
		};
		pr _conditionActive = {
			params ["_vehicleFrom"];
			alive player;
		};
		pr _conditionColor = {
			params ["_vehicleFrom"];
			!isnull cursorObject&&{_vehicleFrom distance cursorObject < INT_MAX_DISTANCE_TO_REREARM}
		};
					
		[_script,_conditionActive,_conditionColor,_vehicleFrom] call jn_fnc_common_addActionSelect;
	},
	[],
	4,
	true,
	false,
	"",
	"alive _target && {_target distance _this < 5} && {player == vehicle player}"
		
];
ACTION_SET_ICON_AND_TEXT(_vehicleFrom, _id, STR_ACTION_TEXT_REARM(_rearmCargo,_rearmCargoCapacity), STR_ACTION_ICON_REARM);
	

_vehicleFrom setVariable ["rearmAction_id",_id];

_vehicleFrom setAmmoCargo 0; //disable Armas shit because its broken
[_vehicleFrom, _rearmCargoCapacity]	call JN_fnc_ammo_setCargoCapacity;//call this before setting rearm value
[_vehicleFrom, _rearmCargo]			call JN_fnc_ammo_setCargo;//need actionId so we need to run it after we create the action
