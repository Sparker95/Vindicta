#include "common.hpp"

/*
Design documentation:
https://docs.google.com/document/d/1DeFhqNpsT49aIXdgI70GI3GIR95LR2NnJ5cpAYYl3hE/edit#bookmark=id.ev4wu6mmqtgf
*/

#define ENEMY_SIDE INDEPENDENT

CLASS("CivilWarGameMode", "GameModeBase")

	VARIABLE("lastUpdateTime");

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "CivilWar");
		T_SETV("spawningEnabled", false);
		T_SETV("lastUpdateTime", TIME_NOW);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("getLocationOwner") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		OOP_DEBUG_MSG("%1", [_loc]);
		private _type = GETV(_loc, "type");
		// Initial setup has AAF holding all bases and police stations
		if(_type == LOCATION_TYPE_BASE or _type == LOCATION_TYPE_POLICE_STATION) then {
			ENEMY_SIDE
		} else {
			CIVILIAN
		}
	} ENDMETHOD;

	/* protected virtual */ METHOD("initServerOnly") {
		params [P_THISOBJECT];
		// Create custom game mode data objects for city locations
		{
			private _cityData = NEW("CivilWarCityData", []);
			SETV(_x, "gameModeData", _cityData);
		} forEach GET_STATIC_VAR("Location", "all") select { CALLM0(_x, "getType") == LOCATION_TYPE_CITY };
	} ENDMETHOD;

	/* protected virtual */METHOD("update") {
		params [P_THISOBJECT];

		T_PRVAR(lastUpdateTime);
		private _dt = TIME_NOW - _lastUpdateTime;
		T_SETV("lastUpdateTime", TIME_NOW);

		// Update city stability and state
		{
			private _cityData = GETV(_x, "gameModeData");
			private _state = GETV(_cityData, "state");
			// if City is stable or agitated then instability is a factor
			if(_state == CITY_STATE_STABLE or _state == CITY_STATE_AGITATED) then {
				private _cityPos = CALLM0(_x, "getPos");
				private _cityRadius = 500 max GETV(_x, "border");
				private _enemyCmdr = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [ENEMY_SIDE]);
				private _activity = CALLM(_enemyCmdr, "getActivity", [_cityPos ARG _cityRadius]);
				// For now we will just have instability directly related to activity (activity fades over time just
				// as we want instability to)
				SETV(_cityData, "instability", _activity);
				_state = switch true do {
					case (_activity > 200): { CITY_STATE_IN_REVOLT };
					case (_activity > 100): { CITY_STATE_AGITATED };
					default { CITY_STATE_STABLE };
				};
			};
			SETV(_cityData, "state", _state);
			
			switch _state do {
				case CITY_STATE_STABLE: {
					// TODO: police harass civilians
				};
				case CITY_STATE_AGITATED: {
					// TODO: if local garrison is spawned then
					//	a) spawn a civ or two with weapons to attack them
					//	b) spawn an IED with proximity detonation
				};
				case CITY_STATE_IN_REVOLT: {
					// TODO: if local garrison is spawned then
					//	a) arm all civs, put them on player side
					//	b) spawn an timed IED blowing up a building or two (police station maybe?)
				};
				case CITY_STATE_SUPPRESSED: {
					// TODO: keep spawned civilians inside
					// TODO: modify cmdr strategy to occupy this town
				};
				case CITY_STATE_LIBERATED: {
					// TODO: police is on player side
				};
			};
		} forEach GET_STATIC_VAR("Location", "all") select { CALLM0(_x, "getType") == LOCATION_TYPE_CITY };
	} ENDMETHOD;
ENDCLASS;

CLASS("CivilWarCityData", "")
	VARIABLE("state");
	VARIABLE("instability");

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("state", CITY_STATE_STABLE);
		T_SETV("instability", 0);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];
	} ENDMETHOD;
ENDCLASS;