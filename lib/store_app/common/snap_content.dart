import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/link.dart';
import 'package:software/store_app/common/safe_image.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapContent extends StatelessWidget {
  const SnapContent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    final List<SnapMedia> media = model.media != null
        ? model.media!
            .where((snapMedia) => snapMedia.type == 'screenshot')
            .toList()
        : [];
    return SizedBox(
      width: 450,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (media.isNotEmpty)
            YaruExpandable(
              expandIcon: const Icon(YaruIcons.pan_end),
              isExpanded: true,
              header: const SizedBox(
                width: 395,
                child: Divider(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: YaruCarousel(
                  nextIcon: const Icon(YaruIcons.go_next),
                  previousIcon: const Icon(YaruIcons.go_previous),
                  navigationControls: media.length > 1,
                  viewportFraction: 1,
                  height: 250,
                  children: [
                    for (final image in media)
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => SimpleDialog(
                            children: [
                              InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                child: SafeImage(
                                  url: image.url,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.medium,
                                ),
                              )
                            ],
                          ),
                        ),
                        child: SafeImage(
                          url: image.url,
                        ),
                      )
                  ],
                ),
              ),
            ),
          const SizedBox(
            height: 10,
          ),
          if (model.contact != null && model.publisher != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (model.website != null)
                    Link(url: model.website!, linkText: context.l10n.website),
                  Link(
                    url: model.contact!,
                    linkText:
                        '${context.l10n.contact} ${model.publisher!.displayName}',
                  ),
                ],
              ),
            ),
          const SizedBox(
            height: 10,
          ),
          if (model.description != null)
            YaruExpandable(
              header: Text(
                context.l10n.description,
              ),
              expandIcon: const Icon(YaruIcons.pan_end),
              child: Text(
                model.description!,
                overflow: TextOverflow.fade,
              ),
            ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            height: 10,
          ),
        ],
      ),
    );
  }
}
