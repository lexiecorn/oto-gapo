import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo_core/otogapo_core.dart';

class CarouselViewFromFirebase extends StatefulWidget {
  const CarouselViewFromFirebase({super.key});

  @override
  _CarouselViewFromFirebaseState createState() => _CarouselViewFromFirebaseState();
}

class _CarouselViewFromFirebaseState extends State<CarouselViewFromFirebase> {
  List<String> _imageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchImagesFromFirebase();
  }

  Future<void> _fetchImagesFromFirebase() async {
    try {
      final result = await FirebaseStorage.instance.ref('dashboard-gallery').listAll();

      // Get download URLs for each image
      final urls = await Future.wait(
        result.items.map((ref) => ref.getDownloadURL()).toList(),
      );

      setState(() {
        _imageUrls = urls;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : CarouselSlider(
            options: CarouselOptions(
              height: 150,
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 1 / 1,
              autoPlayInterval: const Duration(seconds: 5),
            ),
            items: _imageUrls.map((imageUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return OpstechExtendedImageNetwork(
                    img: imageUrl,
                    width: 90.sw,
                    height: 200.h,
                    borderrRadius: 15.r,
                    border: Border.all(
                      color: Colors.white.withOpacity(.1),
                      width: 3,
                    ),
                  );
                },
              );
            }).toList(),
          );
  }
}
