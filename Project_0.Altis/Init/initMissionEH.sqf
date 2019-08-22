gPlayersList = [];

// TODO: handle HC connections
_onPlayerConnectedMissionEH = {
	params ["_id", "_uid", "_name", "_jip", "_owner"];
	
	if (_owner == 2) exitWith {};

	

	// Todo rework this player list thing
	gPlayersList pushBackUnique _this;
	publicVariable "gPlayersList";

	diag_log format ["debug EHConn gPlayersList %1", gPlayersList];
};
handlerCon = addMissionEventHandler ["PlayerConnected", _onPlayerConnectedMissionEH];

_onPlayerDisconnectedMissionEH = {
	gPlayersList = gPlayersList - [_this];
	publicVariable "gPlayersList";
	diag_log format ["debug EHDisco gPlayersList %1", gPlayersList];
};
handlerDecon = addMissionEventHandler ["PlayerDisconnected", _onPlayerDisconnectedMissionEH];

// If SP force add the player since these events dont fire
// TODO: remove if player list is deleted on SP
if (isServer && hasInterface) then {
	gPlayersList pushBackUnique player;
	publicVariable "gPlayersList";
	diag_log format ["debug SP gPlayersList %1", gPlayersList];
};

