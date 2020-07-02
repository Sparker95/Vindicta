#include "..\common.hpp"

#ifndef RELEASE_BUILD
// #define SABOTEUR_CIVILIANS_TESTING
#endif

#ifdef SABOTEUR_CIVILIANS_TESTING
Saboteur_fnc_drawDebugMarkers = 
{
	params ["_positions", "_name", "_color"];
	{
		private _mrk = format["SabTgt %1 #%2", _name, _forEachIndex];
		deleteMarker _mrk;
		createMarker[_mrk, _x];
		_mrk setMarkerPos _x;
		_mrk setMarkerText _mrk;
		_mrk setMarkerShape "ICON";
		_mrk setMarkerType "hd_dot";
		_mrk setMarkerColor _color;
		_mrk setMarkerAlpha 0.7;
	} forEach _positions;
};
#endif

// This sets up a saboteur with appropriate gear
Saboteur_fnc_initSaboteur =
{
	// Lets apply our civ settings from selected faction template
	private _civTemplate = CALLM1(gGameMode, "getTemplate", civilian);
	private _templateClass = [_civTemplate, T_INF, T_INF_exp, -1] call t_fnc_select;
	if ([_templateClass] call t_fnc_isLoadout) then {
		[_this, _templateClass] call t_fnc_setUnitLoadout;
	} else {
		OOP_ERROR_0("Only loadouts are valid for Civilian T_INF_exp faction templates (not classes)");
	};

	_this addItemToBackpack "IEDLandSmall_Remote_Mag";
	_this addItemToBackpack "IEDUrbanSmall_Remote_Mag";
	_this allowFleeing 0; // brave?
	// Set unit skill
	_this setSkill ["aimingAccuracy", 0.3];
	_this setSkill ["aimingShake", 0.3];
	_this setSkill ["aimingSpeed", 0.4];
	_this setSkill ["commanding", 0.2];
	_this setSkill ["courage", 1];
	//_this setSkill ["endurance", 0.8];
	_this setSkill ["general", 0.5];
	_this setSkill ["reloadSpeed", 0.5];
	_this setSkill ["spotDistance", 0.6];
	_this setSkill ["spotTime", 0.3];
};

