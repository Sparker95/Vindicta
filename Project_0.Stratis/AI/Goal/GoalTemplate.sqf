#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"

#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "..\goalRelevance.hpp"

/*
Template of a goal class
*/

//Include some forld state properties
#include "garrisonWorldStateProperties.hpp"


#define pr private

CLASS("MyGoal", "Goal")

	STATIC_VARIABLE("effects"); // Array of world properties
	
	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	
	STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];
		
	} ENDMETHOD;

ENDCLASS;