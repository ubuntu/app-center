import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appCenterLabel => 'Centro de aplicaciones';

  @override
  String get appstreamSearchGreylist => 'aplicación;aplicaciones;app;paquete;paquetes;programa;programas;software;herramienta;herramientas';

  @override
  String get snapPageChannelLabel => 'Canal';

  @override
  String get snapPageConfinementLabel => 'Confinamiento';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Contactar con $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Descripción';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Sitio web del desarrollador';

  @override
  String get snapPageDownloadSizeLabel => 'Tamaño de la descarga';

  @override
  String get snapPageSizeLabel => 'Tamaño';

  @override
  String get snapPageGalleryLabel => 'Galería';

  @override
  String get snapPageLicenseLabel => 'Licencia';

  @override
  String get snapPageLinksLabel => 'Enlaces';

  @override
  String get snapPagePublisherLabel => 'Editor';

  @override
  String get snapPagePublishedLabel => 'Publicado';

  @override
  String get snapPageSummaryLabel => 'Resumen';

  @override
  String get snapPageVersionLabel => 'Versión';

  @override
  String get snapPageShareLinkCopiedMessage => 'Se copió el enlace en el portapapeles';

  @override
  String get explorePageLabel => 'Explorar';

  @override
  String get explorePageCategoriesLabel => 'Categorías';

  @override
  String get managePageOwnUpdateAvailable => 'Actualización disponible para el centro de aplicaciones';

  @override
  String get managePageQuitToUpdate => 'Cerrar para actualizar';

  @override
  String get managePageOwnUpdateDescription => 'Al salir de la aplicación, esta se actualizará automáticamente.';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return 'El centro de aplicaciones se actualizará automáticamente en $time.';
  }

  @override
  String get managePageOwnUpdateQuitButton => 'Salir para actualizar';

  @override
  String get managePageCheckForUpdates => 'Buscar actualizaciones';

  @override
  String get managePageCheckingForUpdates => 'Buscando actualizaciones';

  @override
  String get managePageNoInternet => 'No se puede acceder al servidor, compruebe su conexión a Internet o inténtelo más tarde.';

  @override
  String get managePageDescription => 'Compruebe si hay actualizaciones disponibles, actualice sus aplicaciones y gestione el estado de todas ellas.';

  @override
  String get managePageDebUpdatesMessage => 'Las actualizaciones de los paquetes de Debian son gestionadas por el actualizador de software.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Instalado y actualizado';

  @override
  String get managePageLabel => 'Gestionar los Snaps instalados';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'No hay actualizaciones disponibles. Tus aplicaciones están actualizadas.';

  @override
  String get managePageSearchFieldSearchHint => 'Buscar las aplicaciones instaladas';

  @override
  String get managePageShowDetailsLabel => 'Mostrar los detalles';

  @override
  String get managePageShowSystemSnapsLabel => 'Mostrar «snaps» del sistema';

  @override
  String get managePageUpdateAllLabel => 'Actualizar todo';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n días',
      one: '$n día',
    );
    return 'Actualizado hace $_temp0';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n semanas',
      one: '$n semana',
    );
    return 'Actualizado hace $_temp0';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n meses',
      one: '$n mes',
    );
    return 'Actualizado hace $_temp0';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n años',
      one: '$n año',
    );
    return 'Actualizado hace $_temp0';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Actualizaciones disponibles ($n)';
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
  String get productivityPageLabel => 'Productividad';

  @override
  String get developmentPageLabel => 'Desarrollo';

  @override
  String get gamesPageLabel => 'Juegos';

  @override
  String get gamesPageTitle => 'Populares';

  @override
  String get gamesPageTop => 'Los mejores juegos';

  @override
  String get gamesPageFeatured => 'Títulos destacados';

  @override
  String get gamesPageBundles => 'Paquetes de aplicaciones';

  @override
  String get unknownPublisher => 'Editor desconocido';

  @override
  String get searchFieldDebSection => 'Paquetes de Debian';

  @override
  String get searchFieldSearchHint => 'Buscar las aplicaciones';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Ver todos los resultados de «$query»';
  }

  @override
  String get searchFieldSnapSection => 'Paquetes snap';

  @override
  String get searchPageFilterByLabel => 'Filtrar por';

  @override
  String searchPageNoResults(String query) {
    return 'No se encontró ningún resultado para «$query»';
  }

  @override
  String get searchPageNoResultsHint => 'Prueba a utilizar unas palabras clave diferentes o más generales';

  @override
  String get searchPageNoResultsCategory => 'Lo sentimos, no hemos encontrado ningún paquete en esta categoría';

  @override
  String get searchPageNoResultsCategoryHint => 'Prueba con otra categoría o utiliza unas palabras clave más generales';

  @override
  String get searchPageSortByLabel => 'Ordenar por';

  @override
  String get searchPageRelevanceLabel => 'Relevancia';

  @override
  String searchPageTitle(String query) {
    return 'Resultados de «$query»';
  }

  @override
  String get aboutPageLabel => 'Acerca de';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get aboutPageContributorTitle => 'Diseñado y desarrollado por:';

  @override
  String get aboutPageCommunityTitle => 'Forma parte de la comunidad:';

  @override
  String get aboutPageContributeLabel => 'Contribuir o informar de un error';

  @override
  String get aboutPageGitHubLabel => 'Encuéntrenos en GitHub';

  @override
  String get aboutPagePublishLabel => 'Publicar en la Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Leer más';

  @override
  String get appstreamUrlTypeBugtracker => 'Rastreador de errores';

  @override
  String get appstreamUrlTypeContact => 'Contacto';

  @override
  String get appstreamUrlTypeContribute => 'Contribuir';

  @override
  String get appstreamUrlTypeDonation => 'Donar';

  @override
  String get appstreamUrlTypeFaq => 'PREGUNTAS FRECUENTES';

  @override
  String get appstreamUrlTypeHelp => 'Ayuda';

  @override
  String get appstreamUrlTypeHomepage => 'Página principal';

  @override
  String get appstreamUrlTypeTranslate => 'Traducciones';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Fuente';

  @override
  String get packageFormatDebLabel => 'Paquetes de Debian';

  @override
  String get packageFormatSnapLabel => 'Paquetes snap';

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
  String get snapActionSwitchChannelLabel => 'Cambiar de canal';

  @override
  String get snapActionUpdateLabel => 'Actualizar';

  @override
  String get snapCategoryAll => 'Todas las categorías';

  @override
  String get snapActionUpdatingLabel => 'Actualizando';

  @override
  String get snapCategoryArtAndDesign => 'Arte y diseño';

  @override
  String get snapCategoryBooksAndReference => 'Libros y referencia';

  @override
  String get snapCategoryDefaultButtonLabel => 'Descubrir más';

  @override
  String get snapCategoryDevelopment => 'Desarrollo';

  @override
  String get snapCategoryDevelopmentSlogan => '«Snaps» indispensables para desarrolladores';

  @override
  String get snapCategoryDevicesAndIot => 'Dispositivos e IoT';

  @override
  String get snapCategoryEducation => 'Educación';

  @override
  String get snapCategoryEntertainment => 'Entretenimiento';

  @override
  String get snapCategoryFeatured => 'Destacado';

  @override
  String get snapCategoryFeaturedSlogan => '«Snaps» destacados';

  @override
  String get snapCategoryFinance => 'Finanzas';

  @override
  String get snapCategoryGames => 'Juegos';

  @override
  String get snapCategoryGamesSlogan => 'Todo para su noche de juegos';

  @override
  String get snapCategoryGameDev => 'Desarrollo de juegos';

  @override
  String get snapCategoryGameDevSlogan => 'Desarrollo de juegos';

  @override
  String get snapCategoryGameEmulators => 'Emuladores';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emuladores';

  @override
  String get snapCategoryGnomeGames => 'Juegos de GNOME';

  @override
  String get snapCategoryGnomeGamesSlogan => 'Compilación de juegos de GNOME';

  @override
  String get snapCategoryKdeGames => 'Juegos de KDE';

  @override
  String get snapCategoryKdeGamesSlogan => 'Compilación de juegos de KDE';

  @override
  String get snapCategoryGameLaunchers => 'Iniciadores de juegos';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Iniciadores de juegos';

  @override
  String get snapCategoryGameContentCreation => 'Creación de contenido';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Creación de contenido';

  @override
  String get snapCategoryHealthAndFitness => 'Salud y bienestar físico';

  @override
  String get snapCategoryMusicAndAudio => 'Música y audio';

  @override
  String get snapCategoryNewsAndWeather => 'Noticias y meteorología';

  @override
  String get snapCategoryPersonalisation => 'Personalización';

  @override
  String get snapCategoryPhotoAndVideo => 'Fotos y vídeo';

  @override
  String get snapCategoryProductivity => 'Productividad';

  @override
  String get snapCategoryProductivityButtonLabel => 'Descubre la colección de productividad';

  @override
  String get snapCategoryProductivitySlogan => 'Tacha una cosa de tu lista de tareas pendientes';

  @override
  String get snapCategoryScience => 'Ciencia';

  @override
  String get snapCategorySecurity => 'Seguridad';

  @override
  String get snapCategoryServerAndCloud => 'Servidor y nube';

  @override
  String get snapCategorySocial => 'Redes sociales';

  @override
  String get snapCategoryUbuntuDesktop => 'Escritorio de Ubuntu';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Saque el máximo partido a su escritorio';

  @override
  String get snapCategoryUtilities => 'Utilidades';

  @override
  String get snapConfinementClassic => 'Clásico';

  @override
  String get snapConfinementDevmode => 'Modo de desarrollo';

  @override
  String get snapConfinementStrict => 'Estricto';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Alfabético (de la A a la Z)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Alfabético (de la Z a la A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Tamaño (de menor a mayor)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Tamaño (de mayor a menor)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Tamaño (de menor a mayor)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Tamaño (de mayor a menor)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Lo menos reciente';

  @override
  String get snapSortOrderInstalledDateDesc => 'Lo más reciente';

  @override
  String get snapSortOrderRelevance => 'Relevancia';

  @override
  String get snapRatingsBandVeryGood => 'Muy bien';

  @override
  String get snapRatingsBandGood => 'Bien';

  @override
  String get snapRatingsBandNeutral => 'Neutral';

  @override
  String get snapRatingsBandPoor => 'Pobre';

  @override
  String get snapRatingsBandVeryPoor => 'Muy pobre';

  @override
  String get snapRatingsBandInsufficientVotes => 'Votos insuficientes';

  @override
  String snapRatingsVotes(int n) {
    return '$n votos';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Denunciar $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Elija una razón para denunciar este «snap»';

  @override
  String get snapReportSelectAnOptionLabel => 'Seleccione una opción';

  @override
  String get snapReportOptionCopyrightViolation => 'Violación de los derechos de autor o marca registrada';

  @override
  String get snapReportOptionStoreViolation => 'Violación de los términos de servicio de Snap Store';

  @override
  String get snapReportDetailsLabel => 'Proporcione un motivo más detallado para su denuncia';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Su correo electrónico (opcional)';

  @override
  String get snapReportCancelButtonLabel => 'Cancelar';

  @override
  String get snapReportSubmitButtonLabel => 'Enviar informe';

  @override
  String get snapReportEnterValidEmailError => 'Introduzca una dirección de correo electrónico válida';

  @override
  String get snapReportDetailsHint => 'Comentar…';

  @override
  String get snapReportPrivacyAgreementLabel => 'Al enviar este formulario, confirmo que he leído y acepto el ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Aviso de privacidad de Canonical ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'y la ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'Normativa de privacidad';

  @override
  String get debPageErrorNoPackageInfo => 'No se encontró información del paquete';

  @override
  String get externalResources => 'Recursos adicionales';

  @override
  String get externalResourcesButtonLabel => 'Descubrir más';

  @override
  String get allGamesButtonLabel => 'Todos los juegos';

  @override
  String get externalResourcesDisclaimer => 'Nota: todas estas herramientas son externas. No son propiedad de Canonical ni esta es responsable de distribuirlas.';

  @override
  String get openInBrowser => 'Abrir en el navegador';

  @override
  String get installAll => 'Instalar todo';

  @override
  String get localDebWarningTitle => 'Potencialmente inseguro';

  @override
  String get localDebWarningBody => 'Este paquete es proporcionado por un tercero. La instalación de paquetes desde fuera del App Center puede aumentar el riesgo para su sistema y sus datos personales. Asegúrese de confiar en la fuente antes de continuar.';

  @override
  String get localDebLearnMore => 'Aprenda más información sobre paquetes de terceros';

  @override
  String get localDebDialogMessage => 'Este paquete es provisto por un tercero y puede amenazar su sistema y sus datos personales.';

  @override
  String get localDebDialogConfirmation => '¿Estás seguro de que quieres instalarlo?';

  @override
  String snapdExceptionRunningApps(String snapName) {
    return 'No hemos podido actualizar $snapName porque se está ejecutando actualmente.';
  }

  @override
  String get errorViewCheckStatusLabel => 'Comprobar el estado';

  @override
  String get errorViewNetworkErrorTitle => 'Conectar a internet';

  @override
  String get errorViewNetworkErrorDescription => 'No podemos cargar contenidos en el App Center sin conexión a Internet.';

  @override
  String get errorViewNetworkErrorAction => 'Compruebe tu conexión y vuelve a intentarlo.';

  @override
  String get errorViewServerErrorDescription => 'Lo sentimos, estamos experimentando problemas con el App Center.';

  @override
  String get errorViewServerErrorAction => 'Comprueba si hay actualizaciones o inténtalo más tarde.';

  @override
  String get errorViewUnknownErrorTitle => 'Algo salió mal';

  @override
  String get errorViewUnknownErrorDescription => 'Lo sentimos, pero no estamos seguros de cuál es el error.';

  @override
  String get errorViewUnknownErrorAction => 'Puedes reintentarlo ahora, comprobar el estado de las actualizaciones o volver a intentarlo más tarde.';
}
