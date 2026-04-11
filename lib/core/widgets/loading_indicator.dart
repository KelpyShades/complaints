import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Centered circular loading spinner.
class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({this.size = 32, super.key});

  final double size;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.rotate(
            angle: _controller.value * 2 * 3.14159,
            child: child,
          ),
          child: Icon(
            LucideIcons.loader,
            size: widget.size,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
