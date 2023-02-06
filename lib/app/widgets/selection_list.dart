import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:shimmer/shimmer.dart';

class SelectionList<T extends SelectionData> extends StatefulWidget {
  final String headerText;
  final String hintText;
  final Function(String)? onTextChanged;
  final bool isLoaded;
  final List<T> data;
  final Function(T) onEntrySelected;
  final Function()? onBackPressed;
  final TextStyle? selectionTextStyle;

  const SelectionList({
    super.key,
    required this.headerText,
    required this.hintText,
    required this.isLoaded,
    required this.onEntrySelected,
    required this.selectionTextStyle,
    required this.data,
    this.onTextChanged,
    this.onBackPressed,
  });

  @override
  State<SelectionList<T>> createState() => _SelectionListState<T>();
}

class _SelectionListState<T extends SelectionData>
    extends State<SelectionList<T>> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          widget.onBackPressed == null
              ? Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    widget.headerText,
                    style: context.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 15, left: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBackPressed,
                        icon: const Icon(Iconsax.arrow_left_1),
                        iconSize: context.theme.iconTheme.size,
                        color: context.theme.iconTheme.color,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          widget.headerText,
                          style: context.theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: TextField(
              controller: textEditingController,
              onChanged: widget.onTextChanged,
              style: context.theme.textTheme.titleMedium,
              decoration: InputDecoration(
                labelText: widget.hintText,
                labelStyle: context.theme.textTheme.labelLarge?.copyWith(
                  color: Colors.grey,
                ),
                fillColor: context.theme.colorScheme.primaryContainer,
                filled: true,
                prefixIcon: const Icon(
                  Iconsax.search_normal_1,
                  color: Colors.grey,
                  size: 18,
                ),
                suffixIcon: textEditingController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          textEditingController.clear();
                          if (widget.onTextChanged != null) {
                            widget.onTextChanged!('');
                          }
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 20,
                        ),
                      )
                    : null,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: context.theme.colorScheme.primaryContainer,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: context.theme.colorScheme.primaryContainer,
                  ),
                ),
              ),
              autofocus: false,
            ),
          ),
          Divider(
            color: context.theme.dividerColor,
            height: 20,
            thickness: 2,
            indent: 10,
            endIndent: 10,
          ),
          Expanded(
            child: Visibility(
              visible: widget.isLoaded,
              replacement: Shimmer.fromColors(
                baseColor: context.theme.colorScheme.primaryContainer,
                highlightColor: context.theme.unselectedWidgetColor,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: 10,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        color: context.theme.colorScheme.primaryContainer,
                      ),
                    );
                  },
                ),
              ),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: widget.data.length,
                itemBuilder: (BuildContext context, int index) {
                  final T data = widget.data[index];
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      color: context.theme.colorScheme.primaryContainer,
                    ),
                    child: TextButton(
                      onPressed: () => widget.onEntrySelected(data),
                      child: Text(
                        data.name,
                        style: widget.selectionTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
