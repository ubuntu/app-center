import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Esperanto (`eo`).
class AppLocalizationsEo extends AppLocalizations {
  AppLocalizationsEo([String locale = 'eo']) : super(locale);

  @override
  String get appCenterLabel => 'Programcentro';

  @override
  String get appstreamSearchGreylist => 'programo;aplikaĵo;pako;apo;ilo;programaro;softvaro';

  @override
  String get snapPageChannelLabel => 'Kanalo';

  @override
  String get snapPageConfinementLabel => 'Enfermado';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Kontakti $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Priskribo';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Retejo de aŭtoro';

  @override
  String get snapPageDownloadSizeLabel => 'Elŝuta grando';

  @override
  String get snapPageSizeLabel => 'Grando';

  @override
  String get snapPageGalleryLabel => 'Galerio';

  @override
  String get snapPageLicenseLabel => 'Licenco';

  @override
  String get snapPageLinksLabel => 'Ligoj';

  @override
  String get snapPagePublisherLabel => 'Eldonejo';

  @override
  String get snapPagePublishedLabel => 'Eldonita';

  @override
  String get snapPageSummaryLabel => 'Resumo';

  @override
  String get snapPageVersionLabel => 'Versio';

  @override
  String get snapPageShareLinkCopiedMessage => 'Ligilo kopiita al tondujo';

  @override
  String get explorePageLabel => 'Esplori';

  @override
  String get explorePageCategoriesLabel => 'Kategorioj';

  @override
  String get managePageOwnUpdateAvailable => 'Ĝisdatigo de la Programcentro disponeblas';

  @override
  String get managePageQuitToUpdate => 'Forlasi por ĝisdatigi';

