#include "..\common.hpp"

#define LOOTING_RANGE 250

#ifdef MILITANT_CIVILIANS_TESTING
#define LOG_MILITANT systemChat format
#else
#define LOG_MILITANT __null = 
#endif

// Called on client
pr0_fnc_CivilianJoinPlayer = {
	params ["_target", "_caller", "_actionId", "_arguments"];

	private _grp = group _caller;

	// Only allow up to 5 in player group
	if(count units _grp < 5) then {
		// Remove the action on all the clients
		[[_target, _actionId], { 
			params ["_target", "_actionId"];
			_target removeAction _actionId;
		}] remoteExec ["call"];

		// Do the unit actions on the server
		[[_target, _caller], { 
			params ["_target", "_caller"];
			doStop _target;
			_target lookAt _caller;
		}] remoteExec ["call", 2];

		[_target, _caller] spawn {
			params ["_target", "_caller"];

			[_caller, selectRandom [
				"Join us brother!",
				"The revolution needs you!",
				"I need your help",
				"Follow me!",
				"We should work together"
				], _target] call Dialog_fnc_hud_createSentence;

			sleep 2;

			if(alive _target) then {
				[_target, selectRandom [
					"I will follow you! Onward!",
					"Lead the way!",
					"Together we will be stronger!",
					"Okay",
					"What are we waiting for?"
					], _caller] call Dialog_fnc_hud_createSentence;

				// Join on server
				[[_target, _caller, clientOwner], {
					params ["_target", "_caller", "_clientOwner"];

					if (random 1 > 0.5) then {
						// Do the unit actions on the server
						_target lookAt _caller;
						_target action ["Salute", _target];
						sleep 2;
					};

					private _otherUnits = units group _caller - [_caller];
					[_target] join group _caller;

					{
						sleep random [0, 0.5, 1];
						[[_x, _target], {
							params ["_unit", "_target"];
							_unit lookAt _target;
							[_unit, selectRandom [
								"Welcome brother!",
								"Another for the cause!",
								"Hi",
								"...",
								"Do you have any spare bullets?",
								"Hi neighbour!"
							], _target] call Dialog_fnc_hud_createSentence;
						}] remoteExec ["call", _clientOwner];
					} foreach _otherUnits;

					// _target stop false;
				}] remoteExec ["spawn", 2];
			} else {
				[_target, selectRandom [
					"(...)",
					"(bleeds)",
					"(maybe they are sleeping?)",
					"(looks so peaceful)",
					"(NNNNNNNOOOOOOOOOOOOOOOOOOO!!!!!!)",
					"(he's dead Jim!)",
					"(refuses the call)",
					"(has other problems)",
					"(doesn't appear to be listening)",
					"(has already given everything)",
					"(will be missed)",
					"(ashes to ashes)",
					"(looks pale)"
					], _caller] call Dialog_fnc_hud_createSentence;
			};
		};
	} else {
		[_target, "You are too many already, we must be inconspicuous!", _caller] call Dialog_fnc_hud_createSentence;
	};
};

pr0_fnc_generateRandomPath = {
	params ["_pos", "_radius", "_grp"];
	
	if(leader _grp in allPlayers) exitWith {
		// Don't give waypoints to player group
		false
	};

	// Add some random waypoints
	for "_j" from 0 to 5 do {
		private _wp = _grp addWaypoint [_pos, _radius];
		_wp setWaypointCompletionRadius 20;
		_wp setWaypointType "MOVE";
		_wp setWaypointTimeout [0, 30, 60];
		//_wp setWaypointBehaviour "STEALTH";
		if(_j == 0) then { _grp setCurrentWaypoint _wp; }
	};

	// Create a cycle waypoint at last wp
	private _wpCycle = _grp addWaypoint [waypointPosition [_grp, 5], 0];
	_wpCycle setWaypointType "CYCLE";

	true
};

#define BUSY_TAG "vin_militant_busy"
#define USAGE_TAG "vin_militant_use"

// TODO: generalize this BS inventory stuff
// pr0_fnc_findSource = {
// 	params ["_pos", "_range", "_predFn", "_tag"];
// 	// All inventories
// 	private _obj = (nearestObjects [_this, ["WeaponHolderSimulated", "GroundWeaponHolder", "WeaponHolder"], _range]) + (allDead select {_x distance _pos < _range}) apply {
// 		[_x distance _pos, _x]
// 	};
// 	_obj sort ASCENDING;
// 	_obj = _obj apply {
// 		private _src = _x#1;
// 		private _gear = _src call _predFn;
// 		[_src, _gear]
// 	} select {
// 		// Not all already allocated
// 		count (_x#1) > _x#0 getVariable [USAGE_TAG + _tag, 0]
// 	}
// };

