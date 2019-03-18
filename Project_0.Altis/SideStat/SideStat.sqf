#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#include "..\OOP_Light\OOP_Light.h"

/*
Class: SideStat
Author: zalexki 18.03.2019
*/

CLASS("SideStat", "");

	//Integer
	VARIABLE("humanResources");
	//Side
	VARIABLE("side");

	/*
	Method: new
	Parameters: _side
	_side - Side
	Returns: nil
	*/
	METHOD("new") {
		params ["_thisObject", "_side", "_humanResources"];
		T_SETV("side", _side);
		T_SETV("humanResources", _humanResources);
	} ENDMETHOD;
	
	/*
	Method: gethumanResources
	Returns: integer - humanResources
	*/
	METHOD("getHumanResources") {
		params ["_thisObject"];
		T_GETV("humanResources");
	} ENDMETHOD;
	
	/*
	Method: incrementXHumanResources
	Parameters: _valueToInc
	_valueToInc - integer
	Returns: nil
	*/
	METHOD("incrementXHumanResources") {
		params ["_thisObject", "_valueToInc"];
		private _currentHR = T_GETV("humanResources");
		private _nextHR = _currentHR + _valueToInc;

		T_SETV("humanResources", _nextHR);
	} ENDMETHOD;

	/*
	Method: decrementXHumanResources 
	Parameters: _valueToDec
	_valueToDec - integer
	Returns: nil
	*/
	METHOD("decrementXHumanResources") {
		params ["_thisObject", "_valueToDec"];
		private _currentHR = T_GETV("humanResources");
		private _nextHR = _currentHR - _valueToDec;

		T_SETV("humanResources", _nextHR);
	} ENDMETHOD;

ENDCLASS;
