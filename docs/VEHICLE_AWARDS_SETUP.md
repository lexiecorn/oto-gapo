# Vehicle Awards System Setup Guide

This guide provides step-by-step instructions for setting up the Vehicle Awards system in PocketBase and integrating it with the Flutter app.

## Overview

The Vehicle Awards system allows members to showcase their car's achievements and trophies won at car shows and events. Each award includes details like the event name, date, category, placement, and optional images.

## PocketBase Setup

### 1. Create Vehicle Awards Collection

1. **Access PocketBase Admin UI**

   - Navigate to your PocketBase admin interface
   - Go to Collections section

2. **Create New Collection**

   - Click "New Collection"
   - Name: `vehicle_awards`
   - Type: `base`

3. **Add Schema Fields**
   Use the provided schema file: `pocketbase/pocketbase_vehicle_awards_schema.json`

   **Required Fields:**

   - `id` (text, required, unique)
   - `vehicle_id` (relation to vehicles collection, required)
   - `award_name` (text, required)
   - `event_name` (text, required)
   - `event_date` (date, required)
   - `created_by` (relation to users collection)

   **Optional Fields:**

   - `category` (text) - e.g., "Modified", "Classic", "Best in Show"
   - `placement` (text) - e.g., "1st Place", "Winner", "Champion"
   - `description` (text) - Additional details
   - `award_image` (file) - Photo of trophy/certificate
   - `created_at` (date)
   - `updated_at` (date)

4. **Set Up Indexes**
   ```sql
   CREATE INDEX idx_vehicle_awards_vehicle_id ON vehicle_awards (vehicle_id);
   CREATE INDEX idx_vehicle_awards_event_date ON vehicle_awards (event_date);
   CREATE INDEX idx_vehicle_awards_created_by ON vehicle_awards (created_by);
   ```

### 2. Update Vehicles Collection

1. **Add New Fields to Vehicles Collection**
   Use the provided schema file: `pocketbase/pocketbase_vehicles_schema.json`

   **New Specification Fields:**

   - `mileage` (number) - Vehicle mileage in km
   - `fuelType` (text) - "Petrol", "Diesel", "Electric", "Hybrid"
   - `wheelSize` (text) - e.g., "18-inch Alloy"
   - `maxSpeed` (number) - Maximum speed in km/h
   - `engineDisplacement` (text) - e.g., "2.0L", "3.5L V6"
   - `horsepower` (number) - Engine power in HP
   - `transmission` (text) - "Automatic", "Manual", "CVT", etc.

2. **Set Up Indexes**
   ```sql
   CREATE INDEX idx_vehicles_user ON vehicles (user);
   CREATE INDEX idx_vehicles_make ON vehicles (make);
   CREATE INDEX idx_vehicles_plateNumber ON vehicles (plateNumber);
   ```

### 3. Configure Permissions

**Vehicle Awards Collection Permissions:**

- **List Rule:** `@request.auth.id != ""` (authenticated users can view)
- **View Rule:** `@request.auth.id != ""` (authenticated users can view)
- **Create Rule:** `@request.auth.id != ""` (authenticated users can create)
- **Update Rule:** `created_by = @request.auth.id || @request.auth.isAdmin = true` (owner or admin can update)
- **Delete Rule:** `created_by = @request.auth.id || @request.auth.isAdmin = true` (owner or admin can delete)

**Vehicles Collection Permissions:**

- **List Rule:** `@request.auth.id != ""` (authenticated users can view)
- **View Rule:** `@request.auth.id != ""` (authenticated users can view)
- **Create Rule:** `@request.auth.id != ""` (authenticated users can create)
- **Update Rule:** `user = @request.auth.id || @request.auth.isAdmin = true` (owner or admin can update)
- **Delete Rule:** `user = @request.auth.id || @request.auth.isAdmin = true` (owner or admin can delete)

## Flutter App Integration

### 1. Update Dependencies

The following packages are already included in the project:

- `authentication_repository` - Contains VehicleAward model and VehicleAwardsRepository
- `flutter_animate` - For animations
- `flutter_screenutil` - For responsive design

### 2. Generated Files

The following files have been created/updated:

**Models:**

- `packages/authentication_repository/lib/src/models/vehicle_award.dart`
- `packages/authentication_repository/lib/src/vehicle_awards_repository.dart`

**UI Components:**

- `lib/widgets/vehicle_spec_card.dart` - Reusable spec display card
- `lib/widgets/awards_trophy_row.dart` - Awards display with trophy icons

**Pages:**

- `lib/app/pages/car_details_page.dart` - Full vehicle details with image carousel
- `lib/app/pages/vehicle_awards_page.dart` - Awards list for a vehicle
- `lib/app/pages/add_vehicle_award_page.dart` - Form to add/edit awards

**Updated Files:**

