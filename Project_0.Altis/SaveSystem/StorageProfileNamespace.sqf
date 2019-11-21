#include "common.hpp"

/*
Class: StorageProfileNamespace

Performs saving data into profile namespace
*/

// Lazy to type that...
#define __PNS profileNamespace

// Unique tag in profile namespace we will be using
// For other missions use your own tag to not confuse our records
#define __NAMESPACE_TAG "vin_save_"
// One record is reserved to store data to organize other records
#define __RECORD_MASTER_RECORD "masterRecord"
#define __VAR_ALL_RECORDS "__allRecords_"
#define __VAR_RECORD_OPEN "__recordOpen_"

// Namespace variable name formatting
#define __NS_VAR_NAME(recordName, varName) (toLower (__NAMESPACE_TAG + recordName + varName))

// Prefix of all variables in the profile namespace
#define __NS_VAR_PREFIX(recordName) (toLower (__NAMESPACE_TAG + recordName))

#define pr private

// Class name is too long to type every time...
#define __CLASS_NAME "StorageProfileNamespace"

CLASS(__CLASS_NAME, "Storage")

	VARIABLE("bOpen");			// Bool, true if open
	VARIABLE("currentRecord");	// String, current record name

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("bOpen", false);
	} ENDMETHOD;

	/* override */ METHOD("open") {
		params [P_THISOBJECT, P_STRING("_recordName")];

		CALL_CLASS_METHOD("Storage", _thisObject, "open", [_recordName]);

		_recordName = toLower _recordName;

		// Bail if trying to open a prohibited name
		if (_recordName == (toLower __RECORD_MASTER_RECORD)) exitWith {
			OOP_ERROR_0("Attempt to overwrite master record");
		};

		// Bail if already open
		if (T_GETV("bOpen")) exitWith {};

		// Bail if this record is already open
		pr _alreadyOpen = __PNS getVariable [__NS_VAR_NAME(_recordName, __VAR_RECORD_OPEN), false];
		if (_alreadyOpen) exitWith {};

		// Add to the array of all records
		pr _allRecords = T_CALLM0("getAllRecords");
		_allRecords pushBackUnique _recordName;
		__PNS setVariable [__NS_VAR_NAME(__RECORD_MASTER_RECORD, __VAR_RECORD_OPEN), _allRecords];

		// Set record lock
		__PNS setVariable [__NS_VAR_NAME(_recordName, __VAR_RECORD_OPEN), true];
		
		saveProfileNamespace;
		T_SETV("bOpen", true);
		T_SETV("currentRecord", _recordName);
	} ENDMETHOD;

	// Must close the file or whatever
	/* override */ METHOD("close") {
		params [P_THISOBJECT];

		CALL_CLASS_METHOD("Storage", _thisObject, "close", []);

		// Bail if not open
		if (!T_GETV("bOpen")) exitWith {};

		pr _recordName = T_GETV("currentRecord");

		// Reset record lock
		__PNS setVariable [__NS_VAR_NAME(_recordName, __VAR_RECORD_OPEN), false];

		saveProfileNamespace;	// Commit all the data we wrote
		T_SETV("bOpen", false);
		T_SETV("currentRecord", nil);
	} ENDMETHOD;

	// Must return true if the object is ready to save/load data
	/* override */ METHOD("isOpen") {
		params [P_THISOBJECT];
		T_GETV("bOpen");
	} ENDMETHOD;

	// Saves variable, returns true on success
	/* override */ METHOD("saveVariable") {
		params [P_THISOBJECT, P_STRING("_varName"), P_DYNAMIC("_value")];

		#ifdef OOP_ASSERT
		// Bail if not open
		if (!T_GETV("bOpen")) exitWith {
			OOP_ERROR_0("Not open!");
		};
		#endif

		__PNS setVariable [__NS_VAR_NAME(T_GETV("currentRecord"), _varName), _value];
	} ENDMETHOD;

	// Loads variable, returns the value it has read
	/* override */ METHOD("loadVariable") {
		params [P_THISOBJECT, P_STRING("_varName")];

		#ifdef OOP_ASSERT
		// Bail if not open
		if (!T_GETV("bOpen")) exitWith {
			OOP_ERROR_0("Not open!");
		};
		#endif

		__PNS getVariable __NS_VAR_NAME(T_GETV("currentRecord"), _varName)
	} ENDMETHOD;

	// Erases variable (loadVariable must return nil afterwards)
	/* virtual */ METHOD("eraseVariable") {
		params [P_THISOBJECT, P_STRING("_varName")];

		#ifdef OOP_ASSERT
		// Bail if not open
		if (!T_GETV("bOpen")) exitWith {
			OOP_ERROR_0("Not open!");
		};
		#endif

		__PNS setVariable [__NS_VAR_NAME(T_GETV("currentRecord"), _varName), nil];
	} ENDMETHOD;

	// Must returns true if a record with given record name already exists
	/* override */ METHOD("recordExists") {
		params [P_THISOBJECT, P_STRING("_recordName")];
		(toLower _recordName) in T_CALLM0("getAllRecords")
	} ENDMETHOD;

	// Must return array of all record names which exist in this storage
	/* override */ METHOD("getAllRecords") {
		params [P_THISOBJECT];
		__PNS getVariable [__NS_VAR_NAME(__RECORD_MASTER_RECORD, __VAR_RECORD_OPEN), []];
	} ENDMETHOD;

	/* override */ METHOD("eraseRecord") {
		params [P_THISOBJECT, P_STRING("_recordName")];

		pr _allRecords = +T_CALLM0("getAllRecords");

		_recordName = toLower _recordName;

		// Bail if there is no such record
		if (!(_recordName in _allRecords)) exitWith {
			true
		};

		// Iterate all variables and delete those which are from this record
		pr _prefix = __NS_VAR_PREFIX(_recordName);
		{
			if(_prefix in _x) then {
				profileNamespace setVariable [_x, nil];
			};
		} forEach (allVariables profileNamespace);

		// Remove it from the array of all records
		_allRecords deleteAt (_allRecords find _recordName);
		__PNS setVariable [__NS_VAR_NAME(__RECORD_MASTER_RECORD, __VAR_RECORD_OPEN), _allRecords];


		// Save profile namespace
		saveProfileNamespace;

		true
	} ENDMETHOD;

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
	["Record found in all records", _recordName in _allRecords] call test_Assert;

	// Try to open same record, should fail because it's already open
	pr _obj2 = NEW(__CLASS_NAME, []);
	CALLM1(_obj2, "open", _recordName);
	["Cant open same record twice", !CALLM0(_obj2, "isOpen")] call test_Assert;

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
	CALLM2(_obj2, "saveVariable", _varName0, 11);
	CALLM2(_obj2, "saveVariable", _varName1, 22);
	["Test var 0", CALLM1(_obj2, "loadVariable", _varName0) == 11] call test_Assert;
	["Test var 1", CALLM1(_obj2, "loadVariable", _varName1) == 22] call test_Assert;

	// Try to erase variables
	CALLM1(_obj2, "eraseVariable", _varName0);
	["Erase var 0", isNil {CALLM1(_obj2, "loadVariable", _varName0)}] call test_Assert;
	CALLM2(_obj2, "saveVariable", _varName0, 11);	// Revert it back


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
	["Test var 0", CALLM1(_obj2, "loadVariable", _varName0) == 11] call test_Assert;
	["Test var 1", CALLM1(_obj2, "loadVariable", _varName1) == 22] call test_Assert;

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
	CLASS("StorableTest", "Storable")
		VARIABLE("noSave0");
		VARIABLE_ATTR("save0", [ATTR_SAVE]);
		VARIABLE_ATTR("save1", [ATTR_SAVE]);
		VARIABLE("noSave1");

		METHOD("new") {
			params [P_THISOBJECT];
		} ENDMETHOD;

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

}] call test_AddTest;

#endif