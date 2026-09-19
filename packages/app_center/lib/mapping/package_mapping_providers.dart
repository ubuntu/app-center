import 'package:app_center/mapping/package_mapping_service.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/mapping/unified_app_identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final packageMappingServiceProvider = Provider<PackageMappingService>((ref) {
  return PackageMappingService();
});

final unifiedIdentityProvider = FutureProvider.autoDispose
    .family<UnifiedAppIdentity?, PackageSourceDescriptor>((ref, source) {
      final service = ref.watch(packageMappingServiceProvider);
      return service.resolve(source);
    });
