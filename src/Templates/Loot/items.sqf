// Basic modern items
t_miscItems_civ_modern = ["FirstAidKit", "ItemGPS", "ItemWatch", "ItemCompass", "ItemMap", "ToolKit"];

// Basic WW2 items
t_miscItems_civ_WW2 = [];

// KAT class names (addon name: kat_main)
t_KATitems_Vehicle = [
                ["kat_chestSeal", 5]
                ];

// KAT cargo items, ACE items are added because the other array contains ACE blood so it will load this instead.
t_KATitems_Cargo = [
                ["kat_chestSeal", 80],
                ["kat_accuvac", 10],
                ["kat_guedel", 30],
                ["kat_X_AED", 10],
                ["kat_crossPanel", 30],
                ["kat_bloodIV_O", 10],
                ["kat_bloodIV_A", 30],
                ["kat_bloodIV_B", 30],
                ["kat_bloodIV_AB", 30],
                ["kat_bloodIV_O_500", 10],
                ["kat_bloodIV_A_500", 30],
                ["kat_bloodIV_B_500", 30],
                ["kat_bloodIV_AB_500", 30],
                ["kat_bloodIV_O_250", 10],
                ["kat_bloodIV_A_250", 30],
                ["kat_bloodIV_B_250", 30],
                ["kat_bloodIV_AB_250", 30],
                ["ACE_fieldDressing", 100],
                ["ACE_packingBandage", 100],
                ["ACE_elasticBandage", 100],
                ["ACE_tourniquet", 40],
                ["ACE_splint", 30],
                ["ACE_morphine", 40],
                ["ACE_adenosine", 20],
                ["ACE_epinephrine", 40],
                ["ACE_quikClot", 40],
                ["ACE_personalAidKit", 10],
                ["ACE_surgicalKit", 10]
                ];

// ACRE class names and their quantities
t_ACRERadios = [
				["ACRE_SEM52SL",2], // medium-range radio, similar to the 148 and 152
				["ACRE_SEM70",4], // Long-range radio, is NOT a backpack, but needs to be put in a backpack.
				["ACRE_PRC77",1], // Vietnam-era radio, needs to be put in a backpack.
				["ACRE_PRC343",6], // Shortest-range infantry radio. (400m-900m range, depending on terrain)
				["ACRE_PRC152",3], //medium-range radio, 3-5km
				["ACRE_PRC148",3], //medium-range radio, 3-5km
				["ACRE_PRC117F",1], //Long range radio, is NOT a backpack, but needs to be put in a backpack. 10-20km
				["ACRE_VHF30108SPIKE",1], // antenna for radio signal extension, with a spike to put it higher in the air.
				["ACRE_VHF30108",3], // Just the antenna
				["ACRE_VHF30108MAST",1] // Antenna with a mast.
			];

// TFAR class names
// Numbers are amount of items per man for loot calculations
t_TFARRadios_0912 = [
					//["tf_fadak",2], //"Belongs" to Opfor
					//["tf_pnr1000a",1], //"Belongs" to Opfor
					//["tf_anprc154",2], //"Belongs" to INDEP
					//["tf_anprc148jem",2] //"Belongs" to INDEP
					["tf_rf7800str", 0.5], //"Belongs" to BluFor
					["tf_anprc152", 1] //"Belongs" to BluFor
				];

// Numbers are amount of items per man for loot calculations
// Numbers are amount of items per man for loot calculations
t_TFARBackpacks_0912 = [
					["tf_rt1523g", 0.2], //"Belongs" to BluFor
					//["tf_rt1523g_big", 0.1], //"Belongs" to BluFor
					//["tf_rt1523g_black", 0.1], //"Belongs" to BluFor
					["tf_rt1523g_fabric", 0.2] //"Belongs" to BluFor
					//["tf_rt1523g_green", 0.1], //"Belongs" to BluFor
					//["tf_rt1523g_rhs", 0.1], //"Belongs" to BluFor
					//["tf_rt1523g_sage", 0.1], //"Belongs" to BluFor	
					//["tf_rt1523g_big_rhs", 0.1], //"Belongs" to BluFor
					//["tf_anarc210", 1] //, //"Belongs" to BluFor
					//"tf_anprc152" //"Belongs" to BluFor
					//["tf_anprc155"], //"Belongs" to INDEP
					//["tf_anprc155_coyote"], //"Belongs" to INDEP
					//["tf_anarc164"], //"Belongs" to INDEP
					//["tf_mr3000"], //"Belongs" to OPFOR
					//["tf_mr3000_multicam"], //"Belongs" to OPFOR
					//["tf_mr3000_rhs"], //"Belongs" to OPFOR
					//["tf_mr6000l"] //"Belongs" to OPFOR
				];

// TFAR new radio class names
t_TFARRadios_0100 = [
					//["TFAR_fadak",2], //"Belongs" to Opfor
					//["TFAR_pnr1000a",1], //"Belongs" to Opfor
					//["TFAR_anprc154",2], //"Belongs" to INDEP
					//["TFAR_anprc148jem",2] //"Belongs" to INDEP
					["TFAR_rf7800str",0.5], //"Belongs" to BluFor
					["TFAR_anprc152",1] //"Belongs" to BluFor
				];

