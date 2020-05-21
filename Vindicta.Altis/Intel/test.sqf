#include "..\common.h"

intel0 = NEW("Intel", []);
SETV(intel0, "timeCreated", time);
SETV(intel0, "timeUpdated", 123);

// Test cloning
intel1 = CLONE(intel0);

// Test assignment
intel2 = NEW("Intel", []);
ASSIGN(intel2, intel0);

// Test update macro
intel3 = CLONE(intel0);
intelUpdate = NEW("Intel", []);
SETV(intelUpdate, "source", "---update---");

UPDATE(intel3, intelUpdate);

// Test serialization
serIntel = SERIALIZE(intel0);

// Test deserialization
intel4 = NEW("Intel", []);
DESERIALIZE(intel4, serIntel);

// Test databases
db0 = NEW("IntelDatabase", [EAST]);
db1 = NEW("IntelDatabase", [WEST]);


intel0 = NEW("Intel", []);
intel1 = NEW("Intel", []);
intel2 = NEW("Intel", []);
intel3 = NEW("Intel", []);

// Update from source
//SETV(intel1, "timeCreated", 666);
//CALLM1(db1, "updateIntelFromSource", intel1);

SETV(intel0, "timeCreated", 456);
SETV(intel1, "timeCreated", 899);
SETV(intel2, "timeCreated", 123);
SETV(intel3, "timeCreated", 456);

CALLM1(db0, "addIntel", intel0);
CALLM1(db0, "addIntel", intel1);
CALLM1(db0, "addIntel", intel2);
CALLM1(db0, "addIntel", intel3);

intelLinked0 = CLONE(intel0);
SETV(intelLinked0, "source", intel1); // Source of this intel item is intel1
CALLM1(db1, "addIntel", intelLinked0);



// Query items
intelQuery = NEW("Intel", []);
SETV(intelQuery, "timeCreated", 22456);
queryResult = CALLM1(db0, "findFirstIntel", intelQuery);
queryResult