#include "common.hpp"
/*
Responds to every spotted cluster with targets.
*/

CLASS("ActionCommanderRespondToTargetCluster", "Action")

	// ID of the cluster we are responding to
	VARIABLE("clusterID");

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]], ["_clusterID", 0, [0]] ];

		T_SETV("clusterID", _clusterID);
	
	} ENDMETHOD;

	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];

		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);

		// Return ACTIVE state
		ACTION_STATE_ACTIVE

	} ENDMETHOD;

	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];

		CALLM(_thisObject, "activateIfInactive", []);

		// Return the current state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;

	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;

ENDCLASS;