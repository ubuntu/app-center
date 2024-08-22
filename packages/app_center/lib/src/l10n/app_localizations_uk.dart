import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appCenterLabel => 'Центр застосунків';

  @override
  String get appstreamSearchGreylist => 'програма;додаток;застосунок;пакет;інструмент;засіб;засоби';

  @override
  String get snapPageChannelLabel => 'Канал';

  @override
  String get snapPageConfinementLabel => 'Обмеження';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Зв\'язатися з $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Опис';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Вебсайт розробника';

  @override
  String get snapPageDownloadSizeLabel => 'Розмір завантаження';

  @override
  String get snapPageSizeLabel => 'Розмір';

  @override
  String get snapPageGalleryLabel => 'Галерея';

  @override
  String get snapPageLicenseLabel => 'Ліцензія';

  @override
  String get snapPageLinksLabel => 'Посилання';

  @override
  String get snapPagePublisherLabel => 'Видавець';

  @override
  String get snapPagePublishedLabel => 'Опубліковано';

  @override
  String get snapPageSummaryLabel => 'Підсумок';

  @override
  String get snapPageVersionLabel => 'Версія';

  @override
  String get snapPageShareLinkCopiedMessage => 'Посилання скопійовано в буфер обміну';

  @override
  String get explorePageLabel => 'Цікаве';

  @override
  String get explorePageCategoriesLabel => 'Категорії';

  @override
  String get managePageOwnUpdateAvailable => 'Доступне оновлення центру застосунків';

  @override
  String get managePageQuitToUpdate => 'Вийти, щоб оновити';

  @override
  String get managePageOwnUpdateDescription => 'Коли ви вийдете з застосунку, він автоматично оновиться.';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return 'Центр застосунків автоматично оновиться за $time.';
  }

  @override
  String get managePageOwnUpdateQuitButton => 'Вийти, щоб оновити';

  @override
  String get managePageCheckForUpdates => 'Перевірити наявність оновлень';

  @override
  String get managePageCheckingForUpdates => 'Перевірка наявності оновлень';

  @override
  String get managePageNoInternet => 'Не вдалося зв\'язатися з сервером, перевірте з\'єднання з інтернетом або спробуйте пізніше.';

  @override
  String get managePageDescription => 'Перевіряйте наявність доступних оновлень, оновлюйте програми та керуйте їхнім станом.';

  @override
  String get managePageDebUpdatesMessage => 'Оновлення пакунків Debian виконує програма оновлення програмного забезпечення.';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Встановлено та оновлено';

  @override
  String get managePageLabel => 'Керувати встановленими прив\'язками';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Немає оновлень. Всі ваші програми актуальні.';

  @override
  String get managePageSearchFieldSearchHint => 'Шукати встановлені програми';

  @override
  String get managePageShowDetailsLabel => 'Показати деталі';

  @override
  String get managePageShowSystemSnapsLabel => 'Показати системні пакунки snap';

  @override
  String get managePageUpdateAllLabel => 'Оновити все';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n день',
      many: '$n днів',
      few: '$n дні',
      one: '$n день',
    );
    return 'Оновлено $_temp0 тому';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n тиждень',
      many: '$n тижнів',
      few: '$n тижні',
      one: '$n тиждень',
    );
    return 'Оновлено $_temp0 тому';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n місяць',
      many: '$n місяців',
      few: '$n місяці',
      one: '$n місяць',
    );
    return 'Оновлено $_temp0 тому';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n рік',
      many: '$n років',
      few: '$n роки',
      one: '$n рік',
    );
    return 'Оновлено $_temp0 тому';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Доступні оновлення ($n)';
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
  String get productivityPageLabel => 'Продуктивність';

  @override
  String get developmentPageLabel => 'Розробка';

  @override
  String get gamesPageLabel => 'Ігри';

  @override
  String get gamesPageTitle => 'Актуальне';

  @override
  String get gamesPageTop => 'Найкращі ігри';

  @override
  String get gamesPageFeatured => 'Обрані найменування';

  @override
  String get gamesPageBundles => 'Пакети застосунків';

  @override
  String get unknownPublisher => 'Невідомий видавець';

  @override
  String get searchFieldDebSection => 'Debian пакети';

  @override
  String get searchFieldSearchHint => 'Шукати програми';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Переглянути всі результати для \"$query\"';
  }

  @override
  String get searchFieldSnapSection => 'Snap пакети';

  @override
  String get searchPageFilterByLabel => 'Фільтрувати за';

  @override
  String searchPageNoResults(String query) {
    return 'За запитом \"$query\" нічого не знайдено';
  }

  @override
  String get searchPageNoResultsHint => 'Спробуйте використовувати інші або більш загальні ключові слова';

  @override
  String get searchPageNoResultsCategory => 'На жаль, ми не знайшли жодного пакету в цій категорії';

  @override
  String get searchPageNoResultsCategoryHint => 'Спробуйте іншу категорію або використовуйте більш загальні ключові слова';

  @override
  String get searchPageSortByLabel => 'Сортувати за';

  @override
  String get searchPageRelevanceLabel => 'Актуальність';

  @override
  String searchPageTitle(String query) {
    return 'Результати за запитом \"$query\"';
  }

  @override
  String get aboutPageLabel => 'Про';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Версія $version';
  }

  @override
  String get aboutPageContributorTitle => 'Спроектовано та розроблено:';

  @override
  String get aboutPageCommunityTitle => 'Станьте частиною спільноти:';

  @override
  String get aboutPageContributeLabel => 'Зробити внесок або повідомити про ваду';

  @override
  String get aboutPageGitHubLabel => 'Знаходьте нас на GitHub';

  @override
  String get aboutPagePublishLabel => 'Опублікувати в Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Докладніше';

  @override
  String get appstreamUrlTypeBugtracker => 'Багтрекер';

  @override
  String get appstreamUrlTypeContact => 'Контакт';

  @override
  String get appstreamUrlTypeContribute => 'Зробити внесок';

  @override
  String get appstreamUrlTypeDonation => 'Підтримати';

  @override
  String get appstreamUrlTypeFaq => 'ЧаПи';

  @override
  String get appstreamUrlTypeHelp => 'Довідка';

  @override
  String get appstreamUrlTypeHomepage => 'Головна сторінка';

  @override
  String get appstreamUrlTypeTranslate => 'Переклади';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Джерело';

  @override
  String get packageFormatDebLabel => 'Debian пакети';

  @override
  String get packageFormatSnapLabel => 'Snap пакети';

  @override
  String get snapActionCancelLabel => 'Скасувати';

  @override
  String get snapActionInstallLabel => 'Встановити';

  @override
  String get snapActionInstalledLabel => 'Встановлено';

  @override
  String get snapActionInstallingLabel => 'Встановлення';

  @override
  String get snapActionOpenLabel => 'Відкрити';

  @override
  String get snapActionRemoveLabel => 'Видалити';

  @override
  String get snapActionRemovingLabel => 'Видалення';

  @override
  String get snapActionSwitchChannelLabel => 'Перемкнути канал';

  @override
  String get snapActionUpdateLabel => 'Оновити';

  @override
  String get snapCategoryAll => 'Усі категорії';

  @override
  String get snapActionUpdatingLabel => 'Оновлення';

  @override
  String get snapCategoryArtAndDesign => 'Дизайн і мистецтво';

  @override
  String get snapCategoryBooksAndReference => 'Книги та довідники';

  @override
  String get snapCategoryDefaultButtonLabel => 'Знайти більше';

  @override
  String get snapCategoryDevelopment => 'Розробка';

  @override
  String get snapCategoryDevelopmentSlogan => 'Обов\'язкові пакунки snap для розробників';

  @override
  String get snapCategoryDevicesAndIot => 'Пристрої та IoT';

  @override
  String get snapCategoryEducation => 'Освіта й навчання';

  @override
  String get snapCategoryEntertainment => 'Розваги';

  @override
  String get snapCategoryFeatured => 'Обране';

  @override
  String get snapCategoryFeaturedSlogan => 'Обрані Snap-пакунки';

  @override
  String get snapCategoryFinance => 'Фінанси';

  @override
  String get snapCategoryGames => 'Ігри';

  @override
  String get snapCategoryGamesSlogan => 'Все для вашого ігрового вечора';

  @override
  String get snapCategoryGameDev => 'Розробка ігор';

  @override
  String get snapCategoryGameDevSlogan => 'Розробка ігор';

  @override
  String get snapCategoryGameEmulators => 'Емулятори';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Емулятори';

  @override
  String get snapCategoryGnomeGames => 'Ігри GNOME';

  @override
  String get snapCategoryGnomeGamesSlogan => 'Набір ігор GNOME';

  @override
  String get snapCategoryKdeGames => 'Ігри KDE';

  @override
  String get snapCategoryKdeGamesSlogan => 'Набір ігор KDE';

  @override
  String get snapCategoryGameLaunchers => 'Запускачі ігор';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Запускачі ігор';

  @override
  String get snapCategoryGameContentCreation => 'Створення контенту';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Створення контенту';

  @override
  String get snapCategoryHealthAndFitness => 'Здоров\'я та спорт';

  @override
  String get snapCategoryMusicAndAudio => 'Музика й звуки';

  @override
  String get snapCategoryNewsAndWeather => 'Новини й погода';

  @override
  String get snapCategoryPersonalisation => 'Персоналізація';

  @override
  String get snapCategoryPhotoAndVideo => 'Фотографії й відео';

  @override
  String get snapCategoryProductivity => 'Продуктивність';

  @override
  String get snapCategoryProductivityButtonLabel => 'Відкрийте для себе колекцію продуктивності';

  @override
  String get snapCategoryProductivitySlogan => 'Викресліть одну річ зі свого списку справ';

  @override
  String get snapCategoryScience => 'Наука';

  @override
  String get snapCategorySecurity => 'Безпека';

  @override
  String get snapCategoryServerAndCloud => 'Сервера та мережі';

  @override
  String get snapCategorySocial => 'Соціальні мережі';

  @override
  String get snapCategoryUbuntuDesktop => 'Стільниця Ubuntu';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Швидкий старт для вашої стільниці';

  @override
  String get snapCategoryUtilities => 'Утиліти';

  @override
  String get snapConfinementClassic => 'Класичний';

  @override
  String get snapConfinementDevmode => 'Режим розробника';

  @override
  String get snapConfinementStrict => 'Суворий';

  @override
  String get snapSortOrderAlphabeticalAsc => 'За абеткою (від А до Я)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'За абеткою (від Я до А)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'Розмір (від найменшого до найбільшого)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'Розмір (від найбільшого до найменшого)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'Розмір (від найменшого до найбільшого)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'Розмір (від найбільшого до найменшого)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Найдавніші оновлення';

  @override
  String get snapSortOrderInstalledDateDesc => 'Останні оновлення';

  @override
  String get snapSortOrderRelevance => 'Актуальність';

  @override
  String get snapRatingsBandVeryGood => 'Дуже добре';

  @override
  String get snapRatingsBandGood => 'Добре';

  @override
  String get snapRatingsBandNeutral => 'Нейтрально';

  @override
  String get snapRatingsBandPoor => 'Погано';

  @override
  String get snapRatingsBandVeryPoor => 'Дуже погано';

  @override
  String get snapRatingsBandInsufficientVotes => 'Недостатньо голосів';

  @override
  String snapRatingsVotes(int n) {
    return 'Голосів: $n';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Поскаржитися на $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Виберіть причину для скарги про цей snap';

  @override
  String get snapReportSelectAnOptionLabel => 'Оберіть опцію';

  @override
  String get snapReportOptionCopyrightViolation => 'Порушення авторського права або торгової марки';

  @override
  String get snapReportOptionStoreViolation => 'Порушення умов надання послуг Snap Store';

  @override
  String get snapReportDetailsLabel => 'Будь ласка, надайте більш детальну причину вашої скарги';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Ваша електронна пошта (необов\'язково)';

  @override
  String get snapReportCancelButtonLabel => 'Скасувати';

  @override
  String get snapReportSubmitButtonLabel => 'Надіслати скаргу';

  @override
  String get snapReportEnterValidEmailError => 'Введіть дійсну адресу електронної пошти';

  @override
  String get snapReportDetailsHint => 'Коментар...';

  @override
  String get snapReportPrivacyAgreementLabel => 'Відправляючи цю форму, я підтверджую ознайомлення та свою згоду з ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Повідомленням про приватність компанії Canonical ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'та ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'Політикою приватності';

  @override
  String get debPageErrorNoPackageInfo => 'Інформація про пакет не знайдена';

  @override
  String get externalResources => 'Додаткові ресурси';

  @override
  String get externalResourcesButtonLabel => 'Знайти більше';

  @override
  String get allGamesButtonLabel => 'Всі ігри';

  @override
  String get externalResourcesDisclaimer => 'Примітка: Це все зовнішні інструменти. Вони не належать і не розповсюджуються компанією Canonical.';

  @override
  String get openInBrowser => 'Відкрити в браузері';

  @override
  String get installAll => 'Встановити все';

  @override
  String get localDebWarningTitle => 'Потенційно небезпечно';

  @override
  String get localDebWarningBody => 'Цей пакет надається третьою стороною. Встановлення пакунків не з Центру додатків може збільшити ризик для вашої системи та особистих даних. Переконайтеся, що ви довіряєте джерелу, перш ніж продовжувати.';

  @override
  String get localDebLearnMore => 'Дізнайтеся більше про сторонні пакети';

  @override
  String get localDebDialogMessage => 'Цей пакет надається третьою стороною і може загрожувати вашій системі та персональним даним.';

  @override
  String get localDebDialogConfirmation => 'Ви впевнені, що ви бажаєте встановити це?';

  @override
  String snapdExceptionRunningApps(String snapName) {
    return 'Ми не змогли оновити $snapName, оскільки він наразі запущений.';
  }

  @override
  String get errorViewCheckStatusLabel => 'Перевірити стан';

  @override
  String get errorViewNetworkErrorTitle => 'Під\'єднатися до інтернету';

  @override
  String get errorViewNetworkErrorDescription => 'Ми не можемо завантажити вміст у Центр застосунків без інтернет-з\'єднання.';

  @override
  String get errorViewNetworkErrorAction => 'Перевірте з\'єднання та спробуйте ще раз.';

  @override
  String get errorViewServerErrorDescription => 'Перепрошуємо, наразі маємо проблеми з Центром застосунків.';

  @override
  String get errorViewServerErrorAction => 'Перевірте стан оновлень або спробуйте пізніше.';

  @override
  String get errorViewUnknownErrorTitle => 'Щось пішло не так';

  @override
  String get errorViewUnknownErrorDescription => 'Вибачте, але ми не впевнені, в чому саме полягає помилка.';

  @override
  String get errorViewUnknownErrorAction => 'Ви можете повторити спробу зараз, перевірити стан оновлень або спробувати пізніше.';
}
