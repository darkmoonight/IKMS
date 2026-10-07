///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsRuRu extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRuRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ruRu,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru-RU>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final TranslationsRuRu _root = this; // ignore: unused_field

	@override 
	TranslationsRuRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRuRu(meta: meta ?? this.$meta);

	// Translations
	@override String get time_complete => 'Время выполнения';
	@override String get done => 'Выполненные';
	@override String get doing => 'В процессе';
	@override String get update => 'Задача изменена';
	@override String get add_todo => 'Добавьте задачу';
	@override String get completed_todo => 'Выполните задачу';
	@override String get todo_delete => 'Задача удалена';
	@override String get todo_create => 'Задача создана';
	@override String get duplicate_todo => 'Задача уже существует';
	@override String get editing => 'Редактирование';
	@override String get create => 'Создание';
	@override String get name => 'Имя';
	@override String get validate_name => 'Пожалуйста, введите имя';
	@override String get validate_discipline => 'Пожалуйста, выберите дисциплину';
	@override String get todos => 'Задачи';
	@override String get timetable => 'Расписание занятий';
	@override String get sched_hint => 'В нашем приложении вы сможете посмотреть свое расписание, а также расписание преподавателей, аудиторий и других групп.';
	@override String get schedule => 'Расписание';
	@override String get theme => 'Тема';
	@override String get settings => 'Настройки';
	@override String get group => 'Группа';
	@override String get university => 'Университет';
	@override String get audiences => 'Аудитории';
	@override String get professors => 'Преподаватели';
	@override String get number => 'Номер аудитории';
	@override String get fio => 'ФИО преподавателя';
	@override String get universities => 'Университеты';
	@override String get groups => 'Группы';
	@override String get universities_name => 'Название университета';
	@override String get groups_name => 'Название группы';
	@override String get week => 'Неделя';
	@override String get two_week => '2 недели';
	@override String get month => 'Месяц';
	@override String get no_par => 'Сегодня пар нет';
	@override String get no_rasp => 'Нет данных о расписании';
	@override String get error => 'Произошла ошибка';
	@override String get no_select => 'Не выбран';
	@override String get no_university => 'Университет не выбран';
	@override String get no_internet => 'Нет связи с сервером\nОбновите страницу или проверьте подключение к интернету';
	@override String get get_started => 'Начать';
	@override String get discipline => 'Выберите дисциплинy';
	@override String get version => 'Версия приложения';
	@override String get material_color => 'Динамические цвета';
	@override String get amoled_theme => 'AMOLED-тема';
	@override String get appearance => 'Внешний вид';
	@override String get project => 'Проект на';
	@override String get language => 'Язык';
	@override String get ads => 'Отключить рекламу';
	@override String get search_todo => 'Поиск задачи';
	@override String get ads_disable_title => 'Отключение рекламы';
	@override String get ads_disable => 'Вы уверены, что хотите отключить рекламу? Ваша поддержка через рекламу помогает нам улучшать и поддерживать это приложение. Спасибо за вашу поддержку!';
	@override String get cancel => 'Отмена';
	@override String get disable => 'Отключить';
	@override String get system => 'Системная';
	@override String get dark => 'Тёмная';
	@override String get light => 'Светлая';
	@override String get license => 'Лицензии';
	@override String get license_app_summary => 'Приложение использует ПО с открытым исходным кодом. Нажмите на пакет, чтобы прочитать лицензию.';
	@override String get license_dependencies => 'Зависимости';
	@override String get license_packages => 'пакетов';
	@override String get close => 'Закрыть';
	@override String get error_occurred => 'Произошла ошибка';
	@override String get deleted_todo => 'Удаление задачи';
	@override String get deleted_todo_query => 'Вы уверены что хотите удалить задачу?';
	@override String get delete => 'Удалить';
	@override String get our_groups => 'Наши группы';
	@override String get search => 'Поиск';
	@override String get failed_to_load_groups => 'Не удалось загрузить группы';
	@override String get no_items_found => 'Ничего не найдено';
	@override String get error_loading_data => 'Ошибка при загрузке данных';
	@override String get try_again => 'Попробуйте снова';
	@override String get loading => 'Загрузка';
	@override String get about_app => 'О приложении';
	@override String get app_preferences => 'Настройки приложения';
	@override String get schedule_settings => 'Настройки расписания';
	@override String get edit_todo_hint => 'Измените детали задачи';
	@override String get create_todo_hint => 'Заполните информацию о задаче';
	@override String get ready => 'Готово';
	@override String get confirm => 'Подтвердить';
	@override String get clear_text => 'Удалить изменения';
	@override String get clear_text_warning => 'Вы уверены, что хотите отменить изменения? Все несохраненные данные будут потеряны.';
	@override String get days_short => 'дн.';
	@override String get hours_short => 'ч.';
	@override String get minutes_short => 'мин.';
	@override String get overdue => 'просрочено';
	@override String get through => 'через';
	@override String get task_one => 'задача';
	@override String get task_few => 'задачи';
	@override String get task_many => 'задач';
	@override String get no_results => 'Ничего не найдено';
}

