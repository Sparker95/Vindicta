class JN {
	
	class Test {
		file = "JeroenArsenal\Test";
		class test_init {preinit = 1;};
		class test_recompile {};
		class test_debugv2 {postinit = 1;};
		class test_configCopier {};
	};
	class Common {
		file = "JeroenArsenal\Common";
		class common_addActionSelect {};
		class common_addActionCancel {};
		class common_updateActionCancel {};
		class common_removeActionCancel {};
		class common_getActionCanceled {};
	};
	class Common_Vehicle {
		file = "JeroenArsenal\Common\vehicle";
		class common_vehicle_getSeatNames {};
		class common_vehicle_getVehicleType {};
	};
	class Common_Array {
		file = "JeroenArsenal\Common\array";
		class common_array_add {};
		class common_array_remove {};
	};
	class JNA {
		file = "JeroenArsenal\JNA";
		class arsenal {};
		class arsenal_addItem {};
		class arsenal_cargoToArray {};
		class arsenal_arrayToArsenal {};
		class arsenal_cargoToArsenal {};
		class arsenal_arsenalToArsenal {};
		class arsenal_container {};
		class arsenal_init {};
		class arsenal_initPersistent {};
		class arsenal_inList {};
		class arsenal_itemCount {};
		class arsenal_itemType {};
		class arsenal_loadInventory {};
		class arsenal_removeItem {};
		class arsenal_requestOpen {};
		class arsenal_requestClose {};
		class arsenal_getEmptyArray {};
		class arsenal_getPrimaryWeapons {};
		class arsenal_getSecondaryWeapons {};
		class arsenal_getHeadgear {};
		class arsenal_getVests {};
	};
	class JNG {
		file = "JeroenArsenal\JNG";
		class garage {};
		class garage_addVehicle {};
		class garage_init {};
		class garage_releaseVehicle {};
		class garage_removeVehicle {};
		class garage_requestOpen {};
		class garage_requestClose {};
		class garage_requestVehicle {};
		class garage_getVehicleData {};
		class garage_garageVehicle {};
		class garage_canGarageVehicle {};
		class garage_updatePoints {};
	};
	
	/*
	// Sorry had to disable that, it seems to desynchronize and nullify fual amounts sometimes
	class Fuel {
		file = "JeroenArsenal\Fuel";
		class fuel_init {postinit = 1;};
		class fuel_vehicleInit {};
		class fuel_consumption_init {postInit = 1;};
		class fuel_consumption_start {};
		class fuel_consumption_stop {};
		class fuel_refuel {};
		class fuel_addActionRefuel {};
		class fuel_get {};
		class fuel_set {};
		class fuel_getCapacity {};
		class fuel_setCapacity {};
		class fuel_getCargo {};
		class fuel_setCargo {};
		class fuel_getCargoCapacity {};
		class fuel_setCargoCapacity {};
	};
	*/
	
	class Ammo {
		file = "JeroenArsenal\Ammo";
		class ammo_init {preinit = 1;};
		class ammo_getLoadout {};
		class ammo_getPylonLoadoutMissing {};
		class ammo_addActionRearm {};
		class ammo_rearm {};
		class ammo_gui {};
		class ammo_set {};
		class ammo_getCost {};
		class ammo_getCargo {};
		class ammo_setCargo {};
		class ammo_getCargoCapacity {};
		class ammo_setCargoCapacity {};
	};
	
	class Repair {
		file = "JeroenArsenal\Repair";
		class repair_addActionRepair {};
		class repair_addActionRepairPlayer {};
		class repair_addSelectRepair {};
		class repair_getWheelHitPointsWithSelections {};
		class repair_getVehicleData {};
		class repair_inventoryEvent {};
		class repair_repairHitpoint {};
		class repair_removeCargo {};
		class repair_getCargo {};
		class repair_setCargo {};
		class repair_getCargoCapacity {};
		class repair_setCargoCapacity {};
	};
	
	class JNL {
		file = "JeroenArsenal\JNL";
		class logistics_init {preinit = 1;};
		class logistics_load {};
		class logistics_unLoad {};
		class logistics_addAction {};
		class logistics_removeAction {};
	};

	class JNL_Actions {
		file = "JeroenArsenal\JNL\Actions";
		class logistics_addActionGetInWeapon {};
		class logistics_addActionLoad {};
		class logistics_addActionUnload {};
		class logistics_addEventGetOutWeapon {};
		class logistics_removeActionGetInWeapon {};
		class logistics_removeActionLoad {};
		class logistics_removeActionUnload {};
		class logistics_removeEventGetOutWeapon {};
	};

	class JNL_Functions {
		file = "JeroenArsenal\JNL\Functions";
		class logistics_canLoad {};
		class logistics_getCargo {};
		class logistics_getCargoOffsetAndDir {};
		class logistics_getCargoType {};
		class logistics_getNodes {};
		class logistics_lockSeats {};
	};
};
