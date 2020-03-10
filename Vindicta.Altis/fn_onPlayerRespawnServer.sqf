#include "OOP_Light\OOP_Light.h"
#include "AI\Stimulus\Stimulus.hpp"
#include "AI\stimulusTypes.hpp"
#define pr private
/*
onPlayerRespawn.sqf calls this when player respawns
Arguments are the same as in onPlayerRespawn.sqf.
*/

diag_log format ["------- onPlayerRespawnServer %1", _this];

params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

// Create a new Unit and attach it to player
pr _args = [[], T_INF, T_INF_rifleman, -1, "", _newUnit];
pr _unit = NEW("Unit", _args);

// Add player's unit to the global garrison
pr _gar = CALLSM1("GameModeBase", "getPlayerGarrisonForSide", side group _newUnit);

CALLM2(_gar, "postMethodAsync", "addUnit", [_unit]);

// Re-evaluate spawn checks of city garrisons and city locations to accelerate the spawning of civilians
// First, update the array of units which can spawn locations/garrisons
CALLM0(gLUAP, "handleMessage"); // It doesn't care about the actual message; We don't care about thread safety here.
// Update garrisons
CALLSM1("Garrison", "updateSpawnStateOfGarrisonsNearPos", getPos _newUnit);
// Update locations
CALLSM1("Location", "processLocationsNearPos", getPos _newUnit);