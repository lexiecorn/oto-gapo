import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:authentication_repository/authentication_repository.dart';

@RoutePage(name: 'AddVehicleAwardPageRouter')
class AddVehicleAwardPage extends StatefulWidget {
  const AddVehicleAwardPage({required this.vehicle, this.award, super.key});

  final Vehicle vehicle;
  final VehicleAward? award; // null for new award, non-null for editing

  @override
  State<AddVehicleAwardPage> createState() => _AddVehicleAwardPageState();
}

class _AddVehicleAwardPageState extends State<AddVehicleAwardPage> {
  final _formKey = GlobalKey<FormState>();
  final _awardNameController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _placementController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.award != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final award = widget.award!;
    _awardNameController.text = award.awardName;
    _eventNameController.text = award.eventName;
    _descriptionController.text = award.description ?? '';
    _categoryController.text = award.category ?? '';
    _placementController.text = award.placement ?? '';
    _selectedDate = award.eventDate;
  }

  @override
  void dispose() {
    _awardNameController.dispose();
    _eventNameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _placementController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00d4ff),
              onPrimary: Colors.white,
              surface: Color(0xFF1a1e3f),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveAward() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(
          content: Text('Please select an event date'),
          backgroundColor: Colors.red));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual save logic when repository is integrated
      await Future<void>.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.award != null
                ? 'Award updated successfully!'
                : 'Award added successfully!'),
            backgroundColor: const Color(0xFF00d4ff),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
            content: Text('Failed to save award: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    String? hint,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines ?? 1,
          style: TextStyle(fontSize: 16.sp, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFF1e2340).withOpacity(0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:
                  BorderSide(color: const Color(0xFF00d4ff).withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:
                  BorderSide(color: const Color(0xFF00d4ff).withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: const Color(0xFF00d4ff), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Date',
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1e2340).withOpacity(0.8),
              borderRadius: BorderRadius.circular(12.r),
              border:
                  Border.all(color: const Color(0xFF00d4ff).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 20.sp, color: const Color(0xFF00d4ff)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select event date',
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: _selectedDate != null
                            ? Colors.white
                            : Colors.grey[400]),
                  ),
                ),
                Icon(Icons.arrow_drop_down,
                    size: 20.sp, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.award != null ? 'Edit Award' : 'Add Award',
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20.sp),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2a1a0e).withOpacity(0.8),
                      const Color(0xFF3d2815).withOpacity(0.6)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                      color: const Color(0xFFffd700).withOpacity(0.3),
                      width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.sp),
                      decoration: BoxDecoration(
                        color: const Color(0xFFffd700).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.emoji_events,
                          size: 24.sp, color: const Color(0xFFffd700)),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.award != null
                                ? 'Edit Award'
                                : 'Add New Award',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFffd700),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${widget.vehicle.make} ${widget.vehicle.model}',
                            style: TextStyle(
                                fontSize: 14.sp, color: Colors.grey[300]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(
                  begin: 0.2, duration: 600.ms, curve: Curves.easeOutCubic),
              SizedBox(height: 24.h),
              // Form fields
              _buildFormField(
                label: 'Award Name *',
                controller: _awardNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the award name';
                  }
                  return null;
                },
                hint: 'e.g., Best Modified Car',
              ),
              SizedBox(height: 20.h),
              _buildFormField(
                label: 'Event Name *',
                controller: _eventNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the event name';
                  }
                  return null;
                },
                hint: 'e.g., Manila Auto Show 2025',
              ),
              SizedBox(height: 20.h),
              _buildDateField(),
              SizedBox(height: 20.h),
              _buildFormField(
                label: 'Category',
                controller: _categoryController,
                validator: (value) => null,
                hint: 'e.g., Modified, Classic, Best in Show',
              ),
              SizedBox(height: 20.h),
              _buildFormField(
                label: 'Placement',
                controller: _placementController,
                validator: (value) => null,
                hint: 'e.g., 1st Place, Winner, Champion',
              ),
              SizedBox(height: 20.h),
              _buildFormField(
                label: 'Description',
                controller: _descriptionController,
                validator: (value) => null,
                hint: 'Additional details about the award...',
                maxLines: 3,
              ),
              SizedBox(height: 32.h),
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAward,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00d4ff),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.award != null ? 'Update Award' : 'Add Award',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
