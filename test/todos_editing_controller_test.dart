import 'package:flutter_test/flutter_test.dart';
import 'package:ikms/features/todos/presentation/widgets/todos_editing_controller.dart';

void main() {
  test('create form can compose when title and discipline are set', () {
    final controller = TodosEditingController('', '', null);
    addTearDown(controller.dispose);

    expect(controller.canCompose.value, isFalse);

    controller.title.value = 'Homework';
    expect(controller.canCompose.value, isFalse);

    controller.discipline.value = 'Math';
    expect(controller.canCompose.value, isTrue);
    expect(controller.hasChanges.value, isTrue);
  });

  test('edit form requires a change before compose', () {
    final controller = TodosEditingController('Homework', '', 'Math');
    addTearDown(controller.dispose);

    expect(controller.canCompose.value, isFalse);
    expect(controller.hasChanges.value, isFalse);

    controller.title.value = 'Homework 2';
    expect(controller.hasChanges.value, isTrue);
    expect(controller.canCompose.value, isTrue);
  });

  test('markCurrentAsInitial clears dirty after async hydrate', () {
    final controller = TodosEditingController('Homework', '', null);
    addTearDown(controller.dispose);

    controller.time.value = 'Mon, Oct 18, 2026 10:00';
    controller.discipline.value = 'Math';
    expect(controller.hasChanges.value, isTrue);

    controller.markCurrentAsInitial();
    expect(controller.hasChanges.value, isFalse);
    expect(controller.canCompose.value, isFalse);
  });
}
