import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/social_feed/bloc/feed_cubit.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo/app/widgets/post_card_widget.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/services/sync_service.dart';

@RoutePage(name: 'HashtagPostsPageRouter')
class HashtagPostsPage extends StatefulWidget {
  const HashtagPostsPage({
    @PathParam('hashtag') required this.hashtag,
    super.key,
  });

  final String hashtag;

  @override
  State<HashtagPostsPage> createState() => _HashtagPostsPageState();
}

class _HashtagPostsPageState extends State<HashtagPostsPage> {
  late FeedCubit _feedCubit;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';

    _feedCubit = FeedCubit(
      pocketBaseService: PocketBaseService(),
      currentUserId: currentUserId,
      syncService: SyncService(),
    );

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _feedCubit.loadHashtagPosts(widget.hashtag);
  }

  @override
  void dispose() {
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
        appBar: AppBar(
          title: Text('#${widget.hashtag}'),
          centerTitle: true,
        ),
        body: BlocBuilder<FeedCubit, FeedState>(
          builder: (context, state) {
            if (state.status == FeedStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.tag,
                      size: 64.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No posts with #${widget.hashtag}',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  _feedCubit.loadHashtagPosts(widget.hashtag),
              child: ListView.builder(
                controller: _scrollController,
                itemCount:
                    state.hasMore ? state.posts.length + 1 : state.posts.length,
                itemBuilder: (context, index) {
                  if (index >= state.posts.length) {
                    return Padding(
                      padding: EdgeInsets.all(16.h),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  final post = state.posts[index];
                  final userReaction = state.userReactions[post.id];

                  return PostCardWidget(
                    post: post,
                    currentUserId: currentUserId,
                    userReaction: userReaction,
                    onReactionTap: () {
                      // Show reaction picker
                    },
                    onCommentTap: () {
                      context.router
                          .push(PostDetailPageRouter(postId: post.id));
                    },
                    onUserTap: () {
                      context.router.push(
                        UserPostsPageRouter(userId: post.userId),
                      );
                    },
                    onImageTap: () {
                      context.router
                          .push(PostDetailPageRouter(postId: post.id));
                    },
                    onHashtagTap: (hashtag) {
                      if (hashtag != widget.hashtag) {
                        context.router.push(
                          HashtagPostsPageRouter(hashtag: hashtag),
                        );
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
