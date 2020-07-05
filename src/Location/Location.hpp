
// Spawn Positions
// [_pos, _dir, _building]
#define LOCATION_SP_ID_POS		0
#define LOCATION_SP_ID_DIR		1
#define LOCATION_SP_ID_BUILDING	2
#define LOCATION_SP_ID_COOLDOWN	3

#define LOCATION_SP_DEFAULT [[], 0, objNull, 0]

// Spawn Position Types:
// [_unitTypes, _groupTypes, _positions, _counter]

// Array with unit types [_catid, subcatid]
#define LOCATION_SPT_ID_UNIT_TYPES 	0
// Array with group types
#define LOCATION_SPT_ID_GROUP_TYPES	1
// Array with spawn positions (look above)
#define LOCATION_SPT_ID_SPAWN_POS	2
// Counter
#define LOCATION_SPT_ID_COUNTER		3

#define LOCATION_SPT_DEFAULT [[], [], [], 0]

#define LOCATION_TYPE_UNKNOWN "unknown"
#define LOCATION_TYPE_CITY "city"
#define LOCATION_TYPE_CAMP "camp"
#define LOCATION_TYPE_BASE "base"
#define LOCATION_TYPE_OUTPOST "outpost"
#define LOCATION_TYPE_DEPOT "depot"
#define LOCATION_TYPE_POWER_PLANT "pwrPlant"
#define LOCATION_TYPE_POLICE_STATION "policeStation"
#define LOCATION_TYPE_RADIO_STATION "radioStation"
#define LOCATION_TYPE_AIRPORT "airport"
#define LOCATION_TYPE_ROADBLOCK "roadblock"
#define LOCATION_TYPE_OBSERVATION_POST "obsPost"
#define LOCATION_TYPE_RESPAWN "respawn"

#define LOCATIONS_RECRUIT [LOCATION_TYPE_CAMP, LOCATION_TYPE_BASE, LOCATION_TYPE_OUTPOST, LOCATION_TYPE_AIRPORT]
#define LOCATIONS_BUILD_PROGRESS [LOCATION_TYPE_BASE, LOCATION_TYPE_OUTPOST, LOCATION_TYPE_AIRPORT]

#define BUILDUI_OBJECT_TAG "build_ui_allowMove"

#define SAVED_OBJECT_TAGS [BUILDUI_OBJECT_TAG]
