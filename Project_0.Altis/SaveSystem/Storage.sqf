#include "common.hpp"

/*
Class: Storage

Base class for derived classes which perform saving and loading of variables elsewhere to save or load the mission state.
*/

#define pr private

CLASS("Storage", "")

	VARIABLE("savedObjects");	// Hash maps of objects saved and loaded during this save/load session
	VARIABLE("loadedObjects");	// Maps are reset ad each open/close call

	METHOD("new") {
		params [P_THISOBJECT];
		#ifndef _SQF_VM
		T_SETV("savedObjects", locationNull);
		T_SETV("loadedObjects", locationNull);
		#else
		T_SETV("savedObjects", objNull);
		T_SETV("loadedObjects", objNull);
		#endif
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
		// Check if we are saving an object or a basic type
		if (_valueOrRef isEqualType OOP_OBJECT_TYPE && {IS_OOP_OBJECT(_valueOrRef)}) then {

			// Check if this object has been saved before
			pr _savedObjectsMap = T_GETV("savedObjects");
			if (_savedObjectsMap getVariable [_valueOrRef, false]) exitWith {
				OOP_WARNING_1("Object was saved before: %1", _valueOrRef);
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

			if(!CALLM1(_valueOrRef, "postSerialize", _thisObject)) exitWith {	// Postserialize
				OOP_ERROR_1("postSerialize failed for %1", _valueOrRef);
				false
			};

			// All is good so far

			T_CALLM2("saveVariable", _valueOrRef, _serial);		// Save serialized object

			pr _className = GET_OBJECT_CLASS(_valueOrRef);		// Save parent class name
			pr _isPublic = IS_PUBLIC(_valueOrRef);				// bool
			T_CALLM2("saveVariable", _valueOrRef + "_" + OOP_PARENT_STR, _className);	
			T_CALLM2("saveVariable", _valueOrRef + "_" + OOP_PUBLIC_STR, _isPublic); // as a public object

			// Add object ref to the map
			_savedObjectsMap setVariable [_valueOrRef, true];

			true
		} else {
			// It's a basic type, save it just as it is
			T_CALLM2("saveVariable", _valueOrRef, _value);
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
		pr _className = T_CALLM1("loadVariable", _ref + "_" + OOP_PARENT_STR);
		if (!isNil "_className") then {
			// We are loading an object

			// Check if this object has been saved before
			pr _loadedObjectsMap = T_GETV("loadedObjects");
			if (_loadedObjectsMap getVariable [_ref, false]) exitWith {
				OOP_WARNING_1("Object was loaded before: %1", _valueOrRef);
				_ref
			};

			pr _isPublic = T_CALLM1("loadVariable", _ref + "_" +  OOP_PUBLIC_STR);
			pr _serial = T_CALLM1("loadVariable", _ref);	// Variable with name = ref is the serialized object

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
			// Just load it and return value
			T_CALLM1("loadVariable", _ref)
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
		pr _hashmapSave = createLocation ["empty", [0,0,0], 0, 0];
		pr _hashmapLoad = createLocation ["empty", [0,0,0], 0, 0];
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
	/* virtual */ METHOD("saveVariable") {
		params [P_THISOBJECT, P_STRING("_varName"), P_DYNAMIC("_value")];
	} ENDMETHOD;

	// Loads variable, returns the value it has read
	/* virtual */ METHOD("loadVariable") {
		params [P_THISOBJECT, P_STRING("_varName")];
		0
	} ENDMETHOD;

	// Erases variable (loadVariable must return nil afterwards)
	/* virtual */ METHOD("eraseVariable") {
		params [P_THISOBJECT, P_STRING("_varName")];
	} ENDMETHOD;

	// Must returns true if a record with given record name already exists
	/* virtual */ METHOD("recordExists") {
		params [P_THISOBJECT, P_STRING("_recordName")];
		false
	} ENDMETHOD;

	// Must return array of all record names which exist in this storage
	/* virtual */ METHOD("getAllRecords") {
		params [P_THISOBJECT];
		[]
	} ENDMETHOD;

ENDCLASS;