#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Intel.rpt"
#include "..\OOP_Light\OOP_Light.h"
#include "InventoryItems.hpp"

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
// Array with true/false which tells if this data cell is occupied
#define __ID_BITFIELD 3

CLASS("PersonalInventory", "")

	VARIABLE("data");

	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV("data", []);

		{
			CALLM2(_thisObject, "_addInventoryClass", _x, INTEL_INVENTORY_CLASSES_COPY_AMOUNT);
		} forEach INTEL_INVENTORY_ALL_CLASSES;
	} ENDMETHOD;

	METHOD("_addInventoryClass") {
		params [P_THISOBJECT, P_STRING("_className"), P_NUMBER("_amount")];

		pr _data = T_GETV("data");
		
		pr _classData = [];
		_classData resize _amount;
		pr _bitfield = [];
		_bitfield resize _amount;
		_bitfield = _bitfield apply {false};
		pr _counter = 0;
		_data pushBack [_className, _counter, _classData, _bitfield];

	} ENDMETHOD;

	// Returns [_data, _dataExists]
	METHOD("getInventoryData") {
		pr _returnData = 0;
		pr _returnDataExists = false;
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_STRING("_className"), P_NUMBER("_ID")];

			pr _data = T_GETV("data");

			pr _index = _data findIf {_x#__ID_CLASS_NAME == _className};

			if (_index != -1) then {
				// Check if this cell is occupied or not
				if (_data#_index#__ID_BITFIELD#_ID) then {
					_returnData = _data#_index#__ID_DATA#_ID;
					if (isNil "_returnData") then {
						_returnData = 0;
					} else {
						_returnDataExists = true;
					};
				};
			} else {
				OOP_ERROR_1("Base class name %1 not found", _className);
			};
			
			OOP_INFO_3("getInventoryData: %1 %2   return: %3", _className, _ID, [_returnData ARG _returnDataExists]);
		};
		[_returnData, _returnDataExists]
	} ENDMETHOD;

	METHOD("setInventoryData") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_STRING("_className"), P_NUMBER("_ID"), "_inventoryData"];
			
			pr _data = T_GETV("data");

			pr _index = _data findIf {_x#__ID_CLASS_NAME == _className};

			if (_index != -1) then {
				(_data#_index#__ID_DATA) set [_ID, _inventoryData];

				// Return this ID to the free ID pool if we have set data to nil
				if (isNil "_inventoryData") then {
					// Reset bitfield
					(_data#_index#__ID_BITFIELD) set [_ID, false];

					// Decrease the counter
					pr _counter = _data#_index#__ID_COUNTER;
					(_data#_index) set [__ID_COUNTER, _counter - 1];
				};
			} else {
				OOP_ERROR_1("Base class name %1 not found", _className);
			};
		};
	} ENDMETHOD;



	/*
	METHOD("resetInventoryData") {
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_STRING("_className"), P_NUMBER("_ID")];
		
			pr _data = T_GETV("data");

			pr _index = _data findIf {_x#__ID_CLASS_NAME == _className};

			if (_index != -1) then {
				// Reset data
				(_data#_index#__ID_DATA) set [_ID, nil];

				// Reset bitfield
				(_data#_index#__ID_BITFIELD) set [_ID, false];

				// Decrease the counter
				pr _counter = _data#_index#__ID_COUNTER;
				(_data#_index) set [__ID_COUNTER, _counter - 1]; 
			} else {
				OOP_ERROR_1("Base class name %1 not found", _className);
			};
		};
	} ENDMETHOD;
	*/

	METHOD("getInventoryClassIDs") {
		pr _return = [];

		CRITICAL_SECTION {
			params [P_THISOBJECT, P_STRING("_baseClassName"), P_NUMBER("_amount")];

			pr _data = T_GETV("data");
			pr _run = true;
			pr _amountTotal = 0;
			
			pr _index = _data findIf {_x#__ID_CLASS_NAME == _baseClassName};

			if (_index == -1) then {
				OOP_ERROR_1("Base class name %1 not found", _baseClassName);
				// Return an empty array
				[]
			} else {
				pr _inventoryData = _data#_index#__ID_DATA;
				pr _bitfield = _data#_index#__ID_BITFIELD;
				pr _counter = _data#_index#__ID_COUNTER;
				while {true} do {
					// Try to find an inventory class name which wasn't used yet
					pr _index0 = _bitfield findIf {!_x}; // Find bitfield item which is false

					// Bail if we can't find anything any more
					if (_index0 == -1) exitWith {
						OOP_WARNING_1("No more free inventory items: %1", _baseClassName);
					};

					// We have found something, add it to the array
					_amountTotal = _amountTotal + 1;
					_return pushBack _index0;

					// Set the bitfield - it is occupied now
					_bitfield set [_index0, true];

					// Bail if we have found enough free inventory items
					if (_amountTotal == _amount) exitWith {};
				};

				// Increase the counter
				_counter = _counter + _amountTotal;
				(_data#_index) set [__ID_COUNTER, _counter];
			};
		};

		_return
	} ENDMETHOD;

	// Returns the counter for this inventory class
	METHOD("getInventoryClassCounter") {
		pr _return = -1;

		CRITICAL_SECTION {
			params [P_THISOBJECT, P_STRING("_baseClassName")];

			pr _data = T_GETV("data");
			
			pr _index = _data findIf {_x#__ID_CLASS_NAME == _baseClassName};

			if (_index == -1) then {
				OOP_ERROR_1("Base class name %1 not found", _baseClassName);
				// Return an empty array
				[]
			} else {
				_return = _data#_index#__ID_COUNTER;
			};
		};

		_return
	} ENDMETHOD;

	// Returns base class name and ID from a full class name
	STATIC_METHOD("getBaseClassAndID") {
		params [P_THISCLASS, P_STRING("_fullClass")];
		_array = toArray _fullClass;
		private _count = count _array;
		private _i = _count - 1; // Last character
		while {_array#_i != 95} do {_i = _i - 1}; // 95 = '_' character
		[_fullClass select [0, _i], parseNumber (_fullClass select [_i+1, _count - _i - 1])]
	} ENDMETHOD;

ENDCLASS;