// Creates a set of waypoints for our saboteur
Saboteur_fnc_createBombWPs = {
	params ["_civie", "_tgtPos", "_immediateDetonate"];

	// Cleaning old orders by moving group
	private _oldGrp = group _civie;
	private _grp = createGroup [west, true];
	[_civie] joinSilent _grp;
	_grp allowFleeing 0;
	deleteGroup _oldGrp;

	deleteWaypoint [_grp, 0];

	// No enemy attacking them for now
	_civie setCaptive true;

	// Make them just do what we damn well tell them
	_civie disableAI "AUTOCOMBAT";
	_civie disableAI "CHECKVISIBLE";

	// WAYPOINT 1 - plant bomb
	private _firstWP = _grp addWaypoint [_tgtPos, 0];
	_firstWP setWaypointType "MOVE";
	_firstWP setWaypointBehaviour "STEALTH";
	_firstWP setWaypointSpeed "LIMITED";
	_firstWP setWaypointStatements ["true", 
		"
			this fire ['DemoChargeMuzzle', 'DemoChargeMuzzle', 'IEDUrbanSmall_Remote_Mag'];
			[this] remoteExec ['removeAllActions', 0, this];
		"
	];

	// WAYPOINT 2 - hide
	private _hidePos = [_tgtPos, 10, 50] call BIS_fnc_findSafePos;
	// private _range = 10;
	// while{count _hidePos == 3 and _range < 200} do {
	// 	_hidePos = [_tgtPos, _range, _range * 2] call BIS_fnc_findSafePos;
	// 	_range = _range * 2;
	// };
	if(count _hidePos == 3) then {
		_hidePos = _tgtPos vectorAdd [15,15,0];
	};
	private _wp = _grp addWaypoint [_hidePos, 0];
	_wp setWaypointType "MOVE";
	_wp setWaypointBehaviour "COMBAT";
	_wp setWaypointSpeed "FULL";
	_wp setWaypointStatements ["true", "this setVariable ['ready_to_bomb', true];"];

	// WAYPOINT 3 - wait
	// Wait until blowed up the bomb
	private _wp = _grp addWaypoint [_hidePos, 0];
	_wp setWaypointType "MOVE";
	_wp setWaypointBehaviour "STEALTH";
	_wp setWaypointSpeed "FULL";
	_wp setWaypointStatements ["this getVariable ['bombed', false]", ""];

	// WAYPOINT 4 - run away!
	// Run far away!
	private _wp = _grp addWaypoint [[_tgtPos, 1000, 2000] call BIS_fnc_findSafePos, 0];
	_wp setWaypointType "MOVE";
	_wp setWaypointBehaviour "COMBAT";
	_wp setWaypointSpeed "FULL";
	_wp setWaypointStatements ["true", "deleteVehicle this;"];

	private _trigger = _civie getVariable["_trigger", objNull];
	if(!isNull _trigger) then {
		_trigger setPos _tgtPos;
	} else {
		_trigger = createTrigger ["EmptyDetector", _tgtPos];
		_civie setVariable["_trigger", _trigger];
	};
	_trigger setTriggerArea  [8, 8, 0, false];
	_trigger setTriggerActivation ["ANY", "PRESENT", true];
	// _trigger setTriggerInterval 5;
	_trigger setVariable ["owner", _civie];
	private _triggerCond = if(!_immediateDetonate) then {
		"
		private _owner = thisTrigger getVariable 'owner';
		alive _owner && {
			_owner getVariable ['ready_to_bomb', false] 
		} && {
			({side _x == INDEPENDENT} count thisList) > 0 && 
			({(_x isKindOf 'Man') && (side _x != INDEPENDENT)} count thisList) == 0
		}
		"
	} else {
		"
		private _owner = thisTrigger getVariable 'owner';
		alive _owner && {
			_owner getVariable ['ready_to_bomb', false] 
		}
		"
	};

	_trigger setTriggerStatements [
		_triggerCond,
		"
		private _owner = thisTrigger getVariable 'owner';
		if(alive _owner) then {
			systemChat format['%1: Vindicta!', name _owner];
			_owner action ['TOUCHOFF', _owner];
			_owner setVariable ['bombed', true];
			_owner setCaptive false;
		};
		deleteVehicle thisTrigger;
		[INDEPENDENT, getPos thisTrigger, 5 + random 10] call AI_fnc_addActivity;
		",
		"true"];
	// Resume wp following
	_civie doFollow leader _civie;
	_trigger
};

// Called when player interacts with the saboteur. 
// They can take the explosives.
// Called on players client.
Saboteur_fnc_playerTakesBomb = {
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
			]] call vin_fnc_dialogue_createSentence;

		sleep 2;

		// Civie always says yes...
		[_target, selectRandom [
			"Okay, don't waste it!",
			"Here you go",
			"No problem",
			"Be careful with it, I'm no explosives expert!",
			"You owe me"
			]] call vin_fnc_dialogue_createSentence;

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
			]] call vin_fnc_dialogue_createSentence;
		
		sleep 2;

		// Civie says goodbye cos they are polite like that
		[_target, selectRandom [
			"Right, I am out of here!",
			"Goodbye!",
			"Good luck!",
			"Bye!",
			"I need to be somewhere else..."
			]] call vin_fnc_dialogue_createSentence;

		// Civie runs off after maybe saluting
		[[_target, _caller], { 
			params ["_target", "_caller"];

			if (random 1 > 0.5) then {
				// Do the unit actions on the server
				_target lookAt _caller;
				_target action ["Salute", _target];
				sleep 2;
			};

			_target call vin_fnc_CivieRunAway;
		}] remoteExec ["spawn", 2];

		// Clear actions on this civie
		[_target] remoteExec ['removeAllActions', 0, _target];
	};
};

