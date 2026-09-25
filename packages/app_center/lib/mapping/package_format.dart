enum PackageFormat {
  snap,
  deb;

  String get displayName => switch (this) {
    PackageFormat.snap => 'Snap',
    PackageFormat.deb => 'Debian (APT)',
  };
}
