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
		params [P_THISOBJECT];
		
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

ENDCLASS;

SET_STATIC_VAR("MyClass", "myStaticVariable", 0);
