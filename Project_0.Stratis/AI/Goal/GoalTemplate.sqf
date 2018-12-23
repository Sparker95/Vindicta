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

#define pr private

CLASS("MyGoal", "Goal")

	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// If this method is not overwritten, it will return a static relevance
	STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];
		
	} ENDMETHOD;

ENDCLASS;