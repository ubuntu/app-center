import 'package:app_center/gstreamer/gstreamer_resource.dart';
import 'package:app_center/packagekit/packagekit_service.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'gstreamer_model.g.dart';

@riverpod
class GstreamerModel extends _$GstreamerModel {
  @override
  Future<int?> build(
    List<GstResource> resources,
  ) async {
    final packageKit = getService<PackageKitService>();
    await packageKit.activateService();

    return null;
  }

  Future<void> installAll() async {
    final packageKit = getService<PackageKitService>();

    final providers = await Future.wait(
      resources.map((resource) => packageKit.whatProvides(resource.id)),
    );
    final packageIds = providers.flattened.map((p) => p.packageId);
    state = AsyncData(await packageKit.installAll(packageIds));
    await packageKit.waitTransaction(state.value!);
    state = AsyncData(null);
  }
}
