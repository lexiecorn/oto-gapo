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
      final DocumentSnapshot userDoc = await  usersRef.doc(uid).get();

      if (userDoc.exists) {
        // final currentUser = my_auth_repo.User.fromDoc(userDoc);
        final currentUser = my_auth_repo.User.fromDoc(userDoc,uid);
        return currentUser;
      }

      throw ProfileFailure(
        code: '',
        message: 'User not found',
        plugin: '',
      );
    } on FirebaseException catch (e) {
      throw ProfileFailure(
        code: e.code,
        message: e.message!,
        plugin: e.plugin,
      );
    } catch (e) {
      throw ProfileFailure(
        code: 'Exception',
        message: e.toString(),
        plugin: 'flutter_error/server_error',
      );
    }
  }
}
