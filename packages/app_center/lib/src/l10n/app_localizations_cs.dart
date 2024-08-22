import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appCenterLabel => 'Centrum aplikací';

  @override
  String get appstreamSearchGreylist => 'aplikace;balíček;program;sada;nástroj';

  @override
  String get snapPageChannelLabel => 'Kanál';

  @override
  String get snapPageConfinementLabel => 'Režim ohraničení';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Kontaktovat $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Popis';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Webové stránky vývojáře';

  @override
  String get snapPageDownloadSizeLabel => 'Stahovaná velikost';

  @override
  String get snapPageSizeLabel => 'Velikost';

  @override
  String get snapPageGalleryLabel => 'Galerie';

  @override
  String get snapPageLicenseLabel => 'Licence';

  @override
  String get snapPageLinksLabel => 'Odkazy';

  @override
  String get snapPagePublisherLabel => 'Vydavatel';

  @override
  String get snapPagePublishedLabel => 'Publikováno';

  @override
  String get snapPageSummaryLabel => 'Shrnutí';

  @override
  String get snapPageVersionLabel => 'Verze';

  @override
  String get snapPageShareLinkCopiedMessage => 'Odkaz zkopírován do schránky';

  @override
  String get explorePageLabel => 'Procházet';

  @override
  String get explorePageCategoriesLabel => 'Kategorie';

  @override
  String get managePageOwnUpdateAvailable => 'Je k dispozici aktualizace Centra aplikací';

  @override
  String get managePageQuitToUpdate => 'Ukončit pro aktualizaci';

  @override
  String get managePageOwnUpdateDescription => 'Když aplikaci ukončíte, automaticky se aktualizuje.';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return 'Centrum aplikací se automaticky aktualizuje za $time.';
  }

  @override
  String get managePageOwnUpdateQuitButton => 'Ukončit pro aktualizaci';

  @override
  String get managePageCheckForUpdates => 'Zkontrolovat aktualizace';

  @override
  String get managePageCheckingForUpdates => 'Kontrolují se aktualizace';

  @override
  String get managePageNoInternet => 'Nelze se připojit k serveru, zkontrolujte připojení k internetu nebo to zkuste znovu později.';

  @override
  String get managePageDescription => 'Zkontrolujte dostupné aktualizace, aktualizujte své aplikace a spravujte stav všech svých aplikací.';

  @override
  String get managePageDebUpdatesMessage => 'Aktualizace balíčků Debian zajišťuje Správce aktualizací.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Nainstalováno a aktualizováno';

  @override
  String get managePageLabel => 'Spravovat nainstalované Snapy';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Nejsou k dispozici žádné aktualizace. Všechny vaše aplikace jsou aktuální.';

  @override
  String get managePageSearchFieldSearchHint => 'Hledat nainstalované aplikace';

  @override
  String get managePageShowDetailsLabel => 'Zobrazit podrobnosti';

  @override
  String get managePageShowSystemSnapsLabel => 'Zobrazit systémové snapy';

  @override
  String get managePageUpdateAllLabel => 'Aktualizovat vše';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dny',
      one: '$n dnem',
    );
    return 'Aktualizováno před $_temp0';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n týdny',
      one: '$n týdnem',
    );
    return 'Aktualizováno před $_temp0';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n měsíci',
      one: '$n měsícem',
    );
    return 'Aktualizováno před $_temp0';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n lety',
      one: '$n rokem',
    );
    return 'Aktualizováno před $_temp0';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Dostupné aktualizace ($n)';
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
  String get productivityPageLabel => 'Kancelář';

  @override
  String get developmentPageLabel => 'Vývoj';

  @override
  String get gamesPageLabel => 'Hry';

  @override
  String get gamesPageTitle => 'Co je populární';

  @override
  String get gamesPageTop => 'Nejlepší hry';

  @override
  String get gamesPageFeatured => 'Vybrané tituly';

  @override
  String get gamesPageBundles => 'Balíčky aplikací';

  @override
  String get unknownPublisher => 'Neznámý vydavatel';

  @override
  String get searchFieldDebSection => 'Balíčky Debian';

  @override
  String get searchFieldSearchHint => 'Hledat aplikace';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Zobrazit všechny výsledky pro dotaz „$query“';
  }

  @override
  String get searchFieldSnapSection => 'Balíčky Snap';

  @override
  String get searchPageFilterByLabel => 'Filtrovat podle';

  @override
  String searchPageNoResults(String query) {
    return 'Nebyly nalezeny žádné výsledky pro dotaz „$query“';
  }

  @override
  String get searchPageNoResultsHint => 'Zkuste použít jiná nebo obecnější klíčová slova';

  @override
  String get searchPageNoResultsCategory => 'Litujeme, v této kategorii jsme nenašli žádné balíčky';

  @override
  String get searchPageNoResultsCategoryHint => 'Zkuste jinou kategorii nebo použijte obecnější klíčová slova';

  @override
  String get searchPageSortByLabel => 'Řadit podle';

  @override
  String get searchPageRelevanceLabel => 'Relevance';

  @override
  String searchPageTitle(String query) {
    return 'Výsledky pro „$query“';
  }

  @override
  String get aboutPageLabel => 'O aplikaci';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Verze $version';
  }

  @override
  String get aboutPageContributorTitle => 'Navrženo a vyvinuto:';

  @override
  String get aboutPageCommunityTitle => 'Staňte se součástí komunity:';

  @override
  String get aboutPageContributeLabel => 'Přispějte nebo nahlaste chybu';

  @override
  String get aboutPageGitHubLabel => 'Najděte si nás na GitHubu';

  @override
  String get aboutPagePublishLabel => 'Publikovat ve Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Dozvědět se více';

  @override
  String get appstreamUrlTypeBugtracker => 'Bugtracker';

  @override
  String get appstreamUrlTypeContact => 'Kontakt';

  @override
  String get appstreamUrlTypeContribute => 'Přispět';

  @override
  String get appstreamUrlTypeDonation => 'Věnovat dar';

  @override
  String get appstreamUrlTypeFaq => 'Často kladené dotazy';

  @override
  String get appstreamUrlTypeHelp => 'Nápověda';

  @override
  String get appstreamUrlTypeHomepage => 'Domovská stránka';

  @override
  String get appstreamUrlTypeTranslate => 'Překlady';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Zdrojový kód';

  @override
  String get packageFormatDebLabel => 'Balíčky Debian';

  @override
  String get packageFormatSnapLabel => 'Balíčky Snap';

  @override
  String get snapActionCancelLabel => 'Zrušit';

  @override
  String get snapActionInstallLabel => 'Instalovat';

  @override
  String get snapActionInstalledLabel => 'Nainstalováno';

  @override
  String get snapActionInstallingLabel => 'Instaluje se';

  @override
  String get snapActionOpenLabel => 'Otevřít';

  @override
  String get snapActionRemoveLabel => 'Odinstalovat';

  @override
  String get snapActionRemovingLabel => 'Odinstalace';

  @override
  String get snapActionSwitchChannelLabel => 'Přepnout kanál';

  @override
  String get snapActionUpdateLabel => 'Aktualizovat';

  @override
  String get snapCategoryAll => 'Všechny kategorie';

  @override
  String get snapActionUpdatingLabel => 'Aktualizace';

  @override
  String get snapCategoryArtAndDesign => 'Umění a design';

  @override
  String get snapCategoryBooksAndReference => 'Knihy a reference';

  @override
  String get snapCategoryDefaultButtonLabel => 'Objevit více';

  @override
  String get snapCategoryDevelopment => 'Vývoj';

  @override
  String get snapCategoryDevelopmentSlogan => 'Nepostradatelné snapy pro vývojáře';

  @override
  String get snapCategoryDevicesAndIot => 'Zařízení a IoT';

  @override
  String get snapCategoryEducation => 'Výuka';

  @override
  String get snapCategoryEntertainment => 'Zábava';

  @override
  String get snapCategoryFeatured => 'Významné';

  @override
  String get snapCategoryFeaturedSlogan => 'Významné Snapy';

  @override
  String get snapCategoryFinance => 'Finance';

  @override
  String get snapCategoryGames => 'Hry';

  @override
  String get snapCategoryGamesSlogan => 'Vše pro vaši herní noc';

  @override
  String get snapCategoryGameDev => 'Vývoj her';

  @override
  String get snapCategoryGameDevSlogan => 'Vývoj her';

  @override
  String get snapCategoryGameEmulators => 'Emulátory';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emulátory';

  @override
  String get snapCategoryGnomeGames => 'Hry GNOME';

  @override
  String get snapCategoryGnomeGamesSlogan => 'Sada her GNOME';

  @override
  String get snapCategoryKdeGames => 'Hry KDE';

  @override
  String get snapCategoryKdeGamesSlogan => 'Sada her KDE';

  @override
  String get snapCategoryGameLaunchers => 'Spouštěče her';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Spouštěče her';

  @override
  String get snapCategoryGameContentCreation => 'Tvorba obsahu';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Tvorba obsahu';

  @override
  String get snapCategoryHealthAndFitness => 'Zdraví a fitness';

  @override
  String get snapCategoryMusicAndAudio => 'Hudba a zvuk';

  @override
  String get snapCategoryNewsAndWeather => 'Zprávy a počasí';

  @override
  String get snapCategoryPersonalisation => 'Přizpůsobení';

  @override
  String get snapCategoryPhotoAndVideo => 'Fotografie a video';

  @override
  String get snapCategoryProductivity => 'Kancelář';

  @override
  String get snapCategoryProductivityButtonLabel => 'Objevte sbírku pro produktivitu';

  @override
  String get snapCategoryProductivitySlogan => 'Vyškrtněte jednu věc ze svého seznamu úkolů';

  @override
  String get snapCategoryScience => 'Věda';

  @override
  String get snapCategorySecurity => 'Bezpečnost';

  @override
  String get snapCategoryServerAndCloud => 'Server a cloud';

  @override
  String get snapCategorySocial => 'Sociální';

  @override
  String get snapCategoryUbuntuDesktop => 'Uživatelské prostředí Ubuntu';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Vylepšete své uživatelské prostředí';

  @override
  String get snapCategoryUtilities => 'Nástroje';

  @override
  String get snapConfinementClassic => 'Klasický';

  @override
  String get snapConfinementDevmode => 'Vývojářský režim';

  @override
  String get snapConfinementStrict => 'Striktní';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Abecedně (od A do Z)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Abecedně (od Z do A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Velikost (od nejmenší po největší)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Velikost (od největší po nejmenší)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Velikost (od nejmenší po největší)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Velikost (od největší po nejmenší)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Nejdéle neaktualizované';

  @override
  String get snapSortOrderInstalledDateDesc => 'Naposledy aktualizované';

  @override
  String get snapSortOrderRelevance => 'Relevance';

  @override
  String get snapRatingsBandVeryGood => 'Velmi dobré';

  @override
  String get snapRatingsBandGood => 'Dobré';

  @override
  String get snapRatingsBandNeutral => 'Neutrální';

  @override
  String get snapRatingsBandPoor => 'Špatné';

  @override
  String get snapRatingsBandVeryPoor => 'Velmi špatné';

  @override
  String get snapRatingsBandInsufficientVotes => 'Nedostatek hodnocení';

  @override
  String snapRatingsVotes(int n) {
    return '$n hodnocení';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Nahlásit $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Vyberte důvod nahlášení tohoto snapu';

  @override
  String get snapReportSelectAnOptionLabel => 'Vyberte možnost';

  @override
  String get snapReportOptionCopyrightViolation => 'Porušení autorských práv nebo ochranné známky';

  @override
  String get snapReportOptionStoreViolation => 'Porušení podmínek služby Snap Store';

  @override
  String get snapReportDetailsLabel => 'Uveďte prosím podrobnější důvod svého hlášení';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Váš e-mail (volitelné)';

  @override
  String get snapReportCancelButtonLabel => 'Zrušit';

  @override
  String get snapReportSubmitButtonLabel => 'Odeslat hlášení';

  @override
  String get snapReportEnterValidEmailError => 'Zadejte platnou e-mailovou adresu';

  @override
  String get snapReportDetailsHint => 'Komentář...';

  @override
  String get snapReportPrivacyAgreementLabel => 'Odesláním tohoto formuláře potvrzuji, že jsem četl(a) a souhlasím s ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'prohlášením společnosti Canonical o ochraně osobních údajů ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'a ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'zásadami ochrany osobních údajů';

  @override
  String get debPageErrorNoPackageInfo => 'Nenalezeny žádné informace o balíčku';

  @override
  String get externalResources => 'Další zdroje';

  @override
  String get externalResourcesButtonLabel => 'Objevit více';

  @override
  String get allGamesButtonLabel => 'Všechny hry';

  @override
  String get externalResourcesDisclaimer => 'Poznámka: Všechny tyto nástroje jsou externí. Nejsou vlastněny ani distribuovány společností Canonical.';

  @override
  String get openInBrowser => 'Otevřít v prohlížeči';

  @override
  String get installAll => 'Instalovat vše';

  @override
  String get localDebWarningTitle => 'Potenciálně nebezpečné';

  @override
  String get localDebWarningBody => 'Tento balíček poskytuje třetí strana. Instalace balíčků mimo Centrum aplikací může zvýšit riziko pro váš systém a osobní data. Než budete pokračovat, ujistěte se, že zdroji důvěřujete.';

  @override
  String get localDebLearnMore => 'Dozvědět se více o balíčcích třetích stran';

  @override
  String get localDebDialogMessage => 'Tento balíček je poskytován třetí stranou a může ohrozit váš systém a osobní data.';

  @override
  String get localDebDialogConfirmation => 'Jste si jisti, že jej chcete nainstalovat?';

  @override
  String snapdExceptionRunningApps(String snapName) {
    return 'Nemohli jsme aktualizovat $snapName, protože je aktuálně spuštěn.';
  }

  @override
  String get errorViewCheckStatusLabel => 'Zkontrolovat stav';

  @override
  String get errorViewNetworkErrorTitle => 'Připojit k internetu';

  @override
  String get errorViewNetworkErrorDescription => 'Bez připojení k internetu nemůžeme načíst obsah Centra aplikací.';

  @override
  String get errorViewNetworkErrorAction => 'Zkontrolujte připojení a zkuste to znovu.';

  @override
  String get errorViewServerErrorDescription => 'Je nám líto, ale v současné době dochází k problémům s Centrem aplikací.';

  @override
  String get errorViewServerErrorAction => 'Zkontrolujte aktualizace stavu nebo to zkuste znovu později.';

  @override
  String get errorViewUnknownErrorTitle => 'Něco se nepovedlo';

  @override
  String get errorViewUnknownErrorDescription => 'Je nám líto, ale nejsme si jisti, o jakou chybu se jedná.';

  @override
  String get errorViewUnknownErrorAction => 'Můžete to nyní zopakovat, zkontrolovat aktualizace stavu nebo to zkusit znovu později.';
}
