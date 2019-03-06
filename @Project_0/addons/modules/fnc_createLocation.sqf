#include "script_component.hpp"

params [
    ["_logic",""],
    ["_string",""]
];


diag_log format["DEBUG: _logic %1", _logic];
_marker = _string select 0;

diag_log format["DEBUG: _marker pos %1", getPos _marker];

_type = _marker getVariable ["Type", ""];
diag_log format["DEBUG: _type %1", _type];

// Module specific behavior. Function can extract arguments from logic and use them.
// Attribute values are saved in module's object space under their class names
// _type = _logic getVariable ["Type",-1]; //(as per the previous example, but you can define your own.) 
// diag_log format ["DEBUG: Type location is: %1", _type ]; // will display the bomb yield, once the game is started 

// Module function is executed by spawn command, so returned value is not necessary, but it's good practice.
true
