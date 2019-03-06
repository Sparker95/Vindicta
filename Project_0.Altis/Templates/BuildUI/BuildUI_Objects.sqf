#define pr private

pr _catDefense = [
	// format: Classname, Display name string
	["Land_HBarrier_01_big_4_green_F", "H-Barrier 1x4 L"],
	["Land_HBarrier_01_line_1_green_F", "H-Barrier Block"],
	["Land_HBarrier_01_line_5_green_F", "H-Barrier Long"],
	["Land_HBarrier_01_line_3_green_F", "H-Barrier Short"],
	["Land_HBarrier_01_wall_corridor_green_F", "H-Barrier Corridor"],
	["Land_HBarrier_01_wall_corner_green_F", "H-Barrier Corner"],
	["Land_HBarrier_01_wall_6_green_F", "H-Barrier Wall L"],
	["Land_HBarrier_01_wall_4_green_F", "H-Barrier Wall S"],
	["Land_HBarrier_01_big_tower_green_F", "H-Barrier Tower"]
];

pr _catLights = [
	// format: Classname, Display name string
	["Land_PortableLight_double_F", "Portable Floodlight"],
	["PortableHelipadLight_01_white_F", "White Helipad Light"],
	["PortableHelipadLight_01_green_F", "Green Helipad Light"],
	["PortableHelipadLight_01_red_F", "Red Helipad Light"],
	["Land_Camping_Light_F", "Camping Light"]
];

pr _catDeco = [
	// format: Classname, Display name string
	["Land_CampingChair_V2_F", "Camping Chair"],
	["Land_CampingTable_F", "Camping Table"],
	["Land_WoodenTable_large_F", "Wooden Table"],
	["Land_WoodPile_large_F", "Woodpile Cover"],
	["Land_WoodenCrate_01_F", "Wooden Crate"],
	["Land_WoodenCrate_01_stack_x5_F", "Wooden Crates"]
];

pr _catCamo = [
	// format: Classname, Display name string
	["CamoNet_BLUFOR_open_F", "Camonet Open"],
	["CamoNet_BLUFOR_big_F", "Camonet"]
];

pr _catCover = [
	// format: Classname, Display name string
	["Land_Rampart_F", "Rampart"],
	["Land_SlumWall_01_s_2m_F", "Slumwall"],
	["Land_SlumWall_01_s_4m_F", "Slumwall 2"],
	["Land_Mound01_8m_F", "Stone Wall"],
	["Land_TinWall_01_m_4m_v2_F", "Tin Wall"],
	["Land_TinWall_01_m_4m_v1_F", "Tin Wall 2"]
];

pr _catRange = [
	// format: Classname, Display name string
	["Land_Target_Dueling_01_F", "Dueling Target"],
	["Zombie_PopUp_Moving_90deg_F", "Target Zombie 1"],
	["Zombie_PopUp_Moving_F", "Target Zombie 2"],
	["TargetP_Zom_F", "Target Zombie 3"]
];


// array of categories and category names
g_BuildUIObjects = [

[_catLights, "Lights"], 			
[_catDefense, "Fortification"],
[_catCamo, "Camouflage"],
[_catDeco, "Decoration"],
[_catCover, "Cover"],
[_catRange, "Training"]

];



