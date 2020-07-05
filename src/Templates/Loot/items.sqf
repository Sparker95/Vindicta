// Basic modern items
t_miscItems_civ_modern = ["FirstAidKit", "ItemGPS", "ItemWatch", "ItemCompass", "ItemMap", "ToolKit"];

// Basic WW2 items
t_miscItems_civ_WW2 = [];

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
t_TFARRadios_0912 = [
					//["tf_fadak",2], //"Belongs" to Opfor
					//["tf_pnr1000a",1], //"Belongs" to Opfor
					//["tf_anprc154",2], //"Belongs" to INDEP
					//["tf_anprc148jem",2] //"Belongs" to INDEP
					["tf_rf7800str",4], //"Belongs" to BluFor
					["tf_anprc152",2] //"Belongs" to BluFor
				];

t_TFARBackpacks_0912 = [
					"tf_rt1523g", //"Belongs" to BluFor
					"tf_rt1523g_big", //"Belongs" to BluFor
					"tf_rt1523g_black", //"Belongs" to BluFor
					"tf_rt1523g_fabric", //"Belongs" to BluFor
					"tf_rt1523g_green", //"Belongs" to BluFor
					"tf_rt1523g_rhs", //"Belongs" to BluFor
					"tf_rt1523g_sage", //"Belongs" to BluFor	
					"tf_rt1523g_big_rhs", //"Belongs" to BluFor
					"tf_anarc210" //, //"Belongs" to BluFor
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
					["TFAR_rf7800str",4], //"Belongs" to BluFor
					["TFAR_anprc152",2] //"Belongs" to BluFor
				];

// TFAR new radio backpacks
t_TFARBackpacks_0100 = [
					"TFAR_rt1523g", //"Belongs" to BluFor
					"TFAR_rt1523g_big", //"Belongs" to BluFor
					"TFAR_rt1523g_black", //"Belongs" to BluFor
					"TFAR_rt1523g_fabric", //"Belongs" to BluFor
					"TFAR_rt1523g_green", //"Belongs" to BluFor
					"TFAR_rt1523g_rhs", //"Belongs" to BluFor
					"TFAR_rt1523g_sage", //"Belongs" to BluFor	
					"TFAR_rt1523g_big_rhs", //"Belongs" to BluFor
					"TFAR_anarc210" //"Belongs" to BluFor
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
					["ACE_UAVBattery",6],
					["ACE_wirecutter",4],
					["ACE_MapTools",12],
					["ACE_microDAGR",3],
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
					["ACE_Altimeter",3],
					["ACE_Sandbag_empty",10],
					["ACE_SpottingScope",1],
					//["ACE_SpraypaintBlack",5],
					//["ACE_SpraypaintRed",5],
					//["ACE_SpraypaintBlue",5],
					//["ACE_SpraypaintGreen",5],
					["ACE_EntrenchingTool",8],
					["ACE_Tripod",1],
					["ACE_Vector",2],
					//["ACE_Yardage450",4],
					//["ACE_IR_Strobe_Item",12],
					["ACE_CableTie",12],
					//["ACE_Chemlight_Shield",12],
					["ACE_DAGR",3],
					["ACE_Clacker",12],
					["ACE_M26_Clacker",6],
					["ACE_DefusalKit",4],
					//["ACE_Deadmanswitch",6],
					//["ACE_Cellphone",10],
					//["ACE_Flashlight_MX991",12],
					//["ACE_Flashlight_KSF1",12],
					//["ACE_Flashlight_XL50",12],
					["ACE_EarPlugs",20],
					["ACE_Kestrel4500",2],
					["ACE_ATragMX",6],
					["ACE_RangeCard",6],
					["ACE_HandFlare_White", 30], // Flares
					["ACE_key_lockpick", 20],	// Lockpick
					["ACE_Banana", 2]
				];

// ACE medical items for vehicles
t_ACEMedicalItems_vehicles = [
                ["ACE_fieldDressing", 10],
                ["ACE_packingBandage", 10],
                ["ACE_elasticBandage", 10],
                ["ACE_tourniquet", 5],
                ["ACE_splint", 2],
                ["ACE_morphine", 4],
                ["ACE_adenosine", 3],
                ["ACE_epinephrine", 3],
                //["ACE_plasmaIV", 1],
                //["ACE_plasmaIV_500", 1],
                //["ACE_plasmaIV_250", 0],
                //["ACE_salineIV", 1],
                //["ACE_salineIV_500", 1],
                //["ACE_salineIV_250", 10],
                //["ACE_bloodIV", 10],
                //["ACE_bloodIV_500", 8],
                //["ACE_bloodIV_250", 10],
                ["ACE_quikClot", 5]
                //["ACE_personalAidKit", 3],
                //["ACE_surgicalKit", 1] //,
                //["ACE_bodyBag", 0]
                ];

// ACE medical items for cargo boxes
t_ACEMedicalItems_cargo = [
                ["ACE_fieldDressing", 100],
                ["ACE_packingBandage", 100],
                ["ACE_elasticBandage", 100],
                ["ACE_tourniquet", 40],
                ["ACE_splint", 30],
                ["ACE_morphine", 40],
                ["ACE_adenosine", 20],
                ["ACE_epinephrine", 40],
                //["ACE_plasmaIV", 1],
                //["ACE_plasmaIV_500", 10],
                //["ACE_plasmaIV_250", 20],
                //["ACE_salineIV", 1],
                //["ACE_salineIV_500", 10],
               // ["ACE_salineIV_250", 20],
                ["ACE_bloodIV", 40],
                ["ACE_bloodIV_500", 40],
                ["ACE_bloodIV_250",  20],
                ["ACE_quikClot", 40],
                ["ACE_personalAidKit", 10],
                ["ACE_surgicalKit", 10]
                //["ACE_bodyBag", 0]
                ];