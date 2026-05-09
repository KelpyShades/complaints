import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DashboardWelcomeBlock extends StatelessWidget {
  const DashboardWelcomeBlock({required this.theme, required this.name, super.key});

  final ShadThemeData theme;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 12,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Text(
              initial,
              style: theme.textTheme.large.copyWith(
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: theme.textTheme.muted.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: theme.textTheme.h4.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DashboardBentoHeroTotalCard extends StatelessWidget {
  const DashboardBentoHeroTotalCard({
    required this.theme,
    required this.total,
    this.caption = 'Lifetime submissions',
    super.key,
  });

  final ShadThemeData theme;
  final int total;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    Color.lerp(
                      theme.colorScheme.primary,
                      theme.colorScheme.accent,
                      0.35,
                    )!,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primaryForeground.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -28,
            top: -28,
            child: IgnorePointer(
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.accent.withValues(alpha: 0.22),
                ),
              ),
            ),
          ),
          Positioned(
            right: 56,
            bottom: -40,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -0.35,
                child: Container(
                  width: 100,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primaryForeground.withValues(
                        alpha: 0.14,
                      ),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All complaints',
                      style: theme.textTheme.large.copyWith(
                        color: theme.colorScheme.primaryForeground.withValues(
                          alpha: 0.92,
                        ),
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Icon(
                      LucideIcons.files,
                      size: 22,
                      color: theme.colorScheme.primaryForeground.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '$total',
                  style: theme.textTheme.h1.copyWith(
                    fontSize: 44,
                    height: 0.95,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    color: theme.colorScheme.primaryForeground,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  caption,
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.primaryForeground.withValues(
                      alpha: 0.72,
                    ),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardBentoAccentStatCard extends StatelessWidget {
  const DashboardBentoAccentStatCard({
    required this.theme,
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final ShadThemeData theme;
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: ColoredBox(
        color: theme.colorScheme.accent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -16,
              bottom: -16,
              child: Icon(
                icon,
                size: 72,
                color: theme.colorScheme.accentForeground.withValues(
                  alpha: 0.06,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      icon,
                      size: 20,
                      color: theme.colorScheme.accentForeground.withValues(
                        alpha: 0.9,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.accentForeground.withValues(
                            alpha: 0.78,
                          ),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$value',
                        style: theme.textTheme.h2.copyWith(
                          color: theme.colorScheme.accentForeground,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          height: 1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardBentoSurfaceStatCard extends StatelessWidget {
  const DashboardBentoSurfaceStatCard({
    required this.theme,
    required this.label,
    required this.caption,
    required this.value,
    required this.icon,
    super.key,
  });

  final ShadThemeData theme;
  final String label;
  final String caption;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.border),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.foreground.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, size: 18, color: theme.colorScheme.primary),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.foreground,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  caption,
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '$value',
                  style: theme.textTheme.h2.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardRecentEmptyState extends StatelessWidget {
  const DashboardRecentEmptyState({
    required this.theme,
    this.message = 'When you submit one, it will show up here.',
    super.key,
  });

  final ShadThemeData theme;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        child: Column(
          children: [
            Icon(
              LucideIcons.inbox,
              size: 40,
              color: theme.colorScheme.mutedForeground.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 12),
            Text(
              'No complaints yet',
              style: theme.textTheme.large.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.muted.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
