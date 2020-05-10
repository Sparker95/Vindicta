// === Position

// Position ASL
#define WSP_UNIT_POS_ASL 0

// Vehicle position ASL
// Action that performs vehicle driving has this property as effect
#define WSP_UNIT_VEHICLE_POS_ASL 1

// [buildingHandle, buildingPosID]
#define WSP_UNIT_POS_BUILDING 2



// === Vehicle interaction

// Bool, true if in any vehicle
#define WSP_UNIT_IN_VEHICLE 3

// OOP Vehicle Unit handle, or NULL_OBJECT if not in vehicle
#define WSP_UNIT_CURRENT_VEHICLE 4

// ["TURRET", turretpath]
// ["DRIVER"]
// ["CARGO"]
// [""] - if not in vehicle
#define WSP_UNIT_VEHICLE_ROLE 5


// === Object interaction

// Object unit is interacting with
// General case: go to some place or to target, interact with it
// Target of ambient animation
// Shooting range target
// Target unit to heal
// Target unit to repair
// Target to do warning shots
// What else?
#define WSP_UNIT_INTERACT_OBJECT 6

// Bool, true if interacting with some object
#define WSP_UNIT_INTERACTING_WITH_OBJECT 7


// === Other

// Bool, true if talking with someone
#define WSP_UNIT_DOING_DIALOGUE 8

// Following leader while on foot
#define WSP_UNIT_IN_INFANTRY_FORMATION 9

// Bool, true if in combat or in danger
 // Might trigger different behaviours for civilians and military?
#define WSP_UNIT_DANGER 10