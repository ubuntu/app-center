#ifndef APP_CENTER_COMMAND_LINE_H_
#define APP_CENTER_COMMAND_LINE_H_

#include <stdbool.h>

// Prints help locally if any argument is exactly --help or -h. Otherwise leaves
// argv unchanged for GUI dispatch. Requires no GTK or GLib setup.
bool handle_command_line(int argc, char** argv, int* exit_status);

#endif  // APP_CENTER_COMMAND_LINE_H_