// TFAR new radio backpacks
t_TFARBackpacks_0100 = [
					["TFAR_rt1523g", 0.1], //"Belongs" to BluFor
					//["TFAR_rt1523g_big", 1], //"Belongs" to BluFor
					//["TFAR_rt1523g_black", 1], //"Belongs" to BluFor
					["TFAR_rt1523g_fabric", 0.1] //"Belongs" to BluFor
					//["TFAR_rt1523g_green", 1], //"Belongs" to BluFor
					//["TFAR_rt1523g_rhs", 1], //"Belongs" to BluFor
					//["TFAR_rt1523g_sage", 1], //"Belongs" to BluFor	
					//["TFAR_rt1523g_big_rhs", 1] //"Belongs" to BluFor
					//["TFAR_anarc210" //"Belongs" to BluFor
					//"TFAR_anprc152" //"Belongs" to BluFor
					//["TFAR_anprc155"], //"Belongs" to INDEP
					//["TFAR_anprc155_coyote"], //"Belongs" to INDEP
					//["TFAR_anarc164"], //"Belongs" to INDEP
					//["TFAR_mr3000"], //"Belongs" to OPFOR
					//["TFAR_mr3000_multicam"], //"Belongs" to OPFOR
					//["TFAR_mr3000_rhs"], //"Belongs" to OPFOR
					//["TFAR_mr6000l"] //"Belongs" to OPFOR
				];

// ACE misc items
// Numbers are amount of items per man for loot calculations
t_ACEMiscItems = [
					//["ACE_muzzle_mzls_H",2],
					//["ACE_muzzle_mzls_B",2],
					//["ACE_muzzle_mzls_L",2],
					//["ACE_muzzle_mzls_smg_01",2],
					//["ACE_muzzle_mzls_smg_02",2],
					//["ACE_muzzle_mzls_338",5],
					//["ACE_muzzle_mzls_93mmg",5],
					//["ACE_HuntIR_monitor",5],
					//["ACE_acc_pointer_green",4],
					["ACE_UAVBattery",0.1],
					["ACE_wirecutter",0.1],
					["ACE_MapTools",1],
					["ACE_microDAGR",0.1],
					//["ACE_MX2A",6], // Thermal imager
					//["ACE_NVG_Gen1",6],
					//["ACE_NVG_Gen2",6],
					//["ACE_NVG_Gen4",6],
					//["ACE_NVG_Wide",6],
					//["ACE_optic_Hamr_2D",2],
					//["ACE_optic_Hamr_PIP",2],
					//["ACE_optic_Arco_2D",2],
					//["ACE_optic_Arco_PIP",2],
					//["ACE_optic_MRCO_2D",2],
					//["ACE_optic_SOS_2D",2],
					//["ACE_optic_SOS_PIP",2],
					//["ACE_optic_LRPS_2D",2],
					//["ACE_optic_LRPS_PIP",2],
					["ACE_Altimeter",0.1],
					["ACE_Sandbag_empty",1],
					["ACE_SpottingScope",0.1],
					//["ACE_SpraypaintBlack",5],
					//["ACE_SpraypaintRed",5],
					//["ACE_SpraypaintBlue",5],
					//["ACE_SpraypaintGreen",5],
					["ACE_EntrenchingTool",1],
					["ACE_Tripod",0.1],
					["ACE_Vector",0.3],
					//["ACE_Yardage450",4],
					//["ACE_IR_Strobe_Item",12],
					//["ACE_CableTie",12],
					//["ACE_Chemlight_Shield",12],
					["ACE_DAGR",0.3],
					["ACE_Clacker",0.2],
					["ACE_M26_Clacker",0.2],
					["ACE_DefusalKit",0.3],
					//["ACE_Deadmanswitch",6],
					//["ACE_Cellphone",10],
					//["ACE_Flashlight_MX991",12],
					//["ACE_Flashlight_KSF1",12],
					//["ACE_Flashlight_XL50",12],
					["ACE_EarPlugs",1],
					["ACE_Kestrel4500",0.2],
					["ACE_ATragMX",0.2],
					["ACE_RangeCard",0.3],
					["ACE_HandFlare_White", 3], // Flares
					["ACE_key_lockpick", 3],	// Lockpick
					["ACE_Banana", 2]
				];

// ACE medical items for vehicles
t_ACEMedicalItems_vehicles = [
                ["ACE_fieldDressing", 20],
                ["ACE_packingBandage", 20],
                ["ACE_elasticBandage", 20],
                ["ACE_tourniquet", 5],
                ["ACE_splint", 5],
                ["ACE_morphine", 4],
                ["ACE_adenosine", 4],
                ["ACE_epinephrine", 4],
                //["ACE_plasmaIV", 1],
                //["ACE_plasmaIV_500", 10],
                //["ACE_plasmaIV_250", 20],
                //["ACE_salineIV", 1],
                //["ACE_salineIV_500", 10],
                //["ACE_salineIV_250", 20],
                ["ACE_bloodIV", 1],
                ["ACE_bloodIV_500", 0.5],
                //["ACE_bloodIV_250",  20],
                ["ACE_quikClot", 20],
                ["ACE_personalAidKit", 1],
                ["ACE_surgicalKit", 1]
                //["ACE_bodyBag", 0]
                ];

// ACE medical items for cargo boxes
// Numbers are amount of items per man for loot calculations
t_ACEMedicalItems_cargo = [
                ["ACE_fieldDressing", 10],
                ["ACE_packingBandage", 10],
                ["ACE_elasticBandage", 10],
                ["ACE_tourniquet", 5],
                ["ACE_splint", 5],
                ["ACE_morphine", 2],
                ["ACE_adenosine", 2],
                ["ACE_epinephrine", 2],
                //["ACE_plasmaIV", 1],
                //["ACE_plasmaIV_500", 10],
                //["ACE_plasmaIV_250", 20],
                //["ACE_salineIV", 1],
                //["ACE_salineIV_500", 10],
                //["ACE_salineIV_250", 20],
                ["ACE_bloodIV", 1],
                ["ACE_bloodIV_500", 0.5],
                //["ACE_bloodIV_250",  20],
                ["ACE_quikClot", 20],
                ["ACE_personalAidKit", 1],
                ["ACE_surgicalKit", 1]
                //["ACE_bodyBag", 0]
                ];