import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/src/deb/local_deb_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

class LocalDebPage extends ConsumerWidget {
  const LocalDebPage({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(localDebModelProvider(path: path));
    return model.when(
      data: (debData) => ResponsiveLayoutBuilder(builder: (context) {
        return _LocalDebView(debData: debData);
      }),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
      error: (error, stackTrace) => ErrorWidget(error),
    );
  }
}

class _LocalDebView extends ConsumerWidget {
  const _LocalDebView({required this.debData});

  final LocalDebData debData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ResponsiveLayout.of(context);

    return debData.details != null
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: kPagePadding),
            child: Center(
              child: SizedBox(
                width: layout.totalWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${debData.details!.packageId.name}'),
                    Text('Summary: ${debData.details!.summary}'),
                    Text('Description: ${debData.details!.description}'),
                    Text('Group: ${debData.details!.group}'),
                    Text(
                        'Size: ${context.formatByteSize(debData.details!.size)}'),
                    Text('License: ${debData.details!.license}'),
                    Text('URL: ${debData.details!.url}'),
                    debData.activeTransactionId != null
                        ? const YaruCircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => ref
                                .read(localDebModelProvider(path: debData.path)
                                    .notifier)
                                .install(),
                            child: const Text('Install'),
                          ),
                  ],
                ),
              ),
            ),
          )
        : const Center(child: YaruCircularProgressIndicator());
  }
}
