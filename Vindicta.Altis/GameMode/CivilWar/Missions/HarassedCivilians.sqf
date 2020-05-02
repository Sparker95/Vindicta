#include "..\common.hpp"

// Callback for the start of the free civilian action
pr0_fnc_StartFreeingCivilian = {
	params ["_target", "_caller", "_actionId", "_arguments"];

	// On server
	[_caller, {
		CALLSM("UndercoverMonitor", "onUnitCompromised", [_this]);
	}] remoteExec ["call", 0];

	[player, "Let me free you brother!", _target] call Dialog_fnc_hud_createSentence;
};

// Callback for the end of the free civilian action
pr0_fnc_CompleteFreeingCivilian = {
	// This is all done in its own scheduled script, as it is mostly
	// just waiting for conversation to progress.
	_this spawn {
		params ["_target", "_caller", "_actionId", "_arguments", "_progress", "_maxProgress"];

		// On server
		[_target, {
			// Untie them
			_this playMoveNow "Acts_ExecutionVictim_Unbow";
			// Make sure they don't get arrested again
			_this setVariable [UNDERCOVER_TARGET, false, false];
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

			// Make sure the civilian is allowed to move again
			_target enableAI "MOVE";
			_target enableAI "AUTOTARGET";
			_target enableAI "ANIM";
			_target setBehaviour "SAFE";

			// Run far away!
			_target call pr0_fnc_CivieRunAway;

			// Increase area activity
			CALLSM("AICommander", "addActivity", [ENEMY_SIDE ARG getPos _caller ARG (10+random(20))]);
		}] remoteExec ["call", 0];
	};
};

// Add the free action to a civilian
pr0_fnc_AddCivilianFreeAction = {
	[
		_this, "Free this civilian", "", "",
		"_this distance _target < 3",
		"_caller distance _target < 3",
		pr0_fnc_StartFreeingCivilian, {}, pr0_fnc_CompleteFreeingCivilian, {}, [], 8, 0, true, false
	] remoteExec ["BIS_fnc_holdActionAdd", 0, _this];
	//call BIS_fnc_holdActionAdd;
};

/*
Class: HarassedCiviliansAmbientMission
This mission spawns a number of civilians that police will try to arrest (when they see them).
If the player frees them after they are arrested they will provide rewards of intel, and increase local
activity.
*/
#define OOP_CLASS_NAME HarassedCiviliansAmbientMission
CLASS("HarassedCiviliansAmbientMission", "AmbientMission")
	// How many missions of this type can be running at a time.
	VARIABLE("maxActive");
	// Currently running missions of this type (as represented by the civilian units).
	VARIABLE("activeCivs");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		T_SETV("activeCivs", []);

		private _radius = GETV(_city, "boundingRadius");
		// How many civilians should be harrassed at the same time for this city size?
		private _maxActive = 1 + ((3 * ln(0.01 * _radius + 1)) min 5);
		T_SETV("maxActive", _maxActive);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		// Clean up an active missions
		private _activeCivs = T_GETV("activeCivs");
		{
			deleteVehicle _x;
		} forEach _activeCivs;
	ENDMETHOD;

	/* protected override */ METHOD(updateExisting)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		private _activeCivs = T_GETV("activeCivs");

		// Check for finished missions
		{
			_activeCivs deleteAt (_activeCivs find _x);
		} forEach (_activeCivs select { !alive _x });
	ENDMETHOD;

	/* protected override */ METHOD(spawnNew)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		// Add new missions if required
		private _activeCivs = T_GETV("activeCivs");
		private _maxActive = T_GETV("maxActive");
		private _deficit = _maxActive - (count _activeCivs);
		if(_deficit > 0) then {

			OOP_INFO_MSG("Spawning %1 civilians in %2 to be harassed", [_deficit ARG _city]);

			private _pos = ZERO_HEIGHT(CALLM0(_city, "getPos"));
			private _radius = GETV(_city, "boundingRadius");

			// Use the civ types specified in the presence module
			private _civTypes = missionNameSpace getVariable ["CivPresence_unitTypes", []];
			for "_i" from 0 to (_deficit-1) do {
				private _rndpos = [_pos, 0, _radius] call BIS_fnc_findSafePos;
				private _tmpGroup = createGroup civilian;
				private _civie = _tmpGroup createUnit [(selectRandom _civTypes), _rndpos, [], 0, "NONE"];

				// Lets apply our civ settings from selected faction template
				private _civTemplate = CALLM1(gGameMode, "getTemplate", civilian);
				private _templateClass = [_civTemplate, T_INF, T_INF_unarmed, -1] call t_fnc_select;
				if ([_templateClass] call t_fnc_isLoadout) then {
					[_civie, _templateClass] call t_fnc_setUnitLoadout;
				} else {
					OOP_ERROR_0("Only loadouts are valid for Civilian T_INF_unarmed faction templates (not classes)");
				};

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
	ENDMETHOD;
ENDCLASS;