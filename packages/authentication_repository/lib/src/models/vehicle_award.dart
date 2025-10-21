// ignore_for_file: public_member_api_docs

import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_award.freezed.dart';
part 'vehicle_award.g.dart';

@freezed
abstract class VehicleAward with _$VehicleAward {
  const factory VehicleAward({
    String? id, // PocketBase record ID
    required String vehicleId, // Relation to vehicles collection
    required String awardName, // e.g., "Best Modified Car"
    required String eventName, // e.g., "Manila Auto Show 2025"
    required DateTime eventDate, // Date of the event
    String? category, // e.g., "Modified", "Classic", "Best in Show"
    String? placement, // e.g., "1st Place", "Winner", "Champion"
    String? description, // Optional additional details
    String? awardImage, // File name for award photo/certificate
    String? createdBy, // User who created the award entry
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _VehicleAward;

  factory VehicleAward.fromJson(Map<String, Object?> json) => _$VehicleAwardFromJson(json);
}
