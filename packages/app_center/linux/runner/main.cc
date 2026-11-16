#include "my_application.h"

#include "command_line/command_line.h"

int main(int argc, char** argv) {
  int exit_status = 0;
  if (handle_command_line(argc, argv, &exit_status)) return exit_status;

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
