import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:otogapo/app/modules/profile_progress/bloc/profile_progress_state.dart';

/// Cubit for managing profile completion progress
class ProfileProgressCubit extends Cubit<ProfileProgressState> {
  ProfileProgressCubit() : super(const ProfileProgressState());

  /// Calculate completion based on user data
  void calculateCompletion(User user) {
    final completedFields = <ProfileField>[];
    final missingFields = <ProfileField>[];

    // Check required fields
    if (user.firstName.isNotEmpty) {
      completedFields.add(ProfileField.firstName);
    } else {
      missingFields.add(ProfileField.firstName);
    }

    if (user.lastName.isNotEmpty) {
      completedFields.add(ProfileField.lastName);
    } else {
      missingFields.add(ProfileField.lastName);
    }

    if (user.memberNumber.isNotEmpty) {
      completedFields.add(ProfileField.memberNumber);
    } else {
      missingFields.add(ProfileField.memberNumber);
    }

    if (user.contactNumber.isNotEmpty) {
      completedFields.add(ProfileField.contactNumber);
    } else {
      missingFields.add(ProfileField.contactNumber);
    }

    // Check optional fields
    if (user.profileImage != null && user.profileImage!.isNotEmpty) {
      completedFields.add(ProfileField.profileImage);
    } else {
      missingFields.add(ProfileField.profileImage);
    }

    if (user.middleName != null && user.middleName!.isNotEmpty) {
      completedFields.add(ProfileField.middleName);
    } else {
      missingFields.add(ProfileField.middleName);
    }

    if (user.bloodType != null && user.bloodType!.isNotEmpty) {
      completedFields.add(ProfileField.bloodType);
    } else {
      missingFields.add(ProfileField.bloodType);
    }

    if (user.driversLicenseNumber != null &&
        user.driversLicenseNumber!.isNotEmpty) {
      completedFields.add(ProfileField.driversLicenseNumber);
    } else {
      missingFields.add(ProfileField.driversLicenseNumber);
    }

    if (user.emergencyContactName != null &&
        user.emergencyContactName!.isNotEmpty) {
      completedFields.add(ProfileField.emergencyContactName);
    } else {
      missingFields.add(ProfileField.emergencyContactName);
    }

    // Calculate percentage
    final totalFields = ProfileField.values.length.toDouble();
    final completedCount = completedFields.length.toDouble();
    final percentage = (completedCount / totalFields) * 100;

    // Generate suggestions
    final suggestions = _generateSuggestions(missingFields);

    emit(
      state.copyWith(
        completionPercentage: percentage,
        completedFields: completedFields,
        missingFields: missingFields,
        suggestions: suggestions,
      ),
    );
  }

  List<ProfileSuggestion> _generateSuggestions(
      List<ProfileField> missingFields,) {
    final suggestions = <ProfileSuggestion>[];

    for (final field in missingFields) {
      switch (field) {
        case ProfileField.profileImage:
          suggestions.add(
            const ProfileSuggestion(
              field: ProfileField.profileImage,
              title: 'Add Profile Photo',
              description:
                  'Help others recognize you by adding a profile photo',
            ),
          );

        case ProfileField.contactNumber:
          suggestions.add(
            const ProfileSuggestion(
              field: ProfileField.contactNumber,
              title: 'Add Contact Number',
              description: 'Stay connected with other members',
              priority: 2,
            ),
          );

        case ProfileField.memberNumber:
          suggestions.add(
            const ProfileSuggestion(
              field: ProfileField.memberNumber,
              title: 'Member Number Missing',
              description: 'Contact admin to get your member number assigned',
            ),
          );

        case ProfileField.middleName:
          suggestions.add(
            const ProfileSuggestion(
              field: ProfileField.middleName,
              title: 'Add Middle Name',
              description: 'Complete your full name information',
              priority: 3,
            ),
          );

        case ProfileField.bloodType:
          suggestions.add(
            const ProfileSuggestion(
              field: ProfileField.bloodType,
              title: 'Add Blood Type',
              description: 'Important for emergency situations',
              priority: 2,
            ),
          );

        case ProfileField.driversLicenseNumber:
          suggestions.add(
            const ProfileSuggestion(
              field: ProfileField.driversLicenseNumber,
              title: "Add Driver's License",
              description: 'Complete your driving credentials',
              priority: 2,
            ),
          );

        case ProfileField.emergencyContactName:
          suggestions.add(
            const ProfileSuggestion(
              field: ProfileField.emergencyContactName,
              title: 'Add Emergency Contact',
              description: 'Important for safety and emergencies',
            ),
          );

        default:
          break;
      }
    }

    // Sort by priority
    suggestions.sort((a, b) => a.priority.compareTo(b.priority));

    return suggestions;
  }

  /// Get missing fields
  List<ProfileField> getMissingFields() {
    return state.missingFields;
  }

  /// Get suggestions
  List<ProfileSuggestion> getSuggestions() {
    return state.suggestions;
  }
}
