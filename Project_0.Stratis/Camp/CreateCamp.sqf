private _allLocations = GETSV("Location", "all");
private _isPosAllowed = true;
private _pos = getPos player;

{
	pr _locPos = GETV(_x, "pos");
	private _dist = _pos distance _locPos;
	diag_log format ["DEBUG: location: %1", _x];
	// if (_dist < 1000) exitWith {_isPosAllowed = false};
	// TODO if (_dist < 3000 && location == Camp) exitWith {_isPosAllowed = false};
} forEach _allLocations;

if (_isPosAllowed) then {
	NEW("Camp", [_pos]);
} else {
	hint "Too close from another Location (need 1km)"
}