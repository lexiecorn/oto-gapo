import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/models/post_report.dart';

/// Dialog for reporting inappropriate content
class ReportDialogWidget extends StatefulWidget {
  const ReportDialogWidget({
    this.isPost = true,
    super.key,
  });

  final bool isPost;

  @override
  State<ReportDialogWidget> createState() => _ReportDialogWidgetState();
}

class _ReportDialogWidgetState extends State<ReportDialogWidget> {
  ReportReason _selectedReason = ReportReason.spam;
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Report ${widget.isPost ? "Post" : "Comment"}',
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why are you reporting this ${widget.isPost ? "post" : "comment"}?',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),

            // Reason selection
            ...ReportReason.values.map((reason) {
              return RadioListTile<ReportReason>(
                title: Text(
                  reason.displayName,
                  style: TextStyle(fontSize: 14.sp),
                ),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedReason = value;
                    });
                  }
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }),

            SizedBox(height: 16.h),

            // Additional details
            Text(
              'Additional details (optional):',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Provide more information...',
                hintStyle: TextStyle(fontSize: 14.sp),
                border: const OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'reason': _selectedReason,
              'details': _detailsController.text.trim(),
            });
          },
          child: Text(
            'Submit Report',
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ],
    );
  }
}
