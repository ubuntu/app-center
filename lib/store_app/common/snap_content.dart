import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/link.dart';
import 'package:software/store_app/common/safe_image.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapContent extends StatelessWidget {
  const SnapContent({
    Key? key,
    required this.media,
    required this.contact,
    required this.publisherName,
    required this.website,
    required this.description,
  }) : super(key: key);

  final List<String> media;
  final String contact;
  final String publisherName;
  final String website;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (media.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: YaruCarousel(
              nextIcon: const Icon(YaruIcons.go_next),
              previousIcon: const Icon(YaruIcons.go_previous),
              navigationControls: media.length > 1,
              viewportFraction: 1,
              height: 250,
              children: [
                for (final url in media)
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: SafeImage(
                              url: url,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.medium,
                            ),
                          )
                        ],
                      ),
                    ),
                    child: SafeImage(
                      url: url,
                    ),
                  )
              ],
            ),
          ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Link(url: website, linkText: context.l10n.website),
              Link(
                url: contact,
                linkText: '${context.l10n.contact} $publisherName',
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        YaruExpandable(
          header: Text(
            context.l10n.description,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          expandIcon: const Icon(YaruIcons.pan_end),
          child: Text(
            description,
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
    );
  }
}
