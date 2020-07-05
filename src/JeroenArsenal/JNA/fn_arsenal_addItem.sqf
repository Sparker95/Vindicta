#include "defineCommon.inc"

params["_object"];

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

		if!(_item isEqualTo "" || {_item isEqualTo "ACE_PreloadedMissileDummy"}) then{

			if(_index == -1)exitWith{["ERROR in additemarsenal: %1", _this] call BIS_fnc_error};
			if(_index == IDC_RSCDISPLAYARSENAL_TAB_CARGOMAG)then{_index = IDC_RSCDISPLAYARSENAL_TAB_CARGOMAGALL};

			//TFAR fix
			pr _radioName = getText(configfile >> "CfgWeapons" >> _item >> "tf_parent");
			if!(_radioName isEqualTo "")then{_item = _radioName};

			//fix for hosted sp
			pr _playersInArsenal = +(_object getVariable ["jna_inUseBy",[]]);
			if!(0 in _playersInArsenal)then{_playersInArsenal pushBackUnique 2;};
			
			//update
			["UpdateItemAdd",[_index, _item, _amount, _object]] remoteExecCall ["jn_fnc_arsenal",_playersInArsenal];
			OOP_INFO_3("jn_arsenal_addItem ----- item: %1 ----- index: %2 ----- amount: %3", _item, _index, _amount);
		};
	} forEach _x;
}foreach _array;





