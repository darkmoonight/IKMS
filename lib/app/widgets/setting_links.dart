import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SettingLinks extends StatelessWidget {
  const SettingLinks({
    super.key,
    required this.icon,
    required this.text,
    required this.switcher,
    this.description,
    this.value,
    this.onPressed,
    this.onChange,
  });
  final Icon icon;
  final String text;
  final Text? description;
  final bool switcher;
  final bool? value;
  final Function()? onPressed;
  final Function(bool)? onChange;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        height: 65,
        decoration: BoxDecoration(
          color: context.theme.primaryColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Row(
          children: [
            Flexible(
              child: Row(
                children: [
                  icon,
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    text,
                    style: context.theme.textTheme.headline6,
                  ),
                ],
              ),
            ),
            switcher
                ? Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: value!,
                      onChanged: onChange,
                    ),
                  )
                : Row(
                    children: [
                      description!,
                      const SizedBox(width: 5),
                      const Icon(Iconsax.arrow_right_3),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
