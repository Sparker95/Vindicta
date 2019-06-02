#include "..\common.hpp"

// fnc_RecruitCivilian = {
// 	player addAction ["Talk to civilian", // title
//                  "cursorObject spawn CivPresence_fnc_talkTo", // Script
//                  0, // Arguments
//                  9000, // Priority
//                  true, // ShowWindow
//                  false, //hideOnUse
//                  "", //shortcut
//                  "call pr0_fnc_talkCond", //condition
//                  2, //radius
//                  false, //unconscious
//                  "", //selection
//                  ""]; //memoryPoint
// };

// This mission spawns a number of civilians with various weapons who will fight with the police.
CLASS("MilitantCiviliansAmbientMission", "AmbientMission")
	VARIABLE("maxActive");
	VARIABLE("activeCivs");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		T_SETV("activeCivs", []);

		private _radius = GETV(_city, "boundingRadius");

		private _maxActive = 1 + ((2 * ln(0.01 * _radius + 1)) min 5);
		T_SETV("maxActive", _maxActive);
	} ENDMETHOD;

	METHOD("update") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		T_PRVAR(activeCivs);

		// Check for finished actions
		{
			_activeCivs deleteAt (_activeCivs find _x);
		} forEach (_activeCivs select { !alive _x });
		
		T_PRVAR(maxActive);
		private _deficit = _maxActive - (count _activeCivs);
		if(_deficit > 0) then {
			OOP_INFO_MSG("Spawning %1 civilians in %2 to do some damage", [_deficit ARG _city]);

			// Create some civilians that can do some damage!
			private _pos = CALLM0(_city, "getPos");
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
	
	METHOD("delete") {
		params [P_THISOBJECT];

		T_PRVAR(activeCivs);
		{
			deleteVehicle _x;
		} forEach _activeCivs;
	} ENDMETHOD;
	
ENDCLASS;