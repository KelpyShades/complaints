import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:toastification/toastification.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';

/// Root application widget.
/// Switches between admin (dark) and student (light) themes based on the
/// resolved role — using the pre-warmed [RoleCache] so the correct theme
/// is applied on the very first frame, with no visible flicker.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return ToastificationWrapper(
      child: ShadApp.router(
        title: 'Complaints',
        theme: isAdmin ? AppTheme.admin : AppTheme.student,
        routerConfig: router,
      ),
    );
  }
}