/// The flat map containing all translations for locale <ru-RU>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsRuRu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'time_complete' => 'Время выполнения',
			'done' => 'Выполненные',
			'doing' => 'В процессе',
			'update' => 'Задача изменена',
			'add_todo' => 'Добавьте задачу',
			'completed_todo' => 'Выполните задачу',
			'todo_delete' => 'Задача удалена',
			'todo_create' => 'Задача создана',
			'duplicate_todo' => 'Задача уже существует',
			'editing' => 'Редактирование',
			'create' => 'Создание',
			'name' => 'Имя',
			'validate_name' => 'Пожалуйста, введите имя',
			'validate_discipline' => 'Пожалуйста, выберите дисциплину',
			'todos' => 'Задачи',
			'timetable' => 'Расписание занятий',
			'sched_hint' => 'В нашем приложении вы сможете посмотреть свое расписание, а также расписание преподавателей, аудиторий и других групп.',
			'schedule' => 'Расписание',
			'theme' => 'Тема',
			'settings' => 'Настройки',
			'group' => 'Группа',
			'university' => 'Университет',
			'audiences' => 'Аудитории',
			'professors' => 'Преподаватели',
			'number' => 'Номер аудитории',
			'fio' => 'ФИО преподавателя',
			'universities' => 'Университеты',
			'groups' => 'Группы',
			'universities_name' => 'Название университета',
			'groups_name' => 'Название группы',
			'week' => 'Неделя',
			'two_week' => '2 недели',
			'month' => 'Месяц',
			'no_par' => 'Сегодня пар нет',
			'no_rasp' => 'Нет данных о расписании',
			'error' => 'Произошла ошибка',
			'no_select' => 'Не выбран',
			'no_university' => 'Университет не выбран',
			'no_internet' => 'Нет связи с сервером\nОбновите страницу или проверьте подключение к интернету',
			'get_started' => 'Начать',
			'discipline' => 'Выберите дисциплинy',
			'version' => 'Версия приложения',
			'material_color' => 'Динамические цвета',
			'amoled_theme' => 'AMOLED-тема',
			'appearance' => 'Внешний вид',
			'project' => 'Проект на',
			'language' => 'Язык',
			'ads' => 'Отключить рекламу',
			'search_todo' => 'Поиск задачи',
			'ads_disable_title' => 'Отключение рекламы',
			'ads_disable' => 'Вы уверены, что хотите отключить рекламу? Ваша поддержка через рекламу помогает нам улучшать и поддерживать это приложение. Спасибо за вашу поддержку!',
			'cancel' => 'Отмена',
			'disable' => 'Отключить',
			'system' => 'Системная',
			'dark' => 'Тёмная',
			'light' => 'Светлая',
			'license' => 'Лицензии',
			'license_app_summary' => 'Приложение использует ПО с открытым исходным кодом. Нажмите на пакет, чтобы прочитать лицензию.',
			'license_dependencies' => 'Зависимости',
			'license_packages' => 'пакетов',
			'close' => 'Закрыть',
			'error_occurred' => 'Произошла ошибка',
			'deleted_todo' => 'Удаление задачи',
			'deleted_todo_query' => 'Вы уверены что хотите удалить задачу?',
			'delete' => 'Удалить',
			'our_groups' => 'Наши группы',
			'search' => 'Поиск',
			'failed_to_load_groups' => 'Не удалось загрузить группы',
			'no_items_found' => 'Ничего не найдено',
			'error_loading_data' => 'Ошибка при загрузке данных',
			'try_again' => 'Попробуйте снова',
			'loading' => 'Загрузка',
			'about_app' => 'О приложении',
			'app_preferences' => 'Настройки приложения',
			'schedule_settings' => 'Настройки расписания',
			'edit_todo_hint' => 'Измените детали задачи',
			'create_todo_hint' => 'Заполните информацию о задаче',
			'ready' => 'Готово',
			'confirm' => 'Подтвердить',
			'clear_text' => 'Удалить изменения',
			'clear_text_warning' => 'Вы уверены, что хотите отменить изменения? Все несохраненные данные будут потеряны.',
			'days_short' => 'дн.',
			'hours_short' => 'ч.',
			'minutes_short' => 'мин.',
			'overdue' => 'просрочено',
			'through' => 'через',
			'task_one' => 'задача',
			'task_few' => 'задачи',
			'task_many' => 'задач',
			'no_results' => 'Ничего не найдено',
			_ => null,
		};
	}
}
