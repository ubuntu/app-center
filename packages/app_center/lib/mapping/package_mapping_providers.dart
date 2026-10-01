import 'package:app_center/mapping/package_mapping_service.dart';
import 'package:app_center/mapping/package_runtime_state.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/mapping/unified_app_identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

final unifiedIdentityProvider = FutureProvider.autoDispose
    .family<UnifiedAppIdentity?, PackageSourceDescriptor>(
      (ref, source) => getService<PackageMappingService>().resolve(source),
    );

final runtimeStateProvider = FutureProvider.autoDispose
    .family<Map<PackageFormat, PackageRuntimeState>, UnifiedAppIdentity>(
      (ref, identity) =>
          getService<PackageRuntimeStateService>().getIdentityState(identity),
    );
