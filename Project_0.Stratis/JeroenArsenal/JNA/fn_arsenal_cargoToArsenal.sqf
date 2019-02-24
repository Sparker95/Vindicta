#include "defineCommon.inc"

params["_objectFrom","_objectTo"];

pr _array = _objectFrom call jn_fnc_arsenal_cargoToArray;

//clear cargo
clearMagazineCargoGlobal _objectFrom;
clearItemCargoGlobal _objectFrom;
clearweaponCargoGlobal _objectFrom;
clearbackpackCargoGlobal _objectFrom;


[_objectTo,_array] remoteExec ["jn_fnc_arsenal_arrayToArsenal",2];