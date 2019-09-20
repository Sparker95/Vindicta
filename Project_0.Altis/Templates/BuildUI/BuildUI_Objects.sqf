#define pr private

pr _catDefense = [
	// format: Classname, Display name string, build resource
	["Land_HBarrier_01_big_4_green_F", "H-Barrier 1x4 L",			50],
	["Land_HBarrier_01_line_1_green_F", "H-Barrier Block",			50],
	["Land_HBarrier_01_line_5_green_F", "H-Barrier Long",			50],
	["Land_HBarrier_01_line_3_green_F", "H-Barrier Short",			50],
	["Land_HBarrier_01_wall_corridor_green_F", "H-Barrier Corridor", 50],
	["Land_HBarrier_01_wall_corner_green_F", "H-Barrier Corner",	50],
	["Land_HBarrier_01_wall_6_green_F", "H-Barrier Wall L",			50],
	["Land_HBarrier_01_wall_4_green_F", "H-Barrier Wall S",			50],
	["Land_HBarrier_01_big_tower_green_F", "H-Barrier Tower",		50]
];

pr _catLights = [
	// format: Classname, Display name string, build resource
	["Land_PortableLight_double_F", "Portable Floodlight",			10],
	["PortableHelipadLight_01_white_F", "White Helipad Light",		10],
	["PortableHelipadLight_01_green_F", "Green Helipad Light",		10],
	["PortableHelipadLight_01_red_F", "Red Helipad Light",			10],
	["Land_Camping_Light_F", "Camping Light",						10]
];

pr _catDeco = [
	// format: Classname, Display name string, build resource
	["Land_CampingChair_V2_F", "Camping Chair",			10],
	["Land_WoodenLog_F", "Wooden Log",					10],
	["Land_CampingTable_F", "Camping Table",			10],
	["Land_WoodenTable_large_F", "Wooden Table",		10],
	["Land_WoodPile_large_F", "Woodpile Cover",			10],
	["Land_WoodenCrate_01_F", "Wooden Crate",			10],
	["Land_WoodenCrate_01_stack_x5_F", "Wooden Crates",	10]
];

pr _catCamo = [
	// format: Classname, Display name string, build resource
	["CamoNet_OPFOR_F", 	"123",			30],
	["CamoNet_OPFOR_open_F", "123",			30],
	["CamoNet_OPFOR_big_F", "123",			30]
];

pr _catCover = [
	// format: Classname, Display name string, build resource
	["Land_Rampart_F", "Rampart",						20],
	["Land_CncShelter_F", "Concrete Shelter",			20],
	["Land_SlumWall_01_s_2m_F", "Slumwall",				20],
	["Land_SlumWall_01_s_4m_F", "Slumwall 2",			20],
	["Land_Mound01_8m_F", "Stone Wall",					20],
	["Land_TinWall_01_m_4m_v2_F", "Tin Wall",			20],
	["Land_TinWall_01_m_4m_v1_F", "Tin Wall 2"],
	["Land_SandbagBarricade_01_hole_F", "Sandbag Wall Tall",	20],
	["Land_SandbagBarricade_01_half_F", "Sandbag Wall Half",	20]
];

pr _catRange = [
	// format: Classname, Display name string, build resource
	["Land_Target_Dueling_01_F", "Dueling Target",		10],
	["Zombie_PopUp_Moving_90deg_F", "Target Zombie 1",	10],
	["Zombie_PopUp_Moving_F", "Target Zombie 2",		10],
	["TargetP_Zom_F", "Target Zombie 3",				10],
	["TargetP_Inf2_Acc2_F", "Target (Accuracy)",		10]
];

pr _catStorage = [
	["Box_FIA_Support_F",	"Supply cache",			20],
	["Box_Syndicate_Ammo_F", "Supply Box (small)",	10],
	["I_supplyCrate_F",		"Supply Box (medium)",	20],
	["B_CargoNet_01_ammo_F", "Supply Box (large)",	30]
];

pr _catMisc = [
	["Land_Sun_chair_F",	"123",	10]
];

// array of categories and category names

g_BuildUIObjects = [
	[_catStorage, "Storage"],
	[_catCamo, "Camouflage"],
	[_catDefense, "Fortification"],
	[_catLights, "Lights"],
	[_catDeco, "Decoration"],
	[_catCover, "Cover"],
	[_catRange, "Training"],
	[_catMisc, "Miscellaneous"]
];