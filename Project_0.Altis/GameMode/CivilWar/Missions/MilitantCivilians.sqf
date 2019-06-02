#include "..\common.hpp"

// This mission spawns a number of civilians with various weapons who will fight with the police.
CLASS("MilitantCiviliansAmbientMission", "AmbientMission")
	VARIABLE("civGroups");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];

		private _pos = CALLM0(_city, "getPos");
		private _radius = GETV(_city, "boundingRadius");

		// Create some civilians that can do some damage!

		/// Use the civ types specified in the presence module
		private _civTypes = missionNameSpace getVariable ["CivPresence_unitTypes", []];

		// Separate groups for each civilian so they can do their own thing
		private _civGroups = [];
		private _civCount = 1 + (2 * ln(0.01 * _radius + 1) min 10);
		OOP_INFO_MSG("Spawning %1 civilians in %2 to do some damage", [_civCount ARG _city]);
		for "_i" from 0 to _civCount do {
			private _rndpos = [_pos, 0, _radius] call BIS_fnc_findSafePos;
			private _tmpGroup = createGroup civilian;
			private _civie = _tmpGroup createUnit [(selectRandom _civTypes), _rndpos, [], 0, "NONE"];
			private _grp = createGroup [FRIENDLY_SIDE, true];
			[_civie] joinSilent _grp;
			deleteGroup _tmpGroup;
			_civGroups pushBack _grp;

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
		T_SETV("civGroups", _civGroups);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		T_PRVAR(civGroups);
		{
			{ deleteVehicle _x } forEach units _x;
			deleteGroup _x;
		} forEach _civGroups;

		T_SETV("civGroups", []);
	} ENDMETHOD;
	
ENDCLASS;