project('packagekit-session-installer',
  'c',
  version: '1.0')

gnome = import('gnome')
pkg = import('pkgconfig')

glib_dep = dependency('gio-unix-2.0')

pk_sources = [
  'main.c',
]
pk_sources += gnome.gdbus_codegen(
  'pk-modify2',
  'org.freedesktop.PackageKit.Modify2.xml',
  interface_prefix: 'org.freedesktop.')

executable('packagekit-session-installer',
  pk_sources,
  dependencies: [glib_dep],
  install: true)
