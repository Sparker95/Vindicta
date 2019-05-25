#include "ClientMapUI_Macros.h"

#include "..\MissionUIControlClasses.h"
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
		//#include "Controls\PlayerList.h"
	};
};
