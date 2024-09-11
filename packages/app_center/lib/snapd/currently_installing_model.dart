import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'currently_installing_model.g.dart';

@Riverpod(keepAlive: true)
class CurrentlyInstallingModel extends _$CurrentlyInstallingModel {
  @override
  Map<String, SnapData> build() => {};

  /// Adds the snap to the currently installing list.
  void add(String snapName, SnapData snap) {
    state = {...state, snapName: snap};
    late final ProviderSubscription<AsyncValue<SnapData>> subscription;
    subscription = ref.listen(snapModelProvider(snapName), (_, snapModel) {
      if (snapModel.valueOrNull?.activeChangeId == null) {
        state = {...state}..remove(snapName);
        subscription.close();
      } else if (snapModel.hasValue && state.containsKey(snapName)) {
        state = {...state}..[snapName] = snapModel.value!;
      }
    });
  }
}
