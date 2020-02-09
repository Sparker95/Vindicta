params ["_tName"];

// SAVEBREAK >>>
// Remapping old faction names to new ones
private _mapping = [
	["tRHS_AAF2017_police", "tRHS_AAF_police"],
	["tRHS_AAF2017_elite", "tRHS_AAF_2020"]
];

private _remap = _mapping findIf { _x#0 isEqualTo _tName };
if(_remap != -1) then {
	_tName = _mapping#_remap#1;
};
// <<< SAVEBREAK

missionNamespace getVariable [_tName, []]