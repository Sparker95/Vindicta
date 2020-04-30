#include "..\OOP_Light\OOP_Light.h"

/*
Class: Commander
It is a requirement that we attach an AI object to an Agent-object.
Therefore I have made this class although it doesn't do anything.

It just implements methods needed for an AI object to function.
*/

CLASS("Commander", "")

	
	METHOD(getSubagents)
		[]
	ENDMETHOD;
	
	METHOD(getPossibleGoals)
		[]
	ENDMETHOD;
	
	METHOD(getPossibleActions)
		[]
	ENDMETHOD;

ENDCLASS;