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

private _class = format["CivilianPresence_%1",selectRandom (_module getVariable ["#unitTypes",[]])];

private _unit = if (_module getVariable ["#useAgents",true]) then
{
	createAgent [_class, _pos, [], 0, "NONE"];
}
else
{
	(createGroup civilian) createUnit [_class, _pos, [], 0, "NONE"];
};

//make backlink to the core module
_unit setVariable ["#core",_module];

_unit setBehaviour "CARELESS";
_unit spawn (_module getVariable ["#onCreated",{}]);
_unit execFSM "CivilianPresence\FSM\behavior.fsm";

_unit