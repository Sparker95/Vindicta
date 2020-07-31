#include "common.h"
#include "AI\Stimulus\Stimulus.hpp"
#include "AI\stimulusTypes.hpp"
#define pr private
/*
onPlayerRespawn.sqf calls this when player respawns
Arguments are the same as in onPlayerRespawn.sqf.
*/

diag_log format ["------- onPlayerRespawnServer %1", _this];

params	[P_OBJECT("_newUnit"), P_OBJECT("_oldUnit"), P_SIDE("_playerSide"), P_ARRAY("_respawnPos")];

// Re-evaluate spawn checks of city garrisons and city locations to accelerate the spawning of civilians
// First, update the array of units which can spawn locations/garrisons
CALLM0(gLUAP, "handleMessage"); // It doesn't care about the actual message; We don't care about thread safety here.
// Update garrisons
CALLSM1("Garrison", "updateSpawnStateOfGarrisonsNearPos", getPos _newUnit);
// Update locations
CALLSM1("Location", "processLocationsNearPos", getPos _newUnit);

if(IS_MULTIPLAYER) then {
	// Stop negative score bugs (hopefully)
	_newUnit addScore 1000000;
};

if(isNil {_newUnit getVariable "__player_real_side"}) then {
	// We can assume the side of the group it is spawning into is correct, or more things would be broken than this little variable could solve
	_newUnit setVariable ["__player_real_side", _playerSide];
};

// We make sure players stay on the correct side, some 3rd party group management system might put them in a group of the wrong side accidentally
if(isNil "gPlayerSideCorrection") then {
	gPlayerSideCorrection = [
		{
			// This check takes 0.004ms, and we can't afford to let player be on incorrect side any longer than we have to,
			// so we do it every frame.
			{
				private _realSide = _x getVariable ["__player_real_side", sideUnknown];
				if(_realSide != sideUnknown && _realSide != side group _x) then {
					systemChat format ["WARNING: units %1 detected on incorrect side %2, switching back to %3", units group _x, side group _x, _realSide];
					private _newGroup = createGroup _realSide;
					(units group _x) joinSilent _newGroup;
				};
			} forEach HUMAN_PLAYERS;
		},
		0,
		[]
	] call CBA_fnc_addPerFrameHandler;
};

// Post message to main thread to finish player spawn
pr _args = [_newUnit, _playerSide, _respawnPos];
CALLM2(gMessageLoopMainManager, "postMethodAsync", "finishPlayerSpawn", _args);