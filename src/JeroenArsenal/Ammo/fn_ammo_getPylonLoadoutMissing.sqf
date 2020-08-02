#include "defineCommon.inc"

//returns [["PylonRack_12Rnd_missiles",12],["PylonRack_12Rnd_missiles",12]]

params["_veh"];

pr _array = [];
{
	pr _name = _x;
	pr _amountCurrent = _veh ammoOnPylon (_forEachIndex + 1);
	pr _amountCfg = getNumber(configfile >> "cfgMagazines">> _name >>"count");
	_array pushBack [_name,(_amountCfg-_amountCurrent)];
}forEach (getPylonMagazines _veh);

_array;