#include "..\common.hpp"

//#define MILITANT_CIVILIANS_TESTING

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

		};
	} else {
		[_target, "You are too many already, we must be inconspicuous!", _caller] call Dialog_fnc_hud_createSentence;
	};
};

/*
Class: MilitantCiviliansAmbientMission
This mission spawns a number of civilians with various weapons who will fight with the police.
*/
CLASS("MilitantCiviliansAmbientMission", "AmbientMission")
	// Max number of militants that can be active at one time.
	VARIABLE("maxActive");
	// The active militants.
	VARIABLE("activeCivs");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		T_SETV("activeCivs", []);

		private _radius = GETV(_city, "boundingRadius");

#ifdef MILITANT_CIVILIANS_TESTING
		private _maxActive = 15;
#else
		// Number of active militants relates to city size
		private _maxActive = 1 + ((2 * ln(0.01 * _radius + 1)) min 5);
#endif
		T_SETV("maxActive", _maxActive);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		// Clean up an active missions
		T_PRVAR(activeCivs);
		{
			deleteVehicle _x;
		} forEach _activeCivs;
	} ENDMETHOD;

#ifdef MILITANT_CIVILIANS_TESTING
	// Make it always active mission if we are testing
	METHOD("isActive") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		true
	} ENDMETHOD;
#endif

	/* protected override */ METHOD("updateExisting") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		// Check for finished actions
		T_PRVAR(activeCivs);
		{
			_activeCivs deleteAt (_activeCivs find _x);
		} forEach (_activeCivs select { !alive _x });
	} ENDMETHOD;

	/* protected override */ METHOD("spawnNew") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		// Add new actions if required
		T_PRVAR(activeCivs);
		T_PRVAR(maxActive);
		private _deficit = _maxActive - (count _activeCivs);
		if(_deficit > 0) then {
			OOP_INFO_MSG("Spawning %1 civilians in %2 to do some damage", [_deficit ARG _city]);

			// Create some civilians that can do some damage!
			private _pos = POS_TO_ATL(CALLM0(_city, "getPos"));
			private _radius = GETV(_city, "boundingRadius");

			/// Use the civ types specified in the presence module
			private _civTypes = missionNameSpace getVariable ["CivPresence_unitTypes", []];

			// Separate groups for each civilian so they can do their own thing
			for "_i" from 0 to (_deficit-1) do {
				private _rndpos = [_pos, 0, _radius] call BIS_fnc_findSafePos;
				private _tmpGroup = createGroup civilian;
				private _civie = _tmpGroup createUnit [(selectRandom _civTypes), _rndpos, [], 0, "NONE"];
				private _grp = createGroup [FRIENDLY_SIDE, true];
				[_civie] joinSilent _grp;
				deleteGroup _tmpGroup;
				_activeCivs pushBack _civie;

				for "_j" from 1 to 5 do {_civie addItemToUniform "16Rnd_9x21_Mag";};
				_civie addHeadgear "H_Bandanna_khk";
				comment "Add weapons";
				_civie addWeapon "hgun_P07_F";

				// Add action to recruit them to your squad
				[
					_civie, 
					["Join me brother!", pr0_fnc_CivilianJoinPlayer, [], 1.5, false, true, "", "true", 10]
				] remoteExec ["addAction", 0, _civie];

				// Add some random waypoints
				for "_j" from 0 to 5 do {
					private _wp = _grp addWaypoint [_pos, _radius];
					_wp setWaypointCompletionRadius 20;
					_wp setWaypointType "MOVE";
					_wp setWaypointBehaviour "STEALTH";
					if(_j == 0) then { _grp setCurrentWaypoint _wp; }
				};

				// Create a cycle waypoint
				private _wpCycle = _grp addWaypoint [waypointPosition [_grp, 0], 0];
				_wpCycle setWaypointType "CYCLE";
			};
		};
	} ENDMETHOD;
	
ENDCLASS;