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
      alwaysShowMiddle: false,
      middle: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'GoogleSans',
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
