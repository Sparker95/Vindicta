#include "..\OOP_Light\OOP_Light.h"

/*
Class: IntelInventory
Maintains IDs of free and used intel inventory items, and what data is assigned to each of them.
*/

#define pr private

CLASS("PersonalInventory", "")

	VARIABLE("data");

	METHOD("new") {
		params [P_THISOBJECT];


	} ENDMETHOD;

	METHOD("_addInventoryClass") {
		params [P_THISOBJECT, P_STRING("_className"), P_NUMBER("_amount")];

		pr _data = T_GETV("data");
		
		pr _classData = [];
		_classData resize _amount;
		_data pushBack [_className, _classData];

	} ENDMETHOD;

	METHOD("getInventoryData") {
		params [P_THISOBJECT, P_STRING("_className"), P_NUMBER("_ID")];

		pr _data = T_GETV("data");

		pr _index = _data findIf {_x#0 == _className};

		if (_index != -1) then {
			_data#_index#1#_ID
		} else {
			nil
		};
	} ENDMETHOD;

	METHOD("resetInventoryData") {
				params [P_THISOBJECT, P_STRING("_className"), P_NUMBER("_ID")];

		pr _data = T_GETV("data");

		pr _index = _data findIf {_x#0 == _className};

		if (_index != -1) then {
			(_data#_index#1) set [_ID, nil];
		};
	} ENDMETHOD;

ENDCLASS;