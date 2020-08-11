// An array with unique identifiers (numbers))
#define TARGET_CLUSTER_ID_ID			0

// The cluster
#define TARGET_CLUSTER_ID_CLUSTER		1

// Efficiency vector (strength) of this target cluster
#define TARGET_CLUSTER_ID_EFFICIENCY	2

// Damange caused by this target cluster
#define TARGET_CLUSTER_ID_CAUSED_DAMAGE	3

// Array with garrisons that observe this target cluster
#define TARGET_CLUSTER_ID_OBSERVED_BY	4

// Max time of all observed targets (max time when they were last spotted)
#define TARGET_CLUSTER_ID_MAX_DATE_NUMBER 5

// Intel object associated with this cluster
#define TARGET_CLUSTER_ID_INTEL 6

#define TARGET_CLUSTER_NEW() [nil, nil, nil, nil, nil, nil, ""]

// Minimum distance for enemy clusters before they are merged into one cluster
#define TARGETS_CLUSTER_DISTANCE_MIN	500

// Maximum distance for QRF that doesn't need vehicles to transport troops
#define QRF_NO_TRANSPORT_DISTANCE_MAX	666

#define TAKE_LOCATION_NO_TRANSPORT_DISTANCE_MAX 1500
#define REINFORCE_NO_TRANSPORT_DISTANCE_MAX 2000

// Distance from cluster center to where the troops must dismount while performing ClearArea goal
#define CLEAR_AREA_DISMOUNT_DISTANCE	400


// Structure of a target record for commander
// It's the same as targets structure but has an array with garrisons that are observing this target
#define TARGET_COMMANDER_ID_UNIT			0 
#define TARGET_COMMANDER_ID_KNOWS_ABOUT		1
#define TARGET_COMMANDER_ID_POS				2
#define TARGET_COMMANDER_ID_DATE_NUMBER		3
#define TARGET_COMMANDER_ID_EFFICIENCY		4
#define TARGET_COMMANDER_ID_OBSERVED_BY		5
#define TARGET_COMMANDER_NEW(hO, knows, pos, time, eff, observedBy) [hO, knows, pos, time, eff, observedBy]






// ===================== Ported from CmdrAI =======================

#define MODEL_HANDLE_INVALID 		-1


// Enum: AI.CmdrAI.WORLD_TYPE
// Flags for <Model.WorldModel.new> type parameter.
// WORLD_TYPE_REAL - Real world model, contained objects represent the last known state of actual garrisons, locations, clusters etc.
// WORLD_TYPE_SIM_NOW - Sim model with only current effects of actions applied.
// 						i.e. Real world model + the effects of any active action that would be applied immediately if
//						the action itself were to update. For instance if the action is to split a garrison in half, it would apply 
//						immediately because splitting a garrison is an instantaneous operation. But a move action would not apply
//						because moving takes time.
//						The purpose of this model of the world is mostly to simulate changes in available resources while new 
//						actions are being planned. Usually the first part of an action is to allocate its resources (e.g. splitting 
//						a detachment off from an existing garrison to perform the action with).
// WORLD_TYPE_SIM_FUTURE - Sim model with current and future effects of actions applied
#define WORLD_TYPE_REAL					0
#define WORLD_TYPE_SIM_NOW				1
#define WORLD_TYPE_SIM_FUTURE			2

// Enum: AI.CmdrAI.SPLIT_FLAGS
// Flags for <Model.GarrisonModel.splitActual> flags parameter, they control logic and validation.
// ASSIGN_TRANSPORT - Attempt to assign transport for the new garrison
// FAIL_WITHOUT_FULL_TRANSPORT -Fail if we couldn't assign transport to the new garrison (<ASSIGN_TRANSPORT> required)
// FAIL_UNDER_EFF -Fail if the split garrison didn't meet efficiency requirements
// CHEAT_TRANSPORT -Spawn trucks if they are not available and transport is requested
// OCCUPYING_FORCE_HINT -Hint to select units approproiate for an occupying force (e.g. plenty of inf)
// COMBAT_FORCE_HINT -Hint to select units approproiate for direct combat (e.g. heavy firepower)
// RECON_FORCE_HINT -Hint to select units approproiate for a recon force (e.g. recon units, fast transport)
// SPEC_OPS_FORCE_HINT -Hint to select units approproiate for a spec ops (e.g. spec ops units, covert transport)
// PATROL_FORCE_HINT -Hint to select units approproiate for a patrol force (e.g. normal units, fast/lightly armed transport)
#define ASSIGN_TRANSPORT				1
#define FAIL_WITHOUT_FULL_TRANSPORT		2
#define FAIL_UNDER_EFF					3
#define CHEAT_TRANSPORT					4
#define OCCUPYING_FORCE_HINT			5
#define COMBAT_FORCE_HINT				6
#define RECON_FORCE_HINT				7
#define SPEC_OPS_FORCE_HINT				8
#define PATROL_FORCE_HINT				9

#define SPLIT_VALIDATE_ATTACK			10
#define SPLIT_VALIDATE_TRANSPORT		11
#define SPLIT_VALIDATE_TRANSPORT_EXT	12
#define SPLIT_VALIDATE_CREW				13
#define SPLIT_VALIDATE_CREW_EXT			14

#ifdef _SQF_VM
#undef DEBUG_CMDRAI_ACTIONS
#endif

