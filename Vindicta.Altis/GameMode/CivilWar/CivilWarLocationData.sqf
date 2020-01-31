#include "common.hpp"

/*
Class: GameMode.CivilWarLocationData
Game mode data for general locations
*/

#define pr private

CLASS("CivilWarLocationData", "LocationGameModeData")

	// Setting it to true will force enable respawn of players here regardless of other rules
	VARIABLE_ATTR("forceEnablePlayerRespawn", [ATTR_SAVE]);

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("forceEnablePlayerRespawn", false);
	} ENDMETHOD;

	/* virtual override */ METHOD("updatePlayerRespawn") {
		params [P_THISOBJECT];

		pr _loc = T_GETV("location");
		pr _capInf = CALLM0(_loc, "getCapacityInf");
		pr _garrisons = CALLM0(_loc, "getGarrisons");
		pr _sidesOccupied = [];
		{_sidesOccupied pushBackUnique (CALLM0(_x, "getSide"))} forEach _garrisons;
		{
			//  We can respawn here if there is a garrison of our side and
			// if there is infantry capacity which is calculated from buildings and objects
			pr _enable = (_x in _sidesOccupied) && (_capInf > 0) || T_GETV("forceEnablePlayerRespawn");
			CALLM2(_loc, "enablePlayerRespawn", _x, _enable);
		} forEach [WEST, EAST, INDEPENDENT];

		// Search for nearby cities now
		pr _nearCities = CALLSM2("Location", "nearLocations", CALLM0(_loc, "getPos"), CITY_PLAYER_RESPAWN_ACTIVATION_RADIUS) select {
			CALLM0(_x, "getType") == LOCATION_TYPE_CITY
		};
		{
			pr _gmdata = CALLM0(_x, "getGameModeData");
			if (!IS_NULL_OBJECT(_gmdata)) then {
				CALLM0(_gmdata, "updatePlayerRespawn"); // Cities have an instance of "CivilWarCityData" class
			};
		} forEach _nearCities;
		CITY_PLAYER_RESPAWN_ACTIVATION_RADIUS
	} ENDMETHOD;

	METHOD("forceEnablePlayerRespawn") {
		params [P_THISOBJECT, P_BOOL("_enable")];
		T_SETV("forceEnablePlayerRespawn", _enable);
	} ENDMETHOD;

	// Overrides the location name
	/* public virtual */ METHOD("getDisplayColor") {
		params [P_THISOBJECT];
		private _loc = T_GETV("location");
		if(CALLM1(_loc, "hasGarrisons", FRIENDLY_SIDE)) then {
			[FRIENDLY_SIDE, false] call BIS_fnc_sideColor
		} else {
			if(CALLM1(_loc, "hasGarrisons", ENEMY_SIDE)) then {
				[ENEMY_SIDE, false] call BIS_fnc_sideColor
			} else {
				[1,1,1,1]
			};
		};
	} ENDMETHOD;

	/* virtual override */ METHOD("getMapInfoEntries") {
		private _return = [];
		CRITICAL_SECTION {
			params [P_THISOBJECT];
			// By default get the amount of recruits we can recruit at this place
			pr _loc = T_GETV("location");
			pr _pos = CALLM0(_loc, "getPos");
			pr _cities = CALLM1(gGameMode, "getRecruitCities", _pos);
			pr _nRecruits = CALLM1(gGameMode, "getRecruitCount", _cities);
			_return = [
				["AVAILABLE RECRUITS", str _nRecruits]
			];
		};
		_return
	} ENDMETHOD;

	// STORAGE
	/* override */ METHOD("postDeserialize") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Call method of all base classes
		CALL_CLASS_METHOD("LocationGameModeData", _thisObject, "postDeserialize", [_storage]);

		true
	} ENDMETHOD;

ENDCLASS;
