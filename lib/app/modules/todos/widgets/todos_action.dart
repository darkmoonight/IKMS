import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:ikms/app/api/donstu/caching.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/controller/todo_controller.dart';
import 'package:ikms/app/widgets/text_form.dart';
import 'package:ikms/main.dart';
import 'package:intl/intl.dart';

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

class _TodosActionState extends State<TodosAction> {
  final formKey = GlobalKey<FormState>();
  final todoController = Get.put(TodoController());
  TextEditingController titleEdit = TextEditingController();
  TextEditingController timeEdit = TextEditingController();

  Schedule? selectedDiscipline;
  List<Schedule>? disciplineList;

  textTrim(value) {
    value.text = value.text.trim();
    while (value.text.contains('  ')) {
      value.text = value.text.replaceAll('  ', ' ');
    }
  }

  @override
  initState() {
    getListData();
    if (widget.edit) {
      titleEdit = TextEditingController(text: widget.todo!.name);
      timeEdit = TextEditingController(
          text: widget.todo!.todoCompletedTime != null
              ? DateFormat.yMMMEd(locale.languageCode)
                  .add_Hm()
                  .format(widget.todo!.todoCompletedTime!)
              : '');
    }
    super.initState();
  }

  getListData() async {
    final g = settings.group.value;
    var seen = <String>{};
    if (g != null) {
      final t = await DonstuCaching.cacheGroupSchedule(g);
      if (t.schedules.isNotEmpty) {
        setState(() {
          List<Schedule> scheduleList =
              t.schedules.where((list) => seen.add(list.discipline)).toList();
          disciplineList = scheduleList.toList();
          disciplineList!.sort((a, b) =>
              a.discipline.toLowerCase().compareTo(b.discipline.toLowerCase()));
          widget.todo != null
              ? selectedDiscipline = disciplineList
                  ?.firstWhere((e) => e.discipline == widget.todo!.discipline)
              : null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        titleEdit.clear();
                        timeEdit.clear();
                        Get.back();
                      },
                      icon: const Icon(
                        IconsaxOutline.close_square,
                        size: 20,
                      ),
                    ),
                    Text(
                      widget.text,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      children: [
                        widget.todo != null
                            ? IconButton(
                                onPressed: () {
                                  todoController.deleteTodo(widget.todo!);
                                  Get.back();
                                },
                                icon: const Icon(
                                  IconsaxOutline.trash,
                                  size: 20,
                                ),
                              )
                            : SizedBox.fromSize(),
                        IconButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              textTrim(titleEdit);
                              widget.edit
                                  ? todoController.updateTodo(
                                      widget.todo!,
                                      titleEdit.text,
                                      selectedDiscipline!,
                                      timeEdit.text,
                                    )
                                  : todoController.addTodo(
                                      titleEdit.text,
                                      selectedDiscipline!,
                                      timeEdit.text,
                                    );
                              Get.back();
                            }
                          },
                          icon: const Icon(
                            IconsaxOutline.tick_square,
                            size: 20,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              MyTextForm(
                elevation: 4,
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                controller: titleEdit,
                labelText: 'name'.tr,
                type: TextInputType.multiline,
                icon: const Icon(IconsaxOutline.edit_2),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'validateName'.tr;
                  }
                  return null;
                },
                maxLine: null,
              ),
              Card(
                elevation: 4,
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: DropdownButtonFormField(
                  style: context.textTheme.titleMedium,
                  isExpanded: true,
                  decoration: InputDecoration(
                    label: Text('discipline'.tr),
                    prefixIcon: const Icon(IconsaxOutline.book),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 15, bottom: 10),
                    child: Icon(IconsaxOutline.arrow_down_1, size: 18),
                  ),
                  value: selectedDiscipline,
                  items: disciplineList?.map((e) {
                    return DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.discipline,
                          style: context.textTheme.bodyMedium,
                          overflow: TextOverflow.visible,
                        ));
                  }).toList(),
                  onChanged: (Schedule? newValue) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    setState(() {
                      selectedDiscipline = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'validateDiscipline'.tr;
                    }
                    return null;
                  },
                ),
              ),
              MyTextForm(
                elevation: 4,
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                onChanged: (value) => setState(() {}),
                readOnly: true,
                controller: timeEdit,
                labelText: 'timeComlete'.tr,
                type: TextInputType.datetime,
                icon: const Icon(IconsaxOutline.clock),
                iconButton: timeEdit.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                        ),
                        onPressed: () {
                          timeEdit.clear();
                          setState(() {});
                        },
                      )
                    : null,
                onTap: () {
                  BottomPicker.dateTime(
                    titlePadding: const EdgeInsets.only(top: 10),
                    title: 'time'.tr,
                    description: 'timeDesc'.tr,
                    titleStyle: context.textTheme.titleMedium!,
                    descriptionStyle: context.textTheme.labelLarge!
                        .copyWith(color: Colors.grey),
                    pickerTextStyle:
                        context.textTheme.labelMedium!.copyWith(fontSize: 15),
                    closeIconColor: Colors.red,
                    backgroundColor: context.theme.primaryColor,
                    onSubmit: (date) {
                      String formattedDate =
                          DateFormat.yMMMEd(locale.languageCode)
                              .add_Hm()
                              .format(date);
                      timeEdit.text = formattedDate;
                      setState(() {});
                    },
                    bottomPickerTheme: BottomPickerTheme.plumPlate,
                    minDateTime: DateTime.now(),
                    maxDateTime: DateTime.now().add(const Duration(days: 1000)),
                    initialDateTime: DateTime.now(),
                    use24hFormat: true,
                    dateOrder: DatePickerDateOrder.dmy,
                  ).show(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