- `lib/app/pages/car_widget.dart` - Complete redesign with dark theme
- `packages/authentication_repository/lib/src/models/vehicle.dart` - Added spec fields
- `lib/app/routes/app_router.dart` - Added new routes

### 3. Route Configuration

New routes have been added to the app router:

```dart
// Vehicle routes
AutoRoute(
  page: CarDetailsPageRouter.page,
  path: '/car-details/:vehicleId',
),
AutoRoute(
  page: VehicleAwardsPageRouter.page,
  path: '/vehicle/:vehicleId/awards',
),
AutoRoute(
  page: AddVehicleAwardPageRouter.page,
  path: '/vehicle/:vehicleId/awards/add',
),
AutoRoute(
  page: EditVehicleAwardPageRouter.page,
  path: '/vehicle/:vehicleId/awards/:awardId/edit',
),
```

### 4. Navigation Usage

```dart
// Navigate to car details
context.router.pushNamed('/car-details/$vehicleId');

// Navigate to awards page
context.router.pushNamed('/vehicle/$vehicleId/awards');

// Navigate to add award
context.router.pushNamed('/vehicle/$vehicleId/awards/add');

// Navigate to edit award
context.router.pushNamed('/vehicle/$vehicleId/awards/$awardId/edit');
```

## Features Implemented

### 1. Enhanced Car Profile

- **Dark Theme Design:** Inspired by premium automotive apps with dark gradients and glowing accents
- **Hero Car Images:** Large, dramatic car images as the focal point
- **Specifications Grid:** Comprehensive vehicle specs in an elegant card layout
- **Awards Display:** Trophy count and quick access to awards

### 2. Vehicle Specifications

- **Mileage:** Odometer reading in kilometers
- **Fuel Type:** Petrol, Diesel, Electric, Hybrid
- **Wheel Size:** Rim and tire specifications
- **Max Speed:** Top speed in km/h
- **Transmission:** Automatic, Manual, CVT, etc.
- **Horsepower:** Engine power in HP
- **Engine Displacement:** Engine size and configuration

### 3. Awards System

- **Award Management:** Add, edit, and delete vehicle awards
- **Event Details:** Event name, date, category, placement
- **Visual Display:** Trophy icons with count badges
- **Image Support:** Optional award photos/certificates
- **Admin Controls:** Admins can manage all awards

### 4. UI/UX Features

- **Responsive Design:** Works on all screen sizes
- **Smooth Animations:** Staggered fade-ins and slide effects
- **Loading States:** Skeleton loaders and shimmer effects
- **Empty States:** Encouraging messages for no data
- **Error Handling:** Graceful error states with retry options

## Color Scheme

The new design uses a dark automotive theme:

- **Background:** Dark blue/black gradient (#0a0e27 to #1a1e3f)
- **Cards:** Semi-transparent dark (#1e2340 with opacity)
- **Text:** White/light gray
- **Accents:** Electric blue (#00d4ff), Purple (#a855f7), Gold (#ffd700)
- **Glowing Effects:** BoxShadow with blur for premium feel

## Testing Checklist

- [ ] Vehicle with no photos shows placeholder
- [ ] Vehicle with multiple awards displays correctly
- [ ] Awards wrap properly on small screens
- [ ] Spec cards display with missing data gracefully
- [ ] Dark theme looks good on different devices
- [ ] Animations perform smoothly
- [ ] Awards navigation works correctly
- [ ] Add/edit award form validates properly
- [ ] Permissions: only owner/admin can edit

## Future Enhancements

1. **Award Verification:** Photo proof requirement for awards
2. **Leaderboard:** Most awarded vehicles in community
3. **Award Categories:** Gold/silver/bronze medal system
4. **Social Integration:** Share awards on social feed
5. **Export Features:** PDF certificates for awards
6. **QR Verification:** QR codes for authentic awards

## Troubleshooting

### Common Issues

1. **Auto Route Generation:** If routes aren't generated, run:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Permission Errors:** Ensure PocketBase permissions are set correctly for authenticated users

3. **Image Loading:** Check that PocketBase file URLs are properly constructed

4. **Animation Performance:** Reduce animation complexity on older devices if needed

### Support

For issues with the Vehicle Awards system:

1. Check PocketBase logs for API errors
2. Verify collection permissions
3. Test with sample data first
4. Check Flutter console for widget errors

## Sample Data

To test the system, create sample awards:

```json
{
  "vehicle_id": "vehicle_record_id",
  "award_name": "Best Modified Car",
  "event_name": "Manila Auto Show 2025",
  "event_date": "2025-03-15",
  "category": "Modified",
  "placement": "1st Place",
  "description": "Won for outstanding modifications and performance",
  "created_by": "user_record_id"
}
```

This completes the Vehicle Awards system setup. The system is now ready for members to showcase their car's achievements!
