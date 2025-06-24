import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:otogapo_core/otogapo_core.dart';

class IdCard extends StatefulWidget {
  const IdCard({
    required this.imagePath,
    required this.name,
    required this.dob,
    required this.idNumber,
    required this.car,
    required this.membersNum,
    required this.licenseNum,
    required this.restrictionCode,
    required this.emergencyContact,
    this.licenseNumExpr,
    super.key,
  });
  final String imagePath;
  final String name;
  final String dob;
  final String idNumber;
  final String car;
  final String membersNum;
  final String licenseNum;
  final Timestamp? licenseNumExpr;
  final String? restrictionCode;
  final String? emergencyContact;

  @override
  State<IdCard> createState() => _IdCardState();
}

class _IdCardState extends State<IdCard> with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _hoverAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _hoverAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
    ));

    _shadowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    ));

    // Start the initial animation
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _hoverAnimationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverAnimationController.forward();
    } else {
      _hoverAnimationController.reverse();
    }
  }

  bool get _isAssetImage => widget.imagePath.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: Listenable.merge([_cardAnimationController, _hoverAnimationController]),
        builder: (context, child) {
          final hoverScale = 1.0 + (_hoverAnimationController.value * 0.02);
          final currentScale = _scaleAnimation.value * hoverScale;

          return Transform.scale(
            scale: currentScale,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Card(
                  color: Colors.redAccent.shade700,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 10 + (_shadowAnimation.value * 5) + (_hoverAnimationController.value * 3),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.redAccent.shade700,
                          Colors.redAccent.shade400,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1 + (_shadowAnimation.value * 0.2)),
                          blurRadius: 8 + (_hoverAnimationController.value * 4),
                          offset: Offset(0, 4 + (_hoverAnimationController.value * 2)),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 20.h,
                          ),
                          child: Column(
                            children: [
                              ClipOval(
                                child: _isAssetImage
                                    ? OpstechExtendedImageAsset(
                                        img: widget.imagePath,
                                        width: 80.w,
                                        height: 80.w,
                                        borderrRadius: 40.r,
                                      )
                                    : OpstechExtendedImageNetwork(
                                        img: widget.imagePath,
                                        width: 80.w,
                                        height: 80.w,
                                        borderrRadius: 40.r,
                                      ),
                              )
                                  .animate()
                                  .fadeIn(delay: 600.ms, duration: 800.ms)
                                  .scale(delay: 700.ms, duration: 600.ms, curve: Curves.easeOutBack),
                              const SizedBox(height: 10),
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  '# ${widget.membersNum}',
                                  style: OpstechTextTheme.heading4.copyWith(
                                    color: Colors.amber,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(begin: 0.3, duration: 600.ms),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.name.toUpperCase(),
                                style: OpstechTextTheme.heading2.copyWith(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ).animate().fadeIn(delay: 900.ms, duration: 600.ms).slideX(begin: 0.3, duration: 600.ms),
                              const SizedBox(height: 10),
                              Text(
                                'License #: ${widget.licenseNum}',
                                style: OpstechTextTheme.regular.copyWith(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                ),
                              ).animate().fadeIn(delay: 1000.ms, duration: 600.ms).slideX(begin: 0.3, duration: 600.ms),
                              Text(
                                'DOB: ${widget.dob}',
                                style: OpstechTextTheme.regular.copyWith(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                ),
                              ).animate().fadeIn(delay: 1100.ms, duration: 600.ms).slideX(begin: 0.3, duration: 600.ms),
                              Text(
                                'ID Number: ${widget.idNumber}',
                                style: OpstechTextTheme.regular.copyWith(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                ),
                              ).animate().fadeIn(delay: 1200.ms, duration: 600.ms).slideX(begin: 0.3, duration: 600.ms),
                              Text(
                                'Joined: December 20, 2023',
                                style: OpstechTextTheme.regular.copyWith(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                ),
                              ).animate().fadeIn(delay: 1300.ms, duration: 600.ms).slideX(begin: 0.3, duration: 600.ms),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