pr0_fnc_selectPrimaryWeapon = {
	if ( (primaryWeapon _this) != "") then
	{
		private _type = primaryWeapon _this;
		// check for multiple muzzles (eg: GL)
		private _muzzles = getArray(configFile >> "cfgWeapons" >> _type >> "muzzles");
		if (count _muzzles > 1) then
		{
			_this selectWeapon (_muzzles select 0);
		}
		else
		{
			_this selectWeapon _type;
		};
	};
};

pr0_fnc_doMoveTimeout = {
	params ["_unit", "_tgt", "_range"];
	private _timeout = GAME_TIME + 60;
	LOG_MILITANT ["%1 moving to %2", name _unit, mapGridPosition _tgt];
	_unit stop false;
	private _lastTgtPos = position _tgt;
	_unit doMove _lastTgtPos;
	private _ledByPlayer = leader _unit in allPlayers;
	private _nextRetarget = GAME_TIME + 5;
	waitUntil {
		sleep 1;

		if(_lastTgtPos distance _tgt > 0 && GAME_TIME > _nextRetarget) then {
			_lastTgtPos = position _tgt;
			_unit doMove _lastTgtPos;
			_nextRetarget = GAME_TIME + 5;
		};

		if(isNull _unit || {!alive _unit}) exitWith {
			LOG_MILITANT ["%1 failed to move to %2: %1 died", name _unit, mapGridPosition _tgt];
			true
		};
		if(isNull _tgt) exitWith {
			LOG_MILITANT ["%1 failed to move to target: target became invalid", name _unit];
			true
		};
		if(_unit distance _tgt <= _range) exitWith {
			LOG_MILITANT ["%1 moved to %2 successfully", name _unit, mapGridPosition _tgt];
			true
		};
		if(GAME_TIME > _timeout) exitWith {
			LOG_MILITANT ["%1 failed to move to %2: timeout", name _unit, mapGridPosition _tgt];
			true
		};
		if(!_ledByPlayer && {leader _unit in allPlayers}) exitWith {
			LOG_MILITANT ["%1 failed to move to %2: now led by player", name _unit, mapGridPosition _tgt];
			true
		};
		false
	};
	!isNull _unit && {alive _unit} && {!isNull _tgt} && {_unit distance _tgt <= _range}
};

