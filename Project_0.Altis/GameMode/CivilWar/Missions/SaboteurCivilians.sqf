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
};

// This mission spawns a number of civilians with various weapons who will fight with the police.
CLASS("SaboteurCiviliansAmbientMission", "AmbientMission")
	VARIABLE("civGroups");
	VARIABLE("triggers");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];

		private _pos = CALLM0(_city, "getPos");
		private _radius = GETV(_city, "boundingRadius");

		private _civGroups = [];
		T_SETV("civGroups", _civGroups);
		private _triggers = [];
		T_SETV("triggers", _triggers);

		// Create some civilians that can do some damage!

		/// Use the civ types specified in the presence module
		private _civTypes = missionNameSpace getVariable ["CivPresence_unitTypes", []];

		private _locs = GETV(_city, "children");
		private _targetBuildings = [];
		if(count _locs > 0) then {
			{
				private _locPos = CALLM0(_x, "getPos");
				_targetBuildings = _targetBuildings + (_locPos nearObjects ["House", 30]);
			} forEach _locs;
		};
		if(_targetBuildings isEqualTo []) then {
			_targetBuildings = _pos nearObjects ["House", _radius];
		};
		if(_targetBuildings isEqualTo []) exitWith {
			OOP_ERROR_MSG("Couldn't find any targets for saboteurs in %1", [_city]);
		};

		// Separate groups for each civilian so they can do their own thing
		private _civCount = 1 + (ln(0.01 * _radius + 1) min 3);
		OOP_INFO_MSG("Spawning %1 civilians in %2 to do blow shit up!", [_civCount ARG _city]);
		for "_i" from 0 to _civCount do {
			

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
			_civGroups pushBack _grp;
			_civie call fnc_initSaboteur;

			// No attacking them for now?
			_civie setCaptive true;

			private _wp = _grp addWaypoint [_tgtPos, 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointBehaviour "STEALTH";
			_wp setWaypointSpeed "LIMITED";
			_wp setWaypointStatements ["true", "this fire ['DemoChargeMuzzle', 'DemoChargeMuzzle', 'IEDUrbanSmall_Remote_Mag']; hint 'placed bomb';"]; 

			private _hidePos = [_tgtPos, 25, 50] call BIS_fnc_findSafePos;
			private _wp = _grp addWaypoint [_hidePos, 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointBehaviour "AWARE";
			_wp setWaypointSpeed "NORMAL";
			// Enemy can shoot on sight!
			_wp setWaypointStatements ["true", "this setCaptive false; this action ['TOUCHOFF', this];"]; 

			// private _trigger = createTrigger ["EmptyDetector", _pos];
			// _trigger setTriggerArea  [15, 15, 0, false];
			// _trigger setTriggerActivation [str ENEMY_SIDE, "PRESENT", true];
			// _trigger setVariable ["owner", _civie];
			// // _owner action ['TOUCHOFF', _owner] doesn't workkkk
			// _trigger setTriggerStatements ["private _owner = thisTrigger getVariable 'owner'; unitReady _owner", "private _owner = thisTrigger getVariable 'owner'; if(alive _owner) then { private _ied = (nearestObject [thisTrigger, 'IEDUrbanSmall_Remote_Ammo']); _ied setDamage 1;}; deleteVehicle thisTrigger; hint 'blowed up bomb';", ""];
			// _triggers pushBack _trigger;
			//"_ied = (nearestObject [thisTrigger, ""IEDLandSmall_Remote_Ammo""]); _ied setDamage 1;"

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
		
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		{ { deleteVehicle _x } forEach units _x; deleteGroup _x; } forEach T_GETV("civGroups");
		{ deleteVehicle _x; } forEach T_GETV("triggers");
	} ENDMETHOD;
	
ENDCLASS;