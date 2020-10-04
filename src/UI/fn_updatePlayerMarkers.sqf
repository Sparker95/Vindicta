/*
Updates player markers for all players.
Must be run locally.
It auto-adds itself to be executed periodically.
*/

#define pr private

pr _allPlayersPrev = if (isNil "gUIAllPlayersPrev") then { [] } else {gUIAllPlayersPrev};
pr _allPlayerVehiclesPrev = if (isNil "gUIAllPlayerVehiclesPrev") then {[]} else {gUIAllPlayerVehiclesPrev};
pr _allPlayers = (allPlayers select {(side group _x) == playerSide}) /*allUnits*/ - (entities "HeadlessClient_F");
//pr _allPlayers = allUnits - (entities "HeadlessClient_F");
pr _allPlayerVehicles = [];
pr _nextID = if (isNil "gUINextMapMarkerID") then {0} else {gUINextMapMarkerID};

// Alpha for enabled markers
// If markers are disabled, we just set their alpha to 0
pr _alphaEnabled = [0, 1] select (gUIEnablePlayerMarkers && {if (! isNil "vin_diff_allowPlayerMarkers") then {vin_diff_allowPlayerMarkers} else {true} }); // vin_enablePlayerMarkers is from CBA settings

// Delete markers for previous players which have been killed
{
	// If old object is not alive any more
	if (!(alive _x)) then {
		pr _mrk = _x getVariable ["ui_mapMarker", ""];
		if (_mrk != "") then {
			deleteMarkerLocal _mrk;
			_x setVariable ["ui_mapMarker", nil];
		};
	};
} forEach _allPlayersPrev;

// Delete markers for all previous vehicles which have been killed
// Also delete marker if crew of the vehicle has no players any more
{
	if (
		!(alive _x) ||
		{count ( ((crew _x) select {alive _x}) arrayIntersect _allPlayers) == 0}	// No more alive players in this vehicle
	) then {
		pr _mrk = _x getVariable ["ui_mapMarker", ""];
		if (_mrk != "") then {
			deleteMarkerLocal _mrk;
			_x setVariable ["ui_mapMarker", nil];
		};
	};
} forEach _allPlayerVehiclesPrev;

// Create markers for all players
{
	pr _mrk = _x getVariable ["ui_mapMarker", "_none_"];
	if ((markerShape _mrk) == "") then {
		_mrk = format ["ui_mapMarker_%1", _nextID];
		_nextID = _nextID + 1;
		createMarkerLocal [_mrk, getPosASL _x];
		_mrk setMarkerShapeLocal "ICON";
		_mrk setMarkerColorLocal "colorBlue";
		_mrk setMarkerTypeLocal "mil_dot";
		_mrk setMarkerTextLocal (name _x);
		_x setVariable ["ui_mapMarker", _mrk];

		// Add deleted EH
		pr _deletedEH = _x getVariable ["ui_deletedEH", -1];
		if (_deletedEH == -1) then {
			pr _deletedEH = _x addEventHandler ["Deleted", {
				params ["_unit"];
				pr _mrk = _unit getVariable ["ui_mapMarker", ""];
				if (_mrk != "") then {
					deleteMarkerLocal _mrk;
					_unit setVariable ["ui_mapMarker", nil];
				};
			}];
			_x setVariable ["ui_deletedEH", _deletedEH];
		};
	};

	// Update alpha and pos, depending if unit is in vehicle or on foot
	if ((vehicle _x) isEqualTo _x) then {
		// Unit is on foot
		// Update pos, enable marker
		_mrk setMarkerAlphaLocal _alphaEnabled;
		_mrk setMarkerPosLocal (getPosASL _x);
	} else {
		// Unit is in vehicle
		// Disable his marker
		_mrk setMarkerAlphaLocal 0;

		// Add unit's vehicle into vehicle array
		_allPlayerVehicles pushBackUnique (vehicle _x);
	};
} forEach _allPlayers;

// Create markers for all vehicles with players
{
	pr _mrk = _x getVariable ["ui_mapMarker", ""];
	if ((markerShape _mrk) == "") then {
		_mrk = format ["ui_mapMarker_%1", _nextID];
		_nextID = _nextID + 1;
		createMarkerLocal [_mrk, getPosASL _x];
		_mrk setMarkerShapeLocal "ICON";
		_mrk setMarkerColorLocal "colorBlue";
		_mrk setMarkerTypeLocal "mil_dot";
		_x setVariable ["ui_mapMarker", _mrk];

		// Add deleted EH
		pr _deletedEH = _x getVariable ["ui_deletedEH", -1];
		if (_deletedEH == -1) then {
			pr _deletedEH = _x addEventHandler ["Deleted", {
				params ["_unit"];
				pr _mrk = _unit getVariable ["ui_mapMarker", ""];
				if (_mrk != "") then {
					deleteMarkerLocal _mrk;
					_unit setVariable ["ui_mapMarker", nil];
				};
			}];
			_x setVariable ["ui_deletedEH", _deletedEH];
		};
	};

	// Set marker text and alpha
	_mrk setMarkerAlphaLocal _alphaEnabled;
	pr _crewNames = ( ((crew _x) select {alive _x}) arrayIntersect _allPlayers ) apply {name _x};
	pr _text = "";
	{ _text = _text + _x + ",  " } forEach _crewNames;
	_mrk setMarkerTextLocal _text;
	_mrk setMarkerPosLocal (getPosASL _x);
} forEach _allPlayerVehicles;

// Set array with players we iterated through previously
gUIAllPlayersPrev = _allPlayers;

// Set array with all player vehicles we iterated through previously
gUIAllPlayerVehiclesPrev = _allPlayerVehicles;

// Set next ID variable
gUINextMapMarkerID = _nextID;

// Loop it
[ui_fnc_updatePlayerMarkers, 0, 1] call CBA_fnc_waitAndExecute;