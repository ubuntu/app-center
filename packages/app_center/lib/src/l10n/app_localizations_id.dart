import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appCenterLabel => 'Pusat Aplikasi';

  @override
  String get appstreamSearchGreylist => 'app;application;package;program;programme;suite;tool';

  @override
  String get snapPageChannelLabel => 'Kanal';

  @override
  String get snapPageConfinementLabel => 'Aturan Pakai';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Kontak $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Deskripsi';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Situs pengembang';

  @override
  String get snapPageDownloadSizeLabel => 'Ukuran unduhan';

  @override
  String get snapPageSizeLabel => 'Size';

  @override
  String get snapPageGalleryLabel => 'Galeri';

  @override
  String get snapPageLicenseLabel => 'Lisensi';

  @override
  String get snapPageLinksLabel => 'Tautan';

  @override
  String get snapPagePublisherLabel => 'Penerbit';

  @override
  String get snapPagePublishedLabel => 'Diterbitkan';

  @override
  String get snapPageSummaryLabel => 'Ringkasan';

  @override
  String get snapPageVersionLabel => 'Versi';

  @override
  String get snapPageShareLinkCopiedMessage => 'Tautan disalin ke papan klip';

  @override
  String get explorePageLabel => 'Jelajahi';

  @override
  String get explorePageCategoriesLabel => 'Kategori';

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
  String get managePageCheckForUpdates => 'Cek pembaruan';

  @override
  String get managePageCheckingForUpdates => 'Mengecek pembaruan';

  @override
  String get managePageNoInternet => 'Can\'t reach server, check your internet connection or try again later.';

  @override
  String get managePageDescription => 'Cek pembaruan tersedia, perbarui aplikasi Anda, dan kelola status semua aplikasi Anda.';

  @override
  String get managePageDebUpdatesMessage => 'Debian package updates are handled by the Software Updater.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Terinstal dan diperbarui';

  @override
  String get managePageLabel => 'Kelola';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Tidak ada pembaruan. Aplikasi Anda telah mutakhir.';

  @override
  String get managePageSearchFieldSearchHint => 'Telusuri aplikasi terinstal';

  @override
  String get managePageShowDetailsLabel => 'Tampilkan detail';

  @override
  String get managePageShowSystemSnapsLabel => 'Tampilkan aplikasi sistem';

  @override
  String get managePageUpdateAllLabel => 'Perbarui semua';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '$n day',
    );
    return 'Updated $_temp0 ago';
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
    return 'Pembaruan tersedia ($n)';
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
  String get productivityPageLabel => 'Produktivitas';

  @override
  String get developmentPageLabel => 'Pengembangan';

  @override
  String get gamesPageLabel => 'Permainan';

  @override
  String get gamesPageTitle => 'What\'s Hot';

  @override
  String get gamesPageTop => 'Permainan Teratas';

  @override
  String get gamesPageFeatured => 'Featured Titles';

  @override
  String get gamesPageBundles => 'Bundel Apli';

  @override
  String get unknownPublisher => 'Penerbit tidak diketahui';

  @override
  String get searchFieldDebSection => 'Paket Debian';

  @override
  String get searchFieldSearchHint => 'Telusuri aplikasi';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Lihat semua hasil untuk \"$query\"';
  }

  @override
  String get searchFieldSnapSection => 'Paket Snap';

  @override
  String get searchPageFilterByLabel => 'Filter berdasarkan';

  @override
  String searchPageNoResults(String query) {
    return 'Tidak ada hasil untuk \"$query\"';
  }

  @override
  String get searchPageNoResultsHint => 'Coba gunakan kata kunci yang lain atau yang lebih umum';

  @override
  String get searchPageNoResultsCategory => 'Maaf, kami tidak dapat menemukan paket apapun dalam kategori ini';

  @override
  String get searchPageNoResultsCategoryHint => 'Coba kategori lain atau kata kunci yang lebih umum';

  @override
  String get searchPageSortByLabel => 'Urut Berdasarkan';

  @override
  String get searchPageRelevanceLabel => 'Relevansi';

  @override
  String searchPageTitle(String query) {
    return 'Hasil untuk \"$query\"';
  }

  @override
  String get aboutPageLabel => 'Tentang';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Versi $version';
  }

  @override
  String get aboutPageContributorTitle => 'Didesain dan dikembangkan oleh:';

  @override
  String get aboutPageCommunityTitle => 'Bagian dari komunitas:';

  @override
  String get aboutPageContributeLabel => 'Kontribusi atau laporkan bug';

  @override
  String get aboutPageGitHubLabel => 'Temukan di GitHub';

  @override
  String get aboutPagePublishLabel => 'Terbitkan ke Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Pelajari selengkapnya';

  @override
  String get appstreamUrlTypeBugtracker => 'Pelacak bug';

  @override
  String get appstreamUrlTypeContact => 'Kontak';

  @override
  String get appstreamUrlTypeContribute => 'Kontribusi';

  @override
  String get appstreamUrlTypeDonation => 'Donasi';

  @override
  String get appstreamUrlTypeFaq => 'Pertanyaan Umum';

  @override
  String get appstreamUrlTypeHelp => 'Bantuan';

  @override
  String get appstreamUrlTypeHomepage => 'Halaman beranda';

  @override
  String get appstreamUrlTypeTranslate => 'Terjemahan';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Sumber';

  @override
  String get packageFormatDebLabel => 'Paket Debian';

  @override
  String get packageFormatSnapLabel => 'Paket Snap';

  @override
  String get snapActionCancelLabel => 'Batal';

  @override
  String get snapActionInstallLabel => 'Pasangkan';

  @override
  String get snapActionInstalledLabel => 'Installed';

  @override
  String get snapActionInstallingLabel => 'Menginstal';

  @override
  String get snapActionOpenLabel => 'Buka';

  @override
  String get snapActionRemoveLabel => 'Copot pemasangan';

  @override
  String get snapActionRemovingLabel => 'Mencopot pemasangan';

  @override
  String get snapActionSwitchChannelLabel => 'Alihkan kanal';

  @override
  String get snapActionUpdateLabel => 'Perbarui';

  @override
  String get snapCategoryAll => 'Semua kategori';

  @override
  String get snapActionUpdatingLabel => 'Memperbarui';

  @override
  String get snapCategoryArtAndDesign => 'Desain dan Seni';

  @override
  String get snapCategoryBooksAndReference => 'Buku dan Referensi';

  @override
  String get snapCategoryDefaultButtonLabel => 'Temukan lebih banyak';

  @override
  String get snapCategoryDevelopment => 'Pengembangan';

  @override
  String get snapCategoryDevelopmentSlogan => 'Snap yang wajib dimiliki pengembang';

  @override
  String get snapCategoryDevicesAndIot => 'Perangkat dan IoT';

  @override
  String get snapCategoryEducation => 'Pendidikan';

  @override
  String get snapCategoryEntertainment => 'Hiburan';

  @override
  String get snapCategoryFeatured => 'Unggulan';

  @override
  String get snapCategoryFeaturedSlogan => 'Snap Unggulan';

  @override
  String get snapCategoryFinance => 'Keuangan';

  @override
  String get snapCategoryGames => 'Permainan';

  @override
  String get snapCategoryGamesSlogan => 'Semuanya untuk malam permainan Anda';

  @override
  String get snapCategoryGameDev => 'Pengembangan Permainan';

  @override
  String get snapCategoryGameDevSlogan => 'Pengembangan Permainan';

  @override
  String get snapCategoryGameEmulators => 'Emulator';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Emulator';

  @override
  String get snapCategoryGnomeGames => 'Permainan GNOME';

  @override
  String get snapCategoryGnomeGamesSlogan => 'Rangkaian Permainan GNOME';

  @override
  String get snapCategoryKdeGames => 'Permainan KDE';

  @override
  String get snapCategoryKdeGamesSlogan => 'Rangkaian Permainan KDE';

  @override
  String get snapCategoryGameLaunchers => 'Peluncur Permainan';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Peluncur Permainan';

  @override
  String get snapCategoryGameContentCreation => 'Pembuatan Konten';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Pembuatan Konten';

  @override
  String get snapCategoryHealthAndFitness => 'Fitnes dan Kesehatan';

  @override
  String get snapCategoryMusicAndAudio => 'Audio dan Musik';

  @override
  String get snapCategoryNewsAndWeather => 'Cuaca dan Berita';

  @override
  String get snapCategoryPersonalisation => 'Personalisasi';

  @override
  String get snapCategoryPhotoAndVideo => 'Vidio dan Foto';

  @override
  String get snapCategoryProductivity => 'Produktivitas';

  @override
  String get snapCategoryProductivityButtonLabel => 'Temukan koleksi produktivitas';

  @override
  String get snapCategoryProductivitySlogan => 'Coret satu hal dari daftar tugas Anda';

  @override
  String get snapCategoryScience => 'Sains';

  @override
  String get snapCategorySecurity => 'Keamanan';

  @override
  String get snapCategoryServerAndCloud => 'Cloud dan Server';

  @override
  String get snapCategorySocial => 'Sosial';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu Desktop';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Langsung mulai desktop Anda';

  @override
  String get snapCategoryUtilities => 'Utilitas';

  @override
  String get snapConfinementClassic => 'Klasik';

  @override
  String get snapConfinementDevmode => 'Mode developer';

  @override
  String get snapConfinementStrict => 'Ketat';

  @override
  String get snapSortOrderAlphabeticalAsc => 'Alfabetis (A sampai Z)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'Alfabetis (Z sampai A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Ukuran (paling kecil sampai paling besar)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Ukuran (paling besar sampai paling kecil)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Ukuran (paling kecil sampai paling besar)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Ukuran (paling besar sampai paling kecil)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Least recently updated';

  @override
  String get snapSortOrderInstalledDateDesc => 'Baru-baru ini diperbarui';

  @override
  String get snapSortOrderRelevance => 'Relevansi';

  @override
  String get snapRatingsBandVeryGood => 'Sangat Bagus';

  @override
  String get snapRatingsBandGood => 'Bagus';

  @override
  String get snapRatingsBandNeutral => 'Netral';

  @override
  String get snapRatingsBandPoor => 'Buruk';

  @override
  String get snapRatingsBandVeryPoor => 'Sangat buruk';

  @override
  String get snapRatingsBandInsufficientVotes => 'Suara tidak memadai';

  @override
  String snapRatingsVotes(int n) {
    return '$n suara';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Laporkan $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Pilih alasan untuk melaporkan snap ini';

  @override
  String get snapReportSelectAnOptionLabel => 'Pilih sebuah opsi';

  @override
  String get snapReportOptionCopyrightViolation => 'Pelanggaran hak cipta atau merek dagang';

  @override
  String get snapReportOptionStoreViolation => 'Pelanggaran ketentuan penggunaan Snap Store';

  @override
  String get snapReportDetailsLabel => 'Harap berikan alasan lebih lanjut tentang laporan Anda';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Email Anda (opsional)';

  @override
  String get snapReportCancelButtonLabel => 'Batal';

  @override
  String get snapReportSubmitButtonLabel => 'Kirim laporan';

  @override
  String get snapReportEnterValidEmailError => 'Masukkan alamat email yang valid';

  @override
  String get snapReportDetailsHint => 'Komentar...';

  @override
  String get snapReportPrivacyAgreementLabel => 'Dalam mengirimkan laporan ini, saya mengkonfirmasi bahwa saya telah membaca dan menyetujui ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Pemberitahuan Privasi Canonical ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'dan ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'Kebijakan Privasi';

  @override
  String get debPageErrorNoPackageInfo => 'Tidak ada informasi paket yang ditemukan';

  @override
  String get externalResources => 'Sumber daya tambahan';

  @override
  String get externalResourcesButtonLabel => 'Temukan lebih banyak';

  @override
  String get allGamesButtonLabel => 'Semua permainan';

  @override
  String get externalResourcesDisclaimer => 'Catatan: Semua ini adalah alat eksternal. Tidak dimiliki ataupun didistribusikan oleh Canonical.';

  @override
  String get openInBrowser => 'Buka di browser';

  @override
  String get installAll => 'Pasang semua';

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
