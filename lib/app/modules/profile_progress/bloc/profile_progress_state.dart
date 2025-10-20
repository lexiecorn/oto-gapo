import 'package:equatable/equatable.dart';

/// Profile field that can be completed
enum ProfileField {
  firstName,
  lastName,
  memberNumber,
  contactNumber,
  profileImage,
  middleName,
  bloodType,
  driversLicenseNumber,
  emergencyContactName,
}

/// Suggestion for profile completion
class ProfileSuggestion extends Equatable {
  const ProfileSuggestion({
    required this.field,
    required this.title,
    required this.description,
    this.priority = 1,
  });

  final ProfileField field;
  final String title;
  final String description;
  final int priority; // 1 = high, 2 = medium, 3 = low

  @override
  List<Object?> get props => [field, title, description, priority];
}

/// State for profile completion tracking
class ProfileProgressState extends Equatable {
  const ProfileProgressState({
    this.completionPercentage = 0.0,
    this.completedFields = const [],
    this.missingFields = const [],
    this.suggestions = const [],
  });

  final double completionPercentage;
  final List<ProfileField> completedFields;
  final List<ProfileField> missingFields;
  final List<ProfileSuggestion> suggestions;

  bool get isFullyCompleted => completionPercentage >= 100.0;
  bool get hasOptionalFields => missingFields.length < ProfileField.values.length;

  ProfileProgressState copyWith({
    double? completionPercentage,
    List<ProfileField>? completedFields,
    List<ProfileField>? missingFields,
    List<ProfileSuggestion>? suggestions,
  }) {
    return ProfileProgressState(
      completionPercentage: completionPercentage ?? this.completionPercentage,
      completedFields: completedFields ?? this.completedFields,
      missingFields: missingFields ?? this.missingFields,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  @override
  List<Object?> get props => [
        completionPercentage,
        completedFields,
        missingFields,
        suggestions,
      ];
}
