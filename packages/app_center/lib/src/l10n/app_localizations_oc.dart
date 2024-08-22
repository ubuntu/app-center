import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Occitan (`oc`).
class AppLocalizationsOc extends AppLocalizations {
  AppLocalizationsOc([String locale = 'oc']) : super(locale);

  @override
  String get appCenterLabel => 'Logitèca';

  @override
  String get appstreamSearchGreylist => 'app;aplicacion;paquet;programa;aisinas;esplech;utilitari;logicial;aplech;otís';

  @override
  String get snapPageChannelLabel => 'Canal';

  @override
  String get snapPageConfinementLabel => 'Isolacion';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Contactar $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Descripcion';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Site web dels desvolopaires';

  @override
  String get snapPageDownloadSizeLabel => 'Talha del telecargament';

  @override
  String get snapPageSizeLabel => 'Size';

  @override
  String get snapPageGalleryLabel => 'Galariá';

  @override
  String get snapPageLicenseLabel => 'Licéncia';

  @override
  String get snapPageLinksLabel => 'Ligams';

  @override
  String get snapPagePublisherLabel => 'Editor';

  @override
  String get snapPagePublishedLabel => 'Publicacion';

  @override
  String get snapPageSummaryLabel => 'Resumit';

  @override
  String get snapPageVersionLabel => 'Version';

  @override
  String get snapPageShareLinkCopiedMessage => 'Ligam copiat al quichapapièrs';

  @override
  String get explorePageLabel => 'Explorar';

  @override
  String get explorePageCategoriesLabel => 'Categorias';

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
  String get managePageCheckForUpdates => 'Verificar las mesas a jorn';

  @override
  String get managePageCheckingForUpdates => 'Verificacion de mesas a jorn';

  @override
  String get managePageNoInternet => 'Can\'t reach server, check your internet connection or try again later.';

  @override
  String get managePageDescription => 'Verificatz se de mesas a jorn o nivèl son disponiblas per vòstras aplicacions e gerissètz l’estat de vòstras aplicacions.';

  @override
  String get managePageDebUpdatesMessage => 'Debian package updates are handled by the Software Updater.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Installat e mes a jorn';

  @override
  String get managePageLabel => 'Gerir';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Cap de mesa a jorn pas disponibla. Las aplicacions es a jorn.';

  @override
  String get managePageSearchFieldSearchHint => 'Cercar dins las aplicacions installadas';

  @override
  String get managePageShowDetailsLabel => 'Veire los detalhs';

  @override
  String get managePageShowSystemSnapsLabel => 'Veire los snaps sistèma';

  @override
  String get managePageUpdateAllLabel => 'Tot metre a jorn';

