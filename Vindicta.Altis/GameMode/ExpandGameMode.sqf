#include "common.hpp"

#define pr private

#define OOP_CLASS_NAME ExpandGameMode
CLASS("ExpandGameMode", "GameModeBase")

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("name", "expand");
		T_SETV("spawningEnabled", false); // It's done by AICommander now
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

	ENDMETHOD;
		
	/* protected virtual */ METHOD(getLocationOwner)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		OOP_DEBUG_MSG("%1", [_loc]);
		if(GETV(_loc, "type") in [LOCATION_TYPE_AIRPORT, LOCATION_TYPE_BASE]) then {
			OOP_INFO_1("Found airport: %1", _loc);
			independent
		} else {
			CIVILIAN
		}
	ENDMETHOD;

	METHOD(getRecruitCount)
		params [P_THISOBJECT, P_ARRAY("_cities")];
		100
	ENDMETHOD;

	METHOD(getRecruitmentRadius)
		params [P_THISCLASS];
		10000
	ENDMETHOD;

	METHOD(initLocationGameModeData)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		private _type = CALLM0(_loc, "getType");
		private _data = NEW("ExpandLocationData", [_loc]);
		SETV(_loc, "gameModeData", _data);
		
		PUBLIC_VAR(_loc, "gameModeData");

		// Update respawn rules
		if (_type != LOCATION_TYPE_CITY) then { // Cities will search for other nearby locations which will slow down everything probably, let's not use that
			private _gmdata = CALLM0(_loc, "getGameModeData");
			CALLM0(_gmdata, "updatePlayerRespawn");
		};

		// Return
		CALLM0(_loc, "getGameModeData")
	ENDMETHOD;

	METHOD(initServerOnly)
		params [P_THISOBJECT];
				
		// Create LocationGameModeData objects for all locations
		{
			private _loc = _x;
			T_CALLM1("initLocationGameModeData", _loc);
		} forEach GET_STATIC_VAR("Location", "all");
	ENDMETHOD;

	/* protected virtual */ METHOD(initClientOnly)
		params [P_THISOBJECT];

		["Game Mode", "Add activity here", {
			// Call to server to add the activity
			[[getPos player], {
				params ["_playerPos"];
				CALL_STATIC_METHOD("AICommander", "addActivity", [ENEMY_SIDE ARG _playerPos ARG 10]);
			}] remoteExec ["call", 0];
		}] call pr0_fnc_addDebugMenuItem;

		["Game Mode", "Get local info", {
			// Call to server to get the info
			[[getPos player, clientOwner], {
				params ["_playerPos", "_clientOwner"];
				private _enemyCmdr = CALL_STATIC_METHOD("AICommander", "getAICommander", [ENEMY_SIDE]);
				private _activity = CALLM(_enemyCmdr, "getActivity", [_playerPos ARG 500]);
				// Callback to client with the result
				[format["Phase %1, local activity %2", GETV(gGameMode, "phase"), _activity]] remoteExec ["systemChat", _clientOwner];
			}] remoteExec ["call", 0];
		}] call pr0_fnc_addDebugMenuItem;

	ENDMETHOD;
	
ENDCLASS;

#define OOP_CLASS_NAME ExpandLocationData
CLASS("ExpandLocationData", "LocationGameModeData")

	METHOD(new)
		params [P_THISOBJECT];
	ENDMETHOD;

	/* virtual override */ METHOD(updatePlayerRespawn)
		params [P_THISOBJECT];

		pr _loc = T_GETV("location");
		pr _capInf = CALLM0(_loc, "getCapacityInf");
		pr _garrisons = CALLM0(_loc, "getGarrisons");
		pr _sidesOccupied = [];
		{_sidesOccupied pushBackUnique (CALLM0(_x, "getSide"))} forEach _garrisons;
		{
			//  We can respawn here if there is a garrison of our side
			pr _enable = (_x in _sidesOccupied);
			CALLM2(_loc, "enablePlayerRespawn", _x, _enable);
		} forEach [WEST, EAST, INDEPENDENT];
	ENDMETHOD;

ENDCLASS;