#include "common.hpp"

/*
Class: GameMode.CivilWarLocationData
Game mode data for general locations
*/

#define pr private

#define OOP_CLASS_NAME CivilWarLocationData
CLASS("CivilWarLocationData", "LocationGameModeData")

	// Setting it to true will force enable respawn of players here regardless of other rules
	VARIABLE_ATTR("forceEnablePlayerRespawn", [ATTR_SAVE]);
	VARIABLE("ownerSide");

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("forceEnablePlayerRespawn", false);
		T_SETV_PUBLIC("ownerSide", CIVILIAN);
	ENDMETHOD;
	
	/* virtual override server */ METHOD(updatePlayerRespawn)
		params [P_THISOBJECT];

		pr _loc = T_GETV("location");
		pr _capInf = CALLM0(_loc, "getCapacityInf");
		pr _garrisons = CALLM0(_loc, "getGarrisons");
		pr _sidesOccupied = [];
		{_sidesOccupied pushBackUnique (CALLM0(_x, "getSide"))} forEach _garrisons;
		{
			//  We can respawn here if there is a garrison of our side and
			// if there is infantry capacity which is calculated from buildings and objects - - DISABLED FOR NOW
			pr _enable = (_x in _sidesOccupied) /*&& (_capInf > 0)*/ || T_GETV("forceEnablePlayerRespawn");
			CALLM2(_loc, "enablePlayerRespawn", _x, _enable);
		} forEach [WEST, EAST, INDEPENDENT];

		// Search for nearby cities now
		pr _nearCities = CALLSM2("Location", "overlappingLocations", CALLM0(_loc, "getPos"), CITY_PLAYER_RESPAWN_ACTIVATION_RADIUS) select {
			CALLM0(_x, "getType") == LOCATION_TYPE_CITY
		};

		{
			pr _gmdata = CALLM0(_x, "getGameModeData");
			if (!IS_NULL_OBJECT(_gmdata)) then {
				CALLM0(_gmdata, "updatePlayerRespawn"); // Cities have an instance of "CivilWarCityData" class
			};
		} forEach _nearCities;

		private _oldOwner = T_GETV("ownerSide");
		private _newOwner = if(FRIENDLY_SIDE in _sidesOccupied) then {
			FRIENDLY_SIDE
		} else {
			if(ENEMY_SIDE in _sidesOccupied) then {
				ENEMY_SIDE
			} else {
				CIVILIAN
			};
		};

		if(_newOwner != _oldOwner) then {
			T_SETV_PUBLIC("ownerSide", _newOwner);
			if(_newOwner == FRIENDLY_SIDE) then {
				// Notify players of what happened
				private _args = ["LOCATION CLAIMED", format["%1 was claimed", CALLM0(_loc, "getDisplayName")], "Garrison some fighters to hold it"];
				REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createLocationNotification", _args, ON_CLIENTS, NO_JIP);
			} else {
				if(_oldOwner == FRIENDLY_SIDE) then {
					// Notify players of what happened
					private _args = ["LOCATION LOST", format["%1 was lost", CALLM0(_loc, "getDisplayName")], "Send some fighters to retake it"];
					REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createLocationNotification", _args, ON_CLIENTS, NO_JIP);
				};
			};
		};
		CITY_PLAYER_RESPAWN_ACTIVATION_RADIUS
	ENDMETHOD;

	METHOD(forceEnablePlayerRespawn)
		params [P_THISOBJECT, P_BOOL("_enable")];
		T_SETV("forceEnablePlayerRespawn", _enable);
	ENDMETHOD;

	// Overrides the location name
	/* public virtual client */ METHOD(getDisplayColor)
		params [P_THISOBJECT];
		switch T_GETV("ownerSide") do {
			case FRIENDLY_SIDE: {
				[FRIENDLY_SIDE, false] call BIS_fnc_sideColor
			};
			case ENEMY_SIDE: {
				[ENEMY_SIDE, false] call BIS_fnc_sideColor
			};
			default {
				[1,1,1,1]
			};
		}
	ENDMETHOD;

	/* virtual override client */ METHOD(getMapInfoEntries)
		private _return = [];
		CRITICAL_SECTION {
			params [P_THISOBJECT];
			// By default get the amount of recruits we can recruit at this place
			pr _loc = T_GETV("location");
			pr _type = CALLM0(_loc, "getType");
			if(_type in LOCATIONS_RECRUIT) then {
				pr _pos = CALLM0(_loc, "getPos");
				pr _cities = CALLM1(gGameMode, "getRecruitCities", _pos);
				pr _nRecruits = CALLM1(gGameMode, "getRecruitCount", _cities);
				_return = _return + [["AVAILABLE RECRUITS", str _nRecruits]];
			};
			if(_type in LOCATIONS_BUILD_PROGRESS) then {
				pr _buildProgress = GETV(_loc, "buildProgress");
				_return = _return + [["BUILD PROGRESS", format["%1%2", _buildProgress * 100, "%"]]];
			};
		};
		_return
	ENDMETHOD;

	// STORAGE
	/* override server */ METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Call method of all base classes
		CALL_CLASS_METHOD("LocationGameModeData", _thisObject, "postDeserialize", [_storage]);
		T_SETV_PUBLIC("ownerSide", CIVILIAN);

		true
	ENDMETHOD;

ENDCLASS;
