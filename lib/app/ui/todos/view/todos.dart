import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app/controller/todo_controller.dart';
import 'package:ikms/app/ui/todos/widgets/todos_list.dart';
import 'package:ikms/app/ui/widgets/confirmation_dialog.dart';
import 'package:ikms/app/ui/widgets/text_form.dart';
import 'package:ikms/app/utils/responsive_utils.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  final _todoController = Get.put(TodoController());
  final _searchController = TextEditingController();
  String _searchFilter = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _initializeSearch() => _applyFilter('');

  void _applyFilter(String value) =>
      setState(() => _searchFilter = value.toLowerCase());

  void _clearSearch() {
    _searchController.clear();
    _applyFilter('');
  }

  Future<void> _showDeleteConfirmationDialog() async {
    await showDeleteConfirmation(
      context: context,
      title: 'deletedTodo',
      message: 'deletedTodoQuery',
      onConfirm: () async {
        await _todoController.deleteTodo(_todoController.selectedTodo);
        _todoController.doMultiSelectionTodoClear();
      },
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    centerTitle: true,
    leading: _todoController.isMultiSelectionTodo.isTrue
        ? IconButton(
            onPressed: _todoController.doMultiSelectionTodoClear,
            icon: const Icon(IconsaxPlusLinear.close_square, size: 20),
          )
        : null,
    title: Text(
      'todos'.tr,
      style: context.theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    actions: [
      Visibility(
        visible: _todoController.selectedTodo.isNotEmpty,
        child: IconButton(
          icon: const Icon(IconsaxPlusLinear.trash_square, size: 20),
          onPressed: _showDeleteConfirmationDialog,
        ),
      ),
    ],
  );

  Widget _buildSearchField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return MyTextForm(
      labelText: 'searchTodo'.tr,
      variant: TextFieldVariant.card,
      type: TextInputType.text,
      icon: Icon(
        IconsaxPlusLinear.search_normal_1,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
      controller: _searchController,
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 5 : 8,
      ),
      onChanged: _applyFilter,
      iconButton: _searchController.text.isNotEmpty
          ? IconButton(
              onPressed: _clearSearch,
              icon: Icon(
                IconsaxPlusLinear.close_circle,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            )
          : null,
    );
  }

  Widget _buildTabBar() => TabBar(
    controller: _tabController,
    tabAlignment: TabAlignment.start,
    isScrollable: true,
    dividerColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    overlayColor: WidgetStateProperty.all(Colors.transparent),
    tabs: [
      Tab(text: 'doing'.tr),
      Tab(text: 'done'.tr),
    ],
  );

  Widget _buildTabContent() => Expanded(
    child: Padding(
      padding: const EdgeInsets.only(top: 5),
      child: TabBarView(
        controller: _tabController,
        children: [
          TodosList(done: false, searchTodo: _searchFilter),
          TodosList(done: true, searchTodo: _searchFilter),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Obx(
    () => PopScope(
      canPop: _todoController.isPop.value,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_todoController.isMultiSelectionTodo.isTrue) {
          _todoController.doMultiSelectionTodoClear();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(context),
            _buildTabBar(),
            _buildTabContent(),
          ],
        ),
      ),
    ),
  );
}
