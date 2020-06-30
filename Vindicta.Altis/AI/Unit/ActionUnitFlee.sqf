#include "common.hpp"

#define pr private

/*
This action orders the unit to run to a given destination in panic.
Standard AIUnitHuman movement methods are not used here, movement is handled differently here.
*/

#define OOP_CLASS_NAME ActionUnitFlee
CLASS("ActionUnitFlee", "ActionUnit")

	VARIABLE("pos");

	public override METHOD(getPossibleParameters)
		[
			[ ],	// Required parameters
			[ [TAG_MOVE_TARGET, [[]]], [TAG_MOVE_RADIUS, [0]] ]	// Optional parameters
		]
	ENDMETHOD;

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_ai"), P_ARRAY("_parameters")];

		pr _pos = CALLSM3("Action", "getParameterValue", _parameters, TAG_MOVE_TARGET, [0 ARG 0 ARG 0]);
		T_SETV("pos", _pos);
	ENDMETHOD;


	protected override METHOD(activate)
		params [P_THISOBJECT];
		
		private _hO = T_GETV("hO");
		/*
		private _panicAnimsErectAndKneeled = [
			"ApanPercMstpSnonWnonDnon_G01", "ApanPercMstpSnonWnonDnon_G02", "ApanPercMstpSnonWnonDnon_G03",
			"ApanPknlMstpSnonWnonDnon_G01", "ApanPknlMstpSnonWnonDnon_G02", "ApanPknlMstpSnonWnonDnon_G03"
		];
		*/

		// Keeping this for a civi variant maybe ?
		// private _animationsProned = ["ApanPpneMstpSnonWnonDnon_G01", "ApanPpneMstpSnonWnonDnon_G02", "ApanPpneMstpSnonWnonDnon_G03"];

		//doStop _hO;
		//_hO spawn misc_fnc_actionDropAllWeapons; // this can sleep so we should spawn it

		pr _ai = T_GETV("AI");
		CALLM0(_ai, "stopMoveToTarget"); // Stop standard movement, we handle it ourselves in this action

		_hO forceWalk false;
		_hO setUnitPosWeak "UP";
		_hO setUnitPos "UP";
		if (random 10 > 4) then {
			_hO switchAction "Panic";
			_hO forceSpeed (selectRandom [5, -1]); // 5 - runs slowly, -1 - runs very very fast
		} else {
			_hO switchAction "";
			_hO forceSpeed -1;
		};

		_hO setBehaviour "CARELESS";

		//_hO switchMove selectRandom _panicAnimsErectAndKneeled;

		private _posMove = T_GETV("pos");
		if (_posMove isEqualTo [0,0,0]) then {
			private _pos = getPos _hO;
			_posMove = [(_pos#0) - 100 + random 200, (_pos#1) - 100 + random 200, _pos select 2];
			T_SETV("pos", _posMove);
		};

		if (GET_AGENT_FLAG(_hO)) then {
			_hO setDestination [_posMove,"LEADER PLANNED",true];
		} else {
			_hO doMove _posMove;
		};

		T_SETV("state", ACTION_STATE_ACTIVE);
		ACTION_STATE_ACTIVE
	ENDMETHOD;

	public override METHOD(process)
		params [P_THISOBJECT];
		T_CALLM0("activateIfInactive");
		//ACTION_STATE_COMPLETED

		pr _hO = T_GETV("hO");
		if (_hO distance T_GETV("pos") < 2) then {
			_hO setUnitPosWeak "Middle";
			_hO setUnitPos "Middle";
		};

		// Always active
		ACTION_STATE_ACTIVE
	ENDMETHOD;

	public override METHOD(terminate)
		params [P_THISOBJECT];
		pr _hO = T_GETV("hO");
		doStop _hO;
	ENDMETHOD;
ENDCLASS;

// List of moves
// https://community.bistudio.com/wiki/Arma_3_Moves

// We can use that to make civies run into houses
// for other methods, internet says it can be buggy 
// switch(worldName) do {
// 	case "Stratis":{//IF map is Stratis = Altis/Stratis Houses
// 		nH_List=["Land_CarService_F","Land_Chapel_Small_V1_F","Land_Chapel_Small_V2_F","Land_Chapel_V1_F","Land_Chapel_V2_F","Land_d_Stone_Shed_V1_F","Land_FuelStation_Build_F","Land_FuelStation_Shed_F","Land_Hospital_main_F","Land_Hospital_side1_F","Land_Hospital_side2_F","Land_i_Addon_02_V1_F","Land_i_Addon_03mid_V1_F","Land_i_Addon_03_V1_F","Land_i_Addon_04_V1_F","Land_i_Barracks_V1_F","Land_i_Barracks_V2_F","Land_i_Garage_V1_F","Land_i_Garage_V2_F","Land_i_House_Big_01_V1_F","Land_i_House_Big_01_V2_F","Land_i_House_Big_01_V3_F","Land_i_House_Big_02_V1_F","Land_i_House_Big_02_V2_F","Land_i_House_Big_02_V3_F","Land_i_House_Small_01_V1_F","Land_i_House_Small_01_V2_F","Land_i_House_Small_01_V3_F","Land_i_House_Small_02_V1_F","Land_i_House_Small_02_V2_F","Land_i_House_Small_02_V3_F","Land_i_House_Small_03_V1_F","Land_i_Shed_Ind_F","Land_i_Shop_01_V1_F","Land_i_Shop_01_V2_F","Land_i_Shop_01_V3_F","Land_i_Shop_02_V1_F","Land_i_Shop_02_V2_F","Land_i_Shop_02_V3_F","Land_i_Stone_HouseBig_V1_F","Land_i_Stone_HouseBig_V2_F","Land_i_Stone_HouseBig_V3_F","Land_i_Stone_HouseSmall_V1_F","Land_i_Stone_HouseSmall_V2_F","Land_i_Stone_HouseSmall_V3_F","Land_i_Stone_Shed_V1_F","Land_i_Stone_Shed_V2_F","Land_i_Stone_Shed_V3_F","Land_Metal_Shed_F","Land_MilOffices_V1_F","Land_Offices_01_V1_F","Land_Slum_House01_F","Land_Slum_House02_F","Land_Slum_House03_F","Land_Unfinished_Building_01_F","Land_Unfinished_Building_02_F","Land_u_Addon_01_V1_F","Land_u_Addon_02_V1_F","Land_u_Barracks_V2_F","Land_u_House_Big_01_V1_F","Land_u_House_Big_02_V1_F","Land_u_House_Small_01_V1_F","Land_u_House_Small_02_V1_F","Land_u_Shed_Ind_F","Land_u_Shop_01_V1_F","Land_u_Shop_02_V1_F","Land_WIP_F"];
// 	};

// 	case "Altis":{//IF MAP IS ALTIS = Altis/Stratis Houses
// 		nH_List=["Land_CarService_F","Land_Chapel_Small_V1_F","Land_Chapel_Small_V2_F","Land_Chapel_V1_F","Land_Chapel_V2_F","Land_d_Stone_Shed_V1_F","Land_FuelStation_Build_F","Land_FuelStation_Shed_F","Land_Hospital_main_F","Land_Hospital_side1_F","Land_Hospital_side2_F","Land_i_Addon_02_V1_F","Land_i_Addon_03mid_V1_F","Land_i_Addon_03_V1_F","Land_i_Addon_04_V1_F","Land_i_Barracks_V1_F","Land_i_Barracks_V2_F","Land_i_Garage_V1_F","Land_i_Garage_V2_F","Land_i_House_Big_01_V1_F","Land_i_House_Big_01_V2_F","Land_i_House_Big_01_V3_F","Land_i_House_Big_02_V1_F","Land_i_House_Big_02_V2_F","Land_i_House_Big_02_V3_F","Land_i_House_Small_01_V1_F","Land_i_House_Small_01_V2_F","Land_i_House_Small_01_V3_F","Land_i_House_Small_02_V1_F","Land_i_House_Small_02_V2_F","Land_i_House_Small_02_V3_F","Land_i_House_Small_03_V1_F","Land_i_Shed_Ind_F","Land_i_Shop_01_V1_F","Land_i_Shop_01_V2_F","Land_i_Shop_01_V3_F","Land_i_Shop_02_V1_F","Land_i_Shop_02_V2_F","Land_i_Shop_02_V3_F","Land_i_Stone_HouseBig_V1_F","Land_i_Stone_HouseBig_V2_F","Land_i_Stone_HouseBig_V3_F","Land_i_Stone_HouseSmall_V1_F","Land_i_Stone_HouseSmall_V2_F","Land_i_Stone_HouseSmall_V3_F","Land_i_Stone_Shed_V1_F","Land_i_Stone_Shed_V2_F","Land_i_Stone_Shed_V3_F","Land_Metal_Shed_F","Land_MilOffices_V1_F","Land_Offices_01_V1_F","Land_Slum_House01_F","Land_Slum_House02_F","Land_Slum_House03_F","Land_Unfinished_Building_01_F","Land_Unfinished_Building_02_F","Land_u_Addon_01_V1_F","Land_u_Addon_02_V1_F","Land_u_Barracks_V2_F","Land_u_House_Big_01_V1_F","Land_u_House_Big_02_V1_F","Land_u_House_Small_01_V1_F","Land_u_House_Small_02_V1_F","Land_u_Shed_Ind_F","Land_u_Shop_01_V1_F","Land_u_Shop_02_V1_F","Land_WIP_F"];
// 	};

// 	case "Tanoa":{//IF MAP IS TANOA = Tanoa Houses
// 		nH_List=["Land_Airport_02_terminal_F","Land_House_Big_04_F","Land_House_Small_04_F","Land_House_Small_05_F","Land_Shop_City_01_F","Land_Shop_City_02_F","Land_Addon_04_F","Land_Shop_City_05_F","Land_School_01_F","Land_House_Big_03_F","Land_House_Native_01_F","Land_House_Native_02_F","Land_Temple_Native_01_F","Land_SM_01_shed_F","Land_Warehouse_03_F","Land_Barracks_01_dilapidated_F","Land_Barracks_01_grey_F","Land_Barracks_01_camo_F","Land_Cathedral_01_F","Land_GuardHouse_01_F","Land_FuelStation_01_shop_F","Land_FuelStation_01_workshop_F","Land_FuelStation_02_workshop_F","Land_Hotel_01_F","Land_Hotel_02_F","Land_Supermarket_01_F","Land_House_Small_02_F","Land_House_Big_02_F","Land_House_Small_03_F","Land_House_Small_06_F","Land_House_Big_01_F","Land_Shed_07_F","Land_Shed_05_F","Land_Shed_02_F","Land_Slum_05_F","Land_Slum_02_F","Land_Slum_01_F","Land_GarageShelter_01_F","Land_Shop_Town_03_F","Land_Shop_Town_05_F","Land_Shop_Town_01_F","Land_House_Small_01_F","Land_Slum_03_F","Land_Slum_04_F","Land_Shed_01_F","Land_Shed_04_F"];
// 	};

// 	case "Takistan":{//IF MAP IS TAKISTAN = Middle Eastern Houses
// 		nH_List=["Land_House_K_1_EP1","Land_House_K_3_EP1","Land_House_K_5_EP1","Land_House_K_6_EP1","Land_House_K_7_EP1","Land_House_K_8_EP1","Land_House_L_1_EP1","Land_House_L_2_EP1","Land_House_L_3_EP1","Land_House_L_4_EP1","Land_House_L_6_EP1","Land_House_L_7_EP1","Land_House_L_8_EP1","Land_House_L_9_EP1","Land_House_C_1_EP1","Land_House_C_1_v2_EP1","Land_House_C_2_EP1","Land_House_C_3_EP1","Land_House_C_4_EP1","Land_House_C_5_EP1","Land_House_C_5_V1_EP1","Land_House_C_5_V2_EP1","Land_House_C_5_V3_EP1","Land_House_C_10_EP1","Land_House_C_11_EP1","Land_House_C_12_EP1","Land_A_Mosque_small_1_EP1","Land_A_Mosque_small_2_EP1","Land_A_Mosque_big_addon_EP1","Land_A_Mosque_big_hq_EP1"];
// 	};

// 	case "Zargabad":{//IF MAP IS ZARGABAD = Middle Eastern Houses
// 		nH_List=["Land_House_K_1_EP1","Land_House_K_3_EP1","Land_House_K_5_EP1","Land_House_K_6_EP1","Land_House_K_7_EP1","Land_House_K_8_EP1","Land_House_L_1_EP1","Land_House_L_2_EP1","Land_House_L_3_EP1","Land_House_L_4_EP1","Land_House_L_6_EP1","Land_House_L_7_EP1","Land_House_L_8_EP1","Land_House_L_9_EP1","Land_House_C_1_EP1","Land_House_C_1_v2_EP1","Land_House_C_2_EP1","Land_House_C_3_EP1","Land_House_C_4_EP1","Land_House_C_5_EP1","Land_House_C_5_V1_EP1","Land_House_C_5_V2_EP1","Land_House_C_5_V3_EP1","Land_House_C_10_EP1","Land_House_C_11_EP1","Land_House_C_12_EP1","Land_A_Mosque_small_1_EP1","Land_A_Mosque_small_2_EP1","Land_A_Mosque_big_addon_EP1","Land_A_Mosque_big_hq_EP1"];
// 	};

// 	case "Chernarus":{//IF MAP IS CHERNARUS = Chernarus buildings
// 		nH_List=["Land_A_BuildingWIP","Land_A_FuelStation_Build","Land_A_GeneralStore_01","Land_A_GeneralStore_01a","Land_A_Hospital","Land_A_Pub_01","Land_a_stationhouse","Land_Barn_Metal","Land_Barn_W_01","Land_Church_03","Land_Farm_Cowshed_a","Land_Farm_Cowshed_b","Land_Farm_Cowshed_c","Land_Hlidac_budka","Land_HouseBlock_A1","Land_HouseB_Tenement","Land_HouseV2_01A","Land_HouseV2_02_Interier","Land_HouseV2_04_interier","Land_HouseV_1I1","Land_HouseV_1I4","Land_HouseV_1L1","Land_HouseV_1L2","Land_HouseV_2L","Land_Ind_Garage01","Land_Ind_Workshop01_01","Land_Ind_Workshop01_02","Land_Ind_Workshop01_04","Land_Ind_Workshop01_L","Land_kulna","Land_Mil_Barracks_i","Land_Mil_ControlTower","Land_Panelak","Land_Panelak2","Land_Rail_House_01","Land_rail_station_big","Land_Shed_Ind02","Land_Shed_W01","Land_stodola_old_open","Land_Tovarna2","Land_vez"];
// 	};

// 	default{//If any of the above maps aren't detected, default select A2 Takistan houses
// 		nH_List=["Land_House_K_1_EP1","Land_House_K_3_EP1","Land_House_K_5_EP1","Land_House_K_6_EP1","Land_House_K_7_EP1","Land_House_K_8_EP1","Land_House_L_1_EP1","Land_House_L_2_EP1","Land_House_L_3_EP1","Land_House_L_4_EP1","Land_House_L_6_EP1","Land_House_L_7_EP1","Land_House_L_8_EP1","Land_House_L_9_EP1","Land_House_C_1_EP1","Land_House_C_1_v2_EP1","Land_House_C_2_EP1","Land_House_C_3_EP1","Land_House_C_4_EP1","Land_House_C_5_EP1","Land_House_C_5_V1_EP1","Land_House_C_5_V2_EP1","Land_House_C_5_V3_EP1","Land_House_C_10_EP1","Land_House_C_11_EP1","Land_House_C_12_EP1","Land_A_Mosque_small_1_EP1","Land_A_Mosque_small_2_EP1","Land_A_Mosque_big_addon_EP1","Land_A_Mosque_big_hq_EP1"];
// 	};
// };
