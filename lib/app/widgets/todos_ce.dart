import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/services/isar_services.dart';
import 'package:ikms/app/widgets/my_text_form.dart';

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

  textTrim(value) {
    value.text = value.text.trim();
    while (value.text.contains("  ")) {
      value.text = value.text.replaceAll("  ", " ");
    }
  }

  @override
  initState() {
    if (widget.edit == true) {
      service.titleEdit.value = TextEditingController(text: widget.todo!.name);
      service.disciplineEdit.value =
          TextEditingController(text: widget.todo!.discipline);
    }
    super.initState();
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
                    IconButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          textTrim(service.titleEdit.value);
                          textTrim(service.disciplineEdit.value);
                          widget.edit == false
                              ? service.addTodo(
                                  service.titleEdit.value,
                                  service.disciplineEdit.value,
                                )
                              : service.updateTodo(
                                  widget.todo!,
                                  service.titleEdit.value,
                                  service.disciplineEdit.value,
                                );
                          Get.back();
                        }
                      },
                      icon: const Icon(
                        Icons.save,
                      ),
                    ),
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
              MyTextForm(
                textEditingController: service.disciplineEdit.value,
                hintText: 'discipline'.tr,
                type: TextInputType.text,
                icon: const Icon(Iconsax.note_text),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'validateDiscipline'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
