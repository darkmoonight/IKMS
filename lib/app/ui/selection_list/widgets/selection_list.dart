import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/ui/widgets/list_empty.dart';
import 'package:ikms/app/ui/widgets/shimmer.dart';
import 'package:ikms/app/ui/widgets/text_form.dart';
import 'package:ikms/app/utils/responsive_utils.dart';

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

  PreferredSizeWidget _buildAppBar() => AppBar(
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

  Widget _buildSearchField(BuildContext context) {
    if (widget.onTextChanged == null) return const SizedBox();

    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return MyTextForm(
      onChanged: widget.onTextChanged,
      labelText: widget.labelText,
      variant: TextFieldVariant.card,
      type: TextInputType.text,
      icon: Icon(
        IconsaxPlusLinear.search_normal_1,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
      iconButton: _searchController.text.isNotEmpty
          ? IconButton(
              onPressed: () {
                _searchController.clear();
                widget.onTextChanged?.call('');
                _searchFocusNode.requestFocus();
              },
              icon: Icon(
                IconsaxPlusLinear.close_circle,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            )
          : null,
      controller: _searchController,
      focusNode: _searchFocusNode,
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 5 : 8,
      ),
    );
  }

  Widget _buildShimmerLoader() => ListView.builder(
    itemCount: 10,
    itemBuilder: (BuildContext context, int index) => Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const MyShimmer(height: 36, width: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: const [
                  MyShimmer(height: 14, width: 120),
                  MyShimmer(height: 12, width: 180),
                ],
              ),
            ),
            const MyShimmer(height: 18, width: 18),
          ],
        ),
      ),
    ),
  );

  Widget _buildErrorState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 60,
          color: context.theme.colorScheme.error,
        ),
        const Gap(16),
        Text(
          'error_loading_data'.tr,
          style: context.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const Gap(8),
        ElevatedButton(onPressed: () {}, child: Text('try_again'.tr)),
      ],
    ),
  );

  Widget _buildEmptyState() {
    if (widget.emptyStateWidget != null) {
      return widget.emptyStateWidget!;
    }

    return ListEmpty(
      img: 'assets/images/search.png',
      text: 'no_items_found'.tr,
    );
  }

  Widget _buildListItem(T item, int index) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: ListTile(
      onTap: () => widget.onEntrySelected(item),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          _getIconForItem(item),
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          size: 18,
        ),
      ),
      title: Text(
        item.name,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: item.description.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            )
          : null,
      trailing: Icon(
        IconsaxPlusLinear.arrow_right_3,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 18,
      ),
    ),
  );

  IconData _getIconForItem(T item) {
    if (item is GroupSchedule) return IconsaxPlusLinear.people;
    if (item is TeacherSchedule) return IconsaxPlusLinear.user;
    if (item is AudienceSchedule) return IconsaxPlusLinear.buildings_2;
    return IconsaxPlusLinear.tag;
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
      itemBuilder: (BuildContext context, int index) =>
          _buildListItem(widget.data[index], index),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _buildAppBar(),
    body: SafeArea(
      child: Column(
        children: [
          _buildSearchField(context),
          if (_buildSearchField(context) != const SizedBox()) const Divider(),
          Expanded(child: _buildContent()),
        ],
      ),
    ),
  );
}
