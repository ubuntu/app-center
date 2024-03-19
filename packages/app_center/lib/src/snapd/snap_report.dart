import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/src/snapd/logger.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SnapReport extends StatefulWidget {
  const SnapReport({required this.name, super.key});

  final String name;

  @override
  State<SnapReport> createState() => _SnapReportState();
}

class _SnapReportState extends State<SnapReport> {
  String? selectedReason;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final titleTextStyle = textTheme.headlineSmall!;
    final layout = ResponsiveLayout.of(context);

    return Dialog(
      child: Container(
        width: layout.cardSize.width * 2 + kCardSpacing,
        padding: const EdgeInsets.all(kCardSpacing),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.snapReportLabel(widget.name), style: titleTextStyle),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: kCardMargin),
                child: Text(l10n.snapReportSelectReportReasonLabel),
              ),
              MenuButtonBuilder(
                entries: <String>[
                  l10n.snapReportOptionCopyrightViolation,
                  l10n.snapReportOptionStoreViolation,
                ].map<MenuButtonEntry<String>>((value) {
                  return MenuButtonEntry<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                itemBuilder: (context, value, child) => Text(value),
                selected: selectedReason,
                onSelected: (value) {
                  setState(() {
                    selectedReason = value;
                  });
                },
                menuPosition: PopupMenuPosition.under,
                itemStyle: MenuItemButton.styleFrom(
                  maximumSize: const Size.fromHeight(100),
                ),
                child: Text(
                  selectedReason ?? l10n.snapReportSelectAnOptionLabel,
                ),
              ),
              const SizedBox(
                height: kPagePadding,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: kCardMargin),
                child: Text(l10n.snapReportDetailsLabel),
              ),
              SizedBox(
                height: 100,
                child: TextField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    fillColor: Theme.of(context).dividerColor,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    isDense: true,
                    hintText: l10n.snapReportDetailsHint,
                  ),
                  controller: _detailsController,
                  expands: true,
                  maxLines: null,
                ),
              ),
              const SizedBox(
                height: kPagePadding,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: kCardMargin),
                child: Text(
                  l10n.snapReportOptionalEmailAddressLabel,
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  fillColor: Theme.of(context).dividerColor,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: 'email@exemple.com',
                ),
                validator: (value) {
                  const pattern =
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                  final regex = RegExp(pattern);
                  if (!regex.hasMatch(value!)) {
                    return l10n.snapReportEnterValidEmailError;
                  } else {
                    return null;
                  }
                },
                controller: _emailController,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: kPagePadding),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: l10n.snapReportPrivacyAgreementLabel,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextSpan(
                          text: l10n
                              .snapReportPrivacyAgreementCanonicalPrivacyNotice,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await launchUrlString(
                                  'https://ubuntu.com/legal/data-privacy/contact');
                            }),
                      TextSpan(
                        text: l10n.snapReportPrivacyAgreementAndLabel,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextSpan(
                          text: l10n.snapReportPrivacyAgreementPrivacyPolicy,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await launchUrlString(
                                  'https://ubuntu.com/legal/data-privacy');
                            }),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.snapReportCancelButtonLabel),
                  ),
                  const SizedBox(width: kPagePadding),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedReason == null ||
                          _detailsController.text.isEmpty) {
                        return;
                      }

                      const url =
                          'https://docs.google.com/forms/d/e/1FAIpQLSelELZwXzvnDkx52GL7cpnQyWdc_Te6APDs843gIKRBHbh6jA/formResponse';

                      final headers = {
                        'Content-Type': 'application/x-www-form-urlencoded',
                      };
                      final requestBody = <String, String>{
                        'entry.1703677219': widget.name.toLowerCase(),
                        'entry.1193754313': selectedReason!,
                        'entry.1170971435': _detailsController.text,
                        'entry.1424146082': _emailController.text,
                      };

                      final response = await http.post(Uri.parse(url),
                          headers: headers, body: requestBody);
                      if (response.statusCode != 200) {
                        log.error(
                            'Snap reporting for snap "${widget.name}" failed with HTTP Code ${response.statusCode}');
                      }
                      if (mounted) {
                        // TODO: fix async gap
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(l10n.snapReportSubmitButtonLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
