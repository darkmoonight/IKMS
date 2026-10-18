import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/core/constants/app_constants.dart';
import 'package:ikms/core/di/providers.dart';
import 'package:ikms/core/utils/navigation_helper.dart';
import 'package:ikms/core/utils/responsive_utils.dart';
import 'package:ikms/core/widgets/confirmation_dialog.dart';
import 'package:ikms/domain/entities/todo_item.dart';
import 'package:ikms/features/todos/presentation/widgets/todos_action_form.dart';
import 'package:ikms/features/todos/presentation/widgets/todos_editing_controller.dart';
import 'package:ikms/i18n/tr.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

/// Bottom sheet form for creating or editing a task.
class TodosAction extends ConsumerStatefulWidget {
  /// Creates a create/edit task sheet.
  const TodosAction({
    super.key,
    required this.text,
    required this.edit,
    this.todo,
  });

  /// Header title text.
  final String text;

  /// Whether the form edits an existing task.
  final bool edit;

  /// Task being edited, if any.
  final TodoItem? todo;

  @override
  ConsumerState<TodosAction> createState() => _TodosActionState();
}

class _TodosActionState extends ConsumerState<TodosAction>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _timeController;

  String? _selectedDiscipline;
  List<String> _disciplineList = [];
  bool _isLoading = true;

  late final TodosEditingController _editingController;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  late DateFormat _dateFormatter;
  bool _disciplineLoadStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeEditingController();
    _initAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dateFormatter = DateFormat.yMMMEd(
      ref.read(appSettingsProvider).locale.languageCode,
    ).add_Hm();
    if (widget.edit &&
        widget.todo?.completedAt != null &&
        _timeController.text.isEmpty) {
      _timeController.text = _dateFormatter.format(widget.todo!.completedAt!);
      _editingController.time.value = _timeController.text;
      // Baseline must include hydrated deadline, or discard dialog always fires.
      _editingController.markCurrentAsInitial();
    }
    if (!_disciplineLoadStarted) {
      _disciplineLoadStarted = true;
      _loadDisciplineData();
    }
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _timeController = TextEditingController();

    if (widget.edit && widget.todo != null) {
      _titleController.text = widget.todo!.name;
    }
  }

  void _initializeEditingController() {
    _editingController = TodosEditingController(
      _titleController.text,
      _timeController.text,
      null,
    );
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.shortAnimation,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animationController.forward();
    });
  }

  Future<void> _loadDisciplineData() async {
    try {
      final names = await ref
          .read(scheduleCachePortProvider)
          .disciplineNamesForSelectedGroup();

      if (!mounted) return;

      setState(() {
        _disciplineList = names;
        if (widget.todo != null) {
          final match = names.cast<String?>().firstWhere(
            (n) => n == widget.todo!.discipline,
            orElse: () => null,
          );
          _selectedDiscipline = match ?? widget.todo!.discipline;
          if (_selectedDiscipline != null &&
              !_disciplineList.contains(_selectedDiscipline)) {
            _disciplineList = [..._disciplineList, _selectedDiscipline!];
          }
          _editingController.discipline.value = _selectedDiscipline;
        }
        _isLoading = false;
      });

      _editingController.markCurrentAsInitial();
    } catch (e) {
      debugPrint('Error loading discipline data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _editingController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onPopInvokedWithResult(bool didPop, dynamic result) async {
    if (didPop) return;

    if (!_editingController.hasChanges.value) {
      NavigationHelper.back(context);
      return;
    }

    final shouldPop = await showClearTextConfirmation(
      context: context,
      onConfirm: _clearControllers,
    );

    if (shouldPop == true && mounted) {
      NavigationHelper.back(context);
    }
  }

  void _clearControllers() {
    _titleController.clear();
    _timeController.clear();
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;

    _trimText(_titleController);

    if (_selectedDiscipline == null) return;

    final todoNotifier = ref.read(todoNotifierProvider.notifier);

    if (widget.edit && widget.todo != null) {
      todoNotifier.updateTodo(
        widget.todo!,
        _titleController.text,
        _selectedDiscipline!,
        _timeController.text,
      );
    } else {
      todoNotifier.addTodo(
        _titleController.text,
        _selectedDiscipline!,
        _timeController.text,
      );
    }

    _clearControllers();
    NavigationHelper.back(context);
  }

  void _trimText(TextEditingController controller) {
    controller.text = controller.text.trim();
    while (controller.text.contains('  ')) {
      controller.text = controller.text.replaceAll('  ', ' ');
    }
  }

  Future<void> _showDateTimePicker() async {
    final dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1000)),
      is24HourMode: true,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
    );

    if (dateTime != null) {
      setState(() {
        _timeController.text = _dateFormatter.format(dateTime);
        if (widget.edit) {
          _editingController.time.value = _timeController.text;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : AppConstants.maxModalWidth,
          maxHeight:
              MediaQuery.of(context).size.height * (isMobile ? 0.95 : 0.90),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(colorScheme, isMobile),
            _buildHeader(colorScheme, padding),
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            Flexible(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: TodosActionForm(
                    formKey: _formKey,
                    padding: padding,
                    isEdit: widget.edit,
                    isLoading: _isLoading,
                    titleController: _titleController,
                    timeController: _timeController,
                    selectedDiscipline: _selectedDiscipline,
                    disciplineList: _disciplineList,
                    editingController: _editingController,
                    onTitleChanged: (value) =>
                        _editingController.title.value = value,
                    onDisciplineChanged: (newValue) {
                      setState(() {
                        _selectedDiscipline = newValue;
                        _editingController.discipline.value = newValue;
                      });
                    },
                    onTimeTap: _showDateTimePicker,
                    onTimeCleared: () {
                      setState(() {
                        _timeController.clear();
                        if (widget.edit) {
                          _editingController.time.value = '';
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(ColorScheme colorScheme, bool isMobile) {
    if (!isMobile) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(
        top: AppConstants.spacingM,
        bottom: AppConstants.spacingS,
      ),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding * 1.5,
        vertical: padding,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingS + 2),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
            ),
            child: Icon(
              widget.edit ? IconsaxPlusBold.edit : IconsaxPlusBold.task_square,
              size: AppConstants.iconSizeLarge,
              color: colorScheme.onTertiaryContainer,
            ),
          ),
          SizedBox(width: padding * 1.2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      20,
                    ),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: AppConstants.spacingXS),
                Text(
                  widget.edit ? 'editTodoHint'.tr : 'createTodoHint'.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: padding * 0.8),
          _buildSaveButton(colorScheme),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme) {
    return ValueListenableBuilder<bool>(
      valueListenable: _editingController.canCompose,
      builder: (context, canCompose, _) {
        return AnimatedScale(
          scale: canCompose ? 1.0 : 0.92,
          duration: AppConstants.longAnimation,
          curve: Curves.easeOutCubic,
          child: Material(
            color: canCompose
                ? colorScheme.tertiary
                : colorScheme.surfaceContainerHigh,
            elevation: canCompose ? AppConstants.elevationLow : 0,
            shadowColor: colorScheme.tertiary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusXLarge,
            ),
            child: InkWell(
              onTap: canCompose ? _onSavePressed : null,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusXLarge,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: AppConstants.spacingS,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconsaxPlusBold.tick_circle,
                      size: AppConstants.iconSizeSmall,
                      color: canCompose
                          ? colorScheme.onTertiary
                          : colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: AppConstants.spacingXS + 2),
                    Text(
                      'ready'.tr,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          13,
                        ),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: canCompose
                            ? colorScheme.onTertiary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
