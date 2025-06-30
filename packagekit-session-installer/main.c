/* SPDX-License-Identifier: GPL-3.0-or-later */
/* Copyright 2025 Canonical Ltd. */

#include <gio/gio.h>
#include <gio/gdesktopappinfo.h>
#include "pk-modify2.h"

#define BUS_NAME "org.freedesktop.PackageKit"
#define APP_CENTER_DESKTOP "snap-store_snap-store.desktop"
#define APP_CENTER_BUS_NAME "io.snapcraft.Store"

#define PACKAGE_KIT_TYPE_SESSION_INSTALLER (package_kit_session_installer_get_type ())
G_DECLARE_FINAL_TYPE (PackageKitSessionInstaller, package_kit_session_installer, PACKAGE_KIT, SESSION_INSTALLER, GApplication)

struct _PackageKitSessionInstaller {
    GApplication parent;
    PackageKitModify2 *skeleton;

    GSList *gstreamer_invocations;
    guint gstreamer_installed_signal;

    guint snapcraft_store_name_lost_signal;
};
G_DEFINE_TYPE (PackageKitSessionInstaller, package_kit_session_installer, G_TYPE_APPLICATION)

static void
package_kit_session_installer_complete_gstreamer (PackageKitSessionInstaller *self);

static void
handle_snapcraft_store_name_lost (GDBusConnection *connection,
                                  const gchar     *sender_name,
                                  const gchar     *object_path,
                                  const gchar     *interface_name,
                                  const gchar     *signal_name,
                                  GVariant        *parameters,
                                  gpointer         user_data)
{
    PackageKitSessionInstaller *service = PACKAGE_KIT_SESSION_INSTALLER (user_data);

    const char *name;
    const char *old_owner;
    const char *new_owner;

    g_variant_get (parameters, "(&s&s&s)", &name, &old_owner, &new_owner);
    g_return_if_fail (g_strcmp0 (name, APP_CENTER_BUS_NAME) == 0);

    if (old_owner[0] != '\0' && new_owner[0] == '\0') {
        /* App Center has quit, possibly without completing the install requests.
         * Reply now to all pending requests.
         */
        package_kit_session_installer_complete_gstreamer (service);
    }
}

static void
handle_install_gstreamer_resources_finished (GDBusConnection *connection,
                                             const gchar     *sender_name,
                                             const gchar     *object_path,
                                             const gchar     *interface_name,
                                             const gchar     *signal_name,
                                             GVariant        *parameters,
                                             gpointer         user_data)
{
    PackageKitSessionInstaller *service = PACKAGE_KIT_SESSION_INSTALLER (user_data);

    package_kit_session_installer_complete_gstreamer (service);
}


static gboolean
handle_install_gstreamer_resources (PackageKitModify2      *interface,
                                    GDBusMethodInvocation  *invocation,
                                    char                  **arg_resources,
                                    const char             *arg_interaction,
                                    const char             *arg_desktop_id,
                                    GVariant               *arg_platform_data,
                                    gpointer                user_data)
{
    PackageKitSessionInstaller *service = PACKAGE_KIT_SESSION_INSTALLER (user_data);
    g_autoptr (GStrvBuilder) builder = g_strv_builder_new ();
    g_auto (GStrv) envp = g_get_environ ();
    g_auto (GStrv) argv = NULL;
    g_autoptr (GError) error = NULL;
    const char *sni = NULL;

    if (!arg_resources[0]) {
        package_kit_modify2_complete_install_gstreamer_resources (service->skeleton, invocation);
        return TRUE;
    }

    if (g_variant_lookup (arg_platform_data, "desktop-startup-id", "&s", &sni)) {
        envp = g_environ_setenv (envp, "STARTUP_NOTIFY_ID", sni, TRUE);
        envp = g_environ_setenv (envp, "XDG_ACTIVATION_TOKEN", sni, TRUE);
    }

    g_strv_builder_add (builder, "snap-store");
    for (int i = 0; arg_resources[i]; i++) {
        g_strv_builder_add (builder, "--gst");
        g_strv_builder_add (builder, arg_resources[i]);
    }
    argv = g_strv_builder_end (builder);

    if (!g_spawn_async (g_get_home_dir (), argv, envp,
                        G_SPAWN_SEARCH_PATH,
                        NULL, NULL, NULL, &error)) {
        g_warning ("Failed to launch App Center: %s", error->message);
        g_dbus_method_invocation_return_gerror (invocation, error);
        return TRUE;
    }

    g_application_hold (G_APPLICATION (service));
    service->gstreamer_invocations = g_slist_prepend (service->gstreamer_invocations,
                                                      g_object_ref (invocation));

    return TRUE;
}

static void
package_kit_session_installer_complete_gstreamer (PackageKitSessionInstaller *self)
{
    for (GSList *item = self->gstreamer_invocations; item; item = item->next) {
        GDBusMethodInvocation *invocation = G_DBUS_METHOD_INVOCATION (item->data);
        package_kit_modify2_complete_install_gstreamer_resources (self->skeleton, invocation);

        g_object_unref (invocation);
        g_application_release (G_APPLICATION (self));
    }
    g_slist_free (g_steal_pointer (&self->gstreamer_invocations));
}

