#include "common.h"

// Gets called on the server after player's GameMode has been initialized.

params ["_uid", "_profileName", "_clientOwner", "_side"];

diag_log format ["- - - - - onPlayerInitializedServer - - - - -"];
diag_log format ["  UID:          %1", _uid];
diag_log format ["  PROFILE NAME: %1", _profileName];
diag_log format ["  CLIENT OWNER: %1", _clientOwner];
diag_log format ["- - - - - - - - - - - - - - - - - - - - - - -"];

// Add the player to the player database
private _args = [_uid, _profileName, _clientOwner];
CALLM(gPlayerDatabaseServer, "onPlayerConnected", _args);

// Send data about all garrisons to the player
// Don't need it any more since I've converted it to use JIP IDs instead
//CALLM2(gGarrisonServer, "postMethodAsync", "onClientConnected", [_clientOwner ARG _side]);