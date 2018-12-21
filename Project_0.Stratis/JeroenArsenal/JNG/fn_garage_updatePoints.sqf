#include "defineCommon.inc"

params ["_object","_amount","_type"];

//update
pr _playersInGarage = +(_object getVariable ["jng_playersInGarage",[]]);
if!(0 in _playersInGarage)then{_playersInGarage pushBackUnique 2;};

["UpdatePoints",[_amount,_type]] remoteExecCall ["jn_fnc_garage",_playersInGarage];
