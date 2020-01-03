#define OOP_INFO
#define OOP_DEBUG
#include "OOP_Light\OOP_Light.h"

// Bail if game mode init is disabled
#ifdef GAME_MODE_DISABLE
if (true) exitWith {
	// Just create some respawn points
	{
		createMarker [_x, [22000, 18000, 0]];
	} forEach ["respawn_west", "respawn_east", "respawn_guerrila"];
};
#endif

// Typical initialization
if (!CALLM0(gGameManager, "isGameModeInitialized")) exitWith {
	if (HAS_INTERFACE) then {
		0 spawn {
			waitUntil {!isNull (findDisplay 46)};
			CALLSM1("NotificationFactory", "createSystem", "Press [U] to setup the mission or load a saved game");
		};
	};
};

// Code which adds all objects to be edited by zeus
if (isServer) then {  
    [] spawn { 
        sleep 5;  
        while {true} do {  
            {  
                _x addCuratorEditableObjects [allUnits, true];  
                _x addCuratorEditableObjects [vehicles, true];  
                sleep 10;  
            } forEach allCurators;   
        };  
    };   
};