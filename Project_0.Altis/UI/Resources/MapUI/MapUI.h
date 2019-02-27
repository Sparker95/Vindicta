#include "MapUI_Macros.h"
#include "CustomControlClasses.h"

class MapUI
{
	idd = IDD_MAP_UI;

	class ControlsBackground
	{

	};
	class Controls
	{
		#include "Controls\LocationData.h"
		#include "Controls\PlayerList.h"
	};
};
