/*
Class: Camps
Location has garrisons at a static place and spawns units.

Author: Sparker 28.07.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "Camps.hpp"

#define pr private

//add arsenal to box: [_object] call JN_fnc_arsenal_init; 

CLASS("Camps", "")

	// |                               N E W                             	|

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_pos", [], [[]]]];

		// create a new location for our camp
		pr _location = NEW("Location", [getPos player]);
		CALLM2(_location, "setBorder", "circle", CAMP_SIZE);
		pr _locationPos = CALLM0(_location, "getPos");

		// create Jeroen arsenal box
		pr _arsenalBox = "Box_FIA_Support_F" createVehicle _locationPos;
		[_arsenalBox] call JN_fnc_arsenal_init;

		systemChat "Creating camp";
	} ENDMETHOD;
	

	// |                            D E L E T E                             |

	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;

	// |                            			                            |

ENDCLASS;Box_FIA_Support_F