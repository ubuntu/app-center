import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appCenterLabel => 'Центр приложений';

  @override
  String get appstreamSearchGreylist => 'приложение;програма;программа;пакет;программы;приложения;инструмент';

  @override
  String get snapPageChannelLabel => 'Канал';

  @override
  String get snapPageConfinementLabel => 'Уровень изоляции';

  @override
  String snapPageContactPublisherLabel(String publisher) {
    return 'Связаться с $publisher';
  }

  @override
  String get snapPageDescriptionLabel => 'Описание';

  @override
  String get snapPageDeveloperWebsiteLabel => 'Веб-сайт разработчика';

  @override
  String get snapPageDownloadSizeLabel => 'Размер загрузки';

  @override
  String get snapPageSizeLabel => 'Размер';

  @override
  String get snapPageGalleryLabel => 'Галерея';

  @override
  String get snapPageLicenseLabel => 'Лицензия';

  @override
  String get snapPageLinksLabel => 'Ссылки';

  @override
  String get snapPagePublisherLabel => 'Издатель';

  @override
  String get snapPagePublishedLabel => 'Опубликовано';

  @override
  String get snapPageSummaryLabel => 'Главное';

  @override
  String get snapPageVersionLabel => 'Версия';

  @override
  String get snapPageShareLinkCopiedMessage => 'Ссылка скопирована в буфер обмена';

  @override
  String get explorePageLabel => 'Обзор';

  @override
  String get explorePageCategoriesLabel => 'Категории';

  @override
  String get managePageOwnUpdateAvailable => 'Доступно обновление Центра приложений';

  @override
  String get managePageQuitToUpdate => 'Закройте для обновления';

  @override
  String get managePageOwnUpdateDescription => 'Обновление произойдёт автоматически, когда Вы закроете приложение.';

  @override
  String managePageOwnUpdateDescriptionSoon(String time) {
    return 'Центр приложений будет автоматически обновлён через $time.';
  }

  @override
  String get managePageOwnUpdateQuitButton => 'Закрыть и обновить';

  @override
  String get managePageCheckForUpdates => 'Проверить наличие обновлений';

  @override
  String get managePageCheckingForUpdates => 'Проверка обновлений';

  @override
  String get managePageNoInternet => 'Не удалось подключиться к серверу. Проверьте подключение к Интернету или повторите попытку позже.';

  @override
  String get managePageDescription => 'Проверяйте доступность обновлений, обновляйте приложения и управляйте ими.';

  @override
  String get managePageDebUpdatesMessage => 'Обновление пакетов Debian осуществляется с помощью программы «Обновление приложений».';

  @override
  String get managePageInstalledAndUpdatedLabel => 'Установлено и обновлено';

  @override
  String get managePageLabel => 'Управление установленными Snap';

  @override
  String get managePageTitle => 'Manage installed snaps';

  @override
  String get managePageNoUpdatesAvailableDescription => 'Нет доступных обновлений. Все Ваши приложения актуальны.';

  @override
  String get managePageSearchFieldSearchHint => 'Поиск установленных приложений';

  @override
  String get managePageShowDetailsLabel => 'Подробнее';

  @override
  String get managePageShowSystemSnapsLabel => 'Показать системные';

  @override
  String get managePageUpdateAllLabel => 'Обновить всё';

  @override
  String managePageUpdatedDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n дн',
      one: '$n день',
    );
    return 'Обновлено $_temp0 назад';
  }

  @override
  String managePageUpdatedWeeksAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n нед',
      one: '$n неделю',
    );
    return 'Обновлено $_temp0 назад';
  }

  @override
  String managePageUpdatedMonthsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n мес',
      one: '$n месяц',
    );
    return 'Обновлено $_temp0 назад';
  }

  @override
  String managePageUpdatedYearsAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n г',
      one: '$n год',
    );
    return 'Обновлено $_temp0 назад';
  }

  @override
  String managePageUpdatesAvailable(int n) {
    return 'Доступны обновления ($n)';
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
  String get productivityPageLabel => 'Работа';

  @override
  String get developmentPageLabel => 'Разработка';

  @override
  String get gamesPageLabel => 'Игры';

  @override
  String get gamesPageTitle => 'Актуальное';

  @override
  String get gamesPageTop => 'Лучшие игры';

  @override
  String get gamesPageFeatured => 'Избранные наименования';

  @override
  String get gamesPageBundles => 'Наборы приложений';

  @override
  String get unknownPublisher => 'Неизвестный издатель';

  @override
  String get searchFieldDebSection => 'Debian-пакеты';

  @override
  String get searchFieldSearchHint => 'Поиск приложений';

  @override
  String searchFieldSearchForLabel(String query) {
    return 'Показать все результаты для \"$query\"';
  }

  @override
  String get searchFieldSnapSection => 'Snap-пакеты';

  @override
  String get searchPageFilterByLabel => 'Фильтр';

  @override
  String searchPageNoResults(String query) {
    return 'Нет результатов для \"$query\"';
  }

  @override
  String get searchPageNoResultsHint => 'Попробуйте использовать другие или больше ключевых слов';

  @override
  String get searchPageNoResultsCategory => 'Извините, мы не смогли найти никаких пакетов в этой категории';

  @override
  String get searchPageNoResultsCategoryHint => 'Попробуйте поискать в другой категории, или используйте другие ключевые слова';

  @override
  String get searchPageSortByLabel => 'Сортировка';

  @override
  String get searchPageRelevanceLabel => 'по Релевантности';

  @override
  String searchPageTitle(String query) {
    return 'Результаты для \"$query\"';
  }

  @override
  String get aboutPageLabel => 'Инфо';

  @override
  String aboutPageVersionLabel(String version) {
    return 'Версия $version';
  }

  @override
  String get aboutPageContributorTitle => 'Участники разработки:';

  @override
  String get aboutPageCommunityTitle => 'Будьте частью сообщества:';

  @override
  String get aboutPageContributeLabel => 'Поучаствовать или сообщить о проблеме';

  @override
  String get aboutPageGitHubLabel => 'Проект на GitHub';

  @override
  String get aboutPagePublishLabel => 'Публикация приложений в Snap Store';

  @override
  String get aboutPageLearnMoreLabel => 'Узнать больше';

  @override
  String get appstreamUrlTypeBugtracker => 'Багтрекер';

  @override
  String get appstreamUrlTypeContact => 'Связаться';

  @override
  String get appstreamUrlTypeContribute => 'Участие';

  @override
  String get appstreamUrlTypeDonation => 'Пожертвование';

  @override
  String get appstreamUrlTypeFaq => 'ЧаВо';

  @override
  String get appstreamUrlTypeHelp => 'Помощь';

  @override
  String get appstreamUrlTypeHomepage => 'Домашняя страница';

  @override
  String get appstreamUrlTypeTranslate => 'Локализация';

  @override
  String get appstreamUrlTypeVcsBrowser => 'Исходный код';

  @override
  String get packageFormatDebLabel => 'Debian-пакеты';

  @override
  String get packageFormatSnapLabel => 'Snap-пакеты';

  @override
  String get snapActionCancelLabel => 'Отменить';

  @override
  String get snapActionInstallLabel => 'Установить';

  @override
  String get snapActionInstalledLabel => 'Установлено';

  @override
  String get snapActionInstallingLabel => 'Установка';

  @override
  String get snapActionOpenLabel => 'Открыть';

  @override
  String get snapActionRemoveLabel => 'Удалить';

  @override
  String get snapActionRemovingLabel => 'Удаление';

  @override
  String get snapActionSwitchChannelLabel => 'Переключить канал';

  @override
  String get snapActionUpdateLabel => 'Обновить';

  @override
  String get snapCategoryAll => 'Все категории';

  @override
  String get snapActionUpdatingLabel => 'Обновление';

  @override
  String get snapCategoryArtAndDesign => 'Дизайн и искусство';

  @override
  String get snapCategoryBooksAndReference => 'Книги и справочники';

  @override
  String get snapCategoryDefaultButtonLabel => 'Исследовать больше';

  @override
  String get snapCategoryDevelopment => 'Разработка';

  @override
  String get snapCategoryDevelopmentSlogan => 'Приложения для разработчиков';

  @override
  String get snapCategoryDevicesAndIot => 'Устройства и IoT';

  @override
  String get snapCategoryEducation => 'Образование';

  @override
  String get snapCategoryEntertainment => 'Развлечения';

  @override
  String get snapCategoryFeatured => 'Избранное';

  @override
  String get snapCategoryFeaturedSlogan => 'Избранные приложения';

  @override
  String get snapCategoryFinance => 'Финансы';

  @override
  String get snapCategoryGames => 'Игры';

  @override
  String get snapCategoryGamesSlogan => 'Всё для ночной игры';

  @override
  String get snapCategoryGameDev => 'Разработка игр';

  @override
  String get snapCategoryGameDevSlogan => 'Разработка игр';

  @override
  String get snapCategoryGameEmulators => 'Эмуляторы';

  @override
  String get snapCategoryGameEmulatorsSlogan => 'Эмуляторы';

  @override
  String get snapCategoryGnomeGames => 'Игры GNOME';

  @override
  String get snapCategoryGnomeGamesSlogan => 'Набор игр GNOME';

  @override
  String get snapCategoryKdeGames => 'Игры KDE';

  @override
  String get snapCategoryKdeGamesSlogan => 'Набор игр KDE';

  @override
  String get snapCategoryGameLaunchers => 'Программы запуска игр';

  @override
  String get snapCategoryGameLaunchersSlogan => 'Игровые лаунчеры';

  @override
  String get snapCategoryGameContentCreation => 'Создание контента';

  @override
  String get snapCategoryGameContentCreationSlogan => 'Создание контента';

  @override
  String get snapCategoryHealthAndFitness => 'Здоровье и фитнес';

  @override
  String get snapCategoryMusicAndAudio => 'Музыка и аудио';

  @override
  String get snapCategoryNewsAndWeather => 'Новости и погода';

  @override
  String get snapCategoryPersonalisation => 'Персонализация';

  @override
  String get snapCategoryPhotoAndVideo => 'Фото и видео';

  @override
  String get snapCategoryProductivity => 'Работа';

  @override
  String get snapCategoryProductivityButtonLabel => 'Исследовать коллекцию для работы';

  @override
  String get snapCategoryProductivitySlogan => 'Вычеркните из списка дел';

  @override
  String get snapCategoryScience => 'Наука';

  @override
  String get snapCategorySecurity => 'Безопасность';

  @override
  String get snapCategoryServerAndCloud => 'Серверы и облака';

  @override
  String get snapCategorySocial => 'Социальность';

  @override
  String get snapCategoryUbuntuDesktop => 'Ubuntu Desktop';

  @override
  String get snapCategoryUbuntuDesktopSlogan => 'Всё для начала работы';

  @override
  String get snapCategoryUtilities => 'Утилиты';

  @override
  String get snapConfinementClassic => 'Классический';

  @override
  String get snapConfinementDevmode => 'Режим разработчика (Devmode)';

  @override
  String get snapConfinementStrict => 'Строгий';

  @override
  String get snapSortOrderAlphabeticalAsc => 'по Алфавиту (от А до Я)';

  @override
  String get snapSortOrderAlphabeticalDesc => 'по Алфавиту (от Я до А)';

  @override
  String get snapSortOrderDownloadSizeAsc => 'по Размеру (от мен. к бол.)';

  @override
  String get snapSortOrderDownloadSizeDesc => 'по Размеру (от бол. к мен.)';

  @override
  String get snapSortOrderInstalledSizeAsc => 'по Размеру (от мен. к бол.)';

  @override
  String get snapSortOrderInstalledSizeDesc => 'по Размеру (от бол. к мен.)';

  @override
  String get snapSortOrderInstalledDateAsc => 'Обновлено давно';

  @override
  String get snapSortOrderInstalledDateDesc => 'Обновлено недавно';

  @override
  String get snapSortOrderRelevance => 'по Релевантности';

  @override
  String get snapRatingsBandVeryGood => 'Очень положительный';

  @override
  String get snapRatingsBandGood => 'Положительный';

  @override
  String get snapRatingsBandNeutral => 'Нейтральный';

  @override
  String get snapRatingsBandPoor => 'Отрицательный';

  @override
  String get snapRatingsBandVeryPoor => 'Очень отрицательный';

  @override
  String get snapRatingsBandInsufficientVotes => 'Недостаточно голосов';

  @override
  String snapRatingsVotes(int n) {
    return '$n голосов';
  }

  @override
  String snapReportLabel(String snapName) {
    return 'Пожаловаться на $snapName';
  }

  @override
  String get snapReportSelectReportReasonLabel => 'Выберите причину жалобы на этот snap-пакет';

  @override
  String get snapReportSelectAnOptionLabel => 'Выберите пункт';

  @override
  String get snapReportOptionCopyrightViolation => 'Нарушение авторских прав или товарных знаков';

  @override
  String get snapReportOptionStoreViolation => 'Нарушение условий обслуживания Snap Store';

  @override
  String get snapReportDetailsLabel => 'Предоставьте более подробное обоснование к жалобе';

  @override
  String get snapReportOptionalEmailAddressLabel => 'Ваш адрес электронной почты (необязательно)';

  @override
  String get snapReportCancelButtonLabel => 'Отменить';

  @override
  String get snapReportSubmitButtonLabel => 'Отправить жалобу';

  @override
  String get snapReportEnterValidEmailError => 'Введите действительный адрес электронной почты';

  @override
  String get snapReportDetailsHint => 'Комментарий...';

  @override
  String get snapReportPrivacyAgreementLabel => 'Отправляя эту форму, я подтверждаю, что соглашаюсь с ';

  @override
  String get snapReportPrivacyAgreementCanonicalPrivacyNotice => 'Уведомлением о конфиденциальности Canonical ';

  @override
  String get snapReportPrivacyAgreementAndLabel => 'и ';

  @override
  String get snapReportPrivacyAgreementPrivacyPolicy => 'Политикой конфиденциальности';

  @override
  String get debPageErrorNoPackageInfo => 'Информация о пакете не найдена';

  @override
  String get externalResources => 'Дополнительные ресурсы';

  @override
  String get externalResourcesButtonLabel => 'Исследовать';

  @override
  String get allGamesButtonLabel => 'Все игры';

  @override
  String get externalResourcesDisclaimer => 'Примечание. Всё это внешние инструменты. Они не принадлежат и не распространяются Canonical.';

  @override
  String get openInBrowser => 'Открыть в браузере';

  @override
  String get installAll => 'Установить все';

  @override
  String get localDebWarningTitle => 'Потенциально небезопасно';

  @override
  String get localDebWarningBody => 'Этот пакет предоставлен третьей стороной. Установка пакетов не из каталога Центра приложений может повысить риск для Вашей системы и персональных данных. Прежде чем приступить к установке, убедитесь, что доверяете источнику.';

  @override
  String get localDebLearnMore => 'Узнайте больше о сторонних пакетах';

  @override
  String get localDebDialogMessage => 'Этот пакет предоставляется третьей стороной и может представлять угрозу для Вашей системы и персональных данных.';

  @override
  String get localDebDialogConfirmation => 'Вы уверены, что хотите установить его?';

  @override
  String snapdExceptionRunningApps(String snapName) {
    return 'Мы не смогли обновить приложение $snapName, так как оно сейчас запущено.';
  }

  @override
  String get errorViewCheckStatusLabel => 'Проверить состояние';

  @override
  String get errorViewNetworkErrorTitle => 'Подключитесь к Интернету';

  @override
  String get errorViewNetworkErrorDescription => 'Мы не можем загрузить каталог Центра приложений без подключения к Интернету.';

  @override
  String get errorViewNetworkErrorAction => 'Проверьте соединение и повторите попытку.';

  @override
  String get errorViewServerErrorDescription => 'Мы сожалеем, но в настоящее время у нас возникли проблемы с Центром приложений.';

  @override
  String get errorViewServerErrorAction => 'Проверьте состояние служб для сведения или повторите попытку позже.';

  @override
  String get errorViewUnknownErrorTitle => 'Что-то пошло не так';

  @override
  String get errorViewUnknownErrorDescription => 'Нам жаль, но мы не уверены, в чем заключается проблема.';

  @override
  String get errorViewUnknownErrorAction => 'Вы можете повторить попытку сейчас, проверить состояние служб для сведения или повторить попытку позже.';
}
