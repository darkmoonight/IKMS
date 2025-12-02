import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app/api/caching.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/controller/todo_controller.dart';
import 'package:ikms/app/ui/widgets/text_form.dart';
import 'package:ikms/main.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class TodosAction extends StatefulWidget {
  final String text;
  final bool edit;
  final Todos? todo;

  const TodosAction({
    super.key,
    required this.text,
    required this.edit,
    this.todo,
  });

  @override
  State<TodosAction> createState() => _TodosActionState();
}

class _TodosActionState extends State<TodosAction> {
  final _formKey = GlobalKey<FormState>();
  final _todoController = Get.find<TodoController>();
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  Schedule? _selectedDiscipline;
  List<Schedule> _disciplineList = [];
  bool _isLoading = true;
  final _dateFormatter = DateFormat.yMMMEd(locale.languageCode).add_Hm();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadDisciplineData();
  }

  void _initializeControllers() {
    if (widget.edit && widget.todo != null) {
      _titleController.text = widget.todo!.name;
      _timeController.text = widget.todo!.todoCompletedTime != null
          ? _dateFormatter.format(widget.todo!.todoCompletedTime!)
          : '';
    }
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

        setState(() {
          _disciplineList =
              scheduleData.schedules
                  .where((schedule) => seen.add(schedule.discipline))
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
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading discipline data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _trimText(TextEditingController controller) {
    controller.text = controller.text.trim();
    while (controller.text.contains('  ')) {
      controller.text = controller.text.replaceAll('  ', ' ');
    }
  }

  Future<void> _selectDateTime() async {
    final dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1000)),
      minutesInterval: 1,
      is24HourMode: true,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      transitionDuration: const Duration(milliseconds: 200),
    );

    if (dateTime != null) {
      _timeController.text = _dateFormatter.format(dateTime);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _trimText(_titleController);

      if (_selectedDiscipline != null) {
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
        Get.back();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
    child: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildTitleField(),
              _buildDisciplineDropdown(),
              _buildTimeField(),
              const Gap(10),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildCloseButton(), _buildTitleText(), _buildSubmitButton()],
    ),
  );

  Widget _buildCloseButton() => IconButton(
    onPressed: () {
      _titleController.clear();
      _timeController.clear();
      Get.back();
    },
    icon: const Icon(IconsaxPlusLinear.close_square, size: 20),
  );

  Widget _buildTitleText() => Text(
    widget.text,
    style: context.textTheme.titleLarge?.copyWith(fontSize: 20),
    textAlign: TextAlign.center,
  );

  Widget _buildSubmitButton() => IconButton(
    onPressed: _submitForm,
    icon: const Icon(IconsaxPlusLinear.tick_square, size: 20),
  );

  Widget _buildTitleField() => MyTextForm(
    elevation: 4,
    margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
    controller: _titleController,
    labelText: 'name'.tr,
    type: TextInputType.multiline,
    icon: const Icon(IconsaxPlusLinear.edit),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'validateName'.tr;
      }
      return null;
    },
    maxLine: null,
  );

  Widget _buildDisciplineDropdown() => Card(
    elevation: 4,
    margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
    child: DropdownButtonFormField<Schedule>(
      style: context.textTheme.titleMedium,
      isExpanded: true,
      initialValue: _isLoading ? null : _selectedDiscipline,
      decoration: InputDecoration(
        labelText: _isLoading ? 'loading'.tr : 'discipline'.tr,
        prefixIcon: const Icon(IconsaxPlusLinear.book_square),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
      ),
      borderRadius: BorderRadius.circular(15),
      icon: _isLoading
          ? const SizedBox(width: 24, height: 24)
          : const Padding(
              padding: EdgeInsets.only(right: 15, bottom: 10),
              child: Icon(IconsaxPlusLinear.arrow_down, size: 18),
            ),
      items: _isLoading
          ? []
          : _disciplineList
                .map(
                  (schedule) => DropdownMenuItem<Schedule>(
                    value: schedule,
                    child: Text(
                      schedule.discipline,
                      style: context.textTheme.bodyMedium,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                )
                .toList(),
      onChanged: _isLoading
          ? null
          : (Schedule? newValue) {
              FocusScope.of(context).unfocus();
              setState(() => _selectedDiscipline = newValue);
            },
      validator: (value) {
        if (_isLoading) return null;
        if (value == null) {
          return 'validateDiscipline'.tr;
        }
        return null;
      },
    ),
  );

  Widget _buildTimeField() => MyTextForm(
    elevation: 4,
    margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
    readOnly: true,
    controller: _timeController,
    labelText: 'timeComplete'.tr,
    type: TextInputType.datetime,
    icon: const Icon(IconsaxPlusLinear.clock_1),
    iconButton: _timeController.text.isNotEmpty
        ? IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => _timeController.clear(),
          )
        : null,
    onTap: _selectDateTime,
  );
}
