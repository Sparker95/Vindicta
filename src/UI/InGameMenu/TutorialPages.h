#define QUOTE(value) #value
#define __TUT_IMAGE(imagename) QUOTE(\z\vindicta\addons\ui\pictures\imagename)

class TutorialPages
{
	// base class, default page
	class TutBasePage 
	{
		textHeadline = "Vindicta Gameplay Tutorial";
		text = "Welcome to the Vindicta tutorial. This tutorial will help you enjoy this mission.";
		imagePath = __TUT_IMAGE(tut_image_default.paa);
	};

	class TutPage_AddInfo : TutBasePage
	{
		textHeadline = "Useful Links";
		text = "Additional information about the mission can be found at:\n\nvindicta-team.github.io/Vindicta-Docs\n\nYou can also find the development team's Discord channel on the mod's Steam Workshop page.\n\nThis tutorial may contain outdated information, so please check the online documentation if you are having issues.";
	};

	class TutPage_Intro : TutBasePage
	{
		textHeadline = "Introduction";
		text = "If you are reading this, congratulations! You have navigated to the mission's in-game menu and you have opened the tutorial. There are no other keyboard keys you need to know about to play this mission.\n\nVindicta is a sandbox scenario where your main goal is to liberate the island from enemy occupation. There is no strict end condition and no end screen, but you may consider the mission finished when you take all airfields under your control, because then enemy will not be able to bring more reinforcements.";
		imagePath = __TUT_IMAGE(tut_scenario.paa);
	};

	class TutPage_StepByStep1 : TutBasePage
	{
		textHeadline = "Quick Start I";
		text = "This is a simple step by step series, to help you get started:\n\n1. Start by asking civilians for intel. See 'Intel I' in this tutorial for more information on this. Hopefully a civilian will already point out the location of a police station.\n\n2. If not, drive away to a different town and retry until you have found a police station.\n\n3. Once you have found your first police station, kill the police officers inside using your pistol. You always spawn with a pistol and some ammo.\n\n4. Find a suitable vehicle and use ACE3 to load the ammo boxes inside.\n\nProceed to the next page to continue this series.";
		imagePath = __TUT_IMAGE(tut_scenario.paa);
	};

	class TutPage_StepByStep2 : TutBasePage
	{
		textHeadline = "Quick Start II";
		text = "5. Drive to a remote location, preferrably one the enemy cannot easily spot. Unload the crate. It should contain some construction resources. Look directly at the crate, or place some of the construction resources in your inventory, then press [U]. This will open the in-game menu you are in now. Go to the 'Strategic' tab and select type Camp, enter a name (or use the pre-selected one) and press 'Create'. This will create your first camp. NOTE: You must be away from other locations, such as cities, to create a camp.\n\nProceed to the next page to continue this series. There are also additional pages with more in-depth information.";
		imagePath = __TUT_IMAGE(tut_scenario.paa);
	};

	class TutPage_StepByStep3 : TutBasePage
	{
		textHeadline = "Quick Start III";
	text = "6. Your new camp should give you an option to open the build menu. See the page 'Build Menu' for additional information. Once you have opened the build menu, navigate to the Storage category and create any crate, provided you have enough construction resources.\n\n7. The newly built storage crate will give you three options: 'Arsenal', 'Arsenal To External Inventory', and 'External Inventory To Arsenal'. Use the third option to load the box from the police station into the Limited Arsenal crate.\n\n 8. You can now use the Limited Arsenal to more easily equip your captured equipment.\n\nProceed to the next page to continue this series.";
		imagePath = __TUT_IMAGE(tut_scenario.paa);
	};

	class TutPage_StepByStep4 : TutBasePage
	{
		textHeadline = "Quick Start IV";
	text = "9. Any crate or vehicle can be loaded into the Limited Arsenal, and you can load parts or all of the Limited Arsenal into vehicles, crates, and other Limited Arsenals. You can also load items into the normal 'Inventory' to load them into the Limited Arsenal. This is useful if you would like to quickly unequip, but not lose, your personal equipment. Simply go into the Limited Arsenal using the 'Arsenal' action, and press 'Inv. To Arsenal' at the bottom to load the regular 'Inventory'.\n\nProceed to the next page to continue this series.";
		imagePath = __TUT_IMAGE(tut_scenario.paa);
	};

