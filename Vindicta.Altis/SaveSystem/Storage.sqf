#include "common.hpp"

/*
Class: Storage

Base class for derived classes which perform saving and loading of variables elsewhere to save or load the mission state.
*/

#define pr private

// Side macros
#define SIDE_ARRAY [east, west, independent, civilian, sideUnknown, sideEnemy, sideFriendly, sideLogic, sideEmpty]
#define SIDE_TO_NUMBER(side) (SIDE_ARRAY find (side))
#define NUMBER_TO_SIDE(number) (SIDE_ARRAY select (number))

// Length of special prefix
#define SPECIAL_PREFIX_LENGTH 4

// Special prefix common for all special strings
#define SPECIAL_PREFIX "$@&_"
#define SPECIAL_PREFIX_0 "$"
#define SPECIAL_PREFIX_1 "@"
#define SPECIAL_PREFIX_2 "&"
#define SPECIAL_PREFIX_3 "_"

#define IS_SPECIAL_STR(str_) str_#0 == SPECIAL_PREFIX_0
// Character used for sides
#define SPECIAL_PREFIX_SIDE_CHAR "S"

// Character used for object handles
#define SPECIAL_PREFIX_OBJECT_HANDLE_CHAR "O"

// Tag for objNull
#define TAG_OBJECT_NULL (SPECIAL_PREFIX + SPECIAL_PREFIX_OBJECT_HANDLE_CHAR)

// If defined, it will broadcast saving progress to everyone's UI
#ifndef _SQF_VM
#define BROADCAST_PROGRESS
#endif
FIX_LINE_NUMBERS()

// Variable needed for converting sides into strings and back
gSideTags = SIDE_ARRAY apply {
	SPECIAL_PREFIX + SPECIAL_PREFIX_SIDE_CHAR + (str _x)
};

// Converts string to side or side to string
// Fuck arma with its inability to stringify and return back strings
/* private */ storage_fnc_sideToString = {
	gSideTags select SIDE_TO_NUMBER(_this)
};

/* private */ storage_fnc_stringToSide = {
	NUMBER_TO_SIDE(gSideTags find _this)
};

// Called before converting an array into string
// Modifies existing array by converting some data types into strings
/* private */ storage_fnc_preStringifyArray = {
	private _success = true;
	{
		if (!isNil "_x") then {
			switch (typeName _x) do {
				case "ARRAY": {
					#ifdef OOP_ASSERT
					_success = _success && _x call storage_fnc_preStringifyArray;
					#else
					_x call storage_fnc_preStringifyArray;
					#endif
					FIX_LINE_NUMBERS()
				};
				case "SIDE": {
					// Convert side to string
					_this set [_forEachIndex, _x call storage_fnc_sideToString];
				};
				case "OBJECT": {
					// Convert object handle to objNull
					_this set [_forEachIndex, TAG_OBJECT_NULL];;
				};
				case "SCALAR": {};
				case "BOOL": {};
				case "STRING": {};
				default {
					// Check if it's even one of the correct data types
					// And warn if it's not
					_success = false;
					OOP_ERROR_2("Data type %1, value: %2 is not supported for saving and will not be loaded properly!", typeName _x, _x);
				};
			};
		};
	} forEach _this;
	_success
};

// Called after converting a string into array
// Modifies existing array by converting some special strings into special data types
/* private */ storage_fnc_postParseArray = {
	{
		if (!isNil "_x") then {
			switch (typeName _x) do {
				case "ARRAY": { _x call storage_fnc_postParseArray };
				case "STRING": {
					// Check if it's a special string
					if ((_x find SPECIAL_PREFIX) == 0) then {
						// Check if it's a one of side values
						switch(_x select [SPECIAL_PREFIX_LENGTH, 1]) do {
							case SPECIAL_PREFIX_SIDE_CHAR: { _this set [_forEachIndex, _x call storage_fnc_stringToSide] };
							case SPECIAL_PREFIX_OBJECT_HANDLE_CHAR: { _this set [_forEachIndex, objNull] };
						};
					};
				};
			};
		};
	} forEach _this;
};

