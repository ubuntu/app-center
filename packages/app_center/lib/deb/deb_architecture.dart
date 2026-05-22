/// Best-effort map from a system's native architecture to the package
/// architectures it is likely able to execute. It is used only to reject the
/// installs that are *certain* to fail (a completely foreign CPU) with a clear
/// message instead of an indefinite spinner.
///
/// The 32-bit companion entries (e.g. amd64 includes i386, arm64 includes
/// armhf) cover the common case and the only multiarch pairs Debian permits
/// side by side, but they are not guaranteed: AArch64-only cores cannot run
/// armhf, and i386 multiarch may not be enabled. Those entries therefore err
/// towards allowing the install; any residual failure is caught by the generic
/// PackageKit error handling in LocalDebModel, which clears the spinner and
/// surfaces the error.
///
/// This is intentionally static: the App Center runs inside a strictly
/// confined snap where `dpkg --print-foreign-architectures` cannot be
/// executed, so the enabled-multiarch set is not observable at runtime.
const _executableArchitectures = <String, Set<String>>{
  'amd64': {'amd64', 'i386'},
  'arm64': {'arm64', 'armhf', 'armel'},
  'armhf': {'armhf', 'armel'},
  'armel': {'armel'},
  'i386': {'i386'},
  'ppc64el': {'ppc64el'},
  's390x': {'s390x'},
  'riscv64': {'riscv64'},
};

/// Whether a `.deb` built for [packageArch] can possibly be installed on a
/// system whose native architecture is [systemArch].
///
/// Returns `true` for the architecture-independent `all`, and `true` whenever
/// either architecture is empty or unrecognized: the check only rejects
/// installs that are *certain* to fail because the CPU cannot execute the
/// code at all, and leaves every uncertain case to PackageKit.
bool isDebArchitectureCompatible({
  required String packageArch,
  required String systemArch,
}) {
  if (packageArch.isEmpty || packageArch == 'all') return true;
  final executable = _executableArchitectures[systemArch];
  if (executable == null) return true;
  return executable.contains(packageArch);
}