// Shortcuts
#define LABEL(model) GETV(model, "label")
#define EFF_ZERO T_EFF_null
#define MAKE_SCORE_VEC(scorePriority, scoreResource, scoreStrategy, scoreCompleteness) [scorePriority, scoreResource, scoreStrategy, scoreCompleteness]
#define ZERO_SCORE [0,0,0,0]
#define GET_SCORE_PRIORITY(scoreVec) (scoreVec select 0)
#define GET_SCORE_RESOURCE(scoreVec) (scoreVec select 1)
#define GET_SCORE_STRATEGY(scoreVec) (scoreVec select 2)
#define GET_SCORE_COMPLETENESS(scoreVec) (scoreVec select 3)
#define APPLY_SCORE_STRATEGY(scoreVec, strategyScore) [scoreVec select 0, scoreVec select 1, strategyScore, scoreVec select 3]

// Minimum efficiency of a garrison.
// Controls lots of commander actions, e.g. reinforcements won't be less than this, or leave less than this at an outpost.
// See Templates\initEfficiency.sqf to understand what these mean:
//									 0  1  2  3  4  5  6  7  8  9  10 11 12 13
//									soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
#define EFF_MIN_EFF					[6,		0,		0,		0,		6,		0,		0,		0,		0,		0,		0,		0,		0,		6]
#define EFF_GARRISON_MIN_EFF		[12,	0,		0,		0,		12,		0,		0,		0,		0,		0,		0,		0,		0,		12]
	
#define EFF_FOOT_PATROL_EFF			[8,		0,		0,		0,		8,		0,		0,		0,		0,		0,		0,		0,		0,		8]
#define EFF_MOUNTED_PATROL_EFF		[8,		0,		0,		0,		8,		0,		0,		0,		0,		0,		0,		0,		0,		8]

// Maximum ENEMY efficiency values to limit potential response force within sane values
//									soft,	medium,	armor,	air,	a-soft,	a-med,	a-arm,	a-air	req.tr	transp	ground	water	req.cr	crew
// Used in 'take location'
#define ENEMY_LOCATION_EFF_MAX		[40,	7,		6,		2,		9999,	9999,	9999,	9999,	9999,	9999,	9999,	9999,	9999,	9999]
// Used in 'QRF' cmdr action
#define ENEMY_CLUSTER_EFF_MAX		[30,	7,		6,		2,		9999,	9999,	9999,	9999,	9999,	9999,	9999,	9999,	9999,	9999]

// Max amount of simultaneous actions
#define CMDR_MAX_TAKE_OUTPOST_ACTIONS 2
#define CMDR_MAX_REINFORCE_ACTIONS 3
#define CMDR_MAX_SUPPLY_ACTIONS 6
#define CMDR_MAX_OFFICER_ASSIGNMENT_ACTIONS 3
// QRF actions
#define CMDR_MAX_ATTACK_ACTIONS 4
#define CMDR_MAX_PATROL_ACTIONS 6
#define CMDR_MAX_CONSTRUCT_ACTIONS 2

// Max amount of units at airfields
#define CMDR_MAX_INF_AIRFIELD 80
#define CMDR_MAX_VEH_AIRFIELD 25

// Max amount of ground vehicles which can be imported at each external reinforcement
#define CMDR_MAX_GROUND_VEH_EACH_EXTERNAL_REINFORCEMENT 5

#ifdef OOP_ASSERT
#define ASSERT_CLUSTER_ACTUAL_OR_NULL(actual)  \
	ASSERT_MSG(actual isEqualType [], QUOTE(actual) + " is invalid type. It should be an array."); \
	if(count actual > 0) then { \
		ASSERT_CLUSTER_ACTUAL_NOT_NULL(actual); \
	}
#define ASSERT_CLUSTER_ACTUAL_NOT_NULL(actual) \
	ASSERT_MSG(actual isEqualType [], QUOTE(actual) + " is invalid type. It should be an array."); \
	ASSERT_MSG(count actual == 2, QUOTE(actual) + " should be an array of the form [AICommander, Cluster ID]"); \
	ASSERT_OBJECT_CLASS(actual select 0, "AICommander"); \
	ASSERT_MSG((actual select 1) isEqualType 0, QUOTE(actual) + " should be an array of the form [AICommander, Cluster ID]")
#else
#define ASSERT_CLUSTER_ACTUAL_OR_NULL(actual)
#define ASSERT_CLUSTER_ACTUAL_NOT_NULL(actual)
#endif

#ifdef OOP_INFO
#define OOP_INFO_MSG_REAL_ONLY(world, fmt, args) \
	if(CALLM0(world, "isReal")) then { \
		OOP_INFO_MSG(fmt, args); \
	};
#else
#define OOP_INFO_MSG_REAL_ONLY(world, fmt, args)
#endif
#ifdef OOP_DEBUG
#define OOP_DEBUG_MSG_REAL_ONLY(world, fmt, args) \
	if(CALLM0(world, "isReal")) then { \
		OOP_DEBUG_MSG(fmt, args); \
	};
#else
#define OOP_DEBUG_MSG_REAL_ONLY(world, fmt, args)
#endif

// Activity function common between different methods
// Maps activity at area to a priority multiplier
// https://www.desmos.com/calculator/sjoagy4rro
// This maps activity=value like: 25=~0.5, 100=1, 1000=~2 
#define __ACTIVITY_FUNCTION(rawActivity) (log (0.09 * MAP_LINEAR_SET_POINT(vin_diff_global, 0.2, 1, 3) * (rawActivity) + 1))

// https://www.desmos.com/calculator/vgvrm8x3un
#define __DAMAGE_FUNCTION(rawDamage, campaignProgress) (exp(-0.5 * (1 - sqrt(0.9 * MAP_GAMMA(vin_diff_global, campaignProgress))) * (rawDamage - 8)) - 0.1)
