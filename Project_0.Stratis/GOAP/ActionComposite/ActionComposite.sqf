/*
The composite goal class. It is a base class for ActionCompositeSerial and ActionCompositeParallel.

Based on source from "Programming Game AI by Example" by Mat Buckland: http://www.ai-junkie.com/books/toc_pgaibe.html

Author: Sparker 05.08.2018
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\Action\Action.hpp"

CLASS("ActionComposite", "Action")

	VARIABLE("subgoals"); // Array with subgoals
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]]];
		SETV(_thisObject, "subactions", []);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
		// Delete all subactions
		CALLM(_thisObject, "deleteAllSubactions", []);
	} ENDMETHOD;
	
	
	// Serial and Parallel composite actions implement this method differently
	/*virtual*/ METHOD("processSubactions") {	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          A D D   S U B G O A L                     |
	// |                                                                    |
	// | Adds a subaction to the front of the subaction array                   |
	// ----------------------------------------------------------------------
	METHOD("addSubaction") {
		params [["_thisObject", "", [""]], ["_subaction", "", [""]] ];
		private _subactions = GETV(_thisObject, "subactions");
		private _newSubactions = [_subaction];
		_newSubactions append _subactions;
		SETV(_thisObject, "subactions", _newSubactions);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          G E T   S U B G O A L S                   |
	// |                                                                    
	// | Returns the list of subactions (for debug purposes)
	// ----------------------------------------------------------------------
	METHOD("getSubactions") {
		params [["_thisObject", "", [""]]];
		GETV(_thisObject, "subactions")
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   D E L E T E   A L L   S U B G O A L S            |
	// ----------------------------------------------------------------------
	
	METHOD("deleteAllSubactions") {
		params [["_thisObject", "", [""]]];
		// Regardless if the action is serial or parallel, terminate and delete all subactions
		private _subactions = GETV(_thisObject, "subactions");
		{
			CALLM(_x, "terminate", []);
			DELETE(_x);
		} forEach _subactions;
		SETV(_thisObject, "subactions", []);
	} ENDMETHOD;

ENDCLASS;