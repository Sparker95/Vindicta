params [["_civ", objNull, [objNull]], ["_whoIsTalking", objNull, [objNull]], ["_start", false, [false]]];

if (isNull _civ) exitWith {};

private _lookedAtBy = _civ getVariable ["#interactWith",[]];

if (_start) then {
	_lookedAtBy pushBack _whoIsTalking;
} else {
	_lookedAtBy deleteAt (_lookedAtBy find _whoIsTalking);
};

_civ setVariable ["#interactWith", _lookedAtBy];