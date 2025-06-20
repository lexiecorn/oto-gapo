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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
                        // This will rebuild the widget and retry the stream
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final docs = snapshot.data?.docs ?? [];
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

              // Create user data with document ID included
              final userData = Map<String, dynamic>.from(data ?? {});
              userData['id'] = doc.id; // Add the document ID

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(name.isEmpty ? '(No Name)' : name),
                subtitle: Text(email),
                trailing: Text(displayMemberNumber),
                onTap: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserDetailPage(
                        userData: userData,
                        onUserDeleted: () {
                          // This callback will be called when user is deleted
                          print('User deleted callback triggered'); // Debug log
                        },
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
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
