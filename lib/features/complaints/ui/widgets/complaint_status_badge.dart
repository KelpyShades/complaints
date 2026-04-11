import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/complaint_model.dart';

/// Colored badge showing a complaint's status.
class ComplaintStatusBadge extends StatelessWidget {
  const ComplaintStatusBadge({required this.status, super.key});

  final ComplaintStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ComplaintStatus.pending => ShadBadge.secondary(child: Text(status.label)),
      ComplaintStatus.inProgress => ShadBadge.outline(child: Text(status.label)),
      ComplaintStatus.resolved => ShadBadge(child: Text(status.label)),
      ComplaintStatus.rejected =>
        ShadBadge.destructive(child: Text(status.label)),
    };
  }
}
