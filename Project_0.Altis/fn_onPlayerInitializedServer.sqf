#include "OOP_Light\OOP_Light.h"

// Gets called on the server after player's GameMode has been initialized.

params ["_uid", "_profileName", "_clientOwner"];

diag_log format ["- - - - - onPlayerInitializedServer - - - - -"];
diag_log format ["  UID:          %1", _uid];
diag_log format ["  PROFILE NAME: %1", _profileName];
diag_log format ["  CLIENT OWNER: %1", _clientOwner];
diag_log format ["- - - - - - - - - - - - - - - - - - - - - - -"];

private _args = [_uid, _profileName, _clientOwner];
CALLM(gPlayerDatabaseServer, "onPlayerConnected", _args);