// Called when player interacts with the saboteur to reroute them. 
// Player can ask bomber to target a road with a proximity mine.
// Called on players client.
Saboteur_fnc_playerSelectsTarget = {
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

		// "Ask" them to target somewhere specific	
		[_caller, selectRandom [
			"I have a plan, perhaps you can help?",
			"The resistence has a plan for us all",
			"You looking for something to, er, BLOW UP?",
			"You wanna be 'sploding something?",
			"Let me make a suggestion...",
			"I got an idea"
			]] call vin_fnc_dialogue_createSentence;

		sleep 2;

		// Civie always says yes...
		[_target, selectRandom [
			"Okay, show me!",
			"Where?",
			"Just point the way",
			"Sorry, you will have to show me"
			]] call vin_fnc_dialogue_createSentence;

		sleep 2;

		// Open player map so you can click where the bomber should go
		openMap true;
		"bomber_map_text" cutText ["<t size='3'>Shift Click to select a target for the bomber.<br/>Close the map to confirm the selection.<br/>Alt Click to clear the target.</t>", "PLAIN DOWN", -1, true, true];
		gBomberTarget = [];
		onMapSingleClick {
			if (_shift) then {
				gBomberTarget = _pos;
				createMarker ["Bomber Target", _pos];
				"Bomber Target" setMarkerColor "ColorRed";
				"Bomber Target" setMarkerShape "ICON";
				"Bomber Target" setMarkerType "hd_destroy";
			} else {
				if(_alt) then {
					gBomberTarget = [];
					deleteMarker "Bomber Target";
				};
			};
			_shift
		};
		waitUntil { !visibleMap };
		onMapSingleClick {};
		deleteMarker "Bomber Target";
		"bomber_map_text" cutFadeOut 1;

		if(count gBomberTarget > 0) then {

			// Player acknowledges
			[_caller, selectRandom [
				"Here!",
				"Can you go here?",
				"Go here",
				"What about here?",
				"Put it just...here"
				]] call vin_fnc_dialogue_createSentence;

			sleep 2;

			// Civie goes off to do it
			[_target, selectRandom [
				"On my way!",
				"Good idea, I'll make sure it gets done.",
				"They will never know what hit them!",
				"Mwuhahahaha!",
				"Oh yes."
				]] call vin_fnc_dialogue_createSentence;

			// Civie runs off after maybe saluting
			[[_target, _caller], { 
				params ["_target", "_caller"];

				if (random 10 > 5) then {
					// Do the unit actions on the server
					_target lookAt _caller;
					_target action ["Salute", _target];
					sleep 2;
				};

				[_target, gBomberTarget, false] call Saboteur_fnc_createBombWPs;
			}] remoteExec ["spawn", 2];

			// Clear actions on this civie
			[_target] remoteExec ['removeAllActions', 0, _target];
		};
	};
};

// Returns positions of valid target vehicles (enemy and empty)
Saboteur_fnc_getTargetVehiclePositions = {
	params ["_city"];

	private _enemyGarrisons = CALLM1(_city, "getGarrisonsRecursive", ENEMY_SIDE);
	private _vehiclePositions = [];
	{
		_vehiclePositions = _vehiclePositions + (CALLM0(_x, "getVehicleUnits") select {
			CALLM0(_x, "isEmpty")
		} apply {
			CALLM0(_x, "getPos")
		});
	} forEach _enemyGarrisons;

	_vehiclePositions
	// // Find enemy side unoccupied vics in the target area
	// private _vics = nearestObjects [_pos, ["Car", "Tank", "Truck"], _radius] select {
	// 	count crew _x == 0 && {side _x == ENEMY_SIDE}
	// };
};

