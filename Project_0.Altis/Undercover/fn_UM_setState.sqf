#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR
#define OFSTREAM_FILE "Undercover.rpt"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "UndercoverMonitor.hpp"
#include "..\modCompatBools.sqf"
#include "..\UI\UndercoverUI\UndercoverUI_Macros.h"

#define pr private

/* 
	Tests the "compromise" feature of the undercoverMonitor by sending a message to the monitor.

	Parameter: _unit - the unit that is to be compromised

	Example: [player] call fnc_testCompromise
*/


params ["_unit", "_state"];

pr _uM = _unit getVariable "undercoverMonitor";

if (_uM != "") then {

	CALLM(_uM, "setState", [_state]);

};