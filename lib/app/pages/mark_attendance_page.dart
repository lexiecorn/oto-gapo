import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/attendance/bloc/attendance_cubit.dart';
import 'package:otogapo/models/attendance.dart';

@RoutePage(name: 'MarkAttendancePageRouter')
class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({
    @PathParam('meetingId') required this.meetingId,
    super.key,
  });

  final String meetingId;

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  final _formKey = GlobalKey<FormState>();
  final _memberNumberController = TextEditingController();
  final _memberNameController = TextEditingController();
  final _notesController = TextEditingController();

  AttendanceStatus _selectedStatus = AttendanceStatus.present;

  @override
  void dispose() {
    _memberNumberController.dispose();
    _memberNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _markAttendance() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: Get current user ID for markedBy
    context.read<AttendanceCubit>().markAttendance(
          userId: 'temp_user_id', // Should get from context
          memberNumber: _memberNumberController.text.trim(),
          memberName: _memberNameController.text.trim(),
          meetingId: widget.meetingId,
          meetingDate: DateTime.now(), // Should get from meeting
          status: _selectedStatus.value,
          checkInMethod: 'manual',
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: BlocListener<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state.status == AttendanceStateStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Attendance marked successfully'),
              ),
            );
            context.router.maybePop();
          } else if (state.status == AttendanceStateStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(state.errorMessage ?? 'Failed to mark attendance'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // Member Number
              TextFormField(
                controller: _memberNumberController,
                decoration: const InputDecoration(
                  labelText: 'Member Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter member number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Member Name
              TextFormField(
                controller: _memberNameController,
                decoration: const InputDecoration(
                  labelText: 'Member Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter member name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Status Selection
              Text(
                'Attendance Status',
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: AttendanceStatus.values.map((status) {
                  final isSelected = status == _selectedStatus;
                  return ChoiceChip(
                    label: Text(status.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedStatus = status);
                      }
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                  hintText: 'Add any notes or comments',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24.h),

              // Submit Button
              BlocBuilder<AttendanceCubit, AttendanceState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.status == AttendanceStateStatus.submitting
                        ? null
                        : _markAttendance,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: state.status == AttendanceStateStatus.submitting
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Mark Attendance'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


