import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Nynorsk (`nn`).
class AppLocalizationsNn extends AppLocalizations {
  AppLocalizationsNn([String locale = 'nn']) : super(locale);

  @override
  String get appCenterLabel => 'App Center';

  @override
  String get appstreamSearchGreylist => 'app;applikasjon;pakke;program;program;programpakke;verktøy';

  @override
  String get snapPageChannelLabel => 'Kanal';

  @override
  String get snapPageConfinementLabel => 'Avgrensa';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Kontakt $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Skildring';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Utviklarnettstad';

  @override
  String get snapPageDownloadSizeLabel => 'Nedlastingsstorleik';

  @override
  String get snapPageSizeLabel => 'Storleik';

  @override
  String get snapPageGalleryLabel => 'Galleri';

  @override
  String get snapPageLicenseLabel => 'Lisens';

  @override
  String get snapPageLinksLabel => 'Lenkjer';

  @override
  String get snapPagePublisherLabel => 'Utgjevar';

  @override
  String get snapPagePublishedLabel => 'Utgjeve';

  @override
  String get snapPageSummaryLabel => 'Samanfatning';

  @override
  String get snapPageVersionLabel => 'Versjon';

  @override
  String get snapPageShareLinkCopiedMessage => 'Lenkje kopiert til utklyppstavle';

  @override
  String get explorePageLabel => 'Utforsk';

  @override
  String get explorePageCategoriesLabel => 'Kategoriar';

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
  String get managePageCheckForUpdates => 'Sjå etter oppdateringar';

  @override
  String get managePageCheckingForUpdates => 'Ser etter oppdateringar';

  @override
  String get managePageNoInternet => 'Can\'t reach server, check your internet connection or try again later.';

  @override
  String get managePageDescription => 'Sjå etter tilgjengelege oppdateringar, oppdater appane dine, og sjekk statusen til alle appane dine.';

  @override
  String get managePageDebUpdatesMessage => 'Debianpakkeoppdateringar er handtert av Programvareoppdatering-appen.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Installert og oppdatert';

  @override
  String get managePageLabel => 'Administrer installerte Snaps';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Ingen oppdateringar tilgjengeleg. Applikasjonane dine er oppdaterte.';

  @override
  String get managePageSearchFieldSearchHint => 'Søk i dine installerte appar';

  @override
  String get managePageShowDetailsLabel => 'Vis detaljar';

  @override
  String get managePageShowSystemSnapsLabel => 'Vis systemsnappar';

