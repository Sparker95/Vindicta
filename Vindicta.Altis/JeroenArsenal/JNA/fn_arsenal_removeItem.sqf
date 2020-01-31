#include "defineCommon.inc"

params ["_object"];

pr "_array";

if(typeName (_this select 1) isEqualTo "SCALAR")then{//[_index, _item] and [_index, _item, _amount];
	params["","_index","_item",["_amount",1]];
	_array = EMPTY_ARRAY;
	_array set [_index,[[_item,_amount]]];
}else{
	_array = _this select 1;
};

{
	pr _index = _forEachIndex;
	{
		pr _item = _x select 0;
		pr _amount = _x select 1;

		if!(_item isEqualTo "")then{

			if(_index == -1)exitWith{["ERROR in removeitemarsenal: %1", _this] call BIS_fnc_error};
			if(_index == IDC_RSCDISPLAYARSENAL_TAB_CARGOMAG)then{_index = IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL};

			//update
			pr _playersInArsenal = +(_object getVariable ["jna_inUseBy",[]]);
			if!(0 in _playersInArsenal)then{_playersInArsenal pushBackUnique 2;};
			["UpdateItemRemove",[_index, _item, _amount,_object]] remoteExecCall ["jn_fnc_arsenal",_playersInArsenal];
		};
	} forEach _x;
}foreach _array;
