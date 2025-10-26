import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/social_feed/bloc/comment_cubit.dart';
import 'package:otogapo/app/modules/social_feed/bloc/feed_cubit.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo/models/post.dart';
import 'package:otogapo/models/post_comment.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/utils/text_parsing_utils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:timeago/timeago.dart' as timeago;

@RoutePage(name: 'PostDetailPageRouter')
class PostDetailPage extends StatefulWidget {
  const PostDetailPage({
    @PathParam('postId') required this.postId,
    super.key,
  });

  final String postId;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late FeedCubit _feedCubit;
  late CommentCubit _commentCubit;
  final _commentController = TextEditingController();
  Post? _post;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';

    _feedCubit = FeedCubit(
      pocketBaseService: PocketBaseService(),
      currentUserId: currentUserId,
    );

    _commentCubit = CommentCubit(
      pocketBaseService: PocketBaseService(),
      currentUserId: currentUserId,
    );

    _loadPost();
    _commentCubit.loadComments(widget.postId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _feedCubit.close();
    _commentCubit.close();
    super.dispose();
  }

  Future<void> _loadPost() async {
    try {
      final pocketBaseService = PocketBaseService();
      final record = await pocketBaseService.getPost(widget.postId);
      setState(() {
        _post = Post.fromRecord(record);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading post: $e')),
        );
      }
    }
  }

  Future<void> _addComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    try {
      await _commentCubit.addComment(widget.postId, commentText);
      _commentController.clear();

      // Update local post comment count immediately
      if (_post != null) {
        setState(() {
          _post = _post!.copyWith(
            commentsCount: _post!.commentsCount + 1,
          );
        });
      }

      // Refresh post to update comment count
      await _feedCubit.refreshPost(widget.postId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding comment: $e')),
        );
      }
    }
  }

  void _showFullImage() {
    if (_post == null) return;

    final pocketBaseService = PocketBaseService();
    final imageUrl =
        '${pocketBaseService.baseUrl}/api/files/posts/${_post!.id}/${_post!.imageUrl}';

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: const Center(child: Text('Post not found')),
      );
    }

    final pocketBaseService = PocketBaseService();
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider<FeedCubit>.value(value: _feedCubit),
        BlocProvider<CommentCubit>.value(value: _commentCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User header
                    ListTile(
                      leading: GestureDetector(
                        onTap: () => _navigateToUserProfile(_post!.userId),
                        child: CircleAvatar(
                          backgroundImage: _post!.userProfileImage != null &&
                                  _post!.userProfileImage!.isNotEmpty
                              ? CachedNetworkImageProvider(
                                  '${pocketBaseService.baseUrl}/api/files/users/${_post!.userId}/${_post!.userProfileImage}',
                                )
                              : null,
                          child: _post!.userProfileImage == null ||
                                  _post!.userProfileImage!.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                      ),
                      title: GestureDetector(
                        onTap: () => _navigateToUserProfile(_post!.userId),
                        child: Text(
                          _post!.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: Text(timeago.format(_post!.createdAt)),
                    ),

                    // Post image (if available)
                    if (_post!.imageUrl.isNotEmpty)
                      GestureDetector(
                        onTap: _showFullImage,
                        child: CachedNetworkImage(
                          imageUrl:
                              '${pocketBaseService.baseUrl}/api/files/posts/${_post!.id}/${_post!.imageUrl}',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 300.h,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),

                    // Reactions bar
                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        children: [
                          Icon(Icons.thumb_up, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            '${_post!.likesCount} reactions',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),

                    // Caption
                    if (_post!.caption != null && _post!.caption!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: RichText(
                          text:
                              TextParsingUtils.parseTextWithMentionsAndHashtags(
                            _post!.caption!,
                            baseStyle: TextStyle(
                              fontSize: 14.sp,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),

                    Divider(height: 24.h),

                    // Comments section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'Comments (${_post!.commentsCount})',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Comments list
                    BlocBuilder<CommentCubit, CommentState>(
                      builder: (context, state) {
                        if (state.status == CommentStatus.loading) {
                          return Padding(
                            padding: EdgeInsets.all(24.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (state.comments.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.all(24.h),
                            child: Center(
                              child: Text(
                                'No comments yet. Be the first to comment!',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.comments.length,
                          itemBuilder: (context, index) {
                            final comment = state.comments[index];

                            return ListTile(
                              leading: GestureDetector(
                                onTap: () =>
                                    _navigateToUserProfile(comment.userId),
                                child: CircleAvatar(
                                  radius: 16.r,
                                  backgroundImage: comment.userProfileImage !=
                                              null &&
                                          comment.userProfileImage!.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          '${pocketBaseService.baseUrl}/api/files/users/${comment.userId}/${comment.userProfileImage}',
                                        )
                                      : null,
                                  child: comment.userProfileImage == null ||
                                          comment.userProfileImage!.isEmpty
                                      ? Icon(Icons.person, size: 16.sp)
                                      : null,
                                ),
                              ),
                              title: GestureDetector(
                                onTap: () =>
                                    _navigateToUserProfile(comment.userId),
                                child: Text(
                                  comment.userName,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextParsingUtils
                                        .parseTextWithMentionsAndHashtags(
                                      comment.commentText,
                                      baseStyle: TextStyle(
                                        fontSize: 13.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    timeago.format(comment.createdAt),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: comment.userId == currentUserId
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.more_vert,
                                        size: 16.sp,
                                      ),
                                      onPressed: () =>
                                          _showCommentOptions(context, comment),
                                    )
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Add comment input
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                        ),
                        maxLines: null,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _addComment,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentOptions(BuildContext context, PostComment comment) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (comment.canEdit)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(
                    'Edit Comment',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Show edit dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit feature coming soon!'),
                      ),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text(
                  'Delete Comment',
                  style: TextStyle(fontSize: 16.sp),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Delete Comment',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      content: Text(
                        'Are you sure you want to delete this comment?',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Delete',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await context
                        .read<CommentCubit>()
                        .deleteComment(comment.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Comment deleted')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16.sp),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToUserProfile(String userId) {
    // Navigate to user's profile page
    context.router.push(
      ProfilePageRouter(userId: userId),
    );
  }
}
