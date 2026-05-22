/// Thrown when a local `.deb` file is built for a CPU architecture the
/// system cannot execute. Surfaced to the UI so the user gets an explicit
/// error instead of an indefinite spinner from a failing PackageKit
/// transaction.
class DebArchitectureMismatchException implements Exception {
  const DebArchitectureMismatchException({
    required this.packageArch,
    required this.systemArch,
  });

  final String packageArch;
  final String systemArch;

  @override
  String toString() => 'DebArchitectureMismatchException: '
      'package is $packageArch, system is $systemArch';
}
