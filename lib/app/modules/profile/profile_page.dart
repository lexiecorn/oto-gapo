import 'package:auto_route/auto_route.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/pages/car_widget.dart';
import 'package:otogapo/app/pages/id_card.dart';
import 'package:otogapo/app/pages/current_user_account_page.dart';

@RoutePage(
  name: 'ProfilePageRouter',
)
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  late Reference storageRef;
  String userProfile = '';

  final ScrollController _announcementScrolllController = ScrollController();
  @override
  void initState() {
    super.initState();

    _announcementScrolllController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
          // Add debugging
          print('Profile Page - Profile Status: ${state.profileStatus}');
          print('Profile Page - User Member Number: "${state.user.memberNumber}"');
          print('Profile Page - User First Name: "${state.user.firstName}"');
          print('Profile Page - User Last Name: "${state.user.lastName}"');
          print('Profile Page - User Membership Type: ${state.user.membership_type}');
          print('Profile Page - User UID: "${state.user.uid}"');

          // Check if the current authenticated user is different from the profile user
          final currentAuthUser = context.read<AuthBloc>().state.user;
          if (currentAuthUser != null && state.user.uid.isNotEmpty && state.user.uid != currentAuthUser.uid) {
            print('Profile Page - User mismatch detected!');
            print('Profile Page - Auth user UID: ${currentAuthUser.uid}');
            print('Profile Page - Profile user UID: ${state.user.uid}');
            print('Profile Page - Force clearing profile for new user');
            context.read<ProfileCubit>().forceClear();
            Future.delayed(const Duration(milliseconds: 100), () {
              context.read<ProfileCubit>().getProfile(uid: currentAuthUser.uid);
            });
          }

          if (state.profileStatus == ProfileStatus.initial) {
            return Container();
          } else if (state.profileStatus == ProfileStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state.profileStatus == ProfileStatus.error) {
            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/error.png',
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    'Ooops!\nTry again',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            );
          }

          // Debug display for development
          if (state.user.firstName.isEmpty && state.user.lastName.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    'User data appears to be empty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('UID: ${state.user.uid}'),
                  Text('Member Number: "${state.user.memberNumber}"'),
                  Text('Membership Type: ${state.user.membership_type}'),
                  Text('First Name: "${state.user.firstName}"'),
                  Text('Last Name: "${state.user.lastName}"'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final uid = context.read<AuthBloc>().state.user!.uid;
                      context.read<ProfileCubit>().getProfile(uid: uid);
                    },
                    child: const Text('Reload Profile'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.only(
              top: 20.sp,
              left: 8,
              right: 8,
              bottom: 20,
            ),
            children: [
              FutureBuilder<Widget>(
                future: _userProfileCard(state),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Error loading profile');
                  } else if (snapshot.hasData) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CurrentUserAccountPage(),
                          ),
                        );
                      },
                      child: snapshot.data,
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              SizedBox(height: 12.sp),
              CarWidget(state: state),
              SizedBox(height: 12.sp),
              PaymentStatusCard(userId: state.user.uid),
            ],
          );
        },
      ),
    );
  }

  Future<Widget> _userProfileCard(ProfileState state) async {
    String imagePath;

    // Check if user has a profile image URL stored and it's a gs:// link
    if (state.user.profile_image != null && state.user.profile_image!.startsWith('gs://')) {
      try {
        // Get the download URL from the gs:// URI
        final ref = FirebaseStorage.instance.refFromURL(state.user.profile_image!);
        imagePath = await ref.getDownloadURL();
      } catch (e) {
        // If it fails, use a default placeholder image
        imagePath = 'assets/images/alex.png'; // Using a local asset as fallback
      }
    } else if (state.user.profile_image != null && state.user.profile_image!.isNotEmpty) {
      // It might be a pre-fetched HTTPS URL or a local asset path
      imagePath = state.user.profile_image!;
    } else {
      // No profile_image field, or it's empty. Use a default placeholder.
      imagePath = 'assets/images/alex.png';
    }

    return IdCard(
      imagePath: imagePath,
      name: '${state.user.firstName} ${state.user.lastName}',
      dob: DateFormat('MMM dd, yyyy').format(state.user.dateOfBirth.toDate()),
      idNumber: state.user.memberNumber,
      membersNum: state.user.memberNumber,
      car: state.user.vehicle.isNotEmpty ? state.user.vehicle.first.make : 'No Vehicle',
      licenseNum: state.user.driversLicenseNumber ?? '',
      licenseNumExpr: state.user.driversLicenseExpirationDate,
      restrictionCode: state.user.driversLicenseRestrictionCode,
      emergencyContact: state.user.emergencyContactNumber,
    )
        .animate()
        .slideY(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 500),
        )
        .shimmer(
          duration: const Duration(milliseconds: 800),
        )
        .fadeIn(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 500),
        );
  }
}

class PaymentStatusCard extends StatefulWidget {
  final String userId;

  const PaymentStatusCard({Key? key, required this.userId}) : super(key: key);

  @override
  State<PaymentStatusCard> createState() => _PaymentStatusCardState();
}

class _PaymentStatusCardState extends State<PaymentStatusCard> {
  bool _isLoading = true;
  int _paidCount = 0;
  int _unpaidCount = 0;
  int _advanceCount = 0;
  double _totalAmount = 0.0;
  List<Map<String, dynamic>> _recentPayments = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final now = DateTime.now();
      final currentYear = now.year;
      final currentMonth = now.month;

      // Generate months from January of current year to current month only
      final months = <String>[];
      for (int month = 1; month <= currentMonth; month++) {
        final monthKey = '${currentYear}_${month.toString().padLeft(2, '0')}';
        months.add(monthKey);
      }

