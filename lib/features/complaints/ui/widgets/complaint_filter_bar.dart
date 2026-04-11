import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/complaint_list_provider.dart';
import '../../models/complaint_model.dart';

/// Filter bar for the complaint list — status only.
class ComplaintFilterBar extends ConsumerWidget {
  const ComplaintFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = ref.watch(complaintStatusFilterProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // "All" chip
        if (selectedStatus == null)
          ShadBadge(child: const Text('All'))
        else
          ShadButton.outline(
            onPressed: () =>
                ref.read(complaintStatusFilterProvider.notifier).state = null,
            size: ShadButtonSize.sm,
            child: const Text('All'),
          ),

        // One chip per status
        ...ComplaintStatus.values.map((s) {
          final isSelected = selectedStatus == s;
          if (isSelected) {
            return ShadBadge(child: Text(s.label));
          }
          return ShadButton.outline(
            onPressed: () =>
                ref.read(complaintStatusFilterProvider.notifier).state = s,
            size: ShadButtonSize.sm,
            child: Text(s.label),
          );
        }),
      ],
    );
  }
}
