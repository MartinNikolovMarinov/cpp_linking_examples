#include "some_logic.h"

#include <stdio.h>

// These can be used like this, because they are in the include path:
#include <add.h>
#include <sub.h>

void SomeLogic()
{
  int x = 10, y = 20;
  printf("\n%d + %d = %d\n", x, y, Add(x, y));
  printf("\n%d - %d = %d\n", x, y, Sub(x, y));
}