#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG
#define OFSTREAM_FILE "Intel.rpt"
#include "..\common.h"
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

#define OOP_CLASS_NAME PersonalInventory
CLASS("PersonalInventory", "")

	VARIABLE("data");

	METHOD(new)
		params [P_THISOBJECT];

		T_SETV("data", []);

		{
			T_CALLM2("_addInventoryClass", _x, INTEL_INVENTORY_CLASSES_COPY_AMOUNT);
		} forEach INTEL_INVENTORY_ALL_CLASSES;
	ENDMETHOD;

	METHOD(_addInventoryClass)
		params [P_THISOBJECT, P_STRING("_className"), P_NUMBER("_amount")];

		pr _data = T_GETV("data");
		
		pr _classData = [];
		_classData resize _amount;
		pr _bitfield = [];
		_bitfield resize _amount;
		_bitfield = _bitfield apply {false};
		pr _counter = 0;
		_data pushBack [_className, _counter, _classData, _bitfield];

	ENDMETHOD;

	// Returns [_data, _dataExists]
	public METHOD(getInventoryData)
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
	ENDMETHOD;

	public METHOD(setInventoryData)
		CRITICAL_SECTION {
			params [P_THISOBJECT, P_STRING("_className"), P_NUMBER("_ID"), "_inventoryData"];
			
			pr _data = T_GETV("data");

			pr _index = _data findIf {_x#__ID_CLASS_NAME == _className};

			if (_index != -1) then {
				// Set or reset value
				(_data#_index#__ID_DATA) set [_ID, _inventoryData];

				//OOP_DEBUG_MSG("Set data for id: %1, value: %2", [_ID ARG _inventoryData]);

				// Set or reset bitfield
				(_data#_index#__ID_BITFIELD) set [_ID, !isNil "_inventoryData"];

				// Return this ID to the free ID pool if we have set data to nil
				if (isNil "_inventoryData") then {
					// Decrease the counter
					pr _counter = _data#_index#__ID_COUNTER;
					(_data#_index) set [__ID_COUNTER, _counter - 1];
				};
			} else {
				OOP_ERROR_1("Base class name %1 not found", _className);
			};
		};
	ENDMETHOD;



	/*
	public METHOD(resetInventoryData)
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
	ENDMETHOD;
	*/

	public METHOD(getInventoryClassIDs)
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
	ENDMETHOD;

	// Returns the counter for this inventory class
	public METHOD(getInventoryClassCounter)
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
	ENDMETHOD;

	// Returns base class name and ID from a full class name
	public STATIC_METHOD(getBaseClassAndID)
		params [P_THISCLASS, P_STRING("_fullClass")];
		_array = toArray _fullClass;
		private _count = count _array;
		private _i = _count - 1; // Last character
		while {_array#_i != 95} do {_i = _i - 1}; // 95 = '_' character
		[_fullClass select [0, _i], parseNumber (_fullClass select [_i+1, _count - _i - 1])]
	ENDMETHOD;

ENDCLASS;

#ifdef _SQF_VM

["PersonalInventory_new", {
	gInv = NEW("PersonalInventory", []);
	
	private _class = OBJECT_PARENT_CLASS_STR(gInv);
	["Object exists", (!isNil "_class")] call test_Assert;
}] call test_AddTest;

["PersonalInventory_getClassIDs", {
	gInv = NEW("PersonalInventory", []);
	
	private _class = OBJECT_PARENT_CLASS_STR(gInv);
	
	private _IDs = CALLM2(gInv, "getInventoryClassIDs", "vin_tablet_0", 10);
	//diag_log format ["Returned class IDs: %1", _IDs];
	["Return enough IDs", count _IDs == 10] call test_Assert;
}] call test_AddTest;

["PersonalInventory_setAndGet", {
	gInv = NEW("PersonalInventory", []);
	
	// "vin_tablet_0"
	private _value = 123.456;
	CALLM3(gInv, "setInventoryData", "vin_tablet_0", 4, _value);
	private _dataAndExists = CALLM2(gInv, "getInventoryData", "vin_tablet_0", 4);
	//diag_log format ["Returned value: %1", _dataAndExists];
	["Return value exists", _dataAndExists#1] call test_Assert;
	["Set and return values equal", _value == _dataAndExists#0] call test_Assert;

	// Now try to erase it
	CALLM3(gInv, "setInventoryData", "vin_tablet_0", 4, nil);
	private _dataAndExists = CALLM2(gInv, "getInventoryData", "vin_tablet_0", 4);
	["Return must not exist after erasure", !(_dataAndExists#1)] call test_Assert;

}] call test_AddTest;



#endif
