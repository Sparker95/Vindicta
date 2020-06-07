#include "defineCommon.inc"

//most run locally

params[["_id","",[""]],["_array",[],[[]]]];

// Convert to lowercase
_id = toLower _id;

private _value = pr0_dialogue_sets getVariable _id;

// Add to hashmap
pr0_dialogue_sets setVariable [_id, _array];

// If this dataset was already found, make an error
// However register it anyway, we might use it for debug
if (!isNil "_value") then {
	diag_log format ["[Dialogue]: Error: dataset is already registered: %1",_id];
};