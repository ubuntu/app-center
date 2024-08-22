import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appCenterLabel => 'Centrum aplikácií';

  @override
  String get appstreamSearchGreylist => 'app;aplikácia;balík;program;softvér;sada;súprava;nástroj';

  @override
  String get snapPageChannelLabel => 'Kanál';

  @override
  String get snapPageConfinementLabel => 'Odizolovanie';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Kontaktovať $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Popis';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Webová stránka vývojára';

  @override
  String get snapPageDownloadSizeLabel => 'Veľkosť preberania';

  @override
  String get snapPageSizeLabel => 'Veľkosť';

  @override
  String get snapPageGalleryLabel => 'Galéria';

  @override
  String get snapPageLicenseLabel => 'Licencia';

  @override
  String get snapPageLinksLabel => 'Odkazy';

  @override
  String get snapPagePublisherLabel => 'Vydavateľ';

  @override
  String get snapPagePublishedLabel => 'Vydané';

  @override
  String get snapPageSummaryLabel => 'Zhrnutie';

  @override
  String get snapPageVersionLabel => 'Verzia';

  @override
  String get snapPageShareLinkCopiedMessage => 'Odkaz bol skopírovaný do schránky';

  @override
  String get explorePageLabel => 'Preskúmať';

  @override
  String get explorePageCategoriesLabel => 'Kategórie';

  @override
  String get managePageOwnUpdateAvailable => 'K dispozícii je aktualizácia centra aplikácií';

  @override
  String get managePageQuitToUpdate => 'Ukončite kvôli aktualizácii';

  @override
  String get managePageOwnUpdateDescription => 'Keď aplikáciu ukončíte, aktualizuje sa automaticky.';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return 'Centrum aplikácií sa automaticky aktualizuje o $time.';
  }

  @override
  String get managePageOwnUpdateQuitButton => 'Ukončiť a aktualizovať';

  @override
  String get managePageCheckForUpdates => 'Skontrolovať aktualizácie';

  @override
  String get managePageCheckingForUpdates => 'Kontrolujú sa aktualizácie';

  @override
  String get managePageNoInternet => 'Nedá sa pripojiť k serveru, skontrolujte internetové pripojenie alebo to skúste znova neskôr.';

  @override
  String get managePageDescription => 'Skontrolujte dostupné aktualizácie, aktualizujte svoje aplikácie a riaďte stav všetkých svojich aplikácií.';

  @override
  String get managePageDebUpdatesMessage => 'Aktualizácie balíkov debianu spravuje nástroj na aktualizáciu softvéru.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Nainštalované a aktualizované';

  @override
  String get managePageLabel => 'Riadiť nainštalované snapy';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Nie sú k dispozícii žiadne aktualizácie. Všetky vaše aplikácie sú aktuálne.';

  @override
  String get managePageSearchFieldSearchHint => 'Hľadať nainštalované aplikácie';

  @override
  String get managePageShowDetailsLabel => 'Zobraziť podrobnosti';

  @override
  String get managePageShowSystemSnapsLabel => 'Zobraziť systémové snapy';

  @override
  String get managePageUpdateAllLabel => 'Aktualizovať všetko';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dňami',
      one: '$n dňom',
    );
    return 'Obnovené pred $_temp0';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n týždňami',
      one: '$n týždňom',
    );
    return 'Obnovené pred $_temp0';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n mesiacmi',
      one: '$n mesiacom',
    );
    return 'Obnovené pred $_temp0';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n rokmi',
      one: '$n rokom',
    );
    return 'Obnovené pred $_temp0';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Dostupné aktualizácie ($n)';
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
  String get productivityPageLabel => 'Produktivita';

  @override
  String get developmentPageLabel => 'Vývoj';

  @override
  String get gamesPageLabel => 'Hry';

  @override
  String get gamesPageTitle => 'Populárne';

  @override
  String get gamesPageTop => 'Najlepšie hry';

  @override
  String get gamesPageFeatured => 'Odporúčané tituly';

  @override
  String get gamesPageBundles => 'Balíky aplikácií';

  @override
  String get unknownPublisher => 'Neznámy vydavateľ';

  @override
  String get searchFieldDebSection => 'Debian balíky';

  @override
  String get searchFieldSearchHint => 'Hľadať aplikácie';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Zobraziť všetky výsledky pre „$query“';
  }

  @override
  String get searchFieldSnapSection => 'Snap balíky';

  @override
  String get searchPageFilterByLabel => 'Filtrovať podľa';

  @override
  String searchPageNoResults(String query) {
    return 'Nenašli sa žiadne výsledky pre „$query“';
  }

  @override
  String get searchPageNoResultsHint => 'Skúste použiť iné alebo všeobecnejšie kľúčové slová';

  @override
  String get searchPageNoResultsCategory => 'Ľutujeme, v tejto kategórii sme nenašli žiadne balíky';

  @override
  String get searchPageNoResultsCategoryHint => 'Skúste inú kategóriu alebo použite všeobecnejšie kľúčové slová';

  @override
  String get searchPageSortByLabel => 'Zoradiť podľa';

  @override
  String get searchPageRelevanceLabel => 'Relevantnosť';

  @override
  String searchPageTitle(String query) {
    return 'Výsledky pre „$query“';
  }

  @override
  String get aboutPageLabel => 'O aplikácii';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Verzia $version';
  }

  @override
  String get aboutPageContributorTitle => 'Navrhnuté a vyvinuté:';

  @override
  String get aboutPageCommunityTitle => 'Staňte sa súčasťou komunity:';

  @override
  String get aboutPageContributeLabel => 'Prispejte alebo nahláste chybu';

  @override
  String get aboutPageGitHubLabel => 'Nájdete nás na GitHube';

  @override
  String get aboutPagePublishLabel => 'Uverejniť na Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Zistiť viac';

  @override
  String get appstreamUrlTypeBugtracker => 'Sledovanie chýb';

  @override
  String get appstreamUrlTypeContact => 'Kontakt';

  @override
  String get appstreamUrlTypeContribute => 'Prispieť';

  @override
  String get appstreamUrlTypeDonation => 'Darovať';

  @override
  String get appstreamUrlTypeFaq => 'Často kladené otázky';

  @override
  String get appstreamUrlTypeHelp => 'Pomocník';

  @override
  String get appstreamUrlTypeHomepage => 'Domovská stránka';

  @override
  String get appstreamUrlTypeTranslate => 'Preklady';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Zdroj';

  @override
  String get packageFormatDebLabel => 'Debian balíky';

  @override
  String get packageFormatSnapLabel => 'Snap balíky';

  @override
  String get snapActionCancelLabel => 'Zrušiť';

  @override
  String get snapActionInstallLabel => 'Inštalovať';

  @override
  String get snapActionInstalledLabel => 'Nainštalované';

  @override
  String get snapActionInstallingLabel => 'Inštaluje sa';

  @override
  String get snapActionOpenLabel => 'Otvoriť';

  @override
  String get snapActionRemoveLabel => 'Odinštalovať';

  @override
  String get snapActionRemovingLabel => 'Odinštaluje sa';

  @override
  String get snapActionSwitchChannelLabel => 'Prepnúť kanál';

  @override
  String get snapActionUpdateLabel => 'Aktualizovať';

  @override
  String get snapCategoryAll => 'Všetky kategórie';

  @override
  String get snapActionUpdatingLabel => 'Aktualizuje sa';

  @override
  String get snapCategoryArtAndDesign => 'Umenie a dizajn';

  @override
  String get snapCategoryBooksAndReference => 'Knihy a referencie';

  @override
  String get snapCategoryDefaultButtonLabel => 'Objavte viac';

  @override
  String get snapCategoryDevelopment => 'Vývoj';

  @override
  String get snapCategoryDevelopmentSlogan => 'Nevyhnutné snapy pre vývojárov';

  @override
  String get snapCategoryDevicesAndIot => 'Zariadenia a IoT';

  @override
  String get snapCategoryEducation => 'Vzdelávanie';

  @override
  String get snapCategoryEntertainment => 'Zábava';

  @override
  String get snapCategoryFeatured => 'Odporúčané';

  @override
  String get snapCategoryFeaturedSlogan => 'Odporúčané snapy';

  @override
  String get snapCategoryFinance => 'Financie';

  @override
  String get snapCategoryGames => 'Hry';

  @override
  String get snapCategoryGamesSlogan => 'Všetko pre váš herný večer';

  @override
  String get snapCategoryGameDev => 'Vývoj hier';

  @override
  String get snapCategoryGameDevSlogan => 'Vývoj hier';

  @override
  String get snapCategoryGameEmulators => 'Emulátory';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emulátory';

  @override
  String get snapCategoryGnomeGames => 'Hry GNOME';

  @override
  String get snapCategoryGnomeGamesSlogan => 'Zostava hier GNOME';

  @override
  String get snapCategoryKdeGames => 'Hry KDE';

  @override
  String get snapCategoryKdeGamesSlogan => 'Zostava hier KDE';

  @override
  String get snapCategoryGameLaunchers => 'Spúšťače hier';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Spúšťanie hier';

  @override
  String get snapCategoryGameContentCreation => 'Tvorba obsahu';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Vytváranie obsahu';

  @override
  String get snapCategoryHealthAndFitness => 'Zdravie a fitnes';

  @override
  String get snapCategoryMusicAndAudio => 'Hudba a zvuk';

  @override
  String get snapCategoryNewsAndWeather => 'Správy a počasie';

  @override
  String get snapCategoryPersonalisation => 'Prispôsobenie';

  @override
  String get snapCategoryPhotoAndVideo => 'Foto a video';

  @override
  String get snapCategoryProductivity => 'Produktivita';

  @override
  String get snapCategoryProductivityButtonLabel => 'Objavte zbierku produktivity';

  @override
  String get snapCategoryProductivitySlogan => 'Vyškrtnite jednu vec zo zoznamu úloh';

  @override
  String get snapCategoryScience => 'Veda';

  @override
  String get snapCategorySecurity => 'Bezpečnosť';

  @override
  String get snapCategoryServerAndCloud => 'Server a cloud';

  @override
  String get snapCategorySocial => 'Sociálne';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu pracovná plocha';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Rýchly štart vašej pracovnej plochy';

  @override
  String get snapCategoryUtilities => 'Nástroje';

  @override
  String get snapConfinementClassic => 'Klasické';

  @override
  String get snapConfinementDevmode => 'Vývojové';

  @override
  String get snapConfinementStrict => 'Prísne';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Abecedy (od A po Z)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Abecedy (od Z po A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Veľkosti (od najmenšieho po najväčší)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Veľkosti (od najväčšieho po najmenší)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Veľkosti (od najmenšieho po najväčší)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Veľkosti (od najväčšieho po najmenší)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Najmenej aktualizované';

  @override
  String get snapSortOrderInstalledDateDesc => 'Najviac aktualizované';

  @override
  String get snapSortOrderRelevance => 'Relevantnosti';

  @override
  String get snapRatingsBandVeryGood => 'Veľmi dobré';

  @override
  String get snapRatingsBandGood => 'Dobré';

  @override
  String get snapRatingsBandNeutral => 'Neutrálne';

  @override
  String get snapRatingsBandPoor => 'Zlé';

  @override
  String get snapRatingsBandVeryPoor => 'Veľmi zlé';

  @override
  String get snapRatingsBandInsufficientVotes => 'Nedostatok hlasov';

  @override
  String snapRatingsVotes(int n) {
    return '$n hlasov';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Nahlásiť $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Vyberte dôvod nahlásenia tohto snapu';

  @override
  String get snapReportSelectAnOptionLabel => 'Vyberte možnosť';

  @override
  String get snapReportOptionCopyrightViolation => 'Porušenie autorských práv alebo ochrannej známky';

  @override
  String get snapReportOptionStoreViolation => 'Porušenie zmluvných podmienok obchodu Snap Store';

  @override
  String get snapReportDetailsLabel => 'Prosím, uveďte podrobnejší dôvod svojho hlásenia';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Váš e-mail (voliteľné)';

  @override
  String get snapReportCancelButtonLabel => 'Zrušiť';

  @override
  String get snapReportSubmitButtonLabel => 'Odoslať hlásenie';

  @override
  String get snapReportEnterValidEmailError => 'Zadajte platnú e-mailovú adresu';

  @override
  String get snapReportDetailsHint => 'Objasnenie...';

  @override
  String get snapReportPrivacyAgreementLabel => 'Odoslaním tohto formulára potvrdzujem, že som si prečítal(a) a súhlasím s ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Ochranou údajov Canonical ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'a ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'Zásadami ochrany';

  @override
  String get debPageErrorNoPackageInfo => 'Nenašli sa žiadne informácie o balíku';

  @override
  String get externalResources => 'Dodatočné zdroje';

  @override
  String get externalResourcesButtonLabel => 'Nájdite viac';

  @override
  String get allGamesButtonLabel => 'Všetky hry';

  @override
  String get externalResourcesDisclaimer => 'Poznámka: Toto všetko sú externé nástroje. Nie sú vlastnené ani distribuované spoločnosťou Canonical.';

  @override
  String get openInBrowser => 'Otvoriť v prehliadači';

  @override
  String get installAll => 'Inštalovať všetko';

  @override
  String get localDebWarningTitle => 'Potenciálne nebezpečné';

  @override
  String get localDebWarningBody => 'Tento balík poskytuje tretia strana. Inštalácia balíkov mimo Centra aplikácií môže zvýšiť riziko pre váš systém a osobné údaje. Pred pokračovaním sa uistite, že zdroju dôverujete.';

  @override
  String get localDebLearnMore => 'Získajte viac informácií o balíkoch tretích strán';

  @override
  String get localDebDialogMessage => 'Tento balík poskytuje tretia strana a môže ohroziť váš systém a osobné údaje.';

  @override
  String get localDebDialogConfirmation => 'Naozaj ho chcete nainštalovať?';

  @override
  String snapdExceptionRunningApps(String snapName) {
    return 'Nepodarilo sa aktualizovať $snapName, pretože je momentálne spustený.';
  }

  @override
  String get errorViewCheckStatusLabel => 'Skontrolovať stav';

  @override
  String get errorViewNetworkErrorTitle => 'Pripojenie na internet';

  @override
  String get errorViewNetworkErrorDescription => 'Bez internetového pripojenia nie je možné načítať obsah v Centre aplikácií.';

  @override
  String get errorViewNetworkErrorAction => 'Skontrolujte pripojenie a skúste to znova.';

  @override
  String get errorViewServerErrorDescription => 'Ľutujeme, momentálne máme problémy s centrom aplikácií.';

  @override
  String get errorViewServerErrorAction => 'Skontrolujte stav aktualizácií alebo to skúste znova neskôr.';

  @override
  String get errorViewUnknownErrorTitle => 'Niečo sa pokazilo';

  @override
  String get errorViewUnknownErrorDescription => 'Ľutujeme, ale nie sme si istí, v čom je chyba.';

  @override
  String get errorViewUnknownErrorAction => 'Môžete to skúsiť znova, skontrolovať stav aktualizácií alebo to skúsiť znova neskôr.';
}
