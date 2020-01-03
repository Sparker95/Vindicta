class TutorialPages
{
	// base class, default page
	class TutBasePage 
	{
		textHeadline = "VINDICTA Gameplay Tutorial";
		text = "Welcome to the VINDICTA tutorial. This tutorial will help you enjoy this mission.";
		imagePath = "UI\Images\tut_image_default.paa";
	};

	class TutPage0_0 : TutBasePage
	{
		textHeadline = "Introduction";
		text = "If you are reading this, congratulations! You have navigated to the mission's in-game menu and you have opened the Tutorial. There are no other keyboard keys you need to know about to play this mission. VINDICTA is a sandbox scenario where your main goal is to liberate the island from enemy occupation. For now the end goal is to control all the airfields. The following topics contain important information about the mission, its features, and its limitations.";
		imagePath = "UI\Images\tut_scenario.paa";

	};

	class TutPage0 : TutBasePage
	{
		textHeadline = "Respawn";
		text = "You can respawn at all friendly locations controlled by your faction, if they have an infantry capacity above zero. Camps, which can be created with build resources, also enable respawn in nearby cities in case you run out of vehicles.";
		imagePath = "UI\Images\tut_image_default.paa";

	};


	class TutPage1 : TutBasePage
	{
		textHeadline = "Staying Undercover";
		text = "When you are starting out, you should use the undercover system to your advantage, until you have found better weapons, equipment and vehicles. Watch the meter at the top of your screen: If it's full and red then you are overt, and enemy forces will shoot on sight. The text below the meter informs you about reasons why the meter is filling up.";
		imagePath = "UI\Images\tut_undercover.paa";

	};

	class TutPage2 : TutBasePage
	{
		textHeadline = "Intel: Locations";
		text = "Your first objective should be to find a police station. You can talk to civilians to gain intel about the location of nearby police stations and military outposts and bases. Loot enemies to find tactical tablets. Double click them to in your inventory to gain intel.";
		imagePath = "UI\Images\tut_policeStations.paa";

	};

	class TutPage3 : TutBasePage
	{
		textHeadline = "Intel: Activities";
		text = "Intel does not always inform you about locations. Some intel instead informs you about orders received by enemy squads. Gaining this type of intel is the key to finding out about patrols and supply convoys, which you can then attack.";
		imagePath = "UI\Images\tut_civis.paa";

	};

	class TutPage4 : TutBasePage
	{
		textHeadline = "Intel: Radio Messages";
		text = "Antennas can intercept radio signals within several kilometers from enemy, but only if you have obtained radio cryptokeys from this territory. Cryptokeys can be found at military tactical tablets. They must be activated at any radio you own before you can start intercepting intel. Cryptokeys are automatically copied to your 'Notes' tab, from which you can copy them and to activate at the radio.";

	};

	class TutPage5 : TutBasePage
	{
		textHeadline = "Camps: Creating A Camp";
		text = "Construction resources are required to create new camps, outposts, roadblocks, or to construct new objects at their location. They can be found in ammo boxes found at police stations, outposts, and bases.";
		imagePath = "UI\Images\tut_construction.paa";

	};

	class TutPage6 : TutBasePage
	{
		textHeadline = "Camps: Building";
		text = "Construction resources are required to create new camps, outposts, roadblocks, or to construct new objects at their location. They can be found in ammo boxes found at police stations, outposts, and bases.";
		imagePath = "UI\Images\tut_construction.paa";

	};

	class TutPage7 : TutBasePage
	{
		textHeadline = "Camps: Limited Arsenal";
		text = "The limited Arsenal is an alteration of the Arma 3 arsenal. It has only a limited inventory for each item, and is the main interface to manage gathered weapons in the mission. All the cargo boxes you can create through the build menu have the limited arsenal enabled. Enemy cargo boxes use only the plain Arma 3 inventory.";
		imagePath = "UI\Images\tut_image_default.paa";

	};

	class TutPage8 : TutBasePage
	{
		textHeadline = "Infantry Capacity";
		text = "Every location has an infantry capacity based on the number of buildings at the location. This number limits how many soldiers you can deploy at a location. You can not respawn at a location you own if it has no infantry capacity. When creating a new location, all the buildings at its territory are added to it. You should try to construct camps near existing houses to save resources. You can also build tents to increase the infantry capacity at a location.";

	};

	class TutPage9 : TutBasePage
	{
		textHeadline = "High Command";
		text = "This scenario provides a custom interface on the map screen to command your own forces. Friendly and enemy forces are both organised into 'garrisons'. Garrisons are groups of soldiers that can be commanded to move and attack enemy forces. They operate autonomously, and do not need specific orders to get into vehicles before traveling to a location. Click on a friendly garrison on your map, split it, then give an order to the now detached garrison.";

	};

	class TutPage10 : TutBasePage
	{
		textHeadline = "Saving And Loading";
		text = "The scenario can save the game state with minimal detail. It saves the composition of all garrisons, but it does not save, for example, the position and health of units. All the data is saved in vars.arma3profile and each save takes several megabytes. Arma 3 reads and writes to and from this file quite often, so keep the number of savegames to a minimum.";

	};

	class TutPage11 : TutBasePage
	{
		textHeadline = "Known Limitations";
		text = "• To save vehicles, they must be attached to a friendly garrison. To do this, use the action while looking at a vehicle.\n • Vehicles may not always respawn at their old position if parked close together, but at the nearest road. Do not place vehicles too close to one another, or to buildings.\n • AI units cannot transport static weapons and cargo boxes with them. Do not try to give a static weapon to a garrison and give it an order to move somewhere.\n • Arma 3's AI cannot drive properly, and often gets stuck. Infantry gets stuck in buildings.\n • The mission AI may teleport units in an attempt to get them unstuck.";
		imagePath = "UI\Images\tut_limits.paa";

	};
	
};