#define OOP_CLASS_NAME Storage
CLASS("Storage", "")

	VARIABLE("savedObjects");	// Hash maps of objects saved and loaded during this save/load session
	VARIABLE("loadedObjects");	// Maps are reset ad each open/close call

	VARIABLE("saveDataOutgoing");	// Bool, set to true when any data has been saved

	VARIABLE("version"); // string, storage version

	METHOD(new)
		params [P_THISOBJECT];
		#ifndef _SQF_VM
		T_SETV("savedObjects", locationNull);
		T_SETV("loadedObjects", locationNull);
		#else
		T_SETV("savedObjects", objNull);
		T_SETV("loadedObjects", objNull);
		#endif

		T_SETV("saveDataOutgoing", false);
		#ifndef _SQF_VM
		T_SETV("version", (parseNumber call misc_fnc_getVersion));
		#else
		T_SETV("version", 666);
		#endif
		FIX_LINE_NUMBERS()
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

		T_CALLM0("_clearObjectMaps");

		// Close if some record is still open
		if (T_CALLM0("isOpen")) then {
			T_CALLM0("close");
		};
	ENDMETHOD;

	// Clears hashmaps of object references
	/* private */ METHOD(_clearObjectMaps)
		params [P_THISOBJECT];

		#ifndef _SQF_VM
		if (! isNull T_GETV("savedObjects")) then {
			deleteLocation T_GETV("savedObjects");
			deleteLocation T_GETV("loadedObjects");
		};
		T_SETV("savedObjects", locationNull);
		T_SETV("loadedObjects", locationNull);
		#else
		if (!isNull T_GETV("savedObjects")) then {
			deleteVehicle T_GETV("savedObjects");
			deleteVehicle T_GETV("loadedObjects");
		};
		T_SETV("savedObjects", objNull);
		T_SETV("loadedObjects", objNull);
		#endif
		FIX_LINE_NUMBERS()
	ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	// SAVE and LOAD methods
	// These are public methods which must be used to save/load data
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	/*
	Method: save
	Saves OOP object, or saves a basic type variable

	Examples:

	// Save a variable
	CALLM2(_storage, "save", "myVar", 123);

	// Save some object
	_obj = NEW("MyVehicle", []);
	CALLM1(_storage, "save", _obj);

	Returns: true if value was saved successfully
	*/
	/* public */	METHOD(save)
		params [P_THISOBJECT, P_DYNAMIC("_valueOrRef"), P_DYNAMIC("_value")];
		private _result = nil;
		//CRITICAL_SECTION {
			_result = call {
				#ifdef BROADCAST_PROGRESS
				//diag_log format ["Save: %1", _this];
				[format ["[Storage] Saving %1", _valueOrRef]] remoteExec ["systemChat"];
				#endif
				FIX_LINE_NUMBERS()

				// Set flag
				T_SETV("saveDataOutgoing", true);

				// Check if we are saving an object or a basic type
				if (_valueOrRef isEqualType OOP_OBJECT_TYPE && {IS_OOP_OBJECT(_valueOrRef)}) then {

					OOP_INFO_1("Saving object: %1", _valueOrRef);

					// Check if this object has been saved before
					pr _savedObjectsMap = T_GETV("savedObjects");
					if (_savedObjectsMap getVariable [_valueOrRef, false]) exitWith {
						OOP_INFO_1("Object was saved before: %1", _valueOrRef);
						true
					};

					ASSERT_OBJECT_CLASS(_valueOrRef, "Storable");		// Assert object class

					if (!CALLM1(_valueOrRef, "preSerialize", _thisObject)) exitWith {	// Preserialize
						OOP_ERROR_1("preSerialize failed for %1", _valueOrRef);
						false
					};

					pr _serial = CALLM0(_valueOrRef, "serializeForStorage");		// Serialize
					if (isNil "_serial") exitWith {
						OOP_ERROR_1("serialize failed for %1", _valueOrRef);
						false
					};
					_serial = +_serial;		// We want a deep copy!

					if(!CALLM1(_valueOrRef, "postSerialize", _thisObject)) exitWith {	// Postserialize
						OOP_ERROR_1("postSerialize failed for %1", _valueOrRef);
						false
					};

					// All is good so far

					// Convert some data types into strings
					private _preStringifySuccess = _serial call storage_fnc_preStringifyArray;

					if (!_preStringifySuccess) then {
						OOP_ERROR_1("OOP Object contains incompatible data types: %1", _valueOrRef);
						OOP_ERROR_0("Serialized object value dump:");
						{
							OOP_ERROR_2("  %1: %2", _forEachIndex, _x);
						} forEach _serial;
					};

					// Convert array to string
					toFixed 7;
					pr _serialStr = str _serial;
					toFixed -1;
					T_CALLM2("saveString", _valueOrRef, _serialStr);	// Save serialized object converted into string

					pr _className = GET_OBJECT_CLASS(_valueOrRef);		// Save parent class name
					pr _isPublic = IS_PUBLIC(_valueOrRef);				// bool
					pr _isPublicStr = ["0", "1"] select _isPublic;
					//diag_log format ["%1 is public: %2 %3", _valueOrRef, _isPublic, _isPublicStr];
					T_CALLM2("saveString", _valueOrRef + "_" + OOP_PARENT_STR, _className);
					T_CALLM2("saveString", _valueOrRef + "_" + OOP_PUBLIC_STR, _isPublicStr);

					// Add object ref to the map
					_savedObjectsMap setVariable [_valueOrRef, true];

					true
				} else {
					// Check if it's one of the allowed types
					// ... maybe later ...

					// It's a basic type, convert it to string and save it
					pr _array = [_value];							// Much easier to convert it to the array
					_array = +_array;								// Then use our usual array conversion code
					_array call storage_fnc_preStringifyArray;		// So that it can write values back
					toFixed 7;
					pr _valueStr = str _array;
					toFixed -1;
					T_CALLM2("saveString", _valueOrRef, _valueStr);
					true
				};
			};
		//};
		_result
	ENDMETHOD;

	// Loads a basic type with given ref
	/*
	Method: load
	Loads a variable with given name
	Or loads an OOP object with given ref

	Parameters: _ref, _createNewObject, _version

	_ref - string, variable name to load, or object ref to load
	_createNewObject - bool, default false, if true it will create a new object with a unique ref,
						if false it will load the object into the same ref as it was saved into
	_version - string, version of the object we are loading

	Returns:
	object ref or NULL_OBJECT on failure, if an OOP object ref is passed
	value, if general variable name is passed
	*/
	/* public */	METHOD(load)
		params [P_THISOBJECT, P_DYNAMIC("_ref"), P_BOOL("_createNewObject"), P_NUMBER("_specificVersion")];
		private _result = nil;
		//CRITICAL_SECTION {
			_result = call {

				if(_specificVersion != 0) then {
					// This will apply to all objects loaded under after call
					T_SETV("version", _specificVersion);
				};

				#ifdef BROADCAST_PROGRESS
				//diag_log format ["Save: %1", _this];
				[format ["[Storage] Loading %1", _ref]] remoteExec ["systemChat"];
				#endif
				FIX_LINE_NUMBERS()

				// Check if it was a saved OOP object
				pr _className = T_CALLM1("loadString", _ref + "_" + OOP_PARENT_STR);
				if (!isNil "_className") then {
					// We are loading an object

					OOP_INFO_1("Loading object: %1", _ref);

					// Check if this object has been saved before
					pr _loadedObjectsMap = T_GETV("loadedObjects");
					if (_loadedObjectsMap getVariable [_ref, false] && !_createNewObject) exitWith {
						OOP_INFO_1("Object was loaded before: %1", _ref);
						_ref
					};

					pr _isPublicStr = T_CALLM1("loadString", _ref + "_" + OOP_PUBLIC_STR);
					pr _isPublic = _isPublicStr == "1";
					//diag_log format ["load %1 is public %2 %3", _ref, _isPublicStr, _isPublic];
					pr _serialStr = T_CALLM1("loadString", _ref);	// Variable with name = ref is the serialized object
					#ifdef _SQF_VM
					pr _serial = call compile _serialStr;
					#else
					pr _serial = parseSimpleArray _serialStr;  // Fuck this, it does not understand SIDE values
					#endif
					FIX_LINE_NUMBERS()

					// Convert some special strings into proper data types
					_serial call storage_fnc_postParseArray;

					if (isNil "_serial") exitWith {
						OOP_ERROR_1("serialized data not found for object %1", _ref);
					};

					if (isNil "_isPublic") exitWith {
						OOP_ERROR_1("public attribute not found for object %1", _ref);
						NULL_OBJECT
					};

					private _refLoaded = NULL_OBJECT;							// Ref of loaded object
					if (_createNewObject) then {
						// Create a new object with a new unique ref
						if (_isPublic) then {
							_refLoaded = NEW_PUBLIC(_className, []);
						} else {
							_refLoaded = NEW(_className, []);
						};
						//diag_log format ["Created new object: %1", _refLoaded];
					} else {
						// Recreate object with the same ref
						if (_isPublic) then {									// Reconstruct object parent class
							_refLoaded = NEW_PUBLIC_EXISTING(_className, _ref);	// Create a public object if it was public
						} else {
							_refLoaded = NEW_EXISTING(_className, _ref);		// Or create a local object
						};
						//diag_log format ["Created existing object: %1", _refLoaded];
					};

					private _version = T_GETV("version");
					if (!CALLM2(_refLoaded, "preDeserialize", _thisObject, _version)) exitWith {	// Predeserialize
						OOP_WARNING_1("preDeserialize failed for %1", _refLoaded);
						OOP_WARNING_1("  value: %1", _serial);
						NULL_OBJECT
					};

					if (!CALLM2(_refLoaded, "deserializeFromStorage", _serial, _version)) exitWith {			// Deserialize
						OOP_WARNING_1("deserialize failed for %1", _refLoaded);
						OOP_WARNING_1("  value: %1", _serial);
						NULL_OBJECT
					};

					if(!CALLM2(_refLoaded, "postDeserialize", _thisObject, _version)) exitWith {	// PostDeserialize
						OOP_WARNING_1("postDeserialize failed for %1", _refLoaded);
						OOP_WARNING_1("  value: %1", _serial);
						NULL_OBJECT
					};

					// Add object ref to the map
					_loadedObjectsMap setVariable [_ref, true];

					_refLoaded
				} else {
					// We are loading a variable
					// Parse it back and and return value
					pr _string = T_CALLM1("loadString", _ref);
					if (isNil "_string") exitWith {
						OOP_ERROR_1("[Storage] Failed to load: %1", _ref);
						nil
					};
					#ifdef _SQF_VM
					pr _array = call compile _string;
					#else
					pr _array = parseSimpleArray _string;  // Fuck this, it does not understand SIDE values
					#endif
					FIX_LINE_NUMBERS()
					_array call storage_fnc_postParseArray; // Again run our conversion code to convert special values
					_array select 0
				};
			};
		//};
		if (!isNil "_result") then { _result } else { nil }
	ENDMETHOD;







	// - - - - - - - VIRTUAL METHODS - - - - - - - - - -
	// These methods are storage-platform dependant and inherited class must override them
	// to perform read/write operations with the underlying storage.






	// Must initialize saving with the provided record name
	// analogue is opening a file with given name
	// It should also prohibit opening same record twice
	// Returns nothing
	// ! ! ! Must be called by inherited classes ! ! !
	/* virtual */ METHOD(open)
		params [P_THISOBJECT, P_STRING("_recordName")];

		// Set up hashmaps
		T_CALLM0("_clearObjectMaps");
		#ifndef _SQF_VM
		pr _hashmapSave = createLocation ["invisible", [0,0,0], 0, 0];
		pr _hashmapLoad = createLocation ["invisible", [0,0,0], 0, 0];
		#else
		pr _hashmapSave = "Dummy" createVehicle [0, 0, 0];
		pr _hashmapLoad = "Dummy" createVehicle [0, 0, 0];
		#endif
		FIX_LINE_NUMBERS()
		T_SETV("savedObjects", _hashMapSave);
		T_SETV("loadedObjects", _hashMapLoad);
	ENDMETHOD;

	// Must close the file or whatever
	// ! ! ! Must be called by inherited classes ! ! !
	/* virtual */ METHOD(close)
		params [P_THISOBJECT];

		// Clear hashmaps
		T_CALLM0("_clearObjectMaps");
	ENDMETHOD;

	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	// Methods below do not need hierarchical calling. They just must be implemented.
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	/*
	saveString, loadString and eraseString need to save/load/erase a string associated with the currently open record.
	The implementation of the association with the currently open record is up to the inherited class.
	It can be a file, some table in database, or prefix in profileNamespace, or whatever.
	*/

	// Saves variable
	/* virtual */ METHOD(saveString)
		params [P_THISOBJECT, P_STRING("_varName"), P_STRING("_value")];
	ENDMETHOD;

	// Loads variable, returns the value it has read
	/* virtual */ METHOD(loadString)
		params [P_THISOBJECT, P_STRING("_varName")];
		0
	ENDMETHOD;

	// Erases variable (loadVariable must return nil afterwards)
	/* virtual */ METHOD(eraseString)
		params [P_THISOBJECT, P_STRING("_varName")];
	ENDMETHOD;

	// Must return true if the object is ready to save/load data
	/* virtual */ METHOD(isOpen)
		params [P_THISOBJECT];
		false
	ENDMETHOD;

	
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Rerord manipulation methods
	// They must work regardless of currently open record 
	// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	// Must returns true if a record with given record name already exists
	/* virtual */ METHOD(recordExists)
		params [P_THISOBJECT, P_STRING("_recordName")];
		false
	ENDMETHOD;

	// Must erase all variables of this record. Must return true on success.
	/* virtual */ METHOD(eraseRecord)
		params [P_THISOBJECT, P_STRING("_recordName")];
		true
	ENDMETHOD;

	// Must return array of all record names which exist in this storage
	/* virtual */ METHOD(getAllRecords)
		params [P_THISOBJECT];
		[]
	ENDMETHOD;

ENDCLASS;