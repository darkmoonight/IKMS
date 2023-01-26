import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyTextForm extends StatelessWidget {
  const MyTextForm({
    super.key,
    required this.hintText,
    required this.type,
    required this.icon,
    required this.textEditingController,
    this.onTap,
    this.readOnly = false,
    this.validator,
    this.iconButton,
  });
  final String hintText;
  final TextInputType type;
  final Icon icon;
  final IconButton? iconButton;
  final TextEditingController textEditingController;
  final Function()? onTap;
  final String? Function(String?)? validator;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: TextFormField(
        readOnly: readOnly,
        onTap: readOnly == true ? onTap : null,
        controller: textEditingController,
        keyboardType: type,
        style: context.theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          prefixIcon: icon,
          suffixIcon: iconButton,
          fillColor: context.theme.colorScheme.primaryContainer,
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
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 15,
          ),
        ),
        autofocus: false,
        validator: validator,
      ),
    );
  }
}
