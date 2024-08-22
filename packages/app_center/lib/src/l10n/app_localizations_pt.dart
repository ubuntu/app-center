import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appCenterLabel => 'Centro de Aplicações';

  @override
  String get appstreamSearchGreylist => 'app;aplicação;pacote;programa;programar;suite;ferramenta';

  @override
  String get snapPageChannelLabel => 'Canal';

  @override
  String get snapPageConfinementLabel => 'Confinamento';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Contacto $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Descrição';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Website do programador';

  @override
  String get snapPageDownloadSizeLabel => 'Tamanho da transferência';

  @override
  String get snapPageSizeLabel => 'Tamanho';

  @override
  String get snapPageGalleryLabel => 'Galeria';

  @override
  String get snapPageLicenseLabel => 'Licença';

  @override
  String get snapPageLinksLabel => 'Ligações';

  @override
  String get snapPagePublisherLabel => 'Editor';

  @override
  String get snapPagePublishedLabel => 'Publicado';

  @override
  String get snapPageSummaryLabel => 'Resumo';

  @override
  String get snapPageVersionLabel => 'Versão';

  @override
  String get snapPageShareLinkCopiedMessage => 'Ligação copiada para a área de transferência';

  @override
  String get explorePageLabel => 'Explorar';

  @override
  String get explorePageCategoriesLabel => 'Categorias';

  @override
  String get managePageOwnUpdateAvailable => 'App Center update available';

  @override
  String get managePageQuitToUpdate => 'Sair para atualizar';

  @override
  String get managePageOwnUpdateDescription => 'When you quit the application it will automatically update.';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return 'The app center will automatically update in $time.';
  }

  @override
  String get managePageOwnUpdateQuitButton => 'Sair para atualizar';

  @override
  String get managePageCheckForUpdates => 'Procurar por atualizações';

  @override
  String get managePageCheckingForUpdates => 'A procurar por atualizações';

  @override
  String get managePageNoInternet => 'Can\'t reach server, check your internet connection or try again later.';

  @override
  String get managePageDescription => 'Procure por atualizações disponíveis, atualize as suas aplicações e faça a gestão do estado de todas as suas aplicações.';

  @override
  String get managePageDebUpdatesMessage => 'Debian package updates are handled by the Software Updater.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Instalado e atualizado';

  @override
  String get managePageLabel => 'Gerir';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Não há atualizações disponíveis. As suas aplicações estão todas atualizadas.';

  @override
  String get managePageSearchFieldSearchHint => 'Procurar nas suas aplicações instaladas';

  @override
  String get managePageShowDetailsLabel => 'Mostrar detalhes';

  @override
  String get managePageShowSystemSnapsLabel => 'Mostrar snaps do sistema';

  @override
  String get managePageUpdateAllLabel => 'Atualizar tudo';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dias',
      one: '$n dia',
    );
    return 'Atualizado $_temp0 atrás';
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
    return 'Atualizações disponíveis ($n)';
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
  String get productivityPageLabel => 'Produtividade';

  @override
  String get developmentPageLabel => 'Desenvolvimento';

  @override
  String get gamesPageLabel => 'Jogos';

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
  String get searchFieldDebSection => 'Pacotes Debian';

  @override
  String get searchFieldSearchHint => 'Search for apps';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Ver todos os resultados para \"$query\"';
  }

  @override
  String get searchFieldSnapSection => 'Pacotes Snap';

  @override
  String get searchPageFilterByLabel => 'Filtrar por';

  @override
  String searchPageNoResults(String query) {
    return 'Nenhum resultado encontrado para \"$query\"';
  }

  @override
  String get searchPageNoResultsHint => 'Tente usar palavras-chave diferentes ou mais gerais';

  @override
  String get searchPageNoResultsCategory => 'Desculpe, não encontramos nenhum pacote nesta categoria';

  @override
  String get searchPageNoResultsCategoryHint => 'Tente uma categoria diferente ou use palavras-chave mais gerais';

  @override
  String get searchPageSortByLabel => 'Ordenar por';

  @override
  String get searchPageRelevanceLabel => 'Relevância';

  @override
  String searchPageTitle(String query) {
    return 'Resultados para \"$query\"';
  }

  @override
  String get aboutPageLabel => 'Acerca';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Versão $version';
  }

  @override
  String get aboutPageContributorTitle => 'Projetado e desenvolvido por:';

  @override
  String get aboutPageCommunityTitle => 'Faça parte da comunidade:';

  @override
  String get aboutPageContributeLabel => 'Contribute or report bug';

  @override
  String get aboutPageGitHubLabel => 'Encontre-nos no GitHub';

  @override
  String get aboutPagePublishLabel => 'Publique na Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Saber mais';

  @override
  String get appstreamUrlTypeBugtracker => 'Rastreador de bugs';

  @override
  String get appstreamUrlTypeContact => 'Contacto';

  @override
  String get appstreamUrlTypeContribute => 'Contribute';

  @override
  String get appstreamUrlTypeDonation => 'Doar';

  @override
  String get appstreamUrlTypeFaq => 'Perguntas frequentes';

  @override
  String get appstreamUrlTypeHelp => 'Ajuda';

  @override
  String get appstreamUrlTypeHomepage => 'Página inicial';

  @override
  String get appstreamUrlTypeTranslate => 'Traduções';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Source';

  @override
  String get packageFormatDebLabel => 'Pacotes Debian';

  @override
  String get packageFormatSnapLabel => 'Pacotes Snap';

  @override
  String get snapActionCancelLabel => 'Cancelar';

  @override
  String get snapActionInstallLabel => 'Instalar';

  @override
  String get snapActionInstalledLabel => 'Installed';

  @override
  String get snapActionInstallingLabel => 'A instalar';

  @override
  String get snapActionOpenLabel => 'Abrir';

  @override
  String get snapActionRemoveLabel => 'Desinstalar';

  @override
  String get snapActionRemovingLabel => 'A desinstalar';

  @override
  String get snapActionSwitchChannelLabel => 'Mudar de canal';

  @override
  String get snapActionUpdateLabel => 'Atualizar';

  @override
  String get snapCategoryAll => 'Todas as categorias';

  @override
  String get snapActionUpdatingLabel => 'Atualizando';

  @override
  String get snapCategoryArtAndDesign => 'Arte e Concepção';

  @override
  String get snapCategoryBooksAndReference => 'Livros e Referências';

  @override
  String get snapCategoryDefaultButtonLabel => 'Descubra mais';

  @override
  String get snapCategoryDevelopment => 'Desenvolvimento';

  @override
  String get snapCategoryDevelopmentSlogan => 'Snaps indispensáveis para desenvolvedores';

  @override
  String get snapCategoryDevicesAndIot => 'Dispositivos e IoT';

  @override
  String get snapCategoryEducation => 'Educação';

  @override
  String get snapCategoryEntertainment => 'Entretenimento';

  @override
  String get snapCategoryFeatured => 'Destaque';

  @override
  String get snapCategoryFeaturedSlogan => 'Snaps em destaque';

  @override
  String get snapCategoryFinance => 'Finanças';

  @override
  String get snapCategoryGames => 'Jogos';

  @override
  String get snapCategoryGamesSlogan => 'Tudo para sua noite de jogos';

  @override
  String get snapCategoryGameDev => 'Desenvolvimento de jogos';

  @override
  String get snapCategoryGameDevSlogan => 'Desenvolvimento de jogos';

  @override
  String get snapCategoryGameEmulators => 'Emuladores';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emuladores';

  @override
  String get snapCategoryGnomeGames => 'Jogos do GNOME';

  @override
  String get snapCategoryGnomeGamesSlogan => 'Suíte de Jogos GNOME';

  @override
  String get snapCategoryKdeGames => 'KDE Games';

  @override
  String get snapCategoryKdeGamesSlogan => 'KDE Games Suite';

  @override
  String get snapCategoryGameLaunchers => 'Game Launchers';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Game Launchers';

  @override
  String get snapCategoryGameContentCreation => 'Criação de conteúdo';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Criação de conteúdo';

  @override
  String get snapCategoryHealthAndFitness => 'Saúde e Fitness';

  @override
  String get snapCategoryMusicAndAudio => 'Música e Áudio';

  @override
  String get snapCategoryNewsAndWeather => 'Notícias e Tempo';

  @override
  String get snapCategoryPersonalisation => 'Personalização';

  @override
  String get snapCategoryPhotoAndVideo => 'Foto e Vídeo';

  @override
  String get snapCategoryProductivity => 'Produtividade';

  @override
  String get snapCategoryProductivityButtonLabel => 'Discover the productivity collection';

  @override
  String get snapCategoryProductivitySlogan => 'Cross one thing off your to-do list';

  @override
  String get snapCategoryScience => 'Ciência';

  @override
  String get snapCategorySecurity => 'Segurança';

  @override
  String get snapCategoryServerAndCloud => 'Servidor e Cloud';

  @override
  String get snapCategorySocial => 'Social';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu Desktop';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Jump start your desktop';

  @override
  String get snapCategoryUtilities => 'Utilitários';

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
  String get snapReportPrivacyAgreementLabel => 'Ao enviar este formulário, confirmo que li e concordo com ';

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
  String get installAll => 'Instalar tudo';

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

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr(): super('pt_BR');

  @override
  String get appCenterLabel => 'Centro de Aplicativos';

  @override
  String get appstreamSearchGreylist => 'app;aplicativo;pacote;programa;software;suite;ferramenta';

  @override
  String get snapPageChannelLabel => 'Canal';

  @override
  String get snapPageConfinementLabel => 'Confinamento';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Entre em contato com $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Descrição';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Site do desenvolvedor';

  @override
  String get snapPageDownloadSizeLabel => 'Tamanho da transferência';

  @override
  String get snapPageSizeLabel => 'Tamanho';

  @override
  String get snapPageGalleryLabel => 'Galeria';

  @override
  String get snapPageLicenseLabel => 'Licença';

  @override
  String get snapPageLinksLabel => 'Links';

  @override
  String get snapPagePublisherLabel => 'Editor';

  @override
  String get snapPagePublishedLabel => 'Publicado';

  @override
  String get snapPageSummaryLabel => 'Resumo';

  @override
  String get snapPageVersionLabel => 'Versão';

  @override
  String get snapPageShareLinkCopiedMessage => 'Link copiado para a área de transferência';

  @override
  String get explorePageLabel => 'Explorar';

  @override
  String get explorePageCategoriesLabel => 'Categorias';

  @override
  String get managePageOwnUpdateAvailable => 'Atualização do App Center disponível';

  @override
  String get managePageOwnUpdateDescription => 'Quando você parar o aplicativo ele irá atualizar automaticamente.';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return 'O centro de aplicativos será atualizado automaticamente em $time.';
  }

  @override
  String get managePageOwnUpdateQuitButton => 'Saia para atualizar';

  @override
  String get managePageCheckForUpdates => 'Verificar se há atualizações';

  @override
  String get managePageCheckingForUpdates => 'Verificando se há atualizações';

  @override
  String get managePageNoInternet => 'Não pode chegar ao servidor, verifique sua conexão de internet ou tentar novamente mais tarde.';

  @override
  String get managePageDescription => 'Verifique se há atualizações disponíveis, atualize seus aplicativos e gerencie o status de todos os seus aplicativos.';

  @override
  String get managePageDebUpdatesMessage => 'Atualizações dos pacotes Debian são gerenciadas pelo Atualizador de Software.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Instalado e atualizado';

  @override
  String get managePageLabel => 'Gerenciar Snaps instalados';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Não há atualizações disponíveis. Todos os seus aplicativos estão atualizados.';

  @override
  String get managePageSearchFieldSearchHint => 'Procurar em seus aplicativos instalados';

  @override
  String get managePageShowDetailsLabel => 'Mostrar detalhes';

  @override
  String get managePageShowSystemSnapsLabel => 'Mostrar snaps do sistema';

  @override
  String get managePageUpdateAllLabel => 'Atualizar tudo';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dias',
      one: '$n dia',
    );
    return 'Atualizado $_temp0 atrás';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n semanas',
      one: '$n semana',
    );
    return 'Atualizado há $_temp0 atrás';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n meses',
      one: '$n mês',
    );
    return 'Atualizado há $_temp0 atrás';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n anos',
      one: '$n ano',
    );
    return 'Atualizado há $_temp0 atrás';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Atualizações disponíveis ($n)';
  }

  @override
  String get productivityPageLabel => 'Produtividade';

  @override
  String get developmentPageLabel => 'Desenvolvimento';

  @override
  String get gamesPageLabel => 'Jogos';

  @override
  String get gamesPageTitle => 'Novidades';

  @override
  String get gamesPageTop => 'Jogos mais Populares';

  @override
  String get gamesPageFeatured => 'Títulos em Destaque';

  @override
  String get gamesPageBundles => 'Pacotes de Aplicativos';

  @override
  String get unknownPublisher => 'Editor desconhecido';

  @override
  String get searchFieldDebSection => 'Pacotes debian';

  @override
  String get searchFieldSearchHint => 'Procurar por aplicativos';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Ver todos os resultados para \"$query\"';
  }

  @override
  String get searchFieldSnapSection => 'Pacotes snap';

  @override
  String get searchPageFilterByLabel => 'Filtrar por';

  @override
  String searchPageNoResults(String query) {
    return 'Nenhum resultado encontrado para \"$query\"';
  }

  @override
  String get searchPageNoResultsHint => 'Tente usar palavras-chave diferentes ou mais gerais';

  @override
  String get searchPageNoResultsCategory => 'Desculpe, não conseguimos encontrar nenhum pacote nesta categoria';

  @override
  String get searchPageNoResultsCategoryHint => 'Tente uma categoria diferente ou use palavras-chave mais gerais';

  @override
  String get searchPageSortByLabel => 'Ordenar por';

  @override
  String get searchPageRelevanceLabel => 'Relevância';

  @override
  String searchPageTitle(String query) {
    return 'Resultados para \"$query\"';
  }

  @override
  String get aboutPageLabel => 'Sobre';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Versão $version';
  }

  @override
  String get aboutPageContributorTitle => 'Projetado e desenvolvido por:';

  @override
  String get aboutPageCommunityTitle => 'Faça parte da comunidade:';

  @override
  String get aboutPageContributeLabel => 'Contribuir ou reportar bug';

  @override
  String get aboutPageGitHubLabel => 'Encontre-nos no Github';

  @override
  String get aboutPagePublishLabel => 'Publicar para a Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Saiba mais';

  @override
  String get appstreamUrlTypeBugtracker => 'Rastreador de bugs';

  @override
  String get appstreamUrlTypeContact => 'Contato';

  @override
  String get appstreamUrlTypeContribute => 'Contribuir';

  @override
  String get appstreamUrlTypeDonation => 'Doar';

  @override
  String get appstreamUrlTypeFaq => 'FAQ';

  @override
  String get appstreamUrlTypeHelp => 'Ajuda';

  @override
  String get appstreamUrlTypeHomepage => 'Página inicial';

  @override
  String get appstreamUrlTypeTranslate => 'Traduções';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Fonte';

  @override
  String get packageFormatDebLabel => 'Pacotes debian';

  @override
  String get packageFormatSnapLabel => 'Pacotes snap';

  @override
  String get snapActionCancelLabel => 'Cancelar';

  @override
  String get snapActionInstallLabel => 'Instalar';

  @override
  String get snapActionInstalledLabel => 'Instalado';

  @override
  String get snapActionInstallingLabel => 'Instalando';

  @override
  String get snapActionOpenLabel => 'Abrir';

  @override
  String get snapActionRemoveLabel => 'Desinstalar';

  @override
  String get snapActionRemovingLabel => 'Desinstalando';

  @override
  String get snapActionSwitchChannelLabel => 'Mudar de canal';

  @override
  String get snapActionUpdateLabel => 'Atualizar';

  @override
  String get snapCategoryAll => 'Todas as categorias';

  @override
  String get snapActionUpdatingLabel => 'Atualizando';

  @override
  String get snapCategoryArtAndDesign => 'Arte e Design';

  @override
  String get snapCategoryBooksAndReference => 'Livros e Referências';

  @override
  String get snapCategoryDefaultButtonLabel => 'Descobrir mais';

  @override
  String get snapCategoryDevelopment => 'Desenvolvimento';

  @override
  String get snapCategoryDevelopmentSlogan => 'Snaps indispensáveis para desenvolvedores';

  @override
  String get snapCategoryDevicesAndIot => 'Dispositivos e IoT';

  @override
  String get snapCategoryEducation => 'Educação';

  @override
  String get snapCategoryEntertainment => 'Entretenimento';

  @override
  String get snapCategoryFeatured => 'Em Destaque';

  @override
  String get snapCategoryFeaturedSlogan => 'Snaps em Destaque';

  @override
  String get snapCategoryFinance => 'Finanças';

  @override
  String get snapCategoryGames => 'Jogos';

  @override
  String get snapCategoryGamesSlogan => 'Tudo para a sua noite de jogo';

  @override
  String get snapCategoryGameDev => 'Desenvolvimento de Jogos';

  @override
  String get snapCategoryGameDevSlogan => 'Desenvolvimento de Jogos';

  @override
  String get snapCategoryGameEmulators => 'Emuladores';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emuladores';

  @override
  String get snapCategoryGnomeGames => 'Jogos GNOME';

  @override
  String get snapCategoryGnomeGamesSlogan => 'Suíte de Jogos GNOME';

  @override
  String get snapCategoryKdeGames => 'Jogos KDE';

  @override
  String get snapCategoryKdeGamesSlogan => 'Suíte de Jogos KDE';

  @override
  String get snapCategoryGameLaunchers => 'Lançadores de Jogos';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Lançadores de Jogos';

  @override
  String get snapCategoryGameContentCreation => 'Criação de Conteúdo';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Criação de Conteúdo';

  @override
  String get snapCategoryHealthAndFitness => 'Saúde e Fitness';

  @override
  String get snapCategoryMusicAndAudio => 'Música e Áudio';

  @override
  String get snapCategoryNewsAndWeather => 'Notícias e Clima';

  @override
  String get snapCategoryPersonalisation => 'Personalização';

  @override
  String get snapCategoryPhotoAndVideo => 'Foto e Vídeo';

  @override
  String get snapCategoryProductivity => 'Produtividade';

  @override
  String get snapCategoryProductivityButtonLabel => 'Descubra a coleção de produtividade';

  @override
  String get snapCategoryProductivitySlogan => 'Risque uma coisa da sua lista de tarefas';

  @override
  String get snapCategoryScience => 'Ciência';

  @override
  String get snapCategorySecurity => 'Segurança';

  @override
  String get snapCategoryServerAndCloud => 'Servidores e Nuvem';

  @override
  String get snapCategorySocial => 'Social';

  @override
  String get snapCategoryUbuntuDesktop => 'Área de Trabalho Ubuntu';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Inicie rapidamente a sua área de trabalho';

  @override
  String get snapCategoryUtilities => 'Utilitários';

  @override
  String get snapConfinementClassic => 'Clássico';

  @override
  String get snapConfinementDevmode => 'Modo de desenvolvimento';

  @override
  String get snapConfinementStrict => 'Estrito';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Alfabética (A a Z)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Alfabética (Z a A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Tamanho (do menor ao maior)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Tamanho (do maior ao menor)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Tamanho (do menor ao maior)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Tamanho (do maior ao menor)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Atualizado menos recentemente';

  @override
  String get snapSortOrderInstalledDateDesc => 'Atualizado mais recentemente';

  @override
  String get snapSortOrderRelevance => 'Relevância';

  @override
  String get snapRatingsBandVeryGood => 'Muito bom';

  @override
  String get snapRatingsBandGood => 'Bom';

  @override
  String get snapRatingsBandNeutral => 'Neutro';

  @override
  String get snapRatingsBandPoor => 'Ruim';

  @override
  String get snapRatingsBandVeryPoor => 'Muito ruim';

  @override
  String get snapRatingsBandInsufficientVotes => 'Votos insuficientes';

  @override
  String snapRatingsVotes(int n) {
    return '$n votos';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Relatar $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Escolha um motivo para relatar este snap';

  @override
  String get snapReportSelectAnOptionLabel => 'Selecione uma opção';

  @override
  String get snapReportOptionCopyrightViolation => 'Violação de direitos autorais ou marca registrada';

  @override
  String get snapReportOptionStoreViolation => 'Violação dos termos de serviço da Snap Store';

  @override
  String get snapReportDetailsLabel => 'Forneça um motivo mais detalhado para seu relatório';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Seu e-mail (opcional)';

  @override
  String get snapReportCancelButtonLabel => 'Cancelar';

  @override
  String get snapReportSubmitButtonLabel => 'Enviar relatório';

  @override
  String get snapReportEnterValidEmailError => 'Digite um endereço de e-mail válido';

  @override
  String get snapReportDetailsHint => 'Comente...';

  @override
  String get snapReportPrivacyAgreementLabel => 'Ao enviar este formulário, confirmo que li e concordo com ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Aviso de privacidade da Canonical ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'e ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'Política de Privacidade';

  @override
  String get debPageErrorNoPackageInfo => 'Nenhuma informação de pacote encontrada';

  @override
  String get externalResources => 'Recursos adicionais';

  @override
  String get externalResourcesButtonLabel => 'Descobrir mais';

  @override
  String get allGamesButtonLabel => 'Todos os jogos';

  @override
  String get externalResourcesDisclaimer => 'Nota: Todas essas são ferramentas externas. Eles não pertencem nem são distribuídas pela Canonical.';

  @override
  String get openInBrowser => 'Abrir no navegador';

  @override
  String get installAll => 'Instalar tudo';

  @override
  String get localDebWarningTitle => 'Potencialmente inseguro';

  @override
  String get localDebWarningBody => 'Esse pacote é fornecido por terceiros. Instalar pacotes fora da Central de Aplicativos pode representar um risco para o seu sistema e dados pessoais. Só prossiga se a fonte for confiável.';

  @override
  String get localDebLearnMore => 'Saiba mais sobre pacotes de terceiros';

  @override
  String get localDebDialogMessage => 'Esse pacote é fornecido por terceiros e pode colocar o seu sistema e dados pessoais em risco.';

  @override
  String get localDebDialogConfirmation => 'Tem certeza de que deseja instalá-lo?';

  @override
  String snapdExceptionRunningApps(String snapName) {
    return 'Não conseguimos atualizar $snapName porque ele está sendo executado atualmente.';
  }

  @override
  String get errorViewCheckStatusLabel => 'Verificar o status';

  @override
  String get errorViewNetworkErrorTitle => 'Conecte-se à internet';

  @override
  String get errorViewNetworkErrorDescription => 'Não podemos carregar conteúdo no App Center sem conexão com a internet.';

  @override
  String get errorViewNetworkErrorAction => 'Verifique sua conexão e tente novamente.';

  @override
  String get errorViewServerErrorDescription => 'Lamentamos, estamos tendo problemas com o App Center.';

  @override
  String get errorViewServerErrorAction => 'Verifique o status de atualizações ou tente novamente mais tarde.';

  @override
  String get errorViewUnknownErrorTitle => 'Algo deu errado';

  @override
  String get errorViewUnknownErrorDescription => 'Lamentamos, mas não sabemos qual é o erro.';

  @override
  String get errorViewUnknownErrorAction => 'Você pode tentar novamente agora, verifique o status de atualizações, ou tente novamente mais tarde.';
}
