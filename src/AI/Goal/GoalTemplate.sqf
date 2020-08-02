#include "common.hpp"
/*
Template of a goal class
*/

#define pr private

#define OOP_CLASS_NAME MyGoal
CLASS("MyGoal", "Goal")

	// ----------------------------------------------------------------------
	// |          G E T   P O S S I B L E   P A R A M E T E R S             |
	// ----------------------------------------------------------------------
	/*
	Method: getPossibleParameters

	Other classes must override that to declare parameters passed to goal! 

	Returns array [requiredParameters, optionalParameters]
	requiredParameters and optionalParameters are arrays of: [tag, type]
		tag - string
		type - some value against which isEqualType will be used
	*/
	STATIC_METHOD(getPossibleParameters)
		[
			[],	// Required parameters
			[]	// Optional parameters
		]
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// If this method is not overwritten, it will return a static relevance
	public STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
		
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |            C R E A T E   P R E D E F I N E D   A C T I O N
	// ----------------------------------------------------------------------
	// By default it gets predefined action from database if it is defined and creates it, passing a goal parameter to action parameter, if it exists
	// This method must be redefined for goals that have predefined actions that require parameters not from goal parameters
	
	public virtual STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		
	ENDMETHOD;

	/*
	Updates current world state as perceived by this goal.
	Does nothing by default.
	You can override it and modify the passed _ws world state.
	*/
	STATIC_METHOD(onGoalChosen)
		//params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];
	ENDMETHOD;

	// Gets called when an external goal of this class is added to AI
	STATIC_METHOD(onGoalAdded)
		//params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
	ENDMETHOD;

	// Gets called when an external goal of this class is removed from an AI
	STATIC_METHOD(onGoalDeleted)
		//params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
	ENDMETHOD;

	// Gets called if plan generation is failed
	STATIC_METHOD(onPlanFailed)
		//params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")]
	ENDMETHOD;

	// Called when this goal was reached (action has returned ACTION_STATE_COMPLETED)
	STATIC_METHOD(onGoalCompleted)
		// params [P_THISCLASS, P_OOP_OBJECT("_AI")];
	ENDMETHOD;

	// Called when this goal was failed (action has returned ACTION_STATE_FAILED)
	STATIC_METHOD(onGoalFailed)
		// params [P_THISCLASS, P_OOP_OBJECT("_AI")];
	ENDMETHOD;

ENDCLASS;