  @override
  String managePageUpdatedDaysAgo(int n) {
    return 'Mes a jorn fa $n jorns';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n setmanas',
      one: '$n sermana',
    );
    return 'Actualizat fa $_temp0';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n meses',
      one: '$n mes',
    );
    return 'Actualizat fa $_temp0';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ans',
      one: '$n an',
    );
    return 'Actualizat fa $_temp0';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Mesas a jorn disponiblas ($n)';
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
  String get productivityPageLabel => 'Productivitat';

  @override
  String get developmentPageLabel => 'Desvolopament';

  @override
  String get gamesPageLabel => 'Jòcs';

  @override
  String get gamesPageTitle => 'Popular';

  @override
  String get gamesPageTop => 'Jòcs populars';

  @override
  String get gamesPageFeatured => 'Títols en evidéncia';

  @override
  String get gamesPageBundles => 'Paquets d’aplicacion';

  @override
  String get unknownPublisher => 'Editor desconegut';

  @override
  String get searchFieldDebSection => 'Paquets Debian';

  @override
  String get searchFieldSearchHint => 'Cercar d’aplicacions';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Veire totes los resultats per la recèrca de « $query »';
  }

  @override
  String get searchFieldSnapSection => 'Paquet Snap';

  @override
  String get searchPageFilterByLabel => 'Filtrar per';

  @override
  String searchPageNoResults(String query) {
    return 'Cap de resultat pas trobat per « $query »';
  }

  @override
  String get searchPageNoResultsHint => 'Ensajatz de mots clau diferents o mai generals';

  @override
  String get searchPageNoResultsCategory => 'Avèm pas trobat cap de paquet per aquesta categoria';

  @override
  String get searchPageNoResultsCategoryHint => 'Ensajatz una autra categoria o utilizatz de mots clau mai generals';

  @override
  String get searchPageSortByLabel => 'Triar per';

  @override
  String get searchPageRelevanceLabel => 'Importància';

  @override
  String searchPageTitle(String query) {
    return 'Resultats per « $query »';
  }

  @override
  String get aboutPageLabel => 'A prepaus';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPageContributorTitle => 'Concepcion e desvelopament per :';

  @override
  String get aboutPageCommunityTitle => 'Formatz part de la comunitat :';

  @override
  String get aboutPageContributeLabel => 'Contribuir e senhalar de bugs';

  @override
  String get aboutPageGitHubLabel => 'Nos retrobar sus Github';

  @override
  String get aboutPagePublishLabel => 'Publicar a la botiga de Snap';

  @override
  String get aboutPageLearnMoreLabel => 'Ne saber mai';

  @override
  String get appstreamUrlTypeBugtracker => 'Registre d’avarias';

  @override
  String get appstreamUrlTypeContact => 'Contacte';

  @override
  String get appstreamUrlTypeContribute => 'Contribute';

  @override
  String get appstreamUrlTypeDonation => 'Far un don';

  @override
  String get appstreamUrlTypeFaq => 'FAQ';

  @override
  String get appstreamUrlTypeHelp => 'Ajuda';

  @override
  String get appstreamUrlTypeHomepage => 'Pagina d’acuèlh';

  @override
  String get appstreamUrlTypeTranslate => 'Traduccions';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Source';

  @override
  String get packageFormatDebLabel => 'Paquets Debian';

  @override
  String get packageFormatSnapLabel => 'Paquet Snap';

  @override
  String get snapActionCancelLabel => 'Anullar';

  @override
  String get snapActionInstallLabel => 'Installar';

  @override
  String get snapActionInstalledLabel => 'Installed';

  @override
  String get snapActionInstallingLabel => 'Installacion';

  @override
  String get snapActionOpenLabel => 'Dobrir';

  @override
  String get snapActionRemoveLabel => 'Desinstallar';

  @override
  String get snapActionRemovingLabel => 'Desinstallacion';

  @override
  String get snapActionSwitchChannelLabel => 'Cambiar de canal';

  @override
  String get snapActionUpdateLabel => 'Metre a jorn';

  @override
  String get snapCategoryAll => 'Totas las categorias';

  @override
  String get snapActionUpdatingLabel => 'Mesa a jorn';

  @override
  String get snapCategoryArtAndDesign => 'Arts e concepcion';

  @override
  String get snapCategoryBooksAndReference => 'Libres e referéncias';

  @override
  String get snapCategoryDefaultButtonLabel => 'Ne descobrir mai';

  @override
  String get snapCategoryDevelopment => 'Desvolopament';

  @override
  String get snapCategoryDevelopmentSlogan => 'Snaps indispensables pels desvolopaires';

  @override
  String get snapCategoryDevicesAndIot => 'Aparelh e Internet dels objèctes';

  @override
  String get snapCategoryEducation => 'Educacion';

  @override
  String get snapCategoryEntertainment => 'Léser';

  @override
  String get snapCategoryFeatured => 'Mesas en avant';

  @override
  String get snapCategoryFeaturedSlogan => 'Snaps meses en avant';

  @override
  String get snapCategoryFinance => 'Finança';

  @override
  String get snapCategoryGames => 'Jòcs';

  @override
  String get snapCategoryGamesSlogan => 'Tot per vòstras nuèches de jòc';

  @override
  String get snapCategoryGameDev => 'Desvelopament de jòcs';

  @override
  String get snapCategoryGameDevSlogan => 'Desvelopament de jòcs';

  @override
  String get snapCategoryGameEmulators => 'Emulators';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emulators';

  @override
  String get snapCategoryGnomeGames => 'Jòcs GNOME';

  @override
  String get snapCategoryGnomeGamesSlogan => 'Compilacion de jòcs de GNOME';

  @override
  String get snapCategoryKdeGames => 'Jòcs de KDE';

  @override
  String get snapCategoryKdeGamesSlogan => 'Compilacion de jòcs de KDE';

  @override
  String get snapCategoryGameLaunchers => 'Aviadors de jòcs';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Aviadors de jòcs';

  @override
  String get snapCategoryGameContentCreation => 'Creacion de contengut';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Creacion de contengut';

  @override
  String get snapCategoryHealthAndFitness => 'Santat e espòrt';

  @override
  String get snapCategoryMusicAndAudio => 'Musica e àudio';

  @override
  String get snapCategoryNewsAndWeather => 'Informacions e metèo';

  @override
  String get snapCategoryPersonalisation => 'Personalizacion';

  @override
  String get snapCategoryPhotoAndVideo => 'Fòtos e vidèo';

  @override
  String get snapCategoryProductivity => 'Productivitat';

  @override
  String get snapCategoryProductivityButtonLabel => 'Descobrir la colleccion de productivitat';

  @override
  String get snapCategoryProductivitySlogan => 'Marcatz una causa de vòstra lista de prètzfaches en cors';

  @override
  String get snapCategoryScience => 'Sciéncia';

  @override
  String get snapCategorySecurity => 'Seguretat';

  @override
  String get snapCategoryServerAndCloud => 'Servidor e cloud';

  @override
  String get snapCategorySocial => 'Socializacion';

  @override
  String get snapCategoryUbuntuDesktop => 'Burèu Ubuntu';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Amodatz lo burèu';

  @override
  String get snapCategoryUtilities => 'Utilitaris';

  @override
  String get snapConfinementClassic => 'Classic';

  @override
  String get snapConfinementDevmode => 'Mòde dev';

  @override
  String get snapConfinementStrict => 'Estrict';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Alfabetic (A a Z)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Alfabetic (Z a A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Talha (de la mendre a la màger)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Talha (de la màger a la mendre)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Talha (de la mendre a la màger)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Talha (de la màger a la mendre)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Mens recentament mes a jorn';

  @override
  String get snapSortOrderInstalledDateDesc => 'Mai recentament mes a jorn';

  @override
  String get snapSortOrderRelevance => 'Importància';

  @override
  String get snapRatingsBandVeryGood => 'Plan bona';

  @override
  String get snapRatingsBandGood => 'Bona';

  @override
  String get snapRatingsBandNeutral => 'Neutra';

  @override
  String get snapRatingsBandPoor => 'Febla';

  @override
  String get snapRatingsBandVeryPoor => 'Plan febla';

  @override
  String get snapRatingsBandInsufficientVotes => 'Nombre de vòtes insufisents';

  @override
  String snapRatingsVotes(int n) {
    return '$n vòtes';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Senhalar $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Causissètz una rason pel senhalament d’aqueste snap';

  @override
  String get snapReportSelectAnOptionLabel => 'Seleccionatz una opcion';

  @override
  String get snapReportOptionCopyrightViolation => 'Violacion de dreches d’autor o marca depausada';

  @override
  String get snapReportOptionStoreViolation => 'Violacion dels tèrmes de servici de Snap Store';

  @override
  String get snapReportDetailsLabel => 'Se vos plau, provesissètz una rason mai detalhada per vòstre senhalament';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Vòstra adreça electronica (opcionala)';

  @override
  String get snapReportCancelButtonLabel => 'Anullar';

  @override
  String get snapReportSubmitButtonLabel => 'Enviar lo senhalament';

  @override
  String get snapReportEnterValidEmailError => 'Picatz una adreça electronica valida';

  @override
  String get snapReportDetailsHint => 'Comentari...';

  @override
  String get snapReportPrivacyAgreementLabel => 'En enviant aqueste formula, confirmi qu’ai legit e acceptat ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Avís de confidencialitat de Canonical ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'e ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'Politica de confidencialitat';

  @override
  String get debPageErrorNoPackageInfo => 'Cap d’informacions sul paquet pas trobada';

  @override
  String get externalResources => 'Ressorsas addicionalas';

  @override
  String get externalResourcesButtonLabel => 'Ne descobrir mai';

  @override
  String get allGamesButtonLabel => 'Totes los jòcs';

  @override
  String get externalResourcesDisclaimer => 'Nòta : totas aquestas son d’aisinas extèrnas. Son pas la proprietat nimai distribuida per Canonical.';

  @override
  String get openInBrowser => 'Dobrir dins lo navegador';

  @override
  String get installAll => 'Tot installar';

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
