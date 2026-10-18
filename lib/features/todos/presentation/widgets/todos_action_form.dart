import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/core/constants/app_constants.dart';
import 'package:ikms/core/utils/responsive_utils.dart';
import 'package:ikms/core/widgets/text_form.dart';
import 'package:ikms/features/todos/presentation/widgets/todos_editing_controller.dart';
import 'package:ikms/i18n/tr.dart';
import 'package:material_ui/material_ui.dart';

/// Form sections for the task create/edit sheet.
class TodosActionForm extends StatelessWidget {
  /// Creates the task form body.
  const TodosActionForm({
    super.key,
    required this.formKey,
    required this.padding,
    required this.isEdit,
    required this.isLoading,
    required this.titleController,
    required this.timeController,
    required this.selectedDiscipline,
    required this.disciplineList,
    required this.editingController,
    required this.onTitleChanged,
    required this.onDisciplineChanged,
    required this.onTimeTap,
    required this.onTimeCleared,
  });

  final GlobalKey<FormState> formKey;
  final double padding;
  final bool isEdit;
  final bool isLoading;
  final TextEditingController titleController;
  final TextEditingController timeController;
  final String? selectedDiscipline;
  final List<String> disciplineList;
  final TodosEditingController editingController;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String?> onDisciplineChanged;
  final VoidCallback onTimeTap;
  final VoidCallback onTimeCleared;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BasicInfoSection(
                titleController: titleController,
                isEdit: isEdit,
                onChanged: onTitleChanged,
              ),
              SizedBox(height: padding * 1.5),
              _DisciplineSection(
                isLoading: isLoading,
                selectedDiscipline: selectedDiscipline,
                disciplineList: disciplineList,
                onChanged: onDisciplineChanged,
              ),
              SizedBox(height: padding * 1.5),
              _TimeSection(
                timeController: timeController,
                onTap: onTimeTap,
                onCleared: onTimeCleared,
              ),
              SizedBox(height: padding * 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _BasicInfoSection extends StatelessWidget {
  const _BasicInfoSection({
    required this.titleController,
    required this.isEdit,
    required this.onChanged,
  });

  final TextEditingController titleController;
  final bool isEdit;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      controller: titleController,
      labelText: 'name'.tr,
      type: TextInputType.multiline,
      icon: Icon(IconsaxPlusLinear.edit, color: colorScheme.primary),
      autofocus: !isEdit,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'validateName'.tr;
        }
        return null;
      },
      maxLine: null,
    );
  }
}

class _DisciplineSection extends StatelessWidget {
  const _DisciplineSection({
    required this.isLoading,
    required this.selectedDiscipline,
    required this.disciplineList,
    required this.onChanged,
  });

  final bool isLoading;
  final String? selectedDiscipline;
  final List<String> disciplineList;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return DropdownButtonFormField<String>(
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
        color: colorScheme.onSurface,
      ),
      isExpanded: true,
      initialValue: isLoading ? null : selectedDiscipline,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 8, right: 6),
          child: IconTheme(
            data: IconThemeData(
              color: colorScheme.primary,
              size: isMobile ? 18 : 20,
            ),
            child: const Icon(IconsaxPlusLinear.book_square),
          ),
        ),
        labelText: isLoading ? 'loading'.tr : 'discipline'.tr,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        labelStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 14,
          vertical: isMobile ? 12 : 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      icon: isLoading
          ? const SizedBox(width: 24, height: 24)
          : Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                IconsaxPlusLinear.arrow_down,
                size: AppConstants.iconSizeSmall,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
      items: isLoading
          ? []
          : disciplineList
                .map(
                  (name) => DropdownMenuItem<String>(
                    value: name,
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
      onChanged: isLoading
          ? null
          : (String? newValue) {
              FocusScope.of(context).unfocus();
              onChanged(newValue);
            },
      validator: (value) {
        if (isLoading) return null;
        if (value == null) return 'validateDiscipline'.tr;
        return null;
      },
    );
  }
}

class _TimeSection extends StatelessWidget {
  const _TimeSection({
    required this.timeController,
    required this.onTap,
    required this.onCleared,
  });

  final TextEditingController timeController;
  final VoidCallback onTap;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasTime = timeController.text.isNotEmpty;

    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      readOnly: true,
      controller: timeController,
      labelText: 'timeComplete'.tr,
      type: TextInputType.datetime,
      icon: Icon(IconsaxPlusLinear.clock_1, color: colorScheme.primary),
      iconButton: hasTime
          ? IconButton(
              icon: Icon(
                IconsaxPlusLinear.close_circle,
                size: AppConstants.iconSizeSmall,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: onCleared,
            )
          : null,
      onTap: onTap,
    );
  }
}
