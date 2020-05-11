// === Position

// At desired target position
#define WSP_UNIT_AT_TARGET_POS 0



// === Vehicle interaction

// In any vehicle
#define WSP_UNIT_IN_VEHICLE 1		

// In assigned vehicle
#define WSP_UNIT_IN_TARGET_VEHICLE 2

// In assigned vehicle and in assigned role
#define WSP_UNIT_CORRECT_VEHICLE_ROLE 3


// === Object interaction

// Interacting with something:
// Ambient animation
// Shooting range target
// Healing another unit
// Repairing vehicle
// Doing warning shots
// What else?
// !! Dialogue is not form of interaction since we can do both dialogue and interaction
#define WSP_UNIT_DOING_INTERACTION 4


// === Other

// Bool, true if talking with someone
#define WSP_UNIT_DOING_DIALOGUE 5

// Following leader while on foot
// Might be required for some infantry actions
#define WSP_UNIT_IN_INFANTRY_FORMATION 6

// Bool, true if in combat or in danger
// Might trigger different behaviours for civilians and military?
#define WSP_UNIT_IN_DANGER 7