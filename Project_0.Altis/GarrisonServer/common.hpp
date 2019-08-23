#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OFSTREAM_FILE "Main.rpt"

#include "..\OOP_Light\OOP_Light.h"
#include "..\Group\Group.hpp"
#include "..\MessageTypes.hpp"
#include "..\AI\Garrison\garrisonWorldStateProperties.hpp"
#include "..\AI\Garrison\AIGarrison.hpp"
#include "..\Templates\Efficiency.hpp"
#include "..\Message\Message.hpp"
#include "..\GlobalAssert.hpp"
#include "..\MessageReceiver\MessageReceiver.hpp"
#include "..\Mutex\Mutex.hpp"
#include "..\MutexRecursive\MutexRecursive.hpp"