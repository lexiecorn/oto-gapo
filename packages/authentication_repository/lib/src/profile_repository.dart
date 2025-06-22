import 'package:authentication_repository/authentication_repository.dart' as my_auth_repo;
import 'package:authentication_repository/constants/db_constants.dart';
import 'package:authentication_repository/src/profile_failure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

///Profile Repository
class ProfileRepository {
  ///
  ProfileRepository({
    required this.firebaseFirestore,
  });

  ///
  final FirebaseFirestore firebaseFirestore;

  /// Get User Profile from firestore
  Future<my_auth_repo.User> getProfile({required String uid}) async {
    try {
      print('ProfileRepository.getProfile - UID: $uid');
      final DocumentSnapshot userDoc = await usersRef.doc(uid).get();

      print('ProfileRepository.getProfile - Document exists: ${userDoc.exists}');

      if (userDoc.exists) {
        print('ProfileRepository.getProfile - Document data: ${userDoc.data()}');
        // final currentUser = my_auth_repo.User.fromDoc(userDoc);
        final currentUser = my_auth_repo.User.fromDoc(userDoc, uid);
        print('ProfileRepository.getProfile - User created successfully');
        return currentUser;
      }

      print('ProfileRepository.getProfile - User document not found, creating basic user document');

      // Create a basic user document if it doesn't exist
      final basicUserData = {
        'firstName': 'User',
        'lastName': '',
        'gender': '',
        'memberNumber': '',
        'civilStatus': '',
        'dateOfBirth': Timestamp.now(),
        'birthplace': '',
        'nationality': '',
        'vehicle': [],
        'contactNumber': '',
        'driversLicenseExpirationDate': Timestamp.now(),
        'membership_type': 3, // Default to regular member
        'isActive': true,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      await usersRef.doc(uid).set(basicUserData);
      print('ProfileRepository.getProfile - Basic user document created');

      // Now get the created document
      final createdDoc = await usersRef.doc(uid).get();
      final currentUser = my_auth_repo.User.fromDoc(createdDoc, uid);
      print('ProfileRepository.getProfile - Basic user created successfully');
      return currentUser;
    } on FirebaseException catch (e) {
      print('ProfileRepository.getProfile - FirebaseException: $e');
      throw ProfileFailure(
        code: e.code,
        message: e.message!,
        plugin: e.plugin,
      );
    } catch (e) {
      print('ProfileRepository.getProfile - Exception: $e');
      throw ProfileFailure(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }
}
