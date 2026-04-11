import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_view.dart';
import 'loading_indicator.dart';

/// Generic widget that renders an [AsyncValue] with `.when()`.
///
/// Handles loading, error, and data states consistently across the app.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    required this.value,
    required this.data,
    this.onRetry,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      skipLoadingOnRefresh: true,
      skipError: true,
      loading: () => const LoadingIndicator(),
      error: (error, stackTrace) =>
          ErrorView(message: error.toString(), onRetry: onRetry),
    );
  }
}
