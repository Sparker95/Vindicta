#include "common.h"
#include "AI\Stimulus\Stimulus.hpp"
#include "AI\stimulusTypes.hpp"
#include "CivilianPresence\CivilianPresence.hpp"
#include "Location\Location.hpp"
#include "AI\Commander\AICommander.hpp"
#include "AI\Commander\LocationData.hpp"

/*
This is an event script called by arma. But also we call it ourselves.
https://community.bistudio.com/wiki/Event_Scripts

Executed locally when player respawns in a multiplayer mission or spawns initially in SP session.

Currently player respawns right after death, later we enable the respawn screen to let him choose where to spawn.
This event script will also fire at the beginning of a mission if respawnOnStart is 0 or 1,
oldUnit will be objNull in this instance.
This script will not fire at mission start if respawnOnStart equals -1.
*/

#define pr private

params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

//"gamemode.rpt" ofstream_write (format ["--- onPlayerRespawn.sqf: %1", _this]);

// Set player's position to default respawn position, until player chooses a respawn point.
// "respawn_default" marker should be present
private _pos = getMarkerPos "respawn_default";
if (_pos isEqualTo [0, 0, 0]) then {
    private _text = "[Vindicta] Error: respawn_default marker does not exist, player is respawned at [0, 0, 0]";
    diag_log _text;
    systemChat _text;
};
_newUnit setPos _pos;

// Bail instantly if game mode init is disabled
#ifdef GAME_MODE_DISABLE
if (true) exitWith {};
#endif

// Remove player's weapons
removeAllWeapons player;

// If it's first respawn, show a hint
if (isNil {vin_bRespawned}) then {
    vin_bRespawned = true;
    private _args = [localize "STR_PS_CONTROLS", localize "STR_PS_U_FOR_MENU", localize "STR_PS_CHECK_TUTORIAL"];
    CALLSM("NotificationFactory", "createHint", _args);
};

// Open our beautiful map, enable respawn panel
openMap [true, false];  // Let's not force it... who knows if arma UI locks up again
if(!isNil "gPlayerUIInitialized" && {gPlayerUIInitialized}) then {
    CALLM1(gClientMapUI, "respawnPanelEnable", true);
};