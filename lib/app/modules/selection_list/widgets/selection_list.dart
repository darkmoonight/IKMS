import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/widgets/shimmer.dart';
import 'package:ikms/app/widgets/text_form.dart';

class SelectionList<T extends SelectionData> extends StatefulWidget {
  final String headerText;
  final String labelText;
  final Function(String)? onTextChanged;
  final bool isLoaded;
  final List<T> data;
  final Function(T) onEntrySelected;
  final Function()? onBackPressed;

  const SelectionList({
    super.key,
    required this.headerText,
    required this.labelText,
    required this.isLoaded,
    required this.onEntrySelected,
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleSpacing: 0,
        leading: widget.onBackPressed == null
            ? null
            : IconButton(
                onPressed: widget.onBackPressed,
                icon: const Icon(
                  IconsaxPlusLinear.arrow_left_3,
                  size: 20,
                ),
              ),
        title: widget.onBackPressed == null
            ? Text(
                widget.headerText,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                widget.headerText,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MyTextForm(
              onChanged: widget.onTextChanged,
              labelText: widget.labelText,
              type: TextInputType.text,
              icon: const Icon(IconsaxPlusLinear.search_normal_1, size: 18),
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
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
            ),
            const Divider(),
            Expanded(
              child: Visibility(
                visible: widget.isLoaded,
                replacement: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (BuildContext context, int index) {
                    return const MyShimmer(
                      edgeInsetsMargin: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      hight: 60,
                    );
                  },
                ),
                child: ListView.builder(
                  itemCount: widget.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final T data = widget.data[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        splashColor: Colors.transparent,
                        onTap: () => widget.onEntrySelected(data),
                        title: Text(
                          data.name,
                          style: context.textTheme.labelLarge,
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
      ),
    );
  }
}
