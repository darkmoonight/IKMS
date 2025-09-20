import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/ui/widgets/list_empty.dart';
import 'package:ikms/app/ui/widgets/shimmer.dart';
import 'package:ikms/app/ui/widgets/text_form.dart';

class SelectionList<T extends SelectionData> extends StatefulWidget {
  final String headerText;
  final String labelText;
  final Function(String)? onTextChanged;
  final bool isLoaded;
  final bool isError;
  final List<T> data;
  final Function(T) onEntrySelected;
  final Function()? onBackPressed;
  final Widget? emptyStateWidget;

  const SelectionList({
    super.key,
    required this.headerText,
    required this.labelText,
    required this.isLoaded,
    required this.isError,
    required this.onEntrySelected,
    required this.data,
    this.onTextChanged,
    this.onBackPressed,
    this.emptyStateWidget,
  });

  @override
  State<SelectionList<T>> createState() => _SelectionListState<T>();
}

class _SelectionListState<T extends SelectionData>
    extends State<SelectionList<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      titleSpacing: 0,
      leading: widget.onBackPressed == null
          ? null
          : IconButton(
              onPressed: widget.onBackPressed,
              icon: const Icon(IconsaxPlusLinear.arrow_left_3, size: 20),
            ),
      title: Text(
        widget.headerText,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    if (widget.onTextChanged == null) return const SizedBox();

    return MyTextForm(
      onChanged: widget.onTextChanged,
      labelText: widget.labelText,
      type: TextInputType.text,
      icon: const Icon(IconsaxPlusLinear.search_normal_1, size: 18),
      iconButton: _searchController.text.isNotEmpty
          ? IconButton(
              onPressed: () {
                _searchController.clear();
                widget.onTextChanged?.call('');
                _searchFocusNode.requestFocus();
              },
              icon: const Icon(Icons.close, color: Colors.grey, size: 20),
            )
          : null,
      controller: _searchController,
      focusNode: _searchFocusNode,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return const MyShimmer(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          height: 60,
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: context.theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'error_loading_data'.tr,
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () {}, child: Text('try_again'.tr)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (widget.emptyStateWidget != null) {
      return widget.emptyStateWidget!;
    }

    return ListEmpty(
      img: 'assets/images/search.png',
      text: 'no_items_found'.tr,
    );
  }

  Widget _buildListItem(T item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        splashColor: Colors.transparent,
        onTap: () => widget.onEntrySelected(item),
        title: Text(
          item.name,
          style: context.textTheme.labelLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (!widget.isLoaded) {
      return _buildShimmerLoader();
    }

    if (widget.isError) {
      return _buildErrorState();
    }

    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: widget.data.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildListItem(widget.data[index], index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchField(),
            if (_buildSearchField() != const SizedBox()) const Divider(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }
}
