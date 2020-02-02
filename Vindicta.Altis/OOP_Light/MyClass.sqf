#include "..\OOP_Light\OOP_Light.h"

/*
A template class.
*/

CLASS("MyClass", "MyClassParent");

	VARIABLE("myVariable");
	STATIC_VARIABLE("myStaticVariable");

	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------

	METHOD("new") {
		P_DEFAULT_PARAMS;

	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------

	METHOD("delete") {
		P_DEFAULT_PARAMS;

	} ENDMETHOD;

ENDCLASS;

SET_STATIC_VAR("MyClass", "myStaticVariable", 0);
