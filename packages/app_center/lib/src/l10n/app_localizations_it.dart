import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appCenterLabel => 'App Center';

  @override
  String get appstreamSearchGreylist => 'app;applicazione;pacchetto;programma;programmi;suite;strumento';

  @override
  String get snapPageChannelLabel => 'Canale';

  @override
  String get snapPageConfinementLabel => 'Confinamento';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Contact $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Descrizione';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Developer website';

  @override
  String get snapPageDownloadSizeLabel => 'Download size';

  @override
  String get snapPageSizeLabel => 'Size';

  @override
  String get snapPageGalleryLabel => 'Galleria';

  @override
  String get snapPageLicenseLabel => 'Licenza';

  @override
  String get snapPageLinksLabel => 'Link';

  @override
  String get snapPagePublisherLabel => 'Editore';

  @override
  String get snapPagePublishedLabel => 'Published';

  @override
  String get snapPageSummaryLabel => 'Riepilogo';

  @override
  String get snapPageVersionLabel => 'Versione';

  @override
  String get snapPageShareLinkCopiedMessage => 'Link copied to clipboard';

  @override
  String get explorePageLabel => 'Esplora';

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
  String get managePageCheckForUpdates => 'Verifica aggiornamenti';

  @override
  String get managePageCheckingForUpdates => 'Checking for updates';

  @override
  String get managePageNoInternet => 'Can\'t reach server, check your internet connection or try again later.';

  @override
  String get managePageDescription => 'Check for available updates, update your apps, and manage the status of all your apps.';

  @override
  String get managePageDebUpdatesMessage => 'Debian package updates are handled by the Software Updater.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Installed and updated';

  @override
  String get managePageLabel => 'Gestisci';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'No updates available. Your applications are all up to date.';

  @override
  String get managePageSearchFieldSearchHint => 'Cerca app installate';

  @override
  String get managePageShowDetailsLabel => 'Show details';

  @override
  String get managePageShowSystemSnapsLabel => 'Show system snaps';

  @override
  String get managePageUpdateAllLabel => 'Update all';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '$n day',
    );
    return 'Updated $_temp0 ago';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n weeks',
      one: '$n week',
    );
    return 'Updated $_temp0 ago';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n months',
      one: '$n month',
    );
    return 'Updated $_temp0 ago';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n years',
      one: '$n year',
    );
    return 'Updated $_temp0 ago';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Updates available ($n)';
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
  String get productivityPageLabel => 'Produttività';

  @override
  String get developmentPageLabel => 'Sviluppo';

  @override
  String get gamesPageLabel => 'Giochi';

  @override
  String get gamesPageTitle => 'What\'s Hot';

  @override
  String get gamesPageTop => 'Top Games';

  @override
  String get gamesPageFeatured => 'Featured Titles';

  @override
  String get gamesPageBundles => 'App Bundles';

  @override
  String get unknownPublisher => 'Unknown publisher';

  @override
  String get searchFieldDebSection => 'Pacchetti Debian';

  @override
  String get searchFieldSearchHint => 'Cerca app';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'See all results for \"$query\"';
  }

  @override
  String get searchFieldSnapSection => 'Pacchetti Snap';

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
  String get searchPageSortByLabel => 'Ordina per';

  @override
  String get searchPageRelevanceLabel => 'Relevance';

  @override
  String searchPageTitle(String query) {
    return 'Results for \"$query\"';
  }

  @override
  String get aboutPageLabel => 'Informazioni';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPageContributorTitle => 'Designed and developed by:';

  @override
  String get aboutPageCommunityTitle => 'Be part of the community:';

  @override
  String get aboutPageContributeLabel => 'Contribute or report bug';

  @override
  String get aboutPageGitHubLabel => 'Trovaci su GitHub';

  @override
  String get aboutPagePublishLabel => 'Publish to the Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Learn more';

  @override
  String get appstreamUrlTypeBugtracker => 'Bugtracker';

  @override
  String get appstreamUrlTypeContact => 'Contatto';

  @override
  String get appstreamUrlTypeContribute => 'Contribute';

  @override
  String get appstreamUrlTypeDonation => 'Donate';

  @override
  String get appstreamUrlTypeFaq => 'FAQ';

  @override
  String get appstreamUrlTypeHelp => 'Help';

  @override
  String get appstreamUrlTypeHomepage => 'Homepage';

  @override
  String get appstreamUrlTypeTranslate => 'Translations';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Source';

  @override
  String get packageFormatDebLabel => 'Pacchetti Debian';

  @override
  String get packageFormatSnapLabel => 'Pacchetti Snap';

  @override
  String get snapActionCancelLabel => 'Cancella';

  @override
  String get snapActionInstallLabel => 'Installa';

  @override
  String get snapActionInstalledLabel => 'Installed';

  @override
  String get snapActionInstallingLabel => 'Installazione';

  @override
  String get snapActionOpenLabel => 'Apri';

  @override
  String get snapActionRemoveLabel => 'Uninstall';

  @override
  String get snapActionRemovingLabel => 'Uninstalling';

  @override
  String get snapActionSwitchChannelLabel => 'Switch channel';

  @override
  String get snapActionUpdateLabel => 'Aggiornamento';

  @override
  String get snapCategoryAll => 'All categories';

  @override
  String get snapActionUpdatingLabel => 'Updating';

  @override
  String get snapCategoryArtAndDesign => 'Arte e Disegno';

  @override
  String get snapCategoryBooksAndReference => 'Libri e Riferimento';

  @override
  String get snapCategoryDefaultButtonLabel => 'Discover more';

  @override
  String get snapCategoryDevelopment => 'Sviluppo';

  @override
  String get snapCategoryDevelopmentSlogan => 'Must-have snaps for developers';

  @override
  String get snapCategoryDevicesAndIot => 'Dispositivi e IoT';

  @override
  String get snapCategoryEducation => 'Istruzione';

  @override
  String get snapCategoryEntertainment => 'Intrattenimento';

  @override
  String get snapCategoryFeatured => 'In primo piano';

  @override
  String get snapCategoryFeaturedSlogan => 'Featured Snaps';

  @override
  String get snapCategoryFinance => 'Finanza';

  @override
  String get snapCategoryGames => 'Giochi';

  @override
  String get snapCategoryGamesSlogan => 'Everything for your game night';

  @override
  String get snapCategoryGameDev => 'Game Development';

  @override
  String get snapCategoryGameDevSlogan => 'Game Development';

  @override
  String get snapCategoryGameEmulators => 'Emulators';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emulators';

  @override
  String get snapCategoryGnomeGames => 'GNOME Games';

  @override
  String get snapCategoryGnomeGamesSlogan => 'GNOME Games Suite';

  @override
  String get snapCategoryKdeGames => 'KDE Games';

  @override
  String get snapCategoryKdeGamesSlogan => 'KDE Games Suite';

  @override
  String get snapCategoryGameLaunchers => 'Game Launchers';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Game Launchers';

  @override
  String get snapCategoryGameContentCreation => 'Content Creation';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Content Creation';

  @override
  String get snapCategoryHealthAndFitness => 'Salute e Fitness';

  @override
  String get snapCategoryMusicAndAudio => 'Musica e Audio';

  @override
  String get snapCategoryNewsAndWeather => 'Notizie e Meteo';

  @override
  String get snapCategoryPersonalisation => 'Personalisation';

  @override
  String get snapCategoryPhotoAndVideo => 'Foto e Video';

  @override
  String get snapCategoryProductivity => 'Produttività';

  @override
  String get snapCategoryProductivityButtonLabel => 'Discover the productivity collection';

  @override
  String get snapCategoryProductivitySlogan => 'Cross one thing off your to-do list';

  @override
  String get snapCategoryScience => 'Scienza';

  @override
  String get snapCategorySecurity => 'Sicurezza';

  @override
  String get snapCategoryServerAndCloud => 'Server e Cloud';

  @override
  String get snapCategorySocial => 'Social';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu Desktop';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Jump start your desktop';

  @override
  String get snapCategoryUtilities => 'Utilità';

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
  String get snapRatingsBandVeryGood => 'Very good';

  @override
  String get snapRatingsBandGood => 'Good';

  @override
  String get snapRatingsBandNeutral => 'Neutral';

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
    return 'Report $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Choose a reason for reporting this snap';

  @override
  String get snapReportSelectAnOptionLabel => 'Select an option';

  @override
  String get snapReportOptionCopyrightViolation => 'Copyright or trademark violation';

  @override
  String get snapReportOptionStoreViolation => 'Snap Store terms of service violation';

  @override
  String get snapReportDetailsLabel => 'Please provide more detailed reason to your report';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Your email (optional)';

  @override
  String get snapReportCancelButtonLabel => 'Cancel';

  @override
  String get snapReportSubmitButtonLabel => 'Submit report';

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
  String get externalResourcesButtonLabel => 'Discover more';

  @override
  String get allGamesButtonLabel => 'All games';

  @override
  String get externalResourcesDisclaimer => 'Note: These are all external tools. These aren\'t owned nor distributed by Canonical.';

  @override
  String get openInBrowser => 'Open in browser';

  @override
  String get installAll => 'Install all';

  @override
  String get localDebWarningTitle => 'Potentially unsafe';

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
