#include "..\OOP_Light\OOP_Light.h"

/*
Class: PersonalInventory
Maintains IDs of free and used inventory items, and what data is assigned to each of them.
*/

#define pr private

// Each entry is an array [base class name, counter, array of data per each ID]

// Base class name
#define __ID_CLASS_NAME 0
// Counter of how many items have been used
#define __ID_COUNTER 1
// Array with data per each ID
#define __ID_DATA 2

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
		pr _counter = 0;
		_data pushBack [_className, _counter, _classData];

	} ENDMETHOD;

	METHOD("getInventoryData") {
		params [P_THISOBJECT, P_STRING("_className"), P_NUMBER("_ID")];

		pr _data = T_GETV("data");

		pr _index = _data findIf {_x#__ID_CLASS_NAME == _className};

		if (_index != -1) then {
			_data#_index#__ID_DATA#_ID
		} else {
			OOP_ERROR_1("Base class name %1 not found", _className);
			nil
		};
	} ENDMETHOD;

	METHOD("setInventoryData") {
		params [P_THISOBJECT, P_STRING("_className"), P_NUMBER("_ID"), "_data"];
		
		pr _data = T_GETV("data");

		pr _index = _data findIf {_x#__ID_CLASS_NAME == _className};

		if (_index != -1) then {
			(_data#_index#__ID_DATA) set [_ID, _data];
		} else {
			OOP_ERROR_1("Base class name %1 not found", _className);
		};
	} ENDMETHOD;

	METHOD("resetInventoryData") {
		params [P_THISOBJECT, P_STRING("_className"), P_NUMBER("_ID")];
	
		pr _data = T_GETV("data");

		pr _index = _data findIf {_x#__ID_CLASS_NAME == _className};

		if (_index != -1) then {
			(_data#_index#__ID_DATA) set [_ID, nil];

			// Decrease the counter
			pr _counter = _data#_index#__ID_COUNTER;
			(_data#_index) set [__ID_COUNTER, _counter - 1]; 
		} else {
			OOP_ERROR_1("Base class name %1 not found", _className);
		};
	} ENDMETHOD;

	METHOD("getInventoryClassIDs") {
		params [P_THISOBJECT, P_STRING("_baseClassName"), P_NUMBER["_amount"]];

		pr _data = T_GETV("data");
		pr _return = [];
		pr _run = true;
		pr _amountTotal = 0;
		
		if (_index == -1) then {
			OOP_ERROR_1("Base class name %1 not found", _baseClassName);
			// Return an empty array
			[]
		} else {
			pr _inventoryData = _data#_index#__ID_DATA;
			pr _counter = _data#_index#__ID_COUNTER;
			while {true} do {
				// Try to find an inventory class name which wasn't used yet
				pr _index0 = _inventoryData findIf {isNil {_x}};

				// Bail if we can't find anything any more
				if (_index0 == -1) exitWith {};

				// We have found something, add it to the array
				_amountTotal = _amountTotal + 1;
				_return pushBack _index0;

				// Bail if we have found enough free inventory items
				if (_amountTotal == _amount) exitWith {};
			};

			// Increase the counter
			_counter = _counter + _amountTotal;
			(_data#_index) set [__ID_COUNTER, _counter];

			_return
		};
	} ENDMETHOD;

ENDCLASS;