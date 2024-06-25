import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_logger/ubuntu_logger.dart';

class ErrorObserver extends ProviderObserver {
  final log = Logger('error_observer');
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    log.error('Provider $provider failed', error);
  }
}
