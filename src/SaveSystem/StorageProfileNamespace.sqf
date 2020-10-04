#include "common.hpp"

/*
Class: StorageProfileNamespace

Performs saving data into profile namespace
*/

// Lazy to type that...
#define __PNS profileNamespace

// Unique tag in profile namespace we will be using
// For other missions use your own tag to not confuse our records
#define __NAMESPACE_TAG "vin_"
// One record is reserved to store data to organize other records
#define __RECORD_MASTER_RECORD "masterRecord"
#define __VAR_ALL_RECORDS "__allRecords_"

// Variable within each record which stores all variables
#define __VAR_ALL_VARIABLES "__allVariables"

// Prefix of all variables in the profile namespace
#define __NS_VAR_PREFIX(prefix) (toLower (__NAMESPACE_TAG + prefix))

// Namespace variable name formatting
#define __NS_VAR_NAME(prefix, varName) ( __NS_VAR_PREFIX(prefix) + "_" + (toLower varName) )

// Struct of each value in the record table
#define RECORD_ID_NAME		0
#define RECORD_ID_PREFIX	1

// Our favourite define
#define pr private

// Class name is too long to type every time...
#define __CLASS_NAME "StorageProfileNamespace"

#define OOP_CLASS_NAME StorageProfileNamespace
CLASS("StorageProfileNamespace", "Storage")

	VARIABLE("bOpen");			// Bool, true if open
	VARIABLE("currentRecord");	// String, current record name
	VARIABLE("currentPrefix");	// String, a unique prefix for all variables of this record
	VARIABLE("allVariables");	// All variables in this record

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("bOpen", false);
		T_SETV("currentPrefix", "_error_prefix_");
		T_SETV("currentRecord", "_error_record_");
		T_SETV("allVariables", []);
	ENDMETHOD;

	public override METHOD(open)
		params [P_THISOBJECT, P_STRING("_recordName")];

		CALLCM("Storage", _thisObject, "open", [_recordName]);

		_recordName = toLower _recordName;

		// Bail if trying to open a prohibited name
		if (_recordName == (toLower __RECORD_MASTER_RECORD)) exitWith {
			OOP_ERROR_0("Attempt to overwrite master record");
		};

		// Bail if already open
		if (T_GETV("bOpen")) exitWith {};

		// Bail if this record is already open
		/*
		pr _alreadyOpen = __PNS getVariable [__NS_VAR_NAME(_recordName, __VAR_RECORD_OPEN), false];
		if (_alreadyOpen) exitWith {};
		*/

		// CHeck if this record already exists
		pr _entry = T_CALLM1("_findRecordTableEntry", _recordName);
		if(count _entry > 0) then {
			// Read prefix
			pr _prefix = _entry#RECORD_ID_PREFIX;
			T_SETV("currentPrefix", _prefix);

			T_SETV("bOpen", true);
			T_SETV("currentRecord", _recordName);

			// Read all variables
			pr _allVariablesStr = T_CALLM1("_loadString", __VAR_ALL_VARIABLES);
			if(! isNil "_allVariablesStr") then {
				#ifndef _SQF_VM
				pr _allVariables = parseSimpleArray _allVariablesStr;
				#else
				pr _allVariables = call compile _allVariablesStr;
				#endif
				T_SETV("allVariables", _allVariables);
			} else {
				OOP_ERROR_1("Couldn't load variables for %1", _recordName);
				T_SETV("allVariables", []);
			};
		} else {
			// Add to the record table
			pr _recordTable = T_CALLM0("_loadRecordTable");
			pr _prefix = T_CALLM0("_generateUniquePrefix");
			_recordTable pushBack [_recordName, _prefix];
			T_CALLM1("_saveRecordTable", _recordTable);
			T_SETV("currentPrefix", _prefix);
			T_SETV("allVariables", []);

			T_SETV("bOpen", true);
			T_SETV("currentRecord", _recordName);

			T_CALLM2("_saveString", __VAR_ALL_VARIABLES, "[]");
		};
		
		
	ENDMETHOD;

	// Must close the file or whatever
	public override METHOD(close)
		params [P_THISOBJECT];

		CALLCM("Storage", _thisObject, "close", []);

		// Bail if not open
		if (!T_GETV("bOpen")) exitWith {};

		// Save 'allVariables' variable
		pr _allVariablesStr = str T_GETV("allVariables");
		T_CALLM2("_saveString", __VAR_ALL_VARIABLES, _allVariablesStr);

		// Commit all the data we wrote
		// Only do that if we have saved anything during this session
		if (T_GETV("saveDataOutgoing")) then {
			saveProfileNamespace;
		};

		T_SETV("bOpen", false);
	ENDMETHOD;

	// Must return true if the object is ready to save/load data
	public override METHOD(isOpen)
		params [P_THISOBJECT];
		T_GETV("bOpen");
	ENDMETHOD;

	// Saves variable, returns true on success
	public override METHOD(saveString)
		//diag_log format ["Save string: %1", _this];

		params [P_THISOBJECT, P_STRING("_varName"), P_STRING("_value")];
		
		#ifdef OOP_ASSERT
		// Bail if not open
		if (!T_GETV("bOpen")) exitWith {
			OOP_ERROR_0("Not open!");
		};
		#endif

		T_CALLM2("_saveString", _varName, _value);

		// Add to the array of all variables
		T_GETV("allVariables") pushBackUnique _varName;
	ENDMETHOD;

	/* private */ METHOD(_saveString)
		params [P_THISOBJECT, P_STRING("_varName"), P_DYNAMIC("_value")];
		__PNS setVariable [__NS_VAR_NAME(T_GETV("currentPrefix"), _varName), _value];
	ENDMETHOD;

	// Loads variable, returns the value it has read
	public override METHOD(loadString)
		params [P_THISOBJECT, P_STRING("_varName")];

		#ifdef OOP_ASSERT
		// Bail if not open
		if (!T_GETV("bOpen")) exitWith {
			OOP_ERROR_0("Not open!");
		};
		#endif

		T_CALLM1("_loadString", _varName);
	ENDMETHOD;

	METHOD(_loadString)
		params [P_THISOBJECT, P_STRING("_varName")];
		__PNS getVariable __NS_VAR_NAME(T_GETV("currentPrefix"), _varName)
	ENDMETHOD;

	// Erases variable (loadVariable must return nil afterwards)
	public override METHOD(eraseString)
		params [P_THISOBJECT, P_STRING("_varName")];

		#ifdef OOP_ASSERT
		// Bail if not open
		if (!T_GETV("bOpen")) exitWith {
			OOP_ERROR_0("Not open!");
		};
		#endif

		__PNS setVariable [__NS_VAR_NAME(T_GETV("currentPrefix"), _varName), nil];
	ENDMETHOD;

	// Must returns true if a record with given record name already exists
	public override METHOD(recordExists)
		params [P_THISOBJECT, P_STRING("_recordName")];
		_recordName = toLower _recordName;
		pr _entry = T_CALLM1("_findRecordTableEntry", _recordName);
		count _entry > 0 // True if a valid array was returned
	ENDMETHOD;

	// Must return array of all record names which exist in this storage
	public override METHOD(getAllRecords)
		params [P_THISOBJECT];
		pr _recordTable = T_CALLM0("_loadRecordTable");
		_recordTable apply {_x#RECORD_ID_NAME};
	ENDMETHOD;

	public override METHOD(eraseRecord)
		params [P_THISOBJECT, P_STRING("_recordName")];

		OOP_INFO_1("ERASE RECORD: %1", _recordName);

		_recordName = toLower _recordName;

		pr _entry = T_CALLM1("_findRecordTableEntry", _recordName);

		// Bail if there is no such record
		if (count _entry == 0) exitWith {
			OOP_INFO_0("  Record not found");
			true
		};

		pr _prefix = _entry#RECORD_ID_PREFIX;

		// Read all variables of this record and erase them
		pr _allVariablesStr = __PNS getVariable [__NS_VAR_NAME(_prefix, __VAR_ALL_VARIABLES), "[]"];
		#ifndef _SQF_VM
		pr _allVariables = parseSimpleArray _allVariablesStr;
		#else
		pr _allVariables = call compile _allVariablesStr;
		#endif
		OOP_INFO_1("Erasing %1 variables", count _allVariables);
		{
			__PNS setVariable [__NS_VAR_NAME(_prefix, _x), nil];
		} forEach _allVariables;
		__PNS setVariable [__NS_VAR_NAME(_prefix, __VAR_ALL_VARIABLES), nil];

		// Remove it from the array of all records
		pr _recordTable = T_CALLM0("_loadRecordTable");
		pr _index = _recordTable findIf {_x#RECORD_ID_NAME == (toLower _recordName)};
		_recordTable deleteAt _index;
		T_CALLM1("_saveRecordTable", _recordTable);

		// Save profile namespace
		saveProfileNamespace;

		true
	ENDMETHOD;

	// Generates a unique prefix for a new record
	METHOD(_generateUniquePrefix)
		params [P_THISOBJECT];
		pr _recordTable = T_CALLM0("_loadRecordTable");
		pr _allPrefixes = _recordTable apply {_x#RECORD_ID_PREFIX};
		pr _newPrefix = "";
		pr _alphabet = toArray "abcdefghijklmnopqrstuvwxyz";
		while { (_newPrefix in _allPrefixes) || (_newPrefix == "") } do {
			_newPrefix = "";
			_count = 0;
			while {_count < 4} do {
				_char = toString [selectRandom _alphabet];
				_newPrefix = _newPrefix + _char;
				_count = _count + 1;
			};
		};
		_newPrefix
	ENDMETHOD;

	// Must return an array of structs associated with all records
	METHOD(_loadRecordTable)
		params [P_THISOBJECT];
		__PNS getVariable [__NS_VAR_NAME(__RECORD_MASTER_RECORD, __VAR_ALL_RECORDS), []];
	ENDMETHOD;

	// Saves the record table
	METHOD(_saveRecordTable)
		params [P_THISOBJECT, P_ARRAY("_array")];
		__PNS setVariable [__NS_VAR_NAME(__RECORD_MASTER_RECORD, __VAR_ALL_RECORDS), _array];
		saveProfileNamespace;
	ENDMETHOD;

	// Returns entry into the record table with given record name
	METHOD(_findRecordTableEntry)
		params [P_THISOBJECT, P_STRING("_recordName")];
		//diag_log format ["find record by name: %1", _recordName];
		pr _recordTable = T_CALLM0("_loadRecordTable");
		_recordName = toLower _recordName;
		pr _index = _recordTable findIf {_x#RECORD_ID_NAME == (toLower _recordName)};
		if (_index != -1) then {
			//diag_log format ["found: %1", (_recordTable#_index)];
			pr _array = (_recordTable#_index);
			+_array
		} else {
			[]
		};
	ENDMETHOD;

ENDCLASS;

#ifdef _SQF_VM

// Same test can be used for any derived class actually
[ "StorageInterfaceProfileNamespace", {

	pr _obj = NEW(__CLASS_NAME, []);

	// Check it's not open yet
	["Not open yet", !CALLM0(_obj, "isOpen")] call test_Assert;

	// Check records
	pr _allRecords = CALLM0(_obj, "getAllRecords");
	["No records yet", _allRecords isEqualTo []] call test_Assert;

	// Ensure it doesn't exist
	pr _recordName = "testRecordName";
	["Record does not exist yet", !CALLM1(_obj, "recordExists", _recordName)] call test_Assert;

	// Try to open
	CALLM1(_obj, "open", _recordName);
	["Record is open", CALLM0(_obj, "isOpen")] call test_Assert;

	// Check if it's in all records
	pr _allRecords = CALLM0(_obj, "getAllRecords");
	["Record found in all records", (tolower _recordName) in _allRecords] call test_Assert;

	// Try to open same record, should fail because it's already open
	pr _obj2 = NEW(__CLASS_NAME, []);
	CALLM1(_obj2, "open", _recordName);
	//["Cant open same record twice", !CALLM0(_obj2, "isOpen")] call test_Assert;

	// Try to close
	CALLM0(_obj, "close");
	["Not open any more", !CALLM0(_obj, "isOpen")] call test_Assert;

	// Try to open with another storage interface
	CALLM1(_obj2, "open", _recordName);
	["Reopened same record", CALLM0(_obj2, "isOpen")] call test_Assert;

	// Try to write/read values
	pr _value = "abcd_efgh";
	pr _varName0 = "testVar0";
	pr _varName1 = "testVar1";
	CALLM2(_obj2, "saveString", _varName0, "11");
	CALLM2(_obj2, "saveString", _varName1, "22");
	["Test var 0", CALLM1(_obj2, "loadString", _varName0) == "11"] call test_Assert;
	["Test var 1", CALLM1(_obj2, "loadString", _varName1) == "22"] call test_Assert;

	// Try to erase variables
	CALLM1(_obj2, "eraseString", _varName0);
	["Erase var 0", isNil {CALLM1(_obj2, "loadString", _varName0)}] call test_Assert;
	CALLM2(_obj2, "saveString", _varName0, "11");	// Revert it back


	// Try to delete the objects
	DELETE(_obj);
	DELETE(_obj2);



	// Try to open once again and verify values
	pr _obj2 = NEW(__CLASS_NAME, []);
	CALLM1(_obj2, "open", _recordName);
	["Reopened same record again", CALLM0(_obj2, "isOpen")] call test_Assert;

	// Try to write/read values
	pr _value = "abcd_efgh";
	pr _varName0 = "testVar0";
	pr _varName1 = "testVar1";
	["Test var 0", CALLM1(_obj2, "loadString", _varName0) == "11"] call test_Assert;
	["Test var 1", CALLM1(_obj2, "loadString", _varName1) == "22"] call test_Assert;

	// Add more records
	pr _obj1 = NEW(__CLASS_NAME, []);
	CALLM1(_obj1, "open", "test_0");
	CALLM0(_obj1, "close");
	CALLM1(_obj1, "open", "test_1");
	CALLM0(_obj1, "close");

	pr _allRecords = CALLM0(_obj1, "getAllRecords");
	["Proper amount of records", count _allRecords == 3] call test_Assert;
	//diag_log format ["All records: %1", _allRecords];



	// Try to save/load objects
	#define OOP_CLASS_NAME StorableTest
CLASS("StorableTest", "Storable")
		VARIABLE("noSave0");
		VARIABLE_ATTR("save0", [ATTR_SAVE]);
		VARIABLE_ATTR("save1", [ATTR_SAVE]);
		VARIABLE("noSave1");

		METHOD(new)
			params [P_THISOBJECT];
		ENDMETHOD;

	ENDCLASS;

	pr _testStorable = NEW("StorableTest", []);

	SETV(_testStorable, "noSave0", 0);
	SETV(_testStorable, "save0", 1);
	SETV(_testStorable, "save1", 2);
	SETV(_testStorable, "noSave1", 3);

	pr _storage = NEW(__CLASS_NAME, []);
	CALLM1(_storage, "open", "testRecord0");

	pr _saveSuccess = CALLM1(_storage, "save", _testStorable);

	["Save successful", _saveSuccess] call test_Assert;

	DELETE(_testStorable);

	pr _result = CALLM1(_storage, "load", _testStorable);

	["Load successful", !IS_NULL_OBJECT(_result)] call test_Assert;
	["Check noSave0", isNil {GETV(_testStorable, "noSave0")}] call test_Assert;
	["Check noSave1", isNil {GETV(_testStorable, "noSave1")}] call test_Assert;
	["Check save0", GETV(_testStorable, "save0") == 1] call test_Assert;
	["Check save1", GETV(_testStorable, "save1") == 2] call test_Assert;

	// Try to load same object twice
	SETV(_testStorable, "save0", 111); // Try to set a variable
	pr _result = CALLM1(_storage, "load", _testStorable);
	["Second load successful", !IS_NULL_OBJECT(_result)] call test_Assert;
	["Object was not loaded twice", GETV(_testStorable, "save0") == 111] call test_Assert;

	// Try to save/load variables
	CALLM2(_storage, "save", "testVar", 666);
	pr _return = CALLM1(_storage, "load", "testVar");
	["Save & load varaible", _return == 666] call test_Assert;

	// Try to save/load into a new object ref instead of the ref provided from loading
	CALLM0(_storage, "close"); // Must close or it will not let us load same object twice
	CALLM1(_storage, "open", "testRecord0");

	pr _newStorable0 = CALLM2(_storage, "load", _testStorable, true);

	CALLM0(_storage, "close"); // Must close or it will not let us load same object twice
	CALLM1(_storage, "open", "testRecord0");

	pr _newStorable1 = CALLM2(_storage, "load", _testStorable, true);
	//diag_log format ["newStorable0: %1, newStorable1: %2", _newStorable0, _newStorable1];
	["Refs are different", _newStorable0 != _newStorable1] call test_Assert;
	//["New object loaded properly", GETV(_newStorable, "save0") isEqualTo GETV(_testStorable, "save0")] test_Assert;

}] call test_AddTest;

#endif