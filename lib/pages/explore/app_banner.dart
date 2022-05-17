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
            subtitle: Text(snap.summary),
            title: Text(
              snap.title,
              style:
                  TextStyle(fontSize: MediaQuery.of(context).size.height / 25),
            ),
            leading: SizedBox(
                width: MediaQuery.of(context).size.height / 10,
                child:
                    Image.network(snap.media.first.url, fit: BoxFit.fitHeight)),
          ),
        ),
      ),
    );
  }
}
