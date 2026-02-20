import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app/api/caching.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/controller/todo_controller.dart';
import 'package:ikms/app/ui/widgets/confirmation_dialog.dart';
import 'package:ikms/app/ui/widgets/text_form.dart';
import 'package:ikms/app/constants/app_constants.dart';
import 'package:ikms/app/utils/navigation_helper.dart';
import 'package:ikms/app/utils/responsive_utils.dart';
import 'package:ikms/main.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class TodosAction extends StatefulWidget {
  const TodosAction({
    super.key,
    required this.text,
    required this.edit,
    this.todo,
  });

  final String text;
  final bool edit;
  final Todos? todo;

  @override
  State<TodosAction> createState() => _TodosActionState();
}

class _TodosActionState extends State<TodosAction>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TodoController _todoController = Get.find<TodoController>();

  late final TextEditingController _titleController;
  late final TextEditingController _timeController;

  Schedule? _selectedDiscipline;
  List<Schedule> _disciplineList = [];
  bool _isLoading = true;

  late final _EditingController _editingController;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  late final DateFormat _dateFormatter;

  @override
  void initState() {
    super.initState();
    _dateFormatter = DateFormat.yMMMEd(locale.languageCode).add_Hm();
    _initializeControllers();
    _initializeEditingController();
    _initAnimations();
    _loadDisciplineData();
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _timeController = TextEditingController();

    if (widget.edit && widget.todo != null) {
      _titleController.text = widget.todo!.name;
      _timeController.text = widget.todo!.todoCompletedTime != null
          ? _dateFormatter.format(widget.todo!.todoCompletedTime!)
          : '';
    }
  }

  void _initializeEditingController() {
    _editingController = _EditingController(
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
      final group = settings.group.value;
      final university = settings.university.value;

      if (group != null && university != null) {
        final scheduleData = await UniversityCaching.cacheGroupSchedule(
          university,
          group,
        );
        final seen = <String>{};

        if (!mounted) return;
        setState(() {
          _disciplineList =
              scheduleData.schedules
                  .where((s) => seen.add(s.discipline))
                  .toList()
                ..sort(
                  (a, b) => a.discipline.toLowerCase().compareTo(
                    b.discipline.toLowerCase(),
                  ),
                );

          if (widget.todo != null) {
            _selectedDiscipline = _disciplineList.firstWhereOrNull(
              (e) => e.discipline == widget.todo!.discipline,
            );
            _editingController.discipline.value = _selectedDiscipline;
          }

          _isLoading = false;
        });

        _editingController.markDisciplineAsInitial();
      }
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

    // Если нет изменений, просто закрываем
    if (!_editingController.hasChanges.value) {
      NavigationHelper.back();
      return;
    }

    // Если есть изменения, показываем диалог подтверждения
    final shouldPop = await showClearTextConfirmation(
      context: context,
      onConfirm: () {
        _clearControllers();
        NavigationHelper.back();
      },
    );

    if (shouldPop == true && mounted) {
      NavigationHelper.back();
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

    if (widget.edit && widget.todo != null) {
      _todoController.updateTodo(
        widget.todo!,
        _titleController.text,
        _selectedDiscipline!,
        _timeController.text,
      );
    } else {
      _todoController.addTodo(
        _titleController.text,
        _selectedDiscipline!,
        _timeController.text,
      );
    }

    _clearControllers();
    NavigationHelper.back();
  }

  void _trimText(TextEditingController controller) {
    controller.text = controller.text.trim();
    while (controller.text.contains('  ')) {
      controller.text = controller.text.replaceAll('  ', ' ');
    }
  }

  Future<void> _showDateTimePicker() async {
    final DateTime? dateTime = await showOmniDateTimePicker(
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
                  child: _buildForm(context, padding),
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

  Widget _buildForm(BuildContext context, double padding) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoSection(context, padding),
              SizedBox(height: padding * 1.5),
              _buildDisciplineSection(context, padding),
              SizedBox(height: padding * 1.5),
              _buildTimeSection(context, padding),
              SizedBox(height: padding * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context, double padding) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyTextForm(
          elevation: 0,
          margin: EdgeInsets.zero,
          controller: _titleController,
          labelText: 'name'.tr,
          type: TextInputType.multiline,
          icon: Icon(IconsaxPlusLinear.edit, color: colorScheme.primary),
          autofocus: !widget.edit,
          onChanged: (value) => _editingController.title.value = value,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'validateName'.tr;
            }
            return null;
          },
          maxLine: null,
        ),
      ],
    );
  }

  Widget _buildDisciplineSection(BuildContext context, double padding) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<Schedule>(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
            color: colorScheme.onSurface,
          ),
          isExpanded: true,
          initialValue: _isLoading ? null : _selectedDiscipline,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 8, right: 6),
              child: IconTheme(
                data: IconThemeData(
                  color: colorScheme.onSurfaceVariant,
                  size: isMobile ? 18 : 20,
                ),
                child: const Icon(IconsaxPlusLinear.book_square),
              ),
            ),
            labelText: _isLoading ? 'loading'.tr : 'discipline'.tr,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            labelStyle: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 14,
              vertical: isMobile ? 12 : 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
          ),
          borderRadius: BorderRadius.circular(12),
          icon: _isLoading
              ? const SizedBox(width: 24, height: 24)
              : Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    IconsaxPlusLinear.arrow_down,
                    size: AppConstants.iconSizeSmall,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
          items: _isLoading
              ? []
              : _disciplineList
                    .map(
                      (schedule) => DropdownMenuItem<Schedule>(
                        value: schedule,
                        child: Text(
                          schedule.discipline,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
          onChanged: _isLoading
              ? null
              : (Schedule? newValue) {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _selectedDiscipline = newValue;
                    _editingController.discipline.value = newValue;
                  });
                },
          validator: (value) {
            if (_isLoading) return null;
            if (value == null) return 'validateDiscipline'.tr;
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTimeSection(BuildContext context, double padding) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasTime = _timeController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyTextForm(
          elevation: 0,
          margin: EdgeInsets.zero,
          readOnly: true,
          controller: _timeController,
          labelText: 'timeComplete'.tr,
          type: TextInputType.datetime,
          icon: Icon(IconsaxPlusLinear.clock_1, color: colorScheme.primary),
          iconButton: hasTime
              ? IconButton(
                  icon: Icon(
                    IconsaxPlusLinear.close_circle,
                    size: AppConstants.iconSizeSmall,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _timeController.clear();
                      if (widget.edit) {
                        _editingController.time.value = '';
                      }
                    });
                  },
                )
              : null,
          onTap: _showDateTimePicker,
        ),
      ],
    );
  }
}