static gboolean
package_kit_session_installer_dbus_register (GApplication     *app,
                                             GDBusConnection  *connection,
                                             const gchar      *object_path,
                                             GError          **error)
{
    GApplicationClass *parent_class = G_APPLICATION_CLASS (package_kit_session_installer_parent_class);
    PackageKitSessionInstaller *self = PACKAGE_KIT_SESSION_INSTALLER (app);
    GDBusInterfaceSkeleton *skeleton = G_DBUS_INTERFACE_SKELETON (self->skeleton);

    if (!parent_class->dbus_register (app, connection, object_path, error))
        return FALSE;

    self->gstreamer_installed_signal =
        g_dbus_connection_signal_subscribe (connection,
                                            NULL,
                                            "io.snapcraft.Store.PackageKitInstaller",
                                            "InstallationFinished",
                                            "/io/snapcraft/Store/PackageKitInstaller/GStreamer",
                                            NULL,
                                            G_DBUS_SIGNAL_FLAGS_NONE,
                                            handle_install_gstreamer_resources_finished,
                                            self,
                                            NULL);

    self->snapcraft_store_name_lost_signal =
        g_dbus_connection_signal_subscribe (connection,
                                            "org.freedesktop.DBus",
                                            "org.freedesktop.DBus",
                                            "NameOwnerChanged",
                                            "/org/freedesktop/DBus",
                                            APP_CENTER_BUS_NAME,
                                            G_DBUS_SIGNAL_FLAGS_NONE,
                                            handle_snapcraft_store_name_lost,
                                            self,
                                            NULL);

    return g_dbus_interface_skeleton_export (skeleton,
                                             connection,
                                             "/org/freedesktop/PackageKit",
                                             error);
}

static void
package_kit_session_installer_dbus_unregister (GApplication    *app,
                                               GDBusConnection *connection,
                                               const gchar     *object_path)
{
    GApplicationClass *parent_class = G_APPLICATION_CLASS (package_kit_session_installer_parent_class);
    PackageKitSessionInstaller *self = PACKAGE_KIT_SESSION_INSTALLER (app);
    GDBusInterfaceSkeleton *skeleton = G_DBUS_INTERFACE_SKELETON (self->skeleton);

    package_kit_session_installer_complete_gstreamer (self);

    if (self->gstreamer_installed_signal) {
        g_dbus_connection_signal_unsubscribe (connection, self->gstreamer_installed_signal);
        self->gstreamer_installed_signal = 0;
    }

    if (self->snapcraft_store_name_lost_signal) {
        g_dbus_connection_signal_unsubscribe (connection, self->snapcraft_store_name_lost_signal);
        self->snapcraft_store_name_lost_signal = 0;
    }

    if (g_dbus_interface_skeleton_has_connection (skeleton, connection))
        g_dbus_interface_skeleton_unexport_from_connection (skeleton, connection);

    parent_class->dbus_unregister (app, connection, object_path);
}

static void
package_kit_session_installer_dispose (GObject *object)
{
    PackageKitSessionInstaller *self = PACKAGE_KIT_SESSION_INSTALLER (object);

    g_clear_object (&self->skeleton);
    G_OBJECT_CLASS (package_kit_session_installer_parent_class)->dispose (object);
}

static void
package_kit_session_installer_class_init (PackageKitSessionInstallerClass *klass)
{
    GApplicationClass *app_class = G_APPLICATION_CLASS (klass);
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

    app_class->dbus_register = package_kit_session_installer_dbus_register;
    app_class->dbus_unregister = package_kit_session_installer_dbus_unregister;

    object_class->dispose = package_kit_session_installer_dispose;
}

static void
package_kit_session_installer_init (PackageKitSessionInstaller *self)
{
    g_autoptr (GDesktopAppInfo) app_info = NULL;
    const char *display_name;

    app_info = g_desktop_app_info_new (APP_CENTER_DESKTOP);
    display_name = g_app_info_get_name (G_APP_INFO (app_info));

    self->skeleton = package_kit_modify2_skeleton_new ();
    package_kit_modify2_set_display_name (self->skeleton, display_name);
    g_signal_connect (self->skeleton,
                      "handle-install-gstreamer-resources",
                      G_CALLBACK(handle_install_gstreamer_resources),
                      self);
}

int
main (int argc, char *argv[])
{
    g_autoptr (PackageKitSessionInstaller) service = NULL;

    service = g_object_new (PACKAGE_KIT_TYPE_SESSION_INSTALLER,
                            "application-id", BUS_NAME,
                            "flags", G_APPLICATION_IS_SERVICE,
                            NULL);
    g_application_run (G_APPLICATION (service), argc, argv);
    return 0;
}
