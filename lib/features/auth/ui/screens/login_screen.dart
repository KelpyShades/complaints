import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/push_notifications/notification_service.dart';
import '../../../../core/utils/user_facing_error_message.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

/// Login screen with email and password fields.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(signInProvider.notifier)
        .execute(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      NotificationService.showSuccess(context, 'Welcome back!');
    } else {
      final error = ref.read(signInProvider).error;
      NotificationService.showError(
        context,
        error != null
            ? userFacingErrorMessage(error)
            : 'Sign in failed. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final signInState = ref.watch(signInProvider);
    final isLoading = signInState.isLoading;
    final theme = ShadTheme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Icon(
                    LucideIcons.messageSquare,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome Back',
                    style: theme.textTheme.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    style: theme.textTheme.muted,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email
                  ShadInputFormField(
                    id: 'login-email',
                    controller: _emailController,
                    placeholder: const Text('Email'),
                    leading: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(LucideIcons.mail, size: 16),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    decoration: ShadDecoration(color: theme.colorScheme.card),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  ShadInputFormField(
                    id: 'login-password',
                    controller: _passwordController,
                    placeholder: const Text('Password'),
                    leading: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(LucideIcons.lock, size: 16),
                    ),
                    decoration: ShadDecoration(color: theme.colorScheme.card),
                    obscureText: true,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 8),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: ShadButton.link(
                      onPressed: () => context.go(AppRoutes.forgotPassword),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit
                  ShadButton(
                    onPressed: isLoading ? null : _submit,
                    leading: isLoading
                        ? const SizedBox.square(
                            dimension: 16,
                            child: ShadProgress(),
                          )
                        : null,
                    child: Text(isLoading ? 'Signing in...' : 'Sign In'),
                  ),
                  const SizedBox(height: 16),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: theme.textTheme.muted,
                      ),
                      ShadButton.link(
                        onPressed: () => context.go(AppRoutes.register),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimal scaffold that works with shadcn_ui (no Material dependency).
class Scaffold extends StatelessWidget {
  const Scaffold({required this.body, super.key});
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ColoredBox(
      color: theme.colorScheme.background,
      child: SafeArea(child: body),
    );
  }
}
