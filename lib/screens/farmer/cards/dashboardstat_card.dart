import 'package:flutter/material.dart';

/// A reusable card widget for displaying dashboard statistics with icon, value, label,
/// optional badge, tooltip, progress indicator, icon background, and medal.
///
/// - [icon]: The main icon to display.
/// - [value]: The main value to highlight.
/// - [label]: The label describing the value.
/// - [color]: The primary color for the icon and progress bar.
/// - [badge]: An optional widget (e.g., notification dot) to display in the top-right.
/// - [tooltip]: Tooltip for the badge.
/// - [progress]: Optional progress value (0.0 to 1.0) for a linear indicator.
/// - [iconBackground]: Optional background color for the icon.
/// - [showMedal]: Whether to show a medal overlay on the icon.
/// - [medalColor]: The color of the medal if shown.
class DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Widget? badge;
  final String? tooltip;
  final double? progress;
  final Color? iconBackground;
  final bool showMedal;
  final Color? medalColor;

  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.badge,
    this.tooltip,
    this.progress,
    this.iconBackground,
    this.showMedal = false,
    this.medalColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      container: true,
      label: '$label: $value',
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Icon background circle
                      if (iconBackground != null)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: iconBackground,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Icon(icon, size: 32, color: color),
                      // Medal overlay
                      if (showMedal && medalColor != null)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(
                            Icons.emoji_events,
                            color: medalColor,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color.withOpacity(isDark ? 1.0 : 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress!.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        color: color,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ],
              ),
              if (badge != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: tooltip != null && tooltip!.isNotEmpty
                      ? Tooltip(
                          message: tooltip!,
                          child: badge!,
                        )
                      : badge!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}