import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/profile_progress/bloc/profile_progress_cubit.dart';
import 'package:otogapo/app/modules/profile_progress/bloc/profile_progress_state.dart';

/// Widget that displays profile completion progress and suggestions
class ProfileCompletionCard extends StatelessWidget {
  const ProfileCompletionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileProgressCubit, ProfileProgressState>(
      builder: (context, state) {
        // Hide completely if fully completed
        if (state.isFullyCompleted) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: EdgeInsets.all(16.sp),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      size: 28.sp,
                      color: _getProgressColor(state.completionPercentage),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Complete Your Profile',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${state.completionPercentage.toInt()}% Complete',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.completionPercentage > 80)
                      Icon(
                        Icons.celebration,
                        color: Colors.amber,
                        size: 24.sp,
                      )
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .scale(
                            duration: 1000.ms,
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.1, 1.1),
                          ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: state.completionPercentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(state.completionPercentage),
                    ),
                    minHeight: 8.h,
                  ),
                ),
                if (state.suggestions.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'Suggestions:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...state.suggestions.take(3).map(
                        (suggestion) => _buildSuggestionItem(
                          context,
                          suggestion,
                        ),
                      ),
                ],
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(
              begin: -0.2,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOut,
            );
      },
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    ProfileSuggestion suggestion,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: _getPriorityColor(suggestion.priority).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getSuggestionIcon(suggestion.field),
              size: 14.sp,
              color: _getPriorityColor(suggestion.priority),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  suggestion.description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 12.sp,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getSuggestionIcon(ProfileField field) {
    switch (field) {
      case ProfileField.profileImage:
        return Icons.add_a_photo;
      case ProfileField.contactNumber:
        return Icons.phone;
      case ProfileField.firstName:
      case ProfileField.lastName:
      case ProfileField.middleName:
        return Icons.person;
      case ProfileField.memberNumber:
        return Icons.badge;
      case ProfileField.bloodType:
        return Icons.bloodtype;
      case ProfileField.driversLicenseNumber:
        return Icons.credit_card;
      case ProfileField.emergencyContactName:
        return Icons.emergency;
    }
  }
}
