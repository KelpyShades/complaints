import 'package:flutter/material.dart';

import 'package:complaints/features/student/complaints/ui/desktop/student_complaint_detail_screen.dart';
import 'package:complaints/features/student/complaints/ui/desktop/student_complaint_form_screen.dart';
import 'package:complaints/features/student/complaints/ui/desktop/student_complaints_screen.dart';
import 'package:complaints/features/student/complaints/ui/desktop/student_history_screen.dart';
import 'package:complaints/features/student/notifications/ui/desktop/student_activity_screen.dart';
import 'package:complaints/features/student/profile/ui/desktop/student_profile_screen.dart';
import 'package:complaints/features/student/notifications/ui/mobile/mobile_student_activity_screen.dart';
import 'package:complaints/features/student/complaints/ui/mobile/mobile_student_complaint_detail_screen.dart';
import 'package:complaints/features/student/complaints/ui/mobile/mobile_student_complaint_form_screen.dart';
import 'package:complaints/features/student/complaints/ui/mobile/mobile_student_complaints_screen.dart';
import 'package:complaints/features/student/complaints/ui/mobile/mobile_student_history_screen.dart';
import 'package:complaints/features/student/profile/ui/mobile/mobile_student_profile_screen.dart';

/// Must match [StudentShell] layout split.
const double kStudentShellMobileBreakpoint = 768;

bool studentShellIsMobileLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kStudentShellMobileBreakpoint;

/// Same GoRouter paths — picks mobile vs desktop implementation by width.
class StudentComplaintsRouteBody extends StatelessWidget {
  const StudentComplaintsRouteBody({super.key});

  @override
  Widget build(BuildContext context) {
    return studentShellIsMobileLayout(context)
        ? const MobileStudentComplaintsScreen()
        : const StudentComplaintsScreen();
  }
}

class StudentHistoryRouteBody extends StatelessWidget {
  const StudentHistoryRouteBody({super.key});

  @override
  Widget build(BuildContext context) {
    return studentShellIsMobileLayout(context)
        ? const MobileStudentHistoryScreen()
        : const StudentHistoryScreen();
  }
}

class StudentActivityRouteBody extends StatelessWidget {
  const StudentActivityRouteBody({super.key});

  @override
  Widget build(BuildContext context) {
    return studentShellIsMobileLayout(context)
        ? const MobileStudentActivityScreen()
        : const StudentActivityScreen();
  }
}

class StudentProfileRouteBody extends StatelessWidget {
  const StudentProfileRouteBody({super.key});

  @override
  Widget build(BuildContext context) {
    return studentShellIsMobileLayout(context)
        ? const MobileStudentProfileScreen()
        : const StudentProfileScreen();
  }
}

class StudentComplaintDetailRouteBody extends StatelessWidget {
  const StudentComplaintDetailRouteBody({required this.complaintId, super.key});

  final String complaintId;

  @override
  Widget build(BuildContext context) {
    return studentShellIsMobileLayout(context)
        ? MobileStudentComplaintDetailScreen(complaintId: complaintId)
        : StudentComplaintDetailScreen(complaintId: complaintId);
  }
}

class StudentComplaintFormRouteBody extends StatelessWidget {
  const StudentComplaintFormRouteBody({this.existingComplaintId, super.key});

  final String? existingComplaintId;

  @override
  Widget build(BuildContext context) {
    return studentShellIsMobileLayout(context)
        ? MobileStudentComplaintFormScreen(existingComplaintId: existingComplaintId)
        : StudentComplaintFormScreen(existingComplaintId: existingComplaintId);
  }
}
