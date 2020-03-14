#include "defineCommon.inc"

//most run locally

params[["_id","",[""]],["_array",[],[[]]]];
_id = toLower _id;

private _cur = missionNamespace getVariable ["dialogue_dialogueSets", []];
private _found = false;
{
	if(_x#0 isEqualTo _id)exitWith{
		_found = true;
		_cur set [_forEachindex,[_id,_array]];
		diag_log format ["ERROR DATASET ALL READY REGISTERED: %1",_id];
	};
}forEach _cur;

if(!_found)then{
	_cur pushBack [_id,_array];
	missionNamespace setVariable ["dialogue_dialogueSets", _cur];
};


