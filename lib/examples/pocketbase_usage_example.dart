import 'package:authentication_repository/authentication_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:pocketbase/pocketbase.dart';

/// Example usage of Firebase Auth + PocketBase integration
class PocketBaseUsageExample {
  final AuthRepository _authRepo = GetIt.instance<AuthRepository>();
  final PocketBaseService _pocketBase = GetIt.instance<PocketBaseService>();

  /// Example: Sign in and get user data
  Future<void> signInExample() async {
    try {
      // Sign in with Firebase
      final userCredential = await _authRepo.signin(
        email: 'user@example.com',
        password: 'password123',
      );

      if (userCredential?.user != null) {
        print('Firebase user: ${userCredential!.user!.email}');

        // Get user data from PocketBase
        final userData = await _authRepo.getCurrentUserData();
        if (userData != null) {
          print('PocketBase user data: ${userData.data}');
          print('User is admin: ${userData.data['isAdmin']}');
          print('User member number: ${userData.data['memberNumber']}');
        }
      }
    } catch (e) {
      print('Sign in error: $e');
    }
  }

  /// Example: Update user profile
  Future<void> updateProfileExample() async {
    try {
      // Update user data in PocketBase
      await _authRepo.updateUserData({
        'firstName': 'John',
        'lastName': 'Doe',
        'contactNumber': '09123456789',
        'age': '30',
        'bloodType': 'O+',
        'vehicle': [
          {
            'color': 'Red',
            'make': 'Toyota',
            'model': 'Vios',
            'plateNumber': 'ABC123',
            'type': 'Sedan',
            'year': 2023,
          }
        ]
      });

      print('Profile updated successfully');
    } catch (e) {
      print('Update error: $e');
    }
  }

  /// Example: Get announcements
  Future<void> getAnnouncementsExample() async {
    try {
      final announcements = await _authRepo.getAnnouncements();

      for (final announcement in announcements) {
        print('Title: ${announcement.data['title']}');
        print('Content: ${announcement.data['content']}');
        print('Created: ${announcement.data['created']}');
        print('---');
      }
    } catch (e) {
      print('Get announcements error: $e');
    }
  }

  /// Example: Get app configuration
  Future<void> getAppConfigExample() async {
    try {
      final appVersion = await _authRepo.getAppData('app_version');
      if (appVersion != null) {
        print('App version: ${appVersion.data['value']}');
      }

      final maintenanceMode = await _authRepo.getAppData('maintenance_mode');
      if (maintenanceMode != null) {
        print('Maintenance mode: ${maintenanceMode.data['value']}');
      }
    } catch (e) {
      print('Get app config error: $e');
    }
  }

  /// Example: Create announcement (admin only)
  Future<void> createAnnouncementExample() async {
    try {
      final userData = await _authRepo.getCurrentUserData();
      if (userData?.data['isAdmin'] == true) {
        await _pocketBase.createAnnouncement(
          title: 'New Feature Released!',
          content: 'We have added new features to the app. Check them out!',
          authorId: userData!.id,
          type: 'feature',
        );
        print('Announcement created successfully');
      } else {
        print('Only admins can create announcements');
      }
    } catch (e) {
      print('Create announcement error: $e');
    }
  }

  /// Example: Real-time updates
  void setupRealtimeExample() {
    // Subscribe to user updates
    _pocketBase.subscribeToUsers((RecordModel record) {
      print('User updated: ${record.data['firstName']} ${record.data['lastName']}');
    });

    // Subscribe to announcements
    _pocketBase.subscribeToAnnouncements((RecordModel record) {
      print('New announcement: ${record.data['title']}');
    });
  }

  /// Example: Get all users (admin only)
  Future<void> getAllUsersExample() async {
    try {
      final userData = await _authRepo.getCurrentUserData();
      if (userData?.data['isAdmin'] == true) {
        final users = await _pocketBase.getAllUsers();

        for (final user in users) {
          print('User: ${user.data['firstName']} ${user.data['lastName']}');
          print('Email: ${user.data['email']}');
          print('Member #: ${user.data['memberNumber']}');
          print('Active: ${user.data['isActive']}');
          print('---');
        }
      } else {
        print('Only admins can view all users');
      }
    } catch (e) {
      print('Get all users error: $e');
    }
  }
}
