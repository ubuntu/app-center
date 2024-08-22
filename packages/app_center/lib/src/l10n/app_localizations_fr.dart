import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appCenterLabel => 'Centre d\'applications';

  @override
  String get appstreamSearchGreylist => 'app;appli;application;paquet;programme;outil;utilitaire';

  @override
  String get snapPageChannelLabel => 'Canal';

  @override
  String get snapPageConfinementLabel => 'Confinement';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Contacter $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Description';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Site de développeur';

  @override
  String get snapPageDownloadSizeLabel => 'Taille du téléchargement';

  @override
  String get snapPageSizeLabel => 'Taille';

  @override
  String get snapPageGalleryLabel => 'Galerie';

  @override
  String get snapPageLicenseLabel => 'Licence';

  @override
  String get snapPageLinksLabel => 'Liens';

  @override
  String get snapPagePublisherLabel => 'Éditeur';

  @override
  String get snapPagePublishedLabel => 'Publié';

  @override
  String get snapPageSummaryLabel => 'Résumé';

  @override
  String get snapPageVersionLabel => 'Version';

  @override
  String get snapPageShareLinkCopiedMessage => 'Lien copié dans le presse-papier';

  @override
  String get explorePageLabel => 'Explorer';

  @override
  String get explorePageCategoriesLabel => 'Catégories';

  @override
  String get managePageOwnUpdateAvailable => 'Mise à jour du Centre d\'Applications disponible';

  @override
  String get managePageQuitToUpdate => 'Quitter pour mettre à jour';

  @override
  String get managePageOwnUpdateDescription => 'Lorsque vous quittez l’application, elle est automatiquement mise à jour.';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return 'Le centre d’applications se mettra automatiquement à jour dans $time.';
  }

  @override
  String get managePageOwnUpdateQuitButton => 'Quitter pour mettre à jour';

  @override
  String get managePageCheckForUpdates => 'Vérifier les mises à jour';

  @override
  String get managePageCheckingForUpdates => 'Recherche de mises à jour';

  @override
  String get managePageNoInternet => 'Impossible d’atteindre le serveur, vérifiez votre connexion Internet ou réessayez plus tard.';

  @override
  String get managePageDescription => 'Rechercher les mises à jour disponibles, mettre à jour vos applications, et gérer l\'état de toutes vos applications.';

  @override
  String get managePageDebUpdatesMessage => 'Les mises à jour des paquets Debian sont gérées par le Gestionnaire de mises à jour.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Installés et mis à jour';

  @override
  String get managePageLabel => 'Gérer les Snaps installés';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Pas de mise à jour disponible. Vos applications sont toutes à jour.';

  @override
  String get managePageSearchFieldSearchHint => 'Rechercher vos applications installées';

  @override
  String get managePageShowDetailsLabel => 'Afficher les détails';

  @override
  String get managePageShowSystemSnapsLabel => 'Afficher les paquets snap système';

  @override
  String get managePageUpdateAllLabel => 'Tout mettre à jour';

  @override
  String managePageUpdatedDaysAgo(int n) {
    return 'Mis à jour il y a $n jours';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n semaines',
      one: '$n semaine',
    );
    return 'Mis à jour $_temp0 auparavant';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n mois',
      one: '$n mois',
    );
    return 'Mis à jour $_temp0 auparavant';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ans',
      one: '$n an',
    );
    return 'Mis à jour $_temp0 auparavant';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Mises à jour disponibles ($n)';
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
  String get productivityPageLabel => 'Bureautique';

  @override
  String get developmentPageLabel => 'Développement';

  @override
  String get gamesPageLabel => 'Jeux';

  @override
  String get gamesPageTitle => 'Qu\'est-ce qui est chaud';

  @override
  String get gamesPageTop => 'Meilleurs jeux';

  @override
  String get gamesPageFeatured => 'Titres en vedette';

  @override
  String get gamesPageBundles => 'Lots d\'applications';

  @override
  String get unknownPublisher => 'Éditeur inconnu';

  @override
  String get searchFieldDebSection => 'Paquets Debian';

  @override
  String get searchFieldSearchHint => 'Rechercher des applications';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Afficher tous les résultats pour \"$query\"';
  }

  @override
  String get searchFieldSnapSection => 'Paquets Snap';

  @override
  String get searchPageFilterByLabel => 'Filtrer par';

  @override
  String searchPageNoResults(String query) {
    return 'Aucun résultat trouvé pour \"$query\"';
  }

  @override
  String get searchPageNoResultsHint => 'Essayez d\'utiliser des mots-clés différents ou plus généraux';

  @override
  String get searchPageNoResultsCategory => 'Désolé, nous n\'avons pu trouver aucun paquets dans cette catégorie';

  @override
  String get searchPageNoResultsCategoryHint => 'Essayez une autre catégorie ou utilisez des mots-clés plus généraux';

  @override
  String get searchPageSortByLabel => 'Trier par';

  @override
  String get searchPageRelevanceLabel => 'Pertinence';

  @override
  String searchPageTitle(String query) {
    return 'Résultats pour \"$query\"';
  }

  @override
  String get aboutPageLabel => 'À propos';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPageContributorTitle => 'Conçu et développé par :';

  @override
  String get aboutPageCommunityTitle => 'Faites partie de la communauté :';

  @override
  String get aboutPageContributeLabel => 'Contribuer ou signaler une anomalie';

  @override
  String get aboutPageGitHubLabel => 'Retrouvez-nous sur GitHub';

  @override
  String get aboutPagePublishLabel => 'Publier sur le Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'En savoir plus';

  @override
  String get appstreamUrlTypeBugtracker => 'Système de suivi des bogues';

  @override
  String get appstreamUrlTypeContact => 'Contact';

  @override
  String get appstreamUrlTypeContribute => 'Contribuer';

  @override
  String get appstreamUrlTypeDonation => 'Faire un don';

  @override
  String get appstreamUrlTypeFaq => 'FAQ';

  @override
  String get appstreamUrlTypeHelp => 'Aide';

  @override
  String get appstreamUrlTypeHomepage => 'Page d’accueil';

  @override
  String get appstreamUrlTypeTranslate => 'Traductions';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Source';

  @override
  String get packageFormatDebLabel => 'Paquets Debian';

  @override
  String get packageFormatSnapLabel => 'Paquets Snap';

  @override
  String get snapActionCancelLabel => 'Annuler';

  @override
  String get snapActionInstallLabel => 'Installer';

  @override
  String get snapActionInstalledLabel => 'Installées';

  @override
  String get snapActionInstallingLabel => 'En cours d’installation';

  @override
  String get snapActionOpenLabel => 'Ouvrir';

  @override
  String get snapActionRemoveLabel => 'Désinstaller';

  @override
  String get snapActionRemovingLabel => 'Désinstallation en cours';

  @override
  String get snapActionSwitchChannelLabel => 'Changer de canal';

  @override
  String get snapActionUpdateLabel => 'Mettre à jour';

  @override
  String get snapCategoryAll => 'Toutes les catégories';

  @override
  String get snapActionUpdatingLabel => 'Mise à jour';

  @override
  String get snapCategoryArtAndDesign => 'Art et conception';

  @override
  String get snapCategoryBooksAndReference => 'Livres et références';

  @override
  String get snapCategoryDefaultButtonLabel => 'Découvrir davantage';

  @override
  String get snapCategoryDevelopment => 'Développement';

  @override
  String get snapCategoryDevelopmentSlogan => 'Snaps indispensables pour les développeurs';

  @override
  String get snapCategoryDevicesAndIot => 'Appareils et IoT';

  @override
  String get snapCategoryEducation => 'Éducation';

  @override
  String get snapCategoryEntertainment => 'Divertissement';

  @override
  String get snapCategoryFeatured => 'En vedette';

  @override
  String get snapCategoryFeaturedSlogan => 'Snaps en vedette';

  @override
  String get snapCategoryFinance => 'Finance';

  @override
  String get snapCategoryGames => 'Jeux';

  @override
  String get snapCategoryGamesSlogan => 'Tout pour votre soirée de jeu';

  @override
  String get snapCategoryGameDev => 'Développement de jeu';

  @override
  String get snapCategoryGameDevSlogan => 'Développement de jeu';

  @override
  String get snapCategoryGameEmulators => 'Émulateurs';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Émulateurs';

  @override
  String get snapCategoryGnomeGames => 'Jeux GNOME';

  @override
  String get snapCategoryGnomeGamesSlogan => 'Suite de jeux GNOME';

  @override
  String get snapCategoryKdeGames => 'Jeux KDE';

  @override
  String get snapCategoryKdeGamesSlogan => 'Suite de jeux KDE';

  @override
  String get snapCategoryGameLaunchers => 'Lanceurs de jeux';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Lanceurs de jeux';

  @override
  String get snapCategoryGameContentCreation => 'Création de contenu';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Création de contenu';

  @override
  String get snapCategoryHealthAndFitness => 'Santé et forme';

  @override
  String get snapCategoryMusicAndAudio => 'Musique et audio';

  @override
  String get snapCategoryNewsAndWeather => 'Informations et météo';

  @override
  String get snapCategoryPersonalisation => 'Personnalisation';

  @override
  String get snapCategoryPhotoAndVideo => 'Photo et vidéo';

  @override
  String get snapCategoryProductivity => 'Bureautique';

  @override
  String get snapCategoryProductivityButtonLabel => 'Découvrez la collection productivité';

  @override
  String get snapCategoryProductivitySlogan => 'Rayez une chose de votre liste de choses à faire';

  @override
  String get snapCategoryScience => 'Sciences';

  @override
  String get snapCategorySecurity => 'Sécurité';

  @override
  String get snapCategoryServerAndCloud => 'Serveur et cloud';

  @override
  String get snapCategorySocial => 'Social';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu Desktop';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Démarrez votre bureau';

  @override
  String get snapCategoryUtilities => 'Utilitaires';

  @override
  String get snapConfinementClassic => 'Classique';

  @override
  String get snapConfinementDevmode => 'Mode développement';

  @override
  String get snapConfinementStrict => 'Strict';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Alphabétique (A à Z)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Alphabétique (Z à A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Taille (du plus petit au plus grand)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Taille (du plus grand au plus petit)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Taille (du plus petit au plus grand)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Taille (du plus grand au plus petit)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Moins récemment mis à jour';

  @override
  String get snapSortOrderInstalledDateDesc => 'Plus récemment mis à jour';

  @override
  String get snapSortOrderRelevance => 'Pertinence';

  @override
  String get snapRatingsBandVeryGood => 'Très bon';

  @override
  String get snapRatingsBandGood => 'Bon';

  @override
  String get snapRatingsBandNeutral => 'Neutre';

  @override
  String get snapRatingsBandPoor => 'Mauvais';

  @override
  String get snapRatingsBandVeryPoor => 'Très mauvais';

  @override
  String get snapRatingsBandInsufficientVotes => 'Votes insuffisants';

  @override
  String snapRatingsVotes(int n) {
    return '$n votes';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Signaler $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Choisissez une raison pour signaler ce snap';

  @override
  String get snapReportSelectAnOptionLabel => 'Sélectionner une option';

  @override
  String get snapReportOptionCopyrightViolation => 'Violation de droit d\'auteur ou marque';

  @override
  String get snapReportOptionStoreViolation => 'Violation des conditions d\'utilisation de Snap Store';

  @override
  String get snapReportDetailsLabel => 'Veuillez fournir une raison plus détaillée à votre signalement';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Votre email (optionnel)';

  @override
  String get snapReportCancelButtonLabel => 'Annuler';

  @override
  String get snapReportSubmitButtonLabel => 'Soumettre le signalement';

  @override
  String get snapReportEnterValidEmailError => 'Entrez une adresse email valide';

  @override
  String get snapReportDetailsHint => 'Commentaire...';

  @override
  String get snapReportPrivacyAgreementLabel => 'En soumettant ce formulaire, je confirme avoir lu et accepté de ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Avis de confidentialité de Canonical ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'et ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get debPageErrorNoPackageInfo => 'Aucune information de paquet trouvée';

  @override
  String get externalResources => 'Ressources additionnelles';

  @override
  String get externalResourcesButtonLabel => 'Découvrir davantage';

  @override
  String get allGamesButtonLabel => 'Tous les jeux';

  @override
  String get externalResourcesDisclaimer => 'Remarque : ce sont tous des outils externes. Ceux-ci ne sont ni détenus ni distribués par Canonical.';

  @override
  String get openInBrowser => 'Ouvrir dans navigateur';

  @override
  String get installAll => 'Installer tout';

  @override
  String get localDebWarningTitle => 'Potentiellement non sécurisé';

  @override
  String get localDebWarningBody => 'Ce paquetage est fourni par un tiers. L’installation de paquetages à l’extérieur du Centre d\'applications peut augmenter le risque pour votre système et vos données personnelles. Assurez-vous que la source soit de confiance avant de poursuivre.';

  @override
  String get localDebLearnMore => 'En savoir plus sur les paquetages tiers';

  @override
  String get localDebDialogMessage => 'Ce paquetage est fourni par un tiers et pourrait menacer votre système et vos données personnelles.';

  @override
  String get localDebDialogConfirmation => 'Vous êtes sûr(e) de vouloir l’installer ?';

  @override
  String snapdExceptionRunningApps(String snapName) {
    return 'Nous n’avons pas pu mettre à jour $snapName car il est actuellement en cours d’exécution.';
  }

  @override
  String get errorViewCheckStatusLabel => 'Vérifier statut';

  @override
  String get errorViewNetworkErrorTitle => 'Connecte à Internet';

  @override
  String get errorViewNetworkErrorDescription => 'Nous ne pouvons pas charger de contenu dans le Centre d\'applications sans connexion Internet.';

  @override
  String get errorViewNetworkErrorAction => 'Vérifiez votre connexion et réessayez.';

  @override
  String get errorViewServerErrorDescription => 'Nous sommes désolés, nous rencontrons actuellement des problèmes avec le Centre d\'applications.';

  @override
  String get errorViewServerErrorAction => 'Vérifiez l’état des mises à jour ou réessayez plus tard.';

  @override
  String get errorViewUnknownErrorTitle => 'Quelque chose n\'allait pas';

  @override
  String get errorViewUnknownErrorDescription => 'Nous sommes désolés, mais nous ne savons pas quelle est l’erreur.';

  @override
  String get errorViewUnknownErrorAction => 'Vous pouvez réessayer maintenant, vérifier l’état des mises à jour ou réessayer plus tard.';
}
