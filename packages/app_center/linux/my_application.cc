#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#include <handy.h>
#include <gdk/gdk.h>

#include "flutter/generated_plugin_registrant.h"

#ifdef NDEBUG
#define APPLICATION_FLAGS \
  G_APPLICATION_HANDLES_COMMAND_LINE | G_APPLICATION_HANDLES_OPEN
#else
#define APPLICATION_FLAGS G_APPLICATION_NON_UNIQUE
#endif

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);

#ifdef NDEBUG
  GList* windows = gtk_application_get_windows(GTK_APPLICATION(application));
  if (windows) {
    gtk_window_present(GTK_WINDOW(windows->data));
    return;
  }
#endif

  GtkWindow* window = GTK_WINDOW(hdy_application_window_new());
  gtk_window_set_application(window, GTK_APPLICATION(application));

  // Get screen size using GdkMonitor
  GdkDisplay* display = gdk_display_get_default();
  GdkMonitor* monitor = gdk_display_get_primary_monitor(display);
  GdkRectangle monitor_geometry;
  gdk_monitor_get_geometry(monitor, &monitor_geometry);
  gint screen_width = monitor_geometry.width;
  gint screen_height = monitor_geometry.height;

  // Calculate default window size (e.g., 80% of screen size)
  gint default_width = screen_width * 0.8;
  gint default_height = screen_height * 0.8;

  GdkGeometry geometry;

  // This ensures that the minimum width of the window is at least 800+52 pixels
  geometry.min_width = default_width < 800 + 52 ? 800 + 52 : default_width;
  geometry.min_height = default_height < 600 + 52 ? 600 + 52 : default_height;

  gtk_window_set_geometry_hints(window, nullptr, &geometry, GDK_HINT_MIN_SIZE);

  gtk_window_set_default_size(window, default_width, default_height);
  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

#ifdef NDEBUG
// Implements GApplication::command_line.
static gint my_application_command_line(GApplication* application,
                                        GApplicationCommandLine* command_line) {
  gchar** arguments =
      g_application_command_line_get_arguments(command_line, nullptr);
  gint exit_status = 0;
  my_application_local_command_line(application, &arguments, &exit_status);
  return exit_status;
}
#endif

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
#ifdef NDEBUG
  G_APPLICATION_CLASS(klass)->command_line = my_application_command_line;
#else
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
#endif
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     APPLICATION_FLAGS, nullptr));
}
