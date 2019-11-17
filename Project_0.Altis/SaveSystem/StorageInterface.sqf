#include "common.hpp"

/*
Class: StorageInterface

Base class for derived classes which perform saving and loading of variables elsewhere to save or load the mission state.
*/

CLASS("StorageInterface", "")

	METHOD("delete") {
		params [P_THISOBJECT];

		// Close if some record is still open
		if (T_CALLM0("isOpen")) then {
			T_CALLM0("close");
		};
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