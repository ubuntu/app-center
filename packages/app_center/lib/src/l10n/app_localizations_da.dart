import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appCenterLabel => 'Appcenter';

  @override
  String get appstreamSearchGreylist => 'app;applikation;pakke;program;værktøj;tilbehør;plugin';

  @override
  String get snapPageChannelLabel => 'Kanal';

  @override
  String get snapPageConfinementLabel => 'Forvaring';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Kontakt $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Beskrivelse';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Udviklerwebsted';

  @override
  String get snapPageDownloadSizeLabel => 'Downloadstørrelse';

  @override
  String get snapPageSizeLabel => 'Size';

  @override
  String get snapPageGalleryLabel => 'Galleri';

  @override
  String get snapPageLicenseLabel => 'Licens';

  @override
  String get snapPageLinksLabel => 'Link';

  @override
  String get snapPagePublisherLabel => 'Udgiver';

  @override
  String get snapPagePublishedLabel => 'Udgivet';

  @override
  String get snapPageSummaryLabel => 'Opsummering';

  @override
  String get snapPageVersionLabel => 'Udgave';

  @override
  String get snapPageShareLinkCopiedMessage => 'Link kopieret til udklipsholder';

  @override
  String get explorePageLabel => 'Udforsk';

  @override
  String get explorePageCategoriesLabel => 'Kategorier';

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
  String get managePageCheckForUpdates => 'Kontrollér for opdateringer';

  @override
  String get managePageCheckingForUpdates => 'Kontrollerer, om der er opdateringer';

  @override
  String get managePageNoInternet => 'Can\'t reach server, check your internet connection or try again later.';

  @override
  String get managePageDescription => 'Kontrollér om der er opdateringer, opdatér dine programmer, og håndtér status for alle dine programmer.';

  @override
  String get managePageDebUpdatesMessage => 'Debian package updates are handled by the Software Updater.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Installeret og opdateret';

  @override
  String get managePageLabel => 'Administrér';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Der er ingen tilgængelige opdateringer. Alle dine programmer er opdateret.';

  @override
  String get managePageSearchFieldSearchHint => 'Søg i dine installerede programmer';

  @override
  String get managePageShowDetailsLabel => 'Vis detaljer';

  @override
  String get managePageShowSystemSnapsLabel => 'Vis systemsnapper';

  @override
  String get managePageUpdateAllLabel => 'Opdatér alle';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dage',
      one: '$n dag',
    );
    return 'Opdateret for $_temp0 siden';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n uger',
      one: '$n uge',
    );
    return 'Opdateret for $_temp0 siden';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n måneder',
      one: '$n måned',
    );
    return 'Opdateret for $_temp0 siden';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n år',
      one: '$n år',
    );
    return 'Opdateret for $_temp0 siden';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Opdateringer er tilgængelige ($n)';
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
  String get productivityPageLabel => 'Produktivitet';

  @override
  String get developmentPageLabel => 'Udvikling';

  @override
  String get gamesPageLabel => 'Spil';

  @override
  String get gamesPageTitle => 'Populære';

  @override
  String get gamesPageTop => 'Populære spil';

  @override
  String get gamesPageFeatured => 'Fremhævede titler';

  @override
  String get gamesPageBundles => 'Programpakker';

  @override
  String get unknownPublisher => 'Ukendt udgiver';

  @override
  String get searchFieldDebSection => 'Debian-pakker';

  @override
  String get searchFieldSearchHint => 'Søg efter programmer';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Vis alle resultater for “$query”';
  }

  @override
  String get searchFieldSnapSection => 'Snap-pakker';

  @override
  String get searchPageFilterByLabel => 'Filtrér efter';

  @override
  String searchPageNoResults(String query) {
    return 'Ingen resultater for “$query”';
  }

  @override
  String get searchPageNoResultsHint => 'Prøv at bruge andre eller mere generelle nøgleord';

  @override
  String get searchPageNoResultsCategory => 'Beklager, vi kunne ikke finde nogen pakker i denne kategori';

  @override
  String get searchPageNoResultsCategoryHint => 'Prøv en anden kategori eller brug mere generelle nøgleord';

  @override
  String get searchPageSortByLabel => 'Sortér efter';

  @override
  String get searchPageRelevanceLabel => 'Relevans';

  @override
  String searchPageTitle(String query) {
    return 'Resultater for “$query”';
  }

  @override
  String get aboutPageLabel => 'Om';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPageContributorTitle => 'Designet og udviklet af:';

  @override
  String get aboutPageCommunityTitle => 'Deltag i fællesskabet:';

  @override
  String get aboutPageContributeLabel => 'Bidrag eller rapportér fejl';

  @override
  String get aboutPageGitHubLabel => 'Find os på GitHub';

  @override
  String get aboutPagePublishLabel => 'Udgiv i Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Mere info';

  @override
  String get appstreamUrlTypeBugtracker => 'Fejlrapportering';

  @override
  String get appstreamUrlTypeContact => 'Kontakt';

  @override
  String get appstreamUrlTypeContribute => 'Contribute';

  @override
  String get appstreamUrlTypeDonation => 'Donér';

  @override
  String get appstreamUrlTypeFaq => 'OSS';

  @override
  String get appstreamUrlTypeHelp => 'Hjælp';

  @override
  String get appstreamUrlTypeHomepage => 'Hjemmeside';

  @override
  String get appstreamUrlTypeTranslate => 'Oversættelser';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Source';

  @override
  String get packageFormatDebLabel => 'Debian-pakker';

  @override
  String get packageFormatSnapLabel => 'Snap-pakker';

  @override
  String get snapActionCancelLabel => 'Annullér';

  @override
  String get snapActionInstallLabel => 'Installér';

  @override
  String get snapActionInstalledLabel => 'Installed';

  @override
  String get snapActionInstallingLabel => 'Installerer';

  @override
  String get snapActionOpenLabel => 'Åbn';

  @override
  String get snapActionRemoveLabel => 'Afinstallér';

  @override
  String get snapActionRemovingLabel => 'Afinstallerer';

  @override
  String get snapActionSwitchChannelLabel => 'Skift kanal';

  @override
  String get snapActionUpdateLabel => 'Opdatér';

  @override
  String get snapCategoryAll => 'Alle kategorier';

  @override
  String get snapActionUpdatingLabel => 'Opdaterer';

  @override
  String get snapCategoryArtAndDesign => 'Kunst og design';

  @override
  String get snapCategoryBooksAndReference => 'Bøger og reference';

  @override
  String get snapCategoryDefaultButtonLabel => 'Gå på opdagelse';

  @override
  String get snapCategoryDevelopment => 'Udvikling';

  @override
  String get snapCategoryDevelopmentSlogan => 'Essentielle snapper til udviklere';

  @override
  String get snapCategoryDevicesAndIot => 'Enheder og IoT';

  @override
  String get snapCategoryEducation => 'Uddannelse';

  @override
  String get snapCategoryEntertainment => 'Underholdning';

  @override
  String get snapCategoryFeatured => 'Udvalgte';

  @override
  String get snapCategoryFeaturedSlogan => 'Udvalgte snapper';

  @override
  String get snapCategoryFinance => 'Finans';

  @override
  String get snapCategoryGames => 'Spil';

  @override
  String get snapCategoryGamesSlogan => 'Alt til din spilaften';

  @override
  String get snapCategoryGameDev => 'Spiludvikling';

  @override
  String get snapCategoryGameDevSlogan => 'Spiludvikling';

  @override
  String get snapCategoryGameEmulators => 'Emulatorer';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emulatorer';

  @override
  String get snapCategoryGnomeGames => 'GNOME-spil';

  @override
  String get snapCategoryGnomeGamesSlogan => 'GNOME-spilsamling';

  @override
  String get snapCategoryKdeGames => 'KDE-spil';

  @override
  String get snapCategoryKdeGamesSlogan => 'KDE-spilsamling';

  @override
  String get snapCategoryGameLaunchers => 'Spilstartere';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Spilstartere';

  @override
  String get snapCategoryGameContentCreation => 'Kreativitet';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Kreativitet';

  @override
  String get snapCategoryHealthAndFitness => 'Helse og form';

  @override
  String get snapCategoryMusicAndAudio => 'Musik og lyd';

  @override
  String get snapCategoryNewsAndWeather => 'Nyheder og vejr';

  @override
  String get snapCategoryPersonalisation => 'Brugertilpasning';

  @override
  String get snapCategoryPhotoAndVideo => 'Foto og video';

  @override
  String get snapCategoryProductivity => 'Produktivitet';

  @override
  String get snapCategoryProductivityButtonLabel => 'På opdagelse i produktivitetssamlingen';

  @override
  String get snapCategoryProductivitySlogan => 'Sæt hak ved en ting på din to-do-liste';

  @override
  String get snapCategoryScience => 'Videnskab';

  @override
  String get snapCategorySecurity => 'Sikkerhed';

  @override
  String get snapCategoryServerAndCloud => 'Server og sky';

  @override
  String get snapCategorySocial => 'Socialt';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu-skrivebord';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Aktivér dit skrivebord';

  @override
  String get snapCategoryUtilities => 'Værktøjer';

  @override
  String get snapConfinementClassic => 'Klassisk';

  @override
  String get snapConfinementDevmode => 'Udviklertilstand';

  @override
  String get snapConfinementStrict => 'Begrænset';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Alfabetisk (A til Z)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Alfabetisk (Z til A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Størrelse (mindste til største)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Størrelse (største til mindste)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Størrelse (mindste til største)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Størrelse (største til mindste)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Opdateret for længst tid siden';

  @override
  String get snapSortOrderInstalledDateDesc => 'Senest opdateret';

  @override
  String get snapSortOrderRelevance => 'Relevans';

  @override
  String get snapRatingsBandVeryGood => 'Meget god';

  @override
  String get snapRatingsBandGood => 'God';

  @override
  String get snapRatingsBandNeutral => 'Neutral';

  @override
  String get snapRatingsBandPoor => 'Dårlig';

  @override
  String get snapRatingsBandVeryPoor => 'Meget dårlig';

  @override
  String get snapRatingsBandInsufficientVotes => 'Ikke nok stemmer';

  @override
  String snapRatingsVotes(int n) {
    return '$n stemmer';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Rapportér $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Vælg en årsag til, at du rapporterer denne snap';

  @override
  String get snapReportSelectAnOptionLabel => 'Vælg en mulighed';

  @override
  String get snapReportOptionCopyrightViolation => 'Brud på ophavsret eller varemærke';

  @override
  String get snapReportOptionStoreViolation => 'Brud på Snap Stores brugsbetingelser';

  @override
  String get snapReportDetailsLabel => 'Angiv venligst en mere uddybende begrundelse for din rapport';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Din e-postadresse (valgfri)';

  @override
  String get snapReportCancelButtonLabel => 'Annullér';

  @override
  String get snapReportSubmitButtonLabel => 'Indsend rapport';

  @override
  String get snapReportEnterValidEmailError => 'Indtast en gyldig e-postadresse';

  @override
  String get snapReportDetailsHint => 'Kommentar …';

  @override
  String get snapReportPrivacyAgreementLabel => 'I forbindelse med indsendelse af denne formular bekræfter jeg, at jeg har læst og accepterer ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Canonicals privatlivsnotits ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'og ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'Privatlivspolitik';

  @override
  String get debPageErrorNoPackageInfo => 'Ingen pakkeinformation fundet';

  @override
  String get externalResources => 'Yderligere ressourcer';

  @override
  String get externalResourcesButtonLabel => 'Gå på opdagelse';

  @override
  String get allGamesButtonLabel => 'Alle spil';

  @override
  String get externalResourcesDisclaimer => 'Bemærk: Alle disse er eksterne værktøjer. De ejes eller distribueres ikke af Canonical.';

  @override
  String get openInBrowser => 'Åbn i browser';

  @override
  String get installAll => 'Installér alle';

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
