import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/meetings/bloc/meeting_cubit.dart'
    as meeting_cubit;
import 'package:otogapo/models/meeting.dart';
import 'package:qr_flutter/qr_flutter.dart';

@RoutePage(name: 'MeetingQRCodePageRouter')
class MeetingQRCodePage extends StatelessWidget {
  const MeetingQRCodePage({
    required this.meeting,
    super.key,
  });

  final Meeting meeting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting QR Code'),
      ),
      body: BlocBuilder<meeting_cubit.MeetingCubit, meeting_cubit.MeetingState>(
        builder: (context, state) {
          final currentMeeting = state.selectedMeeting ?? meeting;

          if (!currentMeeting.hasQRCode || !currentMeeting.isQRCodeValid) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 64.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'QR Code Not Active',
                    style: theme.textTheme.titleLarge,
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      'Generate a QR code to allow members to check in',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  ElevatedButton.icon(
                    onPressed:
                        state.status == meeting_cubit.MeetingStatus.submitting
                            ? null
                            : () {
                                context
                                    .read<meeting_cubit.MeetingCubit>()
                                    .generateQRCode(currentMeeting.id);
                              },
                    icon: const Icon(Icons.qr_code_2),
                    label:
                        state.status == meeting_cubit.MeetingStatus.submitting
                            ? const Text('Generating...')
                            : const Text('Generate QR Code'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                // Meeting Info
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentMeeting.title,
                          style: theme.textTheme.headlineSmall,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          currentMeeting.formattedDate,
                          style: theme.textTheme.bodyLarge,
                        ),
                        if (currentMeeting.location != null) ...[
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: 4.w),
                              Text(currentMeeting.location!),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // QR Code
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: currentMeeting.qrCodeToken!,
                    version: QrVersions.auto,
                    size: 280.w,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 24.h),

                // Instructions
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Instructions',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        _InstructionItem(
                          number: 1,
                          text: 'Display this QR code at the meeting venue',
                        ),
                        _InstructionItem(
                          number: 2,
                          text: 'Members scan the code to mark attendance',
                        ),
                        _InstructionItem(
                          number: 3,
                          text: 'QR code expires after the meeting',
                        ),
                        if (currentMeeting.qrCodeExpiry != null) ...[
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 20.sp,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Expires: ${currentMeeting.qrCodeExpiry!.hour.toString().padLeft(2, '0')}:'
                                    '${currentMeeting.qrCodeExpiry!.minute.toString().padLeft(2, '0')}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Regenerate Button
                OutlinedButton.icon(
                  onPressed:
                      state.status == meeting_cubit.MeetingStatus.submitting
                          ? null
                          : () {
                              showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Regenerate QR Code?'),
                                  content: const Text(
                                    'This will create a new QR code and invalidate the current one.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Regenerate'),
                                    ),
                                  ],
                                ),
                              ).then((confirmed) {
                                if (confirmed == true && context.mounted) {
                                  context
                                      .read<meeting_cubit.MeetingCubit>()
                                      .generateQRCode(currentMeeting.id);
                                }
                              });
                            },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Regenerate QR Code'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  const _InstructionItem({
    required this.number,
    required this.text,
  });

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}
