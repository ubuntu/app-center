import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appCenterLabel => 'App Center';

  @override
  String get appstreamSearchGreylist => 'Anwenderprogramm;Anwenderprogramme;Anwendung;Anwendungen;Anwendungsprogramm;Anwendungsprogramme;Anwendungssoftware;App;Apps;Applikation;Applikationen;Berechnungsprogramm;Berechnungsprogramme;Computerprogramm;Computerprogramme;Paket;Pakete;Programm;Programme;Software';

  @override
  String get snapPageChannelLabel => 'Kanal';

  @override
  String get snapPageConfinementLabel => 'Einschränkung';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Kontakt $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Beschreibung';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Entwickler-Webseite';

  @override
  String get snapPageDownloadSizeLabel => 'Downloadgröße';

  @override
  String get snapPageSizeLabel => 'Größe';

  @override
  String get snapPageGalleryLabel => 'Galerie';

  @override
  String get snapPageLicenseLabel => 'Lizenz';

  @override
  String get snapPageLinksLabel => 'Links';

  @override
  String get snapPagePublisherLabel => 'Herausgeber';

  @override
  String get snapPagePublishedLabel => 'Veröffentlicht';

  @override
  String get snapPageSummaryLabel => 'Zusammenfassung';

  @override
  String get snapPageVersionLabel => 'Version';

  @override
  String get snapPageShareLinkCopiedMessage => 'Link in die Zwischenablage kopiert';

  @override
  String get explorePageLabel => 'Entdecken';

  @override
  String get explorePageCategoriesLabel => 'Kategorien';

  @override
  String get managePageOwnUpdateAvailable => 'App Center-Aktualisierung verfügbar';

  @override
  String get managePageQuitToUpdate => 'Beenden, um zu aktualisieren';

  @override
  String get managePageOwnUpdateDescription => 'Wenn Sie die Anwendung beenden, wird sie automatisch aktualisiert.';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return 'Das App Center wird automatisch in $time aktualisiert.';
  }

  @override
  String get managePageOwnUpdateQuitButton => 'Zum Aktualisieren beenden';

  @override
  String get managePageCheckForUpdates => 'Auf Aktualisierungen prüfen';

  @override
  String get managePageCheckingForUpdates => 'Prüfe auf updates';

  @override
  String get managePageNoInternet => 'Der Server kann nicht erreicht werden, überprüfen Sie Ihre Internetverbindung oder versuchen Sie es später noch einmal.';

  @override
  String get managePageDescription => 'Auf verfügbare Aktualisierungen prüfen, Ihre Apps aktualisieren und den Status aller Ihrer Apps verwalten.';

  @override
  String get managePageDebUpdatesMessage => 'Debian-Paketaktualisierungen werden von der Softwareaktualisierung durchgeführt.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Installiert und aktualisiert';

  @override
  String get managePageLabel => 'Installierte Snaps verwalten';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Keine Aktualisierungen verfügbar. Ihre Anwendungen sind alle auf dem neuesten Stand.';

  @override
  String get managePageSearchFieldSearchHint => 'Durchsuchen Sie Ihre installierten Apps';

  @override
  String get managePageShowDetailsLabel => 'Details anzeigen';

  @override
  String get managePageShowSystemSnapsLabel => 'System-Snaps anzeigen';

  @override
  String get managePageUpdateAllLabel => 'Alle aktualisieren';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Tagen',
      one: '$n Tag',
    );
    return 'Aktualisiert vor $_temp0';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Wochen',
      one: '$n Woche',
    );
    return 'Vor $_temp0 aktualisiert';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Monaten',
      one: '$n Monat',
    );
    return 'Vor $_temp0 aktualisiert';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Jahren',
      one: '$n Jahr',
    );
    return 'Vor $_temp0 aktualisiert';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Aktualisierungen verfügbar ($n)';
  }

  @override
  String managePageUpdatesFailed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n updates',
      one: 'One update',
    );
    return '$_temp0 failed';
  }

  @override
  String managePageUpdatesFailedBody(Object snapList) {
    return 'We couldn\'t update these applications because they are currently running.\n\n$snapList\nWhen you quit the applications, they will automatically update.';
  }

  @override
  String get productivityPageLabel => 'Produktivität';

  @override
  String get developmentPageLabel => 'Entwicklung';

  @override
  String get gamesPageLabel => 'Spiele';

  @override
  String get gamesPageTitle => 'Was ist angesagt';

  @override
  String get gamesPageTop => 'Top-Spiele';

  @override
  String get gamesPageFeatured => 'Ausgewählte Titel';

  @override
  String get gamesPageBundles => 'App-Bundles';

  @override
  String get unknownPublisher => 'Unbekannter Herausgeber';

  @override
  String get searchFieldDebSection => 'Debian-Pakete';

  @override
  String get searchFieldSearchHint => 'Nach Apps suchen';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Alle Ergebnisse für „$query“ anzeigen';
  }

  @override
  String get searchFieldSnapSection => 'Snap-Pakete';

  @override
  String get searchPageFilterByLabel => 'Filtern nach';

  @override
  String searchPageNoResults(String query) {
    return 'Keine Ergebnisse für „$query“ gefunden';
  }

  @override
  String get searchPageNoResultsHint => 'Versuchen Sie es mit anderen oder allgemeineren Schlüsselwörtern';

  @override
  String get searchPageNoResultsCategory => 'Leider konnten wir keine Pakete in dieser Kategorie finden';

  @override
  String get searchPageNoResultsCategoryHint => 'Versuchen Sie eine andere Kategorie oder verwenden Sie allgemeinere Schlüsselwörter';

  @override
  String get searchPageSortByLabel => 'Sortierung';

  @override
  String get searchPageRelevanceLabel => 'Relevanz';

  @override
  String searchPageTitle(String query) {
    return 'Ergebnisse für „$query“';
  }

  @override
  String get aboutPageLabel => 'Über';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPageContributorTitle => 'Entworfen und entwickelt von:';

  @override
  String get aboutPageCommunityTitle => 'Seien Sie Teil der Gemeinschaft:';

  @override
  String get aboutPageContributeLabel => 'Beitragen oder Fehler melden';

  @override
  String get aboutPageGitHubLabel => 'Finde uns auf GitHub';

  @override
  String get aboutPagePublishLabel => 'Im Snap Store veröffentlichen';

  @override
  String get aboutPageLearnMoreLabel => 'Mehr erfahren';

  @override
  String get appstreamUrlTypeBugtracker => 'Bugtracker';

  @override
  String get appstreamUrlTypeContact => 'Kontakt';

  @override
  String get appstreamUrlTypeContribute => 'Beitragen';

  @override
  String get appstreamUrlTypeDonation => 'Spenden';

  @override
  String get appstreamUrlTypeFaq => 'FAQ';

  @override
  String get appstreamUrlTypeHelp => 'Hilfe';

  @override
  String get appstreamUrlTypeHomepage => 'Homepage';

  @override
  String get appstreamUrlTypeTranslate => 'Übersetzungen';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Quelle';

  @override
  String get packageFormatDebLabel => 'Debian-Pakete';

  @override
  String get packageFormatSnapLabel => 'Snap-Pakete';

  @override
  String get snapActionCancelLabel => 'Abbrechen';

  @override
  String get snapActionInstallLabel => 'Installieren';

  @override
  String get snapActionInstalledLabel => 'Installiert';

  @override
  String get snapActionInstallingLabel => 'Wird installiert';

  @override
  String get snapActionOpenLabel => 'Öffnen';

  @override
  String get snapActionRemoveLabel => 'Deinstallieren';

  @override
  String get snapActionRemovingLabel => 'Wird deinstalliert';

  @override
  String get snapActionSwitchChannelLabel => 'Kanal wechseln';

  @override
  String get snapActionUpdateLabel => 'Aktualisieren';

  @override
  String get snapCategoryAll => 'Alle Kategorien';

  @override
  String get snapActionUpdatingLabel => 'Wird aktualisiert';

  @override
  String get snapCategoryArtAndDesign => 'Kunst und Design';

  @override
  String get snapCategoryBooksAndReference => 'Bücher und Referenzen';

  @override
  String get snapCategoryDefaultButtonLabel => 'Mehr entdecken';

  @override
  String get snapCategoryDevelopment => 'Entwicklung';

  @override
  String get snapCategoryDevelopmentSlogan => 'Unverzichtbare Snaps für Entwickler';

  @override
  String get snapCategoryDevicesAndIot => 'Geräte und IoT';

  @override
  String get snapCategoryEducation => 'Bildung';

  @override
  String get snapCategoryEntertainment => 'Unterhaltung';

  @override
  String get snapCategoryFeatured => 'Vorgestellt';

  @override
  String get snapCategoryFeaturedSlogan => 'Ausgewählte Snaps';

  @override
  String get snapCategoryFinance => 'Finanzen';

  @override
  String get snapCategoryGames => 'Spiele';

  @override
  String get snapCategoryGamesSlogan => 'Alles für Ihren Spieleabend';

  @override
  String get snapCategoryGameDev => 'Spieleentwicklung';

  @override
  String get snapCategoryGameDevSlogan => 'Spieleentwicklung';

  @override
  String get snapCategoryGameEmulators => 'Emulatoren';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emulatoren';

  @override
  String get snapCategoryGnomeGames => 'GNOME-Spiele';

  @override
  String get snapCategoryGnomeGamesSlogan => 'GNOME-Spielesuite';

  @override
  String get snapCategoryKdeGames => 'KDE-Spiele';

  @override
  String get snapCategoryKdeGamesSlogan => 'KDE-Spielesuite';

  @override
  String get snapCategoryGameLaunchers => 'Game-Launchers';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Game-Launchers';

  @override
  String get snapCategoryGameContentCreation => 'Content-Erstellung';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Content-Erstellung';

  @override
  String get snapCategoryHealthAndFitness => 'Gesundheit und Fitness';

  @override
  String get snapCategoryMusicAndAudio => 'Musik und Audio';

  @override
  String get snapCategoryNewsAndWeather => 'Nachrichten und Wetter';

  @override
  String get snapCategoryPersonalisation => 'Personalisierung';

  @override
  String get snapCategoryPhotoAndVideo => 'Foto und Video';

  @override
  String get snapCategoryProductivity => 'Produktivität';

  @override
  String get snapCategoryProductivityButtonLabel => 'Entdecken Sie die Produktivitätssammlung';

  @override
  String get snapCategoryProductivitySlogan => 'Streichen Sie eine Sache von Ihrer Aufgabenliste';

  @override
  String get snapCategoryScience => 'Wissenschaft';

  @override
  String get snapCategorySecurity => 'Sicherheit';

  @override
  String get snapCategoryServerAndCloud => 'Server und Cloud';

  @override
  String get snapCategorySocial => 'Kontakte';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu Desktop';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Starthilfe für Ihren Desktop';

  @override
  String get snapCategoryUtilities => 'Nützliches';

  @override
  String get snapConfinementClassic => 'Klassisch';

  @override
  String get snapConfinementDevmode => 'Entwicklermodus';

  @override
  String get snapConfinementStrict => 'Streng';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Alphabetisch (A bis Z)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Alphabetisch (Z bis A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Größe (von klein bis groß)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Größe (von groß bis klein)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Größe (von klein bis groß)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Größe (von groß bis klein)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Am wenigsten kürzlich aktualisiert';

  @override
  String get snapSortOrderInstalledDateDesc => 'Am häufigsten kürzlich aktualisiert';

  @override
  String get snapSortOrderRelevance => 'Relevanz';

  @override
  String get snapRatingsBandVeryGood => 'Sehr gut';

  @override
  String get snapRatingsBandGood => 'Gut';

  @override
  String get snapRatingsBandNeutral => 'Neutral';

  @override
  String get snapRatingsBandPoor => 'Schlecht';

  @override
  String get snapRatingsBandVeryPoor => 'Sehr schlecht';

  @override
  String get snapRatingsBandInsufficientVotes => 'Unzureichende Stimmenzahl';

  @override
  String snapRatingsVotes(int n) {
    return '$n Stimmen';
  }

  @override
  String snapReportLabel(String snapName) {
    return '$snapName melden';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Einen Grund für die Meldung dieses Snaps wählen';

  @override
  String get snapReportSelectAnOptionLabel => 'Wählen Sie eine Option';

  @override
  String get snapReportOptionCopyrightViolation => 'Urheberrechts- oder Markenrechtsverletzung';

  @override
  String get snapReportOptionStoreViolation => 'Verstoß gegen die Nutzungsbedingungen des Snap Store';

  @override
  String get snapReportDetailsLabel => 'Bitte begründen Sie Ihre Meldung ausführlicher';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Ihre E-Mail (optional)';

  @override
  String get snapReportCancelButtonLabel => 'Abbrechen';

  @override
  String get snapReportSubmitButtonLabel => 'Meldung einreichen';

  @override
  String get snapReportEnterValidEmailError => 'Gültige E-Mail-Adresse eingeben';

  @override
  String get snapReportDetailsHint => 'Kommentar ...';

  @override
  String get snapReportPrivacyAgreementLabel => 'Mit dem Absenden dieses Formulars bestätige ich, dass ich gelesen habe und zustimme zu ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Datenschutzerklärung von Canonical ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'und ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get debPageErrorNoPackageInfo => 'Keine Paket-Informationen gefunden';

  @override
  String get externalResources => 'Zusätzliche Ressourcen';

  @override
  String get externalResourcesButtonLabel => 'Mehr entdecken';

  @override
  String get allGamesButtonLabel => 'Alle Spiele';

  @override
  String get externalResourcesDisclaimer => 'Anmerkung: Dies sind alles externe Werkzeuge. Sie sind weder Eigentum von, noch vertrieben von Canonical.';

  @override
  String get openInBrowser => 'Im Browser öffnen';

  @override
  String get installAll => 'Alle installieren';

  @override
  String get localDebWarningTitle => 'Möglicherweise unsicher';

  @override
  String get localDebWarningBody => 'Dieses Paket wird von einem Drittanbieter bereitgestellt. Die Installation von Paketen von außerhalb des App Centers kann das Risiko für Ihr System und Ihre persönlichen Daten erhöhen. Stellen Sie sicher, dass Sie der Quelle vertrauen, bevor Sie fortfahren.';

  @override
  String get localDebLearnMore => 'Mehr über Pakete von Drittanbietern erfahren';

  @override
  String get localDebDialogMessage => 'Dieses Paket wird von einem Drittanbieter bereitgestellt und kann Ihr System und Ihre persönlichen Daten gefährden.';

  @override
  String get localDebDialogConfirmation => 'Sind Sie sicher, dass Sie es installieren möchten?';

  @override
  String snapdExceptionRunningApps(String snapName) {
    return 'Wir konnten $snapName nicht aktualisieren, da es gerade ausgeführt wird.';
  }

  @override
  String get errorViewCheckStatusLabel => 'Status überprüfen';

  @override
  String get errorViewNetworkErrorTitle => 'Mit dem Internet verbinden';

  @override
  String get errorViewNetworkErrorDescription => 'Ohne Internetverbindung können wir keine Inhalte in das App Center laden.';

  @override
  String get errorViewNetworkErrorAction => 'Überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get errorViewServerErrorDescription => 'Es tut uns leid, wir haben derzeit Probleme mit dem App Center.';

  @override
  String get errorViewServerErrorAction => 'Überprüfen Sie den Status auf Aktualisierungen oder versuchen Sie es später erneut.';

  @override
  String get errorViewUnknownErrorTitle => 'Etwas ist schiefgelaufen';

  @override
  String get errorViewUnknownErrorDescription => 'Es tut uns leid, aber wir sind uns nicht sicher, wo der Fehler liegt.';

  @override
  String get errorViewUnknownErrorAction => 'Sie können es jetzt erneut versuchen, den Status auf Aktualisierungen hin überprüfen oder es später erneut versuchen.';
}
