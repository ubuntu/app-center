import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';

class OfflinePage extends ConsumerStatefulWidget {
  const OfflinePage({super.key});

  @override
  ConsumerState<OfflinePage> createState() => _OfflinePageState();
}

class _OfflinePageState extends ConsumerState<OfflinePage> {

  void restartApp() {
    final currentExecutableFile = Platform.resolvedExecutable;

    Process.start('bash', ['-c', currentExecutableFile]).then((Process process) {
      exit(0);
    });
  }

  @override
  Widget build(BuildContext context) {
  
    return YaruTheme(
      builder: (context, yaru, child) => MaterialApp(
        theme: yaru.theme,
        darkTheme: yaru.darkTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        home: Scaffold(
          appBar: const YaruWindowTitleBar(),
          body: Center(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 5,),
                Image.asset(
                  'assets/icons/ic_offline_512.png',
                  width: 150,
                ),
                const SizedBox(height: 20,),
                Text(
                  'No internet connection!',
                  style: TextStyle(
                    fontFamily: Theme.of(context).textTheme.displaySmall?.fontFamily,
                    fontSize: 20,
                    color: Colors.white,
                  )
                ),
                const SizedBox(height: 40,),
                ElevatedButton(
                  onPressed: () => restartApp(),
                  style: Theme.of(context).elevatedButtonTheme.style, 
                  child: const Text('Restart App'),
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}
