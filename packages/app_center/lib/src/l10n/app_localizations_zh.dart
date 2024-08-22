import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appCenterLabel => '应用中心';

  @override
  String get appstreamSearchGreylist => '应用程序;程序包;程序;套件;工具';

  @override
  String get snapPageChannelLabel => '频道';

  @override
  String get snapPageConfinementLabel => '限制';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return '联系 $publisher';
  }

  @override
  String get snapPageDescriptionLabel => '描述';

  @override
  String get snapPageDeveloperWebsiteLabel => '开发者网站';

  @override
  String get snapPageDownloadSizeLabel => '下载大小';

  @override
  String get snapPageSizeLabel => 'Size';

  @override
  String get snapPageGalleryLabel => '图集';

  @override
  String get snapPageLicenseLabel => '许可证';

  @override
  String get snapPageLinksLabel => '链接';

  @override
  String get snapPagePublisherLabel => '发布者';

  @override
  String get snapPagePublishedLabel => '发布于';

  @override
  String get snapPageSummaryLabel => '摘要';

  @override
  String get snapPageVersionLabel => '版本';

  @override
  String get snapPageShareLinkCopiedMessage => '链接已复制到剪贴板';

  @override
  String get explorePageLabel => '探索';

  @override
  String get explorePageCategoriesLabel => '分类';

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
  String get managePageCheckForUpdates => '检查更新';

  @override
  String get managePageCheckingForUpdates => '正在检查更新';

  @override
  String get managePageNoInternet => 'Can\'t reach server, check your internet connection or try again later.';

  @override
  String get managePageDescription => '检查可用更新，更新应用，并管理所有应用的状态。';

  @override
  String get managePageDebUpdatesMessage => 'Debian package updates are handled by the Software Updater.';

  @override
  String get managePageInstalledAndUpdatedLabel => '已安装和已更新';

  @override
  String get managePageLabel => '管理';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => '无可用更新。您的应用均为最新。';

  @override
  String get managePageSearchFieldSearchHint => '搜索已安装的应用';

  @override
  String get managePageShowDetailsLabel => '显示详情';

  @override
  String get managePageShowSystemSnapsLabel => '显示系统 Snap 程序包';

  @override
  String get managePageUpdateAllLabel => '全部更新';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 天',
      one: '$n 天',
    );
    return '$_temp0 前更新';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 周',
      one: '$n 周',
    );
    return '$_temp0前更新';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 个月',
      one: '$n 个月',
    );
    return '$_temp0前更新';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 年',
      one: '$n 年',
    );
    return '$_temp0前更新';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return '更新可用 ($n)';
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
  String get productivityPageLabel => '生产力';

  @override
  String get developmentPageLabel => '开发';

  @override
  String get gamesPageLabel => '游戏';

  @override
  String get gamesPageTitle => '热门';

  @override
  String get gamesPageTop => '热门游戏';

  @override
  String get gamesPageFeatured => '特色游戏';

  @override
  String get gamesPageBundles => '程序包';

  @override
  String get unknownPublisher => '未知发布者';

  @override
  String get searchFieldDebSection => 'Debian 包';

  @override
  String get searchFieldSearchHint => '搜索应用';

  @override
  String searchFieldSearchForLabel(String query) {
    return '显示“$query”的所有结果';
  }

  @override
  String get searchFieldSnapSection => 'Snap 包';

  @override
  String get searchPageFilterByLabel => '筛选条件';

  @override
  String searchPageNoResults(String query) {
    return '未找到匹配“$query”的结果';
  }

  @override
  String get searchPageNoResultsHint => '试试用不同的或更常见的关键词';

  @override
  String get searchPageNoResultsCategory => '抱歉，我们在此类别中找不到软件包';

  @override
  String get searchPageNoResultsCategoryHint => '试试不同类别，或者用更常见的关键词';

  @override
  String get searchPageSortByLabel => '排序方式';

  @override
  String get searchPageRelevanceLabel => '相关性';

  @override
  String searchPageTitle(String query) {
    return '“$query”的结果';
  }

  @override
  String get aboutPageLabel => '关于';

  @override
  String aboutPageVersionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get aboutPageContributorTitle => '设计与开发人员：';

  @override
  String get aboutPageCommunityTitle => '成为社区的一部分：';

  @override
  String get aboutPageContributeLabel => '作出贡献或报告问题';

  @override
  String get aboutPageGitHubLabel => '在 GitHub 上找到我们';

  @override
  String get aboutPagePublishLabel => '发布到 Snap 商店';

  @override
  String get aboutPageLearnMoreLabel => '了解更多';

  @override
  String get appstreamUrlTypeBugtracker => '问题跟踪器';

  @override
  String get appstreamUrlTypeContact => '联系';

  @override
  String get appstreamUrlTypeContribute => 'Contribute';

  @override
  String get appstreamUrlTypeDonation => '捐赠';

  @override
  String get appstreamUrlTypeFaq => '常见问题';

  @override
  String get appstreamUrlTypeHelp => '帮助';

  @override
  String get appstreamUrlTypeHomepage => '主页';

  @override
  String get appstreamUrlTypeTranslate => '翻译';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Source';

  @override
  String get packageFormatDebLabel => 'Debian 包';

  @override
  String get packageFormatSnapLabel => 'Snap 包';

  @override
  String get snapActionCancelLabel => '取消';

  @override
  String get snapActionInstallLabel => '安装';

  @override
  String get snapActionInstalledLabel => 'Installed';

  @override
  String get snapActionInstallingLabel => '安装中';

  @override
  String get snapActionOpenLabel => '打开';

  @override
  String get snapActionRemoveLabel => '卸载';

  @override
  String get snapActionRemovingLabel => '卸载中';

  @override
  String get snapActionSwitchChannelLabel => '切换频道';

  @override
  String get snapActionUpdateLabel => '更新';

  @override
  String get snapCategoryAll => '所有类别';

  @override
  String get snapActionUpdatingLabel => '更新中';

  @override
  String get snapCategoryArtAndDesign => '艺术与设计';

  @override
  String get snapCategoryBooksAndReference => '书籍和参考资料';

  @override
  String get snapCategoryDefaultButtonLabel => '发现更多';

  @override
  String get snapCategoryDevelopment => '开发';

  @override
  String get snapCategoryDevelopmentSlogan => '开发者必备应用';

  @override
  String get snapCategoryDevicesAndIot => '设备与物联网';

  @override
  String get snapCategoryEducation => '教育';

  @override
  String get snapCategoryEntertainment => '娱乐';

  @override
  String get snapCategoryFeatured => '特色';

  @override
  String get snapCategoryFeaturedSlogan => '特色 Snap 包';

  @override
  String get snapCategoryFinance => '金融';

  @override
  String get snapCategoryGames => '游戏';

  @override
  String get snapCategoryGamesSlogan => '玩你所爱';

  @override
  String get snapCategoryGameDev => '游戏开发';

  @override
  String get snapCategoryGameDevSlogan => '游戏开发';

  @override
  String get snapCategoryGameEmulators => '模拟器';

  @override
  String get snapCategoryGameEmulatorsSlogan => '模拟器';

  @override
  String get snapCategoryGnomeGames => 'GNOME 游戏';

  @override
  String get snapCategoryGnomeGamesSlogan => 'GNOME 游戏套件';

  @override
  String get snapCategoryKdeGames => 'KDE 游戏';

  @override
  String get snapCategoryKdeGamesSlogan => 'KDE 游戏套件';

  @override
  String get snapCategoryGameLaunchers => '游戏启动器';

  @override
  String get snapCategoryGameLaunchersSlogan => '游戏启动器';

  @override
  String get snapCategoryGameContentCreation => '内容创作';

  @override
  String get snapCategoryGameContentCreationSlogan => '内容创作';

  @override
  String get snapCategoryHealthAndFitness => '健康与健身';

  @override
  String get snapCategoryMusicAndAudio => '音乐与音频';

  @override
  String get snapCategoryNewsAndWeather => '新闻和天气';

  @override
  String get snapCategoryPersonalisation => '个性化';

  @override
  String get snapCategoryPhotoAndVideo => '照片和视频';

  @override
  String get snapCategoryProductivity => '生产力';

  @override
  String get snapCategoryProductivityButtonLabel => '探索生产力集合';

  @override
  String get snapCategoryProductivitySlogan => '从待办列表中划去一项';

  @override
  String get snapCategoryScience => '科学';

  @override
  String get snapCategorySecurity => '安全';

  @override
  String get snapCategoryServerAndCloud => '服务器和云';

  @override
  String get snapCategorySocial => '社交';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu 桌面';

  @override
  String get snapCategoryUbuntuDesktopSlogan => '快速启动您的桌面';

  @override
  String get snapCategoryUtilities => '工具';

  @override
  String get snapConfinementClassic => '经典';

  @override
  String get snapConfinementDevmode => '开发模式';

  @override
  String get snapConfinementStrict => '严格';

  @override
  String get snapSortOrderAlphabeticalAsc => '首字母（A 到 Z）';

  @override
  String get snapSortOrderAlphabeticalDesc => '首字母（Z 到 A）';

  @override
  String get snapSortOrderDownloadSizeAsc => '下载大小（从小到大）';

  @override
  String get snapSortOrderDownloadSizeDesc => '下载大小（从大到小）';

  @override
  String get snapSortOrderInstalledSizeAsc => '安装大小（从小到大）';

  @override
  String get snapSortOrderInstalledSizeDesc => '安装大小（从大到小）';

  @override
  String get snapSortOrderInstalledDateAsc => '最早更新';

  @override
  String get snapSortOrderInstalledDateDesc => '最近更新';

  @override
  String get snapSortOrderRelevance => '相关性';

  @override
  String get snapRatingsBandVeryGood => '非常好';

  @override
  String get snapRatingsBandGood => '好';

  @override
  String get snapRatingsBandNeutral => '中性';

  @override
  String get snapRatingsBandPoor => '差';

  @override
  String get snapRatingsBandVeryPoor => '非常差';

  @override
  String get snapRatingsBandInsufficientVotes => '投票不足';

  @override
  String snapRatingsVotes(int n) {
    return '$n 次投票';
  }

  @override
  String snapReportLabel(String snapName) {
    return '举报 $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => '选择举报原因';

  @override
  String get snapReportSelectAnOptionLabel => '选择一项';

  @override
  String get snapReportOptionCopyrightViolation => '版权或商标侵权';

  @override
  String get snapReportOptionStoreViolation => '违反 Snap 商店服务条款';

  @override
  String get snapReportDetailsLabel => '请在举报中提供更多详细理由';

  @override
  String get snapReportOptionalEmailAddressLabel => '您的电子邮件地址（可选）';

  @override
  String get snapReportCancelButtonLabel => '取消';

  @override
  String get snapReportSubmitButtonLabel => '提交举报';

  @override
  String get snapReportEnterValidEmailError => '输入有效的电子邮件地址';

  @override
  String get snapReportDetailsHint => '评论…';

  @override
  String get snapReportPrivacyAgreementLabel => '在提交此表单时，我确定已阅读并同意 ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Canonical 的隐私声明 ';

  @override
  String get snapReportPrivacyAgreementAndLabel => '与 ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => '隐私政策';

  @override
  String get debPageErrorNoPackageInfo => '未找到软件包信息';

  @override
  String get externalResources => '附加资源';

  @override
  String get externalResourcesButtonLabel => '发现更多';

  @override
  String get allGamesButtonLabel => '所有游戏';

  @override
  String get externalResourcesDisclaimer => '注意：这些应用都是不由 Canonical 所有或发布的外部工具。';

  @override
  String get openInBrowser => '在浏览器中打开';

  @override
  String get installAll => '全部安装';

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

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant(): super('zh_Hant');

  @override
  String get appCenterLabel => '應用軟體中心';

  @override
  String get appstreamSearchGreylist => '應用;應用軟體;軟體包;套件;程式;程序;套裝軟體;工具';

  @override
  String get snapPageChannelLabel => '釋出頻道';

  @override
  String get snapPageConfinementLabel => '權限限縮';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return '聯絡 $publisher';
  }

  @override
  String get snapPageDescriptionLabel => '描述';

  @override
  String get snapPageDeveloperWebsiteLabel => '開發者網站';

  @override
  String get snapPageDownloadSizeLabel => '下載大小';

  @override
  String get snapPageSizeLabel => '大小';

  @override
  String get snapPageGalleryLabel => '軟體圖像一覽';

  @override
  String get snapPageLicenseLabel => '授權條款';

  @override
  String get snapPageLinksLabel => '連結';

  @override
  String get snapPagePublisherLabel => '發布者';

  @override
  String get snapPagePublishedLabel => '發布日期';

  @override
  String get snapPageSummaryLabel => '總結';

  @override
  String get snapPageVersionLabel => '版本';

  @override
  String get snapPageShareLinkCopiedMessage => '連結已複製到剪貼簿';

  @override
  String get explorePageLabel => '探索';

  @override
  String get explorePageCategoriesLabel => '類別';

  @override
  String get managePageQuitToUpdate => '結束以更新';

  @override
  String get managePageOwnUpdateDescription => '當您結束應用程式時，它將自動更新。';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return '應用程式中心將在 $time 後自動更新。';
  }

  @override
  String get managePageOwnUpdateQuitButton => '結束以更新';

  @override
  String get managePageCheckForUpdates => '檢查更新';

  @override
  String get managePageCheckingForUpdates => '正在檢查更新';

  @override
  String get managePageNoInternet => '無法連線到伺服器，請檢查您的網路連線或稍後再試。';

  @override
  String get managePageDescription => '檢查可用的更新，更新您的應用程式，並管理所有應用程式的狀態。';

  @override
  String get managePageDebUpdatesMessage => 'Debian 套件更新由軟體更新程式處理。';

  @override
  String get managePageInstalledAndUpdatedLabel => '已安裝並更新';

  @override
  String get managePageLabel => '管理已安裝的 Snap 套件';

  @override
  String get managePageNoUpdatesAvailableDescription => '沒有可用的更新。您的所有應用程式都是最新的。';

  @override
  String get managePageSearchFieldSearchHint => '搜尋已安裝的應用程式';

  @override
  String get managePageShowDetailsLabel => '顯示詳細資訊';

  @override
  String get managePageShowSystemSnapsLabel => '顯示系統快照';

  @override
  String get managePageUpdateAllLabel => '全部更新';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 天前更新',
      one: '$n 天前更新',
    );
    return '$_temp0';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 週前更新',
      one: '$n 週前更新',
    );
    return '$_temp0';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 個月前更新',
      one: '$n 個月前更新',
    );
    return '$_temp0';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 年前更新',
      one: '$n 年前更新',
    );
    return '$_temp0';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return '有更新可用 ($n)';
  }

  @override
  String get productivityPageLabel => '生產力工具';

  @override
  String get developmentPageLabel => '軟體開發';

  @override
  String get gamesPageLabel => '遊戲';

  @override
  String get gamesPageTitle => '熱門遊戲';

  @override
  String get gamesPageTop => '最佳遊戲';

  @override
  String get gamesPageFeatured => '精選遊戲';

  @override
  String get gamesPageBundles => '應用程式套裝';

  @override
  String get unknownPublisher => '未知的發布者';

  @override
  String get searchFieldDebSection => 'Debian 軟體包';

  @override
  String get searchFieldSearchHint => '尋找應用程式';

  @override
  String searchFieldSearchForLabel(String query) {
    return '檢視所有 \"$query\" 的結果';
  }

  @override
  String get searchFieldSnapSection => 'Snap 軟體包';

  @override
  String get searchPageFilterByLabel => '篩選條件';

  @override
  String searchPageNoResults(String query) {
    return '找不到與 \"$query\" 關聯的結果';
  }

  @override
  String get searchPageNoResultsHint => '嘗試使用不同或更通用的關鍵字';

  @override
  String get searchPageNoResultsCategory => '抱歉，我們在這個類別中找不到任何套件';

  @override
  String get searchPageNoResultsCategoryHint => '嘗試不同的類別或使用更通用的關鍵字';

  @override
  String get searchPageSortByLabel => '排序';

  @override
  String get searchPageRelevanceLabel => '關聯性';

  @override
  String searchPageTitle(String query) {
    return '與 \"$query\" 相關的結果';
  }

  @override
  String get aboutPageLabel => '關於';

  @override
  String aboutPageVersionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get aboutPageContributorTitle => '設計與開發者：';

  @override
  String get aboutPageCommunityTitle => '加入社群：';

  @override
  String get aboutPageContributeLabel => '貢獻或回報錯誤';

  @override
  String get aboutPageGitHubLabel => '在 GitHub 上找到我們';

  @override
  String get aboutPagePublishLabel => '發布到 Snap 商店';

  @override
  String get aboutPageLearnMoreLabel => '了解更多';

  @override
  String get appstreamUrlTypeBugtracker => '錯誤追蹤';

  @override
  String get appstreamUrlTypeContact => '聯繫';

  @override
  String get appstreamUrlTypeContribute => '貢獻';

  @override
  String get appstreamUrlTypeDonation => '捐款';

  @override
  String get appstreamUrlTypeFaq => '常見問題';

  @override
  String get appstreamUrlTypeHelp => '幫助';

  @override
  String get appstreamUrlTypeHomepage => '首頁';

  @override
  String get appstreamUrlTypeTranslate => '翻譯';

  @override
  String get appstreamUrlTypeVcsBrowser => '來源';

  @override
  String get packageFormatDebLabel => 'Debian 軟體包';

  @override
  String get packageFormatSnapLabel => 'Snap 軟體包';

  @override
  String get snapActionCancelLabel => '取消';

  @override
  String get snapActionInstallLabel => '安裝';

  @override
  String get snapActionInstalledLabel => '已安裝';

  @override
  String get snapActionInstallingLabel => '安裝中';

  @override
  String get snapActionOpenLabel => '開啟';

  @override
  String get snapActionRemoveLabel => '解除安裝';

  @override
  String get snapActionRemovingLabel => '正在解除安裝';

  @override
  String get snapActionSwitchChannelLabel => '切換頻道';

  @override
  String get snapActionUpdateLabel => '更新';

  @override
  String get snapCategoryAll => '所有類別';

  @override
  String get snapActionUpdatingLabel => '正在更新';

  @override
  String get snapCategoryArtAndDesign => '藝術與設計';

  @override
  String get snapCategoryBooksAndReference => '書籍與參考文獻';

  @override
  String get snapCategoryDefaultButtonLabel => '探索更多';

  @override
  String get snapCategoryDevelopment => '軟體開發';

  @override
  String get snapCategoryDevelopmentSlogan => '開發者必備的 snaps';

  @override
  String get snapCategoryDevicesAndIot => '設備與 IoT 裝置';

  @override
  String get snapCategoryEducation => '教育';

  @override
  String get snapCategoryEntertainment => '娛樂';

  @override
  String get snapCategoryFeatured => '精選';

  @override
  String get snapCategoryFeaturedSlogan => '精選 Snaps';

  @override
  String get snapCategoryFinance => '理財';

  @override
  String get snapCategoryGames => '遊戲';

  @override
  String get snapCategoryGamesSlogan => '您的遊戲之夜所需的一切';

  @override
  String get snapCategoryGameDev => '遊戲開發';

  @override
  String get snapCategoryGameDevSlogan => '遊戲開發';

  @override
  String get snapCategoryGameEmulators => '模擬器';

  @override
  String get snapCategoryGameEmulatorsSlogan => '模擬器';

  @override
  String get snapCategoryGnomeGames => 'GNOME 遊戲';

  @override
  String get snapCategoryGnomeGamesSlogan => 'GNOME 遊戲套裝';

  @override
  String get snapCategoryKdeGames => 'KDE 遊戲';

  @override
  String get snapCategoryKdeGamesSlogan => 'KDE 遊戲套裝';

  @override
  String get snapCategoryGameLaunchers => '遊戲啟動器';

  @override
  String get snapCategoryGameLaunchersSlogan => '遊戲啟動器';

  @override
  String get snapCategoryGameContentCreation => '內容創作';

  @override
  String get snapCategoryGameContentCreationSlogan => '內容創作';

  @override
  String get snapCategoryHealthAndFitness => '健康與健身';

  @override
  String get snapCategoryMusicAndAudio => '音樂與音訊';

  @override
  String get snapCategoryNewsAndWeather => '新聞與天氣';

  @override
  String get snapCategoryPersonalisation => '個人化';

  @override
  String get snapCategoryPhotoAndVideo => '相片與影片';

  @override
  String get snapCategoryProductivity => '生產力工具';

  @override
  String get snapCategoryProductivityButtonLabel => '探索生產力工具集';

  @override
  String get snapCategoryProductivitySlogan => '完成您待辦事項中的一項';

  @override
  String get snapCategoryScience => '科學';

  @override
  String get snapCategorySecurity => '安全';

  @override
  String get snapCategoryServerAndCloud => '伺服器與雲端';

  @override
  String get snapCategorySocial => '社交';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu 桌面';

  @override
  String get snapCategoryUbuntuDesktopSlogan => '快速啟動您的桌面';

  @override
  String get snapCategoryUtilities => '實用工具';

  @override
  String get snapConfinementClassic => '經典';

  @override
  String get snapConfinementDevmode => '開發者模式';

  @override
  String get snapConfinementStrict => '嚴格';

  @override
  String get snapSortOrderAlphabeticalAsc => '字母順序 (A 到 Z)';

  @override
  String get snapSortOrderAlphabeticalDesc => '字母順序 (Z 到 A)';

  @override
  String get snapSortOrderDownloadSizeAsc => '大小 (從小到大)';

  @override
  String get snapSortOrderDownloadSizeDesc => '大小 (從大到小)';

  @override
  String get snapSortOrderInstalledSizeAsc => '大小 (從小到大)';

  @override
  String get snapSortOrderInstalledSizeDesc => '大小 (從大到小)';

  @override
  String get snapSortOrderInstalledDateAsc => '最近最少更新';

  @override
  String get snapSortOrderInstalledDateDesc => '最近最常更新';

  @override
  String get snapSortOrderRelevance => '關聯性';

  @override
  String get snapRatingsBandVeryGood => '非常好';

  @override
  String get snapRatingsBandGood => '好';

  @override
  String get snapRatingsBandNeutral => '中立';

  @override
  String get snapRatingsBandPoor => '差';

  @override
  String get snapRatingsBandVeryPoor => '非常差';

  @override
  String get snapRatingsBandInsufficientVotes => '票數不足';

  @override
  String snapRatingsVotes(int n) {
    return '$n 票';
  }

  @override
  String snapReportLabel(String snapName) {
    return '回報 $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => '選擇回報此 snap 的原因';

  @override
  String get snapReportSelectAnOptionLabel => '選擇一個選項';

  @override
  String get snapReportOptionCopyrightViolation => '侵犯版權或商標';

  @override
  String get snapReportOptionStoreViolation => '違反 Snap 商店服務條款';

  @override
  String get snapReportDetailsLabel => '請提供更詳細的回報原因';

  @override
  String get snapReportOptionalEmailAddressLabel => '您的電子郵件 (選填)';

  @override
  String get snapReportCancelButtonLabel => '取消';

  @override
  String get snapReportSubmitButtonLabel => '提交回報';

  @override
  String get snapReportEnterValidEmailError => '輸入有效的電子郵件地址';

  @override
  String get snapReportDetailsHint => '評論...';

  @override
  String get snapReportPrivacyAgreementLabel => '在提交此表單時，我確認我已閱讀並同意 ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Canonical 的隱私權聲明 ';

  @override
  String get snapReportPrivacyAgreementAndLabel => '和 ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => '隱私權政策';

  @override
  String get debPageErrorNoPackageInfo => '找不到套件資訊';

  @override
  String get externalResources => '額外資源';

  @override
  String get externalResourcesButtonLabel => '探索更多';

  @override
  String get allGamesButtonLabel => '所有遊戲';

  @override
  String get externalResourcesDisclaimer => '注意：這些都是外部工具。它們並非由 Canonical 擁有或提供。';

  @override
  String get openInBrowser => '在瀏覽器中開啟';

  @override
  String get installAll => '全部安裝';

  @override
  String get localDebWarningTitle => '可能不安全';

  @override
  String get localDebWarningBody => '此套件由第三方提供。從應用中心外安裝套件可能會增加系統和個人資料的風險。請在繼續操作前確認您信任此來源。';

  @override
  String get localDebLearnMore => '了解有關此第三方套件的更多資訊';

  @override
  String get localDebDialogMessage => '此套件由第三方提供，可能會危害您的系統及個人資料。';

  @override
  String get localDebDialogConfirmation => '您確定要安裝它嗎？';

  @override
  String snapdExceptionRunningApps(String snapName) {
    return '我們無法更新 $snapName，因為它目前正在使用中。';
  }

  @override
  String get errorViewCheckStatusLabel => '檢查狀態';

  @override
  String get errorViewNetworkErrorTitle => '連接到網路';

  @override
  String get errorViewNetworkErrorDescription => '我們無法在沒有網路連線的情況下載入應用程式中心的內容。';

  @override
  String get errorViewNetworkErrorAction => '請檢查您的網路連線後重試。';

  @override
  String get errorViewServerErrorDescription => '抱歉，我們在使用應用程式中心時遇到問題。';

  @override
  String get errorViewServerErrorAction => '檢查更新狀態或稍後再試。';

  @override
  String get errorViewUnknownErrorTitle => '發生錯誤';

  @override
  String get errorViewUnknownErrorDescription => '很抱歉，我們不確定錯誤的原因。';

  @override
  String get errorViewUnknownErrorAction => '您可以現在重試、檢查更新狀態，或稍後再試。';
}
