#include "common.hpp"

/*
Class: StorageFilext

Performs saving data with FileXT addon.
*/

// Our favourite define
#define pr private

// Class name is too long to type every time...
#define __CLASS_NAME "StorageFilext"

// File extension, appended to all file names
#define __FILE_EXTENSION ".vin"

#define OOP_CLASS_NAME StorageFilext
CLASS("StorageFilext", "Storage")

	VARIABLE("bOpen");			// Bool, true if open
	VARIABLE("currentFile");	// String, current file name with extension

	METHOD(new)
		params [P_THISOBJECT];
		T_SETV("bOpen", false);
		T_SETV("currentFile", "");
	ENDMETHOD;

	public override METHOD(open)
		params [P_THISOBJECT, P_STRING("_recordName")];

		CALLCM("Storage", _thisObject, "open", [_recordName]);

		_recordName = toLower _recordName;
        pr _fileName = _recordName + __FILE_EXTENSION;

		// Bail if already open
		if (T_GETV("bOpen")) exitWith {};

		T_SETV("currentFile", _fileName);

		[_fileName] call filext_fnc_open;
        [_fileName] call filext_fnc_read;

        T_SETV("bOpen", true);
	ENDMETHOD;

	// Close the file and write all data to it
	public override METHOD(close)
		params [P_THISOBJECT];

		CALLCM("Storage", _thisObject, "close", []);

		// Bail if not open
		if (!T_GETV("bOpen")) exitWith {};

		pr _fileName = T_GETV("currentFile");

		// Commit all the data we wrote
		// Only do that if we have saved anything during this session
		if (T_GETV("saveDataOutgoing")) then {
            [_fileName] call filext_fnc_write; // Writes data to file
		};
        [_fileName] call filext_fnc_close; // Deletes all the variables we've passed to it from RAM

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

		pr _currentFile = T_GETV("currentFile");
        [_currentFile, _varName, _value] call filext_fnc_set;
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

		pr _currentFile = T_GETV("currentFile");
        [_currentFile, _varName] call filext_fnc_get;
	ENDMETHOD;

	public override METHOD(eraseString)
		params [P_THISOBJECT, P_STRING("_varName")];

		#ifdef OOP_ASSERT
		// Bail if not open
		if (!T_GETV("bOpen")) exitWith {
			OOP_ERROR_0("Not open!");
		};
		#endif

        pr _currentFile = T_GETV("currentFile");
		[_currentFile, _varName] call filext_fnc_eraseKey;
	ENDMETHOD;

	// Must returns true if a record with given record name already exists
	public override METHOD(recordExists)
		params [P_THISOBJECT, P_STRING("_recordName")];
		_recordName = toLower _recordName;
        pr _fileName = _recordName + __FILE_EXTENSION;
		
        [_fileName] call filext_fnc_fileExists;
	ENDMETHOD;

	// Must return array of all record names which exist in this storage
	public override METHOD(getAllRecords)
		params [P_THISOBJECT];
		pr _allFiles = call filext_fnc_getFiles;
        // Remove extension from file name
        _allFiles select {  // Select files which end with proper extension
            ( (_x find __FILE_EXTENSION) != -1)
        } apply {
            pr _id = _x find __FILE_EXTENSION;
            _x select [0, _id]
        };
	ENDMETHOD;

	public override METHOD(eraseRecord)
		params [P_THISOBJECT, P_STRING("_recordName")];

		OOP_INFO_1("ERASE RECORD: %1", _recordName);

		_recordName = toLower _recordName;
        pr _fileName = _recordName + __FILE_EXTENSION;

		[_fileName] call filext_fnc_deleteFile;

		true
	ENDMETHOD;

ENDCLASS;