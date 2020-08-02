// === Position

// At desired target position
#define WSP_UNIT_HUMAN_AT_TARGET_POS 0



// === Vehicle interaction

// In any vehicle
#define WSP_UNIT_HUMAN_AT_VEHICLE 1		

// In assigned vehicle
#define WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE 2

// In assigned vehicle and in assigned role
#define WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE_ROLE 3


// === Object interaction

// Interacting with something:
// Ambient animation
// Shooting range target
// Healing another unit
// Repairing vehicle
// Doing warning shots
// What else?
// !! Dialogue is not form of interaction since we can do both dialogue and interaction
#define WSP_UNIT_HUMAN_HAS_INTERACTED 4


// === Other

// Bool, true if allowed to do dialogue
#define WSP_UNIT_HUMAN_CAN_DIALOGUE 5

// Following leader while on foot
// Might be required for some infantry actions
#define WSP_UNIT_HUMAN_FOLLOWING_TEAMMATE 6

// In danger
#define WSP_UNIT_HUMAN_IN_DANGER 7

// Bool, true if it is allowed to use vehicles for this plan
#define WSP_UNIT_HUMAN_VEHICLE_ALLOWED 8

// Size is always last
#define WSP_UNIT_HUMAN_COUNT 9

#define WSP_UNIT_HUMAN_NAMES [ \
	"AT TARGET POS", \
	"AT VEHICLE", \
	"AT ASSIGNED VEH", \
	"AT ASSIGNED VEH ROLE", \
	"HAVE INTERACTED", \
	"CAN DIALOGUE", \
	"FOLLOWING TEAMMATE", \
	"IN DANGER", \
	"VEHICLE ALLOWED" \
]