import 'package:app_center/l10n.dart';
import 'package:flutter/material.dart';

class AdditionalDriversPage extends StatelessWidget {
  const AdditionalDriversPage({super.key});

  static String label(BuildContext context) =>
      AppLocalizations.of(context).addonsPageAdditionalDriversTitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context).addonsPageAdditionalDriversTitle,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
