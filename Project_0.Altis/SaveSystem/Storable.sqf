#include "..\OOP_Light\OOP_Light.hpp"

/*
Class: Storable
Base class for classes which support saving and loading features
*/

CLASS("Storable", "")

	// - - - - VIRTUAL METHODS - - - - -
	// These might be overriden to customize saving of objects

	/* virtual */ METHOD("preSerialize") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
	} ENDMETHOD;

	/* virtual */ METHOD("postSerialize") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
	} ENDMETHOD;

	/* virtual */ METHOD("preDeserialize") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
	} ENDMETHOD;

	/* virtual */ METHOD("postDeserialize") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
	} ENDMETHOD;


ENDCLASS;