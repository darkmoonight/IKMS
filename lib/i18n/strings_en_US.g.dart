///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEnUs = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.enUs,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en-US>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en-US: 'Execution time'
	String get time_complete => 'Execution time';

	/// en-US: 'Done'
	String get done => 'Done';

	/// en-US: 'Doing'
	String get doing => 'Doing';

	/// en-US: 'Todo changed'
	String get update => 'Todo changed';

	/// en-US: 'Add a todo'
	String get add_todo => 'Add a todo';

	/// en-US: 'Complete the todo'
	String get completed_todo => 'Complete the todo';

	/// en-US: 'Todo deleted'
	String get todo_delete => 'Todo deleted';

	/// en-US: 'Todo created'
	String get todo_create => 'Todo created';

	/// en-US: 'The todo already exists'
	String get duplicate_todo => 'The todo already exists';

	/// en-US: 'Editing'
	String get editing => 'Editing';

	/// en-US: 'Create'
	String get create => 'Create';

	/// en-US: 'Name'
	String get name => 'Name';

	/// en-US: 'Please enter a name'
	String get validate_name => 'Please enter a name';

	/// en-US: 'Please choose a discipline'
	String get validate_discipline => 'Please choose a discipline';

	/// en-US: 'Todos'
	String get todos => 'Todos';

	/// en-US: 'Timetable'
	String get timetable => 'Timetable';

	/// en-US: 'In our application, you can view your schedule, as well as the schedule of teachers, classrooms and other groups.'
	String get sched_hint => 'In our application, you can view your schedule, as well as the schedule of teachers, classrooms and other groups.';

	/// en-US: 'Schedule'
	String get schedule => 'Schedule';

	/// en-US: 'Theme'
	String get theme => 'Theme';

	/// en-US: 'Settings'
	String get settings => 'Settings';

	/// en-US: 'Group'
	String get group => 'Group';

	/// en-US: 'University'
	String get university => 'University';

	/// en-US: 'Audiences'
	String get audiences => 'Audiences';

	/// en-US: 'Professors'
	String get professors => 'Professors';

	/// en-US: 'Audience number'
	String get number => 'Audience number';

	/// en-US: 'Full name of the professor'
	String get fio => 'Full name of the professor';

	/// en-US: 'Universities'
	String get universities => 'Universities';

	/// en-US: 'Groups'
	String get groups => 'Groups';

	/// en-US: 'Name of the university'
	String get universities_name => 'Name of the university';

	/// en-US: 'Group name'
	String get groups_name => 'Group name';

	/// en-US: 'Week'
	String get week => 'Week';

	/// en-US: '2 weeks'
	String get two_week => '2 weeks';

	/// en-US: 'Month'
	String get month => 'Month';

	/// en-US: 'There are no lessons today'
	String get no_par => 'There are no lessons today';

	/// en-US: 'No scheduling information'
	String get no_rasp => 'No scheduling information';

	/// en-US: 'There's been an error'
	String get error => 'There\'s been an error';

	/// en-US: 'Not selected'
	String get no_select => 'Not selected';

	/// en-US: 'University not selected'
	String get no_university => 'University not selected';

	/// en-US: 'There is no connection to the server Refresh the page or check your internet connection'
	String get no_internet => 'There is no connection to the server\nRefresh the page or check your internet connection';

	/// en-US: 'Get started'
	String get get_started => 'Get started';

	/// en-US: 'Choose a discipline'
	String get discipline => 'Choose a discipline';

	/// en-US: 'Application version'
	String get version => 'Application version';

	/// en-US: 'Dynamic colors'
	String get material_color => 'Dynamic colors';

	/// en-US: 'AMOLED-theme'
	String get amoled_theme => 'AMOLED-theme';

	/// en-US: 'Appearance'
	String get appearance => 'Appearance';

	/// en-US: 'Project on'
	String get project => 'Project on';

	/// en-US: 'Language'
	String get language => 'Language';

	/// en-US: 'Disable ads'
	String get ads => 'Disable ads';

	/// en-US: 'Search todo'
	String get search_todo => 'Search todo';

	/// en-US: 'Disable Ads'
	String get ads_disable_title => 'Disable Ads';

	/// en-US: 'Are you sure you want to disable ads? Your support through ads helps us improve and maintain this application. Thank you for your support!'
	String get ads_disable => 'Are you sure you want to disable ads? Your support through ads helps us improve and maintain this application. Thank you for your support!';

	/// en-US: 'Cancel'
	String get cancel => 'Cancel';

	/// en-US: 'Disable'
	String get disable => 'Disable';

	/// en-US: 'System'
	String get system => 'System';

	/// en-US: 'Dark'
	String get dark => 'Dark';

	/// en-US: 'Light'
	String get light => 'Light';

	/// en-US: 'Licenses'
	String get license => 'Licenses';

	/// en-US: 'Built with open-source software. Tap a package to read its license.'
	String get license_app_summary => 'Built with open-source software. Tap a package to read its license.';

	/// en-US: 'Dependencies'
	String get license_dependencies => 'Dependencies';

	/// en-US: 'packages'
	String get license_packages => 'packages';

	/// en-US: 'Close'
	String get close => 'Close';

	/// en-US: 'An error occurred'
	String get error_occurred => 'An error occurred';

	/// en-US: 'Deleting a todo'
	String get deleted_todo => 'Deleting a todo';

	/// en-US: 'Are you sure you want to delete the todo?'
	String get deleted_todo_query => 'Are you sure you want to delete the todo?';

	/// en-US: 'Delete'
	String get delete => 'Delete';

	/// en-US: 'Our groups'
	String get our_groups => 'Our groups';

	/// en-US: 'Search'
	String get search => 'Search';

	/// en-US: 'Failed to load groups'
	String get failed_to_load_groups => 'Failed to load groups';

	/// en-US: 'No items found'
	String get no_items_found => 'No items found';

	/// en-US: 'Error loading data'
	String get error_loading_data => 'Error loading data';

	/// en-US: 'Try again'
	String get try_again => 'Try again';

	/// en-US: 'Loading'
	String get loading => 'Loading';

	/// en-US: 'About App'
	String get about_app => 'About App';

	/// en-US: 'App Preferences'
	String get app_preferences => 'App Preferences';

	/// en-US: 'Schedule Settings'
	String get schedule_settings => 'Schedule Settings';

	/// en-US: 'Modify task details'
	String get edit_todo_hint => 'Modify task details';

	/// en-US: 'Fill in task information'
	String get create_todo_hint => 'Fill in task information';

	/// en-US: 'Ready'
	String get ready => 'Ready';

	/// en-US: 'Confirm'
	String get confirm => 'Confirm';

	/// en-US: 'Clear changes'
	String get clear_text => 'Clear changes';

	/// en-US: 'Are you sure you want to discard changes? All unsaved data will be lost.'
	String get clear_text_warning => 'Are you sure you want to discard changes? All unsaved data will be lost.';

	/// en-US: 'd.'
	String get days_short => 'd.';

	/// en-US: 'h.'
	String get hours_short => 'h.';

	/// en-US: 'm.'
	String get minutes_short => 'm.';

	/// en-US: 'overdue'
	String get overdue => 'overdue';

	/// en-US: 'in'
	String get through => 'in';

	/// en-US: 'task'
	String get task_one => 'task';

	/// en-US: 'tasks'
	String get task_few => 'tasks';

	/// en-US: 'tasks'
	String get task_many => 'tasks';

	/// en-US: 'No results'
	String get no_results => 'No results';
}

