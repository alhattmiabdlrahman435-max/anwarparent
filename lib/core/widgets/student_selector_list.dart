import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/children_provider.dart';
import '../models/student.dart';
import '../extensions/localization_extension.dart';

class StudentSelectorList extends ConsumerWidget {
  const StudentSelectorList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(childrenProvider);
    final currentChild = ref.watch(currentChildProvider);

    if (students.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.children,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        for (var student in students) ...[
          _buildChildSelectionCard(
            context: context,
            ref: ref,
            child: student,
            isSelected: currentChild?.id == student.id,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildChildSelectionCard({
    required BuildContext context,
    required WidgetRef ref,
    required Student child,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final primaryColor = isDark ? Colors.white : const Color(0xFF062A5A);

    return GestureDetector(
      onTap: () {
        ref.read(currentChildProvider.notifier).setChild(child);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.08) : cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark
                    ? Colors.white12
                    : Colors.grey.withValues(alpha: 0.2)),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isDark || isSelected
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white12 : Colors.grey[100],
              ),
              child: const Icon(
                CupertinoIcons.person_solid,
                size: 20,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                child.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? primaryColor : textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
