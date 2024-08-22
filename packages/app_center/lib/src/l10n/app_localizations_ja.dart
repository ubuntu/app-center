import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appCenterLabel => 'アプリセンター';

  @override
  String get appstreamSearchGreylist => 'アプリ;アプリケーション;プログラム;パッケージ;ソフトウェア;ソフト;ソフトウェアスイート;ツール;ストア;インストール;アップデート;app;application;package;program;programme;suite;tool';

  @override
  String get snapPageChannelLabel => 'チャンネル';

  @override
  String get snapPageConfinementLabel => '隔離';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return '$publisher に連絡を取る';
  }

  @override
  String get snapPageDescriptionLabel => '詳細';

  @override
  String get snapPageDeveloperWebsiteLabel => '開発者のWebサイト';

  @override
  String get snapPageDownloadSizeLabel => 'ダウンロードサイズ';

  @override
  String get snapPageSizeLabel => 'サイズ';

  @override
  String get snapPageGalleryLabel => 'ギャラリー';

  @override
  String get snapPageLicenseLabel => 'ライセンス';

  @override
  String get snapPageLinksLabel => 'リンク';

  @override
  String get snapPagePublisherLabel => 'パブリッシャー';

  @override
  String get snapPagePublishedLabel => 'リリース日';

  @override
  String get snapPageSummaryLabel => '要約';

  @override
  String get snapPageVersionLabel => 'バージョン';

  @override
  String get snapPageShareLinkCopiedMessage => 'クリップボードにリンクをコピー';

  @override
  String get explorePageLabel => '探す';

  @override
  String get explorePageCategoriesLabel => 'カテゴリー';

  @override
  String get managePageOwnUpdateAvailable => 'アプリセンターのアップデートが入手できます';

  @override
  String get managePageQuitToUpdate => 'アップデートを終了';

  @override
  String get managePageOwnUpdateDescription => 'このアプリを終了すると自動的にアップデートが開始します。';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return 'アプリセンターは $time に自動的にアップデートします。';
  }

  @override
  String get managePageOwnUpdateQuitButton => 'アップデートを終了';

  @override
  String get managePageCheckForUpdates => 'アップデートを確認';

  @override
  String get managePageCheckingForUpdates => 'アップデートを確認';

  @override
  String get managePageNoInternet => 'サーバーに接続できません。インターネット接続を確認してやり直してください。';

  @override
  String get managePageDescription => 'アップデートを確認し、アップデートを行い、すべてのアプリケーションの状況を管理します。';

  @override
  String get managePageDebUpdatesMessage => 'Debianパッケージのアップデートはソフトウェアアップデートで管理されています。';

  @override
  String get managePageInstalledAndUpdatedLabel => 'インストールとアップデート';

  @override
  String get managePageLabel => 'インストールしたsnapの管理';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'アップデートはありません。すべてのアプリケーションは最新です。';

  @override
  String get managePageSearchFieldSearchHint => 'インストールされているアプリを検索';

  @override
  String get managePageShowDetailsLabel => '詳細を表示';

  @override
  String get managePageShowSystemSnapsLabel => 'システムsnapを表示';

  @override
  String get managePageUpdateAllLabel => 'すべてをアップデート';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 日',
      one: '$n 日',
    );
    return '$_temp0 前にアップデート';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 週',
      one: '$n 週',
    );
    return '$_temp0 間前にアップデート';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ヶ月',
      one: '$n ヶ月',
    );
    return '$_temp0 前にアップデート';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 年',
      one: '$n 年',
    );
    return '$_temp0 前にアップデート';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return '$n 個のアップデートがあります';
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
  String get productivityPageLabel => '生産性';

  @override
  String get developmentPageLabel => '開発';

  @override
  String get gamesPageLabel => 'ゲーム';

  @override
  String get gamesPageTitle => '今アツいの';

  @override
  String get gamesPageTop => 'トップゲーム';

  @override
  String get gamesPageFeatured => 'イチオシタイトル';

  @override
  String get gamesPageBundles => 'アプリバンドル';

  @override
  String get unknownPublisher => 'パブリッシャー不明';

  @override
  String get searchFieldDebSection => 'Debian パッケージ';

  @override
  String get searchFieldSearchHint => 'アプリを検索';

  @override
  String searchFieldSearchForLabel(String query) {
    return '\"$query\" の検索結果をすべて表示';
  }

  @override
  String get searchFieldSnapSection => 'Snap パッケージ';

  @override
  String get searchPageFilterByLabel => 'フィルター';

  @override
  String searchPageNoResults(String query) {
    return '”$query”の検索結果はありませんでした';
  }

  @override
  String get searchPageNoResultsHint => '違うもの、あるいはもっと一般的になキーワードにしてみてください';

  @override
  String get searchPageNoResultsCategory => 'このカテゴリーにはパッケージが見つかりませんでした';

  @override
  String get searchPageNoResultsCategoryHint => '違うカテゴリにするか、もっと一般的なキーワードにしてみてください';

  @override
  String get searchPageSortByLabel => '並べ替え';

  @override
  String get searchPageRelevanceLabel => '関連度';

  @override
  String searchPageTitle(String query) {
    return '\"$query\" の結果';
  }

  @override
  String get aboutPageLabel => 'アプリ詳細';

  @override
  String aboutPageVersionLabel(String version) {
    return 'バージョン $version';
  }

  @override
  String get aboutPageContributorTitle => 'デザインと開発:';

  @override
  String get aboutPageCommunityTitle => 'コミュニティの一部:';

  @override
  String get aboutPageContributeLabel => '貢献またはバグ報告';

  @override
  String get aboutPageGitHubLabel => 'GitHubリポジトリ';

  @override
  String get aboutPagePublishLabel => 'Snap Storeに公開';

  @override
  String get aboutPageLearnMoreLabel => '追加情報';

  @override
  String get appstreamUrlTypeBugtracker => 'バグトラッカー';

  @override
  String get appstreamUrlTypeContact => '問い合わせ';

  @override
  String get appstreamUrlTypeContribute => '貢献';

  @override
  String get appstreamUrlTypeDonation => '寄付';

  @override
  String get appstreamUrlTypeFaq => 'FAQ';

  @override
  String get appstreamUrlTypeHelp => 'ヘルプ';

  @override
  String get appstreamUrlTypeHomepage => 'ホームページ';

  @override
  String get appstreamUrlTypeTranslate => '翻訳';

  @override
  String get appstreamUrlTypeVcsBrowser => 'ソース';

  @override
  String get packageFormatDebLabel => 'Debian パッケージ';

  @override
  String get packageFormatSnapLabel => 'Snap パッケージ';

  @override
  String get snapActionCancelLabel => 'キャンセル';

  @override
  String get snapActionInstallLabel => 'インストール';

  @override
  String get snapActionInstalledLabel => 'インストール済';

  @override
  String get snapActionInstallingLabel => 'インストール中';

  @override
  String get snapActionOpenLabel => '起動';

  @override
  String get snapActionRemoveLabel => 'アンインストール';

  @override
  String get snapActionRemovingLabel => 'アンインストール中';

  @override
  String get snapActionSwitchChannelLabel => 'チャンネルの変更';

  @override
  String get snapActionUpdateLabel => 'アップデート';

  @override
  String get snapCategoryAll => 'すべてのカテゴリー';

  @override
  String get snapActionUpdatingLabel => 'アップデート中';

  @override
  String get snapCategoryArtAndDesign => '芸術とデザイン';

  @override
  String get snapCategoryBooksAndReference => '本とリファレンス';

  @override
  String get snapCategoryDefaultButtonLabel => 'もっと見つける';

  @override
  String get snapCategoryDevelopment => '開発ツール';

  @override
  String get snapCategoryDevelopmentSlogan => '開発者必携のsnap';

  @override
  String get snapCategoryDevicesAndIot => '端末とIoT';

  @override
  String get snapCategoryEducation => '教育';

  @override
  String get snapCategoryEntertainment => '娯楽';

  @override
  String get snapCategoryFeatured => 'おすすめ';

  @override
  String get snapCategoryFeaturedSlogan => 'おすすめのSnap';

  @override
  String get snapCategoryFinance => '金融';

  @override
  String get snapCategoryGames => 'ゲーム';

  @override
  String get snapCategoryGamesSlogan => '今夜ハマるゲーム';

  @override
  String get snapCategoryGameDev => 'ゲーム開発';

  @override
  String get snapCategoryGameDevSlogan => 'ゲーム開発';

  @override
  String get snapCategoryGameEmulators => 'エミュレーター';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'エミュレーター';

  @override
  String get snapCategoryGnomeGames => 'GNOMEゲーム';

  @override
  String get snapCategoryGnomeGamesSlogan => 'GNOMEゲーム集';

  @override
  String get snapCategoryKdeGames => 'KDEゲーム';

  @override
  String get snapCategoryKdeGamesSlogan => 'KDEゲーム集';

  @override
  String get snapCategoryGameLaunchers => 'ゲームランチャー';

  @override
  String get snapCategoryGameLaunchersSlogan => 'ゲームランチャー';

  @override
  String get snapCategoryGameContentCreation => 'コンテンツ作成';

  @override
  String get snapCategoryGameContentCreationSlogan => 'コンテンツ作成';

  @override
  String get snapCategoryHealthAndFitness => '健康とフィットネス';

  @override
  String get snapCategoryMusicAndAudio => '音楽とオーディオ';

  @override
  String get snapCategoryNewsAndWeather => 'ニュースと天気';

  @override
  String get snapCategoryPersonalisation => '個人向けカスタマイズ';

  @override
  String get snapCategoryPhotoAndVideo => '写真とビデオ';

  @override
  String get snapCategoryProductivity => '生産性';

  @override
  String get snapCategoryProductivityButtonLabel => '生産性向上アプリを見つける';

  @override
  String get snapCategoryProductivitySlogan => 'To Doリストを消化する';

  @override
  String get snapCategoryScience => '科学';

  @override
  String get snapCategorySecurity => 'セキュリティ';

  @override
  String get snapCategoryServerAndCloud => 'サーバーとクラウド';

  @override
  String get snapCategorySocial => 'ソーシャル';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntuデスクトップ';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'デスクトップ使いこなし';

  @override
  String get snapCategoryUtilities => 'ユーティリティ';

  @override
  String get snapConfinementClassic => 'Classic';

  @override
  String get snapConfinementDevmode => 'Devmode';

  @override
  String get snapConfinementStrict => 'Strict';

  @override
  String get snapSortOrderAlphabeticalAsc => 'アルファベット順 (A から Z)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'アルファベット順 (Z から A)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'サイズ （最小から最大）';

  @override
  String get snapSortOrderDownloadSizeDesc => 'サイズ （最大から最小）';

  @override
  String get snapSortOrderInstalledSizeAsc => 'サイズ （最小から最大）';

  @override
  String get snapSortOrderInstalledSizeDesc => 'サイズ （最大から最小）';

  @override
  String get snapSortOrderInstalledDateAsc => '更新順 （古）';

  @override
  String get snapSortOrderInstalledDateDesc => '更新順 （新）';

  @override
  String get snapSortOrderRelevance => '関連性';

  @override
  String get snapRatingsBandVeryGood => '優';

  @override
  String get snapRatingsBandGood => '良';

  @override
  String get snapRatingsBandNeutral => '中立';

  @override
  String get snapRatingsBandPoor => '可';

  @override
  String get snapRatingsBandVeryPoor => '不可';

  @override
  String get snapRatingsBandInsufficientVotes => '不十分な投票数';

  @override
  String snapRatingsVotes(int n) {
    return '$n つの投票';
  }

  @override
  String snapReportLabel(String snapName) {
    return '$snapName を報告';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'このsnapを報告する理由を選択';

  @override
  String get snapReportSelectAnOptionLabel => '1つ選択してください';

  @override
  String get snapReportOptionCopyrightViolation => '著作権または商標権違反';

  @override
  String get snapReportOptionStoreViolation => 'Snap Store の規約違反';

  @override
  String get snapReportDetailsLabel => 'この報告の詳細を入力してください';

  @override
  String get snapReportOptionalEmailAddressLabel => 'メールアドレス（オプション）';

  @override
  String get snapReportCancelButtonLabel => 'キャンセル';

  @override
  String get snapReportSubmitButtonLabel => '報告を提出';

  @override
  String get snapReportEnterValidEmailError => '正しいEメールアドレスを入力してください';

  @override
  String get snapReportDetailsHint => 'コメント...';

  @override
  String get snapReportPrivacyAgreementLabel => '報告にあたり、次の規約を読み、同意する必要があります: ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Canonicalのプライバシー告知 ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'と ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get debPageErrorNoPackageInfo => 'パッケージ情報が見つかりません';

  @override
  String get externalResources => '追加リソース';

  @override
  String get externalResourcesButtonLabel => 'もっと見つける';

  @override
  String get allGamesButtonLabel => 'すべてのゲーム';

  @override
  String get externalResourcesDisclaimer => '注意 これらは外部ツールです。Canonicalによって所有または配布されたものではありません。';

  @override
  String get openInBrowser => 'ブラウザーで開く';

  @override
  String get installAll => 'すべてインストール';

  @override
  String get localDebWarningTitle => '潜在的に安全ではない';

  @override
  String get localDebWarningBody => 'このパッケージはサードパーティによって提供されています。アプリセンター外からパッケージをインストールすることは、システムと個人データのリスクを増すことになり得ます。続ける前に本当に信用できるソースか確認してください。';

  @override
  String get localDebLearnMore => 'サードパーティパッケージについての追加情報';

  @override
  String get localDebDialogMessage => 'このパッケージはサードパーティによって提供されており、システムと個人データを脅かすことになるかもしれません。';

  @override
  String get localDebDialogConfirmation => '本当にインストールしますか？';

  @override
  String snapdExceptionRunningApps(String snapName) {
    return '現在実行中の $snapName はアップデートできません。';
  }

  @override
  String get errorViewCheckStatusLabel => '状況を確認';

  @override
  String get errorViewNetworkErrorTitle => 'インターネットに接続';

  @override
  String get errorViewNetworkErrorDescription => 'インターネット接続がないとアプリセンターの内容を読み込むことはできません。';

  @override
  String get errorViewNetworkErrorAction => '接続を確認してやり直してください。';

  @override
  String get errorViewServerErrorDescription => '現在アプリセンターの問題に直面しています。';

  @override
  String get errorViewServerErrorAction => 'アップデートの状況を確認してやり直してください。';

  @override
  String get errorViewUnknownErrorTitle => '何かがおかしいです';

  @override
  String get errorViewUnknownErrorDescription => 'どんなエラーが起きているのかよくわかっていません。';

  @override
  String get errorViewUnknownErrorAction => 'やり直し、アップデートの状況を確認するか、後でやり直してください。';
}
