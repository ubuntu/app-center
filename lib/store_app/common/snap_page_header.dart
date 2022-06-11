import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/safe_image.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

class SnapPageHeader extends StatelessWidget {
  const SnapPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              height: 50,
              child: SafeImage(
                url: model.iconUrl,
                fallBackIconData: YaruIcons.package_snap,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                model.title ?? '',
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      if (model.snapIsInstalled)
                        YaruRoundIconButton(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.05),
                          tooltip: context.l10n.open,
                          onTap: () => model.open(),
                          child: Icon(
                            YaruIcons.external_link,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    model.summary ?? '',
                    style: Theme.of(context).textTheme.caption,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Column(
              children: [
                Text(
                  context.l10n.confinement,
                  style: headerStyle,
                ),
                Row(
                  children: [
                    Icon(
                      model.strict ? YaruIcons.shield : YaruIcons.warning,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      model.confinement?.name ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            if (model.license != null)
              const SizedBox(height: 50, width: 30, child: VerticalDivider()),
            if (model.license != null)
              Column(
                children: [
                  Text(context.l10n.license, style: headerStyle),
                  Text(
                    model.license!.split(' ').first,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                ],
              ),
            const SizedBox(height: 50, width: 30, child: VerticalDivider()),
            Column(
              children: [
                Text(context.l10n.installDate, style: headerStyle),
                Text(
                  model.installDate.isNotEmpty
                      ? '${model.installDate}, ${model.version}'
                      : context.l10n.notInstalled,
                  style: headerStyle.copyWith(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
