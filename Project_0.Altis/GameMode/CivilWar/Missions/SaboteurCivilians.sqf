#include "..\common.hpp"

//#define SABOTEUR_CIVILIANS_TESTING

// This sets up a saboteur with appropriate gear
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

// Called when player interacts with the saboteur. 
// They can take the explosives.
// Called on players client.
pr0_fnc_SaboteurPlayer = {
	params ["_target", "_caller", "_actionId", "_arguments"];

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

	// Spawn something because we are going to be sleeping a bit
	[_target, _caller] spawn {
		params ["_target", "_caller"];

		// "Ask" for the explosives		
		[_caller, selectRandom [
			"Can I borrow that?",
			"I have a plan, can I have that?",
			"I need that",
			"If you give me that now I will pay you back tuesday",
			"I will take it from here",
			"Don't worry, I will do it"
			], _target] call Dialog_fnc_hud_createSentence;

		sleep 2;

		// Civie always says yes...
		[_target, selectRandom [
			"Okay, don't waste it!",
			"Here you go",
			"No problem",
			"Be careful with it, I'm no explosives expert!",
			"You owe me"
			], _caller] call Dialog_fnc_hud_createSentence;

		sleep 2;
		
		// Civie drops the exposives bag (carefully I would guess).
		[_target, { 
			_this action ["PutBag"];
		}] remoteExec ["call", 2];

		sleep 2;

		// Player acknowledges
		[_caller, selectRandom [
			"Thank you!",
			"I know just where to put this...",
			"They won't know what hit them!",
			"Is this thing safe?!"
			], _target] call Dialog_fnc_hud_createSentence;
		
		sleep 2;

		// Civie says goodbye cos they are polite like that
		[_target, selectRandom [
			"Right, I am out of here!",
			"Goodbye!",
			"Good luck!",
			"Bye!",
			"I need to be somewhere else..."
			], _caller] call Dialog_fnc_hud_createSentence;

		// Civie runs off after maybe saluting
		[[_target, _caller], { 
			params ["_target", "_caller"];

			if (random 1 > 0.5) then {
				// Do the unit actions on the server
				_target lookAt _caller;
				_target action ["Salute", _target];
				sleep 2;
			};

			_target call pr0_fnc_CivieRunAway;
		}] remoteExec ["spawn", 2];
	};
};

/*
Class: SaboteurCiviliansAmbientMission
This mission spawns a number of civilians with IEDs who will try and blow up various buildings near the police station.
TODO:
    Make them choose targets better, they should try and blow up police vehicles, the police station, the police themselves!
    Allow them to set traps for police, roadside bombs, blow up incoming reinforcements etc.
*/
CLASS("SaboteurCiviliansAmbientMission", "AmbientMission")
	// Selection of target buildings remaining.
	VARIABLE("targetBuildings");
	// Max number of saboteurs that can be active at one time.
	VARIABLE("maxActive");
	// The active saboteurs.
	VARIABLE("activeCivs");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		T_SETV("activeCivs", []);

		private _pos = CALLM0(_city, "getPos");
		private _radius = GETV(_city, "boundingRadius");

		// Calcuate some target buildings.
		private _locs = GETV(_city, "children");
		private _targetBuildings = [];
		if(count _locs > 0) then {
			{
				private _locPos = CALLM0(_x, "getPos");
				_targetBuildings = _targetBuildings + (_locPos nearObjects ["House", 50]) - (_locPos nearObjects ["House", 10]);
			} forEach _locs;
		};
		// If we didn't find any then just select some nearby houses without qualification
		if(_targetBuildings isEqualTo []) then {
			_targetBuildings = _pos nearObjects ["House", _radius];
		};
		// We still couldn't find a nearby building? Where the hell is this police station?
		if(_targetBuildings isEqualTo []) exitWith {
			OOP_ERROR_MSG("Couldn't find any targets for saboteurs in %1", [_city]);
		};
		T_SETV("targetBuildings", _targetBuildings);

#ifdef SABOTEUR_CIVILIANS_TESTING
		// This should be interesting!
		private _maxActive = 15;
