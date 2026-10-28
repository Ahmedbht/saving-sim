import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';

/// The app's standard bordered card, with an optional title row.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: BorderSide(color: p.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: 16),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
