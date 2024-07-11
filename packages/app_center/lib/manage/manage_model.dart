import 'package:app_center/manage/manage_snaps_data.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'manage_model.g.dart';

@Riverpod(keepAlive: true)
class ManageModel extends _$ManageModel {
  late final _snapd = getService<SnapdService>();

  @override
  Future<ManageSnapsData> build() async {
    final installedSnaps = await _snapd.getSnaps();
    final refreshableSnapNames =
        (await ref.watch(updatesModelProvider.future)).snapNames;
    return ManageSnapsData(
      installedSnaps: installedSnaps,
      refreshableSnapNames: refreshableSnapNames,
    );
  }
}
