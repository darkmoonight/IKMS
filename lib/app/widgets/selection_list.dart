import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/widgets/text_form.dart';
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
                    style: context.textTheme.titleLarge?.copyWith(
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
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          widget.headerText,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
          MyTextForm(
            onChanged: widget.onTextChanged,
            labelText: widget.hintText,
            type: TextInputType.text,
            icon: const Icon(Iconsax.search_normal_1, size: 18),
            iconButton: textEditingController.text.isNotEmpty
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
            controller: textEditingController,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          const Divider(
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
                    return const Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    );
                  },
                ),
              ),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: widget.data.length,
                itemBuilder: (BuildContext context, int index) {
                  final T data = widget.data[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
