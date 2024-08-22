import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appCenterLabel => 'Centrum oprogramowania';

  @override
  String get appstreamSearchGreylist => 'apka;aplikacja;pakiet;program;oprogramowanie;pakiet;narzędzie';

  @override
  String get snapPageChannelLabel => 'Kanał';

  @override
  String get snapPageConfinementLabel => 'Ograniczenia';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Skontaktuj się z $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Opis';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Witryna twórców';

  @override
  String get snapPageDownloadSizeLabel => 'Rozmiar pobierania';

  @override
  String get snapPageSizeLabel => 'Rozmiar';

  @override
  String get snapPageGalleryLabel => 'Galeria';

  @override
  String get snapPageLicenseLabel => 'Licencja';

  @override
  String get snapPageLinksLabel => 'Łącza';

  @override
  String get snapPagePublisherLabel => 'Wydawca';

  @override
  String get snapPagePublishedLabel => 'Opublikowano';

  @override
  String get snapPageSummaryLabel => 'Podsumowanie';

  @override
  String get snapPageVersionLabel => 'Wersja';

  @override
  String get snapPageShareLinkCopiedMessage => 'Łącze skopiowane do schowka';

  @override
  String get explorePageLabel => 'Przeglądaj';

  @override
  String get explorePageCategoriesLabel => 'Kategorie';

  @override
  String get managePageOwnUpdateAvailable => 'Dostępna aktualizacja Centrum oprogramowania';

  @override
  String get managePageQuitToUpdate => 'Zamknij, aby zaktualizować';

  @override
  String get managePageOwnUpdateDescription => 'Po zamknięciu programu zostanie on automatycznie zaktualizowany.';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return 'Centrum oprogramowania zostanie automatycznie zaktualizowane za $time.';
  }

  @override
  String get managePageOwnUpdateQuitButton => 'Zamknij, aby zaktualizować';

  @override
  String get managePageCheckForUpdates => 'Sprawdź dostępność aktualizacji';

  @override
  String get managePageCheckingForUpdates => 'Sprawdzanie aktualizacji';

  @override
  String get managePageNoInternet => 'Nie można połączyć się z serwerem. Sprawdź połączenie internetowe lub spróbuj ponownie później.';

  @override
  String get managePageDescription => 'Sprawdzaj dostępne aktualizacje, aktualizuj swoje programy i zarządzaj stanem ich wszystkich.';

  @override
  String get managePageDebUpdatesMessage => 'Aktualizacje pakietów Debiana są obsługiwane przez aktualizator oprogramowania.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Zainstalowane i zaktualizowane';

  @override
  String get managePageLabel => 'Zarządzaj zainstalowanymi snapami';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Brak dostępnych aktualizacji. Wszystkie programy są aktualne.';

  @override
  String get managePageSearchFieldSearchHint => 'Wyszukiwanie zainstalowanych programów';

  @override
  String get managePageShowDetailsLabel => 'Pokaż szczegóły';

  @override
  String get managePageShowSystemSnapsLabel => 'Pokaż snapy systemowe';

  @override
  String get managePageUpdateAllLabel => 'Zaktualizuj wszystkie';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dni',
      many: '$n dni',
      few: '$n dni',
      one: '$n dzień',
    );
    return 'Zaktualizowano $_temp0 temu';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tygodni',
      many: '$n tygodni',
      few: '$n tygodnie',
      one: '$n tydzień',
    );
    return 'Zaktualizowano $_temp0 temu';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n miesięcy',
      many: '$n miesięcy',
      few: '$n miesiące',
      one: '$n miesiąc',
    );
    return 'Zaktualizowano $_temp0 temu';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n lat',
      many: '$n lat',
      few: '$n lata',
      one: '$n rok',
    );
    return 'Zaktualizowano $_temp0 temu';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Dostępne aktualizacje ($n)';
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
  String get productivityPageLabel => 'Produktywność';

  @override
  String get developmentPageLabel => 'Programowanie';

  @override
  String get gamesPageLabel => 'Gry';

  @override
  String get gamesPageTitle => 'Co jest na topie';

  @override
  String get gamesPageTop => 'Najpopularniejsze gry';

  @override
  String get gamesPageFeatured => 'Polecane tytuły';

  @override
  String get gamesPageBundles => 'Pakiety oprogramowania';

  @override
  String get unknownPublisher => 'Wydawca nieznany';

  @override
  String get searchFieldDebSection => 'Pakiety systemu Debian';

  @override
  String get searchFieldSearchHint => 'Wyszukiwanie programów';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Zobacz wszystkie wyniki „$query”';
  }

  @override
  String get searchFieldSnapSection => 'Pakiety snap';

  @override
  String get searchPageFilterByLabel => 'Filtruj według';

  @override
  String searchPageNoResults(String query) {
    return 'Nie znaleziono wyników „$query”';
  }

  @override
  String get searchPageNoResultsHint => 'Spróbuj użyć innych lub bardziej ogólnych słów kluczowych';

  @override
  String get searchPageNoResultsCategory => 'Przepraszamy, nie znaleźliśmy żadnych pakietów w tej kategorii';

  @override
  String get searchPageNoResultsCategoryHint => 'Wypróbuj inną kategorię lub użyj bardziej ogólnych słów kluczowych';

  @override
  String get searchPageSortByLabel => 'Sortuj według';

  @override
  String get searchPageRelevanceLabel => 'Znaczenie';

  @override
  String searchPageTitle(String query) {
    return 'Wyniki „$query”';
  }

  @override
  String get aboutPageLabel => 'O programie';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Wersja $version';
  }

  @override
  String get aboutPageContributorTitle => 'Zaprojektowano i opracowano przez:';

  @override
  String get aboutPageCommunityTitle => 'Bądź częścią społeczności:';

  @override
  String get aboutPageContributeLabel => 'Przyczyń się lub zgłoś błąd';

  @override
  String get aboutPageGitHubLabel => 'Znajdź nas na GitHubie';

  @override
  String get aboutPagePublishLabel => 'Opublikuj w Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Dowiedz się więcej';

  @override
  String get appstreamUrlTypeBugtracker => 'Śledzenie błędów';

  @override
  String get appstreamUrlTypeContact => 'Kontakt';

  @override
  String get appstreamUrlTypeContribute => 'Przyczyń się';

  @override
  String get appstreamUrlTypeDonation => 'Wspomóż';

  @override
  String get appstreamUrlTypeFaq => 'Często zadawane pytania';

  @override
  String get appstreamUrlTypeHelp => 'Pomoc';

  @override
  String get appstreamUrlTypeHomepage => 'Strona główna';

  @override
  String get appstreamUrlTypeTranslate => 'Tłumaczenia';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Źródło';

  @override
  String get packageFormatDebLabel => 'Pakiety systemu Debian';

  @override
  String get packageFormatSnapLabel => 'Pakiety snap';

  @override
  String get snapActionCancelLabel => 'Anuluj';

  @override
  String get snapActionInstallLabel => 'Zainstaluj';

  @override
  String get snapActionInstalledLabel => 'Zainstalowano';

  @override
  String get snapActionInstallingLabel => 'Instalowanie';

  @override
  String get snapActionOpenLabel => 'Otwórz';

  @override
  String get snapActionRemoveLabel => 'Odinstaluj';

  @override
  String get snapActionRemovingLabel => 'Odinstalowywanie';

  @override
  String get snapActionSwitchChannelLabel => 'Przełącz kanał';

  @override
  String get snapActionUpdateLabel => 'Aktualizuj';

  @override
  String get snapCategoryAll => 'Wszystkie kategorie';

  @override
  String get snapActionUpdatingLabel => 'Aktualizowanie';

  @override
  String get snapCategoryArtAndDesign => 'Sztuka i projektowanie';

  @override
  String get snapCategoryBooksAndReference => 'Książki i źródła';

  @override
  String get snapCategoryDefaultButtonLabel => 'Odkryj więcej';

  @override
  String get snapCategoryDevelopment => 'Programowanie';

  @override
  String get snapCategoryDevelopmentSlogan => 'Snapy obowiązkowe dla programistów';

  @override
  String get snapCategoryDevicesAndIot => 'Urządzenia i IoT';

  @override
  String get snapCategoryEducation => 'Edukacja';

  @override
  String get snapCategoryEntertainment => 'Rozrywka';

  @override
  String get snapCategoryFeatured => 'Polecane';

  @override
  String get snapCategoryFeaturedSlogan => 'Polecane snapy';

  @override
  String get snapCategoryFinance => 'Finanse';

  @override
  String get snapCategoryGames => 'Gry';

  @override
  String get snapCategoryGamesSlogan => 'Wszystko na wieczór z grami';

  @override
  String get snapCategoryGameDev => 'Tworzenie gier';

  @override
  String get snapCategoryGameDevSlogan => 'Tworzenie gier';

  @override
  String get snapCategoryGameEmulators => 'Emulatory';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emulatory';

  @override
  String get snapCategoryGnomeGames => 'Gry GNOME';

  @override
  String get snapCategoryGnomeGamesSlogan => 'Zestaw gier GNOME';

  @override
  String get snapCategoryKdeGames => 'Gry KDE';

  @override
  String get snapCategoryKdeGamesSlogan => 'Zestaw gier KDE';

  @override
  String get snapCategoryGameLaunchers => 'Programy uruchamiające gry';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Programy uruchamiające gry';

  @override
  String get snapCategoryGameContentCreation => 'Tworzenie treści';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Tworzenie treści';

  @override
  String get snapCategoryHealthAndFitness => 'Zdrowie i fitness';

  @override
  String get snapCategoryMusicAndAudio => 'Muzyka i dźwięk';

  @override
  String get snapCategoryNewsAndWeather => 'Wiadomości i pogoda';

  @override
  String get snapCategoryPersonalisation => 'Personalizacja';

  @override
  String get snapCategoryPhotoAndVideo => 'Zdjęcia i wideo';

  @override
  String get snapCategoryProductivity => 'Produktywność';

  @override
  String get snapCategoryProductivityButtonLabel => 'Odkryj kolekcję produktywności';

  @override
  String get snapCategoryProductivitySlogan => 'Skreśl jedną pozycję ze swojej listy rzeczy do zrobienia';

  @override
  String get snapCategoryScience => 'Nauka';

  @override
  String get snapCategorySecurity => 'Bezpieczeństwo';

  @override
  String get snapCategoryServerAndCloud => 'Serwer i chmura';

  @override
  String get snapCategorySocial => 'Społeczność';

  @override
  String get snapCategoryUbuntuDesktop => 'Pulpit Ubuntu';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Uruchom swój pulpit';

  @override
  String get snapCategoryUtilities => 'Narzędzia';

  @override
  String get snapConfinementClassic => 'Klasyczne';

  @override
  String get snapConfinementDevmode => 'Deweloperskie';

  @override
  String get snapConfinementStrict => 'Ścisłe';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Alfabetycznie (od A do Z)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Alfabetycznie (od Z do A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Rozmiar (od najmniejszego do największego)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Rozmiar (od największego do najmniejszego)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Rozmiar (od najmniejszego do największego)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Rozmiar (od największego do najmniejszego)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Najdawniej zaktualizowane';

  @override
  String get snapSortOrderInstalledDateDesc => 'Ostatnio zaktualizowane';

  @override
  String get snapSortOrderRelevance => 'Znaczenie';

  @override
  String get snapRatingsBandVeryGood => 'Bardzo dobre';

  @override
  String get snapRatingsBandGood => 'Dobre';

  @override
  String get snapRatingsBandNeutral => 'Neutralne';

  @override
  String get snapRatingsBandPoor => 'Słabe';

  @override
  String get snapRatingsBandVeryPoor => 'Bardzo słabe';

  @override
  String get snapRatingsBandInsufficientVotes => 'Niewystarczająca liczba głosów';

  @override
  String snapRatingsVotes(int n) {
    return 'Głosów: $n';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Zgłoś $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Wybierz powód zgłoszenia tego snapa';

  @override
  String get snapReportSelectAnOptionLabel => 'Wybierz opcję';

  @override
  String get snapReportOptionCopyrightViolation => 'Prawa autorskie lub naruszenie znaku towarowego';

  @override
  String get snapReportOptionStoreViolation => 'Warunki naruszenia usługi Snap Store';

  @override
  String get snapReportDetailsLabel => 'Podaj bardziej szczegółowy powód zgłoszenia';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Twój e-mail (opcjonalnie)';

  @override
  String get snapReportCancelButtonLabel => 'Anuluj';

  @override
  String get snapReportSubmitButtonLabel => 'Prześlij zgłoszenie';

  @override
  String get snapReportEnterValidEmailError => 'Podaj ważny adres e -mail';

  @override
  String get snapReportDetailsHint => 'Komentarz...';

  @override
  String get snapReportPrivacyAgreementLabel => 'Przesyłając ten formularz, potwierdzam przeczytanie i akceptację ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'oświadczenia o ochronie prywatności ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'i ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'polityki prywatności firmy Canonical';

  @override
  String get debPageErrorNoPackageInfo => 'Nie znaleziono informacji o pakiecie';

  @override
  String get externalResources => 'Dodatkowe zasoby';

  @override
  String get externalResourcesButtonLabel => 'Odkryj więcej';

  @override
  String get allGamesButtonLabel => 'Wszystkie gry';

  @override
  String get externalResourcesDisclaimer => 'Uwaga: wszystkie te narzędzia są zewnętrzne. Nie są własnością firmy Canonical i nie są przez nią dystrybuowane.';

  @override
  String get openInBrowser => 'Otwórz w przeglądarce';

  @override
  String get installAll => 'Zainstaluj wszystkie';

  @override
  String get localDebWarningTitle => 'Potencjalnie niebezpieczne';

  @override
  String get localDebWarningBody => 'Pakiet ten jest dostarczany przez innego dostawcę. Instalowanie pakietów spoza Centrum oprogramowania może zwiększyć ryzyko w przypadku systemu i prywatnych danych. Zanim przejdziesz dalej, upewnij się, że ufasz źródłu.';

  @override
  String get localDebLearnMore => 'Dowiedz się więcej o pakietach innych dostawców';

  @override
  String get localDebDialogMessage => 'Ten pakiet jest dostarczany przez innego dostawcę, może zagrozić systemowi i prywatnym danym.';

  @override
  String get localDebDialogConfirmation => 'Czy na pewno chcesz to zainstalować?';

  @override
  String snapdExceptionRunningApps(String snapName) {
    return 'Nie mogliśmy zaktualizować programu $snapName, ponieważ jest on aktualnie uruchomiony.';
  }

  @override
  String get errorViewCheckStatusLabel => 'Sprawdź stan';

  @override
  String get errorViewNetworkErrorTitle => 'Połącz się z Internetem';

  @override
  String get errorViewNetworkErrorDescription => 'Nie możemy wczytać treści w Centrum oprogramowania bez połączenia z Internetem.';

  @override
  String get errorViewNetworkErrorAction => 'Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get errorViewServerErrorDescription => 'Przepraszamy, obecnie występują problemy z Centrum oprogramowania.';

  @override
  String get errorViewServerErrorAction => 'Sprawdź stan aktualizacji lub spróbuj ponownie później.';

  @override
  String get errorViewUnknownErrorTitle => 'Coś poszło źle';

  @override
  String get errorViewUnknownErrorDescription => 'Przepraszamy, ale nie jesteśmy pewni, na czym polega błąd.';

  @override
  String get errorViewUnknownErrorAction => 'Możesz spróbować ponownie teraz, sprawdzić stan aktualizacji lub spróbować ponownie później.';
}
