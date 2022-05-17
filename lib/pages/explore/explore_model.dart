import 'package:flutter/material.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_icons/yaru_icons.dart';

class ExploreModel extends SafeChangeNotifier {
  final SnapdClient client;

  bool _installing;
  bool get installing => _installing;
  set installing(bool value) {
    if (value == _installing) return;
    _installing = !_installing;
    notifyListeners();
  }

  bool _searchActive;
  bool get searchActive => _searchActive;
  set searchActive(bool value) {
    if (value == _searchActive) return;
    _searchActive = value;
    if (_searchActive == false) {
      snapSearch = '';
    }
    notifyListeners();
  }

  String _snapSearch;
  String get snapSearch => _snapSearch;
  set snapSearch(String value) {
    if (value == _snapSearch) return;
    _snapSearch = value;
    notifyListeners();
  }

  final List<Snap> searchedSnaps;

  final Map<SnapSection, bool> filters;

  void setFilter({required List<SnapSection> snapSections}) {
    for (var snapSection in snapSections) {
      filters[snapSection] = !filters[snapSection]!;
    }
    notifyListeners();
  }

  ExploreModel(this.client)
      : _installing = false,
        _searchActive = false,
        _snapSearch = '',
        searchedSnaps = [],
        filters = {
          SnapSection.art_and_design: false,
          SnapSection.books_and_reference: false,
          SnapSection.development: true,
          SnapSection.devices_and_iot: false,
          SnapSection.education: false,
          SnapSection.entertainment: false,
          SnapSection.featured: false,
          SnapSection.finance: false,
          SnapSection.games: false,
          SnapSection.health_and_fitness: false,
          SnapSection.music_and_audio: false,
          SnapSection.news_and_weather: false,
          SnapSection.personalisation: false,
          SnapSection.photo_and_video: false,
          SnapSection.productivity: false,
          SnapSection.science: false,
          SnapSection.security: false,
          SnapSection.server_and_cloud: false,
          SnapSection.social: false,
          SnapSection.utilities: false,
        };

  Future<List<Snap>> findSnapsBySection({String? section}) async {
    final snaps = await client.find(section: section);
    return snaps;
  }

  Future<List<Snap>> findSnapsByName() async {
    searchedSnaps.clear();
    return snapSearch.isEmpty ? [] : await client.find(name: _snapSearch);
  }

  Future<void> installSnap(Snap snap) async {
    await client.loadAuthorization();
    final changeId = await client.install([snap.name]);
    _installing = true;
    notifyListeners();
    while (true) {
      final change = await client.getChange(changeId);
      if (change.ready) {
        _installing = false;
        notifyListeners();
        break;
      }

      await Future.delayed(
        Duration(milliseconds: 100),
      );
    }
    _installing = false;
    notifyListeners();
  }
}

enum SnapSection {
  art_and_design,
  books_and_reference,
  development,
  devices_and_iot,
  education,
  entertainment,
  featured,
  finance,
  games,
  health_and_fitness,
  music_and_audio,
  news_and_weather,
  personalisation,
  photo_and_video,
  productivity,
  science,
  security,
  server_and_cloud,
  social,
  utilities;

  String title() => name.replaceAll('_', '-');
}

Map<SnapSection, IconData> snapSectionToIcon = {
  SnapSection.art_and_design: YaruIcons.colors,
  SnapSection.books_and_reference: YaruIcons.book,
  SnapSection.development: YaruIcons.wrench,
  SnapSection.devices_and_iot: YaruIcons.chip,
  SnapSection.education: YaruIcons.book,
  SnapSection.entertainment: YaruIcons.television,
  SnapSection.featured: YaruIcons.star,
  SnapSection.finance: YaruIcons.calculator,
  SnapSection.games: YaruIcons.games,
  SnapSection.health_and_fitness: YaruIcons.health,
  SnapSection.music_and_audio: YaruIcons.headphones,
  SnapSection.news_and_weather: YaruIcons.text_editor,
  SnapSection.personalisation: YaruIcons.desktop_appearance,
  SnapSection.photo_and_video: YaruIcons.camera_photo,
  SnapSection.productivity: YaruIcons.clock,
  SnapSection.science: YaruIcons.beaker,
  SnapSection.security: YaruIcons.shield,
  SnapSection.server_and_cloud: YaruIcons.computer,
  SnapSection.social: YaruIcons.users,
  SnapSection.utilities: YaruIcons.utilities,
};
