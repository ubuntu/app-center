import 'package:flutter/material.dart';
import 'package:software/app/common/constants.dart';

class NoSnapsInstalledPage extends StatelessWidget {
  final String message;
  final IconData icon;

  const NoSnapsInstalledPage(
      {required this.message, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kPagePadding),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 90,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
