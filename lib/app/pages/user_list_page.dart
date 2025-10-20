import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/pages/user_detail_page.dart';
import 'package:otogapo/services/pocketbase_service.dart';

@RoutePage(name: 'UserListPageRouter')
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  bool _isLoading = true;
  List<dynamic> _users = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final pocketBaseService = PocketBaseService();
      final users = await pocketBaseService.getAllUsers();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshUsers() {
    _loadUsers();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildUserAvatar({
    required Map<String, dynamic> userData,
    required String userId,
    required String displayName,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    // Get profile image filename
    String? profileImageFileName;
    if (userData['profile_image'] != null && userData['profile_image'].toString().isNotEmpty) {
      profileImageFileName = userData['profile_image'].toString();
    } else if (userData['profileImage'] != null && userData['profileImage'].toString().isNotEmpty) {
      profileImageFileName = userData['profileImage'].toString();
    }

    // Build profile image URL if we have a filename
    String? profileImageUrl;
    if (profileImageFileName != null) {
      if (profileImageFileName.startsWith('http')) {
        // It's already a full URL
        profileImageUrl = profileImageFileName;
      } else {
        // It's a PocketBase filename, construct the URL
        final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
        profileImageUrl = '$pocketbaseUrl/api/files/users/$userId/$profileImageFileName';
      }
    }

    return Container(
      width: 48.sp,
      height: 48.sp,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.sp),
        border: Border.all(
          color: isDark ? colorScheme.outline.withOpacity(0.2) : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.sp),
        child: profileImageUrl != null
            ? CachedNetworkImage(
                imageUrl: profileImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDark ? colorScheme.primary.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                  child: Center(
                    child: SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? colorScheme.primary : Colors.blue,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: isDark ? colorScheme.primary.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? colorScheme.primary : Colors.blue,
                      ),
                    ),
                  ),
                ),
              )
            : Container(
                color: isDark ? colorScheme.primary.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                child: Center(
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? colorScheme.primary : Colors.blue,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  List<dynamic> _filterUsers(List<dynamic> users) {
    if (_searchQuery.isEmpty) return users;

    return users.where((user) {
      final data = user.data;
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

  Widget _buildUserList() {
    final filteredUsers = _filterUsers(_users);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    if (filteredUsers.isEmpty) {
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
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        final userData = user.data;

        return _buildUserCard(user, userData as Map<String, dynamic>, isDark, colorScheme);
      },
    );
  }

  Widget _buildUserCard(dynamic user, Map<String, dynamic> userData, bool isDark, ColorScheme colorScheme) {
    final firstName = (userData['firstName'] ?? '').toString();
    final lastName = (userData['lastName'] ?? '').toString();
    final fullName = '$firstName $lastName'.trim();
    final titleCaseName = _toTitleCase(fullName);
    final displayName = titleCaseName.isEmpty ? '(no_name)' : titleCaseName;
    final email = (userData['email'] ?? '').toString();
    final memberNumber = (userData['memberNumber'] ?? '').toString();
    final displayMemberNumber = memberNumber == memberNumber ? 'OM-$memberNumber' : memberNumber;

    var creationDate = 'Unknown';
    if (userData['created'] != null) {
      try {
        final date = DateTime.parse(userData['created'].toString());
        creationDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        creationDate = 'Unknown';
      }
    }

    final userDataMap = Map<String, dynamic>.from(userData);
    userDataMap['id'] = user.id;

    return Container(
      margin: EdgeInsets.only(bottom: 8.sp),
      child: Card(
        elevation: isDark ? 0 : 2,
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.sp),
        ),
        child: InkWell(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => UserDetailPage(userData: userDataMap),
              ),
            );

            // Refresh the list after returning from user detail page
            _refreshUsers();
          },
          borderRadius: BorderRadius.circular(12.sp),
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Row(
              children: [
                // Avatar with Profile Photo
                _buildUserAvatar(
                  userData: userData,
                  userId: user.id.toString(),
                  displayName: displayName,
                  isDark: isDark,
                  colorScheme: colorScheme,
                ),
                SizedBox(width: 12.sp),
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
                      if (email.isNotEmpty)
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
                          ),
                        ),
                      SizedBox(height: 2.sp),
                      Row(
                        children: [
                          if (displayMemberNumber.isNotEmpty) ...[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 2.sp),
                              decoration: BoxDecoration(
                                color: isDark ? colorScheme.primary.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.sp),
                              ),
                              child: Text(
                                displayMemberNumber,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? colorScheme.primary : Colors.blue,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.sp),
                          ],
                          Text(
                            'Joined: $creationDate',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[500],
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
                  color: isDark ? colorScheme.onSurface.withOpacity(0.3) : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    if (authState.user == null) {
      return Scaffold(
        backgroundColor: isDark ? colorScheme.surface : Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'User List',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? colorScheme.onSurface : Colors.black87,
            ),
          ),
          backgroundColor: isDark ? colorScheme.surface : Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDark ? colorScheme.onSurface : Colors.black87,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64.sp,
                color: isDark ? colorScheme.onSurface.withOpacity(0.3) : Colors.grey[400],
              ),
              SizedBox(height: 16.sp),
              Text(
                'Please sign in to view users',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
                ),
              ),
              SizedBox(height: 8.sp),
              Text(
                'You need to be authenticated to access this page',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[500],
                ),
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
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? colorScheme.onSurface : Colors.black87,
          ),
        ),
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? colorScheme.onSurface : Colors.black87,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? colorScheme.onSurface : Colors.black87,
            ),
            onPressed: _refreshUsers,
            tooltip: 'Refresh List',
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
                      color: isDark ? colorScheme.surfaceContainerHighest : Colors.grey[100],
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
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? colorScheme.onSurface.withOpacity(0.6) : Colors.grey[600],
                        ),
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
            child: _isLoading
                ? Center(
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
                  )
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64.sp,
                              color: isDark ? colorScheme.onSurface.withOpacity(0.3) : Colors.grey[400],
                            ),
                            SizedBox(height: 16.sp),
                            Text(
                              'No users found',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8.sp),
                            Text(
                              'Users will appear here once they are added',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildUserList(),
          ),
        ],
      ),
    );
  }
}