// Returns a few positions of valid road side bombs (bigger road is better, not too close together)
Saboteur_fnc_findRoadSideBombPositions = {
	params [P_POSITION("_pos"), P_NUMBER("_radius"), P_NUMBER("_amount")];

	private _validPositions = [];

	// Get near roads and sort them far to near, taking width into account
	private _roads_remaining = ((_pos nearRoads _radius) select {
		//private _roadPos = getPosASL _x;
		//(_roadPos distance _pos > _radius) &&	// Pos is far enough
		(count (roadsConnectedTo _x) >= 2) // Connected to two roads, we don't need end road elements
	}) apply {
		private _width = [_x, 1, 20] call misc_fnc_getRoadWidth;
		// We value wide roads more, also we value roads further away more
		[_width, _x]
	};

	// Randomize road order to remove location coherence that we might get from above algorithm
	_roads_remaining = _roads_remaining call BIS_fnc_arrayShuffle;

	// Sort roads by their width
	_roads_remaining sort DESCENDING;
	private _itr = 0;
	private _minDist = (_radius * 0.2) max 50;
	while {count _roads_remaining > 0 && _itr < _amount} do {
		(_roads_remaining#0) params ["_width", "_road"];
		_roads_remaining deleteAt 0;

		private _roadscon = roadsConnectedto _road;

		// Determine a road side location from the road
		private _roadcon = _roadscon#0;
		private _dir = _roadcon getDir _road;
		private _targetPos = [getPos _road, _width * 0.5, _dir + 90] call BIS_Fnc_relPos;
		_validPositions pushBack _targetPos;

		// Remove all the nearby roads so we select fairly separated targets
		_roads_remaining = _roads_remaining select {
			(getPos _road) distance (getPos (_x#1)) > _minDist
		};
		_itr = _itr + 1;
	};

	_validPositions
};

/*
Class: SaboteurCiviliansAmbientMission
This mission spawns a number of civilians with IEDs who will try and blow up various buildings near the police station.
TODO:
	Make them choose targets better, they should try and blow up police vehicles, the police station, the police themselves!
	Allow them to set traps for police, roadside bombs, blow up incoming reinforcements etc.
*/
#define OOP_CLASS_NAME SaboteurCiviliansAmbientMission
CLASS("SaboteurCiviliansAmbientMission", "AmbientMission")
	// Selection of target buildings remaining.
	VARIABLE("targetBuildings");
	// Selection of target roads remaining
	VARIABLE("targetRoads");
	// Max number of saboteurs that can be active at one time.
	VARIABLE("maxActive");
	// The active saboteurs.
	VARIABLE("activeCivs");

	METHOD(new)
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
		_targetBuildings = _targetBuildings call BIS_fnc_arrayShuffle;

		// Density of 1 blown up building every 50m^2 or so
		private _maxBuildings = 3 max (_radius * _radius / 2500);
		_targetBuildings resize (count _targetBuildings min _maxBuildings);

		private _targetBuildingPositions = _targetBuildings apply {
			_x buildingPos -1
		} select {
			count _x > 0
		} apply {
			_x#0
		};
		T_SETV("targetBuildings", _targetBuildingPositions);
		diag_log format ["Target buildings: %1", _targetBuildingPositions];

		#ifdef SABOTEUR_CIVILIANS_TESTING
		[_targetBuildings, "Bld", "ColorBlue"] call Saboteur_fnc_drawDebugMarkers;
		#endif

		private _targetRoads = [_pos, _radius * 0.75, 10] call Saboteur_fnc_findRoadSideBombPositions;
		T_SETV("targetRoads", _targetRoads);
		diag_log format ["Target roads: %1", _targetRoads];

		#ifdef SABOTEUR_CIVILIANS_TESTING
		[_targetRoads, "Rd", "ColorRed"] call Saboteur_fnc_drawDebugMarkers;
		#endif

		// Calculate some target roads for mines
#ifdef SABOTEUR_CIVILIANS_TESTING
		// This should be interesting!
		private _maxActive = 5;
#else
		// Don't want many of these guys
		private _maxActive = 1; //1 + (ln(0.01 * _radius + 1) min 1); // Probably that's too many already
#endif
		T_SETV("maxActive", _maxActive);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		// Clean up an active missions
		{ 
			_x params ["_civie", "_trigger"];
			deleteVehicle _civie;
			deleteVehicle _trigger;
		} forEach T_GETV("activeCivs");
	ENDMETHOD;

#ifdef SABOTEUR_CIVILIANS_TESTING
	// Make it always active mission if we are testing
	public override METHOD(isActive)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		true
	ENDMETHOD;
#endif

	// Called from base class update function, regardless of if the mission is active,
	// because we might need to cleanup some missions that were ongoing.
	protected override METHOD(updateExisting)
		params [P_THISOBJECT, P_OOP_OBJECT("_city"), P_BOOL("_active")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		// Check for finished actions
		private _activeCivs = T_GETV("activeCivs");
		{
			_x params ["_civie", "_trigger"];
			if(!alive _civie) then {
				deleteVehicle _trigger;
				_activeCivs deleteAt (_activeCivs find _x);
			} else {
				// If this mission type shouldn't be active anymore then just send the civies away
				if(!_active) then {
					_civie call vin_fnc_CivieRunAway;
				};
			};
		} forEach +_activeCivs;
	ENDMETHOD;
	
	// Called from base class update function, when the mission is active
	protected override METHOD(spawnNew)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		// Add new actions if don't have enough active already
		private _activeCivs = T_GETV("activeCivs");
		private _maxActive = T_GETV("maxActive");
		private _deficit = _maxActive - (count _activeCivs);

		if(_deficit > 0) then {
			OOP_INFO_MSG("Spawning %1 civilians in %2 to blow shit up!", [_deficit ARG _city]);
			private _pos = CALLM0(_city, "getPos");
			private _radius = GETV(_city, "boundingRadius");

			private _targetBuildings = T_GETV("targetBuildings");
			private _targetRoads = T_GETV("targetRoads");

			private _targetVics = [_city] call Saboteur_fnc_getTargetVehiclePositions;
			//diag_log format ["Target vics: %1", _targetVics];

			#ifdef SABOTEUR_CIVILIANS_TESTING
			[_targetVics, "Vic", "ColorPink"] call Saboteur_fnc_drawDebugMarkers;
			#endif

			// createMarker ["Bomber Target", _pos];
			// _marker setMarkerColor "ColorRed";
			// _marker setMarkerShape "ICON";
			// _marker setMarkerType "hd_destroy";

			// Use the civ types specified in the presence module
			private _civTemplate = CALLM1(gGameMode, "getTemplate", civilian);
			private _civTypes = _civTemplate select T_INF select T_INF_default;

			for "_i" from 0 to (_deficit-1) do {

				// Find a target
				private _tgtPos = [];
				private _immediateDetonate = false;

				private _sel = random 3;

				switch true do {
					case (count _targetVics > 0 && _sel < 1): { 
						private _idx = _targetVics call BIS_fnc_randomIndex;
						_tgtPos = _targetVics#_idx;
						_targetVics deleteAt _idx;
						_immediateDetonate = true;
					};
					case (count _targetRoads > 0 && _sel > 1.5): { 
						private _idx = _targetRoads call BIS_fnc_randomIndex;
						_tgtPos = _targetRoads#_idx;
						_targetRoads deleteAt _idx;
						_immediateDetonate = false;
					};
					case (count _targetBuildings > 0): {
						private _idx = _targetBuildings call BIS_fnc_randomIndex;
						_tgtPos = _targetBuildings#_idx;
						_targetBuildings deleteAt _idx;
						_immediateDetonate = true;
					};
				};

				if(_tgtPos isEqualTo []) exitWith {
					OOP_ERROR_MSG("Couldn't find a target for a saboteurs in %1", [_city]);
				};

				// Get starting point for the civ
				private _rndpos = [_pos, 0, _radius] call BIS_fnc_findSafePos;
				private _tmpGroup = createGroup civilian;
				private _civie = _tmpGroup createUnit [(selectRandom _civTypes), _rndpos, [], 0, "NONE"];
				private _grp = createGroup [FRIENDLY_SIDE, true];
				[_civie] joinSilent _grp;
				_grp allowFleeing 0;
				deleteGroup _tmpGroup;
				_civie call Saboteur_fnc_initSaboteur;
				_civie setVariable ["_owner", _thisObject];

				// Add action to recruit them to your squad
				[
					_civie,
					["Can I borrow that?", Saboteur_fnc_playerTakesBomb, [], 1.5, false, true, "", "true", 10]
				] remoteExec ["addAction", 0, _civie];

				[
					_civie,
					["I have a suggestion!", Saboteur_fnc_playerSelectsTarget, [], 1.5, false, true, "", "true", 10]
				] remoteExec ["addAction", 0, _civie];

				private _trigger = [_civie, _tgtPos, _immediateDetonate] call Saboteur_fnc_createBombWPs;
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
	ENDMETHOD;

ENDCLASS;