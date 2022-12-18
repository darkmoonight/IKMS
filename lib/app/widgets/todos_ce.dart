import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ikms/app/api/donstu/caching.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/services/crud_isar.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:ikms/app/widgets/my_text_form.dart';
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
      service.titleEdit.value = TextEditingController(text: widget.todo!.name);
      service.timeEdit.value = TextEditingController(
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
                            style: context.theme.textTheme.headline2,
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
                textEditingController: service.titleEdit.value,
                hintText: 'name'.tr,
                type: TextInputType.text,
                icon: const Icon(Iconsax.edit_2),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'validateName'.tr;
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: DropdownButtonFormField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.book),
                    fillColor: context.theme.primaryColor,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: context.theme.disabledColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: context.theme.disabledColor,
                      ),
                    ),
                  ),
                  focusColor: Colors.transparent,
                  hint: Text(
                    "discipline".tr,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15.sp,
                    ),
                  ),
                  dropdownColor: context.theme.scaffoldBackgroundColor,
                  icon: const Icon(
                    Iconsax.arrow_down_1,
                  ),
                  isExpanded: true,
                  value: selectedDiscipline,
                  items: disciplineList?.map((e) {
                    return DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.discipline,
                          style: context.theme.textTheme.subtitle2,
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
                      readOnly: true,
                      textEditingController: service.timeEdit.value,
                      hintText: 'timeComlete'.tr,
                      type: TextInputType.datetime,
                      icon: const Icon(Iconsax.clock),
                      iconButton: IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                        ),
                        onPressed: () {
                          service.timeEdit.value.clear();
                        },
                      ),
                      onTap: () {
                        DatePicker.showDateTimePicker(
                          context,
                          showTitleActions: true,
                          theme: DatePickerTheme(
                            backgroundColor:
                                context.theme.scaffoldBackgroundColor,
                            cancelStyle: const TextStyle(color: Colors.red),
                            itemStyle: TextStyle(
                                color:
                                    context.theme.textTheme.headline6?.color),
                          ),
                          minTime: DateTime.now(),
                          maxTime:
                              DateTime.now().add(const Duration(days: 1000)),
                          onConfirm: (date) {
                            service.timeEdit.value.text = date.toString();
                          },
                          currentTime: DateTime.now(),
                          locale: '${locale?.languageCode}' == 'ru'
                              ? LocaleType.ru
                              : LocaleType.en,
                        );
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
                            textTrim(service.titleEdit.value);

                            widget.edit == false
                                ? service.addTodo(
                                    service.titleEdit.value,
                                    selectedDiscipline!,
                                    service.timeEdit.value,
                                  )
                                : service.updateTodo(
                                    widget.todo!,
                                    service.titleEdit.value,
                                    selectedDiscipline!,
                                    service.timeEdit.value,
                                  );
                            Get.back();
                          }
                        },
                        icon: const Icon(
                          Iconsax.send_1,
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
