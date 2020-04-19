_markups = call compile preprocessFileLineNumbers "data.sqf";

private _range = 500;
{ deleteVehicle _x } forEach ((player nearObjects ["Sign_Pointer_Cyan_F", _range]) + (player nearObjects ["Man", _range]) - [player]);

private _group = createGroup west;
private _objects = (nearestObjects [player, [], _range] apply { [false, _x] }) + (nearestTerrainObjects [player, [], _range] apply { [true, _x] });
{
	_x params ["_isTerrainObject", "_object"];
	private _type = typeOf _object;
	private _foundIdx = _markups findIf { _x#0 == _type };
	if(_foundIdx != -1) then {
		_markups#_foundIdx params ["_t", "_m", "_positions"];
		{
			systemChat str _x;
			_x params ["_relPos", "_relDir", "_anim"];

			private _mrk = createVehicle ["Sign_Pointer_Cyan_F", [0,0,0], [], 0, "CAN_COLLIDE"];
			if(_isTerrainObject) then {
				_mrk setPos (_object modelToWorldVisual _relPos);
				_mrk setDir (getDir _object + _relDir);
			} else {
				_mrk attachTo [_object, _relPos];
				_mrk setDir _relDir;
				_mrk attachTo [_object, _relPos];
			};
			_mrk setVariable ["vin_parent", _object];

			//private _unit = _group createUnit ["B_Soldier_A_F", getPos _mrk, [], 0, "CAN_COLLIDE"];
			//[_unit, _anim, "", _mrk] call BIS_fnc_ambientAnim;
		} forEach _positions;
	};
} forEach _objects; //((player nearObjects 500) + nearestTerrainObjects [player, [], 500]) select { !(_x getVariable ["m_tag", false]) };