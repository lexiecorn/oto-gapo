import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/social_feed/bloc/feed_cubit.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo/app/widgets/post_card_widget.dart';
import 'package:otogapo/app/widgets/report_dialog_widget.dart';
import 'package:otogapo/models/post.dart';
import 'package:otogapo/models/post_reaction.dart';
import 'package:otogapo/models/post_report.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/services/sync_service.dart';

@RoutePage(name: 'SocialFeedPageRouter')
class SocialFeedPage extends StatefulWidget {
  const SocialFeedPage({super.key});

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late FeedCubit _feedCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Get current user ID
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';

    // Initialize feed cubit
    _feedCubit = FeedCubit(
      pocketBaseService: PocketBaseService(),
      currentUserId: currentUserId,
      syncService: SyncService(),
    );

    // Load initial feed
    _feedCubit.loadFeed();

    // Listen to tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          _feedCubit.loadFeed(refresh: true);
        } else {
          _feedCubit.loadUserPosts(currentUserId);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _feedCubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _feedCubit.loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';

    return BlocProvider<FeedCubit>.value(
      value: _feedCubit,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            // Compact TabBar at top of body
            Container(
              padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                dividerColor: Colors.transparent,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
                tabs: [
                  Tab(
                    text: 'Feed',
                    icon: Icon(Icons.home, size: 24.sp),
                  ),
                  Tab(
                    text: 'My Posts',
                    icon: Icon(Icons.person, size: 24.sp),
                  ),
                ],
              ),
            ),
            // Feed Content
            Expanded(
              child: BlocBuilder<FeedCubit, FeedState>(
                builder: (context, state) {
                  if (state.status == FeedStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == FeedStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64.sp,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Error loading feed',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          if (state.errorMessage != null) ...[
                            SizedBox(height: 8.h),
                            Text(
                              state.errorMessage!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () => _feedCubit.loadFeed(refresh: true),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.posts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 64.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No posts yet',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Be the first to share something!',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => _feedCubit.loadFeed(refresh: true),
                    child: AnimationLimiter(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h,),
                        itemCount: state.hasMore
                            ? state.posts.length + 1
                            : state.posts.length,
                        itemBuilder: (context, index) {
                          if (index >= state.posts.length) {
                            return Padding(
                              padding: EdgeInsets.all(16.h),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final post = state.posts[index];
                          final userReaction = state.userReactions[post.id];

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50,
                              child: FadeInAnimation(
                                child: PostCardWidget(
                                  post: post,
                                  currentUserId: currentUserId,
                                  userReaction: userReaction,
                                  onReactionTap: () =>
                                      _showReactionPicker(context, post.id),
                                  onCommentTap: () async {
                                    await context.router.push(
                                        PostDetailPageRouter(postId: post.id),);
                                    // Refresh post after returning from detail page
                                    _feedCubit.refreshPost(post.id);
                                  },
                                  onUserTap: () {
                                    // Navigate to user's profile page
                                    context.router.push(
                                      ProfilePageRouter(userId: post.userId),
                                    );
                                  },
                                  onImageTap: () async {
                                    await context.router.push(
                                        PostDetailPageRouter(postId: post.id),);
                                    // Refresh post after returning from detail page
                                    _feedCubit.refreshPost(post.id);
                                  },
                                  onHashtagTap: (hashtag) {
                                    context.router.push(
                                      HashtagPostsPageRouter(hashtag: hashtag),
                                    );
                                  },
                                  onMentionTap: (mention) {
                                    // TODO: Navigate to user profile
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Mentioned: @$mention'),),
                                    );
                                  },
                                  onMoreTap: () =>
                                      _showPostOptions(context, post),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await context.router.push(const CreatePostPageRouter());
            // Refresh feed after returning from create post
            _feedCubit.loadFeed(refresh: true);
          },
          child: const Icon(Icons.add_photo_alternate),
        ),
      ),
    );
  }

  Future<void> _showReactionPicker(BuildContext context, String postId) async {
    final feedCubit = context.read<FeedCubit>();
    final currentReaction = feedCubit.state.userReactions[postId];

    final result = await showModalBottomSheet<ReactionType>(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'React to this post',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ReactionType.values.map((reaction) {
                  final isSelected = currentReaction?.reactionType == reaction;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(reaction),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(reaction.emoji,
                              style: TextStyle(fontSize: 28.sp),),
                          SizedBox(height: 4.h),
                          Text(
                            reaction.displayName,
                            style: TextStyle(fontSize: 10.sp),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      await feedCubit.toggleReaction(postId, result);
    }
  }

  Future<void> _showReportDialog(BuildContext context, String postId) async {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ReportDialogWidget(),
    );

    if (result != null && context.mounted) {
      final pocketBaseService = PocketBaseService();
      try {
        await pocketBaseService.reportPost(
          postId: postId,
          userId: currentUserId,
          reportReason: (result['reason'] as ReportReason).value,
          reportDetails: result['details'] as String?,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post reported successfully'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _showPostOptions(BuildContext context, Post post) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';
    final isOwner = post.userId == currentUserId;
    final isAdmin = authState.user?.data['membership_type'] == 1 ||
        authState.user?.data['membership_type'] == 2;

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOwner) ...[
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text(
                    'Delete Post',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Delete Post',
                          style: TextStyle(fontSize: 18.sp),
                        ),
                        content: Text(
                          'Are you sure you want to delete this post?',
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
                      await context.read<FeedCubit>().deletePost(post.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post deleted')),
                        );
                      }
                    }
                  },
                ),
              ],
              if (!isOwner && !isAdmin)
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: Text(
                    'Report Post',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _showReportDialog(context, post.id);
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
}
