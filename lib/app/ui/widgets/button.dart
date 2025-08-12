import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyTextButton extends StatelessWidget {
  const MyTextButton({
    super.key,
    required this.buttonName,
    required this.onPressed,
  });
  final String buttonName;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          backgroundColor: WidgetStatePropertyAll(
            context.theme.colorScheme.secondaryContainer.withAlpha(80),
          ),
        ),
        onPressed: onPressed,
        child: Text(buttonName, style: context.textTheme.titleMedium),
      ),
    );
  }
}