#else
		// Don't want many of these guys
		private _maxActive = 1; //1 + (ln(0.01 * _radius + 1) min 1); // Probably that's too many already
#endif
		T_SETV("maxActive", _maxActive);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		// Clean up an active missions
		{ 
			_x params ["_civie", "_trigger"];
			deleteVehicle _civie;
			deleteVehicle _trigger;
		} forEach T_GETV("activeCivs");
	} ENDMETHOD;

#ifdef SABOTEUR_CIVILIANS_TESTING
	// Make it always active mission if we are testing
	/* override */ METHOD("isActive") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		true
	} ENDMETHOD;
#endif

	// Called from base class update function, regardless of if the mission is active,
	// because we might need to cleanup some missions that were ongoing.
	/* protected override */ METHOD("updateExisting") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city"), P_BOOL("_active")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		// Check for finished actions
		T_PRVAR(activeCivs);
		{
			_x params ["_civie", "_trigger"];
			if(!alive _civie) then {
				deleteVehicle _trigger;
				_activeCivs deleteAt (_activeCivs find _x);
			} else {
				// If this mission type shouldn't be active anymore then just send the civies away
				if(!_active) then {
					_civie call pr0_fnc_CivieRunAway;
				};
			};
		} forEach +_activeCivs;
	} ENDMETHOD;
	
	// Called from base class update function, when the mission is active
	/* protected virtual */ METHOD("spawnNew") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		// Add new actions if don't have enough active already
		T_PRVAR(activeCivs);
		T_PRVAR(maxActive);
		private _deficit = _maxActive - (count _activeCivs);
		if(_deficit > 0) then {
			OOP_INFO_MSG("Spawning %1 civilians in %2 to blow shit up!", [_deficit ARG _city]);
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

				// Get starting point for the civ
				private _rndpos = [_pos, 0, _radius] call BIS_fnc_findSafePos;
				private _tmpGroup = createGroup civilian;
				private _civie = _tmpGroup createUnit [(selectRandom _civTypes), _rndpos, [], 0, "NONE"];
				private _grp = createGroup [FRIENDLY_SIDE, true];
				[_civie] joinSilent _grp;
				deleteGroup _tmpGroup;
				_civie call fnc_initSaboteur;

				// Add action to recruit them to your squad
				[
					_civie,
					["Can I borrow that?", pr0_fnc_SaboteurPlayer, [], 1.5, false, true, "", "true", 10]
				] remoteExec ["addAction", 0, _civie];

				// No enemy attacking them for now?
				_civie setCaptive true;

				// WAYPOINT 1 - plant bomb
				private _wp = _grp addWaypoint [_tgtPos, 0];
				_wp setWaypointType "MOVE";
				_wp setWaypointBehaviour "STEALTH";
				_wp setWaypointSpeed "LIMITED";
				_wp setWaypointStatements ["true", 
					format["
						this fire ['DemoChargeMuzzle', 'DemoChargeMuzzle', 'IEDUrbanSmall_Remote_Mag'];
						this setVariable ['%1', true];
						[this] remoteExec ['removeAllActions', 0, this];
						",
						UNDERCOVER_SUSPICIOUS]
				];

				// WAYPOINT 2 - hide
				private _hidePos = [_tgtPos, 50, 75] call BIS_fnc_findSafePos;
				private _wp = _grp addWaypoint [_hidePos, 0];
				_wp setWaypointType "MOVE";
				_wp setWaypointBehaviour "AWARE";
				_wp setWaypointSpeed "NORMAL";
				// Enemy can shoot on sight!
				_wp setWaypointStatements ["true", "this setCaptive false;"];

				// WAYPOINT 3 - wait
				// Wait until blowed up the bomb
				private _wp = _grp addWaypoint [_hidePos, 0];
				_wp setWaypointType "MOVE";
				_wp setWaypointBehaviour "AWARE";
				_wp setWaypointSpeed "NORMAL";
				_wp setWaypointStatements ["this getVariable ['bombed', false]", ""]; 

				// WAYPOINT 4 - run away!
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

ENDCLASS;