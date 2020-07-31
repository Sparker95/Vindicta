// Enum, intel commander action states
#define INTEL_ACTION_STATE_INACTIVE		0
#define INTEL_ACTION_STATE_ACTIVE		1
#define INTEL_ACTION_STATE_END			2

// Enum, ways of getting intel
// We found it through some inventory item
#define INTEL_METHOD_INVENTORY_ITEM	0
// We intercepted it through radio
#define INTEL_METHOD_RADIO			1
// Civilians told us
#define INTEL_METHOD_TALK_CIV		2
// City rumours
#define INTEL_METHOD_CITY           3