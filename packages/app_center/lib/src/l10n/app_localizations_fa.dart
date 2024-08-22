import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appCenterLabel => 'مرکز کاره';

  @override
  String get appstreamSearchGreylist => 'app;application;package;program;programme;suite;tool';

  @override
  String get snapPageChannelLabel => 'کانال';

  @override
  String get snapPageConfinementLabel => 'محدودیت';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'تماس با $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'توضیحات';

  @override
  String get snapPageDeveloperWebsiteLabel => 'پایگاه وب توسعه‌دهنده';

  @override
  String get snapPageDownloadSizeLabel => 'اندازهٔ بارگیری';

  @override
  String get snapPageSizeLabel => 'Size';

  @override
  String get snapPageGalleryLabel => 'جُنگ';

  @override
  String get snapPageLicenseLabel => 'پروانه';

  @override
  String get snapPageLinksLabel => 'پیوندها';

  @override
  String get snapPagePublisherLabel => 'ناشر';

  @override
  String get snapPagePublishedLabel => 'منتشر شده';

  @override
  String get snapPageSummaryLabel => 'خلاصه';

  @override
  String get snapPageVersionLabel => 'نگارش';

  @override
  String get snapPageShareLinkCopiedMessage => 'پیوند در تخته‌گیره رونوشت شد';

  @override
  String get explorePageLabel => 'کاوش';

  @override
  String get explorePageCategoriesLabel => 'دسته‌ها';

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
  String get managePageCheckForUpdates => 'بررسی برای به‌روز رسانی';

  @override
  String get managePageCheckingForUpdates => 'بررسی کردن برای به‌روز رسانی';

  @override
  String get managePageNoInternet => 'Can\'t reach server, check your internet connection or try again later.';

  @override
  String get managePageDescription => 'Check for available updates, update your apps, and manage the status of all your apps.';

  @override
  String get managePageDebUpdatesMessage => 'Debian package updates are handled by the Software Updater.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Installed and updated';

  @override
  String get managePageLabel => 'مدیریت';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'No updates available. Your applications are all up to date.';

  @override
  String get managePageSearchFieldSearchHint => 'Search your installed apps';

  @override
  String get managePageShowDetailsLabel => 'نمایش جزییات';

  @override
  String get managePageShowSystemSnapsLabel => 'Show system snaps';

  @override
  String get managePageUpdateAllLabel => 'به‌روز رسانی همه';

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
    return 'Updates available ($n)';
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
  String get productivityPageLabel => 'بهره‌وری';

  @override
  String get developmentPageLabel => 'توسعه';

  @override
  String get gamesPageLabel => 'بازی‌ها';

  @override
  String get gamesPageTitle => 'آن‌چه داغ است';

  @override
  String get gamesPageTop => 'Top Games';

  @override
  String get gamesPageFeatured => 'Featured Titles';

  @override
  String get gamesPageBundles => 'App Bundles';

  @override
  String get unknownPublisher => 'Unknown publisher';

  @override
  String get searchFieldDebSection => 'بسته‌های دبیان';

  @override
  String get searchFieldSearchHint => 'Search for apps';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'See all results for \"$query\"';
  }

  @override
  String get searchFieldSnapSection => 'بسته‌های اسنب';

  @override
  String get searchPageFilterByLabel => 'Filter by';

  @override
  String searchPageNoResults(String query) {
    return 'No results found for \"$query\"';
  }

  @override
  String get searchPageNoResultsHint => 'Try using different or more general keywords';

  @override
  String get searchPageNoResultsCategory => 'Sorry, we couldn’t find any packages in this category';

  @override
  String get searchPageNoResultsCategoryHint => 'Try a different category or use more general keywords';

  @override
  String get searchPageSortByLabel => 'مرتب‌سازی بر اساس';

  @override
  String get searchPageRelevanceLabel => 'ارتباط';

  @override
  String searchPageTitle(String query) {
    return 'Results for \"$query\"';
  }

  @override
  String get aboutPageLabel => 'درباره';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPageContributorTitle => 'Designed and developed by:';

  @override
  String get aboutPageCommunityTitle => 'Be part of the community:';

  @override
  String get aboutPageContributeLabel => 'Contribute or report bug';

  @override
  String get aboutPageGitHubLabel => 'Find us on GitHub';

  @override
  String get aboutPagePublishLabel => 'Publish to the Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Learn more';

  @override
  String get appstreamUrlTypeBugtracker => 'ردیاب مشکل';

  @override
  String get appstreamUrlTypeContact => 'ارتباط';

  @override
  String get appstreamUrlTypeContribute => 'Contribute';

  @override
  String get appstreamUrlTypeDonation => 'اعانه';

  @override
  String get appstreamUrlTypeFaq => 'پ‌پ';

  @override
  String get appstreamUrlTypeHelp => 'راهنما';

  @override
  String get appstreamUrlTypeHomepage => 'آغازه';

  @override
  String get appstreamUrlTypeTranslate => 'ترجمه‌ها';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Source';

  @override
  String get packageFormatDebLabel => 'بسته‌های دبیان';

  @override
  String get packageFormatSnapLabel => 'بسته‌های اسنب';

  @override
  String get snapActionCancelLabel => 'لغو';

  @override
  String get snapActionInstallLabel => 'نصب';

  @override
  String get snapActionInstalledLabel => 'Installed';

  @override
  String get snapActionInstallingLabel => 'نصب';

  @override
  String get snapActionOpenLabel => 'گشودن';

  @override
  String get snapActionRemoveLabel => 'لغو نصب';

  @override
  String get snapActionRemovingLabel => 'لغو کردن نصب';

  @override
  String get snapActionSwitchChannelLabel => 'Switch channel';

  @override
  String get snapActionUpdateLabel => 'به‌روز رسانی';

  @override
  String get snapCategoryAll => 'All categories';

  @override
  String get snapActionUpdatingLabel => 'به‌روز رساندن';

  @override
  String get snapCategoryArtAndDesign => 'هنر و طراحی';

  @override
  String get snapCategoryBooksAndReference => 'کتاب‌ها و ارجاع';

  @override
  String get snapCategoryDefaultButtonLabel => 'Discover more';

  @override
  String get snapCategoryDevelopment => 'توسعه';

  @override
  String get snapCategoryDevelopmentSlogan => 'Must-have snaps for developers';

  @override
  String get snapCategoryDevicesAndIot => 'Devices and IoT';

  @override
  String get snapCategoryEducation => 'تحصیلات';

  @override
  String get snapCategoryEntertainment => 'سرگرمی';

  @override
  String get snapCategoryFeatured => 'ویژه';

  @override
  String get snapCategoryFeaturedSlogan => 'Featured Snaps';

  @override
  String get snapCategoryFinance => 'مالی';

  @override
  String get snapCategoryGames => 'بازی‌ها';

  @override
  String get snapCategoryGamesSlogan => 'Everything for your game night';

  @override
  String get snapCategoryGameDev => 'Game Development';

  @override
  String get snapCategoryGameDevSlogan => 'Game Development';

  @override
  String get snapCategoryGameEmulators => 'شبیه‌سازها';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'شبیه‌سازها';

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
  String get snapCategoryHealthAndFitness => 'سلامتی و تندرستی';

  @override
  String get snapCategoryMusicAndAudio => 'آهنگ و صدا';

  @override
  String get snapCategoryNewsAndWeather => 'اخبار و هواشناسی';

  @override
  String get snapCategoryPersonalisation => 'شخصی‌سازی';

  @override
  String get snapCategoryPhotoAndVideo => 'تصویر و ویدیو';

  @override
  String get snapCategoryProductivity => 'بهره‌وری';

  @override
  String get snapCategoryProductivityButtonLabel => 'Discover the productivity collection';

  @override
  String get snapCategoryProductivitySlogan => 'Cross one thing off your to-do list';

  @override
  String get snapCategoryScience => 'علمی';

  @override
  String get snapCategorySecurity => 'امنیت';

  @override
  String get snapCategoryServerAndCloud => 'کارساز و ابر';

  @override
  String get snapCategorySocial => 'اجتماعی';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu Desktop';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Jump start your desktop';

  @override
  String get snapCategoryUtilities => 'ابزارها';

  @override
  String get snapConfinementClassic => 'کلاسیک';

  @override
  String get snapConfinementDevmode => 'حالت توسعه';

  @override
  String get snapConfinementStrict => 'شدید';

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
  String get snapSortOrderRelevance => 'ارتباط';

  @override
  String get snapRatingsBandVeryGood => 'Very good';

  @override
  String get snapRatingsBandGood => 'خوب';

  @override
  String get snapRatingsBandNeutral => 'متوسط';

  @override
  String get snapRatingsBandPoor => 'ضعیف';

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
  String get snapReportCancelButtonLabel => 'لغو';

  @override
  String get snapReportSubmitButtonLabel => 'Submit report';

  @override
  String get snapReportEnterValidEmailError => 'Enter a valid email address';

  @override
  String get snapReportDetailsHint => 'نظر…';

  @override
  String get snapReportPrivacyAgreementLabel => 'In submitting this form, I confirm that I have read and agree to ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Canonical’s Privacy Notice ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'و ';

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
