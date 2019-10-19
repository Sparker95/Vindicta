#define OOP_INFO
#define OOP_WARNING
#define OOP_ERROR

#define OFSTREAM_FILE "Intel.rpt"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Location\Location.hpp"
#include "InventoryItems.hpp"
#include "PersonalInventory.hpp"
#include "..\GlobalAssert.hpp"

/*
Class UnitIntelData

Data which is assigned to personal inventories.

This class is made for easy serialization and deserialization of tablet data.
*/

CLASS("UnitIntelData", "")

	VARIABLE_ATTR("intelGeneral", [ATTR_SERIALIZABLE]);			// Array with refs to intel
	VARIABLE_ATTR("intelPersonal", [ATTR_SERIALIZABLE]);			// Ref to intel or NULL_OBJECT
	VARIABLE_ATTR("knownFriendlyLocations", [ATTR_SERIALIZABLE]);	// Array with refs to locations

ENDCLASS;