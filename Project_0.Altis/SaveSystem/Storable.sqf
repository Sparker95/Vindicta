#include "..\OOP_Light\OOP_Light.h"

/*
Class: Storable
Base class for classes which support saving and loading features
*/

CLASS("Storable", "")

	// - - - - VIRTUAL METHODS - - - - -
	// These might be overriden to customize saving of objects

	// Must return true on success
	/* virtual */ METHOD("preSerialize") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		true
	} ENDMETHOD;

	// Returns an array which must be a deep copy
	// Must return nil on failure
	/* virtual */ METHOD("serializeForStorage") {
		params [P_THISOBJECT];
		SERIALIZE_ATTR(_thisObject, ATTR_SAVE);
	} ENDMETHOD;

	// Must return true on success
	/* virtual */ METHOD("postSerialize") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		true
	} ENDMETHOD;

	// These methods must return true on success
	/* virtual */ METHOD("preDeserialize") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		true
	} ENDMETHOD;

	/* virtual */ METHOD("deserializeFromStorage") {
		params [P_THISOBJECT, P_ARRAY("_serial")];
		DESERIALIZE_ATTR(_thisObject, _serial, ATTR_SAVE);
		true
	} ENDMETHOD;

	/* virtual */ METHOD("postDeserialize") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		true
	} ENDMETHOD;


ENDCLASS;