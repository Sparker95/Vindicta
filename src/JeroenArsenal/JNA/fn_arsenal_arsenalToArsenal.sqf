#include "defineCommon.inc"

params["_arsenalFrom","_arsenalTo"];

//fix for hosted sp
private _playersInEitherArsenal = +(_arsenalFrom getVariable ["jna_inUseBy",[]]);
{
	_playersInEitherArsenal pushBackUnique _x;
} forEach (_arsenalTo getVariable ["jna_inUseBy",[]]);

if !(0 in _playersInEitherArsenal) then {
	_playersInEitherArsenal pushBackUnique 2;
};

// Transfer
["mergeFromOther", [_arsenalFrom, _arsenalTo]] remoteExecCall ["jn_fnc_arsenal", _playersInEitherArsenal];