	class TutPage_StepByStep5 : TutBasePage
	{
		textHeadline = "Quick Start V";
	text = "10. You may want to continue to attack police station until you have enough equipment.\n\n11. After that you should find an outpost and capture it. Enemy soldiers may carry tactical tablets, which have a chance of giving you a radio crytokey. Once you find a radio cryptokey, you can load it into a radio shack constructed at one of your camps. Open this in-game menu by pressing [U], go to the 'Notes' tab and copy the radio cryptokey. Go to a radio shack, select the action to 'Manage cryptokeys' and enter your found cryptokey. This will give you access to a constant stream of enemy intel, such as attacks on your own outposts and positions.\n\n Capture enemy positions to win the game! Continue reading this tutorial to learn more.";
		imagePath = __TUT_IMAGE(tut_scenario.paa);
	};

	class TutPage_setup : TutBasePage
	{
		textHeadline = "Campaign Setup";
		text = "After the mission is loaded, you must set up the campaign in the 'Create' tab. Select initial conditions and enemy factions of the scenario.\n\nOnce the game world is generated, these settings can not be changed. You can create a new campaign at any time to try different settings.";
	};

	class TutPage0 : TutBasePage
	{
		textHeadline = "Respawn";
		text = "You can respawn at all friendly locations and at any city, so long as there are no enemies nearby, and as long as they have an infantry capacity greater than zero. Camps, which can be created with build resources also enable respawn in nearby cities in case you run out of vehicles.";
	};

	class TutPage_campaignProgress : TutBasePage
	{
		textHeadline = "Campaign Progress";
		text = "The enemy will dynamically react to your actions, and the reaction will depend on the current war state. At the start of the game, however, everything is relatively calm and enemy occupation is low.\n\nExpect the enemy to bring reinforcements to their airfields as a reaction to you attacking outposts.";
	};

	class TutPageUndercover_1 : TutBasePage
	{
		textHeadline = "Staying Undercover I";
		text = "When you are starting out, you should use the undercover system to your advantage until you have found better weapons, equipment, and vehicles. Watch the meter at the top of your screen: If it's full and red, you are overt. Enemy forces will shoot on sight while if they spot you while you are overt. The text below the meter informs you about reasons why the meter is filling up. Some of the factors that determine your 'suspiciousness':\n• Clothing, like headwear, uniform, vest, night vision goggles\n• Openly carrying a weapon immediately makes you overt\n• Fast movement draws attention and suspicion\n• In vehicles, only your headwear and vest count, and enemies will only spot your equipment as you get closer. The meter will only fill once you get closer to enemies.";
		imagePath = __TUT_IMAGE(tut_undercover.paa);

	};

	class TutPageUndercover_2 : TutBasePage
	{
		textHeadline = "Staying Undercover II";
		text = "You can go back to being undercover by...\n\n• Escaping an approx. 1 kilometer radius at the last position where you were spotted as overt.\n• By killing all enemy groups that spotted.\n• By staying for 20 minutes.\n\nAdditionally, you should avoid approaching enemies who are in combat. You should also avoid using the ACE3 medical system while being close to enemies.";
		imagePath = __TUT_IMAGE(tut_undercover.paa);

	};

	class TutPage2 : TutBasePage
	{
		textHeadline = "Intel I";
		text = "Intel about locations is shown on the map when you click on a location marker.\n\nYou can talk to civilians to learn about the location of nearby interesting places. Alternatively, you can simply drive around until you discover something.\n\nYou can also loot enemies to find tactical tablets, which you can read in your inventory by double clicking them with your left mouse button.";
		imagePath = __TUT_IMAGE(tut_policeStations.paa);

	};

	class TutPage3 : TutBasePage
	{
		textHeadline = "Intel II";
		text = "Intel does not always inform you about locations. Some intel instead informs you about orders received by enemy squads.\n\nGaining this type of intel is the key to finding out about patrols and supply convoys, which you can then attack. Look at the map UIs intel panel to show and select currently known intel.\n\nMost intel is represented on the map with a start point and a destination.";
		imagePath = __TUT_IMAGE(tut_civis.paa);
	};

	class TutPage4 : TutBasePage
	{
		textHeadline = "Cryptokeys";
		text = "Antennas at friendly locations can intercept enemy radio signals within several kilometers, but only if you have obtained radio cryptokeys. Cryptokeys can be found at military tactical tablets. They must be activated at any radio you own before you can start intercepting intel. Cryptokeys are automatically copied to your 'Notes' tab, from which you can copy them and to activate at the radio.";
		imagePath = __TUT_IMAGE(tut_radio.paa);
	};

