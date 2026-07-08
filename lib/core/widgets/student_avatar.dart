import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StudentAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;
  final bool isSelected;
  final Color? backgroundColor;

  const StudentAvatar({
    super.key,
    required this.photoUrl,
    required this.name,
    this.size = 40,
    this.isSelected = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final photo = photoUrl;

    if (photo != null && photo.isNotEmpty) {
      if (photo.length <= 4) {
        // It's an emoji (e.g. 👦, 👨‍🎓, etc.)
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor ?? (isDark ? Colors.white12 : Colors.grey[100]),
          ),
          child: Text(
            photo,
            style: TextStyle(fontSize: size * 0.55),
          ),
        );
      } else {
        // It's a network image URL
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF062A5A)
                  : (isDark ? Colors.white24 : Colors.grey.shade300),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: CachedNetworkImage(
              imageUrl: photo,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: isDark ? Colors.white12 : Colors.grey[100],
                child: const CupertinoActivityIndicator(),
              ),
              errorWidget: (context, url, error) => Container(
                color: isDark ? Colors.white12 : Colors.grey[100],
                child: Icon(
                  CupertinoIcons.person_solid,
                  size: size * 0.5,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        );
      }
    }

    // Fallback: initials
    final initials = name.isNotEmpty ? name.substring(0, 1) : '?';
    final fallbackBgColor = backgroundColor ??
        (isSelected
            ? const Color(0xFF062A5A)
            : (isDark ? Colors.white12 : const Color(0xFF062A5A).withValues(alpha: 0.1)));
    final fallbackTextColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF062A5A));

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fallbackBgColor,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: fallbackTextColor,
          fontSize: size * 0.45,
          fontWeight: FontWeight.bold,
          fontFamily: 'GoogleSans',
        ),
      ),
    );
  }
}
