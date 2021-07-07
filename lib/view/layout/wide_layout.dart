import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ubuntu_software_store/pages/page_items.dart';

class WideLayout extends StatefulWidget {
  final List<PageItem> pageItems;

  WideLayout({Key? key, required this.pageItems}) : super(key: key);

  @override
  _WideLayoutState createState() => _WideLayoutState();
}

class _WideLayoutState extends State<WideLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    _selectedIndex = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Ubuntu Software Store'),
        ),
        body: Row(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) =>
                    setState(() => _selectedIndex = index),
                labelType: NavigationRailLabelType.selected,
                destinations: widget.pageItems
                    .map((pageItem) => NavigationRailDestination(
                        icon: Icon(pageItem.iconData),
                        label: Text(pageItem.title)))
                    .toList(),
              ),
            ),
            VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Center(
                child: widget.pageItems[_selectedIndex].builder(context),
              ),
            )
          ],
        ),
      );
    });
  }
}
