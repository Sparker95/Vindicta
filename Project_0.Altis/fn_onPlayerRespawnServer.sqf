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
pr _gar = switch (side group _newUnit) do {
	case WEST: {gGarrisonPlayersWest};
	case EAST: {gGarrisonPlayersEast};
	case INDEPENDENT: {gGarrisonPlayersInd};
	default {gGarrisonPlayersCiv};
};

CALLM2(_gar, "postMethodAsync", "addUnit", [_unit]);
