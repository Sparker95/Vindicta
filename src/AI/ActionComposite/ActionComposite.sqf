#include "..\..\common.h"
#include "..\Action\Action.hpp"

/*
Class: Action.ActionComposite
It is a base class for <ActionCompositeSerial> and <ActionCompositeParallel>.

Based on source from "Programming Game AI by Example" by Mat Buckland: http://www.ai-junkie.com/books/toc_pgaibe.html

Author: Sparker 05.08.2018
*/

#define OOP_CLASS_NAME ActionComposite
CLASS("ActionComposite", "Action")

	VARIABLE("subactions"); // Array with subactions
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD(new)
		params [P_THISOBJECT];

		T_SETV("subactions", []);
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD(delete)
		params [P_THISOBJECT];
		
		// Delete all subactions
		T_CALLM0("deleteAllSubactions");
	ENDMETHOD;
	
	public override METHOD(setInstant)
		params [P_THISOBJECT, P_BOOL("_instant")];

		T_CALLCM1("Action", "setInstant", _instant);

		// Only set subactions instant when true. Only processed actions should have instant toggled off again (this should be done in the overriden process function)
		if(_instant) then {
			{
				CALLM1(_x, "setInstant", _instant);
			} forEach T_CALLM0("getSubactions");
		};
	ENDMETHOD;


	/*
	Method: getFrontSubaction
	Returns the first action in the subactions array, or "" if the array is empty.
	
	Returns: <Action> or ""
	*/
	
	public override METHOD(getFrontSubaction)
		params [P_THISOBJECT];

		private _sa = T_GETV("subactions");
		if (count _sa == 0) then {
			NULL_OBJECT
		} else {
			_sa select 0
		};
	ENDMETHOD;

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
	public override METHOD(addSubactionToFront)
		params [P_THISOBJECT, P_OOP_OBJECT("_subaction")];

		private _subactions = T_GETV("subactions");
		private _newSubactions = [_subaction];
		_newSubactions append _subactions;
		T_SETV("subactions", _newSubactions);
	ENDMETHOD;
	
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
	public override METHOD(addSubactionToBack)
		params [P_THISOBJECT, P_OOP_OBJECT("_subaction")];

		private _subactions = T_GETV("subactions");
		_subactions pushBack _subaction;
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                          G E T   S U B A C T I O N S
	// ----------------------------------------------------------------------
	/*
	Method: getSubations
	Returns the list of subactions
	
	Returns: Array of actions
	*/
	public override METHOD(getSubactions)
		params [P_THISOBJECT];

		T_GETV("subactions")
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                   D E L E T E   A L L   S U B A C T I O N S
	// ----------------------------------------------------------------------
	/*
	Method: deleteAllSubactions
	Deletes all subactions. Calls terminate method before deleting every subaction.
	
	Returns: nil
	*/
	METHOD(deleteAllSubactions)
		params [P_THISOBJECT];

		// Regardless if the action is serial or parallel, terminate and delete all subactions
		private _subactions = T_GETV("subactions");
		{
			CALLM0(_x, "terminate");
			DELETE(_x);
		} forEach _subactions;
		T_SETV("subactions", []);
	ENDMETHOD;

ENDCLASS;