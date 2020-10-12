// Basic modern items
t_miscItems_civ_modern = ["FirstAidKit", "ItemGPS", "ItemWatch", "ItemCompass", "ItemMap", "ToolKit"];

// Basic WW2 items
t_miscItems_civ_WW2 = [];


// KAT class names (addon name: kat_main)
// Numbers are amount of items per man for loot calculations
t_KATitems_Cargo = [
                ["kat_chestSeal", 0.5],
                ["kat_accuvac", 0.5],
                ["kat_guedel", 0.5],
                ["kat_X_AED", 0.5],
                ["kat_crossPanel", 0.5],
                ["kat_bloodIV_O", 0.2],
                ["kat_bloodIV_A", 0.2],
                ["kat_bloodIV_B", 0.2],
                ["kat_bloodIV_AB", 0.2],
                ["kat_bloodIV_O_500", 0.2],
                ["kat_bloodIV_A_500", 0.2],
                ["kat_bloodIV_B_500", 0.2],
                ["kat_bloodIV_AB_500", 0.2],
                ["kat_bloodIV_O_250", 0.2],
                ["kat_bloodIV_A_250", 0.2],
                ["kat_bloodIV_B_250", 0.2],
                ["kat_bloodIV_AB_250", 0.2]
				/*
                ["ACE_fieldDressing", 10],
                ["ACE_packingBandage", 10],
                ["ACE_elasticBandage", 10],
                ["ACE_tourniquet", 4],
                ["ACE_splint", 4],
                ["ACE_morphine", 2],
                ["ACE_adenosine", 2],
                ["ACE_epinephrine", 2],
                ["ACE_quikClot", 10],
                ["ACE_personalAidKit", 1],
                ["ACE_surgicalKit", 1]
				*/
                ];

// ACRE: "acre_main"
// ACRE class names and their quantities
// Numbers are amount of items per man for loot calculations
t_ACRERadios = [
				["ACRE_SEM52SL",0.3], // medium-range radio, similar to the 148 and 152
				["ACRE_SEM70",0.3], // Long-range radio, is NOT a backpack, but needs to be put in a backpack.
				["ACRE_PRC77",0.3], // Vietnam-era radio, needs to be put in a backpack.
				["ACRE_PRC343",0.3], // Shortest-range infantry radio. (400m-900m range, depending on terrain)
				["ACRE_PRC152",0.3], //medium-range radio, 3-5km
				["ACRE_PRC148",0.3], //medium-range radio, 3-5km
				["ACRE_PRC117F",0.3], //Long range radio, is NOT a backpack, but needs to be put in a backpack. 10-20km
				["ACRE_VHF30108SPIKE",0.3], // antenna for radio signal extension, with a spike to put it higher in the air.
				["ACRE_VHF30108",0.3], // Just the antenna
				["ACRE_VHF30108MAST",0.3] // Antenna with a mast.
			];

// TFAR 0.9.12: "task_force_radio"
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

// TFAR 1.0: "tfar_core"
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