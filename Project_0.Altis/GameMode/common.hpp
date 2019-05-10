#define OOP_DEBUG
#define OOP_INFO
#define OOP_ERROR
#define OOP_WARNING
#define OOP_ASSERT
#define OFSTREAM_FILE "GameMode.rpt"

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\CriticalSection\CriticalSection.hpp"
#include "..\AI\Commander\AICommander.hpp"
#include "..\AI\Commander\LocationData.hpp"
#include "..\Group\Group.hpp"

#define IS_HEADLESSCLIENT (!hasInterface && !isDedicated)
