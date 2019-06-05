#include "..\common.hpp"

pr0_fnc_StartFreeingCivilian = {
	params ["_target", "_caller", "_actionId", "_arguments"];

	// On server
	[_caller, {
		CALLSM("UndercoverMonitor", "onUnitCompromised", [_this]);
	}] remoteExec ["call", 0];

	[player, "Let me free you brother!", _target] call Dialog_fnc_hud_createSentence;
};

pr0_fnc_FreeCivilianAnim = {
	_this playMoveNow "Acts_ExecutionVictim_Unbow";
};

pr0_fnc_CompleteFreeingCivilian = {
	_this spawn {
		params ["_target", "_caller", "_actionId", "_arguments", "_progress", "_maxProgress"];

		// On server
		[_target, {
			// Untie them
			_this playMoveNow "Acts_ExecutionVictim_Unbow";
			// Make sure they don't get arrested again
			_this  setVariable [UNDERCOVER_TARGET, false, false];
		}] remoteExec ["call", 0];

		[player, "There you go, tell your friends of what transpired here today!", _target] call Dialog_fnc_hud_createSentence;
		sleep 5;

		// Intel reward for player
		[_target, "Thank you! One of those thugs dropped this, perhaps it is of interest to you.", player] call Dialog_fnc_hud_createSentence;
		sleep 6;
		// CALLSM("UnitIntel", "initObject", [_caller ARG 1]);

		[player, "(You take the papers handed to you)", _target] call Dialog_fnc_hud_createSentence;
		sleep 3;
		[player, "Thank you, you should get out of here now, more will be coming.", _target] call Dialog_fnc_hud_createSentence;
		sleep 5;
		[_target, "I will, and you should go carefully aswell, they will be looking for you now!", player] call Dialog_fnc_hud_createSentence;
		sleep 5;

		systemChat "The enemy has taken note of the increased activity in this area!";

		// On server
		[[_target, _caller], {
			params ["_target", "_caller"];

			_target enableAI "MOVE";
			_target enableAI "AUTOTARGET";
			_target enableAI "ANIM";							
			_target setBehaviour "SAFE";

			// Run far away!
			private _wp = group _target addWaypoint [[getPos _target, 1000, 2000] call BIS_fnc_findSafePos, 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointBehaviour "AWARE";
			_wp setWaypointSpeed "NORMAL";

			// Delete the civie once he escapes
			_wp setWaypointStatements ["true", "deleteVehicle this;"];

			// Increase area activity
			CALLSM("AICommander", "addActivity", [ENEMY_SIDE ARG getPos _caller ARG (10+random(20))]);
		}] remoteExec ["call", 0];
	};
};

pr0_fnc_AddCivilianFreeAction = {
	[
		_this, "Free this civilian", "", "",
		"_this distance _target < 3",
		"_caller distance _target < 3",
		pr0_fnc_StartFreeingCivilian, {}, pr0_fnc_CompleteFreeingCivilian, {}, [], 8, 0, true, false
	] remoteExec ["BIS_fnc_holdActionAdd", 0, _this];
	//call BIS_fnc_holdActionAdd;
};

// This mission spawns a number of civilians that police will try to arrest (when they see them).
// If the player frees them after they are arrested they will provide rewards of intel, and increase local
// activity.
CLASS("HarassedCiviliansAmbientMission", "AmbientMission")
	VARIABLE("maxActive");
	VARIABLE("activeCivs");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		T_SETV("activeCivs", []);

		private _radius = GETV(_city, "boundingRadius");

		private _maxActive = 1 + ((3 * ln(0.01 * _radius + 1)) min 5);
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

			OOP_INFO_MSG("Spawning %1 civilians in %2 to be harassed", [_deficit ARG _city]);

			private _pos = CALLM0(_city, "getPos");
			private _radius = GETV(_city, "boundingRadius");

			// Use the civ types specified in the presence module
			private _civTypes = missionNameSpace getVariable ["CivPresence_unitTypes", []];
			for "_i" from 0 to (_deficit-1) do {
				private _rndpos = [_pos, 0, _radius] call BIS_fnc_findSafePos;
				private _tmpGroup = createGroup civilian;
				private _civie = _tmpGroup createUnit [(selectRandom _civTypes), _rndpos, [], 0, "NONE"];
				private _grp = createGroup [FRIENDLY_SIDE, true];
				[_civie] joinSilent _grp;
				deleteGroup _tmpGroup;
				// Make sure police will arrest the civilian
				_civie setVariable [UNDERCOVER_SUSPICIOUS, true];
				_activeCivs pushBack _civie;

				// Add some random waypoints
				for "_j" from 0 to 5 do {
					private _wp = _grp addWaypoint [_pos, _radius];
					_wp setWaypointCompletionRadius 20;
					_wp setWaypointType "MOVE";
					_wp setWaypointBehaviour "SAFE";
					_wp setWaypointSpeed "LIMITED";
					if(_j == 0) then { _grp setCurrentWaypoint _wp; }
				};

				// Create a cycle waypoint
				private _wpCycle = _grp addWaypoint [waypointPosition [_grp, 1], 0];
				_wpCycle setWaypointType "CYCLE";
				// We don't want the police shooting the civilian
				_civie setCaptive true;

				_civie spawn {
					// Wait until the civie dies or is arrested.
					waitUntil { !alive _this or {_this getVariable ["timeArrested", -1] != -1} };

					// If they died then exit
					if(!alive _this) exitWith {};

					// Unit is arrested, so add the appropriate action to free them
					_this call pr0_fnc_AddCivilianFreeAction;
				}
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