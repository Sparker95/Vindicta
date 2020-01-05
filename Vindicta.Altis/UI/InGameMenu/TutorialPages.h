#define __STRINGIFY(value) #value
#define __TUT_IMAGE(imagename) __STRINGIFY(\z\vindicta\addons\ui\pictures\imagename)

class TutorialPages
{
	// base class, default page
	class TutBasePage 
	{
		textHeadline = "VINDICTA Gameplay Tutorial";
		text = "Welcome to the VINDICTA tutorial. This tutorial will help you enjoy this mission.";
		imagePath = __TUT_IMAGE(tut_image_default.paa);
	};

	class TutPage0_0 : TutBasePage
	{
		textHeadline = "Introduction";
		text = "If you are reading this, congratulations! You have navigated to the mission's in-game menu and you have opened the Tutorial. There are no other keyboard keys you need to know about to play this mission.\n\nVINDICTA is a sandbox scenario where your main goal is to liberate the island from enemy occupation. There is no strict end end condition and no end screen, but you may consider the mission finished when you take all airfields under your control, because then enemy will not be able to bring more reinforcements.";
		imagePath = __TUT_IMAGE(tut_scenario.paa);
	};

	class TutPage_setup : TutBasePage
	{
		textHeadline = "Campaign Setup";
		text = "After mission is loaded, you must setup the campaign In the 'Create' tab. You must set up the initial conditions and enemy factions of the scenario.\n\nOnce the game world is generated, these settings can not be changed.";
	};

	class TutPage0 : TutBasePage
	{
		textHeadline = "Respawn";
		text = "You can respawn at all friendly locations controlled by your faction, if they have an infantry capacity above zero. Camps, which can be created with build resources, also enable respawn in nearby cities in case you run out of vehicles.";
	};

	class TutPage_campaignProgress : TutBasePage
	{
		textHeadline = "Campaign Progress";
		text = "Enemy will dynamicly react to your actions, and the reaction will depend on the current war state. At the start of the game, however, everything is relatively calm and enemy occupation is not full.\n\nExpect enemy to bring reinforcements to their airfields as a reaction to your actions.";
	};

	class TutPage1 : TutBasePage
	{
		textHeadline = "Staying Undercover";
		text = "When you are starting out, you should use the undercover system to your advantage until you have found better weapons, equipment, and vehicles. Watch the meter at the top of your screen: If it's full and red then you are overt. Enemy forces will shoot on sight while you are overt. The text below the meter informs you about reasons why the meter is filling up. Some of the factors that determine your 'suspiciousness':\n • Clothing, like headwear, uniform, vest, night vision goggles\n • Openly carrying a weapon immediately makes you overt\n • Fast movement draws attention and suspicioun\n • In vehicles, only your headwear counts, and enemies will only spot your equipment as you get closer\n\nOnce spotted, you can go back to being undercover by escaping a ~1km area or by killing all enemies who have recently spotted you.";
		imagePath = __TUT_IMAGE(tut_undercover.paa);

	};

	class TutPage2 : TutBasePage
	{
		textHeadline = "Intel: Locations";
		text = "Intel about locations is shown on the map when you click on a location marker.\n\nYou can talk to civilians to learn about the location of nearby interesting places. Alternatively, you can simply drive around until you discover something.\n\nYou can also loot enemies to find tactical tablets, which you can read in your inventory by double clicking them with your left mouse button.";
		imagePath = __TUT_IMAGE(tut_policeStations.paa);

	};

	class TutPage3 : TutBasePage
	{
		textHeadline = "Intel: Activities";
		text = "Intel does not always inform you about locations. Some intel instead informs you about orders received by enemy squads.\n\nGaining this type of intel is the key to finding out about patrols and supply convoys, which you can then attack. Look at the map UIs intel panel to show and select currently known intel.\n\nMost intel is represented on the map with a start point and a destination.";
		imagePath = __TUT_IMAGE(tut_civis.paa);
	};

	class TutPage4 : TutBasePage
	{
		textHeadline = "Intel: Radio Messages";
		text = "Antennas at friendly locations can intercept enemy radio signals within several kilometers, but only if you have obtained radio cryptokeys from this territory. Cryptokeys can be found at military tactical tablets. They must be activated at any radio you own before you can start intercepting intel. Cryptokeys are automatically copied to your 'Notes' tab, from which you can copy them and to activate at the radio.";
		imagePath = __TUT_IMAGE(tut_radio.paa);
	};

	class TutPage5 : TutBasePage
	{
		textHeadline = "Camps: Creating A Camp";
		text = "Construction resources are required to create new camps, outposts, roadblocks, or to construct new objects at their location. They can be found in ammo boxes found at police stations, outposts, and bases.\nWhen creating a location, all buildings are automatically added to it, including the radio antennas.";
		imagePath = __TUT_IMAGE(tut_construction.paa);
	};

	class TutPage6 : TutBasePage
	{
		textHeadline = "Camps: Build Menu";
		text = "Construction resources are required to create new camps, outposts, roadblocks, or to construct new objects at their location. They can be found in ammo boxes found at police stations, outposts, and bases. The build menu is accessible at camps. It has a user interface that explains all the available controls. There are two ways to open the build menu:\n\n• From your inventory: Uses build resources from your inventory to construct objects. Build resources must be either in your uniform, vest, or backpack.\n• From location: Uses build resources deposited at the location you are building at. They must be inside an arsenal or crate that is 'attached' to the garrison (=location).";
		imagePath = __TUT_IMAGE(tut_construction.paa);
	};

	class TutPage7 : TutBasePage
	{
		textHeadline = "Camps: Limited Arsenal";
		text = "The limited Arsenal is an alteration of the Arma 3 arsenal. It has only a limited inventory for each item, and is the main interface to manage gathered weapons in the mission. All the cargo boxes you can create through the build menu have the limited arsenal enabled. Enemy cargo boxes use only the plain Arma 3 inventory. You can use the action on an arsenal constructed through the build menu to load items from a plain inventory crate into the Arsenal. This will load items into the Arsenal box's plain Arma 3 'Inventory'. Once you have done that, open the Arsenal itself and press the appropriate button at the bottom of the Arsenal interface.";
	};

	class TutPage8 : TutBasePage
	{
		textHeadline = "Camps: Infantry Capacity";
		text = "Every location has an infantry capacity based on the number of buildings at the location. This number limits how many soldiers you can deploy at a location. You can not respawn at a location you own if it has no infantry capacity. When creating a new location, all the buildings at its territory are added to it. You should try to construct camps near existing houses to save resources. You can also build tents to increase the infantry capacity at a location.";
	};

	class TutPage_recruit : TutBasePage
	{
		textHeadline = "Camps: Recruiting";
		text = "You can recruit civilians at owned locations from nearby cities. Recruitment radius is shown on the map when you select a location. Each city provides recruits depending on the civilian agitation level. You can agitate citizens by talking to civilians or by performing military actions at cities.";
	};

	class TutPage9 : TutBasePage
	{
		textHeadline = "High Command";
		text = "This scenario provides a custom interface on the map screen to command your own forces. Friendly and enemy forces are both organised into 'garrisons'. Garrisons are groups of soldiers that can be commanded to move and attack enemy forces. They operate autonomously, and do not need specific orders to get into vehicles before traveling to a location. Click on a friendly garrison on your map, split it, then give an order to the now detached garrison.";
		imagePath = __TUT_IMAGE(tut_high_command.paa);
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
		imagePath = __TUT_IMAGE(tut_limits.paa);
	};
	
};
