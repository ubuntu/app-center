import 'package:flutter/material.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_icons/yaru_icons.dart';

class ExploreModel extends SafeChangeNotifier {
  final SnapdClient client;

  bool installing;

  String snapSearch = '';

  List<Snap> searchedSnaps = [];

  Map<SnapSection, bool> filters = {
    SnapSection.art_and_design: false,
    SnapSection.books_and_reference: false,
    SnapSection.development: false,
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

  void setFilter({required List<SnapSection> snapSections}) {
    for (var snapSection in snapSections) {
      filters[snapSection] = !filters[snapSection]!;
    }
    notifyListeners();
  }

  ExploreModel(this.client) : installing = false;

  Future<List<Snap>> findSnapsBySection({String? section}) async {
    final snaps = await client.find(section: section);
    return snaps;
  }

  void findSnapsByName() async {
    searchedSnaps.clear();
    if (snapSearch.isEmpty) return;
    final snaps = await client.find(name: snapSearch);
    searchedSnaps.addAll(snaps);
    notifyListeners();
  }

  Future<void> installSnap(Snap snap) async {
    await client.loadAuthorization();
    final changeId = await client.install([snap.name]);
    installing = true;
    notifyListeners();
    while (true) {
      final change = await client.getChange(changeId);
      if (change.ready) {
        installing = false;
        notifyListeners();
        break;
      }

      await Future.delayed(
        Duration(milliseconds: 100),
      );
    }
    installing = false;
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

const sections = <String, String>{
  'art-and-design': 'art-and-design',
  'books-and-reference': 'books-and-reference',
  'development': 'development',
  'devices-and-iot': 'devices-and-iot',
  'education': 'education',
  'entertainment': 'entertainment',
  'featured': 'featured',
  'finance': 'finance',
  'games': 'games',
  'health-and-fitness': 'health-and-fitness',
  'music-and-audio': 'music-and-audio',
  'news-and-weather': 'news-and-weather',
  'personalisation': 'personalisation',
  'photo-and-video': 'photo-and-video',
  'productivity': 'productivity',
  'science': 'science',
  'security': 'security',
  'server-and-cloud': 'server-and-cloud',
  'social': 'social',
  'utilities': 'utilities',
};
