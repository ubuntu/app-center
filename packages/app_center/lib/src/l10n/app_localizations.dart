import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_be.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_eo.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nn.dart';
import 'app_localizations_oc.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('be'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('en'),
    Locale('en', 'GB'),
    Locale('eo'),
    Locale('es'),
    Locale('fa'),
    Locale('fi'),
    Locale('fr'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nn'),
    Locale('oc'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('sk'),
    Locale('sv'),
    Locale('tr'),
    Locale('uk'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @appCenterLabel.
  ///
  /// In en, this message translates to:
  /// **'App Center'**
  String get appCenterLabel;

  /// No description provided for @appstreamSearchGreylist.
  ///
  /// In en, this message translates to:
  /// **'app;application;package;program;programme;suite;tool'**
  String get appstreamSearchGreylist;

  /// No description provided for @snapPageChannelLabel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get snapPageChannelLabel;

  /// No description provided for @snapPageConfinementLabel.
  ///
  /// In en, this message translates to:
  /// **'Confinement'**
  String get snapPageConfinementLabel;

  /// No description provided for @snapPageContactPublisherLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact {publisher}'**
  String snapPageContactPublisherLabel(String publisher);

  /// No description provided for @snapPageDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get snapPageDescriptionLabel;

  /// No description provided for @snapPageDeveloperWebsiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Developer website'**
  String get snapPageDeveloperWebsiteLabel;

  /// No description provided for @snapPageDownloadSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Download size'**
  String get snapPageDownloadSizeLabel;

  /// No description provided for @snapPageSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get snapPageSizeLabel;

  /// No description provided for @snapPageGalleryLabel.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get snapPageGalleryLabel;

  /// No description provided for @snapPageLicenseLabel.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get snapPageLicenseLabel;

  /// No description provided for @snapPageLinksLabel.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get snapPageLinksLabel;

  /// No description provided for @snapPagePublisherLabel.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get snapPagePublisherLabel;

  /// No description provided for @snapPagePublishedLabel.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get snapPagePublishedLabel;

  /// No description provided for @snapPageSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get snapPageSummaryLabel;

  /// No description provided for @snapPageVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get snapPageVersionLabel;

  /// No description provided for @snapPageShareLinkCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get snapPageShareLinkCopiedMessage;

  /// No description provided for @explorePageLabel.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explorePageLabel;

  /// No description provided for @explorePageCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get explorePageCategoriesLabel;

  /// No description provided for @managePageOwnUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'App Center update available'**
  String get managePageOwnUpdateAvailable;

  /// No description provided for @managePageQuitToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Quit to update'**
  String get managePageQuitToUpdate;

  /// No description provided for @managePageOwnUpdateDescription.
  ///
  /// In en, this message translates to:
  /// **'When you quit the application it will automatically update.'**
  String get managePageOwnUpdateDescription;

  /// No description provided for @managePageOwnUpdateDescriptionSoon.
  ///
  /// In en, this message translates to:
  /// **'The app center will automatically update in {time}.'**
  String managePageOwnUpdateDescriptionSoon(String time);

  /// No description provided for @managePageOwnUpdateQuitButton.
  ///
  /// In en, this message translates to:
  /// **'Quit to update'**
  String get managePageOwnUpdateQuitButton;

  /// No description provided for @managePageCheckForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get managePageCheckForUpdates;

  /// No description provided for @managePageCheckingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates'**
  String get managePageCheckingForUpdates;

  /// No description provided for @managePageNoInternet.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach server, check your internet connection or try again later.'**
  String get managePageNoInternet;

  /// No description provided for @managePageDescription.
  ///
  /// In en, this message translates to:
  /// **'Check for available updates, update your apps, and manage the status of all your apps.'**
  String get managePageDescription;

  /// No description provided for @managePageDebUpdatesMessage.
  ///
  /// In en, this message translates to:
  /// **'Debian package updates are handled by the Software Updater.'**
  String get managePageDebUpdatesMessage;

  /// No description provided for @managePageInstalledAndUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Installed and updated'**
  String get managePageInstalledAndUpdatedLabel;

  /// No description provided for @managePageLabel.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get managePageLabel;

  /// No description provided for @managePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage installed snaps'**
  String get managePageTitle;

  /// No description provided for @managePageNoUpdatesAvailableDescription.
  ///
  /// In en, this message translates to:
  /// **'No updates available. Your applications are all up to date.'**
  String get managePageNoUpdatesAvailableDescription;

  /// No description provided for @managePageSearchFieldSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search your installed apps'**
  String get managePageSearchFieldSearchHint;

  /// No description provided for @managePageShowDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get managePageShowDetailsLabel;

  /// No description provided for @managePageShowSystemSnapsLabel.
  ///
  /// In en, this message translates to:
  /// **'Show system snaps'**
  String get managePageShowSystemSnapsLabel;

  /// No description provided for @managePageUpdateAllLabel.
  ///
  /// In en, this message translates to:
  /// **'Update all'**
  String get managePageUpdateAllLabel;

  /// No description provided for @managePageUpdatedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {n, plural, =1{{n} day} other{{n} days}} ago'**
  String managePageUpdatedDaysAgo(int n);

  /// No description provided for @managePageUpdatedWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {n, plural, =1{{n} week} other{{n} weeks}} ago'**
  String managePageUpdatedWeeksAgo(int n);

  /// No description provided for @managePageUpdatedMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {n, plural, =1{{n} month} other{{n} months}} ago'**
  String managePageUpdatedMonthsAgo(int n);

  /// No description provided for @managePageUpdatedYearsAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {n, plural, =1{{n} year} other{{n} years}} ago'**
  String managePageUpdatedYearsAgo(int n);

  /// No description provided for @managePageUpdatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Updates available ({n})'**
  String managePageUpdatesAvailable(int n);

  /// No description provided for @managePageUpdatesFailed.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{One update} other{{n} updates}} failed'**
  String managePageUpdatesFailed(int n);

  /// No description provided for @managePageUpdatesFailedBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t update these applications because they are currently running.\n\n{snapList}\nWhen you quit the applications, they will automatically update.'**
  String managePageUpdatesFailedBody(Object snapList);

  /// No description provided for @productivityPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivityPageLabel;

  /// No description provided for @developmentPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get developmentPageLabel;

  /// No description provided for @gamesPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get gamesPageLabel;

  /// No description provided for @gamesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s Hot'**
  String get gamesPageTitle;

  /// No description provided for @gamesPageTop.
  ///
  /// In en, this message translates to:
  /// **'Top Games'**
  String get gamesPageTop;

  /// No description provided for @gamesPageFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured Titles'**
  String get gamesPageFeatured;

  /// No description provided for @gamesPageBundles.
  ///
  /// In en, this message translates to:
  /// **'App Bundles'**
  String get gamesPageBundles;

  /// No description provided for @unknownPublisher.
  ///
  /// In en, this message translates to:
  /// **'Unknown publisher'**
  String get unknownPublisher;

  /// No description provided for @searchFieldDebSection.
  ///
  /// In en, this message translates to:
  /// **'Debian packages'**
  String get searchFieldDebSection;

  /// No description provided for @searchFieldSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for apps'**
  String get searchFieldSearchHint;

  /// No description provided for @searchFieldSearchForLabel.
  ///
  /// In en, this message translates to:
  /// **'See all results for \"{query}\"'**
  String searchFieldSearchForLabel(String query);

  /// No description provided for @searchFieldSnapSection.
  ///
  /// In en, this message translates to:
  /// **'Snap packages'**
  String get searchFieldSnapSection;

  /// No description provided for @searchPageFilterByLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter by'**
  String get searchPageFilterByLabel;

  /// No description provided for @searchPageNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\"'**
  String searchPageNoResults(String query);

  /// No description provided for @searchPageNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try using different or more general keywords'**
  String get searchPageNoResultsHint;

  /// No description provided for @searchPageNoResultsCategory.
  ///
  /// In en, this message translates to:
  /// **'Sorry, we couldn’t find any packages in this category'**
  String get searchPageNoResultsCategory;

  /// No description provided for @searchPageNoResultsCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Try a different category or use more general keywords'**
  String get searchPageNoResultsCategoryHint;

  /// No description provided for @searchPageSortByLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get searchPageSortByLabel;

  /// No description provided for @searchPageRelevanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get searchPageRelevanceLabel;

  /// No description provided for @searchPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Results for \"{query}\"'**
  String searchPageTitle(String query);

  /// No description provided for @aboutPageLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutPageLabel;

  /// No description provided for @aboutPageVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutPageVersionLabel(String version);

  /// No description provided for @aboutPageContributorTitle.
  ///
  /// In en, this message translates to:
  /// **'Designed and developed by:'**
  String get aboutPageContributorTitle;

  /// No description provided for @aboutPageCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Be part of the community:'**
  String get aboutPageCommunityTitle;

  /// No description provided for @aboutPageContributeLabel.
  ///
  /// In en, this message translates to:
  /// **'Contribute or report bug'**
  String get aboutPageContributeLabel;

  /// No description provided for @aboutPageGitHubLabel.
  ///
  /// In en, this message translates to:
  /// **'Find us on GitHub'**
  String get aboutPageGitHubLabel;

  /// No description provided for @aboutPagePublishLabel.
  ///
  /// In en, this message translates to:
  /// **'Publish to the Snap Store'**
  String get aboutPagePublishLabel;

  /// No description provided for @aboutPageLearnMoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get aboutPageLearnMoreLabel;

  /// No description provided for @appstreamUrlTypeBugtracker.
  ///
  /// In en, this message translates to:
  /// **'Bugtracker'**
  String get appstreamUrlTypeBugtracker;

  /// No description provided for @appstreamUrlTypeContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get appstreamUrlTypeContact;

  /// No description provided for @appstreamUrlTypeContribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get appstreamUrlTypeContribute;

  /// No description provided for @appstreamUrlTypeDonation.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get appstreamUrlTypeDonation;

  /// No description provided for @appstreamUrlTypeFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get appstreamUrlTypeFaq;

  /// No description provided for @appstreamUrlTypeHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get appstreamUrlTypeHelp;

  /// No description provided for @appstreamUrlTypeHomepage.
  ///
  /// In en, this message translates to:
  /// **'Homepage'**
  String get appstreamUrlTypeHomepage;

  /// No description provided for @appstreamUrlTypeTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get appstreamUrlTypeTranslate;

  /// No description provided for @appstreamUrlTypeVcsBrowser.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get appstreamUrlTypeVcsBrowser;

  /// No description provided for @packageFormatDebLabel.
  ///
  /// In en, this message translates to:
  /// **'Debian packages'**
  String get packageFormatDebLabel;

  /// No description provided for @packageFormatSnapLabel.
  ///
  /// In en, this message translates to:
  /// **'Snap packages'**
  String get packageFormatSnapLabel;

  /// No description provided for @snapActionCancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get snapActionCancelLabel;

  /// No description provided for @snapActionInstallLabel.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get snapActionInstallLabel;

  /// No description provided for @snapActionInstalledLabel.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get snapActionInstalledLabel;

  /// No description provided for @snapActionInstallingLabel.
  ///
  /// In en, this message translates to:
  /// **'Installing'**
  String get snapActionInstallingLabel;

  /// No description provided for @snapActionOpenLabel.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get snapActionOpenLabel;

  /// No description provided for @snapActionRemoveLabel.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get snapActionRemoveLabel;

  /// No description provided for @snapActionRemovingLabel.
  ///
  /// In en, this message translates to:
  /// **'Uninstalling'**
  String get snapActionRemovingLabel;

  /// No description provided for @snapActionSwitchChannelLabel.
  ///
  /// In en, this message translates to:
  /// **'Switch channel'**
  String get snapActionSwitchChannelLabel;

  /// No description provided for @snapActionUpdateLabel.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get snapActionUpdateLabel;

  /// No description provided for @snapCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get snapCategoryAll;

  /// No description provided for @snapActionUpdatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get snapActionUpdatingLabel;

  /// No description provided for @snapCategoryArtAndDesign.
  ///
  /// In en, this message translates to:
  /// **'Art and Design'**
  String get snapCategoryArtAndDesign;

  /// No description provided for @snapCategoryBooksAndReference.
  ///
  /// In en, this message translates to:
  /// **'Books and Reference'**
  String get snapCategoryBooksAndReference;

  /// No description provided for @snapCategoryDefaultButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Discover more'**
  String get snapCategoryDefaultButtonLabel;

  /// No description provided for @snapCategoryDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get snapCategoryDevelopment;

  /// No description provided for @snapCategoryDevelopmentSlogan.
  ///
  /// In en, this message translates to:
  /// **'Must-have snaps for developers'**
  String get snapCategoryDevelopmentSlogan;

  /// No description provided for @snapCategoryDevicesAndIot.
  ///
  /// In en, this message translates to:
  /// **'Devices and IoT'**
  String get snapCategoryDevicesAndIot;

  /// No description provided for @snapCategoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get snapCategoryEducation;

  /// No description provided for @snapCategoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get snapCategoryEntertainment;

  /// No description provided for @snapCategoryFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get snapCategoryFeatured;

  /// No description provided for @snapCategoryFeaturedSlogan.
  ///
  /// In en, this message translates to:
  /// **'Featured Snaps'**
  String get snapCategoryFeaturedSlogan;

  /// No description provided for @snapCategoryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get snapCategoryFinance;

  /// No description provided for @snapCategoryGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get snapCategoryGames;

  /// No description provided for @snapCategoryGamesSlogan.
  ///
  /// In en, this message translates to:
  /// **'Everything for your game night'**
  String get snapCategoryGamesSlogan;

  /// No description provided for @snapCategoryGameDev.
  ///
  /// In en, this message translates to:
  /// **'Game Development'**
  String get snapCategoryGameDev;

  /// No description provided for @snapCategoryGameDevSlogan.
  ///
  /// In en, this message translates to:
  /// **'Game Development'**
  String get snapCategoryGameDevSlogan;

  /// No description provided for @snapCategoryGameEmulators.
  ///
  /// In en, this message translates to:
  /// **'Emulators'**
  String get snapCategoryGameEmulators;

  /// No description provided for @snapCategoryGameEmulatorsSlogan.
  ///
  /// In en, this message translates to:
  /// **'Emulators'**
  String get snapCategoryGameEmulatorsSlogan;

  /// No description provided for @snapCategoryGnomeGames.
  ///
  /// In en, this message translates to:
  /// **'GNOME Games'**
  String get snapCategoryGnomeGames;

  /// No description provided for @snapCategoryGnomeGamesSlogan.
  ///
  /// In en, this message translates to:
  /// **'GNOME Games Suite'**
  String get snapCategoryGnomeGamesSlogan;

  /// No description provided for @snapCategoryKdeGames.
  ///
  /// In en, this message translates to:
  /// **'KDE Games'**
  String get snapCategoryKdeGames;

  /// No description provided for @snapCategoryKdeGamesSlogan.
  ///
  /// In en, this message translates to:
  /// **'KDE Games Suite'**
  String get snapCategoryKdeGamesSlogan;

  /// No description provided for @snapCategoryGameLaunchers.
  ///
  /// In en, this message translates to:
  /// **'Game Launchers'**
  String get snapCategoryGameLaunchers;

  /// No description provided for @snapCategoryGameLaunchersSlogan.
  ///
  /// In en, this message translates to:
  /// **'Game Launchers'**
  String get snapCategoryGameLaunchersSlogan;

  /// No description provided for @snapCategoryGameContentCreation.
  ///
  /// In en, this message translates to:
  /// **'Content Creation'**
  String get snapCategoryGameContentCreation;

  /// No description provided for @snapCategoryGameContentCreationSlogan.
  ///
  /// In en, this message translates to:
  /// **'Content Creation'**
  String get snapCategoryGameContentCreationSlogan;

  /// No description provided for @snapCategoryHealthAndFitness.
  ///
  /// In en, this message translates to:
  /// **'Health and Fitness'**
  String get snapCategoryHealthAndFitness;

  /// No description provided for @snapCategoryMusicAndAudio.
  ///
  /// In en, this message translates to:
  /// **'Music and Audio'**
  String get snapCategoryMusicAndAudio;

  /// No description provided for @snapCategoryNewsAndWeather.
  ///
  /// In en, this message translates to:
  /// **'News and Weather'**
  String get snapCategoryNewsAndWeather;

  /// No description provided for @snapCategoryPersonalisation.
  ///
  /// In en, this message translates to:
  /// **'Personalisation'**
  String get snapCategoryPersonalisation;

  /// No description provided for @snapCategoryPhotoAndVideo.
  ///
  /// In en, this message translates to:
  /// **'Photo and Video'**
  String get snapCategoryPhotoAndVideo;

  /// No description provided for @snapCategoryProductivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get snapCategoryProductivity;

  /// No description provided for @snapCategoryProductivityButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Discover the productivity collection'**
  String get snapCategoryProductivityButtonLabel;

  /// No description provided for @snapCategoryProductivitySlogan.
  ///
  /// In en, this message translates to:
  /// **'Cross one thing off your to-do list'**
  String get snapCategoryProductivitySlogan;

  /// No description provided for @snapCategoryScience.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get snapCategoryScience;

  /// No description provided for @snapCategorySecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get snapCategorySecurity;

  /// No description provided for @snapCategoryServerAndCloud.
  ///
  /// In en, this message translates to:
  /// **'Server and Cloud'**
  String get snapCategoryServerAndCloud;

  /// No description provided for @snapCategorySocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get snapCategorySocial;

  /// No description provided for @snapCategoryUbuntuDesktop.
  ///
  /// In en, this message translates to:
  /// **'Ubuntu Desktop'**
  String get snapCategoryUbuntuDesktop;

  /// No description provided for @snapCategoryUbuntuDesktopSlogan.
  ///
  /// In en, this message translates to:
  /// **'Jump start your desktop'**
  String get snapCategoryUbuntuDesktopSlogan;

  /// No description provided for @snapCategoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get snapCategoryUtilities;

  /// No description provided for @snapConfinementClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get snapConfinementClassic;

  /// No description provided for @snapConfinementDevmode.
  ///
  /// In en, this message translates to:
  /// **'Devmode'**
  String get snapConfinementDevmode;

  /// No description provided for @snapConfinementStrict.
  ///
  /// In en, this message translates to:
  /// **'Strict'**
  String get snapConfinementStrict;

  /// No description provided for @snapSortOrderAlphabeticalAsc.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical (A to Z)'**
  String get snapSortOrderAlphabeticalAsc;

  /// No description provided for @snapSortOrderAlphabeticalDesc.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical (Z to A)'**
  String get snapSortOrderAlphabeticalDesc;

  /// No description provided for @snapSortOrderDownloadSizeAsc.
  ///
  /// In en, this message translates to:
  /// **'Size (Smallest to largest)'**
  String get snapSortOrderDownloadSizeAsc;

  /// No description provided for @snapSortOrderDownloadSizeDesc.
  ///
  /// In en, this message translates to:
  /// **'Size (Largest to smallest)'**
  String get snapSortOrderDownloadSizeDesc;

  /// No description provided for @snapSortOrderInstalledSizeAsc.
  ///
  /// In en, this message translates to:
  /// **'Size (Smallest to largest)'**
  String get snapSortOrderInstalledSizeAsc;

  /// No description provided for @snapSortOrderInstalledSizeDesc.
  ///
  /// In en, this message translates to:
  /// **'Size (Largest to smallest)'**
  String get snapSortOrderInstalledSizeDesc;

  /// No description provided for @snapSortOrderInstalledDateAsc.
  ///
  /// In en, this message translates to:
  /// **'Least recently updated'**
  String get snapSortOrderInstalledDateAsc;

  /// No description provided for @snapSortOrderInstalledDateDesc.
  ///
  /// In en, this message translates to:
  /// **'Most recently updated'**
  String get snapSortOrderInstalledDateDesc;

  /// No description provided for @snapSortOrderRelevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get snapSortOrderRelevance;

  /// No description provided for @snapRatingsBandVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very good'**
  String get snapRatingsBandVeryGood;

  /// No description provided for @snapRatingsBandGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get snapRatingsBandGood;

  /// No description provided for @snapRatingsBandNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get snapRatingsBandNeutral;

  /// No description provided for @snapRatingsBandPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get snapRatingsBandPoor;

  /// No description provided for @snapRatingsBandVeryPoor.
  ///
  /// In en, this message translates to:
  /// **'Very poor'**
  String get snapRatingsBandVeryPoor;

  /// No description provided for @snapRatingsBandInsufficientVotes.
  ///
  /// In en, this message translates to:
  /// **'Insufficient votes'**
  String get snapRatingsBandInsufficientVotes;

  /// No description provided for @snapRatingsVotes.
  ///
  /// In en, this message translates to:
  /// **'{n} votes'**
  String snapRatingsVotes(int n);

  /// No description provided for @snapReportLabel.
  ///
  /// In en, this message translates to:
  /// **'Report {snapName}'**
  String snapReportLabel(String snapName);

  /// No description provided for @snapReportSelectReportReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose a reason for reporting this snap'**
  String get snapReportSelectReportReasonLabel;

  /// No description provided for @snapReportSelectAnOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get snapReportSelectAnOptionLabel;

  /// No description provided for @snapReportOptionCopyrightViolation.
  ///
  /// In en, this message translates to:
  /// **'Copyright or trademark violation'**
  String get snapReportOptionCopyrightViolation;

  /// No description provided for @snapReportOptionStoreViolation.
  ///
  /// In en, this message translates to:
  /// **'Snap Store terms of service violation'**
  String get snapReportOptionStoreViolation;

  /// No description provided for @snapReportDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Please provide more detailed reason to your report'**
  String get snapReportDetailsLabel;

  /// No description provided for @snapReportOptionalEmailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Your email (optional)'**
  String get snapReportOptionalEmailAddressLabel;

  /// No description provided for @snapReportCancelButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get snapReportCancelButtonLabel;

  /// No description provided for @snapReportSubmitButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get snapReportSubmitButtonLabel;

  /// No description provided for @snapReportEnterValidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get snapReportEnterValidEmailError;

  /// No description provided for @snapReportDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Comment...'**
  String get snapReportDetailsHint;

  /// No description provided for @snapReportPrivacyAgreementLabel.
  ///
  /// In en, this message translates to:
  /// **'In submitting this form, I confirm that I have read and agree to '**
  String get snapReportPrivacyAgreementLabel;

  /// No description provided for @snapReportPrivacyAgreementCanonicalPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'Canonical’s Privacy Notice '**
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice;

  /// No description provided for @snapReportPrivacyAgreementAndLabel.
  ///
  /// In en, this message translates to:
  /// **'and '**
  String get snapReportPrivacyAgreementAndLabel;

  /// No description provided for @snapReportPrivacyAgreementPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get snapReportPrivacyAgreementPrivacyPolicy;

  /// No description provided for @debPageErrorNoPackageInfo.
  ///
  /// In en, this message translates to:
  /// **'No package information found'**
  String get debPageErrorNoPackageInfo;

  /// No description provided for @externalResources.
  ///
  /// In en, this message translates to:
  /// **'Additional resources'**
  String get externalResources;

  /// No description provided for @externalResourcesButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Discover more'**
  String get externalResourcesButtonLabel;

  /// No description provided for @allGamesButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'All games'**
  String get allGamesButtonLabel;

  /// No description provided for @externalResourcesDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Note: These are all external tools. These aren\'t owned nor distributed by Canonical.'**
  String get externalResourcesDisclaimer;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get openInBrowser;

  /// No description provided for @installAll.
  ///
  /// In en, this message translates to:
  /// **'Install all'**
  String get installAll;

  /// No description provided for @localDebWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Potentially unsafe'**
  String get localDebWarningTitle;

  /// No description provided for @localDebWarningBody.
  ///
  /// In en, this message translates to:
  /// **'This package is provided by a third party. Installing packages from outside the App Center can increase the risk to your system and personal data. Ensure you trust the source before proceeding.'**
  String get localDebWarningBody;

  /// No description provided for @localDebLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more about third party packages'**
  String get localDebLearnMore;

  /// No description provided for @localDebDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This package is provided by a third party and may threaten your system and personal data.'**
  String get localDebDialogMessage;

  /// No description provided for @localDebDialogConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to install it?'**
  String get localDebDialogConfirmation;

  /// No description provided for @snapdExceptionRunningApps.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t update {snapName} because it is currently running.'**
  String snapdExceptionRunningApps(String snapName);

  /// No description provided for @errorViewCheckStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get errorViewCheckStatusLabel;

  /// No description provided for @errorViewNetworkErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to internet'**
  String get errorViewNetworkErrorTitle;

  /// No description provided for @errorViewNetworkErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'We can\'t load content in the App Center without an internet connection.'**
  String get errorViewNetworkErrorDescription;

  /// No description provided for @errorViewNetworkErrorAction.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and retry.'**
  String get errorViewNetworkErrorAction;

  /// No description provided for @errorViewServerErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'re sorry, we are currently experiencing problems with the App Center.'**
  String get errorViewServerErrorDescription;

  /// No description provided for @errorViewServerErrorAction.
  ///
  /// In en, this message translates to:
  /// **'Check the status for updates or try again later.'**
  String get errorViewServerErrorAction;

  /// No description provided for @errorViewUnknownErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorViewUnknownErrorTitle;

  /// No description provided for @errorViewUnknownErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'re sorry, but we’re not sure what the error is.'**
  String get errorViewUnknownErrorDescription;

  /// No description provided for @errorViewUnknownErrorAction.
  ///
  /// In en, this message translates to:
  /// **'You can retry now, check the status for updates, or try again later.'**
  String get errorViewUnknownErrorAction;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['be', 'cs', 'da', 'de', 'en', 'eo', 'es', 'fa', 'fi', 'fr', 'hu', 'id', 'it', 'ja', 'ko', 'nn', 'oc', 'pl', 'pt', 'ru', 'sk', 'sv', 'tr', 'uk', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh': {
  switch (locale.scriptCode) {
    case 'Hant': return AppLocalizationsZhHant();
   }
  break;
   }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en': {
  switch (locale.countryCode) {
    case 'GB': return AppLocalizationsEnGb();
   }
  break;
   }
    case 'pt': {
  switch (locale.countryCode) {
    case 'BR': return AppLocalizationsPtBr();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'be': return AppLocalizationsBe();
    case 'cs': return AppLocalizationsCs();
    case 'da': return AppLocalizationsDa();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'eo': return AppLocalizationsEo();
    case 'es': return AppLocalizationsEs();
    case 'fa': return AppLocalizationsFa();
    case 'fi': return AppLocalizationsFi();
    case 'fr': return AppLocalizationsFr();
    case 'hu': return AppLocalizationsHu();
    case 'id': return AppLocalizationsId();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'nn': return AppLocalizationsNn();
    case 'oc': return AppLocalizationsOc();
    case 'pl': return AppLocalizationsPl();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'sk': return AppLocalizationsSk();
    case 'sv': return AppLocalizationsSv();
    case 'tr': return AppLocalizationsTr();
    case 'uk': return AppLocalizationsUk();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
