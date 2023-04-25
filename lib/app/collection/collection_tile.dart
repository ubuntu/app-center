import 'package:flutter/material.dart';
import 'package:software/app/common/app_icon.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

enum CollectionTilePosition {
  top,
  middle,
  bottom,
  only;
}

const _kRadius = 10.0;

const _kTopChildShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(_kRadius),
    topRight: Radius.circular(_kRadius),
  ),
);

const _kBottomChildShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(_kRadius),
    bottomRight: Radius.circular(_kRadius),
  ),
);

const _kOnlyChildShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(_kRadius),
    bottomRight: Radius.circular(_kRadius),
    topLeft: Radius.circular(_kRadius),
    topRight: Radius.circular(_kRadius),
  ),
);

RoundedRectangleBorder? createTileShape(
  CollectionTilePosition collectionTilePosition,
) {
  return collectionTilePosition == CollectionTilePosition.middle
      ? null
      : (collectionTilePosition == CollectionTilePosition.top
          ? _kTopChildShape
          : (collectionTilePosition == CollectionTilePosition.bottom
              ? _kBottomChildShape
              : _kOnlyChildShape));
}

class CollectionTile extends StatelessWidget {
  const CollectionTile({
    super.key,
    this.enabled = true,
    required this.collectionTilePosition,
    this.iconUrl,
    required this.name,
    required this.onTap,
    this.trailing,
  });

  final bool enabled;
  final CollectionTilePosition collectionTilePosition;
  final String? iconUrl;
  final String name;
  final void Function() onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: createTileShape(collectionTilePosition),
      key: key,
      enabled: enabled,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kYaruPagePadding,
        vertical: 10,
      ),
      onTap: onTap,
      leading: AppIcon(
        iconUrl: iconUrl,
        size: 25,
      ),
      title: Text(
        name,
      ),
      trailing: trailing,
    );
  }
}
