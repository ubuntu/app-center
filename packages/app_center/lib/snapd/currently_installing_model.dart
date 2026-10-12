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
      if (snapModel.value?.activeChangeId == null) {
        remove(snapName);
        subscription.close();
      } else if (snapModel.hasValue && state.containsKey(snapName)) {
        state = {...state}..[snapName] = snapModel.value!;
      }
    });
  }

  /// Removes the snap from the currently installing list.
  void remove(String snapName) {
    // No-op when absent: the snap model listener can fire inside another
    // provider's build, where state must not change.
    if (!state.containsKey(snapName)) return;
    state = {...state}..remove(snapName);
  }
}
