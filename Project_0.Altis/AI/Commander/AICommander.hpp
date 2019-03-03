// An array with unique identifiers (numbers))
#define TARGET_CLUSTER_ID_IDS			0

// The cluster
#define TARGET_CLUSTER_ID_CLUSTER		1

// Efficiency vector (strength) of this target cluster
#define TARGET_CLUSTER_ID_EFFICIENCY	2

// Damange caused by this target cluster
#define TARGET_CLUSTER_ID_CAUSED_DAMAGE	3

// Array with garrisons that observe this target cluster
#define TARGET_CLUSTER_ID_OBSERVED_BY	4

#define TARGET_CLUSTER_NEW() [nil, nil, nil, nil, nil]

// Minimum distance for enemy clusters before they are merged into one cluster
#define TARGETS_CLUSTER_DISTANCE_MIN	500


// Structure of a target record for commander
// It's the same as targets structure but has an array with garrisons that are observing this target
#define TARGET_COMMANDER_ID_OBJECT_HANDLE	0 
#define TARGET_COMMANDER_ID_KNOWS_ABOUT		1
#define TARGET_COMMANDER_ID_POS				2
#define TARGET_COMMANDER_ID_TIME			3
#define TARGET_COMMANDER_ID_OBSERVED_BY		4
#define TARGET_COMMANDER_NEW(hO, knows, pos, time, observedBy) [hO, knows, pos, time, observedBy]