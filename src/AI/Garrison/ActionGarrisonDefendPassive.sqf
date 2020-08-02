#include "common.hpp"

// Passive defense:
// Assign patrol and idle groups.
// Patrol groups patrol
// - patrol speed to normal, formation to staggered column
// - mount all vehicles
// - move idle groups inside
// - patrol roads with vehicle groups
// - set vehicle gunners to scan their sectors

#define OOP_CLASS_NAME ActionGarrisonDefendPassive
CLASS("ActionGarrisonDefendPassive", "ActionGarrisonDefend")

ENDCLASS;