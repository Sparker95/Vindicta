#include "defineCommon.inc"

/*
	Author: Jeroen Notenbomer

	Description:
	refuel vehicle with objects fuelCargo.
	used by addActionRefuel

	Parameter(s):
	_object: object to refuel
	_object: object to refuel from
	
	Returns:

	
*/
_this spawn {
	params[["_vehicleTo",objNull,[objNull]], ["_vehicleFrom",objNull,[objNull]]];

	if(_vehicleTo distance _vehicleFrom > INT_MAX_DISTANCE_TO_REFUEL)exitwith{hint "vehicle to far away"};

	//check if objects are in use by other players
	if(!isNil {_vehicleTo getVariable "refuelAction_inUse"})exitWith{hint "Vehicle is already being refueld"};
	if(!isNil {_vehicleFrom getVariable "refuelAction_inUse"})exitWith{hint "Object in use"};

	
	//check the options we have where fuel needs to go to and select one
	pr _cargoCapacity = _vehicleTo  call jn_fnc_fuel_getCargoCapacity;
	pr _capacity = _vehicleTo call jn_fnc_fuel_getCapacity;

	if(_cargoCapacity == 0 && {_capacity == 0})exitWith{hint "cant refuel vehicle"};

	pr _hasBoth = (_cargoCapacity != 0 && {_capacity != 0});
	pr "_anserMsg";
	if _hasBoth then{
		if(_vehicleTo isEqualTo _vehicleFrom)then{
			_anserMsg = true
		}else{
			_anserMsg = [
				localize "STR_JN_FUEL_ACT_REFUELOPTION", localize "STR_JN_FUEL_ACT_REFUEL", localize "STR_JN_FUEL_ACT_FUELTANK", localize "STR_JN_FUEL_ACT_FUELCARGO"
			] call BIS_fnc_guiMessage;
		};
	};
		
	//exit when object is for example a fuelstation
	if(_vehicleTo isEqualTo _vehicleFrom && !_hasBoth)exitwith{hint "object has no fuel tank"};
		
	if(isNil "_anserMsg")then{
		_anserMsg = (_cargoCapacity == 0);
	};


	pr _get = 		[jn_fnc_fuel_getCargo, jn_fnc_fuel_get] select _anserMsg;
	pr _set = 		[jn_fnc_fuel_setCargo, jn_fnc_fuel_set] select _anserMsg;
			_capacity = [_cargoCapacity, _capacity] select _anserMsg;

	pr _amount = _vehicleTo call _get;
	pr _amountFrom = _vehicleFrom call jn_fnc_fuel_getCargo;

	//check if tank is already full
	if(_capacity == _amount)exitwith{hint "vehicle is already full"};

	//all checks are done vehicle can be refueled
	
	//disable refuel for other players
	_vehicleTo setVariable ["refuelAction_inUse",name player,true];
	_vehicleFrom setVariable ["refuelAction_inUse",name player,true];
	
	pr _completeRefuel = true;
	
	pr _refuelAmount = _capacity - _amount; //required for full refuel

	if(_refuelAmount > _amountFrom)then{_refuelAmount= _amountFrom;_completeRefuel = false;};

	[player,{}] call JN_fnc_common_addActionCancel;
	
	//0L 10sec 10000L 60sec
	pr _delta = round( (FLOAT_REFUELINTERVAL*_capacity)/(10+(40*_capacity/10000))) + 1;

	while{_refuelAmount > 0}do{
		if (player call JN_fnc_common_getActionCanceled)exitWith{};
		
		//update
		
		if(_delta > _refuelAmount)then{_delta = _refuelAmount};
		_refuelAmount = _refuelAmount - _delta;
		
		[_vehicleTo,(_vehicleTo call _get)+_delta] call _set;
		[_vehicleFrom,(_vehicleFrom call jn_fnc_fuel_getCargo)-_delta] call jn_fnc_fuel_setCargo;
		[player,("(" + str round(((_vehicleTo call _get)/ _capacity)*100) +"%)")] call JN_fnc_common_updateActionCancel;
		sleep FLOAT_REFUELINTERVAL;
	};
	
	//update Global
	[_vehicleTo,(_vehicleTo call _get),true] call _set;
	[_vehicleFrom,(_vehicleFrom call jn_fnc_fuel_getCargo),true] call jn_fnc_fuel_setCargo;
	
	//message
	if(player call JN_fnc_common_getActionCanceled)then{
		hint "Refuel canceled";
	}else{
		if(_completeRefuel)then{
			hint "Vehicle refueled";
		}else{
			hint "Object ran out of fuel"
		};
	};
	
	//cleanup
	player call JN_fnc_common_removeActionCancel;
	_vehicleTo setVariable ["refuelAction_inUse",nil,true];
	_vehicleFrom setVariable ["refuelAction_inUse",nil,true];
	

};//spawn