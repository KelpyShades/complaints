import 'package:flutter/material.dart' hide Scaffold;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart' show Scaffold;

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(resetPasswordProvider.notifier)
        .execute(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      NotificationService.showSuccess(
        context,
        'Password reset email sent. Check your inbox.',
      );
      context.go(AppRoutes.login);
    } else {
      final error = ref.read(resetPasswordProvider).error;
      NotificationService.showError(
        context,
        error?.toString() ?? 'Failed to send reset email.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(resetPasswordProvider);
    final isLoading = resetState.isLoading;
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
                  Icon(
                    LucideIcons.keyRound,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Reset Password',
                    style: theme.textTheme.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your email and we'll send you a reset link",
                    style: theme.textTheme.muted,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  ShadInputFormField(
                    id: 'forgot-email',
                    controller: _emailController,
                    placeholder: const Text('Email'),
                    leading: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(LucideIcons.mail, size: 16),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 24),

                  ShadButton(
                    onPressed: isLoading ? null : _submit,
                    leading: isLoading
                        ? const SizedBox.square(
                            dimension: 16,
                            child: ShadProgress(),
                          )
                        : null,
                    child: Text(isLoading ? 'Sending...' : 'Send Reset Link'),
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: ShadButton.link(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('Back to Sign In'),
                    ),
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
