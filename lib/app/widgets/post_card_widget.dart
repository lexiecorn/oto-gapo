import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/models/post.dart';
import 'package:otogapo/models/post_reaction.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/utils/text_parsing_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Widget for displaying a post card in the feed
class PostCardWidget extends StatelessWidget {
  const PostCardWidget({
    required this.post,
    required this.currentUserId,
    this.userReaction,
    this.onReactionTap,
    this.onCommentTap,
    this.onUserTap,
    this.onImageTap,
    this.onHashtagTap,
    this.onMentionTap,
    this.onMoreTap,
    super.key,
  });

  final Post post;
  final String currentUserId;
  final PostReaction? userReaction;
  final VoidCallback? onReactionTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onUserTap;
  final VoidCallback? onImageTap;
  final void Function(String)? onHashtagTap;
  final void Function(String)? onMentionTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final pocketBaseService = PocketBaseService();

    // Debug: Print image URL construction
    if (post.imageUrl.isNotEmpty) {
      final fullUrl =
          '${pocketBaseService.baseUrl}/api/files/posts/${post.id}/${post.imageUrl}';
      print('PostCard - Full image URL: $fullUrl');
      print('PostCard - Base URL: ${pocketBaseService.baseUrl}');
      print('PostCard - Image filename: ${post.imageUrl}');
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
            leading: GestureDetector(
              onTap: onUserTap,
              child: CircleAvatar(
                radius: 20.r,
                backgroundImage: post.userProfileImage != null &&
                        post.userProfileImage!.isNotEmpty
                    ? CachedNetworkImageProvider(
                        '${pocketBaseService.baseUrl}/api/files/users/${post.userId}/${post.userProfileImage}',
                      )
                    : null,
                child: post.userProfileImage == null ||
                        post.userProfileImage!.isEmpty
                    ? Icon(Icons.person, size: 20.sp)
                    : null,
              ),
            ),
            title: GestureDetector(
              onTap: onUserTap,
              child: Text(
                post.userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
            subtitle: Text(
              timeago.format(post.createdAt),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: onMoreTap,
            ),
          ),

          // Post image (if available)
          if (post.imageUrl.isNotEmpty && post.imageUrl != '')
            GestureDetector(
              onTap: onImageTap,
              child: CachedNetworkImage(
                imageUrl:
                    '${pocketBaseService.baseUrl}/api/files/posts/${post.id}/${post.imageUrl}?thumb=800x800',
                errorListener: (error) {
                  print('Image load error: $error');
                  print(
                      'Image URL: ${pocketBaseService.baseUrl}/api/files/posts/${post.id}/${post.imageUrl}');
                },
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 300.h,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 300.h,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            )
          else if (post.caption != null && post.caption!.isNotEmpty)
            // Text-only post - add some padding
            SizedBox(height: 8.h),

          // Action buttons (reactions, comments)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                // Reaction button
                InkWell(
                  onTap: onReactionTap,
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userReaction?.reactionType.emoji ?? '👍',
                          style: TextStyle(fontSize: 20.sp),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${post.likesCount}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: userReaction != null
                                ? Colors.blue
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.w),

                // Comment button
                InkWell(
                  onTap: onCommentTap,
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 20.sp,
                          color: Colors.grey[700],
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${post.commentsCount}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Caption with mentions and hashtags
          if (post.caption != null && post.caption!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: RichText(
                text: TextParsingUtils.parseTextWithMentionsAndHashtags(
                  post.caption!,
                  baseStyle: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  onMentionTap: onMentionTap,
                  onHashtagTap: onHashtagTap,
                ),
              ),
            ),

          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