class _EditingController extends ChangeNotifier {
  _EditingController(
      this._initialTitle,
      this._initialTime,
      this._initialDiscipline,
      ) {
    _initializeListeners();
  }

  final String _initialTitle;
  final String _initialTime;
  Schedule? _initialDiscipline;

  final ValueNotifier<String> title = ValueNotifier<String>('');
  final ValueNotifier<String> time = ValueNotifier<String>('');
  final ValueNotifier<Schedule?> discipline = ValueNotifier<Schedule?>(null);
  final ValueNotifier<bool> _canCompose = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasChanges = ValueNotifier<bool>(false);

  ValueListenable<bool> get canCompose => _canCompose;
  ValueListenable<bool> get hasChanges => _hasChanges;

  void _initializeListeners() {
    title.value = _initialTitle;
    time.value = _initialTime;
    discipline.value = _initialDiscipline;

    title.addListener(_updateCanCompose);
    time.addListener(_updateCanCompose);
    discipline.addListener(_updateCanCompose);
  }

  void markDisciplineAsInitial() {
    _initialDiscipline = discipline.value;
    _updateCanCompose();
  }

  void _updateCanCompose() {
    _hasChanges.value =
        title.value != _initialTitle ||
            time.value != _initialTime ||
            discipline.value?.discipline != _initialDiscipline?.discipline;

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
