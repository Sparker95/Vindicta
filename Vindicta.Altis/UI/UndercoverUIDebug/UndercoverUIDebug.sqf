#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#include "..\..\common.h"
#include "..\..\Undercover\undercoverMonitor.hpp"
#include "..\Resources\UndercoverUIDebug\UndercoverUIDebug_Macros.h"

#define pr private

/*

	Handles displaying data on the Undercover debug UI.

	Author: Marvis
	Date: 08.02.2019

*/

params ["_unit"];

pr _uM = _unit getVariable "undercoverMonitor";


pr _var = _unit getVariable "suspicion";
if (isNil "_var") then { _var = "Undefined"; };
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T1) ctrlSetText format ["suspicion: %1", _var];


_var = GETV(_uM, "suspGear");
if (isNil "_var") then { _var = "Undefined"; };
_var2 = GETV(_uM, "suspGearVeh");
if (isNil "_var2") then { _var2 = "Undefined"; };
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T2) ctrlSetText format ["suspGear: %1 (%2)", _var, _var2];

_var = _unit getVariable "bInVeh";
if (isNil "_var") then { _var = "Undefined"; };
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T3) ctrlSetText format ["In veh: %1", _var];

_var = _unit getVariable "bodyExposure";
if (isNil "_var") then { _var = "Undefined"; };
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T4) ctrlSetText format ["bodyExposure: %1", _var];

_var = _unit getVariable "distance";
if (isNil "_var") then { _var = "Undefined"; };
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T5) ctrlSetText format ["Distance near. E.: %1", _var];

_var = _unit getVariable "nearestEnemy";
if (isNil "_var") then { _var = "Undefined"; };
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T6) ctrlSetText format ["Nearest enemy: %1", _var];


_var = GETV(_uM, "bCaptive");
if (isNil "_var") then { 
	_var = "Undefined";
} else {
	if (_var) then {
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T7) ctrlSetBackgroundColor [0, 0.819, 0.341, 1];
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T7) ctrlSetTextColor [1, 1, 1, 1];
	} else {	
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T7) ctrlSetBackgroundColor [0.819, 0, 0.113, 1];
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T7) ctrlSetTextColor [1, 1, 1, 1];
	};
};
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T7) ctrlSetText format ["bCaptive: %1", _var];


_var = _unit getVariable "suspDistVeh";
if (isNil "_var") then { _var = "Undefined"; };
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T12) ctrlSetText format ["suspDistVeh: %1", _var];


_var = _unit getUnitTrait "camouflageCoef";
if (isNil "_var") then { _var = "Undefined"; };
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T13) ctrlSetText format ["CamoCoeff: %1", _var];


pr _uM = _unit getVariable "undercoverMonitor";
_var = GETV(_uM, "state");
if (isNil "_var") then { 
	_var = "Undefined";
} else {
	switch (_var) do {
		case 0: { _var = "UNDERCOVER"; };
		case 1: { _var = "WANTED"; };
		case 2: { _var = "COMPROMISED"; };
		case 3: { _var = "ARRESTED"; };
		case 4: { _var = "INCAPACITATED"; };
	};
};
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T8) ctrlSetTextColor [1, 1, 1, 1];
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T8) ctrlSetBackgroundColor [0, 0, 0, 1];
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T8) ctrlSetText _var;

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

_var = GETV(_uM, "bSeen");
if (isNil "_var") then { 
	_var = "Undefined";
} else {
	if (_var) then {
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T10) ctrlSetBackgroundColor [0, 0.819, 0.341, 1];
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T10) ctrlSetTextColor [1, 1, 1, 1];
	} else {	
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T10) ctrlSetBackgroundColor [0.819, 0, 0.113, 1];
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T10) ctrlSetTextColor [1, 1, 1, 1];
	};
};
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T10) ctrlSetText format ["Seen: %1", _var];

_var = _unit getVariable "bSuspicious";
if (isNil "_var") then { 
	_var = "Undefined";
} else {
	if (_var) then {
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T11) ctrlSetBackgroundColor [0, 0.819, 0.341, 1];
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T11) ctrlSetTextColor [1, 1, 1, 1];
	} else {	
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T11) ctrlSetBackgroundColor [0.819, 0, 0.113, 1];
		((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T11) ctrlSetTextColor [1, 1, 1, 1];
	};
};
((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_T11) ctrlSetText format ["Suspicious: %1", _var];


if (captive _unit) then {
	((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_CAPT) ctrlSetBackgroundColor [0, 0.819, 0.341, 1];
	((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_CAPT) ctrlSetTextColor [1, 1, 1, 1];
	((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_CAPT) ctrlSetText "CAPTIVE";
} else {	
	((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_CAPT) ctrlSetBackgroundColor [0.819, 0, 0.113, 1];
	((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_CAPT) ctrlSetTextColor [1, 1, 1, 1];
	((uinamespace getVariable "undercoverUIDebug_display") displayCtrl IDC_CAPT) ctrlSetText "NOT CAPTIVE";
};