import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
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
///
/// [FlutterNativeSplash.remove] runs after the first frame so the native
/// splash (from `flutter_native_splash.yaml`) stays up during [main]'s async
/// work and until Flutter has painted the initial UI.
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
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

