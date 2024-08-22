import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appCenterLabel => 'Appcentral';

  @override
  String get appstreamSearchGreylist => 'app;program;paket;svit;verktyg';

  @override
  String get snapPageChannelLabel => 'Kanal';

  @override
  String get snapPageConfinementLabel => 'Isolering';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Kontakt $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Beskrivning';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Utvecklarens webbplats';

  @override
  String get snapPageDownloadSizeLabel => 'Nedladdningsstorlek';

  @override
  String get snapPageSizeLabel => 'Storlek';

  @override
  String get snapPageGalleryLabel => 'Galleri';

  @override
  String get snapPageLicenseLabel => 'Licens';

  @override
  String get snapPageLinksLabel => 'Länkar';

  @override
  String get snapPagePublisherLabel => 'Utgivare';

  @override
  String get snapPagePublishedLabel => 'Publicerades';

  @override
  String get snapPageSummaryLabel => 'Sammanfattning';

  @override
  String get snapPageVersionLabel => 'Version';

  @override
  String get snapPageShareLinkCopiedMessage => 'Länk kopierad till urklipp';

  @override
  String get explorePageLabel => 'Utforska';

  @override
  String get explorePageCategoriesLabel => 'Kategorier';

  @override
  String get managePageOwnUpdateAvailable => 'Appcentral uppdatering är tillgänglig';

  @override
  String get managePageQuitToUpdate => 'Avsluta för att uppdatera';

  @override
  String get managePageOwnUpdateDescription => 'När du avslutar programmet uppdateras det automatiskt.';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return 'Appcentral kommer automatiskt att uppdateras om $time.';
  }

  @override
  String get managePageOwnUpdateQuitButton => 'Avsluta vid uppdatering';

  @override
  String get managePageCheckForUpdates => 'Sök efter uppdateringar';

  @override
  String get managePageCheckingForUpdates => 'Söker efter uppdateringar';

  @override
  String get managePageNoInternet => 'Kan inte nå servern, kontrollera din internetanslutning eller försök igen senare.';

  @override
  String get managePageDescription => 'Sök efter tillgängliga uppdateringar, uppdatera dina appar och hantera statusen för alla dina appar.';

  @override
  String get managePageDebUpdatesMessage => 'Debian paket uppdateringar hanteras av Appcentralen.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Installerade och uppdaterade';

  @override
  String get managePageLabel => 'Hantera installerade snaps';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Inga uppdateringar tillgängliga. Dina applikationer är redan alla uppdaterade.';

  @override
  String get managePageSearchFieldSearchHint => 'Sök bland dina installerade program';

  @override
  String get managePageShowDetailsLabel => 'Visa detaljer';

  @override
  String get managePageShowSystemSnapsLabel => 'Visa systemets snap-paket';

  @override
  String get managePageUpdateAllLabel => 'Uppdatera alla';

  @override
  String managePageUpdatedDaysAgo(int n) {
    return 'Uppdaterades $n dagar sedan';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n veckor',
      one: '$n vecka',
    );
    return 'Uppdaterades för $_temp0 sedan';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n månader',
      one: '$n månad',
    );
    return 'Uppdaterades för $_temp0 sedan';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n år',
      one: '$n år',
    );
    return 'Uppdaterades för $_temp0 sedan';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Uppdateringar tillgängliga ($n)';
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
  String get developmentPageLabel => 'Utveckling';

  @override
  String get gamesPageLabel => 'Spel';

  @override
  String get gamesPageTitle => 'Vad är hett';

  @override
  String get gamesPageTop => 'Toppspel';

  @override
  String get gamesPageFeatured => 'Utvalda titlar';

  @override
  String get gamesPageBundles => 'Programbundlingar';

  @override
  String get unknownPublisher => 'Okänd utgivare';

  @override
  String get searchFieldDebSection => 'Debian paket';

  @override
  String get searchFieldSearchHint => 'Sök efter program';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Se alla resultat för \"$query\"';
  }

  @override
  String get searchFieldSnapSection => 'Snap paket';

  @override
  String get searchPageFilterByLabel => 'Filtrera efter';

  @override
  String searchPageNoResults(String query) {
    return 'Inga resultat för \"$query\"';
  }

  @override
  String get searchPageNoResultsHint => 'Prova att använda andra eller mer allmänna nyckelord';

  @override
  String get searchPageNoResultsCategory => 'Vi kunde tyvärr inte hitta några paket i den här kategorin';

  @override
  String get searchPageNoResultsCategoryHint => 'Prova en annan kategori eller använd mer allmänna nyckelord';

  @override
  String get searchPageSortByLabel => 'Sortera efter';

  @override
  String get searchPageRelevanceLabel => 'Relevans';

  @override
  String searchPageTitle(String query) {
    return 'Resultat för \"$query\"';
  }

  @override
  String get aboutPageLabel => 'Om';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPageContributorTitle => 'Designad och utvecklad av:';

  @override
  String get aboutPageCommunityTitle => 'Var en del av gemenskapen:';

  @override
  String get aboutPageContributeLabel => 'Bidra eller rapportera fel';

  @override
  String get aboutPageGitHubLabel => 'Hitta oss på GitHub';

  @override
  String get aboutPagePublishLabel => 'Publicera till Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Läs mer';

  @override
  String get appstreamUrlTypeBugtracker => 'Felspårare';

  @override
  String get appstreamUrlTypeContact => 'Kontakta';

  @override
  String get appstreamUrlTypeContribute => 'Bidra';

  @override
  String get appstreamUrlTypeDonation => 'Donera';

  @override
  String get appstreamUrlTypeFaq => 'FAQ';

  @override
  String get appstreamUrlTypeHelp => 'Hjälp';

  @override
  String get appstreamUrlTypeHomepage => 'Hemsida';

  @override
  String get appstreamUrlTypeTranslate => 'Översättningar';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Källkod';

  @override
  String get packageFormatDebLabel => 'Debian paket';

  @override
  String get packageFormatSnapLabel => 'Snap paket';

  @override
  String get snapActionCancelLabel => 'Avbryt';

  @override
  String get snapActionInstallLabel => 'Installera';

  @override
  String get snapActionInstalledLabel => 'Installerad';

  @override
  String get snapActionInstallingLabel => 'Installerar';

  @override
  String get snapActionOpenLabel => 'Öppna';

  @override
  String get snapActionRemoveLabel => 'Avinstallera';

  @override
  String get snapActionRemovingLabel => 'Avinstallerar';

  @override
  String get snapActionSwitchChannelLabel => 'Byt kanal';

  @override
  String get snapActionUpdateLabel => 'Uppdatera';

  @override
  String get snapCategoryAll => 'Alla kategorier';

  @override
  String get snapActionUpdatingLabel => 'Uppdaterar';

  @override
  String get snapCategoryArtAndDesign => 'Konst och Design';

  @override
  String get snapCategoryBooksAndReference => 'Böcker och Referens';

  @override
  String get snapCategoryDefaultButtonLabel => 'Upptäck mer';

  @override
  String get snapCategoryDevelopment => 'Utveckling';

  @override
  String get snapCategoryDevelopmentSlogan => 'Måste-ha snaps för utvecklare';

  @override
  String get snapCategoryDevicesAndIot => 'Enheter och IoT';

  @override
  String get snapCategoryEducation => 'Utbildning';

  @override
  String get snapCategoryEntertainment => 'Underhållning';

  @override
  String get snapCategoryFeatured => 'Utvalda';

  @override
  String get snapCategoryFeaturedSlogan => 'Utvalda Snaps';

  @override
  String get snapCategoryFinance => 'Finans';

  @override
  String get snapCategoryGames => 'Spel';

  @override
  String get snapCategoryGamesSlogan => 'Allt för din spelkväll';

  @override
  String get snapCategoryGameDev => 'Spelutveckling';

  @override
  String get snapCategoryGameDevSlogan => 'Spelutveckling';

  @override
  String get snapCategoryGameEmulators => 'Emulatorer';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emulatorer';

  @override
  String get snapCategoryGnomeGames => 'GNOME spel';

  @override
  String get snapCategoryGnomeGamesSlogan => 'GNOME spelsvit';

  @override
  String get snapCategoryKdeGames => 'KDE spel';

  @override
  String get snapCategoryKdeGamesSlogan => 'KDE spelsvit';

  @override
  String get snapCategoryGameLaunchers => 'Spelstartare';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Spelstartare';

  @override
  String get snapCategoryGameContentCreation => 'Innehållsskapande';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Innehållsskapande';

  @override
  String get snapCategoryHealthAndFitness => 'Hälsa och träning';

  @override
  String get snapCategoryMusicAndAudio => 'Musik och Ljud';

  @override
  String get snapCategoryNewsAndWeather => 'Nyheter och väder';

  @override
  String get snapCategoryPersonalisation => 'Personalisering';

  @override
  String get snapCategoryPhotoAndVideo => 'Foto och Video';

  @override
  String get snapCategoryProductivity => 'Produktivitet';

  @override
  String get snapCategoryProductivityButtonLabel => 'Upptäck produktivitets samlingen';

  @override
  String get snapCategoryProductivitySlogan => 'Stryk en sak från din att göra-lista';

  @override
  String get snapCategoryScience => 'Vetenskap';

  @override
  String get snapCategorySecurity => 'Säkerhet';

  @override
  String get snapCategoryServerAndCloud => 'Server och moln';

  @override
  String get snapCategorySocial => 'Social';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu skrivbord';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Sätt igång ditt skrivbord';

  @override
  String get snapCategoryUtilities => 'Verktyg';

  @override
  String get snapConfinementClassic => 'Klassisk';

  @override
  String get snapConfinementDevmode => 'Utvecklarläge';

  @override
  String get snapConfinementStrict => 'Strikt';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Alfabetisk (A till Ö)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Alfabetisk (Z till A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Storlek (minst till störst)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Storlek (störst till minst)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Storlek (minsta till största)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Storlek (största till minsta)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Minst nyligen uppdaterade';

  @override
  String get snapSortOrderInstalledDateDesc => 'Mest senast uppdaterade';

  @override
  String get snapSortOrderRelevance => 'Relevans';

  @override
  String get snapRatingsBandVeryGood => 'Väldigt bra';

  @override
  String get snapRatingsBandGood => 'Bra';

  @override
  String get snapRatingsBandNeutral => 'Neutral';

  @override
  String get snapRatingsBandPoor => 'Dålig';

  @override
  String get snapRatingsBandVeryPoor => 'Väldigt dålig';

  @override
  String get snapRatingsBandInsufficientVotes => 'Inte tillräckligt med röster';

  @override
  String snapRatingsVotes(int n) {
    return '$n röster';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Rapportera $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Välj en anledning varför du vill rapportera denna snap';

  @override
  String get snapReportSelectAnOptionLabel => 'Välj ett alternativ';

  @override
  String get snapReportOptionCopyrightViolation => 'Upphovsrätts eller varumärkesintrång';

  @override
  String get snapReportOptionStoreViolation => 'Överträdelse av användarvillkoren för Snap Store';

  @override
  String get snapReportDetailsLabel => 'Vänligen ange en mer detaljerad anledning till din rapport';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Din e-postadress (valfritt)';

  @override
  String get snapReportCancelButtonLabel => 'Avbryt';

  @override
  String get snapReportSubmitButtonLabel => 'Skicka in rapport';

  @override
  String get snapReportEnterValidEmailError => 'Ange en giltig e-postadress';

  @override
  String get snapReportDetailsHint => 'Kommentar...';

  @override
  String get snapReportPrivacyAgreementLabel => 'Genom att skicka in detta formulär bekräftar jag att jag har läst och godkänner ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Canonicals integritetsmeddelande ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'och ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'Integritetspolicy';

  @override
  String get debPageErrorNoPackageInfo => 'Ingen paketinformation hittades';

  @override
  String get externalResources => 'Ytterligare resurser';

  @override
  String get externalResourcesButtonLabel => 'Upptäck mer';

  @override
  String get allGamesButtonLabel => 'Alla spel';

  @override
  String get externalResourcesDisclaimer => 'Obs: Dessa är alla externa verktyg. Dessa ägs eller distribueras inte av Canonical.';

  @override
  String get openInBrowser => 'Öppna i webbläsare';

  @override
  String get installAll => 'Installera alla';

  @override
  String get localDebWarningTitle => 'Potentiellt osäkert';

  @override
  String get localDebWarningBody => 'Detta paket tillhandahålls av en tredje part. Att installera paket utanför App Center kan öka risken för ditt system och dina personuppgifter. Se till att du litar på källan innan du fortsätter.';

  @override
  String get localDebLearnMore => 'Läs mer om paket från tredje part';

  @override
  String get localDebDialogMessage => 'Detta paket tillhandahålls av en tredje part och kan hota ditt system och dina personuppgifter.';

  @override
  String get localDebDialogConfirmation => 'Är du säker på att du vill installera det?';

  @override
  String snapdExceptionRunningApps(String snapName) {
    return 'Vi kunde inte uppdatera $snapName eftersom det körs just nu.';
  }

  @override
  String get errorViewCheckStatusLabel => 'Kolla status';

  @override
  String get errorViewNetworkErrorTitle => 'Anslut till internet';

  @override
  String get errorViewNetworkErrorDescription => 'Vi kan inte ladda innehåll i Appcentral utan en internetanslutning.';

  @override
  String get errorViewNetworkErrorAction => 'Kontrollera din uppkoppling och försök igen.';

  @override
  String get errorViewServerErrorDescription => 'Vi är ledsna, vi har för närvarande problem med Appcentral.';

  @override
  String get errorViewServerErrorAction => 'Kontrollera status för uppdateringar eller försök igen senare.';

  @override
  String get errorViewUnknownErrorTitle => 'Någonting gick fel';

  @override
  String get errorViewUnknownErrorDescription => 'Vi är ledsna, men vi är inte säkra på vad felet är.';

  @override
  String get errorViewUnknownErrorAction => 'Du kan försöka igen nu, kontrollera status för uppdateringar eller försöka igen senare.';
}
