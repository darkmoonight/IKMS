import 'package:flutter/material.dart';
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
    required this.info,
    this.textInfo,
  });
  final Icon icon;
  final String text;
  final Text? description;
  final bool switcher;
  final bool? value;
  final bool info;
  final String? textInfo;
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
          color: context.theme.colorScheme.primaryContainer,
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
                    style: context.theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            switcher
                ? Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: value!,
                      onChanged: onChange,
                    ),
                  )
                : info
                    ? Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Text(
                          textInfo!,
                          style: context.theme.textTheme.titleMedium,
                          overflow: TextOverflow.visible,
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
