import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_cdis/app/data/schema.dart';

class SelectionList extends StatefulWidget {
  final String headerText;
  final String hintText;
  final Function(String)? onTextChanged;
  final bool isLoaded;
  final List<SelectionData>? filteredData;
  final Function(SelectionData) onEntrySelected;
  final Function()? onBackPressed;
  final TextStyle? selectionTextStyle;

  const SelectionList({
    super.key,
    required this.headerText,
    required this.hintText,
    required this.isLoaded,
    required this.onEntrySelected,
    required this.selectionTextStyle,
    required this.filteredData,
    this.onTextChanged,
    this.onBackPressed,
  });

  @override
  State<SelectionList> createState() => _SelectionListState();
}

class _SelectionListState extends State<SelectionList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          widget.onBackPressed == null
              ? Padding(
                  padding: EdgeInsets.only(top: 15.w),
                  child: Text(
                    widget.headerText,
                    style: Theme.of(context).textTheme.headline2,
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(top: 15.w, left: 10.w),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBackPressed,
                        icon: const Icon(Icons.arrow_back),
                        iconSize: Theme.of(context).iconTheme.size,
                        color: Theme.of(context).iconTheme.color,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Expanded(
                        child: Text(
                          widget.headerText,
                          style: Theme.of(context).textTheme.headline2,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
            child: TextField(
              onChanged: widget.onTextChanged,
              style: Theme.of(context).textTheme.headline6,
              decoration: InputDecoration(
                fillColor: Theme.of(context).primaryColor,
                filled: true,
                prefixIcon: const Icon(
                  Icons.search_outlined,
                  color: Colors.grey,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15.sp,
                ),
              ),
              autofocus: false,
            ),
          ),
          Divider(
            color: Theme.of(context).dividerColor,
            height: 20.w,
            thickness: 2,
            indent: 10.w,
            endIndent: 10.w,
          ),
          Expanded(
            child: Visibility(
              visible: widget.isLoaded,
              replacement: const Center(
                child: CircularProgressIndicator(),
              ),
              child: ListView.builder(
                itemCount: widget.filteredData?.length,
                itemBuilder: (BuildContext context, int index) {
                  final data = widget.filteredData![index];
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
                    child: Container(
                      height: 45.w,
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          color: Theme.of(context).primaryColor),
                      child: TextButton(
                        onPressed: () => widget.onEntrySelected(data),
                        child: Center(
                          child: Text(
                            data.name,
                            style: widget.selectionTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
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
