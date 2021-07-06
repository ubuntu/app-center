import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yaru_icons/widgets/yaru_icons.dart';

class WideLayoutBody extends StatefulWidget {
  @override
  _WideLayoutBodyState createState() => _WideLayoutBodyState();
}

class _WideLayoutBodyState extends State<WideLayoutBody> {
  late int _selectedIndex;
  final List<Widget> _views = <Widget>[
    Text('My Apps'),
    Text('Search apps'),
    Text('Update')
  ];

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
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              labelType: NavigationRailLabelType.selected,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(YaruIcons.app_grid),
                  selectedIcon: Icon(YaruIcons.app_grid),
                  label: Text('My Apps'),
                ),
                NavigationRailDestination(
                  icon: Icon(YaruIcons.search),
                  selectedIcon: Icon(YaruIcons.search),
                  label: Text('Search'),
                ),
                NavigationRailDestination(
                    icon: Icon(Icons.update_outlined),
                    selectedIcon: Icon(Icons.update),
                    label: Text('Update'))
              ],
            ),
            VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Center(
                child: _views[_selectedIndex],
              ),
            )
          ],
        ),
      );
    });
  }
}
