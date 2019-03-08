#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Undercover\undercoverMonitor.hpp"
#include "..\Resources\UndercoverUIDebug\UndercoverUIDebug_Macros.h"

#define pr private

/*

	Handles displaying data on the Undercover debug UI.

	Author: Marvis
	Date: 08.02.2019

*/

params ["_unit"];


pr _var = _unit getVariable "suspicion";
if (isNil "_var") then { _var = "Undefined"; };
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T1) ctrlSetText format ["suspicion: %1", _var];

_var = _unit getVariable "suspGear";
if (isNil "_var") then { _var = "Undefined"; };
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T2) ctrlSetText format ["suspGear: %1", _var];

_var = _unit getVariable "suspGearVeh";
if (isNil "_var") then { _var = "Undefined"; };
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T3) ctrlSetText format ["suspGearVeh: %1", _var];

_var = _unit getVariable "bodyExposure";
if (isNil "_var") then { _var = "Undefined"; };
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T4) ctrlSetText format ["bodyExposure: %1", _var];


/*
_var = _unit getVariable "bInVeh";
if (isNil "_var") then { 
	_var = "Undefined"; 
} else {
	if (_var) then {
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T8) ctrlSetBackgroundColor [0, 0.819, 0.341, 1];
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T8) ctrlSetTextColor [1, 1, 1, 1];
	} else {	
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T8) ctrlSetBackgroundColor [0.819, 0, 0.113, 1];
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T8) ctrlSetTextColor [1, 1, 1, 1];
	};
};
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T8) ctrlSetText format ["bInVeh (in Vehicle): %1", _var];
*/


_var = _unit getVariable "bExposed";
if (isNil "_var") then { 
	_var = "Undefined"; 
} else {
	if (_var) then {
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T9) ctrlSetBackgroundColor [0, 0.819, 0.341, 1];
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T9) ctrlSetTextColor [1, 1, 1, 1];
	} else {	
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T9) ctrlSetBackgroundColor [0.819, 0, 0.113, 1];
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T9) ctrlSetTextColor [1, 1, 1, 1];
	};
};
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T9) ctrlSetText format ["Is exposed: %1", _var];

_var = _unit getVariable "suspGearVeh";
if (isNil "_var") then { _var = "Undefined"; };
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T10) ctrlSetText format ["suspGearVeh: %1", _var];