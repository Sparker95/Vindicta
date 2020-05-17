#define OFSTREAM_FILE "UI.rpt"
#include "..\..\common.h"

#define pr private

		private _inst = CALLSM0("TacticalTablet", "newInstance");

		private _tipOfTheDay = 	[	"Always wear a helmet, even at base!",
									"Have you checked your ammo?",
									"Stay alert when on patrol!",
									"Ensure your radio frequency and channel!",
									"Never do a selfie in fight!",
									"Remember to stay in formation, ... but not too close!",
									"Remember to check fuel of your vehicles!",
									"Find your gun safety switch before fight!"];

		// Make us some time while we are waiting for server response...
		CALLM2(_inst,"appendTextDelay", "Welcome to TactiCool OS v28.3!\nDetected 128 GB RAM, 16 TB SSD\n", 0.1);
		pr _text = format ["System date: %1, grid: %2\n", date, mapGridPosition player];
		CALLM2(_inst,"appendTextDelay", _text, 0.2);
		pr _text = format ["User class: %1\n", typeof player];
		CALLM2(_inst,"appendTextDelay", _text, 0.2);

		CALLM2(_inst,"appendTextDelay", "\nTip of the day:\n",  0.1 + random 0.2);
		CALLM2(_inst,"appendTextDelay", selectrandom _tipOfTheDay, 0);
		CALLM2(_inst,"appendTextDelay", "\n", 0);

		CALLM2(_inst,"appendTextDelay", "\nConnecting to TactiCommNetwork server...\n",  0.15 + random 0.2);
		CALLM2(_inst,"appendTextDelay", "Tx SYN\n",  0.2 + random 0.2);
		CALLM2(_inst,"appendTextDelay", "Rx SYN-ACK\nTx ACK\n",  0.2 + random 0.2);
		//CALLM2(_inst,"appendTextDelay", ".", 0.3);
		//CALLM2(_inst,"appendTextDelay", ".", 0.3);
		//CALLM2(_inst,"appendTextDelay", ".", 0.1);
		CALLM2(_inst,"appendTextDelay", "Tx RQ-DATA\n", 0.2);
		CALLM2(_inst,"appendTextDelay", "Rx INTEL_CMDR_ACTION\n", 0.2);
		CALLM2(_inst,"appendTextDelay", "\nConnection established!\n", 0.1);

		CALLM2(_inst, "setTextDelay", "Logged in Altis Armed Forces TactiCommNetWork", 0.4);