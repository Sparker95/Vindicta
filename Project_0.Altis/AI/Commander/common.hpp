#define OOP_DEBUG
#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING

#define OFSTREAM_FILE "Commander.rpt"
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\Location\Location.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\..\Cluster\Cluster.hpp"
#include "..\..\Templates\Efficiency.hpp"
#include "..\Action\Action.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "..\parameterTags.hpp"
#include "..\..\Group\Group.hpp"
#include "..\commonStructs.hpp"
#include "..\Garrison\garrisonWorldStateProperties.hpp"
#include "..\Group\groupWorldStateProperties.hpp"
#include "LocationData.hpp"
#include "AICommander.hpp"
#include "..\..\MessageReceiver\MessageReceiver.hpp"
#include "..\..\Mutex\Mutex.hpp"
#include "..\..\Intel\Intel.hpp"

#define PROFILER_COUNTERS_ENABLE

#include "CmdrAction\CmdrActionStates.hpp"
