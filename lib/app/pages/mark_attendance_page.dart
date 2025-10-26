import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:otogapo/app/modules/attendance/bloc/attendance_cubit.dart';
import 'package:otogapo/models/attendance.dart';
import 'package:otogapo/services/pocketbase_service.dart';

@RoutePage(name: 'MarkAttendancePageRouter')
class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({
    @PathParam('meetingId') required this.meetingId,
    super.key,
  });

  final String meetingId;

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _pocketbaseService = PocketBaseService();

  AttendanceStatus _selectedStatus = AttendanceStatus.present;
  String? _selectedUserId;
  String? _selectedMemberNumber;
  String? _selectedMemberName;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _browseUsers() async {
    final result = await showModalBottomSheet<Map<String, String>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UserBrowserModal(
        pocketbaseService: _pocketbaseService,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedUserId = result['userId'];
        _selectedMemberNumber = result['memberNumber'];
        _selectedMemberName = result['memberName'];
      });
    }
  }

  Future<void> _scanQRCode() async {
    final result = await showModalBottomSheet<Map<String, String>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UserQRScannerModal(
        pocketbaseService: _pocketbaseService,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedUserId = result['userId'];
        _selectedMemberNumber = result['memberNumber'];
        _selectedMemberName = result['memberName'];
      });
    }
  }

  void _markAttendance() {
    if (!_formKey.currentState!.validate()) return;

    // Validate user selection
    if (_selectedUserId == null ||
        _selectedMemberNumber == null ||
        _selectedMemberName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a member first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<AttendanceCubit>().markAttendance(
          userId: _selectedUserId!,
          memberNumber: _selectedMemberNumber!,
          memberName: _selectedMemberName!,
          meetingId: widget.meetingId,
          meetingDate: DateTime.now(), // Should get from meeting
          status: _selectedStatus.value,
          checkInMethod: 'qr_scan',
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: BlocListener<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state.status == AttendanceStateStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Attendance marked successfully'),
              ),
            );
            context.router.maybePop();
          } else if (state.status == AttendanceStateStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(state.errorMessage ?? 'Failed to mark attendance'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // Selection Methods Header
              Text(
                'Select Member',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Choose a method to mark attendance',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 16.h),

              // Two Selection Options
              Row(
                children: [
                  // Browse Users Option
                  Expanded(
                    child: _SelectionCard(
                      icon: Icons.people,
                      title: 'Browse',
                      subtitle: 'Select from list',
                      onTap: _browseUsers,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Scan QR Code Option
                  Expanded(
                    child: _SelectionCard(
                      icon: Icons.qr_code_scanner,
                      title: 'Scan QR',
                      subtitle: 'Quick scan',
                      onTap: _scanQRCode,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Show selected user info if any
              if (_selectedUserId != null) ...[
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            color: theme.colorScheme.onPrimary,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedMemberName ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Member #${_selectedMemberNumber ?? ''}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedUserId = null;
                              _selectedMemberNumber = null;
                              _selectedMemberName = null;
                            });
                          },
                          tooltip: 'Clear selection',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ] else ...[
                // Show message when no user selected
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Select a member to mark attendance',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Status Selection
              Text(
                'Attendance Status',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: AttendanceStatus.values.map((status) {
                  final isSelected = status == _selectedStatus;
                  final isDark = theme.brightness == Brightness.dark;
                  return ChoiceChip(
                    label: Text(
                      status.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? (isDark
                                ? theme.colorScheme.onPrimary
                                : Colors.white)
                            : null,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedStatus = status);
                      }
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),

              // Notes
              TextFormField(
                controller: _notesController,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  labelStyle: theme.textTheme.bodyMedium,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.note),
                  hintText: 'Add any notes or comments',
                  hintStyle: theme.textTheme.bodySmall,
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24.h),

              // Submit Button
              BlocBuilder<AttendanceCubit, AttendanceState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.status == AttendanceStateStatus.submitting
                        ? null
                        : _markAttendance,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: state.status == AttendanceStateStatus.submitting
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Mark Attendance'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selection card widget for choosing between browse and scan options
class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 24.h,
            horizontal: 16.w,
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24.sp,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal for browsing and selecting users
class _UserBrowserModal extends StatefulWidget {
  const _UserBrowserModal({
    required this.pocketbaseService,
  });

  final PocketBaseService pocketbaseService;

  @override
  State<_UserBrowserModal> createState() => _UserBrowserModalState();
}

class _UserBrowserModalState extends State<_UserBrowserModal> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  String? _error;

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
        _error = null;
      });

      final users = await widget.pocketbaseService.getAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          final data = user.data as Map<String, dynamic>;
          final firstName = data['firstName']?.toString().toLowerCase() ?? '';
          final lastName = data['lastName']?.toString().toLowerCase() ?? '';
          final memberNumber =
              data['memberNumber']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();

          return firstName.contains(searchLower) ||
              lastName.contains(searchLower) ||
              memberNumber.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Member',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search by name or member number',
                hintStyle: theme.textTheme.bodySmall,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              onChanged: _filterUsers,
            ),
          ),

          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48.sp,
                              color: theme.colorScheme.error,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Failed to load users',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              _error!,
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_search,
                                  size: 48.sp,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No members found',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.only(bottom: 16.h),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              final data = user.data as Map<String, dynamic>;
                              final firstName =
                                  data['firstName']?.toString() ?? '';
                              final lastName =
                                  data['lastName']?.toString() ?? '';
                              final memberNumber =
                                  data['memberNumber']?.toString() ?? '';
                              final profileImage =
                                  data['profile_image']?.toString();

                              // Validate profile image URL
                              final hasValidImage = profileImage != null &&
                                  profileImage.isNotEmpty &&
                                  (profileImage.startsWith('http://') ||
                                      profileImage.startsWith('https://'));

                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 20.r,
                                  backgroundColor: hasValidImage
                                      ? Colors.transparent
                                      : theme.colorScheme.inverseSurface,
                                  backgroundImage: hasValidImage
                                      ? NetworkImage(profileImage)
                                      : null,
                                  child: !hasValidImage
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme.inverseSurface,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              memberNumber.isNotEmpty
                                                  ? memberNumber
                                                  : '?',
                                              style: TextStyle(
                                                color: theme.colorScheme
                                                    .onInverseSurface,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  '$firstName $lastName',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                subtitle: Text(
                                  'Member #$memberNumber',
                                  style: theme.textTheme.bodySmall,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  Navigator.of(context).pop({
                                    'userId': user.id as String,
                                    'memberNumber': memberNumber,
                                    'memberName': '$firstName $lastName',
                                  });
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

/// Modal for scanning user QR codes
class _UserQRScannerModal extends StatefulWidget {
  const _UserQRScannerModal({
    required this.pocketbaseService,
  });

  final PocketBaseService pocketbaseService;

  @override
  State<_UserQRScannerModal> createState() => _UserQRScannerModalState();
}

class _UserQRScannerModalState extends State<_UserQRScannerModal> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final code = barcode.rawValue;

    if (code == null || code.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      // Parse QR code: Expected format "USER:{userId}:{memberNumber}"
      if (!code.startsWith('USER:')) {
        _showError('Invalid user QR code');
        return;
      }

      final parts = code.split(':');
      if (parts.length < 3) {
        _showError('Invalid QR code format');
        return;
      }

      final userId = parts[1];
      final memberNumber = parts[2];

      // Fetch user details from PocketBase
      final user = await widget.pocketbaseService.getUser(userId);
      if (user == null) {
        _showError('User not found');
        return;
      }

      final userData = user.data;
      final firstName = userData['firstName']?.toString() ?? '';
      final lastName = userData['lastName']?.toString() ?? '';

      if (mounted) {
        Navigator.of(context).pop({
          'userId': userId,
          'memberNumber': memberNumber,
          'memberName': '$firstName $lastName',
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to process QR code: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Scan Member QR Code',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Scanner
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
                // Scanning Overlay
                CustomPaint(
                  painter: _ScannerOverlay(),
                  child: Container(),
                ),
                // Instructions
                Positioned(
                  bottom: 80.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Align member QR code within the frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // Processing Indicator
                if (_isProcessing)
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),

          // Controls
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, value, child) {
                      final isFlashOn = value.torchState == TorchState.on;
                      return Icon(
                        isFlashOn ? Icons.flash_on : Icons.flash_off,
                        size: 32.sp,
                      );
                    },
                  ),
                  onPressed: _controller.toggleTorch,
                ),
                SizedBox(width: 32.w),
                IconButton(
                  icon: Icon(Icons.cameraswitch, size: 32.sp),
                  onPressed: _controller.switchCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Scanner overlay painter
class _ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.width * 0.7,
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corners
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const cornerLength = 30.0;

    // Top-left
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top),
      Offset(scanArea.left + cornerLength, scanArea.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top),
      Offset(scanArea.left, scanArea.top + cornerLength),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(scanArea.right, scanArea.top),
      Offset(scanArea.right - cornerLength, scanArea.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.top),
      Offset(scanArea.right, scanArea.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom),
      Offset(scanArea.left + cornerLength, scanArea.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom),
      Offset(scanArea.left, scanArea.bottom - cornerLength),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(scanArea.right, scanArea.bottom),
      Offset(scanArea.right - cornerLength, scanArea.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.bottom),
      Offset(scanArea.right, scanArea.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