/// The flat map containing all translations for locale <en-US>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'time_complete' => 'Execution time',
			'done' => 'Done',
			'doing' => 'Doing',
			'update' => 'Todo changed',
			'add_todo' => 'Add a todo',
			'completed_todo' => 'Complete the todo',
			'todo_delete' => 'Todo deleted',
			'todo_create' => 'Todo created',
			'duplicate_todo' => 'The todo already exists',
			'editing' => 'Editing',
			'create' => 'Create',
			'name' => 'Name',
			'validate_name' => 'Please enter a name',
			'validate_discipline' => 'Please choose a discipline',
			'todos' => 'Todos',
			'timetable' => 'Timetable',
			'sched_hint' => 'In our application, you can view your schedule, as well as the schedule of teachers, classrooms and other groups.',
			'schedule' => 'Schedule',
			'theme' => 'Theme',
			'settings' => 'Settings',
			'group' => 'Group',
			'university' => 'University',
			'audiences' => 'Audiences',
			'professors' => 'Professors',
			'number' => 'Audience number',
			'fio' => 'Full name of the professor',
			'universities' => 'Universities',
			'groups' => 'Groups',
			'universities_name' => 'Name of the university',
			'groups_name' => 'Group name',
			'week' => 'Week',
			'two_week' => '2 weeks',
			'month' => 'Month',
			'no_par' => 'There are no lessons today',
			'no_rasp' => 'No scheduling information',
			'error' => 'There\'s been an error',
			'no_select' => 'Not selected',
			'no_university' => 'University not selected',
			'no_internet' => 'There is no connection to the server\nRefresh the page or check your internet connection',
			'get_started' => 'Get started',
			'discipline' => 'Choose a discipline',
			'version' => 'Application version',
			'material_color' => 'Dynamic colors',
			'amoled_theme' => 'AMOLED-theme',
			'appearance' => 'Appearance',
			'project' => 'Project on',
			'language' => 'Language',
			'ads' => 'Disable ads',
			'search_todo' => 'Search todo',
			'ads_disable_title' => 'Disable Ads',
			'ads_disable' => 'Are you sure you want to disable ads? Your support through ads helps us improve and maintain this application. Thank you for your support!',
			'cancel' => 'Cancel',
			'disable' => 'Disable',
			'system' => 'System',
			'dark' => 'Dark',
			'light' => 'Light',
			'license' => 'Licenses',
			'license_app_summary' => 'Built with open-source software. Tap a package to read its license.',
			'license_dependencies' => 'Dependencies',
			'license_packages' => 'packages',
			'close' => 'Close',
			'error_occurred' => 'An error occurred',
			'deleted_todo' => 'Deleting a todo',
			'deleted_todo_query' => 'Are you sure you want to delete the todo?',
			'delete' => 'Delete',
			'our_groups' => 'Our groups',
			'search' => 'Search',
			'failed_to_load_groups' => 'Failed to load groups',
			'no_items_found' => 'No items found',
			'error_loading_data' => 'Error loading data',
			'try_again' => 'Try again',
			'loading' => 'Loading',
			'about_app' => 'About App',
			'app_preferences' => 'App Preferences',
			'schedule_settings' => 'Schedule Settings',
			'edit_todo_hint' => 'Modify task details',
			'create_todo_hint' => 'Fill in task information',
			'ready' => 'Ready',
			'confirm' => 'Confirm',
			'clear_text' => 'Clear changes',
			'clear_text_warning' => 'Are you sure you want to discard changes? All unsaved data will be lost.',
			'days_short' => 'd.',
			'hours_short' => 'h.',
			'minutes_short' => 'm.',
			'overdue' => 'overdue',
			'through' => 'in',
			'task_one' => 'task',
			'task_few' => 'tasks',
			'task_many' => 'tasks',
			'no_results' => 'No results',
			_ => null,
		};
	}
}
