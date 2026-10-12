import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_logger/ubuntu_logger.dart';

base class ErrorObserver extends ProviderObserver {
  final log = Logger('error_observer');
  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    log.error('Provider ${context.provider} failed', error);
  }
}
