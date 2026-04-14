import 'package:complaints/features/auth/providers/auth_provider.dart';
import 'package:complaints/features/student/complaints/providers/student_complaint_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/shared/complaints/models/complaint_model.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/complaint_card.dart';

class MobileStudentComplaintsScreen extends ConsumerWidget {
  const MobileStudentComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final statsAsync = ref.watch(studentDashboardStatsProvider);
    final rawAsync = ref.watch(studentRawComplaintsProvider);

    return ColoredBox(
      color: theme.colorScheme.background,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WelcomeBlock(
                theme: theme,
                name: currentUser?.fullName ?? 'Student',
              ),
              const SizedBox(height: 28),
              AsyncValueWidget<StudentDashboardStats>(
                value: statsAsync,
                onRetry: () => ref.invalidate(studentRawComplaintsProvider),
                data: (stats) {
                  final open = stats.pending + stats.inProgress;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _BentoHeroTotalCard(theme: theme, total: stats.total),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 158,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _BentoAccentStatCard(
                                theme: theme,
                                label: 'Resolved',
                                value: stats.resolved,
                                icon: LucideIcons.circleCheck,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _BentoSurfaceStatCard(
                                theme: theme,
                                label: 'Open',
                                caption: 'Pending & in progress',
                                value: open,
                                icon: LucideIcons.clock,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  'RECENT',
                  style: theme.textTheme.small.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 1.05,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AsyncValueWidget<List<ComplaintModel>>(
                value: rawAsync,
                onRetry: () => ref.invalidate(studentRawComplaintsProvider),
                data: (complaints) {
                  final recent = complaints.take(5).toList();
                  if (recent.isEmpty) {
                    return _RecentEmptyState(theme: theme);
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < recent.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        ComplaintCard(
                          complaint: recent[i],
                          onTap: () => context.go(
                            AppRoutes.studentComplaintDetailPath(
                              recent[i].id,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeBlock extends StatelessWidget {
  const _WelcomeBlock({required this.theme, required this.name});

  final ShadThemeData theme;
  final String name;

  @override
  Widget build(BuildContext context) {
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
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Center(
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: theme.textTheme.large.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
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

class _BentoHeroTotalCard extends StatelessWidget {
  const _BentoHeroTotalCard({required this.theme, required this.total});

  final ShadThemeData theme;
  final int total;

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
                  'Lifetime submissions',
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

class _BentoAccentStatCard extends StatelessWidget {
  const _BentoAccentStatCard({
    required this.theme,
    required this.label,
    required this.value,
    required this.icon,
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

class _BentoSurfaceStatCard extends StatelessWidget {
  const _BentoSurfaceStatCard({
    required this.theme,
    required this.label,
    required this.caption,
    required this.value,
    required this.icon,
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

class _RecentEmptyState extends StatelessWidget {
  const _RecentEmptyState({required this.theme});

  final ShadThemeData theme;

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
              'When you submit one, it will show up here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.muted.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
