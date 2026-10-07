import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikms/core/di/context_extensions.dart';
import 'package:ikms/core/di/providers.dart';
import 'package:ikms/core/services/notification_service.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/i18n/tr.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Single todo row with checkbox, discipline, and deadline chip.
class TodosCard extends ConsumerStatefulWidget {
  /// Creates a todo card for [todo].
  const TodosCard({
    super.key,
    required this.todo,
    required this.onLongPress,
    required this.onTap,
  });

  /// Todo shown by this card.
  final Todos todo;

  /// Long-press handler (typically starts multi-select).
  final VoidCallback onLongPress;

  /// Tap handler (edit or toggle selection).
  final VoidCallback onTap;

  @override
  ConsumerState<TodosCard> createState() => _TodosCardState();
}

class _TodosCardState extends ConsumerState<TodosCard> {
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays > 7) {
      return DateFormat(
        'dd MMM, HH:mm',
        context.appLocale.languageCode,
      ).format(date);
    } else if (diff.inDays > 0) {
      return '${'through'.tr} ${diff.inDays} ${'days_short'.tr}';
    } else if (diff.inHours > 0) {
      return '${'through'.tr} ${diff.inHours} ${'hours_short'.tr}';
    } else if (diff.inMinutes > 0) {
      return '${'through'.tr} ${diff.inMinutes} ${'minutes_short'.tr}';
    } else {
      return 'overdue'.tr;
    }
  }

  Color _getDeadlineColor(Todos todo) {
    if (todo.done) return Theme.of(context).colorScheme.onSurfaceVariant;
    if (todo.todoCompletedTime == null) {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }

    final diff = todo.todoCompletedTime!.difference(DateTime.now());
    if (diff.inDays < 1) {
      return Theme.of(context).colorScheme.error;
    } else if (diff.inDays < 3) {
      return Theme.of(context).colorScheme.tertiary;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoNotifierProvider);
    final isSelected =
        todoState.isMultiSelectionTodo &&
        todoState.selectedTodo.contains(widget.todo);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Card(
        shape: isSelected
            ? RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: widget.todo.done,
                shape: const CircleBorder(),
                onChanged: _handleCheckboxChanged,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      widget.todo.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: widget.todo.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.todo.discipline,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.todo.todoCompletedTime != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _getDeadlineColor(widget.todo) ==
                                      Theme.of(context).colorScheme.error
                                  ? Theme.of(context).colorScheme.errorContainer
                                  : Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatDate(widget.todo.todoCompletedTime),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        _getDeadlineColor(widget.todo) ==
                                            Theme.of(context).colorScheme.error
                                        ? Theme.of(context)
                                              .colorScheme
                                              .onErrorContainer
                                        : Theme.of(context)
                                              .colorScheme
                                              .onTertiaryContainer,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCheckboxChanged(bool? value) async {
    if (value == null) return;

    setState(() => widget.todo.done = value);

    final plugin = ref.read(notificationsPluginProvider);
    if (value) {
      await plugin.cancel(id: widget.todo.id);
    } else {
      final deadline = widget.todo.todoCompletedTime;
      if (deadline != null && deadline.isAfter(DateTime.now())) {
        await NotificationShow(plugin).showNotification(
          widget.todo.id,
          widget.todo.name,
          widget.todo.discipline,
          deadline,
        );
      }
    }

    if (!mounted) return;
    await ref.read(todoNotifierProvider.notifier).updateTodoCheck(widget.todo);
  }
}
