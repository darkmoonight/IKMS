import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app/controller/todo_controller.dart';
import 'package:ikms/app/ui/todos/widgets/todos_list.dart';
import 'package:ikms/app/ui/widgets/text_form.dart';

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

  Future<void> _showDeleteConfirmationDialog() async =>
      await showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog.adaptive(
          title: Text('deletedTodo'.tr, style: context.textTheme.titleLarge),
          content: Text(
            'deletedTodoQuery'.tr,
            style: context.textTheme.titleMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'cancel'.tr,
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.blueAccent,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _todoController.deleteTodo(_todoController.selectedTodo);
                _todoController.doMultiSelectionTodoClear();
                Get.back();
              },
              child: Text(
                'delete'.tr,
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      );

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

  Widget _buildSearchField() => MyTextForm(
    labelText: 'searchTodo'.tr,
    type: TextInputType.text,
    icon: const Icon(IconsaxPlusLinear.search_normal_1, size: 18),
    controller: _searchController,
    margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
    onChanged: _applyFilter,
    iconButton: _searchController.text.isNotEmpty
        ? IconButton(
            onPressed: _clearSearch,
            icon: const Icon(
              IconsaxPlusLinear.close_circle,
              color: Colors.grey,
              size: 20,
            ),
          )
        : null,
  );

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
          children: [_buildSearchField(), _buildTabBar(), _buildTabContent()],
        ),
      ),
    ),
  );
}