  @override
  String get managePageOwnUpdateDescription => 'Kiam vi forlasos la programon, ĝi ĝisdatiĝos aŭtomate.';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return 'La Programcentro aŭtomate ĝisdatiĝos post $time.';
  }

  @override
  String get managePageOwnUpdateQuitButton => 'Forlasi por ĝisdatigi';

  @override
  String get managePageCheckForUpdates => 'Kontroli ĝisdatigojn';

  @override
  String get managePageCheckingForUpdates => 'Kontrolante ĝisdatigojn';

  @override
  String get managePageNoInternet => 'Ne eblas konekti al la servilo. Kontrolu vian Interretan konekton, aŭ reprovu poste.';

  @override
  String get managePageDescription => 'Kontroli disponeblajn ĝisdatigojn, ĝisdatigi kaj administri viajn programojn.';

  @override
  String get managePageDebUpdatesMessage => 'Ĝisdatigon de Debian-pakoj respondecas la Ĝisdatigilo de Programaroj.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Instalitaj aŭ ĝisdatigitaj';

  @override
  String get managePageLabel => 'Administri instalitajn Snap-pakojn';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Neniu ĝisdatigo disponeblas. Viaj programoj estas ĝisdataj.';

  @override
  String get managePageSearchFieldSearchHint => 'Serĉi viajn instalitajn programojn';

  @override
  String get managePageShowDetailsLabel => 'Montri detalojn';

  @override
  String get managePageShowSystemSnapsLabel => 'Montri sistemajn pakojn';

  @override
  String get managePageUpdateAllLabel => 'Ĝisdatigi ĉiujn';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tagoj',
      one: '$n tago',
    );
    return 'Ĝisdatigita antaŭ $_temp0';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n semajnoj',
      one: '$n semajno',
    );
    return 'Ĝisdatigita antaŭ $_temp0';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n monatoj',
      one: '$n monato',
    );
    return 'Ĝisdatigita antaŭ $_temp0';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n jaroj',
      one: '$n jaro',
    );
    return 'Ĝisdatigita antaŭ $_temp0';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Ĝisdatigoj disponeblas ($n)';
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
  String get productivityPageLabel => 'Laboro';

  @override
  String get developmentPageLabel => 'Programado';

  @override
  String get gamesPageLabel => 'Ludoj';

  @override
  String get gamesPageTitle => 'Kio popularas';

  @override
  String get gamesPageTop => 'Plej bonaj ludoj';

  @override
  String get gamesPageFeatured => 'Elstaraj ludoj';

  @override
  String get gamesPageBundles => 'Programfaskoj';

  @override
  String get unknownPublisher => 'Nekonata eldonejo';

  @override
  String get searchFieldDebSection => 'Debian-pakoj';

  @override
  String get searchFieldSearchHint => 'Serĉi programojn';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Montri ĉiujn rezultojn pri «$query»';
  }

  @override
  String get searchFieldSnapSection => 'Snap-pakoj';

  @override
  String get searchPageFilterByLabel => 'Filtri laŭ';

  @override
  String searchPageNoResults(String query) {
    return 'Neniu rezulto pri «$query»';
  }

  @override
  String get searchPageNoResultsHint => 'Provu aliajn aŭ pli ĝeneralajn serĉojn';

  @override
  String get searchPageNoResultsCategory => 'Bedaŭrinde troviĝis neniu pako en ĉi tiu kategorio';

  @override
  String get searchPageNoResultsCategoryHint => 'Provu aliajn kategoriojn aŭ pli ĝeneralajn serĉojn';

  @override
  String get searchPageSortByLabel => 'Ordigi';

  @override
  String get searchPageRelevanceLabel => 'Rilateco';

  @override
  String searchPageTitle(String query) {
    return 'Rezultoj pri «$query»';
  }

  @override
  String get aboutPageLabel => 'Pri';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Versio $version';
  }

  @override
  String get aboutPageContributorTitle => 'Dezajnita kaj programita de:';

  @override
  String get aboutPageCommunityTitle => 'Partoprenu en la komunumo:';

  @override
  String get aboutPageContributeLabel => 'Kontribui aŭ raporti cimon';

  @override
  String get aboutPageGitHubLabel => 'Trovu nin ĉe GitHub';

  @override
  String get aboutPagePublishLabel => 'Eldoni ĉe Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Lerni plu';

  @override
  String get appstreamUrlTypeBugtracker => 'Cimspurilo';

  @override
  String get appstreamUrlTypeContact => 'Kontakto';

  @override
  String get appstreamUrlTypeContribute => 'Kontribui';

  @override
  String get appstreamUrlTypeDonation => 'Donaci';

  @override
  String get appstreamUrlTypeFaq => 'Oftaj demandoj';

  @override
  String get appstreamUrlTypeHelp => 'Helpo';

  @override
  String get appstreamUrlTypeHomepage => 'Retejo';

  @override
  String get appstreamUrlTypeTranslate => 'Tradukoj';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Fonto';

  @override
  String get packageFormatDebLabel => 'Debian-pakoj';

  @override
  String get packageFormatSnapLabel => 'Snap-pakoj';

  @override
  String get snapActionCancelLabel => 'Nuligi';

  @override
  String get snapActionInstallLabel => 'Instali';

  @override
  String get snapActionInstalledLabel => 'Instalita';

  @override
  String get snapActionInstallingLabel => 'Instalante';

  @override
  String get snapActionOpenLabel => 'Lanĉi';

  @override
  String get snapActionRemoveLabel => 'Malinstali';

  @override
  String get snapActionRemovingLabel => 'Malinstalante';

  @override
  String get snapActionSwitchChannelLabel => 'Ŝanĝi kanalon';

  @override
  String get snapActionUpdateLabel => 'Ĝisdatigi';

  @override
  String get snapCategoryAll => 'Ĉiuj kategorioj';

  @override
  String get snapActionUpdatingLabel => 'Ĝisdatigante';

  @override
  String get snapCategoryArtAndDesign => 'Arto kaj dezajno';

  @override
  String get snapCategoryBooksAndReference => 'Libroj kaj vortaroj';

  @override
  String get snapCategoryDefaultButtonLabel => 'Ekscii pli';

  @override
  String get snapCategoryDevelopment => 'Programado';

  @override
  String get snapCategoryDevelopmentSlogan => 'Esencaj Snap-pakoj por programistoj';

  @override
  String get snapCategoryDevicesAndIot => 'Aparatoj kaj Aĵ-Interreto';

  @override
  String get snapCategoryEducation => 'Eduko';

  @override
  String get snapCategoryEntertainment => 'Distro';

  @override
  String get snapCategoryFeatured => 'Elstaraj';

  @override
  String get snapCategoryFeaturedSlogan => 'Elstaraj Snap-pakoj';

  @override
  String get snapCategoryFinance => 'Financo';

  @override
  String get snapCategoryGames => 'Ludoj';

  @override
  String get snapCategoryGamesSlogan => 'Ĉio necesa por via ludema vespero';

  @override
  String get snapCategoryGameDev => 'Programado de ludoj';

  @override
  String get snapCategoryGameDevSlogan => 'Programado de ludoj';

  @override
  String get snapCategoryGameEmulators => 'Imitiloj';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Imitiloj';

  @override
  String get snapCategoryGnomeGames => 'Ludoj por GNOME';

  @override
  String get snapCategoryGnomeGamesSlogan => 'Ludoj por GNOME';

  @override
  String get snapCategoryKdeGames => 'Ludoj por KDE';

  @override
  String get snapCategoryKdeGamesSlogan => 'Ludoj por KDE';

  @override
  String get snapCategoryGameLaunchers => 'Ludolanĉiloj';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Ludolanĉiloj';

  @override
  String get snapCategoryGameContentCreation => 'Aŭdvida dissendado';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Aŭdvida dissendado';

  @override
  String get snapCategoryHealthAndFitness => 'Sano kaj sporto';

  @override
  String get snapCategoryMusicAndAudio => 'Muziko kaj aŭskultaĵoj';

  @override
  String get snapCategoryNewsAndWeather => 'Sciigu vin';

  @override
  String get snapCategoryPersonalisation => 'Tajlorado';

  @override
  String get snapCategoryPhotoAndVideo => 'Fotoj kaj filmoj';

  @override
  String get snapCategoryProductivity => 'Laboro';

  @override
  String get snapCategoryProductivityButtonLabel => 'Esploru la programojn por laboro';

  @override
  String get snapCategoryProductivitySlogan => 'Malpliigu vian taskoliston';

  @override
  String get snapCategoryScience => 'Scienco';

  @override
  String get snapCategorySecurity => 'Sekureco';

  @override
  String get snapCategoryServerAndCloud => 'Serviloj kaj nuboj';

  @override
  String get snapCategorySocial => 'Sociaj retoj';

  @override
  String get snapCategoryUbuntuDesktop => 'Labortablaj programoj';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Startigu vian labortablon';

  @override
  String get snapCategoryUtilities => 'Ilaĵoj';

  @override
  String get snapConfinementClassic => 'Klasika';

  @override
  String get snapConfinementDevmode => 'Programista reĝimo';

  @override
  String get snapConfinementStrict => 'Strikta';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Alfabete (de A ĝis Z)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Alfabete (de Z ĝis A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Laŭ grando (de malgranda ĝis granda)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Laŭ grando (de granda ĝis malgranda)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Laŭ grando (de malgranda ĝis granda)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Laŭ grando (de granda ĝis malgranda)';

  @override
  String get snapSortOrderInstalledDateAsc => 'De malplej laste ĝis plej laste ĝisdatigita';

  @override
  String get snapSortOrderInstalledDateDesc => 'De plej laste ĝis malplej laste ĝisdatigita';

  @override
  String get snapSortOrderRelevance => 'Rilateco';

  @override
  String get snapRatingsBandVeryGood => 'Bonega';

  @override
  String get snapRatingsBandGood => 'Bona';

  @override
  String get snapRatingsBandNeutral => 'Neŭtra';

  @override
  String get snapRatingsBandPoor => 'Malbona';

  @override
  String get snapRatingsBandVeryPoor => 'Malbonega';

  @override
  String get snapRatingsBandInsufficientVotes => 'Nesufiĉo da voĉoj';

  @override
  String snapRatingsVotes(int n) {
    return '$n voĉoj';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Raporti $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Elektu kialon por raporti ĉi tiun programon';

  @override
  String get snapReportSelectAnOptionLabel => 'Elektu opcion';

  @override
  String get snapReportOptionCopyrightViolation => 'Malobservo de aŭtorrajtoj aŭ markorajtoj';

  @override
  String get snapReportOptionStoreViolation => 'Malobservo de la uzokondiĉoj de Snap Store';

  @override
  String get snapReportDetailsLabel => 'Bonvolu doni pli detalajn kialojn pri via raporto';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Via retpoŝta adreso (nedeviga)';

  @override
  String get snapReportCancelButtonLabel => 'Nuligi';

  @override
  String get snapReportSubmitButtonLabel => 'Submeti raporton';

  @override
  String get snapReportEnterValidEmailError => 'Tajpu validan retpoŝtan adreson';

  @override
  String get snapReportDetailsHint => 'Komenti…';

  @override
  String get snapReportPrivacyAgreementLabel => 'Submetante ĉi tiun raporton, mi konfirmas, ke mi legis kaj konsentas ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'la Averton pri Privateco ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'kaj ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'la Regulojn pri Privateco de Canonical';

  @override
  String get debPageErrorNoPackageInfo => 'Neniu paka informo troviĝis';

  @override
  String get externalResources => 'Pliaj rimedoj';

  @override
  String get externalResourcesButtonLabel => 'Ekscii pli';

  @override
  String get allGamesButtonLabel => 'Ĉiuj ludoj';

  @override
  String get externalResourcesDisclaimer => 'Notu: jen eksteraj ilaĵoj ne posedataj nek distribuataj de Canonical.';

  @override
  String get openInBrowser => 'Malfermi per TTT-legilo';

  @override
  String get installAll => 'Instali ĉiujn';

  @override
  String get localDebWarningTitle => 'Eble nesekura';

  @override
  String get localDebWarningBody => 'Tiu pako estas disponigita de tria partio. Instalado de pakoj ekster la Programcentro povas pliigi la riskon al via sistemo kaj personaj datenoj. Certigu, ke vi fidas la fonton antaŭ ol daŭrigi.';

  @override
  String get localDebLearnMore => 'Lernu pli pri triapartiaj pakoj';

  @override
  String get localDebDialogMessage => 'Tiu pako estas disponigita de tria partio kaj povas minaci vian sistemon kaj personajn datenojn.';

  @override
  String get localDebDialogConfirmation => 'Ĉu vi certe volas instali ĝin?';

  @override
  String snapdExceptionRunningApps(String snapName) {
    return 'Ne eblis ĝisdatigi $snapName, ĉar ĝi nun ruliĝas.';
  }

  @override
  String get errorViewCheckStatusLabel => 'Kontroli staton';

  @override
  String get errorViewNetworkErrorTitle => 'Konekti al Interreto';

  @override
  String get errorViewNetworkErrorDescription => 'Oni ne povas ŝargi enhavon en la Programcentro sen Interreta konekto.';

  @override
  String get errorViewNetworkErrorAction => 'Kontrolu vian konekton kaj reprovu.';

  @override
  String get errorViewServerErrorDescription => 'Bedaŭrinde, ni spertas problemojn pri la Programcentro.';

  @override
  String get errorViewServerErrorAction => 'Kontrolu la staton pri ĝisdatigoj, aŭ reprovu poste.';

  @override
  String get errorViewUnknownErrorTitle => 'Io fiaskis';

  @override
  String get errorViewUnknownErrorDescription => 'Bedaŭrinde, ni ne certas pri la eraro.';

  @override
  String get errorViewUnknownErrorAction => 'Vi povas reprovi nun, kontroli la staton pri ĝisdatigoj, aŭ reprovi poste.';
}
