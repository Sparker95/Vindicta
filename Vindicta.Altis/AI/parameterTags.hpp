// /*
// Parameter tags used by actions are defined here

// TAG_G_... - parameters passed to goals
// TAG_... - parameters passed to actions
// */

#define TAG_MOUNT "a_mount"

#define TAG_G_POS "g_pos"
#define TAG_POS "a_pos"
#define TAG_ROUTE "g_route"
#define TAG_LOCATION "g_location"
#define TAG_MOVE_RADIUS "g_moveRadius"

// Action should be performed instantly where appropriate
// Used when garrisons spawn so they can immediately apply group and unit state for their current action
#define TAG_INSTANT "g_instant"

#define TAG_BEHAVIOUR "g_behaviour"
#define TAG_COMBAT_MODE "g_combatMode"
#define TAG_FORMATION "g_formation"
#define TAG_SPEED_MODE "g_speedMode"

#define TAG_CLEAR_RADIUS "g_clearRadius"

#define TAG_OVERWATCH_DISTANCE_MIN "g_overwatchDistanceMin" // Passed to overwatch action to specify the minimum distance to overwatch from
#define TAG_OVERWATCH_DISTANCE_MAX "g_overwatchDistanceMax" // Passed to overwatch action to specify the maximum distance to overwatch from
#define TAG_OVERWATCH_DIRECTION "g_overwatchDirection" // Passed to overwatch action to specify direction to observe the target from
#define TAG_OVERWATCH_ELEVATION "g_overwatchElevation" // Passed to overwatch action to specify the minimum elevation difference desired
#define TAG_OVERWATCH_GRADIENT "g_overwatchGradient" // Passed to overwatch action to specify the max gradient desired

#define TAG_CARGO "g_cargo"
#define TAG_CARGO_POS "g_cargoPos"

#define TAG_MERGE "a_merge"

#define TAG_DURATION_SECONDS "g_duration"

#define TAG_MAX_SPEED_KMH "g_maxSpeedKmh" // Passed to move actions to limit the agents average speed
#define TAG_FOLLOWERS "g_followers" // Passed to move actions to list other agents that are following this agent (so it can wait for them usually)

#define TAG_TARGET "g_target"	// General target parameter, usually a unit
#define TAG_ANIM "g_anim"	// Anim to use in GoalUnitAmbientAnim
#define TAG_BUILDING_POS_ID "g_buildingPosId"