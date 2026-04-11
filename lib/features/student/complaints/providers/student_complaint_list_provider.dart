import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../complaints/models/complaint_model.dart';
import '../../dashboard/providers/student_dashboard_provider.dart';

final studentComplaintStatusFilterProvider =
    StateProvider<ComplaintStatus?>((ref) => null);

final studentFilteredComplaintsProvider =
    Provider<AsyncValue<List<ComplaintModel>>>((ref) {
      final complaintsAsync = ref.watch(studentRawComplaintsProvider);
      final statusFilter = ref.watch(studentComplaintStatusFilterProvider);

      return complaintsAsync.whenData((complaints) {
        // filter out resolved/rejected first if we are in the "Complaints" tab
        final activeOnes =
            complaints.where(
              (c) =>
                  c.status == ComplaintStatus.pending ||
                  c.status == ComplaintStatus.inProgress,
            );

        if (statusFilter != null) {
          return activeOnes.where((c) => c.status == statusFilter).toList();
        }
        return activeOnes.toList();
      });
    });

final studentActiveComplaintsProvider =
    Provider<AsyncValue<List<ComplaintModel>>>((ref) {
      final complaintsAsync = ref.watch(studentRawComplaintsProvider);
      return complaintsAsync.whenData((complaints) {
        return complaints
            .where(
              (c) =>
                  c.status == ComplaintStatus.pending ||
                  c.status == ComplaintStatus.inProgress,
            )
            .toList();
      });
    });

final studentHistoryComplaintsProvider =
    Provider<AsyncValue<List<ComplaintModel>>>((ref) {
      final complaintsAsync = ref.watch(studentRawComplaintsProvider);
      return complaintsAsync.whenData((complaints) {
        return complaints
            .where(
              (c) =>
                  c.status == ComplaintStatus.resolved ||
                  c.status == ComplaintStatus.rejected,
            )
            .toList();
      });
    });
