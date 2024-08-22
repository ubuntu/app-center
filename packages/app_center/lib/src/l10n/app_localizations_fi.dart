import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appCenterLabel => 'Sovelluskeskus';

  @override
  String get appstreamSearchGreylist => 'app;application;package;program;programme;suite;tool;sovellus;ohjelma;paketti;työkalu;äppi';

  @override
  String get snapPageChannelLabel => 'Kanava';

  @override
  String get snapPageConfinementLabel => 'Eristys';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Ota yhteys julkaisijaan $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Kuvaus';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Kehittäjän sivusto';

  @override
  String get snapPageDownloadSizeLabel => 'Latauksen koko';

  @override
  String get snapPageSizeLabel => 'Koko';

  @override
  String get snapPageGalleryLabel => 'Galleria';

  @override
  String get snapPageLicenseLabel => 'Lisenssi';

  @override
  String get snapPageLinksLabel => 'Linkit';

  @override
  String get snapPagePublisherLabel => 'Julkaisija';

  @override
  String get snapPagePublishedLabel => 'Julkaistu';

  @override
  String get snapPageSummaryLabel => 'Yhteenveto';

  @override
  String get snapPageVersionLabel => 'Julkaisu';

  @override
  String get snapPageShareLinkCopiedMessage => 'Linkki kopioitu leikepöydälle';

  @override
  String get explorePageLabel => 'Tutustu';

  @override
  String get explorePageCategoriesLabel => 'Luokat';

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
  String get managePageCheckForUpdates => 'Tarkista päivitykset';

  @override
  String get managePageCheckingForUpdates => 'Tarkistetaan päivityksiä';

  @override
  String get managePageNoInternet => 'Can\'t reach server, check your internet connection or try again later.';

  @override
  String get managePageDescription => 'Tarkista saatavilla olevat päivitykset, päivitä sovellukset ja hallitse kaikkien sovellusten tilaa.';

  @override
  String get managePageDebUpdatesMessage => 'Debian-pakettien päivityksistä vastaa Ohjelmistojen päivitys.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Asennettu ja päivitetty';

  @override
  String get managePageLabel => 'Hallitse asennettuja snap-paketteja';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Päivityksiä ei ole saatavilla. Kaikki sovellukset ovat ajan tasalla.';

  @override
  String get managePageSearchFieldSearchHint => 'Etsi asennettuja sovelluksia';

  @override
  String get managePageShowDetailsLabel => 'Näytä tiedot';

  @override
  String get managePageShowSystemSnapsLabel => 'Näytä järjestelmä-snapit';

  @override
  String get managePageUpdateAllLabel => 'Päivitä kaikki';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n päivää',
      one: '$n päivä',
    );
    return 'Päivitetty $_temp0 sitten';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n viikkoa',
      one: '$n viikko',
    );
    return 'Päivitetty $_temp0 sitten';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '${n}kuukautta',
      one: '$n kuukausi',
    );
    return 'Päivitetty $_temp0 sitten';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n vuotta',
      one: '$n vuosi',
    );
    return 'Päivitetty $_temp0 sitten';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Päivityksiä saatavilla ($n)';
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
  String get productivityPageLabel => 'Tuotteliaisuus';

  @override
  String get developmentPageLabel => 'Kehitystyö';

  @override
  String get gamesPageLabel => 'Pelit';

  @override
  String get gamesPageTitle => 'Nousussa';

  @override
  String get gamesPageTop => 'Suosituimmat pelit';

  @override
  String get gamesPageFeatured => 'Suositut nimikkeet';

  @override
  String get gamesPageBundles => 'Sovelluskokoelmat';

  @override
  String get unknownPublisher => 'Tuntematon julkaisija';

  @override
  String get searchFieldDebSection => 'Debian-paketit';

  @override
  String get searchFieldSearchHint => 'Etsi sovelluksia';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Näytä kaikki haun \"$query\" tulokset';
  }

  @override
  String get searchFieldSnapSection => 'Snap-paketit';

  @override
  String get searchPageFilterByLabel => 'Suodata';

  @override
  String searchPageNoResults(String query) {
    return 'Haku \"$query\" ei tuottanut tuloksia';
  }

  @override
  String get searchPageNoResultsHint => 'Käytä eri hakuehtoja tai yleisempiä avainsanoja';

  @override
  String get searchPageNoResultsCategory => 'Valitettavasti tästä luokasta ei löytynyt paketteja';

  @override
  String get searchPageNoResultsCategoryHint => 'Etsi eri luokasta tai käytä yleisempiä avainsanoja';

  @override
  String get searchPageSortByLabel => 'Järjestä';

  @override
  String get searchPageRelevanceLabel => 'Asiaankuuluvuus';

  @override
  String searchPageTitle(String query) {
    return 'Tulokset haulla \"$query\"';
  }

  @override
  String get aboutPageLabel => 'Tietoja';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Versio $version';
  }

  @override
  String get aboutPageContributorTitle => 'Suunnitellut ja kehittänyt:';

  @override
  String get aboutPageCommunityTitle => 'Ole osa yhteisöä:';

  @override
  String get aboutPageContributeLabel => 'Osallistu tai ilmoita virheestä';

  @override
  String get aboutPageGitHubLabel => 'Löydät meidät GitHubista';

  @override
  String get aboutPagePublishLabel => 'Julkaise Snap-kauppaan';

  @override
  String get aboutPageLearnMoreLabel => 'Lue lisää';

  @override
  String get appstreamUrlTypeBugtracker => 'Vianseuranta';

  @override
  String get appstreamUrlTypeContact => 'Yhteys';

  @override
  String get appstreamUrlTypeContribute => 'Osallistu';

  @override
  String get appstreamUrlTypeDonation => 'Lahjoita';

  @override
  String get appstreamUrlTypeFaq => 'UKK';

  @override
  String get appstreamUrlTypeHelp => 'Tuki';

  @override
  String get appstreamUrlTypeHomepage => 'Verkkosivusto';

  @override
  String get appstreamUrlTypeTranslate => 'Käännökset';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Lähde';

  @override
  String get packageFormatDebLabel => 'Debian-paketit';

  @override
  String get packageFormatSnapLabel => 'Snap-paketit';

  @override
  String get snapActionCancelLabel => 'Peru';

  @override
  String get snapActionInstallLabel => 'Asenna';

  @override
  String get snapActionInstalledLabel => 'Asennettu';

  @override
  String get snapActionInstallingLabel => 'Asennetaan';

  @override
  String get snapActionOpenLabel => 'Avaa';

  @override
  String get snapActionRemoveLabel => 'Poista asennus';

  @override
  String get snapActionRemovingLabel => 'Poistetaan asennus';

  @override
  String get snapActionSwitchChannelLabel => 'Vaihda kanavaa';

  @override
  String get snapActionUpdateLabel => 'Päivitä';

  @override
  String get snapCategoryAll => 'Kaikki luokat';

  @override
  String get snapActionUpdatingLabel => 'Päivitetään';

  @override
  String get snapCategoryArtAndDesign => 'Taiteet ja suunnittelu';

  @override
  String get snapCategoryBooksAndReference => 'Kirjat ja viitteet';

  @override
  String get snapCategoryDefaultButtonLabel => 'Löydä enemmän';

  @override
  String get snapCategoryDevelopment => 'Kehitystyö';

  @override
  String get snapCategoryDevelopmentSlogan => 'Tärkeimmät snapit kehittäjille';

  @override
  String get snapCategoryDevicesAndIot => 'Laitteet ja IoT';

  @override
  String get snapCategoryEducation => 'Opiskelu';

  @override
  String get snapCategoryEntertainment => 'Viihde';

  @override
  String get snapCategoryFeatured => 'Nyt esillä';

  @override
  String get snapCategoryFeaturedSlogan => 'Esittelyssä olevat snapit';

  @override
  String get snapCategoryFinance => 'Rahatalous';

  @override
  String get snapCategoryGames => 'Pelit';

  @override
  String get snapCategoryGamesSlogan => 'Kaikkea peli-iltaa varten';

  @override
  String get snapCategoryGameDev => 'Pelikehitys';

  @override
  String get snapCategoryGameDevSlogan => 'Pelikehitys';

  @override
  String get snapCategoryGameEmulators => 'Emulaattorit';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emulaattorit';

  @override
  String get snapCategoryGnomeGames => 'Gnomen pelit';

  @override
  String get snapCategoryGnomeGamesSlogan => 'Gnomen pelikokoelma';

  @override
  String get snapCategoryKdeGames => 'KDE:n pelit';

  @override
  String get snapCategoryKdeGamesSlogan => 'KDE:n pelikokoelma';

  @override
  String get snapCategoryGameLaunchers => 'Pelikäynnistimet';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Pelikäynnistimet';

  @override
  String get snapCategoryGameContentCreation => 'Sisällöntuotanto';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Sisällöntuotanto';

  @override
  String get snapCategoryHealthAndFitness => 'Terveys ja kunto';

  @override
  String get snapCategoryMusicAndAudio => 'Musiikki ja ääni';

  @override
  String get snapCategoryNewsAndWeather => 'Uutiset ja sää';

  @override
  String get snapCategoryPersonalisation => 'Mukauttaminen';

  @override
  String get snapCategoryPhotoAndVideo => 'Kuva ja video';

  @override
  String get snapCategoryProductivity => 'Tuotteliaisuus';

  @override
  String get snapCategoryProductivityButtonLabel => 'Tutustu tuottavuuskokoelmaan';

  @override
  String get snapCategoryProductivitySlogan => 'Yksi asia vähemmän tehtävälistalla';

  @override
  String get snapCategoryScience => 'Tiede';

  @override
  String get snapCategorySecurity => 'Tietoturva';

  @override
  String get snapCategoryServerAndCloud => 'Palvelin ja pilvi';

  @override
  String get snapCategorySocial => 'Some';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu-työpöytä';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Hyppy työpöydälle';

  @override
  String get snapCategoryUtilities => 'Apuohjelmat';

  @override
  String get snapConfinementClassic => 'Klassinen';

  @override
  String get snapConfinementDevmode => 'Kehitystila';

  @override
  String get snapConfinementStrict => 'Tiukka';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Aakkosjärjestys (A-Ö)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Aakkosjärjestys (Ö-A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Koko (pienimmästä suurimpaan)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Koko (suurimmasta pienimpään)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Koko (pienimmästä suurimpaan)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Koko (suurimmasta pienimpään)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Pisin aika viime päivityksestä';

  @override
  String get snapSortOrderInstalledDateDesc => 'Lyhyin aika viime päivityksestä';

  @override
  String get snapSortOrderRelevance => 'Asiaankuuluvuus';

  @override
  String get snapRatingsBandVeryGood => 'Erittäin hyvä';

  @override
  String get snapRatingsBandGood => 'Hyvä';

  @override
  String get snapRatingsBandNeutral => 'Neutraali';

  @override
  String get snapRatingsBandPoor => 'Heikko';

  @override
  String get snapRatingsBandVeryPoor => 'Erittäin heikko';

  @override
  String get snapRatingsBandInsufficientVotes => 'Ei riittävästi ääniä';

  @override
  String snapRatingsVotes(int n) {
    return '$n ääntä';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Ilmoita $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Valitse syy, miksi teet ilmoituksen tästä snapista';

  @override
  String get snapReportSelectAnOptionLabel => 'Valitse yksi';

  @override
  String get snapReportOptionCopyrightViolation => 'Tekijänoikeuden tai tavaramerkin loukkaus';

  @override
  String get snapReportOptionStoreViolation => 'Snap-kaupan käyttöehtojen rikkominen';

  @override
  String get snapReportDetailsLabel => 'Anna lisätietoja ilmoitukseen';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Sähköpostiosoitteesi (valinnainen)';

  @override
  String get snapReportCancelButtonLabel => 'Peru';

  @override
  String get snapReportSubmitButtonLabel => 'Lähetä ilmoitus';

  @override
  String get snapReportEnterValidEmailError => 'Kirjoita kelvollinen sähköpostiosoite';

  @override
  String get snapReportDetailsHint => 'Kommentti...';

  @override
  String get snapReportPrivacyAgreementLabel => 'Lähettämällä tämän lomakkeen vahvistan lukeneeni ja hyväksyväni ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Canonicalin tietosuojakäytännön ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'ja ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'tietosuojakäytännön';

  @override
  String get debPageErrorNoPackageInfo => 'Paketin tietoja ei löytynyt';

  @override
  String get externalResources => 'Lisäresurssit';

  @override
  String get externalResourcesButtonLabel => 'Löydä lisää';

  @override
  String get allGamesButtonLabel => 'Kaikki pelit';

  @override
  String get externalResourcesDisclaimer => 'Huomio: nämä ovat ulkoisia työkaluja. Canonical ei omista tai jakele niitä.';

  @override
  String get openInBrowser => 'Avaa selaimessa';

  @override
  String get installAll => 'Asenna kaikki';

  @override
  String get localDebWarningTitle => 'Mahdollisesti turvaton';

  @override
  String get localDebWarningBody => 'This package is provided by a third party. Installing packages from outside the App Center can increase the risk to your system and personal data. Ensure you trust the source before proceeding.';

  @override
  String get localDebLearnMore => 'Lue lisää kolmansien osapuolten paketeista';

  @override
  String get localDebDialogMessage => 'Tämän paketin tarjoaa kolmas osapuoli, ja se saattaa olla uhka järjestelmän turvallisuudelle sekä henkilökohtaisille tiedoille.';

  @override
  String get localDebDialogConfirmation => 'Haluatko varmasti asentaa sen?';

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
