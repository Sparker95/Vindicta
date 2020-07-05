#include "common.hpp"

// Active defense:
// Assign patrol and idle groups.
// Patrol groups patrol
// - patrol speed to full, behaviour to danger, formation to staggered column
// - mount all vehicles
// - move idle groups inside
// - set vehicle gunners to scan their sectors
// - patrol roads with vehicle groups
// - move vehicles to spread out positions, perhaps send some to overwatch positions or wide patrol routes
// - switch patrols to clear area?

#define OOP_CLASS_NAME ActionGarrisonDefendActive
CLASS("ActionGarrisonDefendActive", "ActionGarrisonDefend")

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		T_SETV("behaviour", "COMBAT");
		T_SETV("speedMode", "FULL");
		T_SETV("infantryFormation", "WEDGE");
		T_SETV("air", 1);
	ENDMETHOD;

ENDCLASS;