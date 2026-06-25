import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class AdaptiveSliverAppBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool automaticallyImplyLeading;

  const AdaptiveSliverAppBar({
    super.key,
    required this.title,
    this.trailing,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverNavigationBar(
      largeTitle: Text(
        title,
        style: const TextStyle(height: 1.0, color: AppColors.textPrimaryLight),
      ),
      backgroundColor: AppColors.surfaceAltLight,
      border: null, // No bottom border for a flat look
      leading: automaticallyImplyLeading && context.canPop()
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primary,
              ),
              onPressed: () => context.pop(),
            )
          : null,
      trailing: trailing,
    );
  }
}
