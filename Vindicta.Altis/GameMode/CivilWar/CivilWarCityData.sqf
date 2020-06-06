#include "common.hpp"
FIX_LINE_NUMBERS()

/*
Class: CivilWarCityData
City data specific to this game mode.
*/
#define OOP_CLASS_NAME CivilWarCityData
CLASS("CivilWarCityData", "CivilWarLocationData")
	// City state (stable, agitated, in revolt, suppressed, liberated)
	VARIABLE_ATTR("state", [ATTR_SAVE]);
	// Stability value based on local player activity
	VARIABLE_ATTR("instability", [ATTR_SAVE]);
	// Ambient missions, active while location is spawned
	VARIABLE("ambientMissions");
	// Amount of available recruits
	VARIABLE_ATTR("nRecruits", [ATTR_SAVE]);
	// Map UI info
	VARIABLE("mapUIInfo");

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("state", CITY_STATE_STABLE);
		T_SETV("instability", 0);
		T_SETV("ambientMissions", []);
		T_SETV("nRecruits", 0);
		T_SETV("mapUIInfo", []);
		if (IS_SERVER) then {	// Makes no sense for client
			T_PUBLIC_VAR("state");
			T_PUBLIC_VAR("instability");
			T_PUBLIC_VAR("nRecruits");
			T_PUBLIC_VAR("mapUIInfo");
		};
	ENDMETHOD;

	METHOD(spawned)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		OOP_INFO_MSG("Spawning %1", [_city]);

		private _ambientMissions = T_GETV("ambientMissions");
		private _pos = CALLM0(_city, "getPos");
		private _radius = GETV(_city, "boundingRadius");

		// CivPresence civilians are being arrested too, so there is no need for it any more
		//_ambientMissions pushBack (NEW("HarassedCiviliansAmbientMission", [_city ARG [CITY_STATE_STABLE]]));

		_ambientMissions pushBack NEW("MilitantCiviliansAmbientMission", [_city ARG [CITY_STATE_AGITATED ARG CITY_STATE_IN_REVOLT]]);

		// It's quite confusing so I have disabled it for now, sorry
		_ambientMissions pushBack NEW("SaboteurCiviliansAmbientMission", [_city ARG [CITY_STATE_AGITATED ARG CITY_STATE_IN_REVOLT]]);
	ENDMETHOD;

	METHOD(despawned)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		ASSERT_OBJECT_CLASS(_city, "Location");

		OOP_INFO_MSG("Despawning %1", [_city]);

		private _ambientMissions = T_GETV("ambientMissions");
		{
			DELETE(_x);
		} forEach _ambientMissions;
		T_SETV("ambientMissions", []);
	ENDMETHOD;

	METHOD(update)
		params [P_THISOBJECT, P_OOP_OBJECT("_city"), P_NUMBER("_dt")];
		ASSERT_OBJECT_CLASS(_city, "Location");
		private _state = T_GETV("state");
		private _instability = T_GETV("instability");

		private _cityPos = CALLM0(_city, "getPos");
		private _cityRadius = (300 max GETV(_city, "boundingRadius")) min 700;
		private _cityCivCap = CALLM0(_city, "getCapacityCiv");
		private _oldState = _state;

		// If the location is spawned and there are twice as many friendly as enemy units then it is liberated, otherwise it is suppressed
		private _friendlyCount = 0;
		{ _friendlyCount = _friendlyCount + CALLM0(_x, "countConsciousInfantryUnits") } forEach CALLM1(_city, "getGarrisonsRecursive", FRIENDLY_SIDE);

		private _enemyCount = 0;
		{ _enemyCount = _enemyCount + CALLM0(_x, "countConsciousInfantryUnits") } forEach CALLM1(_city, "getGarrisonsRecursive", ENEMY_SIDE);

		if(_friendlyCount > 0 && _friendlyCount >= _enemyCount * 2) then { 
			_state = CITY_STATE_LIBERATED;
		} else {
			if(_state == CITY_STATE_LIBERATED && _enemyCount > 4) then {
				_state = CITY_STATE_SUPPRESSED;
			};
		};

		// If City is stable or agitated then instability is a factor
		if(_state in [CITY_STATE_STABLE, CITY_STATE_AGITATED]) then {
			private _enemyCmdr = CALLSM("AICommander", "getAICommander", [ENEMY_SIDE]);
			private _activity = CALLM(_enemyCmdr, "getActivity", [_cityPos ARG _cityRadius]);

			// For now we will just have instability directly related to activity and inversely related to city radius (activity fades over time just
			// as we want instability to)
			// TODO: add other interesting factors here to the instability rate.
			// This equation makes required instability relative to area, and means you need ~100 activity at radius 300m and ~600 at radius 750m
			_instability = 1 min (_activity * 900 / (_cityRadius * _cityRadius));
			// diag_log [GETV(_city, "name"), _instability, _activity, _cityRadius];

			// TODO: scale the instability limits using settings
			switch true do {
				case (_instability >= 1): { _state = CITY_STATE_IN_REVOLT; };
				case (_instability > 0.2): { _state = CITY_STATE_AGITATED; };
				default { _state = CITY_STATE_STABLE; };
			};
		} else {
			// Instability is only 0 or 1 for liberated/suppressed cities
			_instability = if(_state in [CITY_STATE_LIBERATED, CITY_STATE_IN_REVOLT]) then { 1 } else { 0 };

			// Make sure amount of activity is appropriate for a city that is liberated
			if(_state == CITY_STATE_LIBERATED) then {
				private _enemyCmdr = CALLSM("AICommander", "getAICommander", [ENEMY_SIDE]);
				private _activity = CALLM(_enemyCmdr, "getActivity", [_cityPos ARG _cityRadius]);

				// Activity trends upwards in liberated revolting cities until it hits an equilibrium with fade out
				// This will ensure the enemy commander doesn't forget about them even if player isn't active in them
				// https://www.desmos.com/calculator/kiphke1gsj
				private _dActivity = _dt * 10 / (30 * (_activity + 10));
				CALLSM("AICommander", "addActivity", [ENEMY_SIDE ARG _cityPos ARG _dActivity]);
			};
		};

		T_SETV_PUBLIC("instability", _instability);
		T_SETV_PUBLIC("state", _state);

		// Send player notifications for changes
		if(_oldState != _state) then {
			// Notify players of what happened
			// private _stateDesc = gCityStateData#_state#0;
			private _stateMsg = CALLM0(_city, "getDisplayName");
			private _args = ["LOCATION STATE CHANGED", _stateMsg, ""];
			REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createLocationNotification", _args, ON_ALL, NO_JIP);
		};

		// Add passive recruits
		private _ratePerHour = T_CALLM1("getRecruitmentRate", _city);
		private _recruitIncome = _dt * _ratePerHour / 3600;
		T_CALLM2("addRecruits", _city, _recruitIncome);

		private _stateData = gCityStateData#_state;
		private _status = ["STATUS", _stateData#0, _stateData#1];
		private _mapUIInfo = [
			["RECRUITS", str floor T_GETV("nRecruits")],
			["  MAX", str floor T_CALLM1("getMaxRecruits", _city)],
			["  PER HOUR", _ratePerHour toFixed 1],
			["INSTABILITY", format["%1%2", (_instability * 100) toFixed 0, "%"]],
			_status
		];
		T_SETV_PUBLIC("mapUIInfo", _mapUIInfo);

#ifdef DEBUG_CIVIL_WAR_GAME_MODE
		private _mrk = GETV(_city, "name") + "_gamemode_data";
		createMarker [_mrk, CALLM0(_city, "getPos") vectorAdd [0, 100, 0]];
		_mrk setMarkerType "mil_marker";
		_mrk setMarkerColor "ColorBlue";
		_mrk setMarkerText (format ["%1 (%2)", gCityStateData#_state#0, T_GETV("instability")]);
		_mrk setMarkerAlpha 1;
#endif
		FIX_LINE_NUMBERS()

		// Update police stations (spawning reinforcements etc)
		private _policeStations = GETV(_city, "children") select { GETV(_x, "type") == LOCATION_TYPE_POLICE_STATION };
		{
			private _policeStation = _x;
			private _data = GETV(_policeStation, "gameModeData");
			CALLM(_data, "update", [_policeStation ARG _state]);
		} forEach _policeStations;

		// Update our ambient missions
		private _ambientMissions = T_GETV("ambientMissions");
		{
			CALLM(_x, "update", [_city]);
		} forEach _ambientMissions;
	ENDMETHOD;
	
	METHOD(getMaxRecruits)
		params [P_THISOBJECT, P_OOP_OBJECT("_city")];
		CALLM0(_city, "getCapacityCiv"); // It gives a quite good estimate for now
	ENDMETHOD;

	// Get the recruitment rate per hour
	METHOD(getRecruitmentRate)
		private _rate = 0;
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_city")];
			ASSERT_OBJECT_CLASS(_city, "Location");
			private _instability = T_GETV("instability");

			private _garrisonedMult = if(count CALLM(_city, "getGarrisons", [FRIENDLY_SIDE]) > 0) then { 1.5 } else { 1 };

			private _nRecruitsMax = T_CALLM1("getMaxRecruits", _city);
			// Recruits is filled up in 2 hours when city is at liberated
			_rate = 0 max (_instability * _nRecruitsMax * _garrisonedMult / 2);
		};
		_rate
	ENDMETHOD;

	// Add/remove recruits
	public METHOD(addRecruits)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_OOP_OBJECT("_city"), P_NUMBER("_amount")];
			private _n = T_GETV("nRecruits");
			private _nRecruitsMax = CALLM0(_city, "getCapacityCiv"); // It gives a quite good estimate for now
			_n = ((_n + _amount) max 0) min _nRecruitsMax;
			T_SETV_PUBLIC("nRecruits", _n);
		};
	ENDMETHOD;

	public METHOD(removeRecruits)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_NUMBER("_amount")];

			private _n = T_GETV("nRecruits");
			_n = (_n - _amount) max 0;
			T_SETV_PUBLIC("nRecruits", _n);
		};
	ENDMETHOD;

	public override METHOD(getRecruitCount)
		private _return = 0;
		CRITICAL_SECTION {
			params [P_THISOBJECT];
			_return = floor T_GETV("nRecruits");
		};
		_return
	ENDMETHOD;

	public override METHOD(updatePlayerRespawn)
		params [P_THISOBJECT];

		// Player respawn is enabled in a city which has non-city locations nearby with enabled player respawn
		private _loc = T_GETV("location");

		private _nearLocs = CALLSM2("Location", "overlappingLocations", CALLM0(_loc, "getPos"), CITY_PLAYER_RESPAWN_ACTIVATION_RADIUS) select {CALLM0(_x, "getType") != LOCATION_TYPE_CITY};

		private _forceEnable = T_GETV("forceEnablePlayerRespawn");
		{
			private _side = _x;
			private _index = _nearLocs findIf {CALLM1(_x, "playerRespawnEnabled", _side)};
			private _enable = (_index != -1) || _forceEnable;
			CALLM2(_loc, "enablePlayerRespawn", _side, _enable);
		} forEach [WEST, EAST, INDEPENDENT];
	ENDMETHOD;

	public override METHOD(getMapInfoEntries)
		private _return = [];
		CRITICAL_SECTION {
			params [P_THISOBJECT];
			private _mapUIInfo = T_GETV("mapUIInfo");
			_return = +_mapUIInfo;
		};
		_return
	ENDMETHOD;

	// Overrides the location name
	public override METHOD(getDisplayName)
		private _return = objNull;
		CRITICAL_SECTION {
			params [P_THISOBJECT];
			private _loc = T_GETV("location");
			private _stateData = gCityStateData#(T_GETV("state"));
			private _baseName = CALLM0(_loc, "getName");
			// format["%1 [%2]", _baseName, _stateData#1]
			_return = format["%1 (%2)", _baseName, _stateData#0];
		};
		_return
	ENDMETHOD;

	// Overrides the location color
	public override METHOD(getDisplayColor)
		private _return = [1,1,1,1];
		CRITICAL_SECTION {
			params [P_THISOBJECT];
			private _loc = T_GETV("location");
			private _stateData = gCityStateData#(T_GETV("state"));
			_return = _stateData#1;
		};
		_return
	ENDMETHOD;
	// STORAGE

	public override METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Call method of all base classes
		CALLCM("CivilWarLocationData", _thisObject, "postDeserialize", [_storage]);

		T_SETV("ambientMissions", []);
		T_SETV("mapUIInfo", []);

		// Broadcast public variables
		T_PUBLIC_VAR("nRecruits");
		T_PUBLIC_VAR("instability");
		T_PUBLIC_VAR("state");
		T_PUBLIC_VAR("mapUIInfo");

		true
	ENDMETHOD;

ENDCLASS;
