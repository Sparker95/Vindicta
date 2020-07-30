#include "common.hpp"
FIX_LINE_NUMBERS()

/*
Class: CivilWarCityData
City data specific to this game mode.
*/
#define OOP_CLASS_NAME CivilWarCityData
CLASS("CivilWarCityData", "CivilWarLocationData")
	// City state 
	VARIABLE_ATTR("state", [ATTR_SAVE]);
	// Ambient missions, active while location is spawned
	VARIABLE("ambientMissions");
	// Amount of available recruits
	VARIABLE_ATTR("nRecruitsFriendly", [ATTR_SAVE]);
	VARIABLE_ATTR("nRecruitsEnemy", [ATTR_SAVE]);
	// Map UI info
	VARIABLE("mapUIInfo");

	VARIABLE_ATTR("population", [ATTR_SAVE]); // Amount of civilians living here
	VARIABLE_ATTR("influence", [ATTR_SAVE]); // Number, positive - BLUE influence, negative - ENEMY influence

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
		T_SETV("state", CITY_STATE_NEUTRAL);
		T_SETV("influence", 0); // 0.3 + random 0.7); // might use for testing
		T_SETV("ambientMissions", []);
		T_SETV("nRecruitsFriendly", 0);
		T_SETV("nRecruitsEnemy", 0);
		T_SETV("mapUIInfo", []);

		// Calculate initial population
		pr _population = CALLM0(_location, "getCapacityCiv");
		T_SETV("population", _population);

		if (IS_SERVER) then {	// Makes no sense for client
			T_PUBLIC_VAR("state");
			T_PUBLIC_VAR("influence");
			T_PUBLIC_VAR("nRecruitsFriendly");
			T_PUBLIC_VAR("nRecruitsEnemy");
			T_PUBLIC_VAR("mapUIInfo");
			T_PUBLIC_VAR("population");
		};
	ENDMETHOD;

	public METHOD(spawned)
		params [P_THISOBJECT];

		pr _city = T_GETV("location");
		ASSERT_OBJECT_CLASS(_city, "Location");

		OOP_INFO_MSG("Spawning %1", [_city]);

		//private _ambientMissions = T_GETV("ambientMissions");
		//private _pos = CALLM0(_city, "getPos");
		//private _radius = GETV(_city, "boundingRadius");

		// CivPresence civilians are being arrested too, so there is no need for it any more
		//_ambientMissions pushBack (NEW("HarassedCiviliansAmbientMission", [_city ARG [CITY_STATE_STABLE]]));

		//_ambientMissions pushBack NEW("MilitantCiviliansAmbientMission", [_city ARG [CITY_STATE_AGITATED ARG CITY_STATE_IN_REVOLT]]);

		// It's quite confusing so I have disabled it for now, sorry
		//_ambientMissions pushBack NEW("SaboteurCiviliansAmbientMission", [_city ARG [CITY_STATE_AGITATED ARG CITY_STATE_IN_REVOLT]]);
		0;
	ENDMETHOD;

	public METHOD(despawned)
		params [P_THISOBJECT];

		pr _city = T_GETV("location");
		ASSERT_OBJECT_CLASS(_city, "Location");

		OOP_INFO_MSG("Despawning %1", [_city]);

		private _ambientMissions = T_GETV("ambientMissions");
		{
			DELETE(_x);
		} forEach _ambientMissions;
		T_SETV("ambientMissions", []);
	ENDMETHOD;

	public METHOD(update)
		params [P_THISOBJECT, P_NUMBER("_dt"), P_NUMBER("_aggression")];

		pr _city = T_GETV("location");
		ASSERT_OBJECT_CLASS(_city, "Location");
		private _state = T_GETV("state");
		private _influence = T_GETV("influence");

		private _cityPos = CALLM0(_city, "getPos");
		private _cityCivCap = CALLM0(_city, "getCapacityCiv");
		private _oldState = _state;

		// If the location is spawned and there are twice as many friendly as enemy units then it is liberated, otherwise it is suppressed
		private _friendlyCount = 0;
		{ _friendlyCount = _friendlyCount + CALLM0(_x, "countConsciousInfantryUnits") } forEach CALLM1(_city, "getGarrisons", FRIENDLY_SIDE);

		private _enemyCount = 0;
		{ _enemyCount = _enemyCount + CALLM0(_x, "countConsciousInfantryUnits") } forEach CALLM1(_city, "getGarrisons", ENEMY_SIDE);

		// Update city state
		if (_friendlyCount == 0 && _enemyCount == 0) then {
			_state = CITY_STATE_NEUTRAL;
		} else {
			if (_enemyCount > _friendlyCount) then {
				_state = CITY_STATE_ENEMY_CONTROL;
			} else {
				_state = CITY_STATE_FRIENDLY_CONTROL;
			};
		};

		// Update influence

		if (_state == CITY_STATE_NEUTRAL) then {
			// Neutral cities lose influence according to aggression
			// At max aggression, decrease rate is 1.0 per 12 hours
			pr _propagandaPerHour = _dt*_aggression/3600/12;
			_influence = _influence - _propagandaPerHour;
		} else {
			// Captured city loses/gains influence at rate of 1 per 3 hours.
			pr _influenceGain = _dt/3600/3;
			if (_state == CITY_STATE_ENEMY_CONTROL) then {
				_influence = _influence - _influenceGain;
			} else {
				_influence = _influence + _influenceGain;
			};
		};

		_influence = CLAMP(_influence, -1.0, 1.0);

		T_SETV_PUBLIC("influence", _influence);
		T_SETV_PUBLIC("state", _state);

		// Send player notifications for changes
		if(_oldState != _state) then {
			// Notify players of what happened
			// private _stateDesc = gCityStateData#_state#0;
			private _stateMsg = CALLM0(_city, "getDisplayName");
			private _args = ["CITY STATE CHANGED", _stateMsg, ""];
			REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createLocationNotification", _args, ON_ALL, NO_JIP);
		};

		// Add recruits to one of the sides
		if (_influence != 0) then {
			pr _sideAddRecruit = FRIENDLY_SIDE;
			if (_influence < 0) then {
				_sideAddRecruit = ENEMY_SIDE;
			};
			private _ratePerHour = T_CALLM2("getRecruitmentRate", abs _influence, _sideAddRecruit);
			private _recruitIncome = _dt * _ratePerHour / 3600;

			pr _nRecruits = if (_influence < 0) then { T_GETV("nRecruitsEnemy"); } else {T_GETV("nRecruitsFriendly"); };
			pr _maxRecruits = T_CALLM1("getMaxRecruits", _sideAddRecruit);
			_nRecruits = (_nRecruits + _recruitIncome) min _maxRecruits;
			if (_influence < 0) then { T_SETV_PUBLIC("nRecruitsEnemy", _nRecruits); } else {T_SETV_PUBLIC("nRecruitsFriendly", _nRecruits); };
		};

		private _stateData = gCityStateData#_state;
		private _mapUIInfo = [];
		pr _ratePerHourFriendly = if (_influence > 0) then {
			T_CALLM2("getRecruitmentRate", abs _influence, FRIENDLY_SIDE);
		} else { 0; };
		pr _ratePerHourEnemy = if (_influence < 0) then {
			T_CALLM2("getRecruitmentRate", abs _influence, ENEMY_SIDE);
		} else { 0; };
		_mapUIInfo pushBack ["STATUS", _stateData#0];
		_mapUIInfo pushBack ["POPULATION", str T_GETV("population")];
		_mapUIInfo pushBack ["INFLUENCE", format["%1%2", (_influence * 100) toFixed 0, "%"]];
		_mapUIInfo pushBack ["FRIENDLY RECRUITS", str floor T_GETV("nRecruitsFriendly")];
		_mapUIInfo pushBack ["  MAX", str round T_CALLM1("getMaxRecruits", FRIENDLY_SIDE)];
		_mapUIInfo pushBack ["  PER HOUR", _ratePerHourFriendly toFixed 1];
		_mapUIInfo pushBack ["ENEMY RECRUITS", str floor T_GETV("nRecruitsEnemy")];
		_mapUIInfo pushBack ["  PER HOUR", _ratePerHourEnemy toFixed 1];
		T_SETV_PUBLIC("mapUIInfo", _mapUIInfo);

#ifdef DEBUG_CIVIL_WAR_GAME_MODE
		private _mrk = GETV(_city, "name") + "_gamemode_data";
		createMarker [_mrk, CALLM0(_city, "getPos") vectorAdd [0, 100, 0]];
		_mrk setMarkerType "mil_marker";
		_mrk setMarkerColor "ColorBlue";
		_mrk setMarkerText (format ["%1 (%2)", gCityStateData#_state#0, 100*T_GETV("influence")]);
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
		params [P_THISOBJECT, P_SIDE("_side")];
		pr _pop = T_GETV("population");
		pr _influence = T_GETV("influence");
		pr _state = T_GETV("state");
		pr _occupiedBySide = if (_influence > 0) then {
			_state == CITY_STATE_FRIENDLY_CONTROL;
		} else {
			_state == CITY_STATE_ENEMY_CONTROL;
		};
		pr _mob = if (_occupiedBySide) then {
			MOBILIZATION_OCCUPIED;
		} else {
			MOBILIZATION_NEUTRAL;
		};
		_pop * _mob; // Population * mobilization
	ENDMETHOD;

	// Adds influence
	METHOD(addInfluence)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_NUMBER("_value")];
			pr _influence = T_GETV("influence");
			_influence = _influence + _value;
			_influence = CLAMP(_influence, -1.0, 1.0);
			T_SETV_PUBLIC("influence", _influence);

			OOP_INFO_2("addInfluence: %1, new value: %2", _value, _influence);
		}; 
	ENDMETHOD;

	// Adds influence scaled by city size
	METHOD(addInfluenceScaled)
		params [P_THISOBJECT, P_NUMBER("_value")];
		pr _population = T_GETV("population");
		pr _mult = (_population/1000)^(-0.75); // https://www.desmos.com/calculator/mkpvvijqze
		_value = _value * _mult;
		OOP_INFO_3("addInfluenceScaled: %1, multiplier: %2, population: %3", _value, _mult, _population);
		T_CALLM1("addInfluence", _value);
	ENDMETHOD;

	// Get the recruitment rate per hour
	METHOD(getRecruitmentRate)
		private _rate = 0;
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_NUMBER("_absInfluence"), P_SIDE("_side")];

			private _nRecruitsMax = T_CALLM1("getMaxRecruits", _side);
			// Recruits is filled up in 2 hours when city is at liberated
			_rate = 0 max (_absInfluence * _nRecruitsMax / 2);
		};
		_rate;
	ENDMETHOD;

	public METHOD(getInfluence)
		params [P_THISOBJECT];
		T_GETV("influence");
	ENDMETHOD;

	public METHOD(getState)
		params [P_THISOBJECT];
		T_GETV("state");
	ENDMETHOD;

	public METHOD(removeRecruits)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_SIDE("_side"), P_NUMBER("_amount")];

			if (_side == FRIENDLY_SIDE) then {
				private _n = T_GETV("nRecruitsFriendly");
				_n = (_n - _amount) max 0;
				T_SETV_PUBLIC("nRecruitsFriendly", _n);
			} else {
				private _n = T_GETV("nRecruitsEnemy");
				_n = (_n - _amount) max 0;
				T_SETV_PUBLIC("nRecruitsEnemy", _n);
			};

			// Remove from all population too
			pr _pop = T_GETV("population");
			_pop = _pop - 1;
			T_SETV("population", _pop);
		};
	ENDMETHOD;

	public override METHOD(getRecruitCount)
		private _return = 0;
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_SIDE("_side")];
			pr _state = T_GETV("state");
			if (_side == FRIENDLY_SIDE && _state != CITY_STATE_ENEMY_CONTROL) then {
				_return = floor T_GETV("nRecruitsFriendly");
			} else {
				if (_side == ENEMY_SIDE && _state != CITY_STATE_FRIENDLY_CONTROL) then {
					_return = floor T_GETV("nRecruitsEnemy");
				};
			};
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
		_return;
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
		_return;
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
		_return;
	ENDMETHOD;
	// STORAGE

	public override METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Call method of all base classes
		CALLCM("CivilWarLocationData", _thisObject, "postDeserialize", [_storage]);

		T_SETV("ambientMissions", []);
		T_SETV("mapUIInfo", []);

		// Broadcast public variables
		T_PUBLIC_VAR("nRecruitsFriendly");
		T_PUBLIC_VAR("nRecruitsEnemy");
		T_PUBLIC_VAR("influence");
		T_PUBLIC_VAR("state");
		T_PUBLIC_VAR("mapUIInfo");

		true;
	ENDMETHOD;

ENDCLASS;
