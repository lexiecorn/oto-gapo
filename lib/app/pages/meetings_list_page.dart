import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:otogapo/app/modules/meetings/bloc/meeting_cubit.dart' as meeting_cubit;
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo/app/widgets/meeting_card.dart';

@RoutePage(name: 'MeetingsListPageRouter')
class MeetingsListPage extends StatefulWidget {
  const MeetingsListPage({super.key});

  @override
  State<MeetingsListPage> createState() => _MeetingsListPageState();
}

class _MeetingsListPageState extends State<MeetingsListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _upcomingScrollController = ScrollController();
  final ScrollController _pastScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _upcomingScrollController.addListener(_onUpcomingScroll);
    _pastScrollController.addListener(_onPastScroll);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<meeting_cubit.MeetingCubit>().loadUpcomingMeetings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _upcomingScrollController.dispose();
    _pastScrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && context.read<meeting_cubit.MeetingCubit>().state.meetings.isEmpty) {
      context.read<meeting_cubit.MeetingCubit>().loadPastMeetings();
    }
  }

  void _onUpcomingScroll() {
    if (_upcomingScrollController.position.pixels >= _upcomingScrollController.position.maxScrollExtent * 0.9) {
      final cubit = context.read<meeting_cubit.MeetingCubit>();
      if (cubit.state.hasMore && cubit.state.status != meeting_cubit.MeetingStatus.loading) {
        cubit.loadUpcomingMeetings();
      }
    }
  }

  void _onPastScroll() {
    if (_pastScrollController.position.pixels >= _pastScrollController.position.maxScrollExtent * 0.9) {
      final cubit = context.read<meeting_cubit.MeetingCubit>();
      if (cubit.state.hasMore && cubit.state.status != meeting_cubit.MeetingStatus.loading) {
        cubit.loadPastMeetings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_tabController.index == 0) {
                context.read<meeting_cubit.MeetingCubit>().loadUpcomingMeetings();
              } else {
                context.read<meeting_cubit.MeetingCubit>().loadPastMeetings();
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Theme(
            data: Theme.of(context).copyWith(
              textTheme: Theme.of(context).textTheme.copyWith(
                    labelLarge: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white,
                        ),
                  ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white,
              unselectedLabelColor: Theme.of(context).brightness == Brightness.light ? Colors.black54 : Colors.white70,
              indicatorColor: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<meeting_cubit.MeetingCubit, meeting_cubit.MeetingState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _MeetingsList(
                scrollController: _upcomingScrollController,
                state: state,
                emptyMessage: 'No upcoming meetings',
              ),
              _MeetingsList(
                scrollController: _pastScrollController,
                state: state,
                emptyMessage: 'No past meetings',
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.router.push(const CreateMeetingPageRouter());
        },
        icon: const Icon(Icons.add),
        label: const Text('New Meeting'),
      ),
    );
  }
}

class _MeetingsList extends StatelessWidget {
  const _MeetingsList({
    required this.scrollController,
    required this.state,
    required this.emptyMessage,
  });

  final ScrollController scrollController;
  final meeting_cubit.MeetingState state;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (state.status == meeting_cubit.MeetingStatus.loading && state.meetings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == meeting_cubit.MeetingStatus.error) {
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
              'Error loading meetings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (state.errorMessage != null) ...[
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<meeting_cubit.MeetingCubit>().loadUpcomingMeetings();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.meetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<meeting_cubit.MeetingCubit>().loadUpcomingMeetings();
      },
      child: AnimationLimiter(
        child: ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.only(top: 8.h, bottom: 80.h),
          itemCount: state.meetings.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.meetings.length) {
              return Padding(
                padding: EdgeInsets.all(16.w),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final meeting = state.meetings[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: MeetingCard(
                    meeting: meeting,
                    onTap: () {
                      context.router.push(
                        MeetingDetailsPageRouter(meetingId: meeting.id),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