  @override
  String get managePageUpdateAllLabel => 'Oppdater alle';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dagar',
      one: '$n dag',
    );
    return 'Oppdatert for $_temp0 sidan';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n veker',
      one: '$n veke',
    );
    return 'Oppdatert for $_temp0 sidan';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n månadar',
      one: '$n månad',
    );
    return 'Oppdatert for $_temp0 sidan';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n år',
      one: '$n år',
    );
    return 'Oppdatert for $_temp0 sidan';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Oppdateringar tilgjengeleg ($n)';
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
  String get developmentPageLabel => 'Utvikling';

  @override
  String get gamesPageLabel => 'Spel';

  @override
  String get gamesPageTitle => 'Populært';

  @override
  String get gamesPageTop => 'Populære spel';

  @override
  String get gamesPageFeatured => 'Utvalde titlar';

  @override
  String get gamesPageBundles => 'App-pakkar';

  @override
  String get unknownPublisher => 'Ukjend utgjevar';

  @override
  String get searchFieldDebSection => 'Debianpakkar';

  @override
  String get searchFieldSearchHint => 'Søk etter appar';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Vis alle resultat for \"$query\"';
  }

  @override
  String get searchFieldSnapSection => 'Snap-pakkar';

  @override
  String get searchPageFilterByLabel => 'Filtrer etter';

  @override
  String searchPageNoResults(String query) {
    return 'Ingen resultat funne for \"$query\"';
  }

  @override
  String get searchPageNoResultsHint => 'Prøv å nytt andre eller meir generelle søkjeord';

  @override
  String get searchPageNoResultsCategory => 'Orsak, vi kunne ikkje finne nokon pakkar i denne kategorien';

  @override
  String get searchPageNoResultsCategoryHint => 'Prøv ein annan kategori eller nytt meir generelle søkjeord';

  @override
  String get searchPageSortByLabel => 'Sorter etter';

  @override
  String get searchPageRelevanceLabel => 'Relevans';

  @override
  String searchPageTitle(String query) {
    return 'Resultat for \"$query\"';
  }

  @override
  String get aboutPageLabel => 'Om';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Versjon $version';
  }

  @override
  String get aboutPageContributorTitle => 'Designa og utvikla av:';

  @override
  String get aboutPageCommunityTitle => 'Ver ein del av fellesskapet:';

  @override
  String get aboutPageContributeLabel => 'Bidra eller rapporter feil';

  @override
  String get aboutPageGitHubLabel => 'Finn oss på GitHub';

  @override
  String get aboutPagePublishLabel => 'Legg til i Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Lær meir';

  @override
  String get appstreamUrlTypeBugtracker => 'Feilsporar';

  @override
  String get appstreamUrlTypeContact => 'Kontakt';

  @override
  String get appstreamUrlTypeContribute => 'Bidra';

  @override
  String get appstreamUrlTypeDonation => 'Doner';

  @override
  String get appstreamUrlTypeFaq => 'FAQ';

  @override
  String get appstreamUrlTypeHelp => 'Hjelp';

  @override
  String get appstreamUrlTypeHomepage => 'Heimeside';

  @override
  String get appstreamUrlTypeTranslate => 'Omsetjingar';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Kjelde';

  @override
  String get packageFormatDebLabel => 'Debianpakkar';

  @override
  String get packageFormatSnapLabel => 'Snap-pakkar';

  @override
  String get snapActionCancelLabel => 'Avbryt';

  @override
  String get snapActionInstallLabel => 'Installer';

  @override
  String get snapActionInstalledLabel => 'Installert';

  @override
  String get snapActionInstallingLabel => 'Installerar';

  @override
  String get snapActionOpenLabel => 'Opne';

  @override
  String get snapActionRemoveLabel => 'Avinstaller';

  @override
  String get snapActionRemovingLabel => 'Avinstallerar';

  @override
  String get snapActionSwitchChannelLabel => 'Byt kanal';

  @override
  String get snapActionUpdateLabel => 'Oppdater';

  @override
  String get snapCategoryAll => 'Alle kategoriar';

  @override
  String get snapActionUpdatingLabel => 'Oppdaterar';

  @override
  String get snapCategoryArtAndDesign => 'Kunst og Design';

  @override
  String get snapCategoryBooksAndReference => 'Bøker og Referanseverktøy';

  @override
  String get snapCategoryDefaultButtonLabel => 'Oppdag meir';

  @override
  String get snapCategoryDevelopment => 'Utvikling';

  @override
  String get snapCategoryDevelopmentSlogan => 'Må-ha-Snaps for utviklarar';

  @override
  String get snapCategoryDevicesAndIot => 'Einingar og IoT';

  @override
  String get snapCategoryEducation => 'Utdanning';

  @override
  String get snapCategoryEntertainment => 'Underhalding';

  @override
  String get snapCategoryFeatured => 'Utvalde';

  @override
  String get snapCategoryFeaturedSlogan => 'Utvalde Snaps';

  @override
  String get snapCategoryFinance => 'Finans';

  @override
  String get snapCategoryGames => 'Spel';

  @override
  String get snapCategoryGamesSlogan => 'Alt til spelekvelden';

  @override
  String get snapCategoryGameDev => 'Spelutvikling';

  @override
  String get snapCategoryGameDevSlogan => 'Spelutvikling';

  @override
  String get snapCategoryGameEmulators => 'Emulatorar';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emulatorar';

  @override
  String get snapCategoryGnomeGames => 'GNOME-spel';

  @override
  String get snapCategoryGnomeGamesSlogan => 'GNOME Spel-pakke';

  @override
  String get snapCategoryKdeGames => 'KDE-spel';

  @override
  String get snapCategoryKdeGamesSlogan => 'KDE Spelpakke';

  @override
  String get snapCategoryGameLaunchers => 'Spelstartarar';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Spelstartarar';

  @override
  String get snapCategoryGameContentCreation => 'Innhaldsskaping';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Innhaldsskaping';

  @override
  String get snapCategoryHealthAndFitness => 'Helse og Trening';

  @override
  String get snapCategoryMusicAndAudio => 'Musikk og Lyd';

  @override
  String get snapCategoryNewsAndWeather => 'Nyhende og Vêr';

  @override
  String get snapCategoryPersonalisation => 'Personalisering';

  @override
  String get snapCategoryPhotoAndVideo => 'Foto og Video';

  @override
  String get snapCategoryProductivity => 'Produktivitet';

  @override
  String get snapCategoryProductivityButtonLabel => 'Oppdag produktivitetssamlinga';

  @override
  String get snapCategoryProductivitySlogan => 'Huk av ting på to-do-lista di';

  @override
  String get snapCategoryScience => 'Vitskap';

  @override
  String get snapCategorySecurity => 'Sikkerheit';

  @override
  String get snapCategoryServerAndCloud => 'Server og Sky';

  @override
  String get snapCategorySocial => 'Sosialt';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu Desktop';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Få i gong skrivebordet ditt';

  @override
  String get snapCategoryUtilities => 'Verktøy';

  @override
  String get snapConfinementClassic => 'Klassisk';

  @override
  String get snapConfinementDevmode => 'Utviklarmodus';

  @override
  String get snapConfinementStrict => 'Streng';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Alfabetisk (A til Å)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Alfabetisk (Å til A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Storleik (Minst til størst)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Storleik (Størst til minst)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Storleik (Minst til størst)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Storleik (Størst til minst)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Minst nyleg oppdatert';

  @override
  String get snapSortOrderInstalledDateDesc => 'Sist oppdatert';

  @override
  String get snapSortOrderRelevance => 'Relevans';

  @override
  String get snapRatingsBandVeryGood => 'Veldig bra';

  @override
  String get snapRatingsBandGood => 'Bra';

  @override
  String get snapRatingsBandNeutral => 'Nøytral';

  @override
  String get snapRatingsBandPoor => 'Dårleg';

  @override
  String get snapRatingsBandVeryPoor => 'Veldig dårleg';

  @override
  String get snapRatingsBandInsufficientVotes => 'Ikkje nok stemmer';

  @override
  String snapRatingsVotes(int n) {
    return '$n stemmer';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Rapporter $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Vel ein grunn for å rapportere denne snappen';

  @override
  String get snapReportSelectAnOptionLabel => 'Vel';

  @override
  String get snapReportOptionCopyrightViolation => 'Brot på opphavsrett eller varemerke';

  @override
  String get snapReportOptionStoreViolation => 'Snap Store vilkårsovertrakking';

  @override
  String get snapReportDetailsLabel => 'Gjer vel å oppgje meir detaljar i rapporten';

  @override
  String get snapReportOptionalEmailAddressLabel => 'E-posten din (valfritt)';

  @override
  String get snapReportCancelButtonLabel => 'Avbryt';

  @override
  String get snapReportSubmitButtonLabel => 'Send inn rapport';

  @override
  String get snapReportEnterValidEmailError => 'Legg inn ei gyldig epost-adresse';

  @override
  String get snapReportDetailsHint => 'Kommenter...';

  @override
  String get snapReportPrivacyAgreementLabel => 'Ved å sende inn dette skjemaet, stadfester eg å ha lese og samtykka til ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Canonical si personvernserklæring ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'og ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'Personvernserklæring';

  @override
  String get debPageErrorNoPackageInfo => 'Ingen pakkeinformasjon funne';

  @override
  String get externalResources => 'Andre ressursar';

  @override
  String get externalResourcesButtonLabel => 'Oppdag meir';

  @override
  String get allGamesButtonLabel => 'Alle spel';

  @override
  String get externalResourcesDisclaimer => 'Merk: Dette er eksterne verktøy. Desse er korkje eig eller tilbytt av Canonical.';

  @override
  String get openInBrowser => 'Opne i nettlesar';

  @override
  String get installAll => 'Installer alle';

  @override
  String get localDebWarningTitle => 'Kan vere usikre';

  @override
  String get localDebWarningBody => 'Denne pakken blir levert av ein tredjepart. Å installere pakkar frå utanfor App Center kan auke risikoen for systemet ditt og personlege data. Forsikre deg om at du stolar på kjelda før du held fram.';

  @override
  String get localDebLearnMore => 'Lær meir om tredjeparts-pakkar';

  @override
  String get localDebDialogMessage => 'Denne pakken er tilbytt av ein tredjepart og kan true systemet ditt, og dine personlege data.';

  @override
  String get localDebDialogConfirmation => 'Er du sikker på at du vil installere den?';

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
