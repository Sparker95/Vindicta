/*
This function decides which units to take for a mission.
Return value: array with unitData of units to take for a mission, or empty array if units can't be allocated.
*/

#include "mission.hpp"

#define DEBUG
#define ANTI_SOFT_MIN 4

params ["_mo", "_gar"];

private _mType = _mo getVariable "AI_m_type";
private _mRequirements = _mo getVariable "AI_m_requirements";
private _mParams = _mo getVariable "AI_m_params";
private _score = 0;
private _unitsPlanned = [];

#ifdef DEBUG
diag_log "== Allocate units was called!";
#endif

switch (_mType) do {
	case "SAD": {
		#ifdef DEBUG
		diag_log "== SAD mission type was detected!";
		#endif

		_mRequirements params ["_effReq"]; // "_clusterStruct"];
		_mParams params ["_target", "_searchRadius"];
		//Make an array with all units and their efficiencies
		private _unitEffArray = []; //Array of [0:_number, 1:_effVector, 2:_unitData]
		//Find infantry
		private _infGroupIDs = [];
		_infGroupIDs append ([_gar, G_GT_idle] call gar_fnc_findGroups);
		_infGroupIDs append ([_gar, G_GT_patrol] call gar_fnc_findGroups);
		for "_i" from 0 to ((count _infGroupIDs) - 1) do {
			private _aliveUnits = [_gar, _infGroupIDs select _i] call gar_fnc_getGroupAliveUnits;
			_unitEffArray append (_aliveUnits apply {[0, _x call T_fnc_getEfficiency, _x]});
		};
		//Find vehicles but don't add their crew
		private _vehGroupIDs = [_gar, G_GT_veh_non_static] call gar_fnc_findGroups;
		for "_i" from 0 to ((count _vehGroupIDs) - 1) do {
			private _aliveUnits = [_gar, _vehGroupIDs select _i] call gar_fnc_getGroupAliveUnits;
			_aliveUnits = _aliveUnits select {_x select 0 == T_veh}; //Select only vehicles
			_unitEffArray append (_aliveUnits apply {[0, _x call T_fnc_getEfficiency, _x]});
		};
		private _eff = T_EFF_null;
		private _nInfPlanned = 0; //Amount of infantry units assigned
		
		#ifdef DEBUG
		diag_log format ["== available units: %1", _unitEffArray];
		#endif
		
		//==== Check air and anti-air ====
		//todo
		
		//==== Check armor and anti-armor ====
		private _effReqAArmor = _effReq select T_EFF_armor;
		private _effAArmor = _eff select T_EFF_aArmor;
		if (_effReqAArmor > 0) then {
			//Sort units by their efficiency against armor
			_unitEffArray = _unitEffArray apply {[_x select 1 select T_EFF_aArmor, _x select 1, _x select 2]};
			_unitEffArray sort false; //Descending
			private _c = count _unitEffArray;
			while {(count _unitEffArray > 0) && (_effAArmor < _effReqAArmor)} do {
				private _e = _unitEffArray select 0 select 0;
				if (_e == 0 ) exitWith {}; //If efficiency is zero, exit the loop
				private _ud = _unitEffArray select 0 select 2; //unitdata
				_unitsPlanned pushBack (_ud); //Add the unit to the list
				if (_ud select 0 == T_INF) then { //Increase the infantry counter
					_nInfPlanned = _nInfPlanned + 1;
				};
				_effAArmor = _effAArmor + _e;
				_eff = [_eff, _unitEffArray select 0 select 1] call BIS_fnc_vectorAdd;
				_unitEffArray deleteAt 0; //Delete unit from the array (to not take units twice)
			};
		};
		#ifdef DEBUG
		diag_log format ["== Added a-armor: %1", _unitsPlanned];
		#endif
		//Check if the requirements are satisfied
		if (_effAArmor < _effReqAArmor) exitWith {
			_unitsPlanned = [];
			#ifdef DEBUG
			diag_log "== Anti-armor requirement not satisfied!";
			#endif
		};
		
		//==== Check medium and anti-medium ====
		private _effReqAMedium = _effReq select T_EFF_medium;
		private _effAMedium = _eff select T_EFF_aMedium;
		if (_effReqAMedium > 0) then {
			//Sort units by their efficiency against armor
			_unitEffArray = _unitEffArray apply {[_x select 1 select T_EFF_aMedium, _x select 1, _x select 2]};
			_unitEffArray sort false; //Descending
			while {( count _unitEffArray > 0) && _effAMedium < _effReqAMedium} do {
				private _e = _unitEffArray select 0 select 0;
				if (_e == 0 ) exitWith {}; //If efficiency is zero, exit the loop
				private _ud = _unitEffArray select 0 select 2; //unitdata
				_unitsPlanned pushBack (_ud); //Add the unit to the list
				if (_ud select 0 == T_INF) then { //Increase the infantry counter
					_nInfPlanned = _nInfPlanned + 1;
				};
				_effAMedium = _effAMedium + _e;
				_eff = [_eff, _unitEffArray select 0 select 1] call BIS_fnc_vectorAdd;
				_unitEffArray deleteAt 0; //Delete unit from the array (to not take units twice)
			};
		};
		#ifdef DEBUG
		diag_log format ["== Added a-medium: %1", _unitsPlanned];
		#endif
		//Check if the requirements are satisfied
		if (_effAMedium < _effReqAMedium) exitWith {
			_unitsPlanned = [];
			#ifdef DEBUG
			diag_log "== Anti-medium requirement not satisfied!";
			#endif
		};
		
		//==== Check soft and anti-soft ====
		private _effReqASoft = _effReq select T_EFF_soft;
		//Minimum amount of anti-infantry to be used
		if (_effReqASoft < ANTI_SOFT_MIN && _effReqAArmor == 0 && _effReqAMedium == 0) then {
			_effReqASoft = ANTI_SOFT_MIN;
		};
		private _effASoft = _eff select T_EFF_aSoft;
		if (_effReqASoft > 0) then {
			//Sort units by their efficiency against armor
			_unitEffArray = _unitEffArray apply {[_x select 1 select T_EFF_aSoft, _x select 1, _x select 2]};
			_unitEffArray sort true; //Ascending
			while {( count _unitEffArray > 0) && _effASoft < _effReqASoft} do {
				private _e = _unitEffArray select 0 select 0;
				//if (_e == 0 ) exitWith {}; //If efficiency is zero, exit the loop
				if (_e > 0) then {
					private _ud = _unitEffArray select 0 select 2; //unitdata
					_unitsPlanned pushBack _ud; //Add the unit to the list
					if (_ud select 0 == T_INF) then { //Increase the infantry counter
						_nInfPlanned = _nInfPlanned + 1;
					};
					_effASoft = _effASoft + _e;
					_eff = [_eff, _unitEffArray select 0 select 1] call BIS_fnc_vectorAdd;
					_unitEffArray deleteAt 0; //Delete unit from the array (to not take units twice)
				};
			};
		};
		#ifdef DEBUG
		diag_log format ["== Added a-soft: %1", _unitsPlanned];
		#endif
		//Check if the requirements are satisfied
		if (_effASoft < _effReqASoft) exitWith {
			_unitsPlanned = [];
			#ifdef DEBUG
			diag_log "== Anti-soft requirement not satisfied!";
			#endif
		};
		
		//==== Find transport for infantry if needed ====
		if ((_gar distance _target) > (_searchRadius + DISTANCE_DISMOUNT)) then {
			//Find capacity of already added vehicles
			private _cargoInfCapacity = 0;
			{
				private _classname = [_gar, _x] call gar_fnc_getUnitClassname;
				_cargoInfCapacity = _cargoInfCapacity + (_classname call misc_fnc_getCargoInfantryCapacity);
			} forEach (_unitsPlanned select {_x select 0 == T_veh});
			//Do we need more vehicles?
			private _noTransport = false;
			if (_cargoInfCapacity < _nInfPlanned) then {
				//Find more vehicles
				_cargoInfCapacityExtra = _nInfPlanned - _cargoInfCapacity; //How many extra cargo seats needed
				private _fv = ([_gar, T_VEH, -1] call gar_fnc_findUnits) - _unitsPlanned; //Free vehicles
				private _fvArray = _fv apply {[([_gar, _x] call gar_fnc_getUnitClassName) call misc_fnc_getCargoInfantryCapacity, _x]}; //[_number, _cargoCapacity, _unitData]
				//Can the extra vehicles carry the infantry?
				private _fvCapacity = 0;
				for "_i" from 0 to ((count _fvArray) - 1) do	{
					_fvCapacity = _fvCapacity + (_fvArray select _i select 0);
				};
				if (_fvCapacity < _cargoInfCapacityExtra) then {
					_unitsPlanned = [];
				} else {
					_fvArray sort false; //Descending
					while {_cargoInfCapacityExtra > 0 && (count _fvArray > 0)} do {
						//Find vehicles that can fully cover the extra needed capacity
						private _fvEnoughCapacity = _fvArray select {_x select 0 > _cargoInfCapacityExtra};
						if (count _fvEnoughCapacity == 0) then {
							//If there are no such vehicles, take the one with biggest cargo capacity
							_cargoInfCapacityExtra = _cargoInfCapacityExtra - (_fvArray select 0 select 0);
							_unitsPlanned pushBack (_fvArray select 0 select 1);
							_fvArray deleteAt 0;
						} else {
							//If there are vehicles that can fully carry infantry, select the one with minimum capacity
							_fvEnoughCapacity sort true; //Ascending
							_cargoInfCapacityExtra = _cargoInfCapacityExtra - (_fvEnoughCapacity select 0 select 0);
							_unitsPlanned pushBack (_fvEnoughCapacity select 0 select 1);
							_fvEnoughCapacity deleteAt 0;
						};
					};
					if (_cargoInfCapacityExtra > 0) then {
						_unitsPlanned = [];
					};
				};
			};
		};
	};
};

#ifdef DEBUG
diag_log format ["== Returning: %1", _unitsPlanned];
#endif

//Return
_unitsPlanned

/*
T_EFF_soft =	0;
T_EFF_medium =	1;
T_EFF_armor =	2;
T_EFF_air =		3;
T_EFF_aSoft =	4;
T_EFF_aMedium =	5;
T_EFF_aArmor =	6;
T_EFF_aAir =	7;
*/