//todo redo this crap

params ["_owner", "_gar", "_loc", "_unitData"];

private _unit = [_gar, _unitData] call gar_fnc_getUnit;
private _groupID = _unit select 3;
private _group = [_gar, _groupID] call gar_fnc_getGroup;
private _groupHandle = _group select 1;

private _garDst = HCGarrisonWEST;
private _side = [_gar] call gar_fnc_getSide;
switch(_side) do
{
	case WEST:
	{
		_garDst = HCGarrisonWEST;
	};

	case EAST:
	{
		_garDst = HCGarrisonEAST;
	};
};
private _returnArray = []; //moveGroup will write the groupid here

[_garDst, _loc] call gar_fnc_setLocation;

private _rID = [_gar, _garDst, _groupID, _returnArray] call gar_fnc_moveGroup;
waitUntil {[_gar, _rID] call gar_fnc_requestDone};

//[_garDst, objNull] call gar_fnc_setLocation;

_groupID = _returnArray select 0;

_group = [_garDst, _groupID] call gar_fnc_getGroup;
_groupHandle = _group select 1;

diag_log format ["transferUnitsToHC.sqf: moveGroup request done!"];

[_groupHandle] remoteExecCall ["ui_fnc_requestReinfClient", _owner];