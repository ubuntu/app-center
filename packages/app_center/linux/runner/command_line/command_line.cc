#include "command_line.h"

#include <stdio.h>
#include <string.h>

static const char* executable_name(const char* path) {
  const char* slash = strrchr(path, '/');
  if (slash != NULL) {
    return slash + 1;
  }
  return path;
}

static bool is_help_requested(int argc, char** argv) {
  for (int i = 1; i < argc; ++i) {
    if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0) {
      return true;
    }
  }
  return false;
}

bool handle_command_line(int argc, char** argv, int* exit_status) {
  if (!is_help_requested(argc, argv)) return false;

  const char* name = executable_name(argv[0]);
  // Keep the documented options in sync with store_providers.dart.
  static const char help[] =
      "Usage: %s [options] [<snap-name> | <path.deb> | URL]\n"
      "\n"
      "Ubuntu App Center manages snaps and Debian packages.\n"
      "Except for help, the arguments below open GUI pages; they do not return\n"
      "search or installation results to the terminal.\n"
      "\n"
      "Options:\n"
      "  -h, --help             Print help and exit\n"
      "      --snap <name>      Open snap details\n"
      "      --search <query>   Open snap search results\n"
      "      --updates          Open the Manage page for installed apps and updates\n"
      "      --unified-details  Use unified snap/Debian details pages (experimental)\n"
      "      --gst <description|resource-id>\n"
      "                         Install GStreamer resources (integration option;\n"
      "                         repeatable, values are not split on commas)\n"
      "\n"
      "Positional arguments and URLs:\n"
      "  <snap-name>                          Open details for a single snap name\n"
      "  <path.deb>                           Open a local Debian package\n"
      "  snap://<name>                        Open snap details\n"
      "  appcenter://addons                   Open Add-ons\n"
      "  appcenter://addons/media-support     Open Media Support\n"
      "\n"
      "Examples:\n"
      "  %s --search \"web browser\"\n"
      "  %s --snap firefox\n"
      "  %s ./example.deb\n"
      "  %s --gst 'H.265 decoder|gstreamer1(decoder-video/x-h265)()(64bit)'\n";
  const int written = fprintf(stdout, help, name, name, name, name, name);
  if (written < 0 || fflush(stdout) != 0) {
    *exit_status = 1;
  } else {
    *exit_status = 0;
  }
  return true;
}
