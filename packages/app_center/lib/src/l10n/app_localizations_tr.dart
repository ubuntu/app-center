import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appCenterLabel => 'Uygulama Merkezi';

  @override
  String get appstreamSearchGreylist => 'uygulama;uygulama;paket;program;program;?;araç';

  @override
  String get snapPageChannelLabel => 'Kanal';

  @override
  String get snapPageConfinementLabel => 'Confinement';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'İletişime geç $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Tanım';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Geliştirici Websitesi';

  @override
  String get snapPageDownloadSizeLabel => 'İndirme boyutu';

  @override
  String get snapPageSizeLabel => 'Size';

  @override
  String get snapPageGalleryLabel => 'Galeri';

  @override
  String get snapPageLicenseLabel => 'Lisans';

  @override
  String get snapPageLinksLabel => 'Bağlantılar';

  @override
  String get snapPagePublisherLabel => 'Yayıncı';

  @override
  String get snapPagePublishedLabel => 'Yayınlanmış';

  @override
  String get snapPageSummaryLabel => 'Özet';

  @override
  String get snapPageVersionLabel => 'Sürüm';

  @override
  String get snapPageShareLinkCopiedMessage => 'Bağlantı panoya kopyalandı';

  @override
  String get explorePageLabel => 'Keşfet';

  @override
  String get explorePageCategoriesLabel => 'Kategoriler';

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
  String get managePageCheckForUpdates => 'Güncellemeleri kontrol et';

  @override
  String get managePageCheckingForUpdates => 'Güncellemeler kontrol ediliyor';

  @override
  String get managePageNoInternet => 'Can\'t reach server, check your internet connection or try again later.';

  @override
  String get managePageDescription => 'Uygulamalarınızın mevcut güncellemelerini kontol edin, güncelleyin ve durumlarını yönetin.';

  @override
  String get managePageDebUpdatesMessage => 'Debian package updates are handled by the Software Updater.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Yüklü ve güncellenmiş';

  @override
  String get managePageLabel => 'Yönet';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Şu an için güncelleme bulunmuyor. Tüm uygulamalarınız güncel.';

  @override
  String get managePageSearchFieldSearchHint => 'Yüklü uygulamalarınızı arayın';

  @override
  String get managePageShowDetailsLabel => 'Ayrıntıları göster';

  @override
  String get managePageShowSystemSnapsLabel => 'System Snap\'lerini göster';

  @override
  String get managePageUpdateAllLabel => 'Tümünü güncelle';

  @override
  String managePageUpdatedDaysAgo(int n) {
    return '$n gün önce güncellendi';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    return '$n hafta önce güncellendi';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    return '$n ay önce güncellendi';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    return '$n yıl önce güncellendi';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Güncellemeler mevcut ($n)';
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
  String get productivityPageLabel => 'Üretkenlik';

  @override
  String get developmentPageLabel => 'Geliştirme';

  @override
  String get gamesPageLabel => 'Oyunlar';

  @override
  String get gamesPageTitle => 'En İyiler';

  @override
  String get gamesPageTop => 'En iyi Oyunlar';

  @override
  String get gamesPageFeatured => 'Öne Çıkanlar';

  @override
  String get gamesPageBundles => 'Uygulama Paketleri';

  @override
  String get unknownPublisher => 'Bilinmeyen yayıncı';

  @override
  String get searchFieldDebSection => 'Debian paketleri';

  @override
  String get searchFieldSearchHint => 'Uygulama ara';

  @override
  String searchFieldSearchForLabel(String query) {
    return '\"$query\" araması için sonuçları gör';
  }

  @override
  String get searchFieldSnapSection => 'Snap paketleri';

  @override
  String get searchPageFilterByLabel => 'Filtrele';

  @override
  String searchPageNoResults(String query) {
    return '\"$query\" araması için sonuç bulunamadı';
  }

  @override
  String get searchPageNoResultsHint => 'Farklı veya daha genel anahtar kelimeler kullanın';

  @override
  String get searchPageNoResultsCategory => 'Üzgünüz, bu kategoriye ait bir paket bulamadık';

  @override
  String get searchPageNoResultsCategoryHint => 'Farklı kategoriyi deneyin veya daha genel anahtar kelimeler kullanın';

  @override
  String get searchPageSortByLabel => 'Sırala';

  @override
  String get searchPageRelevanceLabel => 'Alaka düzeyi';

  @override
  String searchPageTitle(String query) {
    return '\"$query\" için sonuçlar';
  }

  @override
  String get aboutPageLabel => 'Hakkında';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Sürüm $version';
  }

  @override
  String get aboutPageContributorTitle => 'Tasarlayan ve geliştiren:';

  @override
  String get aboutPageCommunityTitle => 'Topluluğun parçası ol:';

  @override
  String get aboutPageContributeLabel => 'Katkıda bulunun veya hata bildirin';

  @override
  String get aboutPageGitHubLabel => 'GitHub\'da bizi bulun';

  @override
  String get aboutPagePublishLabel => 'Snap Mağazası\'na yayınla';

  @override
  String get aboutPageLearnMoreLabel => 'Daha fazla bilgi edinin';

  @override
  String get appstreamUrlTypeBugtracker => 'Hata izleyici';

  @override
  String get appstreamUrlTypeContact => 'İletişim';

  @override
  String get appstreamUrlTypeContribute => 'Contribute';

  @override
  String get appstreamUrlTypeDonation => 'Bağış';

  @override
  String get appstreamUrlTypeFaq => 'SSS';

  @override
  String get appstreamUrlTypeHelp => 'Yardım';

  @override
  String get appstreamUrlTypeHomepage => 'Ana Sayfa';

  @override
  String get appstreamUrlTypeTranslate => 'Çeviriler';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Source';

  @override
  String get packageFormatDebLabel => 'Debian paketleri';

  @override
  String get packageFormatSnapLabel => 'Snap paketleri';

  @override
  String get snapActionCancelLabel => 'İptal Et';

  @override
  String get snapActionInstallLabel => 'Yükle';

  @override
  String get snapActionInstalledLabel => 'Installed';

  @override
  String get snapActionInstallingLabel => 'Yükleniyor';

  @override
  String get snapActionOpenLabel => 'Aç';

  @override
  String get snapActionRemoveLabel => 'Yüklemeyi Kaldır';

  @override
  String get snapActionRemovingLabel => 'Yükleme Kaldırılıyor';

  @override
  String get snapActionSwitchChannelLabel => 'Kanal değiştir';

  @override
  String get snapActionUpdateLabel => 'Güncelle';

  @override
  String get snapCategoryAll => 'Tüm kategoriler';

  @override
  String get snapActionUpdatingLabel => 'Güncelleniyor';

  @override
  String get snapCategoryArtAndDesign => 'Sanat ve Tasarım';

  @override
  String get snapCategoryBooksAndReference => 'Kitaplar ve Kaynak';

  @override
  String get snapCategoryDefaultButtonLabel => 'Daha fazlasını keşfet';

  @override
  String get snapCategoryDevelopment => 'Geliştirme';

  @override
  String get snapCategoryDevelopmentSlogan => 'Must-have snaps for developers';

  @override
  String get snapCategoryDevicesAndIot => 'Devices and IoT';

  @override
  String get snapCategoryEducation => 'Eğitim';

  @override
  String get snapCategoryEntertainment => 'Entertainment';

  @override
  String get snapCategoryFeatured => 'Featured';

  @override
  String get snapCategoryFeaturedSlogan => 'Featured Snaps';

  @override
  String get snapCategoryFinance => 'Finans';

  @override
  String get snapCategoryGames => 'Oyunlar';

  @override
  String get snapCategoryGamesSlogan => 'Everything for your game night';

  @override
  String get snapCategoryGameDev => 'Game Development';

  @override
  String get snapCategoryGameDevSlogan => 'Game Development';

  @override
  String get snapCategoryGameEmulators => 'Emulators';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emulators';

  @override
  String get snapCategoryGnomeGames => 'GNOME Games';

  @override
  String get snapCategoryGnomeGamesSlogan => 'GNOME Games Suite';

  @override
  String get snapCategoryKdeGames => 'KDE Games';

  @override
  String get snapCategoryKdeGamesSlogan => 'KDE Games Suite';

  @override
  String get snapCategoryGameLaunchers => 'Game Launchers';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Game Launchers';

  @override
  String get snapCategoryGameContentCreation => 'Content Creation';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Content Creation';

  @override
  String get snapCategoryHealthAndFitness => 'Health and Fitness';

  @override
  String get snapCategoryMusicAndAudio => 'Müzik ve Ses';

  @override
  String get snapCategoryNewsAndWeather => 'News and Weather';

  @override
  String get snapCategoryPersonalisation => 'Personalisation';

  @override
  String get snapCategoryPhotoAndVideo => 'Fotoğraf ve Video';

  @override
  String get snapCategoryProductivity => 'Üretkenlik';

  @override
  String get snapCategoryProductivityButtonLabel => 'Discover the productivity collection';

  @override
  String get snapCategoryProductivitySlogan => 'Cross one thing off your to-do list';

  @override
  String get snapCategoryScience => 'Bilim';

  @override
  String get snapCategorySecurity => 'Güvenlik';

  @override
  String get snapCategoryServerAndCloud => 'Sunucu ve Bulut';

  @override
  String get snapCategorySocial => 'Sosyal';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu Desktop';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Jump start your desktop';

  @override
  String get snapCategoryUtilities => 'Utilities';

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
  String get snapReportPrivacyAgreementLabel => 'In submitting this form, I confirm that I have read and agree to ';

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
  String get installAll => 'Install all';

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
