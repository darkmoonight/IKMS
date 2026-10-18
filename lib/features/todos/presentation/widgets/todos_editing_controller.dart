import 'package:flutter/foundation.dart';

/// Tracks dirty state and compose readiness for the task create/edit form.
class TodosEditingController extends ChangeNotifier {
  /// Creates a controller seeded with the initial field values.
  TodosEditingController(
    String initialTitle,
    String initialTime,
    String? initialDiscipline,
  ) : _initialTitle = initialTitle,
      _initialTime = initialTime,
      _initialDiscipline = initialDiscipline {
    _initializeListeners();
  }

  String _initialTitle;
  String _initialTime;
  String? _initialDiscipline;

  /// Live title text.
  final ValueNotifier<String> title = ValueNotifier<String>('');

  /// Live completion-time text.
  final ValueNotifier<String> time = ValueNotifier<String>('');

  /// Live selected discipline name.
  final ValueNotifier<String?> discipline = ValueNotifier<String?>(null);

  final ValueNotifier<bool> _canCompose = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasChanges = ValueNotifier<bool>(false);

  /// Whether the form can be saved.
  ValueListenable<bool> get canCompose => _canCompose;

  /// Whether any field differs from the initial snapshot.
  ValueListenable<bool> get hasChanges => _hasChanges;

  void _initializeListeners() {
    title.value = _initialTitle;
    time.value = _initialTime;
    discipline.value = _initialDiscipline;

    title.addListener(_updateCanCompose);
    time.addListener(_updateCanCompose);
    discipline.addListener(_updateCanCompose);
  }

  /// Rebases all baselines to the current field values (after async hydrate).
  void markCurrentAsInitial() {
    _initialTitle = title.value;
    _initialTime = time.value;
    _initialDiscipline = discipline.value;
    _updateCanCompose();
  }

  void _updateCanCompose() {
    _hasChanges.value =
        title.value != _initialTitle ||
        time.value != _initialTime ||
        discipline.value != _initialDiscipline;

    final hasContent =
        title.value.trim().isNotEmpty && discipline.value != null;

    _canCompose.value =
        hasContent && (_hasChanges.value || _initialTitle.isEmpty);
  }

  @override
  void dispose() {
    title.removeListener(_updateCanCompose);
    time.removeListener(_updateCanCompose);
    discipline.removeListener(_updateCanCompose);

    title.dispose();
    time.dispose();
    discipline.dispose();
    _canCompose.dispose();
    _hasChanges.dispose();
    super.dispose();
  }
}
