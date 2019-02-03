#include "..\..\OOP_Light\OOP_Light.h"
#include "..\Action\Action.hpp"

/*
Class: Action.ActionComposite
It is a base class for <ActionCompositeSerial> and <ActionCompositeParallel>.

Based on source from "Programming Game AI by Example" by Mat Buckland: http://www.ai-junkie.com/books/toc_pgaibe.html

Author: Sparker 05.08.2018
*/

CLASS("ActionComposite", "Action")

	VARIABLE("subactions"); // Array with subactions
	
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
	// |            A D D   S U B A C T I O N   T O   F R O N T        
	// ----------------------------------------------------------------------
	/*
	Method: addSubactionToFront
	Adds a subaction to the FRONT of the subaction array
	
	Parameters: _subaction
	
	_subaction - <Action>
	
	Returns: nil
	*/
	METHOD("addSubactionToFront") {
		params [["_thisObject", "", [""]], ["_subaction", "", [""]] ];
		private _subactions = GETV(_thisObject, "subactions");
		private _newSubactions = [_subaction];
		_newSubactions append _subactions;
		SETV(_thisObject, "subactions", _newSubactions);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |            A D D   S U B A C T I O N   T O   F R O N T               
	// ----------------------------------------------------------------------
	/*
	Method: addSubactionToBack
	Adds a subaction to the BACK of the subaction array
	
	Parameters: _subaction
	
	_subaction - <Action>
	
	Returns: nil
	*/
	METHOD("addSubactionToBack") {
		params [["_thisObject", "", [""]], ["_subaction", "", [""]] ];
		private _subactions = GETV(_thisObject, "subactions");
		_subactions pushBack _subaction;
	} ENDMETHOD;
	
	
	// ----------------------------------------------------------------------
	// |                          G E T   S U B A C T I O N S
	// ----------------------------------------------------------------------
	/*
	Method: getSubations
	Returns the list of subactions
	
	Returns: Array of actions
	*/
	METHOD("getSubactions") {
		params [["_thisObject", "", [""]]];
		GETV(_thisObject, "subactions")
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   D E L E T E   A L L   S U B A C T I O N S
	// ----------------------------------------------------------------------
	/*
	Method: deleteAllSubactions
	Deletes all subactions. Calls terminate method before deleting every subaction.
	
	Returns: nil
	*/
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