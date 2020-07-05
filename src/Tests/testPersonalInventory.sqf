#include "..\common.h"
CALL_COMPILE_COMMON("Intel\PersonalInventory.sqf");

#define pr private

gPI = NEW("PersonalInventory", []);

// Should produce an error and return nil 
pr _temp = CALLM2(gPI, "getInventoryData", "abc", 1);
diag_log format ["abc_1: %1", _temp];

// Should return nil
pr _temp = CALLM2(gPI, "getInventoryData", "vin_tablet_0", 1);
diag_log format ["vin_tablet_0_1: %1", _temp];

// Should return three IDs
pr _IDs = CALLM2(gPI, "getInventoryClassIDs", "vin_tablet_0", 3);
diag_log format ["vin_tablet_0 returned IDs: %1", _IDs];

// Set data
{
	CALLM3(gPI, "setInventoryData", "vin_tablet_0", _x, (_x+1)*(_x+2));
} forEach _IDs;

// Get counter value
pr _counter = CALLM1(gPI, "getInventoryClassCounter", "vin_tablet_0");
diag_log format ["Counter of vin_tablet_0: %1", _counter];

// Now get this data and erase it
{
	pr _data = CALLM2(gPI, "getInventoryData", "vin_tablet_0", _x);
	diag_log format ["Data of vin_tablet_0_%1 : %2", _x, _data];
	CALLM3(gPI, "setInventoryData", "vin_tablet_0", _x, nil);
} forEach _IDs;

// Get counter value
pr _counter = CALLM1(gPI, "getInventoryClassCounter", "vin_tablet_0");
diag_log format ["Counter of vin_tablet_0: %1", _counter];


// Retake these IDs
pr _IDs = CALLM2(gPI, "getInventoryClassIDs", "vin_tablet_0", 3);
diag_log format ["vin_tablet_0 returned IDs: %1", _IDs];