#include "common.hpp"

/*
Class: Storage

Base class for derived classes which perform saving and loading of variables elsewhere to save or load the mission state.
*/

#define pr private

CLASS("Storage", "")

	METHOD("delete") {
		params [P_THISOBJECT];

		// Close if some record is still open
		if (T_CALLM0("isOpen")) then {
			T_CALLM0("close");
		};
	} ENDMETHOD;

	// Saves an object
	// Variables marked with attribute ATTR_SAVE will be saved
	// Object must be of "Storable" class
	/* public */ METHOD("saveObject") {
		params [P_THISOBJECT, P_OOP_OBJECT("_objRef")];
		
		ASSERT_OBJECT_CLASS(_objRef, "Storable");

		CALLM1(_objRef, "preSerialize", _thisObject);
		
		pr _serial = SERIALIZE_ATTR(_objRef, ATTR_SAVE);
		
		T_CALLM2("saveVariable", _objRef, _serial);
		
		CALLM1(_objRef, "postSerialize", _thisObject);
	} ENDMETHOD;

	// Loads an object with given ref into mission namespace
	/* public */ METHOD("loadObject") {
		params [P_THISOBJECT, P_OOP_OBJECT("_objRef"), P_BOOL("_public")];

		CALLM1(_objRef, "preDeserialize", _thisObject);

		pr _serial = T_CALLM1("loadVariable", _objRef);

		// Bail if this object ref was not found
		if (isNil _serial) exitWith {false};

		// Initialize object with this ref
		pr _className = SERIALIZED_CLASS_NAME(_serial);
		ASSERT_OBJECT_CLASS(_objRef, "Storable");
		if (_public) then {
			NEW_PUBLIC_EXISTING(_className, _objRef);
		} else {
			NEW_EXISTING(_className, _objRef);
		};

		CALLM1(_objRef, "postDeserialize", _thisObject);

	} ENDMETHOD;

	// Virtual methods which must be overriden

	// Must initialize saving with the provided record name
	// analogue is opening a file with given name
	// It should also prohibit opening same record twice
	// Returns nothing
	/* virtual */ METHOD("open") {
		params [P_THISOBJECT, P_STRING("_recordName")];
	} ENDMETHOD;

	// Must close the file or whatever
	/* virtual */ METHOD("close") {
		params [P_THISOBJECT];
	} ENDMETHOD;

	// Must return true if the object is ready to save/load data
	/* virtual */ METHOD("isOpen") {
		params [P_THISOBJECT];
		false
	} ENDMETHOD;

	// Saves variable, returns true on success
	/* virtual */ METHOD("saveVariable") {
		params [P_THISOBJECT, P_STRING("_varName"), P_DYNAMIC("_value")];
		true
	} ENDMETHOD;

	// Loads variable, returns the value it has read
	/* virtual */ METHOD("loadVariable") {
		params [P_THISOBJECT, P_STRING("_varName")];
		0
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