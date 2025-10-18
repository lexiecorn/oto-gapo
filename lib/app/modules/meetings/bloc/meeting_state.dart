part of 'meeting_cubit.dart';

enum MeetingStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  error,
}

class MeetingState extends Equatable {
  const MeetingState({
    required this.status,
    required this.meetings,
    this.selectedMeeting,
    this.errorMessage,
    this.hasMore = false,
    this.currentPage = 1,
  });

  factory MeetingState.initial() {
    return const MeetingState(
      status: MeetingStatus.initial,
      meetings: [],
    );
  }

  final MeetingStatus status;
  final List<Meeting> meetings;
  final Meeting? selectedMeeting;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  MeetingState copyWith({
    MeetingStatus? status,
    List<Meeting>? meetings,
    Meeting? selectedMeeting,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
  }) {
    return MeetingState(
      status: status ?? this.status,
      meetings: meetings ?? this.meetings,
      selectedMeeting: selectedMeeting,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        meetings,
        selectedMeeting,
        errorMessage,
        hasMore,
        currentPage,
      ];
}

