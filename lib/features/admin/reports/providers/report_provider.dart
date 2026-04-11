import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../complaints/models/complaint_model.dart';
import '../../dashboard/providers/admin_dashboard_provider.dart';

/// Admin report provider combining filters and data.
class ReportState {
  const ReportState({
    required this.complaints,
    this.startDate,
    this.endDate,
    this.category,
  });

  final List<ComplaintModel> complaints;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? category;

  ReportState copyWith({
    List<ComplaintModel>? complaints,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearCategory = false,
  }) {
    return ReportState(
      complaints: complaints ?? this.complaints,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      category: clearCategory ? null : (category ?? this.category),
    );
  }
}

class ReportNotifier extends Notifier<ReportState> {
  @override
  ReportState build() {
    // We listen to the realtime stream.
    final asyncData = ref.watch(adminRawComplaintsProvider);
    return ReportState(
      complaints: asyncData.valueOrNull ?? [],
    );
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
      clearStartDate: start == null,
      clearEndDate: end == null,
    );
  }

  void setCategory(String? category) {
    state = state.copyWith(
      category: category,
      clearCategory: category == null,
    );
  }
}

final reportProvider = NotifierProvider<ReportNotifier, ReportState>(ReportNotifier.new);

// ── Filtered data based on ReportState ──────────────────────────────────

final filteredReportDataProvider = Provider<List<ComplaintModel>>((ref) {
  final reportState = ref.watch(reportProvider);
  
  return reportState.complaints.where((c) {
    bool matchDate = true;
    bool matchCategory = true;

    if (reportState.startDate != null && c.createdAt != null) {
      // isAfter or same day
      matchDate &= c.createdAt!.isAfter(reportState.startDate!.subtract(const Duration(days: 1)));
    }
    if (reportState.endDate != null && c.createdAt != null) {
      matchDate &= c.createdAt!.isBefore(reportState.endDate!.add(const Duration(days: 1)));
    }
    if (reportState.category != null && reportState.category!.isNotEmpty) {
      matchCategory &= c.category.toLowerCase() == reportState.category!.toLowerCase();
    }

    return matchDate && matchCategory;
  }).toList();
});
