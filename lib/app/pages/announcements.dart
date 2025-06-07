import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AnnouncementsWidget extends StatefulWidget {
  const AnnouncementsWidget({super.key});

  @override
  State<AnnouncementsWidget> createState() => _AnnouncementsWidgetState();
}

class _AnnouncementsWidgetState extends State<AnnouncementsWidget> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ScrollController _announcementScrolllController = ScrollController();
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      final docRef = firestore.collection('announcements').doc('general');
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final announcementsData = docSnapshot.data()!['announcements'] as List<dynamic>?;
        if (announcementsData != null) {
          _announcements = announcementsData.map((announcement) => announcement as Map<String, dynamic>).toList();
        } else {
          _errorMessage = 'No announcements found';
        }
      } else {
        _errorMessage = 'No announcements document found';
      }
    } catch (e) {
      _errorMessage = 'Error fetching announcements: $e';
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.sp),
      padding: EdgeInsets.only(left: 40.sp, right: 40.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.5),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Scrollbar(
        controller: _announcementScrolllController,
        trackVisibility: true,
        child: ListView.builder(
          controller: _announcementScrolllController,
          itemCount: _announcements.length,
          itemBuilder: (context, index) {
            final announcement = _announcements[index];
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 40.sp : 0),
              child: Column(
                children: [
                  ListTile(
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        announcement['type'] == 'announce'
                            ? Icons.announcement
                            : announcement['type'] == 'warning'
                                ? Icons.warning
                                : announcement['type'] == 'notice'
                                    ? Icons.info
                                    : Icons.info,
                        color: announcement['type'] == 'announce'
                            ? Colors.blue
                            : announcement['type'] == 'warning'
                                ? Colors.red
                                : announcement['type'] == 'notice'
                                    ? Colors.orange
                                    : Colors.grey,
                      ),
                    ),
                    title: Text(
                      announcement['title'] as String,
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          announcement['content'] as String,
                          style: TextStyle(fontSize: 40.sp),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format((announcement['date'] as Timestamp).toDate()),
                          textAlign: TextAlign.end,
                          style: TextStyle(fontSize: 30.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
