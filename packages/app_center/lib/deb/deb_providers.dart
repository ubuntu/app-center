import 'package:app_center/packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'deb_providers.g.dart';

@riverpod
Stream<PackageKitTransaction> transaction(TransactionRef ref, int id) {
  final transaction = getService<PackageKitService>().getTransaction(id);
  if (transaction == null) return const Stream.empty();

  return transaction.propertiesChanged.asyncMap((_) => transaction);
}
