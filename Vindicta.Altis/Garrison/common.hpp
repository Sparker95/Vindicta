// !! Must be included before OOP_Light.h

#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OFSTREAM_FILE "Main.rpt"

#include "..\common.h"
#include "..\Group\Group.hpp"
#include "..\Garrison\Garrison.hpp"
#include "..\MessageTypes.hpp"
#include "..\AI\Garrison\garrisonWorldStateProperties.hpp"
#include "..\AI\Garrison\AIGarrison.hpp"
#include "..\AI\Stimulus\Stimulus.hpp"
#include "..\AI\stimulusTypes.hpp"
#include "..\Templates\Efficiency.hpp"
#include "..\Message\Message.hpp"
#include "..\defineCommon.inc"
#include "..\MessageReceiver\MessageReceiver.hpp"
#include "..\Mutex\Mutex.hpp"
#include "..\MutexRecursive\MutexRecursive.hpp"
#include "..\AI\Commander\LocationData.hpp"

#include "Garrison.hpp"

// Mutex used in this file
#ifndef _SQF_VM
#define __MUTEX_LOCK	private __mutex = T_GETV("mutex"); MUTEX_RECURSIVE_LOCK(__mutex)
#define __MUTEX_UNLOCK	MUTEX_RECURSIVE_UNLOCK(__mutex)
#else
#define __MUTEX_LOCK	
#define __MUTEX_UNLOCK	
#endif

#define IS_GARRISON_DESTROYED(obj) (GETV(obj, "effTotal") isEqualTo [])