pr0_fnc_militantFindWeapon = {
	private _lootRange = if(leader _this in allPlayers) then { 25 } else { LOOTING_RANGE };
	private _sourcesWithWeapons = (nearestObjects [_this, ["WeaponHolderSimulated", "GroundWeaponHolder", "WeaponHolder"], _lootRange]) apply {
		private _src = _x;
		private _weapons = weaponCargo _src select {
			getNumber( configFile >> "CfgWeapons" >> _x >> "type" ) == 1 // primary weapon type
		};
		[_src, _weapons]
	} select {
		// Not all already allocated
		count (_x#1) > _x#0 getVariable [USAGE_TAG, 0]
	};

	if(count _sourcesWithWeapons > 0) then {
		_sourcesWithWeapons#0 params ["_src", "_weapons"];
		LOG_MILITANT ["%1: rearming at %2", name _this, mapGridPosition _src];
		_this setVariable [BUSY_TAG, true];
		_src setVariable [USAGE_TAG, (_src getVariable [USAGE_TAG, 0]) + 1];

		[_this, _src] spawn {
			params ["_civ", "_src"];
			if([_civ, _src, 3] call pr0_fnc_doMoveTimeout) then {
				doStop _civ;

				private _weapons = weaponCargo _src apply {
					[_x, getNumber( configFile >> "CfgWeapons" >> _x >> "type" )]
				} select {
					_x#1 == 1 // primary weapon type
				} apply {
					_x#0
				};
				if(count _weapons > 0) then {
					private _newWeapon = _weapons#0;
					_civ action ["TakeWeapon", _src, _newWeapon];
					sleep 3;
					_civ action ["rearm", _src];
					sleep 3;
					_civ call pr0_fnc_selectPrimaryWeapon;
					sleep 3;
					LOG_MILITANT ["%1: rearmed with a %2!", name _civ, getText (configfile >> "cfgweapons" >> _newWeapon >> "displayName")];
				};
			};
			if(!isNull _civ) then {
				_civ setVariable [BUSY_TAG, false];
				[_civ] doFollow leader group _civ;
			};
			if(!isNull _src) then {
				_src setVariable [USAGE_TAG, (_src getVariable [USAGE_TAG, 0]) - 1];
			};
		};
		true
	} else {
		false
	}
};

pr0_fnc_militantFindVest = {
	private _lootRange = if(leader _this in allPlayers) then { 25 } else { LOOTING_RANGE };
	private _vestHP = if(vest _this == "") then { -1 } else { getNumber (configfile >> "CfgWeapons" >> vest _this >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Chest" >> "armor") };
	private _obj = allDead select {
		_x distance _this < _lootRange 
		&& {vest _x != ""}
		&& {getNumber (configfile >> "CfgWeapons" >> vest _x >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Chest" >> "armor") > _vestHP}
		&& {!(_x getVariable [USAGE_TAG + "vest", false])}
	} apply {
		[getNumber (configfile >> "CfgWeapons" >> vest _x >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Chest" >> "armor"), _x distance _this, _x]
	};
	_obj sort ASCENDING;
	private _sourcesWithVests = _obj apply {
		_x#2
	};

	if(count _sourcesWithVests > 0) then {
		private _src = _sourcesWithVests#0;
		LOG_MILITANT ["%1: taking vest from %2", name _this, mapGridPosition _src];
		_this setVariable [BUSY_TAG, true];
		_src setVariable [USAGE_TAG + "vest", true];

		[_this, _src] spawn {
			params ["_civ", "_src"];
			if([_civ, _src, 3] call pr0_fnc_doMoveTimeout) then {
				doStop _civ;

				private _vest = vest _src;
				if(_vest != "") then {
					private _srcItems = vestItems _src;
					_civ addVest _vest;
					{_civ addItemToVest _x} forEach _srcItems;
					_civ action ["rearm", _src];
					removeVest _src;
					LOG_MILITANT ["%1: took a %2 vest!", name _civ, getText (configfile >> "cfgweapons" >> _vest >> "displayName")];
				};
				private _headgear = headgear _src;
				if(_headgear != "") then {
					_civ addHeadgear _headgear;
					removeHeadgear _src;
					LOG_MILITANT ["%1: took a %2 helmet!", name _civ, getText (configfile >> "cfgweapons" >> _headgear >> "displayName")];
				};
			};
			if(!isNull _civ) then {
				_civ setVariable [BUSY_TAG, false];
				[_civ] doFollow leader group _civ;
			};
			if(!isNull _src) then {
				_src setVariable [USAGE_TAG + "vest", false];
			};
		};
		true
	} else {
		false
	}
};

pr0_fnc_findLeader = {
	params ["_civ", "_allCivs"];
	if(units group _civ findIf { _x in allPlayers } != NOT_FOUND) exitWith {
		// Already in a player group
		false
	};
	private _civGroupSize = count units group _civ;
	if(_civGroupSize >= 3) exitWith {
		// Group is big enough
		false
	};
	// Find groups
	private _groups = [];
	{ _groups pushBackUnique group _x; } forEach _allCivs;
	_groups = _groups apply {
		[count units _x, _x]
	} select {
		!(leader (_x#1) in allPlayers) // no player led group
		&& {_x#0 > _civGroupSize && _x#0 < 3} // bigger groups only
	};
	_groups sort DESCENDING;
	if(count _groups == 0) exitWith {
		// No groups
		false
	};

	private _bestGroup = _groups#0#1;
	LOG_MILITANT ["%1: joining a group led by %2", name _civ, name leader _bestGroup];
	[_civ] joinSilent _bestGroup;
	true
};

pr0_fnc_givePlayerIntel = {
	params ["_civ", "_newIntel"];

	if(count _newIntel == 0) exitWith {
		false
	};

	private _players = allPlayers select {
		_x distance _civ < 100 && !(_x getVariable [USAGE_TAG + "intel", false])
	} apply {
		[_x distance _civ, _x]
	};

	_players sort ASCENDING;
	_players = _players apply { _x#1 };

	if(count _players > 0) then {
		private _tgt = _players#0;
		private _intel = selectRandom _newIntel;

		LOG_MILITANT ["%1: giving intel %2 to %3", name _civ, CALLM0(_intel, "getShortName"), name _tgt];
		_civ setVariable [BUSY_TAG, true];

		[_civ, _tgt, _intel] spawn {
			params ["_civ", "_tgt", "_intel"];
			if([_civ, _tgt, 3] call pr0_fnc_doMoveTimeout) then {
				doStop _civ;
				_civ lookAt _tgt;

				[_civ, selectRandom [
					"I must tell you something!",
					"There was news while you were away.",
					"Sometimes I hear things...",
					"They are planing something!",
					"Please, you must know something..."
				], _tgt]  remoteExec ["Dialog_fnc_hud_createSentence", _tgt, false];
				sleep 2;

				[_civ, format [ selectRandom [
					"I overheard mention of %1 in the area.",
					"There may be %1 near here!",
					"%1 is planned by the enemy.",
					"The enemy is planning %1!"
				], CALLM0(_intel, "getShortName")], _tgt]  remoteExec ["Dialog_fnc_hud_createSentence", _tgt, false];
				sleep 2;

				CALLSM1("AICommander", "revealIntelToPlayerSide", _intel);
				sleep 2;

				[_civ, selectRandom [
					"I must leave now.",
					"I must be going, they are looking for us!",
					"Its best not to be seen together.",
					"I will keep my ears open.",
					"Come back later, I might know more..."
				], _tgt]  remoteExec ["Dialog_fnc_hud_createSentence", _tgt, false];

				_civ lookAt _tgt;
				_civ action ["Salute", _civ];

				sleep 4;

				[_civ] doFollow leader group _civ;
			};
			if(!isNull _civ) then {
				_civ setVariable [BUSY_TAG, false];
			};
		};
		true
	} else {
		false
	}
};

/*
Class: MilitantCiviliansAmbientMission
This mission spawns a number of civilians with various weapons who will fight with the police.
*/
#define OOP_CLASS_NAME MilitantCiviliansAmbientMission
CLASS("MilitantCiviliansAmbientMission", "AmbientMission")
	// The active militants.
	VARIABLE("activeCivs");
	VARIABLE("nextInformant");
	VARIABLE("nextIntelUpdate");
	VARIABLE("newIntel");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		T_SETV("activeCivs", []);
		T_SETV("nextInformant", GAME_TIME);
		T_SETV("nextIntelUpdate", GAME_TIME);
		T_SETV("newIntel", []);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		// Clean up an active missions
		private _activeCivs = T_GETV("activeCivs");
		{
			deleteVehicle _x;
		} forEach _activeCivs;
	ENDMETHOD;

#ifdef MILITANT_CIVILIANS_TESTING
	// Make it always active mission if we are testing
	METHOD(isActive)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		true
	ENDMETHOD;
#endif

	/* protected override */ METHOD(updateExisting)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		// Check for dead civs
		private _activeCivs = T_GETV("activeCivs");
		{
			_activeCivs deleteAt (_activeCivs find _x);
		} forEach (_activeCivs select { !alive _x });

		private _pos = ZERO_HEIGHT(CALLM0(_city, "getPos"));
		private _radius = GETV(_city, "boundingRadius");

		private _cityData = GETV(_city, "gameModeData");
		private _instability = GETV(_cityData, "instability");

		// Refresh intel if stale
		if(GAME_TIME > T_GETV("nextIntelUpdate")) then
		{
			T_SETV("nextIntelUpdate", GAME_TIME + 120);
			// Lets find out if we have some intel for the player that they don't have already
			private _civGarr = CALLM1(_city, "getGarrisons", civilian) select 0;
			if(!isNil "_civGarr") then {
				private _playerSide = CALLM0(gGameMode, "getPlayerSide");
				private _AI = CALLM0(_civGarr, "getAI");
				private _allIntel = CALLM0(_AI, "getAllGeneralIntel");
				private _newIntel = CALLSM2("AICommander", "filterOutKnownIntel", _allIntel, _playerSide);
				T_SETV("newIntel", _newIntel);
			};
		};

		// Alive civs can do some things
		{
			private _civ = _x;
			private _ledByPlayer = leader _civ in allPlayers;
			switch true do {
				// Look for a primary weapon once instab is getting higher
				case ((_instability > 0.35 || _ledByPlayer)
					&& {primaryWeapon _civ == ""}
					&& {_civ call pr0_fnc_militantFindWeapon}): {
					// continue
				};

				// Look for a vest and helmet
				case ((_instability > 0.5 || _ledByPlayer)
					&& {_civ call pr0_fnc_militantFindVest}): {
					// continue
				};

				// Find a leader
				case (_instability > 0.65 
					&& !_ledByPlayer
					&& {[_civ, _activeCivs] call pr0_fnc_findLeader}): {
					// continue
				};

				case (GAME_TIME >= T_GETV("nextInformant") 
					&& !_ledByPlayer
					&& {[_civ, T_GETV("newIntel")] call pr0_fnc_givePlayerIntel}): {
					// continue
					#ifdef MILITANT_CIVILIANS_TESTING
					private _nextInformant = GAME_TIME + 30;
					#else
					private _nextInformant = GAME_TIME + random [150, 300, 450];
					#endif
					T_SETV("nextInformant", _nextInformant);
				};

				// Run around randomly when not busy with other things
				case (!_ledByPlayer 
					&& {count waypoints group _civ == 1}
					&& {[_pos, _radius * 0.5, group _civ] call pr0_fnc_generateRandomPath}): {
					// continue;
				};
			};

			// other stuff they could do can go here
		} forEach (_activeCivs select {
			// Not already busy
			!(_x getVariable [BUSY_TAG, false])
		});

	ENDMETHOD;

	/* protected override */ METHOD(spawnNew)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		// Add new actions if required
		private _activeCivs = T_GETV("activeCivs");

		private _radius = GETV(_city, "boundingRadius");
		private _cityData = GETV(_city, "gameModeData");
		private _instability = GETV(_cityData, "instability");

#ifdef MILITANT_CIVILIANS_TESTING
		private _maxActive = 10;
#else
		// Number of active militants relates to city size and instability
		// https://www.desmos.com/calculator/9v3zy6zn1v
		private _maxActive = ceil (2 + (2 + 3 * _instability) * ((0.002 * _radius) ^ 2));
#endif

		private _deficit = _maxActive - (count _activeCivs);
		if(_deficit > 0) then {
			OOP_INFO_MSG("Spawning %1 civilians in %2 to do some damage", [_deficit ARG _city]);

			// Create some civilians that can do some damage!
			private _pos = ZERO_HEIGHT(CALLM0(_city, "getPos"));
			private _radius = GETV(_city, "boundingRadius");

			/// Use the civ types specified in the presence module
			private _civTypes = missionNameSpace getVariable ["CivPresence_unitTypes", []];

			// Separate groups for each civilian so they can do their own thing
			for "_i" from 0 to (_deficit-1) do {
				private _rndpos = [_pos, 0, _radius] call BIS_fnc_findSafePos;
				private _tmpGroup = createGroup civilian;
				private _civie = _tmpGroup createUnit [(selectRandom _civTypes), _rndpos, [], 0, "NONE"];
				// Lets apply our civ settings from selected faction template
				private _civTemplate = CALLM1(gGameMode, "getTemplate", civilian);
				private _templateClass = [_civTemplate, T_INF, T_INF_survivor, -1] call t_fnc_select;
				if ([_templateClass] call t_fnc_isLoadout) then {
					[_civie, _templateClass] call t_fnc_setUnitLoadout;
				} else {
					OOP_ERROR_0("Only loadouts are valid for Civilian T_INF_survivor faction templates (not classes)");
				};
				private _grp = createGroup [FRIENDLY_SIDE, true];
				[_civie] joinSilent _grp;
				deleteGroup _tmpGroup;
				_activeCivs pushBack _civie;

				// Set unit skill
				_civie setSkill ["aimingAccuracy", 0.3];
				_civie setSkill ["aimingShake", 0.3];
				_civie setSkill ["aimingSpeed", 0.4];
				_civie setSkill ["commanding", 0.2];
				_civie setSkill ["courage", 1];
				//_civie setSkill ["endurance", 0.8];
				_civie setSkill ["general", 0.5];
				_civie setSkill ["reloadSpeed", 0.5];
				_civie setSkill ["spotDistance", 0.6];
				_civie setSkill ["spotTime", 0.3];

				_grp allowFleeing 0; // brave?
				_grp setFormation "FILE";
				_civie disableAI "AUTOCOMBAT";
				_grp setBehaviour "COMBAT";

				[_pos, _radius * 0.5, _grp] call pr0_fnc_generateRandomPath;

				// Add action to recruit them to your squad
				[
					_civie, 
					["Join me brother!", pr0_fnc_CivilianJoinPlayer, [], 1.5, false, true, "", "true", 10]
				] remoteExec ["addAction", 0, _civie];
			};
		};
	ENDMETHOD;
	
ENDCLASS;