import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/models/post_reaction.dart';

/// Widget for picking a reaction type
class ReactionPickerWidget extends StatelessWidget {
  const ReactionPickerWidget({
    required this.currentReaction,
    required this.onReactionSelected,
    super.key,
  });

  final ReactionType? currentReaction;
  final void Function(ReactionType) onReactionSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'React to this post',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),

          // Reaction buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ReactionType.values.map((reaction) {
              final isSelected = currentReaction == reaction;

              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onReactionSelected(reaction);
                },
                borderRadius: BorderRadius.circular(30.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(isSelected ? 12.w : 8.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        reaction.emoji,
                        style: TextStyle(
                          fontSize: isSelected ? 32.sp : 28.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        reaction.displayName,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  /// Show reaction picker as bottom sheet
  static Future<ReactionType?> show(
    BuildContext context, {
    ReactionType? currentReaction,
  }) async {
    return showModalBottomSheet<ReactionType>(
      context: context,
      builder: (context) => ReactionPickerWidget(
        currentReaction: currentReaction,
        onReactionSelected: (reaction) {
          Navigator.of(context).pop(reaction);
        },
      ),
    );
  }
}
