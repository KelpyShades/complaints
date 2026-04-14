import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/push_notifications/notification_service.dart';
import '../../../../core/utils/user_facing_error_message.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart' show Scaffold;

/// Registration screen with name, email, password, and confirm password.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(signUpProvider.notifier)
        .execute(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      NotificationService.showSuccess(context, 'Account created successfully!');
    } else {
      final error = ref.read(signUpProvider).error;
      NotificationService.showError(
        context,
        error != null
            ? userFacingErrorMessage(error)
            : 'Sign up failed. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpProvider);
    final isLoading = signUpState.isLoading;
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
                    LucideIcons.userPlus,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create Account',
                    style: theme.textTheme.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in your details to get started',
                    style: theme.textTheme.muted,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  ShadInputFormField(
                    id: 'register-name',
                    controller: _nameController,
                    decoration: ShadDecoration(color: theme.colorScheme.card),
                    placeholder: const Text('Full Name'),
                    leading: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(LucideIcons.user, size: 16),
                    ),
                    validator: (v) => Validators.required(v, 'Full name'),
                  ),
                  const SizedBox(height: 16),

                  ShadInputFormField(
                    id: 'register-email',
                    controller: _emailController,
                    placeholder: const Text('Email'),
                    leading: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(LucideIcons.mail, size: 16),
                    ),
                    decoration: ShadDecoration(color: theme.colorScheme.card),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),

                  ShadInputFormField(
                    id: 'register-password',
                    controller: _passwordController,
                    placeholder: const Text('Password'),
                    decoration: ShadDecoration(color: theme.colorScheme.card),
                    leading: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(LucideIcons.lock, size: 16),
                    ),
                    obscureText: true,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 16),

                  ShadInputFormField(
                    id: 'register-confirm-password',
                    controller: _confirmPasswordController,
                    placeholder: const Text('Confirm Password'),
                    leading: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(LucideIcons.lock, size: 16),
                    ),
                    decoration: ShadDecoration(color: theme.colorScheme.card),
                    obscureText: true,
                    validator: (v) =>
                        Validators.confirmPassword(v, _passwordController.text),
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
                    child: Text(isLoading ? 'Creating account...' : 'Sign Up'),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: theme.textTheme.muted,
                      ),
                      ShadButton.link(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text('Sign In'),
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
