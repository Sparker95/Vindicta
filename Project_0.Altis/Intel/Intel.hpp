// Enum, intel commander action states
#define INTEL_ACTION_STATE_INACTIVE		0
#define INTEL_ACTION_STATE_ACTIVE		1
#define INTEL_ACTION_STATE_END			2

// Enum, ways of getting intel
// We have made this intel ourselves, for instance because it's associated with out own action
#define INTEL_METHOD_OWN			0
// Civilians told us
#define INTEL_METHOD_TALK_CIV		1
// We found it through some inventory item
#define INTEL_METHOD_INVENTORY_ITEM	2
// We intercepted it through radio
#define INTEL_METHOD_RADIO			3
