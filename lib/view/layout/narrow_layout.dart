import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yaru_icons/widgets/yaru_icons.dart';

class NarrowLayoutBody extends StatefulWidget {
  @override
  _NarrowLayoutBodyState createState() => _NarrowLayoutBodyState();
}

class _NarrowLayoutBodyState extends State<NarrowLayoutBody> {
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
    return Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: _views[_selectedIndex],
              ),
            ),
            BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                    icon: Icon(YaruIcons.app_grid),
                    activeIcon: Icon(YaruIcons.app_grid),
                    label: 'My Apps'),
                BottomNavigationBarItem(
                    icon: Icon(YaruIcons.search),
                    activeIcon: Icon(YaruIcons.search),
                    label: 'Search'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.update_outlined),
                    activeIcon: Icon(Icons.update),
                    label: 'Update')
              ],
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
            ),
          ],
        ),
        appBar: AppBar(
          title: Text('Ubuntu Store'),
          elevation: 1.0,
        ));
  }
}
