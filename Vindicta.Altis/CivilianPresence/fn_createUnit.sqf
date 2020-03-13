#include "common.hpp"

params [["_module",objNull,[objNull]],["_pos",[],[[]]]];

//randomize position
if (count _pos == 0) then
{
	_pos = getPos selectRandom (_module getVariable ["#modulesUnit",[]]);
};

private _posASL = (AGLToASL _pos) vectorAdd [0,0,1.5];


//check if any player can see the point of creation
private _seenBy = allPlayers select {_x distance _pos < 50 || {(_x distance _pos < 150 && {([_x,"VIEW"] checkVisibility [eyePos _x, _posASL]) > 0.5})}};

//["[ ] Trying to create unit on position %1 that is seen by %2",_pos,_seenBy] call bis_fnc_logFormat;

//terminate if any player can see the position
if (count _seenBy > 0) exitWith {objNull};

private _class = format["vin_cp_%1",selectRandom (_module getVariable ["#unitTypes",[]])];

// Some units are suspicious and must be created as units, not agents
private _suspicious = (random 10 < 5);

private _unit = objNull;

if (!(_module getVariable ["#useAgents",true]) || _suspicious) then
{
	private _group = createGroup [west, true];
	_unit = _group createUnit [_class, _pos, [], 0, "NONE"];
	[_unit] joinSilent _group;
	_unit setCaptive true;
	if (_suspicious) then {
		_unit setVariable ["bSuspicious", true, true]; // So that sensorGroupTargets can recognize it
	};
	_unit setVariable ["#isAgent", false];

	// For some reason danger.fsm does not trigger for dangers of the same side... we can do it with event handlers instead
	_unit addEventHandler ["FiredNear", {
		params ["_unit"]; _unit setVariable ["#newDanger", true];
	}];
	_unit addEventHandler ["Hit", {
		params ["_unit"]; _unit setVariable ["#newDanger", true];
	}];
}
else
{
	_unit = createAgent [_class, _pos, [], 0, "NONE"];
	_unit setVariable ["#isAgent", true];
};

//make backlink to the core module
_unit setVariable ["#core",_module];

// Initialize variables
[_unit] call CivPresence_fnc_initUnitDialogVariables;

_unit setBehaviour "CARELESS";
//_unit spawn (_module getVariable ["#onCreated",{}]); // onCreated is not set anywhere?
_unit execFSM "CivilianPresence\FSM\behavior_2.fsm";

// Set special variable on unit
_unit setVariable [CIVILIAN_PRESENCE_CIVILIAN_VAR_NAME, true, true]; // Set a variable on the created unit

// Add 'untie' action to unit
private _JIPID = if (isNil "gCPUntieID") then { 0 } else {gCPUntieID};
private _JIPString = format ["CP_untie_%1", _JIPID];
_unit setVariable ["CP_untieJIPID", _JIPString];
[_unit] remoteExecCall ["CivPresence_fnc_addUntieActionLocal", 0, _JIPString];
_unit addEventHandler ["Deleted", {
	params ["_entity"];
	private _jipstring = _entity getVariable ["CP_untieJIPID", ""];
	if (_jipstring != "") then { remoteExecCall ["", _jipstring]; };
}];
gCPUntieID = _JIPID + 1;

// Finally lets apply our civ settings from selected faction template
private _civTemplate = CALLM1(gGameMode, "getTemplate", civilian);
private _templateClass = [_civTemplate, T_INF, T_INF_unarmed, -1] call t_fnc_select;
if ([_templateClass] call t_fnc_isLoadout) then {
	[_unit, _templateClass] call t_fnc_setUnitLoadout;
} else {
	// Only load out is allowed!
};

_unit