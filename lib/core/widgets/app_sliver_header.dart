import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/children_provider.dart';
import '../models/student.dart';
import '../extensions/localization_extension.dart';
import 'student_avatar.dart';

class AppSliverHeader extends ConsumerWidget {
  final String title;
  final Widget? trailing;
  final bool automaticallyImplyLeading;
  final bool showChildSwitcher;

  const AppSliverHeader({
    super.key,
    required this.title,
    this.trailing,
    this.automaticallyImplyLeading = false,
    this.showChildSwitcher = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final currentChild = ref.watch(currentChildProvider);
    final children = ref.watch(childrenProvider);


    Widget header = CupertinoSliverNavigationBar(
      backgroundColor: bgColor.withValues(alpha: 0.8),
      border: null, // Removes bottom border
      alwaysShowMiddle: false,
      middle: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'GoogleSans',
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      largeTitle: Text(
        title,
        style: TextStyle(
          fontFamily: 'GoogleSans',
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: automaticallyImplyLeading && Navigator.of(context).canPop()
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
            )
          : Builder(
              builder: (context) => CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(CupertinoIcons.bars, color: textColor, size: 34),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showChildSwitcher && children.length > 1)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () =>
                  _showChildSelector(context, ref, children, currentChild),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFF062A5A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentChild != null
                          ? context
                                .translateMock(currentChild.name)
                                .split(' ')
                                .first
                          : context.loc.selectChild,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF062A5A),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'GoogleSans',
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.chevron_down,
                      size: 14,
                      color: isDark ? Colors.white : const Color(0xFF062A5A),
                    ),
                  ],
                ),
              ),
            ),
          if (trailing != null) ...[
            if (showChildSwitcher && children.length > 1)
              const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );

    return header;
  }

  void _showChildSelector(
    BuildContext context,
    WidgetRef ref,
    List<Student> children,
    Student? currentChild,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

        return Container(
          decoration: BoxDecoration(
            color: sheetColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  context.loc.selectChild,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'GoogleSans',
                  ),
                ),
                const SizedBox(height: 16),
                ...children.map((child) {
                  final isSelected = child.id == currentChild?.id;
                  return ListTile(
                    leading: StudentAvatar(
                      photoUrl: child.photoUrl,
                      name: child.name,
                      size: 36,
                      isSelected: isSelected,
                    ),
                    title: Text(
                      context.translateMock(child.name),
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: textColor,
                        fontFamily: 'GoogleSans',
                      ),
                    ),
                    subtitle: Text(
                      context.translateMock(child.grade),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: 'GoogleSans',
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            CupertinoIcons.check_mark_circled_solid,
                            color: Color(0xFF062A5A),
                          )
                        : null,
                    onTap: () {
                      ref.read(currentChildProvider.notifier).setChild(child);
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
