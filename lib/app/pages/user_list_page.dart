import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:otogapo/app/pages/user_detail_page.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  bool _isMigrating = false;
  int _refreshCounter = 0;
  Stream<QuerySnapshot>? _userStream;
  bool _useStream = true;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;

    // Split the text into words
    final words = text.trim().split(' ');

    // Capitalize each word
    final titleCaseWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();

    // Join the words back together
    return titleCaseWords.join(' ');
  }

  Future<String?> _getProfileImageUrl(String userId) async {
    try {
      // Check if user has a profile image URL stored
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = userDoc.data();

      if (userData != null && userData['profile_image'] != null) {
        final profileImage = userData['profile_image'].toString();

        // If it's a gs:// URI, get the download URL
        if (profileImage.startsWith('gs://')) {
          final ref = FirebaseStorage.instance.refFromURL(profileImage);
          return await ref.getDownloadURL();
        } else if (profileImage.isNotEmpty) {
          // It might be a pre-fetched HTTPS URL
          return profileImage;
        }
      }

      // Try to get the default profile image path
      final defaultImageRef = FirebaseStorage.instance.ref().child('users/$userId/images/profile.png');
      return await defaultImageRef.getDownloadURL();
    } catch (e) {
      // Return null if image doesn't exist or there's an error
      return null;
    }
  }

  List<DocumentSnapshot> _filterUsers(List<DocumentSnapshot> docs) {
    if (_searchQuery.isEmpty) return docs;

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return false;

      final firstName = (data['firstName'] ?? '').toString().toLowerCase();
      final lastName = (data['lastName'] ?? '').toString().toLowerCase();
      final email = (data['email'] ?? '').toString().toLowerCase();
      final memberNumber = (data['memberNumber'] ?? '').toString().toLowerCase();

      return firstName.contains(_searchQuery) ||
          lastName.contains(_searchQuery) ||
          email.contains(_searchQuery) ||
          memberNumber.contains(_searchQuery);
    }).toList();
  }

  Future<void> _refreshAuthentication() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.reload();
        print('User profile refreshed successfully');
        _refreshStream();
      }
    } catch (e) {
      print('Error refreshing user profile: $e');
      _switchToQuery();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDark ? colorScheme.surface : Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'User List',
            style: TextStyle(
              color: isDark ? colorScheme.onSurface : Colors.black87,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? colorScheme.surface : Colors.white,
          foregroundColor: isDark ? colorScheme.onSurface : Colors.black87,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64.sp, color: isDark ? colorScheme.onSurface.withOpacity(0.6) : Colors.grey[400]),
              SizedBox(height: 16.sp),
              Text(
                'Please sign in to view users',
                style: TextStyle(
                    fontSize: 16.sp, color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'User List',
          style: TextStyle(
            color: isDark ? colorScheme.onSurface : Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        foregroundColor: isDark ? colorScheme.onSurface : Colors.black87,
        actions: [
          if (!_isMigrating)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: isDark ? colorScheme.onSurface : Colors.black87,
              ),
              onPressed: _refreshStream,
              tooltip: 'Refresh List',
            ),
          if (!_isMigrating)
            IconButton(
              icon: Icon(
                Icons.update,
                color: isDark ? colorScheme.onSurface : Colors.black87,
              ),
              onPressed: _migrateExistingUsers,
              tooltip: 'Migrate existing users',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.sp),
            color: isDark ? colorScheme.surface : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surfaceVariant : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.sp),
                      border: isDark ? Border.all(color: colorScheme.outline.withOpacity(0.2)) : null,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? colorScheme.onSurface : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[400],
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: isDark ? colorScheme.onSurface.withOpacity(0.6) : Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.sp,
                          vertical: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, color: isDark ? colorScheme.onSurface.withOpacity(0.6) : Colors.grey[600]),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: _useStream && _userStream != null
                ? StreamBuilder<QuerySnapshot>(
                    stream: _userStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(isDark ? colorScheme.primary : Colors.blue),
                              ),
                              SizedBox(height: 16.sp),
                              Text(
                                'Loading users...',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        final error = snapshot.error.toString();
                        final isPermissionError = error.contains('permission-denied') ||
                            error.contains('permission') ||
                            error.contains('PERMISSION_DENIED');

                        return _buildErrorWidget(isPermissionError, error);
                      }

                      final filteredDocs = _filterUsers(snapshot.data?.docs ?? []);
                      return _buildUserList(filteredDocs);
                    },
                  )
                : FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance.collection('users').get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(isDark ? colorScheme.primary : Colors.blue),
                              ),
                              SizedBox(height: 16.sp),
                              Text(
                                'Loading users...',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return _buildErrorWidget(false, snapshot.error.toString());
                      }

                      final filteredDocs = _filterUsers(snapshot.data?.docs ?? []);
                      return _buildUserList(filteredDocs);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(bool isPermissionError, String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.sp),
              decoration: BoxDecoration(
                color: isPermissionError
                    ? (isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.withOpacity(0.1))
                    : (isDark ? Colors.red.withOpacity(0.2) : Colors.red.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(16.sp),
                border: isDark
                    ? Border.all(
                        color: isPermissionError ? Colors.orange.withOpacity(0.3) : Colors.red.withOpacity(0.3))
                    : null,
              ),
              child: Icon(
                isPermissionError ? Icons.security : Icons.error,
                size: 48.sp,
                color: isPermissionError ? Colors.orange : Colors.red,
              ),
            ),
            SizedBox(height: 16.sp),
            Text(
              isPermissionError ? 'Permission Error' : 'Error Loading Users',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isPermissionError ? Colors.orange : Colors.red,
              ),
            ),
            SizedBox(height: 8.sp),
            Text(
              isPermissionError ? 'Unable to access user data. This might be due to recent changes.' : error,
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 14.sp, color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600]),
            ),
            SizedBox(height: 24.sp),
            Wrap(
              spacing: 8.sp,
              runSpacing: 8.sp,
              children: [
                ElevatedButton.icon(
                  onPressed: _refreshStream,
                  icon: Icon(Icons.refresh, size: 16.sp),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? colorScheme.primary : Colors.blue,
                    foregroundColor: isDark ? colorScheme.onPrimary : Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _refreshAuthentication,
                  icon: Icon(Icons.autorenew, size: 16.sp),
                  label: Text('Refresh Auth'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _switchToQuery,
                  icon: Icon(Icons.query_stats, size: 16.sp),
                  label: Text('Use Query'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(List<DocumentSnapshot> docs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
              size: 64.sp,
              color: isDark ? colorScheme.onSurface.withOpacity(0.6) : Colors.grey[400],
            ),
            SizedBox(height: 16.sp),
            Text(
              _searchQuery.isNotEmpty ? 'No users found matching "$_searchQuery"' : 'No users found',
              style: TextStyle(
                fontSize: 16.sp,
                color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              SizedBox(height: 8.sp),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
                child: Text(
                  'Clear search',
                  style: TextStyle(
                    color: isDark ? colorScheme.primary : Colors.blue,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8.sp),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>?;
        final firstName = (data?['firstName'] ?? '').toString();
        final lastName = (data?['lastName'] ?? '').toString();
        final fullName = '$firstName $lastName'.trim();
        final titleCaseName = _toTitleCase(fullName);
        final displayName = titleCaseName.isEmpty ? '(no_name)' : titleCaseName;
        final email = (data?['email'] ?? '').toString();
        final memberNumber = (data?['memberNumber'] ?? '').toString();
        final displayMemberNumber = memberNumber == '${memberNumber}' ? 'OM-${memberNumber}' : memberNumber;

        String creationDate = 'Unknown';
        if (data?['createdAt'] != null) {
          final createdAt = data!['createdAt'];
          if (createdAt is Timestamp) {
            final date = createdAt.toDate();
            creationDate = '${date.day}/${date.month}/${date.year}';
          }
        }

        final userData = Map<String, dynamic>.from(data ?? {});
        userData['id'] = doc.id;

        return Container(
          margin: EdgeInsets.only(bottom: 8.sp),
          child: Card(
            elevation: isDark ? 0 : 2,
            color: isDark ? colorScheme.surfaceVariant : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserDetailPage(userData: userData),
                  ),
                );

                if (result == 'deleted' && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8.sp),
                          Text('User deleted successfully'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  _refreshStream();
                } else if (result != null && result.toString().startsWith('error:') && mounted) {
                  final errorMessage = result.toString().substring(6);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 8.sp),
                          Text('Failed to delete user: $errorMessage'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(12.sp),
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48.sp,
                      height: 48.sp,
                      decoration: BoxDecoration(
                        color: isDark ? colorScheme.primary.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24.sp),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.sp),
                        child: FutureBuilder<String?>(
                          future: _getProfileImageUrl(doc.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                color: isDark ? colorScheme.primary.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                child: Center(
                                  child: SizedBox(
                                    width: 16.sp,
                                    height: 16.sp,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(isDark ? colorScheme.primary : Colors.blue),
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Container(
                                color: isDark ? Colors.red.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                child: Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 20.sp,
                                ),
                              );
                            }
                            if (snapshot.hasData && snapshot.data != null) {
                              return Image.network(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: isDark ? colorScheme.primary.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                    child: Icon(
                                      Icons.person,
                                      color: isDark ? colorScheme.primary : Colors.blue,
                                      size: 24.sp,
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: isDark ? colorScheme.primary.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                    child: Center(
                                      child: SizedBox(
                                        width: 16.sp,
                                        height: 16.sp,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(isDark ? colorScheme.primary : Colors.blue),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                            return Container(
                              color: isDark ? colorScheme.primary.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                color: isDark ? colorScheme.primary : Colors.blue,
                                size: 24.sp,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 16.sp),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark ? colorScheme.onSurface : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.sp),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4.sp),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.sp,
                                  vertical: 2.sp,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.green.withOpacity(0.2) : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.sp),
                                  border: isDark ? Border.all(color: Colors.green.withOpacity(0.3)) : null,
                                ),
                                child: Text(
                                  displayMemberNumber,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.sp),
                              Text(
                                'Created: $creationDate',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: index * 50),
              duration: const Duration(milliseconds: 300),
            )
            .slideX(
              begin: 0.1,
              delay: Duration(milliseconds: index * 50),
              duration: const Duration(milliseconds: 300),
            );
      },
    );
  }

  void _migrateExistingUsers() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    setState(() {
      _isMigrating = true;
    });

    try {
      // Show confirmation dialog
      final shouldMigrate = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? colorScheme.surface : Colors.white,
            title: Text(
              'Migrate Existing Users',
              style: TextStyle(
                color: isDark ? colorScheme.onSurface : Colors.black87,
              ),
            ),
            content: Text(
              'This will add createdAt and updatedAt fields to existing users that don\'t have them. '
              'This action cannot be undone. Continue?',
              style: TextStyle(
                color: isDark ? colorScheme.onSurface.withOpacity(0.8) : Colors.black87,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDark ? colorScheme.primary : Colors.blue,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Migrate',
                  style: TextStyle(
                    color: isDark ? colorScheme.primary : Colors.blue,
                  ),
                ),
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
        builder: (context) => AlertDialog(
          backgroundColor: isDark ? colorScheme.surface : Colors.white,
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(isDark ? colorScheme.primary : Colors.blue),
              ),
              SizedBox(width: 16),
              Text(
                'Migrating users...',
                style: TextStyle(
                  color: isDark ? colorScheme.onSurface : Colors.black87,
                ),
              ),
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
}
