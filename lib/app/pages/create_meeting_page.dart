import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/meetings/bloc/meeting_cubit.dart' as meeting_cubit;
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/models/meeting.dart';

@RoutePage(name: 'CreateMeetingPageRouter')
class CreateMeetingPage extends StatefulWidget {
  const CreateMeetingPage({super.key});

  @override
  State<CreateMeetingPage> createState() => _CreateMeetingPageState();
}

class _CreateMeetingPageState extends State<CreateMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _expectedMembersController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  MeetingType _selectedType = MeetingType.regular;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _expectedMembersController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final theme = Theme.of(context);
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              headlineLarge: theme.textTheme.headlineLarge?.copyWith(fontSize: 24.sp),
              headlineMedium: theme.textTheme.headlineMedium?.copyWith(fontSize: 20.sp),
              headlineSmall: theme.textTheme.headlineSmall?.copyWith(fontSize: 18.sp),
              titleLarge: theme.textTheme.titleLarge?.copyWith(fontSize: 16.sp),
              titleMedium: theme.textTheme.titleMedium?.copyWith(fontSize: 14.sp),
              titleSmall: theme.textTheme.titleSmall?.copyWith(fontSize: 12.sp),
              bodyLarge: theme.textTheme.bodyLarge?.copyWith(fontSize: 14.sp),
              bodyMedium: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
              bodySmall: theme.textTheme.bodySmall?.copyWith(fontSize: 12.sp),
              labelLarge: theme.textTheme.labelLarge?.copyWith(fontSize: 14.sp),
              labelMedium: theme.textTheme.labelMedium?.copyWith(fontSize: 12.sp),
              labelSmall: theme.textTheme.labelSmall?.copyWith(fontSize: 11.sp),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectStartTime() async {
    final theme = Theme.of(context);
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              headlineLarge: theme.textTheme.headlineLarge?.copyWith(fontSize: 24.sp),
              headlineMedium: theme.textTheme.headlineMedium?.copyWith(fontSize: 20.sp),
              headlineSmall: theme.textTheme.headlineSmall?.copyWith(fontSize: 18.sp),
              titleLarge: theme.textTheme.titleLarge?.copyWith(fontSize: 16.sp),
              titleMedium: theme.textTheme.titleMedium?.copyWith(fontSize: 14.sp),
              titleSmall: theme.textTheme.titleSmall?.copyWith(fontSize: 12.sp),
              bodyLarge: theme.textTheme.bodyLarge?.copyWith(fontSize: 14.sp),
              bodyMedium: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
              bodySmall: theme.textTheme.bodySmall?.copyWith(fontSize: 12.sp),
              labelLarge: theme.textTheme.labelLarge?.copyWith(fontSize: 14.sp),
              labelMedium: theme.textTheme.labelMedium?.copyWith(fontSize: 12.sp),
              labelSmall: theme.textTheme.labelSmall?.copyWith(fontSize: 11.sp),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _startTime = time);
    }
  }

  Future<void> _selectEndTime() async {
    final theme = Theme.of(context);
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              headlineLarge: theme.textTheme.headlineLarge?.copyWith(fontSize: 24.sp),
              headlineMedium: theme.textTheme.headlineMedium?.copyWith(fontSize: 20.sp),
              headlineSmall: theme.textTheme.headlineSmall?.copyWith(fontSize: 18.sp),
              titleLarge: theme.textTheme.titleLarge?.copyWith(fontSize: 16.sp),
              titleMedium: theme.textTheme.titleMedium?.copyWith(fontSize: 14.sp),
              titleSmall: theme.textTheme.titleSmall?.copyWith(fontSize: 12.sp),
              bodyLarge: theme.textTheme.bodyLarge?.copyWith(fontSize: 14.sp),
              bodyMedium: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
              bodySmall: theme.textTheme.bodySmall?.copyWith(fontSize: 12.sp),
              labelLarge: theme.textTheme.labelLarge?.copyWith(fontSize: 14.sp),
              labelMedium: theme.textTheme.labelMedium?.copyWith(fontSize: 12.sp),
              labelSmall: theme.textTheme.labelSmall?.copyWith(fontSize: 11.sp),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _endTime = time);
    }
  }

  void _createMeeting() {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a meeting date')),
      );
      return;
    }

    final profileState = context.read<ProfileCubit>().state;
    final user = profileState.user;
    if (user.uid.isEmpty) return;

    DateTime? startDateTime;
    if (_startTime != null) {
      startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
    }

    DateTime? endDateTime;
    if (_endTime != null) {
      endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );
    }

    context.read<meeting_cubit.MeetingCubit>().createMeeting(
          meetingDate: _selectedDate!,
          meetingType: _selectedType.value,
          title: _titleController.text.trim(),
          createdBy: user.uid,
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
          startTime: startDateTime,
          endTime: endDateTime,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          totalExpectedMembers: _expectedMembersController.text.trim().isEmpty
              ? null
              : int.tryParse(_expectedMembersController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Meeting'),
      ),
      body: BlocListener<meeting_cubit.MeetingCubit, meeting_cubit.MeetingState>(
        listener: (context, state) {
          if (state.status == meeting_cubit.MeetingStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meeting created successfully')),
            );
            context.router.maybePop();
          } else if (state.status == meeting_cubit.MeetingStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to create meeting'),
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
              // Title
              TextFormField(
                controller: _titleController,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: 'Meeting Title',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Meeting Type
              DropdownButtonFormField<MeetingType>(
                value: _selectedType,
                style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Meeting Type',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: MeetingType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName, style: TextStyle(fontSize: 14.sp)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              SizedBox(height: 16.h),

              // Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Meeting Date',
                    labelStyle: TextStyle(fontSize: 14.sp),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _selectedDate == null ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Start Time
              InkWell(
                onTap: _selectStartTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Start Time (Optional)',
                    labelStyle: TextStyle(fontSize: 14.sp),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.access_time),
                  ),
                  child: Text(
                    _startTime != null ? _startTime!.format(context) : 'Select time',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _startTime == null ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // End Time
              InkWell(
                onTap: _selectEndTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'End Time (Optional)',
                    labelStyle: TextStyle(fontSize: 14.sp),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.access_time),
                  ),
                  child: Text(
                    _endTime != null ? _endTime!.format(context) : 'Select time',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _endTime == null ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Location
              TextFormField(
                controller: _locationController,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: 'Location (Optional)',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: 16.h),

              // Expected Members
              TextFormField(
                controller: _expectedMembersController,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: 'Expected Members (Optional)',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),

              // Description
              TextFormField(
                controller: _descriptionController,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24.h),

              // Submit Button
              BlocBuilder<meeting_cubit.MeetingCubit, meeting_cubit.MeetingState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.status == meeting_cubit.MeetingStatus.submitting ? null : _createMeeting,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: state.status == meeting_cubit.MeetingStatus.submitting
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Create Meeting', style: TextStyle(fontSize: 16.sp)),
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
