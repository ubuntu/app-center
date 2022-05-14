//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <handy_window/handy_window_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) handy_window_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "HandyWindowPlugin");
  handy_window_plugin_register_with_registrar(handy_window_registrar);
}
