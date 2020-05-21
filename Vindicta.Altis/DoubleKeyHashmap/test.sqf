#include "..\common.h"

call compile preprocessFileLineNumbers "DoubleKeyHashmap\DoubleKeyHashmap.sqf";

private _hm = NEW("DoubleKeyHashmap", []);

// Try to set values

CALLM3(_hm, "set", "123", "armor", 6);
CALLM3(_hm, "set", "123", "health", 7);
CALLM3(_hm, "set", "123", "money", 8);

CALLM3(_hm, "set", "234", "armor", 9);
CALLM3(_hm, "set", "234", "health", 10);
CALLM3(_hm, "set", "234", "money", 11);

// Try to get values
{
	private _k0 = _x;
	{
		private _k1 = _x;
		private _value = CALLM2(_hm, "get", _k0, _k1);
		diag_log format ["Hashmap %1: key 0, key1, value: [%2, %3, %4]", _hm, _k0, _k1, _value];
	} forEach ["armor", "health", "money"];
} forEach ["123", "234"];

// Try to get all keys
private _allKeys = CALLM1(_hm, "getAllSecondaryKeys", "234");
diag_log format ["Secondary keys of %1: %2", "234", _allKeys];