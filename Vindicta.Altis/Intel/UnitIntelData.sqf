#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR

#define OFSTREAM_FILE "Intel.rpt"
#include "..\common.h"
#include "..\Location\Location.hpp"
#include "InventoryItems.hpp"
#include "PersonalInventory.hpp"
#include "..\defineCommon.inc"

/*
Class UnitIntelData

Data which is assigned to personal inventories.

This class is made for easy serialization and deserialization of tablet data.
*/

#define OOP_CLASS_NAME UnitIntelData
CLASS("UnitIntelData", "")

	VARIABLE_ATTR("side", [ATTR_SERIALIZABLE]);						// What side is this data?
	VARIABLE_ATTR("intelGeneral", [ATTR_SERIALIZABLE]);				// Array with refs to intel
	VARIABLE_ATTR("intelPersonal", [ATTR_SERIALIZABLE]);			// Ref to intel or NULL_OBJECT
	VARIABLE_ATTR("knownFriendlyLocations", [ATTR_SERIALIZABLE]);	// Array with refs to locations
	VARIABLE_ATTR("radioKey", [ATTR_SERIALIZABLE]);					// Radio key, string, (see AICommander and AIGarrison)

ENDCLASS;