	class TutPageClaiming : TutBasePage
	{
		textHeadline = "Claiming Locations";
		text = "To claim locations (outposts, bases, police stations) press [U] on your keyboard, then navigate to the 'Strategic' tab, and press claim. Some locations may require construction resources to claim. You do not have to carry them in your inventory. Instead look at any container or vehicle that holds enough construction resources, and open the in-game [U] menu, then use the 'Strategic' tab to claim the location.";
		imagePath = __TUT_IMAGE(tut_construction.paa);
	};

	class TutPage5 : TutBasePage
	{
		textHeadline = "Camps";
		text = "Construction resources are required to create new camps, outposts, roadblocks, or to construct new objects at their location. They can be found in ammo boxes found at police stations, outposts, and bases.\nWhen creating a location, all buildings are automatically added to it, including the radio antennas.";
		imagePath = __TUT_IMAGE(tut_construction.paa);
	};

	class TutPage6 : TutBasePage
	{
		textHeadline = "Build Menu";
		text = "The build menu is accessible at camps and other friendly locations. It has a user interface that explains all the available controls. There are two ways to open the build menu:\n\n• From your inventory: Uses build resources from your inventory to construct objects. Build resources must be either in your uniform, vest, or backpack.\n• From location: Uses build resources deposited at the location you are building at. They must be inside an Limited Arsenal or crate that is 'attached' to the garrison (=location).";
		imagePath = __TUT_IMAGE(tut_construction.paa);
	};

	class TutPage7 : TutBasePage
	{
		textHeadline = "Limited Arsenal";
		text = "The limited Arsenal is an alteration of the Arma 3 Arsenal. It has only a limited inventory for each item, and is the main interface to manage gathered weapons in the mission. All the cargo boxes you can create through the build menu have the Limited Arsenal enabled. Enemy cargo boxes use only the plain Arma 3 inventory. You can use the action on an Limited Arsenal constructed through the build menu to load items from a plain inventory crate into the Arsenal. This will load items into the Arsenal box's plain Arma 3 'Inventory'. Once you have done that, open the Limited Arsenal itself and press the appropriate button at the bottom of the Limited Arsenal interface.";
	};

	class TutPage8 : TutBasePage
	{
		textHeadline = "Infantry Capacity";
		text = "Every location has an infantry capacity based on the number of buildings at the location. This number limits how many soldiers you can deploy at a location. You can not respawn at a location you own if it has no infantry capacity. When creating a new location, all the buildings at its territory are added to it. You should try to construct camps near existing houses to save resources. You can also build tents to increase the infantry capacity at a location.";
	};

	class TutPage9 : TutBasePage
	{
		textHeadline = "High Command";
		text = "This scenario provides a custom interface on the map screen to command your own forces. Friendly and enemy forces are both organised into 'garrisons'. Garrisons are groups of soldiers that can be commanded to move and attack enemy forces.\nAI groups operate autonomously and do not need specific orders to get into vehicles before traveling to a location. Click on a friendly garrison on your map, split it, then give an order to the now detached garrison.";
		imagePath = __TUT_IMAGE(tut_high_command.paa);
	};

	class TutPage10 : TutBasePage
	{
		textHeadline = "Saving And Loading";
		text = "The scenario can save the game state with minimal detail. It saves the composition of all garrisons, but it does not save, for example, the position and health of units. All the data is saved in the user profile 'vars.arma3profile' and each save takes several megabytes. Arma 3 reads and writes to and from this file quite often, so keep the number of savegames to a minimum.\n\nYou should NOT maintain more than 10 savegames at a time!";
	};

	class TutPage11 : TutBasePage
	{
		textHeadline = "Known Issues";
		text = "• Objects may not appear exactly where you place them or they are placed with a delay\n• To save vehicles, they must be attached to a friendly garrison. Some vehicles do not attach automatically. You can use the action 'Attach to Garrison' to manually attach them.\n• Vehicles may not always respawn at their old positions if parked close together, but at the nearest road. Do not place vehicles too close to one another, or too close to buildings.\n• AI units cannot transport static weapons and cargo boxes. Do not try to give a static weapon to a garrison and then give them a 'Move' order.\n• Arma 3's AI cannot drive properly, and often gets stuck. Infantry gets stuck in buildings.\n• The mission AI may teleport units in an attempt to get them unstuck.";
		imagePath = __TUT_IMAGE(tut_limits.paa);
	};
	
};
