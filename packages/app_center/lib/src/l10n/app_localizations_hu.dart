import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appCenterLabel => 'Szoftverközpont';

  @override
  String get appstreamSearchGreylist => 'app;application;package;program;programme;suite;tool;alkalmazás;szoftver;központ;csomag';

  @override
  String get snapPageChannelLabel => 'Csatorna';

  @override
  String get snapPageConfinementLabel => 'Confinement';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Contact $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Leírás';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Fejlesztő honlapja';

  @override
  String get snapPageDownloadSizeLabel => 'Letöltési méret';

  @override
  String get snapPageSizeLabel => 'Méret';

  @override
  String get snapPageGalleryLabel => 'Képek';

  @override
  String get snapPageLicenseLabel => 'Licenc';

  @override
  String get snapPageLinksLabel => 'Hivatkozások';

  @override
  String get snapPagePublisherLabel => 'Fejlesztő';

  @override
  String get snapPagePublishedLabel => 'Kiadás dátuma';

  @override
  String get snapPageSummaryLabel => 'Summary';

  @override
  String get snapPageVersionLabel => 'Verzió';

  @override
  String get snapPageShareLinkCopiedMessage => 'Hivatkozás vágólapra másolva';

  @override
  String get explorePageLabel => 'Felfedezés';

  @override
  String get explorePageCategoriesLabel => 'Categories';

  @override
  String get managePageOwnUpdateAvailable => 'App Center update available';

  @override
  String get managePageQuitToUpdate => 'Quit to update';

  @override
  String get managePageOwnUpdateDescription => 'When you quit the application it will automatically update.';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return 'The app center will automatically update in $time.';
  }

  @override
  String get managePageOwnUpdateQuitButton => 'Quit to update';

  @override
  String get managePageCheckForUpdates => 'Frissítések keresése';

  @override
  String get managePageCheckingForUpdates => 'Frissítések keresése...';

  @override
  String get managePageNoInternet => 'Can\'t reach server, check your internet connection or try again later.';

  @override
  String get managePageDescription => 'Check for available updates, update your apps, and manage the status of all your apps.';

  @override
  String get managePageDebUpdatesMessage => 'Debian package updates are handled by the Software Updater.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Installed and updated';

  @override
  String get managePageLabel => 'Kezelés';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'No updates available. Your applications are all up to date.';

  @override
  String get managePageSearchFieldSearchHint => 'Keresés a telepített alkalmazások között';

  @override
  String get managePageShowDetailsLabel => 'Részletek megtekintése';

  @override
  String get managePageShowSystemSnapsLabel => 'Rendszer-alkalmazások is';

  @override
  String get managePageUpdateAllLabel => 'Összes frissítése';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n nappal',
      one: '$n nappal',
    );
    return '$_temp0 ezelőtt frissítve';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n héttel',
      one: '$n héttel',
    );
    return '$_temp0 ezelőtt frissítve';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n hónappal',
      one: '$n hónappal',
    );
    return '$_temp0 ezelőtt frissítve';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n évvel',
      one: '$n évvel',
    );
    return '$_temp0 ezelőtt frissítve';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Rendelkezésre álló frissítések ($n)';
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
  String get productivityPageLabel => 'Hatékonyság';

  @override
  String get developmentPageLabel => 'Fejlesztés';

  @override
  String get gamesPageLabel => 'Játékok';

  @override
  String get gamesPageTitle => 'Népszerű';

  @override
  String get gamesPageTop => 'Felkapott';

  @override
  String get gamesPageFeatured => 'Kiemelt';

  @override
  String get gamesPageBundles => 'Szoftvercsomagok';

  @override
  String get unknownPublisher => 'Unknown publisher';

  @override
  String get searchFieldDebSection => 'Debian csomagok';

  @override
  String get searchFieldSearchHint => 'Alkalmazások keresése';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'See all results for \"$query\"';
  }

  @override
  String get searchFieldSnapSection => 'Snap csomagok';

  @override
  String get searchPageFilterByLabel => 'Filter by';

  @override
  String searchPageNoResults(String query) {
    return 'No results found for \"$query\"';
  }

  @override
  String get searchPageNoResultsHint => 'Try using different or more general keywords';

  @override
  String get searchPageNoResultsCategory => 'Sorry, we couldn’t find any packages in this category';

  @override
  String get searchPageNoResultsCategoryHint => 'Try a different category or use more general keywords';

  @override
  String get searchPageSortByLabel => 'Rendezés';

  @override
  String get searchPageRelevanceLabel => 'Relevance';

  @override
  String searchPageTitle(String query) {
    return 'Results for \"$query\"';
  }

  @override
  String get aboutPageLabel => 'Névjegy';

  @override
  String aboutPageVersionLabel(String version) {
    return '$version verzió';
  }

  @override
  String get aboutPageContributorTitle => 'Közreműködtek:';

  @override
  String get aboutPageCommunityTitle => 'Csatlakozás a közösséghez:';

  @override
  String get aboutPageContributeLabel => 'Hibajegy küldése';

  @override
  String get aboutPageGitHubLabel => 'Find us on GitHub';

  @override
  String get aboutPagePublishLabel => 'Publish to the Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Learn more';

  @override
  String get appstreamUrlTypeBugtracker => 'Bugtracker';

  @override
  String get appstreamUrlTypeContact => 'Kapcsolat';

  @override
  String get appstreamUrlTypeContribute => 'Contribute';

  @override
  String get appstreamUrlTypeDonation => 'Donate';

  @override
  String get appstreamUrlTypeFaq => 'GYIK';

  @override
  String get appstreamUrlTypeHelp => 'Súgó';

  @override
  String get appstreamUrlTypeHomepage => 'Honlap';

  @override
  String get appstreamUrlTypeTranslate => 'Fordította';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Source';

  @override
  String get packageFormatDebLabel => 'Debian csomagok';

  @override
  String get packageFormatSnapLabel => 'Snap csomagok';

  @override
  String get snapActionCancelLabel => 'Mégse';

  @override
  String get snapActionInstallLabel => 'Telepítés';

  @override
  String get snapActionInstalledLabel => 'Installed';

  @override
  String get snapActionInstallingLabel => 'Telepítés...';

  @override
  String get snapActionOpenLabel => 'Megnyitás';

  @override
  String get snapActionRemoveLabel => 'Eltávolítás';

  @override
  String get snapActionRemovingLabel => 'Eltávolítás...';

  @override
  String get snapActionSwitchChannelLabel => 'Switch channel';

  @override
  String get snapActionUpdateLabel => 'Frissítés';

  @override
  String get snapCategoryAll => 'All categories';

  @override
  String get snapActionUpdatingLabel => 'Frissítés...';

  @override
  String get snapCategoryArtAndDesign => 'Művészet és Tervezés';

  @override
  String get snapCategoryBooksAndReference => 'Könyvek és Dokumentáció';

  @override
  String get snapCategoryDefaultButtonLabel => 'Felfedezés';

  @override
  String get snapCategoryDevelopment => 'Fejlesztés';

  @override
  String get snapCategoryDevelopmentSlogan => 'Ajánlott snap alkalmazások fejlesztők számára';

  @override
  String get snapCategoryDevicesAndIot => 'Eszközök és IoT';

  @override
  String get snapCategoryEducation => 'Oktatás';

  @override
  String get snapCategoryEntertainment => 'Szórakozás';

  @override
  String get snapCategoryFeatured => 'Kiemelt';

  @override
  String get snapCategoryFeaturedSlogan => 'Kiemelt snap alkalmazások';

  @override
  String get snapCategoryFinance => 'Pénzügy';

  @override
  String get snapCategoryGames => 'Játékok';

  @override
  String get snapCategoryGamesSlogan => 'Everything for your game night';

  @override
  String get snapCategoryGameDev => 'Játékfejlesztés';

  @override
  String get snapCategoryGameDevSlogan => 'Játékfejlesztés';

  @override
  String get snapCategoryGameEmulators => 'Emulátorok';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emulátorok';

  @override
  String get snapCategoryGnomeGames => 'GNOME játékok';

  @override
  String get snapCategoryGnomeGamesSlogan => 'GNOME játékcsomag';

  @override
  String get snapCategoryKdeGames => 'KDE játékok';

  @override
  String get snapCategoryKdeGamesSlogan => 'KDE játékcsomag';

  @override
  String get snapCategoryGameLaunchers => 'Game Launchers';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Game Launchers';

  @override
  String get snapCategoryGameContentCreation => 'Tartalomgyártás';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Tartalomgyártás';

  @override
  String get snapCategoryHealthAndFitness => 'Egészség és Életmód';

  @override
  String get snapCategoryMusicAndAudio => 'Zene és Hang';

  @override
  String get snapCategoryNewsAndWeather => 'Hírek és Időjárás';

  @override
  String get snapCategoryPersonalisation => 'Személyre szabás';

  @override
  String get snapCategoryPhotoAndVideo => 'Fotó és Videó';

  @override
  String get snapCategoryProductivity => 'Hatékonyság';

  @override
  String get snapCategoryProductivityButtonLabel => 'Discover the productivity collection';

  @override
  String get snapCategoryProductivitySlogan => 'Cross one thing off your to-do list';

  @override
  String get snapCategoryScience => 'Tudomány';

  @override
  String get snapCategorySecurity => 'Biztonság';

  @override
  String get snapCategoryServerAndCloud => 'Kiszolgáló és Felhő';

  @override
  String get snapCategorySocial => 'Közösségi';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu asztal';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Jump start your desktop';

  @override
  String get snapCategoryUtilities => 'Segédprogramok';

  @override
  String get snapConfinementClassic => 'Classic';

  @override
  String get snapConfinementDevmode => 'Devmode';

  @override
  String get snapConfinementStrict => 'Strict';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Alphabetical (A to Z)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Alphabetical (Z to A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Size (Smallest to largest)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Size (Largest to smallest)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Size (Smallest to largest)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Size (Largest to smallest)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Least recently updated';

  @override
  String get snapSortOrderInstalledDateDesc => 'Most recently updated';

  @override
  String get snapSortOrderRelevance => 'Relevance';

  @override
  String get snapRatingsBandVeryGood => 'Nagyon jó';

  @override
  String get snapRatingsBandGood => 'Jó';

  @override
  String get snapRatingsBandNeutral => 'Semleges';

  @override
  String get snapRatingsBandPoor => 'Poor';

  @override
  String get snapRatingsBandVeryPoor => 'Very poor';

  @override
  String get snapRatingsBandInsufficientVotes => 'Insufficient votes';

  @override
  String snapRatingsVotes(int n) {
    return '$n votes';
  }

  @override
  String snapReportLabel(String snapName) {
    return '$snapName jelentése';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Jelentés okának kiválasztása';

  @override
  String get snapReportSelectAnOptionLabel => 'Indok kiválasztása';

  @override
  String get snapReportOptionCopyrightViolation => 'Szerzői jog megsértése';

  @override
  String get snapReportOptionStoreViolation => 'Szolgáltatási feltételek megsértése';

  @override
  String get snapReportDetailsLabel => 'Please provide more detailed reason to your report';

  @override
  String get snapReportOptionalEmailAddressLabel => 'E-mail cím (nem kötelező)';

  @override
  String get snapReportCancelButtonLabel => 'Mégse';

  @override
  String get snapReportSubmitButtonLabel => 'Bejelentés küldése';

  @override
  String get snapReportEnterValidEmailError => 'Enter a valid email address';

  @override
  String get snapReportDetailsHint => 'Comment...';

  @override
  String get snapReportPrivacyAgreementLabel => 'In submitting this form, I confirm that I have read and agree to ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Canonical’s Privacy Notice ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'and ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'Privacy Policy';

  @override
  String get debPageErrorNoPackageInfo => 'No package information found';

  @override
  String get externalResources => 'Additional resources';

  @override
  String get externalResourcesButtonLabel => 'Felfedezés';

  @override
  String get allGamesButtonLabel => 'All games';

  @override
  String get externalResourcesDisclaimer => 'Note: These are all external tools. These aren\'t owned nor distributed by Canonical.';

  @override
  String get openInBrowser => 'Megnyitás böngészőben';

  @override
  String get installAll => 'Install all';

  @override
  String get localDebWarningTitle => 'Nem biztonságos';

  @override
  String get localDebWarningBody => 'This package is provided by a third party. Installing packages from outside the App Center can increase the risk to your system and personal data. Ensure you trust the source before proceeding.';

  @override
  String get localDebLearnMore => 'Learn more about third party packages';

  @override
  String get localDebDialogMessage => 'This package is provided by a third party and may threaten your system and personal data.';

  @override
  String get localDebDialogConfirmation => 'Are you sure you want to install it?';

  @override
  String snapdExceptionRunningApps(String snapName) {
    return 'We couldn\'t update $snapName because it is currently running.';
  }

  @override
  String get errorViewCheckStatusLabel => 'Check status';

  @override
  String get errorViewNetworkErrorTitle => 'Connect to internet';

  @override
  String get errorViewNetworkErrorDescription => 'We can\'t load content in the App Center without an internet connection.';

  @override
  String get errorViewNetworkErrorAction => 'Check your connection and retry.';

  @override
  String get errorViewServerErrorDescription => 'We\'re sorry, we are currently experiencing problems with the App Center.';

  @override
  String get errorViewServerErrorAction => 'Check the status for updates or try again later.';

  @override
  String get errorViewUnknownErrorTitle => 'Something went wrong';

  @override
  String get errorViewUnknownErrorDescription => 'We\'re sorry, but we’re not sure what the error is.';

  @override
  String get errorViewUnknownErrorAction => 'You can retry now, check the status for updates, or try again later.';
}