      // Generate future months for advance payment calculation (current month + 1 to December)
      final futureMonths = <String>[];
      for (int month = currentMonth + 1; month <= 12; month++) {
        final monthKey = '${currentYear}_${month.toString().padLeft(2, '0')}';
        futureMonths.add(monthKey);
      }

      int paid = 0;
      int unpaid = 0;
      int advance = 0;
      final recentPayments = <Map<String, dynamic>>[];

      // Check current year months (January to current month)
      for (final month in months) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('monthly_dues')
              .doc(month)
              .get();

          final date = DateFormat('yyyy_MM').parse(month);
          final displayText = DateFormat('MMMM yyyy').format(date);
          final amount = 100.0; // Fixed amount per month

          if (doc.exists) {
            final data = doc.data()!;
            final status = data['status'];
            final isPaid = status is bool ? status : false;

            if (isPaid) {
              paid++;
            } else {
              unpaid++;
            }

            final updatedAt = data['updated_at'];
            recentPayments.add({
              'month': displayText,
              'isPaid': isPaid,
              'amount': amount,
              'updatedAt': updatedAt is Timestamp ? updatedAt : null,
              'isAdvance': false,
            });
          } else {
            // No payment record exists, consider as unpaid
            unpaid++;
            recentPayments.add({
              'month': displayText,
              'isPaid': false,
              'amount': amount,
              'updatedAt': null,
              'isAdvance': false,
            });
          }
        } catch (e) {
          print('Error loading payment for month $month: $e');
          unpaid++;
        }
      }

      // Check future months for advance payments
      for (final month in futureMonths) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('monthly_dues')
              .doc(month)
              .get();

          final date = DateFormat('yyyy_MM').parse(month);
          final displayText = DateFormat('MMMM yyyy').format(date);
          final amount = 100.0; // Fixed amount per month

          if (doc.exists) {
            final data = doc.data()!;
            final status = data['status'];
            final isPaid = status is bool ? status : false;

            if (isPaid) {
              advance++;
              final updatedAt = data['updated_at'];
              recentPayments.add({
                'month': displayText,
                'isPaid': isPaid,
                'amount': amount,
                'updatedAt': updatedAt is Timestamp ? updatedAt : null,
                'isAdvance': true,
              });
            }
          }
        } catch (e) {
          print('Error loading advance payment for month $month: $e');
        }
      }

      // Sort recent payments by date (newest first)
      recentPayments.sort((a, b) {
        final aDate = a['updatedAt'] as Timestamp?;
        final bDate = b['updatedAt'] as Timestamp?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      // Take only the last 6 payments for display
      final displayPayments = recentPayments.take(6).toList();

      setState(() {
        _paidCount = paid;
        _unpaidCount = unpaid;
        _advanceCount = advance;
        _totalAmount = (paid + unpaid) * 100.0;
        _recentPayments = displayPayments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading payment data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 8.sp),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Row(
            children: [
              SizedBox(
                width: 20.sp,
                height: 20.sp,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12.sp),
              Text(
                'Loading payment status...',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.sp),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment,
                  color: Colors.blue,
                  size: 20.sp,
                ),
                SizedBox(width: 8.sp),
                Text(
                  'Monthly Dues',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadPaymentData,
                  icon: Icon(
                    Icons.refresh,
                    size: 18.sp,
                  ),
                  tooltip: 'Refresh payment status',
                ),
              ],
            ),
            SizedBox(height: 12.sp),
            // Summary Row - Always visible
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Paid',
                    _paidCount.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Unpaid',
                    _unpaidCount.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Advance',
                    _advanceCount.toString(),
                    Icons.fast_forward,
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Total',
                    '₱${_totalAmount.toInt()}',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Payments
                Text(
                  'Recent Payments',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.sp),

                if (_recentPayments.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.sp),
                    child: Center(
                      child: Text(
                        'No payment records found',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: _recentPayments.map((payment) {
                      final isPaid = payment['isPaid'] as bool? ?? false;
                      final isAdvance = payment['isAdvance'] as bool? ?? false;
                      final month = payment['month'] as String? ?? '';
                      final amount = payment['amount'] as double? ?? 0.0;

                      // Determine icon and color based on payment status
                      IconData icon;
                      Color color;
                      String statusText;
                      Color statusColor;

                      if (isAdvance) {
                        icon = Icons.fast_forward;
                        color = Colors.purple;
                        statusText = 'ADVANCE';
                        statusColor = Colors.purple;
                      } else if (isPaid) {
                        icon = Icons.check_circle;
                        color = Colors.green;
                        statusText = 'PAID';
                        statusColor = Colors.green;
                      } else {
                        icon = Icons.cancel;
                        color = Colors.red;
                        statusText = 'UNPAID';
                        statusColor = Colors.red;
                      }

                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.sp),
                        child: Row(
                          children: [
                            Icon(
                              icon,
                              color: color,
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.sp),
                            Expanded(
                              child: Text(
                                month,
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.sp,
                                vertical: 2.sp,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.sp),
                                border: Border.all(
                                  color: statusColor,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.sp),
                            Text(
                              '₱${amount.toInt()}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                SizedBox(height: 12.sp),

                // Payment Status Summary
                Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: _unpaidCount > 0 ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.sp),
                    border: Border.all(
                      color: _unpaidCount > 0 ? Colors.orange : Colors.green,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _unpaidCount > 0 ? Icons.warning : Icons.check_circle,
                        color: _unpaidCount > 0 ? Colors.orange : Colors.green,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: Text(
                          _unpaidCount > 0
                              ? 'You have $_unpaidCount unpaid monthly due(s)'
                              : 'All payments are up to date!',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: _unpaidCount > 0 ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 500),
        )
        .fadeIn(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 500),
        );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(height: 4.sp),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
