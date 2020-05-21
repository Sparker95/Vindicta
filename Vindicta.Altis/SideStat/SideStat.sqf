#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OOP_DEBUG

#include "..\common.h"

/*
Class: SideStat
Author: zalexki 18.03.2019
*/

#define OOP_CLASS_NAME SideStat
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
	METHOD(new)
		params [P_THISOBJECT, "_side", "_humanResources"];
		T_SETV("side", _side);
		T_SETV("humanResources", _humanResources);
	ENDMETHOD;
	
	/*
	Method: getHumanResources
	Returns: integer - humanResources
	*/
	METHOD(getHumanResources)
		params [P_THISOBJECT];
		T_GETV("humanResources");
	ENDMETHOD;
	
	/*
	Method: incrementHumanResourcesBy
	Parameters: _valueToInc
	_valueToInc - integer
	Returns: nil
	*/
	METHOD(incrementHumanResourcesBy)
		params [P_THISOBJECT, "_valueToInc"];
		private _currentHR = T_GETV("humanResources");
		private _nextHR = _currentHR + _valueToInc;

		T_SETV("humanResources", _nextHR);
	ENDMETHOD;

	/*
	Method: decrementHumanResourcesBy 
	Parameters: _valueToDec
	_valueToDec - integer
	Returns: nil
	*/
	METHOD(decrementHumanResourcesBy)
		params [P_THISOBJECT, "_valueToDec"];
		private _currentHR = T_GETV("humanResources");
		private _nextHR = _currentHR - _valueToDec;

		T_SETV("humanResources", _nextHR);
	ENDMETHOD;

ENDCLASS;
