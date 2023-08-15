import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ikms/app/api/donstu/caching.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/services/crud_isar.dart';
import 'package:ikms/app/widgets/text_form.dart';
import 'package:ikms/main.dart';

class TodosCe extends StatefulWidget {
  const TodosCe({
    super.key,
    required this.text,
    required this.edit,
    this.todo,
  });

  final String text;
  final bool edit;
  final Todos? todo;

  @override
  State<TodosCe> createState() => _TodosCeState();
}

class _TodosCeState extends State<TodosCe> {
  final service = IsarServices();
  final formKey = GlobalKey<FormState>();
  TextEditingController titleEdit = TextEditingController();
  TextEditingController timeEdit = TextEditingController();

  final locale = Get.locale;

  Schedule? selectedDiscipline;
  List<Schedule>? disciplineList;

  textTrim(value) {
    value.text = value.text.trim();
    while (value.text.contains("  ")) {
      value.text = value.text.replaceAll("  ", " ");
    }
  }

  @override
  initState() {
    getListData();
    if (widget.edit == true) {
      titleEdit = TextEditingController(text: widget.todo!.name);
      timeEdit = TextEditingController(
          text: widget.todo!.todoCompletedTime != null
              ? widget.todo!.todoCompletedTime.toString()
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
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 5, right: 10),
                child: Row(
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: const Icon(
                              Icons.close,
                            ),
                          ),
                          Text(
                            widget.text,
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    widget.todo != null
                        ? IconButton(
                            onPressed: () {
                              service.deleteTodo(widget.todo!);
                              Get.back();
                            },
                            icon: const Icon(
                              Iconsax.trash,
                              color: Colors.red,
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              MyTextForm(
                elevation: 4,
                margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                controller: titleEdit,
                labelText: 'name'.tr,
                type: TextInputType.text,
                icon: const Icon(Iconsax.edit_2),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'validateName'.tr;
                  }
                  return null;
                },
              ),
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: DropdownButtonFormField(
                  style: context.textTheme.titleMedium,
                  isExpanded: true,
                  decoration: InputDecoration(
                    label: Text(
                      'discipline'.tr,
                    ),
                    prefixIcon: const Icon(Iconsax.book),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  icon: const Icon(Iconsax.arrow_down_1),
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
                      return "validateDiscipline".tr;
                    }
                    return null;
                  },
                ),
              ),
              Row(
                children: [
                  Flexible(
                    flex: 5,
                    child: MyTextForm(
                      elevation: 4,
                      margin:
                          const EdgeInsets.only(left: 10, right: 10, top: 10),
                      readOnly: true,
                      controller: timeEdit,
                      labelText: 'timeComlete'.tr,
                      type: TextInputType.datetime,
                      icon: const Icon(Iconsax.clock),
                      iconButton: IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                        ),
                        onPressed: () {
                          timeEdit.clear();
                        },
                      ),
                      onTap: () {
                        BottomPicker.dateTime(
                          title: 'time'.tr,
                          description: 'timeDesc'.tr,
                          titleStyle: context.textTheme.titleMedium!,
                          descriptionStyle: context.textTheme.bodyLarge!
                              .copyWith(color: Colors.grey),
                          pickerTextStyle: context.textTheme.bodyLarge!,
                          iconColor: context.theme.iconTheme.color!,
                          closeIconColor: Colors.red,
                          backgroundColor:
                              context.theme.scaffoldBackgroundColor,
                          onSubmit: (date) {
                            timeEdit.text = date.toString();
                          },
                          bottomPickerTheme: BottomPickerTheme.plumPlate,
                          minDateTime: DateTime.now(),
                          maxDateTime:
                              DateTime.now().add(const Duration(days: 1000)),
                          initialDateTime: DateTime.now(),
                          use24hFormat: true,
                          dateOrder: DatePickerDateOrder.dmy,
                        ).show(context);
                      },
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin:
                          const EdgeInsets.only(right: 10, bottom: 5, top: 10),
                      decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: IconButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            textTrim(titleEdit);
                            widget.edit == false
                                ? service.addTodo(
                                    titleEdit,
                                    selectedDiscipline!,
                                    timeEdit,
                                  )
                                : service.updateTodo(
                                    widget.todo!,
                                    titleEdit,
                                    selectedDiscipline!,
                                    timeEdit,
                                  );
                            Get.back();
                          }
                        },
                        icon: const Icon(
                          Iconsax.send_1,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
