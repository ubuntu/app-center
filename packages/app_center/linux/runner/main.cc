#include "my_application.h"

#include <malloc.h>

int main(int argc, char** argv) {
  // Cap arenas before any thread starts; malloc_trim() can't shrink their tops.
  mallopt(M_ARENA_MAX, 4);
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
