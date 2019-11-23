#include "common.hpp"

/*
Class: Storage

Base class for derived classes which perform saving and loading of variables elsewhere to save or load the mission state.
*/

#define pr private

// Side macros
#define SIDE_ARRAY [east, west, independent, civilian, sideUnknown, sideEnemy, sideFriendly, sideLogic, sideEmpty]
#define SIDE_TO_NUMBER(side) (SIDE_ARRAY find side)
#define NUMBER_TO_SIDE(number) (SIDE_ARRAY select number)

// Length of special prefix
#define SPECIAL_PREFIX_LENGTH 4

// Special prefix common for all special strings
#define SPECIAL_PREFIX "$@&_"

// Character used for sides
#define SPECIAL_PREFIX_SIDE_CHAR "S"

CLASS("Storage", "")

	VARIABLE("savedObjects");	// Hash maps of objects saved and loaded during this save/load session
	VARIABLE("loadedObjects");	// Maps are reset ad each open/close call

	VARIABLE("sideTags");		// Variable needed for converting sides into strings and back

	METHOD("new") {
		params [P_THISOBJECT];
		#ifndef _SQF_VM
		T_SETV("savedObjects", locationNull);
		T_SETV("loadedObjects", locationNull);
		#else
		T_SETV("savedObjects", objNull);
		T_SETV("loadedObjects", objNull);
		#endif

		pr _sideTags = SIDE_ARRAY apply {
			SPECIAL_PREFIX + SPECIAL_PREFIX_SIDE_CHAR + (str _x)
		};
		T_SETV("sideTags", _sideTags);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

		T_CALLM0("_clearObjectMaps");

		// Close if some record is still open
		if (T_CALLM0("isOpen")) then {
			T_CALLM0("close");
		};
	} ENDMETHOD;

	// Clears hashmaps of object references
	/* private */ METHOD("_clearObjectMaps") {
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

	} ENDMETHOD;

	// Converts string to side or side to string
	// Fuck arma with its inability to stringify and return back strings
	METHOD("_sideToString") {
		params [P_THISOBJECT, P_SIDE("_side")];
		T_GETV("sideTags") select SIDE_TO_NUMBER(_side)
	} ENDMETHOD;

	METHOD("_stringToSide") {
		params [P_THISOBJECT, P_STRING("_string")];
		private _ID = T_GETV("sideTags") find _string;
		NUMBER_TO_SIDE(_ID)
	} ENDMETHOD;

	// Called before converting an array into string
	// Modifies existing array by converting some data types into strings
	METHOD("_preStringifyArray") {
		params [P_THISOBJECT, P_ARRAY("_array")];
		private _success = true;
		{
			if (!isNil "_x") then {
				if (_x isEqualType []) then {
					_success = _success && T_CALLM1("_preStringifyArray", _x);
				};
				// Convert side to string
				if (_x isEqualType WEST) then {
					_array set [_forEachIndex, T_CALLM1("_sideToString", _x)];
				};
				// Check if it's even one of the correct data types
				// And warn if it's not
				#ifndef _SQF_VM
				if (!(_x isEqualTypeAny [0, "", false, [], WEST])) then {
					_success = false;
					OOP_ERROR_1("Data type %1 is not supported for saving and will not be loaded!", typeName _x);
				};
				#endif
			};
		} forEach _array;
		_success
	} ENDMETHOD;

	// Called after converting a string into array
	// Modifies existing array by converting some special strings into special data types
	METHOD("_postParseArray") {
		params [P_THISOBJECT, P_ARRAY("_array")];
		{
			if (!isNil "_x") then {
				if (_x isEqualType []) then {
					T_CALLM1("_postParseArray", _x);
				};
				// Check if it's a special string
				if (_x isEqualType "") then {
					private _prefix = _x select [0, SPECIAL_PREFIX_LENGTH];
					//diag_log format ["Prefix: %1", _prefix];
					if (_prefix == SPECIAL_PREFIX) then {
						private _prefixChar = _x select [SPECIAL_PREFIX_LENGTH, 1];
						//diag_log format ["Prefix char: %1", _prefixChar];
						// Check if it's a one of side values
						if (_prefixChar == SPECIAL_PREFIX_SIDE_CHAR) then {
							_array set [_forEachIndex, T_CALLM1("_stringToSide", _x)];
						};
					};
				};
			};
		} forEach _array;
	} ENDMETHOD;

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
	METHOD("save") {
		params [P_THISOBJECT, P_DYNAMIC("_valueOrRef"), P_DYNAMIC("_value")];

		//diag_log format ["Save: %1", _this];

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
			private _preStringifySuccess = T_CALLM1("_preStringifyArray", _serial);

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
			T_CALLM2("saveString", _valueOrRef + "_" + OOP_PARENT_STR, _className);	
			T_CALLM2("saveString", _valueOrRef + "_" + OOP_PUBLIC_STR, _isPublic); // as a public object

			// Add object ref to the map
			_savedObjectsMap setVariable [_valueOrRef, true];

			true
		} else {
			// Check if it's one of the allowed types
			// ... maybe later ...

			// It's a basic type, convert it to string and save it
			pr _array = [_value];							// Much easier to convert it to the array
			_array = +_array;								// Then use our usual array conversion code
			T_CALLM1("_preStringifyArray", _array);			// So that it can write values back
			toFixed 7;
			pr _valueStr = str _array;
			toFixed -1;
			T_CALLM2("saveString", _valueOrRef, _valueStr);
			true
		};
	} ENDMETHOD;

	// Loads a basic type with given ref
	/*
	Method: load
	Loads a variable with given name
	Or loads an OOP object with given ref

	Returns:
	object ref or NULL_OBJECT on failure, if an OOP object ref is passed
	value, if general variable name is passed
	*/
	METHOD("load") {
		params [P_THISOBJECT, P_DYNAMIC("_ref")];

		// Check if it was a saved OOP object
		pr _className = T_CALLM1("loadString", _ref + "_" + OOP_PARENT_STR);
		if (!isNil "_className") then {
			// We are loading an object

			OOP_INFO_1("Loading object: %1", _ref);

			// Check if this object has been saved before
			pr _loadedObjectsMap = T_GETV("loadedObjects");
			if (_loadedObjectsMap getVariable [_ref, false]) exitWith {
				OOP_INFO_1("Object was loaded before: %1", _ref);
				_ref
			};

			pr _isPublic = T_CALLM1("loadString", _ref + "_" +  OOP_PUBLIC_STR);
			pr _serialStr = T_CALLM1("loadString", _ref);	// Variable with name = ref is the serialized object
			#ifdef _SQF_VM
			pr _serial = call compile _serialStr;
			#else
			pr _serial = parseSimpleArray _serialStr;  // Fuck this, it does not understand SIDE values
			#endif

			// Convert some special strings into proper data types
			T_CALLM1("_postParseArray", _serial);

			if (isNil "_serial") exitWith {
				OOP_ERROR_1("serialized data not found for object %1", _ref);
			};

			if (isNil "_isPublic") exitWith {
				OOP_ERROR_1("public attribute not found for object %1", _ref);
				NULL_OBJECT
			};

			private _refLoaded = NULL_OBJECT;						// Ref of loaded object
			if (_isPublic) then {									// Reconstruct object parent class
				_refLoaded = NEW_PUBLIC_EXISTING(_className, _ref);	// Create a public object if it was public
			} else {
				_refLoaded = NEW_EXISTING(_className, _ref);		// Or create a local object
			};

			if (!CALLM1(_refLoaded, "preDeserialize", _thisObject)) exitWith {	// Predeserialize
				OOP_ERROR_1("preDeserialize failed for %1", _refLoaded);
				OOP_ERROR_1("  value: %1", _serial);
				NULL_OBJECT
			};

			if (!CALLM1(_refLoaded, "deserializeFromStorage", _serial)) exitWith {			// Deserialize
				OOP_ERROR_1("deserialize failed for %1", _refLoaded);
				OOP_ERROR_1("  value: %1", _serial);
				NULL_OBJECT
			};

			if(!CALLM1(_refLoaded, "postDeserialize", _thisObject)) exitWith {	// PostDeserialize
				OOP_ERROR_1("postDeserialize failed for %1", _refLoaded);
				OOP_ERROR_1("  value: %1", _serial);
				NULL_OBJECT
			};

			// Add object ref to the map
			_loadedObjectsMap setVariable [_ref, true];

			_refLoaded
		} else {
			// We are loading a variable
			// Parse it back and and return value
			pr _string = T_CALLM1("loadString", _ref);
			#ifdef _SQF_VM
			pr _array = call compile _string;
			#else
			pr _array = parseSimpleArray _string;  // Fuck this, it does not understand SIDE values
			#endif
			T_CALLM1("_postParseArray", _array);	// Again run our conversion code to convert special values
			_array select 0
		};

	} ENDMETHOD;

	// Virtual methods which must be overriden

	// Must initialize saving with the provided record name
	// analogue is opening a file with given name
	// It should also prohibit opening same record twice
	// Returns nothing
	// ! ! ! Must be called by inherited classes ! ! !
	/* virtual */ METHOD("open") {
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
		T_SETV("savedObjects", _hashMapSave);
		T_SETV("loadedObjects", _hashMapLoad);
	} ENDMETHOD;

	// Must close the file or whatever
	// ! ! ! Must be called by inherited classes ! ! !
	/* virtual */ METHOD("close") {
		params [P_THISOBJECT];

		// Clear hashmaps
		T_CALLM0("_clearObjectMaps");
	} ENDMETHOD;

	// Must return true if the object is ready to save/load data
	/* virtual */ METHOD("isOpen") {
		params [P_THISOBJECT];
		false
	} ENDMETHOD;

	// Saves variable
	/* virtual */ METHOD("saveString") {
		params [P_THISOBJECT, P_STRING("_varName"), P_DYNAMIC("_value")];
	} ENDMETHOD;

	// Loads variable, returns the value it has read
	/* virtual */ METHOD("loadString") {
		params [P_THISOBJECT, P_STRING("_varName")];
		0
	} ENDMETHOD;

	// Erases variable (loadVariable must return nil afterwards)
	/* virtual */ METHOD("eraseString") {
		params [P_THISOBJECT, P_STRING("_varName")];
	} ENDMETHOD;

	// Must returns true if a record with given record name already exists
	/* virtual */ METHOD("recordExists") {
		params [P_THISOBJECT, P_STRING("_recordName")];
		false
	} ENDMETHOD;

	// Must erase all variables of this record. Must return true on success.
	/* virtual */ METHOD("eraseRecord") {
		params [P_THISOBJECT, P_STRING("_recordName")];
		true
	} ENDMETHOD;

	// Must return array of all record names which exist in this storage
	/* virtual */ METHOD("getAllRecords") {
		params [P_THISOBJECT];
		[]
	} ENDMETHOD;

ENDCLASS;