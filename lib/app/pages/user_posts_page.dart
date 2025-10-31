import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/social_feed/bloc/feed_cubit.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/services/sync_service.dart';

@RoutePage(name: 'UserPostsPageRouter')
class UserPostsPage extends StatefulWidget {
  const UserPostsPage({
    @PathParam('userId') required this.userId,
    super.key,
  });

  final String userId;

  @override
  State<UserPostsPage> createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  late FeedCubit _feedCubit;
  String _userName = '';

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

    _feedCubit.loadUserPosts(widget.userId);
    _loadUserName();
  }

  @override
  void dispose() {
    _feedCubit.close();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    try {
      final pocketBaseService = PocketBaseService();
      final userRecord = await pocketBaseService.getUser(widget.userId);
      if (userRecord != null && mounted) {
        final firstName = userRecord.data['firstName'] as String? ?? '';
        final lastName = userRecord.data['lastName'] as String? ?? '';
        setState(() {
          _userName = '$firstName $lastName'.trim();
        });
      }
    } catch (e) {
      print('Error loading user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pocketBaseService = PocketBaseService();

    return BlocProvider<FeedCubit>.value(
      value: _feedCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_userName.isNotEmpty ? _userName : 'User Posts'),
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
                      Icons.grid_view_outlined,
                      size: 64.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    const Text('No posts yet'),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: EdgeInsets.all(2.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2.w,
                mainAxisSpacing: 2.h,
              ),
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];

                return GestureDetector(
                  onTap: () {
                    context.router.push(PostDetailPageRouter(postId: post.id));
                  },
                  child: CachedNetworkImage(
                    imageUrl:
                        '${pocketBaseService.baseUrl}/api/files/posts/${post.id}/${post.imageUrl}?thumb=400x400',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
