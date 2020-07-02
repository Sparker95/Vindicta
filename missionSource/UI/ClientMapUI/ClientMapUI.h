#include "ClientMapUI_Macros.h"

class ClientMapUI
{
	idd = -1;
	enableSimulation = true;
	movingEnable = true;
	moving = true;
	canDrag = true;
	
	class ControlsBackground
	{
		
	};
	class Controls
	{
		#include "Controls\IntelPanel.h"
	};
};

// Will be included into the .ext root actually
#include "Controls\GarrisonCommand.h"
#include "Controls\GarrisonSelectedMenu.h"
#include "Controls\LocationSelectedMenu.h"
#include "Dialogs\GarrisonSplitDialog.h"