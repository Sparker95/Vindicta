#include "..\common.hpp"

fnc_initSaboteur =
{
	comment "Exported from Arsenal by billw";

	comment "[!] UNIT MUST BE LOCAL [!]";
	if (!local _this) exitWith {};

	comment "Remove existing items";
	removeAllWeapons _this;
	removeAllItems _this;
	removeAllAssignedItems _this;
	removeUniform _this;
	removeVest _this;
	removeBackpack _this;
	removeHeadgear _this;
	removeGoggles _this;

	comment "Add containers";
	_this forceAddUniform "U_C_Poloshirt_salmon";
	_this addBackpack "B_AssaultPack_blk";
	_this addItemToBackpack "IEDLandSmall_Remote_Mag";
	_this addItemToBackpack "IEDUrbanSmall_Remote_Mag";
	_this addHeadgear "H_Bandanna_gry";

	comment "Add weapons";

	comment "Add items";
	_this linkItem "ItemMap";
	_this linkItem "ItemCompass";
	_this linkItem "ItemWatch";
	_this linkItem "ItemRadio";

	comment "Set identity";
	[_this,"GreekHead_A3_09","male02gre"] call BIS_fnc_setIdentity;

	_this allowFleeing 0; // brave?
};

// This mission spawns a number of civilians with various weapons who will fight with the police.
CLASS("SaboteurCiviliansAmbientMission", "AmbientMission")
	VARIABLE("targetBuildings");
	VARIABLE("maxActive");
	VARIABLE("activeCivs");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		T_SETV("activeCivs", []);


		private _pos = CALLM0(_city, "getPos");
		private _radius = GETV(_city, "boundingRadius");

		private _locs = GETV(_city, "children");
		private _targetBuildings = [];
		if(count _locs > 0) then {
			{
				private _locPos = CALLM0(_x, "getPos");
				_targetBuildings = _targetBuildings + (_locPos nearObjects ["House", 50]) - (_locPos nearObjects ["House", 10]);
			} forEach _locs;
		};
		if(_targetBuildings isEqualTo []) then {
			_targetBuildings = _pos nearObjects ["House", _radius];
		};
		if(_targetBuildings isEqualTo []) exitWith {
			OOP_ERROR_MSG("Couldn't find any targets for saboteurs in %1", [_city]);
		};
		T_SETV("targetBuildings", _targetBuildings);

		// Separate groups for each civilian so they can do their own thing
		private _maxActive = 1 + (ln(0.01 * _radius + 1) min 1);
		T_SETV("maxActive", _maxActive);
	} ENDMETHOD;

	METHOD("updateExisting") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		// Check for finished actions
		T_PRVAR(activeCivs);
		{
			_x params ["_civie", "_trigger"];
			if(!alive _civie) then {
				deleteVehicle _trigger;
				_activeCivs deleteAt (_activeCivs find _x);
			};
		} forEach +_activeCivs;
	} ENDMETHOD;
	
	METHOD("spawnNew") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		// Add new actions if required
		T_PRVAR(activeCivs);
		T_PRVAR(maxActive);
		private _deficit = _maxActive - (count _activeCivs);
		if(_deficit > 0) then {

			OOP_INFO_MSG("Spawning %1 civilians in %2 to do blow shit up!", [_deficit ARG _city]);
			private _pos = CALLM0(_city, "getPos");
			private _radius = GETV(_city, "boundingRadius");

			T_PRVAR(targetBuildings);

			// Use the civ types specified in the presence module
			private _civTypes = missionNameSpace getVariable ["CivPresence_unitTypes", []];

			for "_i" from 0 to (_deficit-1) do {
				// Find a target
				private _tgtPos = [];
				
				{
					private _positions = _x buildingPos -1;
					if(count _positions > 0) exitWith {
						_tgtPos = _positions#0;
					};
				} forEach (_targetBuildings call BIS_fnc_arrayShuffle);
				
				if(_tgtPos isEqualTo []) exitWith {
					OOP_ERROR_MSG("Couldn't find a target for a saboteurs in %1", [_city]);
				};

				private _rndpos = [_pos, 0, _radius] call BIS_fnc_findSafePos;
				private _tmpGroup = createGroup civilian;
				private _civie = _tmpGroup createUnit [(selectRandom _civTypes), _rndpos, [], 0, "NONE"];
				private _grp = createGroup [FRIENDLY_SIDE, true];
				[_civie] joinSilent _grp;
				deleteGroup _tmpGroup;
				_civie call fnc_initSaboteur;

				// No attacking them for now?
				_civie setCaptive true;

				private _wp = _grp addWaypoint [_tgtPos, 0];
				_wp setWaypointType "MOVE";
				_wp setWaypointBehaviour "STEALTH";
				_wp setWaypointSpeed "LIMITED";
				_wp setWaypointStatements ["true", 
					format[
						"this fire ['DemoChargeMuzzle', 'DemoChargeMuzzle', 'IEDUrbanSmall_Remote_Mag']; 
						_civie setVariable ['%1', true];",
						UNDERCOVER_SUSPICIOUS]
				]; 

				private _hidePos = [_tgtPos, 50, 75] call BIS_fnc_findSafePos;
				private _wp = _grp addWaypoint [_hidePos, 0];
				_wp setWaypointType "MOVE";
				_wp setWaypointBehaviour "AWARE";
				_wp setWaypointSpeed "NORMAL";
				// Enemy can shoot on sight!
				_wp setWaypointStatements ["true", "this setCaptive false;"];

				// Wait until blowed up the bomb
				private _wp = _grp addWaypoint [_hidePos, 0];
				_wp setWaypointType "MOVE";
				_wp setWaypointBehaviour "AWARE";
				_wp setWaypointSpeed "NORMAL";
				_wp setWaypointStatements ["this getVariable ['bombed', false]", ""]; 

				// Run far away!
				private _wp = _grp addWaypoint [[_tgtPos, 1000, 2000] call BIS_fnc_findSafePos, 0];
				_wp setWaypointType "MOVE";
				_wp setWaypointBehaviour "AWARE";
				_wp setWaypointSpeed "NORMAL";
				_wp setWaypointStatements ["true", "deleteVehicle this;"];

				private _trigger = createTrigger ["EmptyDetector", _pos];
				_trigger setTriggerArea  [5, 5, 0, false];
				_trigger setTriggerActivation [str ENEMY_SIDE, "PRESENT", true];
				_trigger setVariable ["owner", _civie];

				_trigger setTriggerStatements ["
					private _owner = thisTrigger getVariable 'owner';
					alive _owner && {!(captive _owner)}
					",
					"private _owner = thisTrigger getVariable 'owner'; 
					if(alive _owner) then {
						systemChat format['%1 is alive, detonating now!', _owner];
						_owner action ['TOUCHOFF', _owner];
						_owner setVariable ['bombed', true];
					};
					deleteVehicle thisTrigger;",
					""];

				_activeCivs pushBack [_civie, _trigger];

				// "_ied = (nearestObject [thisTrigger, ""IEDLandSmall_Remote_Ammo""]); _ied setDamage 1;"
				// private _ied = (nearestObject [thisTrigger, 'IEDUrbanSmall_Remote_Ammo']); 
				// _ied setDamage 1;

				// for "_j" from 0 to 5 do {
				// 	private _wp = _grp addWaypoint [_pos, _radius];
				// 	_wp setWaypointCompletionRadius 20;
				// 	_wp setWaypointType "MOVE";
				// 	_wp setWaypointBehaviour "STEALTH";
				// 	if(_j == 0) then { _grp setCurrentWaypoint _wp; }
				// };

				// // Create a cycle waypoint
				// private _wpCycle = _grp addWaypoint [waypointPosition [_grp, 0], 0];
				// _wpCycle setWaypointType "CYCLE";
			};
		};
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		{ 
			_x params ["_civie", "_trigger"];
			deleteVehicle _civie;
			deleteVehicle _trigger;
		} forEach T_GETV("activeCivs");
	} ENDMETHOD;
	
ENDCLASS;