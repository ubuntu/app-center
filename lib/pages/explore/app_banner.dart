import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';

class AppBanner extends StatelessWidget {
  const AppBanner({
    Key? key,
    required this.snap,
    this.onTap,
  }) : super(key: key);

  final Snap snap;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Align(
          alignment: Alignment.center,
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 18, right: 18),
            subtitle: Text(snap.summary),
            title: Text(snap.title),
            leading: Image.network(snap.media.first.url, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
