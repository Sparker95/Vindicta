// Call it locally to enable or disable player markers
params [["_enable", true, [false]]];

// We just set the global flag here
gUIEnablePlayerMarkers = _enable;

// Add periodic update of player markers
if (isNil "gUIPlayerMarkersRefreshEnabled") then {
	// We only want to add the waitAndExecute once
	// Otherwise we will be re-adding it on every call to this function
	[ui_fnc_updatePlayerMarkers, 0, 1] call CBA_fnc_waitAndExecute;
	gUIPlayerMarkersRefreshEnabled = true;
};