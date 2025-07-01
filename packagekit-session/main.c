/* SPDX-License-Identifier: GPL-3.0-or-later */
/* Copyright 2025 Canonical Ltd. */

#include <gio/gio.h>
#include <gio/gdesktopappinfo.h>
#include "pk-modify2.h"

#define APP_CENTER_DESKTOP "snap-store_snap-store.desktop"

struct AppCenterData {
    const char *app_name;
} ;

static gboolean
handle_install_gstreamer_resources (PackageKitModify2      *interface,
                                    GDBusMethodInvocation  *invocation,
                                    char                  **arg_resources,
                                    const char             *arg_interaction,
                                    const char             *arg_desktop_id,
                                    GVariant               *arg_platform_data,
                                    gpointer                user_data)
{
    g_autoptr (GAppLaunchContext) context = NULL;
    g_autoptr (GAppInfo) app = NULL;
    g_autoptr (GString) cmdline = NULL;
    g_autoptr (GError) error = NULL;
    struct AppCenterData *data = user_data;
    const char *sni = NULL;

    if (!arg_resources[0])
        return TRUE;

    context = g_app_launch_context_new ();
    if (g_variant_lookup (arg_platform_data, "desktop-startup-id", "&s", &sni)) {
        g_app_launch_context_setenv (context, "STARTUP_NOTIFY_ID", sni);
        g_app_launch_context_setenv (context, "XDG_ACTIVATION_TOKEN", sni);
    }

    cmdline = g_string_new ("snap-store");
    for (int i = 0; arg_resources[i]; i++) {
        g_autofree char *quoted = g_shell_quote (arg_resources[i]);
        g_string_append_printf(cmdline, " --gst %s", quoted);
    }

    app = g_app_info_create_from_commandline (cmdline->str,
                                              data->app_name,
                                              G_APP_INFO_CREATE_NONE,
                                              &error);
    if (!app) {
        g_warning ("Failed to launch App Center: %s", error->message);
        g_dbus_method_invocation_return_gerror (invocation, error);
        return TRUE;
    }

    if (!g_app_info_launch (app, NULL, context, &error)) {
        g_warning ("Failed to launch App Center: %s", error->message);
        g_dbus_method_invocation_return_gerror (invocation, error);
        return TRUE;
    }

    package_kit_modify2_complete_install_gstreamer_resources (interface, invocation);
    return TRUE;
}

static void
on_bus_name_acquired (GDBusConnection *connection,
                      const char      *name,
                      gpointer         user_data)
{
    g_message ("Service is running on session bus.");
}

static void
on_bus_name_lost (GDBusConnection *connection,
                  const char      *name,
                  gpointer         user_data)
{
    GMainLoop *loop = user_data;

    g_message ("Fallen off the session bus.");
    g_main_loop_quit (loop);
}

int
main (int argc, char *argv[])
{
    g_autoptr (GMainLoop) loop = g_main_loop_new (NULL, FALSE);
    g_autoptr (GDBusConnection) connection = NULL;
    g_autoptr (PackageKitModify2) interface = NULL;
    g_autoptr (GDesktopAppInfo) app_info = NULL;
    g_autoptr (GError) error = NULL;
    struct AppCenterData data;
    guint id;

    connection = g_bus_get_sync (G_BUS_TYPE_SESSION, NULL, &error);
    if (!connection) {
        g_warning ("Failed to connect to the session bus: %s", error->message);
        return 1;
    }

    app_info = g_desktop_app_info_new (APP_CENTER_DESKTOP);
    data.app_name = g_app_info_get_name (G_APP_INFO (app_info));

    interface = package_kit_modify2_skeleton_new ();
    package_kit_modify2_set_display_name (interface, data.app_name);
    g_signal_connect (interface,
                      "handle-install-gstreamer-resources",
                      G_CALLBACK(handle_install_gstreamer_resources),
                      &data);

    if (!g_dbus_interface_skeleton_export (G_DBUS_INTERFACE_SKELETON (interface),
                                           connection,
                                           "/org/freedesktop/PackageKit",
                                           &error)) {
        g_warning ("Failed to register bus object: %s", error->message);
        return 1;
    }

    id = g_bus_own_name_on_connection (connection,
                                       "org.freedesktop.PackageKit",
                                       G_BUS_NAME_OWNER_FLAGS_NONE,
                                       on_bus_name_acquired,
                                       on_bus_name_lost,
                                       loop,
                                       NULL);

    g_main_loop_run (loop);

    g_bus_unown_name (id);
    return 0;
}
