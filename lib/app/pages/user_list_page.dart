import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otogapo/app/pages/user_detail_page.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  bool _isMigrating = false;
  int _refreshCounter = 0; // Add refresh counter to force stream rebuild
  Stream<QuerySnapshot>? _userStream;
  bool _useStream = true; // Flag to switch between stream and one-time query

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    _userStream = FirebaseFirestore.instance.collection('users').snapshots();
    _useStream = true;
  }

  void _refreshStream() {
    setState(() {
      _refreshCounter++;
      _initializeStream();
    });
  }

  void _switchToQuery() {
    setState(() {
      _useStream = false;
    });
  }

  Future<void> _refreshAuthentication() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Only reload the user profile, don't force token refresh
        await currentUser.reload();

        print('User profile refreshed successfully');

        // Refresh the stream after profile refresh
        _refreshStream();
      }
    } catch (e) {
      print('Error refreshing user profile: $e');
      // If profile refresh fails, try switching to query mode
      _switchToQuery();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User List'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Please sign in to view users'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        centerTitle: true,
        actions: [
          if (!_isMigrating)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshStream,
              tooltip: 'Refresh List',
            ),
          if (!_isMigrating)
            IconButton(
              icon: const Icon(Icons.update),
              onPressed: _migrateExistingUsers,
              tooltip: 'Migrate existing users',
            ),
        ],
      ),
      body: _useStream && _userStream != null
          ? StreamBuilder<QuerySnapshot>(
              stream: _userStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  // Check if it's a permission error
                  final error = snapshot.error.toString();
                  final isPermissionError = error.contains('permission-denied') ||
                      error.contains('permission') ||
                      error.contains('PERMISSION_DENIED');

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isPermissionError ? Icons.security : Icons.error,
                            size: 64, color: isPermissionError ? Colors.orange : Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          isPermissionError
                              ? 'Permission Error: Unable to access user data'
                              : 'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        if (isPermissionError) ...[
                          const Text(
                            'This might be due to recent changes. Please try refreshing.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                        ],
                        ElevatedButton(
                          onPressed: _refreshStream,
                          child: const Text('Retry Stream'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _refreshAuthentication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Refresh Auth'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _switchToQuery,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Use One-Time Query'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Force refresh by navigating away and back
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const UserListPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Refresh Page'),
                        ),
                      ],
                    ),
                  );
                }
                return _buildUserList(snapshot.data?.docs ?? []);
              },
            )
          : FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('users').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Retry the query
                            });
                          },
                          child: const Text('Retry'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _refreshStream,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Switch to Stream'),
                        ),
                      ],
                    ),
                  );
                }
                return _buildUserList(snapshot.data?.docs ?? []);
              },
            ),
    );
  }

  void _migrateExistingUsers() async {
    setState(() {
      _isMigrating = true;
    });

    try {
      // Show confirmation dialog
      final shouldMigrate = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Migrate Existing Users'),
            content: const Text(
              'This will add createdAt and updatedAt fields to existing users that don\'t have them. '
              'This action cannot be undone. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Migrate'),
              ),
            ],
          );
        },
      );

      if (shouldMigrate != true) {
        setState(() {
          _isMigrating = false;
        });
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Migrating users...'),
            ],
          ),
        ),
      );

      // Get all users
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      int migratedCount = 0;

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();

        // Check if user needs migration
        if (data['createdAt'] == null || data['updatedAt'] == null) {
          final updateData = <String, dynamic>{};

          if (data['createdAt'] == null) {
            updateData['createdAt'] = FieldValue.serverTimestamp();
          }

          if (data['updatedAt'] == null) {
            updateData['updatedAt'] = FieldValue.serverTimestamp();
          }

          await FirebaseFirestore.instance.collection('users').doc(doc.id).update(updateData);
          migratedCount++;
        }
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Migration completed! $migratedCount users updated.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Migration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isMigrating = false;
      });
    }
  }

  Widget _buildUserList(List<DocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const Center(child: Text('No users found.'));
    }
    return ListView.separated(
      itemCount: docs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>?;
        final firstName = (data?['firstName'] ?? '').toString();
        final lastName = (data?['lastName'] ?? '').toString();
        final name = '$firstName $lastName'.trim();
        final email = (data?['email'] ?? '').toString();
        final memberNumber = (data?['memberNumber'] ?? '').toString();
        final displayMemberNumber = memberNumber == '31' ? 'OM-31' : memberNumber;

        // Format creation date
        String creationDate = 'Unknown';
        if (data?['createdAt'] != null) {
          final createdAt = data!['createdAt'];
          if (createdAt is Timestamp) {
            final date = createdAt.toDate();
            creationDate = '${date.day}/${date.month}/${date.year}';
          }
        }

        // Create user data with document ID included
        final userData = Map<String, dynamic>.from(data ?? {});
        userData['id'] = doc.id; // Add the document ID

        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(name.isEmpty ? '(No Name)' : name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(email),
              Text(
                'Created: $creationDate',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          trailing: Text(displayMemberNumber),
          onTap: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserDetailPage(
                  userData: userData,
                ),
              ),
            );

            // Check if user was deleted (result will be 'deleted')
            if (result == 'deleted' && mounted) {
              print('User was deleted, showing success message'); // Debug log
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User deleted successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );

              // Refresh the stream to show updated list
              _refreshStream();
            } else if (result != null && result.toString().startsWith('error:') && mounted) {
              // Handle error result
              final errorMessage = result.toString().substring(6); // Remove 'error: ' prefix
              print('User deletion failed: $errorMessage'); // Debug log
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete user: $errorMessage'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                ),
              );
            }
          },
        );
      },
    );
  }
}
